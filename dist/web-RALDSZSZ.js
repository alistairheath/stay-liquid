// src/components/tabs/web.ts
import { WebPlugin } from "@capacitor/core";

// src/components/tabs/color-utils.ts
function isValidHexColor(color) {
  const hexRegex = /^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$/;
  return hexRegex.test(color);
}
function isValidRgbaColor(color) {
  const rgbaRegex = /^rgba?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*(?:,\s*([01](?:\.\d+)?))?\s*\)$/i;
  const match = color.match(rgbaRegex);
  if (!match) return false;
  const [, r, g, b, a] = match;
  const red = parseFloat(r);
  const green = parseFloat(g);
  const blue = parseFloat(b);
  const alpha = a ? parseFloat(a) : 1;
  return red >= 0 && red <= 255 && green >= 0 && green <= 255 && blue >= 0 && blue <= 255 && alpha >= 0 && alpha <= 1;
}
function isValidColor(color) {
  if (!color || typeof color !== "string") return false;
  return isValidHexColor(color) || isValidRgbaColor(color);
}

// src/components/tabs/web.ts
var ImageValidator = class {
  // 5MB
  static isValidImageFormat(contentType) {
    return this.SUPPORTED_FORMATS.includes(contentType.toLowerCase());
  }
  static isValidBase64DataUri(dataUri) {
    const base64Pattern = /^data:image\/(png|jpeg|jpg|svg\+xml|webp);base64,/i;
    return base64Pattern.test(dataUri);
  }
  static isValidHttpUrl(url) {
    try {
      const urlObj = new URL(url);
      return urlObj.protocol === "http:" || urlObj.protocol === "https:";
    } catch {
      return false;
    }
  }
  static validateImageSize(blob) {
    return blob.size <= this.MAX_FILE_SIZE;
  }
};
ImageValidator.SUPPORTED_FORMATS = ["image/png", "image/jpeg", "image/jpg", "image/svg+xml", "image/webp"];
ImageValidator.MAX_FILE_SIZE = 5 * 1024 * 1024;
var ImageManager = class {
  static async loadImage(imageIcon) {
    const { image } = imageIcon;
    if (ImageValidator.isValidBase64DataUri(image)) {
      return image;
    }
    if (ImageValidator.isValidHttpUrl(image)) {
      return this.loadRemoteImage(image);
    }
    throw new Error(`Invalid image source: ${image}`);
  }
  static async loadRemoteImage(url) {
    if (this.loadingPromises.has(url)) {
      return this.loadingPromises.get(url);
    }
    const cached = this.cache.get(url);
    if (cached && Date.now() - cached.timestamp < this.CACHE_DURATION) {
      return cached.objectUrl;
    }
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
  static async fetchAndCacheImage(url) {
    try {
      const response = await fetch(url, {
        method: "GET",
        mode: "cors",
        cache: "default",
        headers: {
          "Accept": "image/*"
        }
      });
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      const contentType = response.headers.get("content-type") || "";
      if (!ImageValidator.isValidImageFormat(contentType)) {
        throw new Error(`Unsupported image format: ${contentType}`);
      }
      const blob = await response.blob();
      if (!ImageValidator.validateImageSize(blob)) {
        throw new Error("Image file too large");
      }
      const oldCached = this.cache.get(url);
      if (oldCached) {
        URL.revokeObjectURL(oldCached.objectUrl);
      }
      const objectUrl = URL.createObjectURL(blob);
      const cached = {
        url,
        blob,
        timestamp: Date.now(),
        objectUrl
      };
      this.cache.set(url, cached);
      this.cleanupCache();
      return objectUrl;
    } catch (error) {
      throw new Error(`Failed to load image from ${url}: ${error instanceof Error ? error.message : "Unknown error"}`);
    }
  }
  static cleanupCache() {
    const now = Date.now();
    for (const [url, cached] of this.cache.entries()) {
      if (now - cached.timestamp > this.CACHE_DURATION) {
        URL.revokeObjectURL(cached.objectUrl);
        this.cache.delete(url);
      }
    }
  }
  static clearCache() {
    for (const cached of this.cache.values()) {
      URL.revokeObjectURL(cached.objectUrl);
    }
    this.cache.clear();
    this.loadingPromises.clear();
  }
};
ImageManager.cache = /* @__PURE__ */ new Map();
ImageManager.CACHE_DURATION = 24 * 60 * 60 * 1e3;
// 24 hours
ImageManager.loadingPromises = /* @__PURE__ */ new Map();
var TabsBarWeb = class extends WebPlugin {
  constructor() {
    super(...arguments);
    this.loadingStates = /* @__PURE__ */ new Map();
    this.imageLoadPromises = /* @__PURE__ */ new Map();
  }
  async configure(options) {
    if (options.selectedIconColor && !isValidColor(options.selectedIconColor)) {
      console.warn(`TabsBar: Invalid selectedIconColor format: ${options.selectedIconColor}`);
    }
    if (options.unselectedIconColor && !isValidColor(options.unselectedIconColor)) {
      console.warn(`TabsBar: Invalid unselectedIconColor format: ${options.unselectedIconColor}`);
    }
    await this.validateAndPreloadImages(options.items);
    console.log("TabsBar configured with options:", {
      itemCount: options.items.length,
      initialId: options.initialId,
      visible: options.visible,
      hasSelectedColor: !!options.selectedIconColor,
      hasUnselectedColor: !!options.unselectedIconColor
    });
  }
  async validateAndPreloadImages(items) {
    const imagePromises = items.filter((item) => item.imageIcon).map((item) => this.preloadItemImage(item));
    await Promise.allSettled(imagePromises);
  }
  async preloadItemImage(item) {
    if (!item.imageIcon) return;
    const { id } = item;
    const { imageIcon } = item;
    if (this.imageLoadPromises.has(id)) {
      return this.imageLoadPromises.get(id);
    }
    this.loadingStates.set(id, "loading");
    const loadPromise = this.loadImageIcon(imageIcon).then(() => {
      this.loadingStates.set(id, "loaded");
      console.log(`TabsBar: Successfully loaded image for tab ${id}`);
    }).catch((error) => {
      this.loadingStates.set(id, "error");
      console.warn(`TabsBar: Failed to load image for tab ${id}:`, error.message);
      if (item.systemIcon) {
        console.log(`TabsBar: Using systemIcon fallback for tab ${id}: ${item.systemIcon}`);
      } else {
        console.warn(`TabsBar: No fallback available for tab ${id}`);
      }
    }).finally(() => {
      this.imageLoadPromises.delete(id);
    });
    this.imageLoadPromises.set(id, loadPromise);
    return loadPromise;
  }
  async loadImageIcon(imageIcon) {
    try {
      return await ImageManager.loadImage(imageIcon);
    } catch (error) {
      throw new Error(`Image loading failed: ${error instanceof Error ? error.message : "Unknown error"}`);
    }
  }
  /** Get the loading state of an image for a specific tab */
  getImageLoadingState(tabId) {
    return this.loadingStates.get(tabId);
  }
  /** Clear all cached images */
  clearImageCache() {
    ImageManager.clearCache();
    this.loadingStates.clear();
    this.imageLoadPromises.clear();
  }
  async show() {
    console.log("TabsBar: show() called");
  }
  async hide() {
    console.log("TabsBar: hide() called");
  }
  async select(options) {
    console.log("TabsBar: select() called with id:", options.id);
  }
  async setBadge(options) {
    console.log("TabsBar: setBadge() called with:", options);
  }
  async getSafeAreaInsets() {
    return { top: 0, bottom: 0, left: 0, right: 0 };
  }
};
export {
  TabsBarWeb
};
//# sourceMappingURL=web-RALDSZSZ.js.map