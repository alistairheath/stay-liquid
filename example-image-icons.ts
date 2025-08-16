/**
 * Example usage of TabsBar with comprehensive imageIcon support
 * This file demonstrates the new imageIcon functionality with various formats and configurations
 */

import { TabsBar } from './src/index';

// Example 1: Base64 encoded images with different shapes and sizes
async function configureWithBase64Images() {
  // Sample base64 images (1x1 pixel PNGs for demonstration)
  const redPixel = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';
  const bluePixel = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChAFfeTFYuAAAAABJRU5ErkJggg==';
  const greenPixel = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

  await TabsBar.configure({
    items: [
      {
        id: 'home',
        title: 'Home',
        systemIcon: 'house', // Fallback if imageIcon fails
        imageIcon: {
          shape: 'circle',
          size: 'cover',
          image: redPixel
        }
      },
      {
        id: 'search',
        title: 'Search',
        systemIcon: 'magnifyingglass',
        imageIcon: {
          shape: 'square',
          size: 'fit',
          image: bluePixel
        }
      },
      {
        id: 'profile',
        title: 'Profile',
        systemIcon: 'person',
        imageIcon: {
          shape: 'circle',
          size: 'stretch',
          image: greenPixel
        }
      }
    ],
    initialId: 'home',
    visible: true,
    selectedIconColor: '#FF5733',
    unselectedIconColor: '#8E8E93'
  });
}

// Example 2: Remote URL images with error handling
async function configureWithRemoteImages() {
  await TabsBar.configure({
    items: [
      {
        id: 'dashboard',
        title: 'Dashboard',
        systemIcon: 'chart.bar', // Fallback for failed remote load
        imageIcon: {
          shape: 'square',
          size: 'cover',
          image: 'https://via.placeholder.com/30x30/FF5733/FFFFFF?text=D'
        }
      },
      {
        id: 'notifications',
        title: 'Alerts',
        systemIcon: 'bell',
        imageIcon: {
          shape: 'circle',
          size: 'fit',
          image: 'https://via.placeholder.com/30x30/007AFF/FFFFFF?text=N'
        },
        badge: 3
      },
      {
        id: 'settings',
        title: 'Settings',
        systemIcon: 'gear',
        imageIcon: {
          shape: 'square',
          size: 'stretch',
          image: 'https://via.placeholder.com/30x30/34C759/FFFFFF?text=S'
        }
      }
    ],
    initialId: 'dashboard',
    visible: true,
    selectedIconColor: 'rgba(0, 122, 255, 1.0)',
    unselectedIconColor: 'rgba(142, 142, 147, 0.6)'
  });
}

// Example 3: Mixed icon types (imageIcon, systemIcon, and image)
async function configureWithMixedIconTypes() {
  await TabsBar.configure({
    items: [
      {
        id: 'tab1',
        title: 'Image Icon',
        systemIcon: 'star', // Fallback
        imageIcon: {
          shape: 'circle',
          size: 'cover',
          image: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=='
        }
      },
      {
        id: 'tab2',
        title: 'System Icon',
        systemIcon: 'heart' // Uses SF Symbol
      },
      {
        id: 'tab3',
        title: 'Asset Image',
        image: 'custom-icon', // Uses bundled asset
        systemIcon: 'square' // Fallback if asset not found
      }
    ],
    initialId: 'tab1',
    visible: true
  });
}

// Example 4: Different image formats and sizes
async function configureWithVariousFormats() {
  await TabsBar.configure({
    items: [
      {
        id: 'png',
        title: 'PNG',
        systemIcon: 'photo',
        imageIcon: {
          shape: 'square',
          size: 'fit',
          image: 'https://via.placeholder.com/50x50.png/FF5733/FFFFFF?text=PNG'
        }
      },
      {
        id: 'jpg',
        title: 'JPEG',
        systemIcon: 'camera',
        imageIcon: {
          shape: 'circle',
          size: 'cover',
          image: 'https://via.placeholder.com/40x40.jpg/007AFF/FFFFFF?text=JPG'
        }
      },
      {
        id: 'webp',
        title: 'WebP',
        systemIcon: 'globe',
        imageIcon: {
          shape: 'square',
          size: 'stretch',
          image: 'https://via.placeholder.com/60x30.webp/34C759/FFFFFF?text=WEBP'
        }
      }
    ],
    initialId: 'png',
    visible: true,
    selectedIconColor: '#FF3B30',
    unselectedIconColor: '#C7C7CC'
  });
}

// Example 5: Error handling and fallback scenarios
async function configureWithErrorHandling() {
  await TabsBar.configure({
    items: [
      {
        id: 'valid',
        title: 'Valid',
        systemIcon: 'checkmark.circle',
        imageIcon: {
          shape: 'circle',
          size: 'fit',
          image: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=='
        }
      },
      {
        id: 'invalid-url',
        title: 'Invalid URL',
        systemIcon: 'xmark.circle', // Will fallback to this
        imageIcon: {
          shape: 'square',
          size: 'cover',
          image: 'https://invalid-domain-that-does-not-exist.com/image.png'
        }
      },
      {
        id: 'invalid-base64',
        title: 'Invalid Base64',
        systemIcon: 'exclamationmark.triangle', // Will fallback to this
        imageIcon: {
          shape: 'circle',
          size: 'fit',
          image: 'data:image/png;base64,invalid-base64-data'
        }
      },
      {
        id: 'unsupported-format',
        title: 'Unsupported',
        systemIcon: 'questionmark.circle', // Will fallback to this
        imageIcon: {
          shape: 'square',
          size: 'cover',
          image: 'https://example.com/image.bmp' // BMP not supported
        }
      }
    ],
    initialId: 'valid',
    visible: true
  });
}

