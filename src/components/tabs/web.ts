import { WebPlugin } from "@capacitor/core";
import type {
  TabsBarPlugin,
  TabsBarConfigureOptions,
  SelectOptions,
  SetBadgeOptions,
  SafeAreaInsets,
  TabItem,
  ImageIcon,
  ImageLoadingState
} from "./definitions";
import { isValidColor } from "./color-utils";

/** Image cache for remote URLs */
interface CachedImage {
  url: string;
  blob: Blob;
  timestamp: number;
  objectUrl: string;
}

/** Image validation utilities */
class ImageValidator {
  private static readonly SUPPORTED_FORMATS = ['image/png', 'image/jpeg', 'image/jpg', 'image/svg+xml', 'image/webp'];
  private static readonly MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
  
  static isValidImageFormat(contentType: string): boolean {
    return this.SUPPORTED_FORMATS.includes(contentType.toLowerCase());
  }
  
  static isValidBase64DataUri(dataUri: string): boolean {
    const base64Pattern = /^data:image\/(png|jpeg|jpg|svg\+xml|webp);base64,/i;
    return base64Pattern.test(dataUri);
  }
  
  static isValidHttpUrl(url: string): boolean {
    try {
      const urlObj = new URL(url);
      return urlObj.protocol === 'http:' || urlObj.protocol === 'https:';
    } catch {
      return false;
    }
  }
  
  static validateImageSize(blob: Blob): boolean {
    return blob.size <= this.MAX_FILE_SIZE;
  }
}

/** Image loading and caching manager */
class ImageManager {
  private static cache = new Map<string, CachedImage>();
  private static readonly CACHE_DURATION = 24 * 60 * 60 * 1000; // 24 hours
  private static loadingPromises = new Map<string, Promise<string>>();
  
  static async loadImage(imageIcon: ImageIcon): Promise<string> {
    const { image } = imageIcon;
    
    // Handle base64 data URIs
    if (ImageValidator.isValidBase64DataUri(image)) {
      return image;
    }
    
    // Handle remote URLs
    if (ImageValidator.isValidHttpUrl(image)) {
      return this.loadRemoteImage(image);
    }
    
    throw new Error(`Invalid image source: ${image}`);
  }
  
  private static async loadRemoteImage(url: string): Promise<string> {
    // Check if already loading
    if (this.loadingPromises.has(url)) {
      return this.loadingPromises.get(url)!;
    }
    
    // Check cache first
    const cached = this.cache.get(url);
    if (cached && (Date.now() - cached.timestamp) < this.CACHE_DURATION) {
      return cached.objectUrl;
    }
    
    // Create loading promise
    const loadingPromise = this.fetchAndCacheImage(url);
    this.loadingPromises.set(url, loadingPromise);
    
    try {
      const result = await loadingPromise;
      this.loadingPromises.delete(url);
      return result;
    } catch (error) {
      this.loadingPromises.delete(url);
      throw error;
    }
  }
  