// Example 6: Dynamic image loading with loading states
async function demonstrateLoadingStates() {
  // Configure with remote images
  await TabsBar.configure({
    items: [
      {
        id: 'slow-load',
        title: 'Slow Load',
        systemIcon: 'clock',
        imageIcon: {
          shape: 'circle',
          size: 'cover',
          image: 'https://httpbin.org/delay/2' // Simulates slow loading
        }
      },
      {
        id: 'fast-load',
        title: 'Fast Load',
        systemIcon: 'bolt',
        imageIcon: {
          shape: 'square',
          size: 'fit',
          image: 'https://via.placeholder.com/30x30/FF5733/FFFFFF?text=F'
        }
      }
    ],
    initialId: 'slow-load',
    visible: true
  });

  // Note: In a real app, you could check loading states like this:
  // const webPlugin = TabsBar as any; // Cast to access web-specific methods
  // if (webPlugin.getImageLoadingState) {
  //   console.log('Slow load state:', webPlugin.getImageLoadingState('slow-load'));
  //   console.log('Fast load state:', webPlugin.getImageLoadingState('fast-load'));
  // }
}

// Example 7: High-DPI/Retina display support
async function configureForHighDPI() {
  await TabsBar.configure({
    items: [
      {
        id: 'retina',
        title: 'Retina',
        systemIcon: 'eye',
        imageIcon: {
          shape: 'circle',
          size: 'cover',
          // Use 2x size image for retina displays
          image: 'https://via.placeholder.com/60x60/FF5733/FFFFFF?text=2X'
        }
      },
      {
        id: 'standard',
        title: 'Standard',
        systemIcon: 'display',
        imageIcon: {
          shape: 'square',
          size: 'fit',
          image: 'https://via.placeholder.com/30x30/007AFF/FFFFFF?text=1X'
        }
      }
    ],
    initialId: 'retina',
    visible: true
  });
}

// Example 8: Security considerations and CORS handling
async function demonstrateSecurityFeatures() {
  await TabsBar.configure({
    items: [
      {
        id: 'cors-enabled',
        title: 'CORS OK',
        systemIcon: 'shield.checkered',
        imageIcon: {
          shape: 'circle',
          size: 'cover',
          // This URL supports CORS
          image: 'https://via.placeholder.com/30x30/34C759/FFFFFF?text=OK'
        }
      },
      {
        id: 'cors-blocked',
        title: 'CORS Blocked',
        systemIcon: 'shield.slash', // Will fallback to this
        imageIcon: {
          shape: 'square',
          size: 'fit',
          // This might be blocked by CORS (example)
          image: 'https://some-domain-without-cors.com/image.png'
        }
      },
      {
        id: 'https-only',
        title: 'HTTPS Only',
        systemIcon: 'lock',
        imageIcon: {
          shape: 'circle',
          size: 'cover',
          // Only HTTPS URLs are allowed for security
          image: 'https://via.placeholder.com/30x30/FF9500/FFFFFF?text=SSL'
        }
      }
    ],
    initialId: 'cors-enabled',
    visible: true
  });
}

// Export all examples for testing
export {
  configureWithBase64Images,
  configureWithRemoteImages,
  configureWithMixedIconTypes,
  configureWithVariousFormats,
  configureWithErrorHandling,
  demonstrateLoadingStates,
  configureForHighDPI,
  demonstrateSecurityFeatures
};

// Usage instructions and feature summary
console.log(`
TabsBar ImageIcon Feature Examples:

🎨 SHAPE OPTIONS:
- "circle": Circular icon container
- "square": Square icon container (default)

📏 SIZE OPTIONS:
- "cover": Aspect fill - crops to fill container
- "stretch": Stretches image to fill container exactly
- "fit": Aspect fit - scales to fit within container

🖼️ IMAGE SOURCES:
- Base64 Data URIs: "data:image/png;base64,..."
- Remote URLs: "https://example.com/image.png"
- Supported formats: PNG, JPEG, SVG, WebP

🔒 SECURITY FEATURES:
- HTTPS-only for remote URLs
- CORS handling for cross-origin requests
- Content-type validation
- File size limits (5MB max)
- Format validation

⚡ PERFORMANCE FEATURES:
- Image caching for remote URLs
- Loading state management
- Automatic fallback to systemIcon
- Retina/high-DPI support

🛡️ ERROR HANDLING:
- Graceful fallback to systemIcon
- Invalid URL handling
- Network error recovery
- Unsupported format detection

EXAMPLES:
1. configureWithBase64Images() - Base64 encoded images
2. configureWithRemoteImages() - Remote URL images
3. configureWithMixedIconTypes() - Mixed icon types
4. configureWithVariousFormats() - Different image formats
5. configureWithErrorHandling() - Error scenarios
6. demonstrateLoadingStates() - Loading state management
7. configureForHighDPI() - Retina display support
8. demonstrateSecurityFeatures() - Security considerations

All configurations include proper validation, caching, and fallback handling.
Images load asynchronously with smooth transitions between states.
`);