  private static async fetchAndCacheImage(url: string): Promise<string> {
    try {
      const response = await fetch(url, {
        method: 'GET',
        mode: 'cors',
        cache: 'default',
        headers: {
          'Accept': 'image/*'
        }
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      const contentType = response.headers.get('content-type') || '';
      if (!ImageValidator.isValidImageFormat(contentType)) {
        throw new Error(`Unsupported image format: ${contentType}`);
      }
      
      const blob = await response.blob();
      if (!ImageValidator.validateImageSize(blob)) {
        throw new Error('Image file too large');
      }
      
      // Clean up old cache entry if exists
      const oldCached = this.cache.get(url);
      if (oldCached) {
        URL.revokeObjectURL(oldCached.objectUrl);
      }
      
      // Create new cache entry
      const objectUrl = URL.createObjectURL(blob);
      const cached: CachedImage = {
        url,
        blob,
        timestamp: Date.now(),
        objectUrl
      };
      
      this.cache.set(url, cached);
      
      // Clean up old cache entries periodically
      this.cleanupCache();
      
      return objectUrl;
    } catch (error) {
      throw new Error(`Failed to load image from ${url}: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }
  
  private static cleanupCache(): void {
    const now = Date.now();
    for (const [url, cached] of this.cache.entries()) {
      if (now - cached.timestamp > this.CACHE_DURATION) {
        URL.revokeObjectURL(cached.objectUrl);
        this.cache.delete(url);
      }
    }
  }
  
  static clearCache(): void {
    for (const cached of this.cache.values()) {
      URL.revokeObjectURL(cached.objectUrl);
    }
    this.cache.clear();
    this.loadingPromises.clear();
  }
}

export class TabsBarWeb extends WebPlugin implements TabsBarPlugin {
  private loadingStates = new Map<string, ImageLoadingState>();
  private imageLoadPromises = new Map<string, Promise<void>>();
  
  async configure(options: TabsBarConfigureOptions): Promise<void> {
    // Validate color options if provided
    if (options.selectedIconColor && !isValidColor(options.selectedIconColor)) {
      console.warn(`TabsBar: Invalid selectedIconColor format: ${options.selectedIconColor}`);
    }
    if (options.unselectedIconColor && !isValidColor(options.unselectedIconColor)) {
      console.warn(`TabsBar: Invalid unselectedIconColor format: ${options.unselectedIconColor}`);
    }
    
    // Validate and preload images
    await this.validateAndPreloadImages(options.items);
    
    // Web implementation logs configuration for debugging
    console.log('TabsBar configured with options:', {
      itemCount: options.items.length,
      initialId: options.initialId,
      visible: options.visible,
      hasSelectedColor: !!options.selectedIconColor,
      hasUnselectedColor: !!options.unselectedIconColor
    });
  }
  
  private async validateAndPreloadImages(items: TabItem[]): Promise<void> {
    const imagePromises = items
      .filter(item => item.imageIcon)
      .map(item => this.preloadItemImage(item));
    
    await Promise.allSettled(imagePromises);
  }
  
  private async preloadItemImage(item: TabItem): Promise<void> {
    if (!item.imageIcon) return;
    
    const { id } = item;
    const { imageIcon } = item;
    
    // Skip if already loading
    if (this.imageLoadPromises.has(id)) {
      return this.imageLoadPromises.get(id);
    }
    
    this.loadingStates.set(id, 'loading');
    
    const loadPromise = this.loadImageIcon(imageIcon)
      .then(() => {
        this.loadingStates.set(id, 'loaded');
        console.log(`TabsBar: Successfully loaded image for tab ${id}`);
      })
      .catch((error) => {
        this.loadingStates.set(id, 'error');
        console.warn(`TabsBar: Failed to load image for tab ${id}:`, error.message);
        
        // Fallback to system icon if available
        if (item.systemIcon) {
          console.log(`TabsBar: Using systemIcon fallback for tab ${id}: ${item.systemIcon}`);
        } else {
          console.warn(`TabsBar: No fallback available for tab ${id}`);
        }
      })
      .finally(() => {
        this.imageLoadPromises.delete(id);
      });
    
    this.imageLoadPromises.set(id, loadPromise);
    return loadPromise;
  }
  
  private async loadImageIcon(imageIcon: ImageIcon): Promise<string> {
    try {
      return await ImageManager.loadImage(imageIcon);
    } catch (error) {
      throw new Error(`Image loading failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }
  
  /** Get the loading state of an image for a specific tab */
  getImageLoadingState(tabId: string): ImageLoadingState | undefined {
    return this.loadingStates.get(tabId);
  }
  
  /** Clear all cached images */
  clearImageCache(): void {
    ImageManager.clearCache();
    this.loadingStates.clear();
    this.imageLoadPromises.clear();
  }
  
  async show(): Promise<void> {
    console.log('TabsBar: show() called');
  }
  
  async hide(): Promise<void> {
    console.log('TabsBar: hide() called');
  }
  
  async select(options: SelectOptions): Promise<void> {
    console.log('TabsBar: select() called with id:', options.id);
  }
  
  async setBadge(options: SetBadgeOptions): Promise<void> {
    console.log('TabsBar: setBadge() called with:', options);
  }
  
  async getSafeAreaInsets(): Promise<SafeAreaInsets> {
    return { top: 0, bottom: 0, left: 0, right: 0 };
  }
}