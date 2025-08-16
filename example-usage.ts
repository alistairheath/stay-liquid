/**
 * Example usage of TabsBar with dynamic color configuration
 * This file demonstrates how to use the new color configuration features
 */

import { TabsBar } from './src/index';

// Example 1: Basic configuration with hex colors
async function configureWithHexColors() {
  await TabsBar.configure({
    items: [
      {
        id: 'home',
        title: 'Home',
        systemIcon: 'house',
      },
      {
        id: 'search',
        title: 'Search',
        systemIcon: 'magnifyingglass',
      },
      {
        id: 'profile',
        title: 'Profile',
        systemIcon: 'person',
      }
    ],
    initialId: 'home',
    visible: true,
    // Hex color examples
    selectedIconColor: '#FF5733',      // Orange-red for selected tab
    unselectedIconColor: '#8E8E93'     // Gray for unselected tabs
  });
}

// Example 2: Configuration with RGBA colors
async function configureWithRgbaColors() {
  await TabsBar.configure({
    items: [
      {
        id: 'dashboard',
        title: 'Dashboard',
        systemIcon: 'chart.bar',
      },
      {
        id: 'notifications',
        title: 'Alerts',
        systemIcon: 'bell',
        badge: 3
      },
      {
        id: 'settings',
        title: 'Settings',
        systemIcon: 'gear',
      }
    ],
    initialId: 'dashboard',
    visible: true,
    // RGBA color examples
    selectedIconColor: 'rgba(0, 122, 255, 1.0)',    // Blue with full opacity
    unselectedIconColor: 'rgba(142, 142, 147, 0.6)' // Gray with 60% opacity
  });
}

// Example 3: Configuration with 3-digit hex colors
async function configureWithShortHexColors() {
  await TabsBar.configure({
    items: [
      {
        id: 'tab1',
        title: 'Tab 1',
        systemIcon: 'star',
      },
      {
        id: 'tab2',
        title: 'Tab 2',
        systemIcon: 'heart',
      }
    ],
    initialId: 'tab1',
    visible: true,
    // Short hex color examples
    selectedIconColor: '#F57',    // Expands to #FF5577
    unselectedIconColor: '#999'   // Expands to #999999
  });
}

// Example 4: Configuration with 8-digit hex colors (including alpha)
async function configureWithAlphaHexColors() {
  await TabsBar.configure({
    items: [
      {
        id: 'music',
        title: 'Music',
        systemIcon: 'music.note',
      },
      {
        id: 'video',
        title: 'Video',
        systemIcon: 'video',
      }
    ],
    initialId: 'music',
    visible: true,
    // 8-digit hex colors with alpha channel
    selectedIconColor: '#FF5733FF',    // Orange-red with full opacity
    unselectedIconColor: '#8E8E9380'   // Gray with 50% opacity (128/255)
  });
}

// Example 5: Configuration with invalid colors (fallback handling)
async function configureWithInvalidColors() {
  await TabsBar.configure({
    items: [
      {
        id: 'test1',
        title: 'Test 1',
        systemIcon: 'checkmark',
      },
      {
        id: 'test2',
        title: 'Test 2',
        systemIcon: 'xmark',
      }
    ],
    initialId: 'test1',
    visible: true,
    // These invalid colors will trigger warnings and use system defaults
    selectedIconColor: 'invalid-color',           // Invalid - will use default
    unselectedIconColor: 'rgba(300, 300, 300, 1)' // Invalid RGB values - will use default
  });
}

// Example 6: Dynamic color changes
async function dynamicColorChanges() {
  // Initial configuration
  await TabsBar.configure({
    items: [
      {
        id: 'dynamic1',
        title: 'Dynamic 1',
        systemIcon: 'circle',
      },
      {
        id: 'dynamic2',
        title: 'Dynamic 2',
        systemIcon: 'square',
      }
    ],
    initialId: 'dynamic1',
    visible: true,
    selectedIconColor: '#007AFF',
    unselectedIconColor: '#8E8E93'
  });

  // Change colors after 3 seconds
  setTimeout(async () => {
    await TabsBar.configure({
      items: [
        {
          id: 'dynamic1',
          title: 'Dynamic 1',
          systemIcon: 'circle',
        },
        {
          id: 'dynamic2',
          title: 'Dynamic 2',
          systemIcon: 'square',
        }
      ],
      initialId: 'dynamic1',
      visible: true,
      selectedIconColor: '#FF3B30',      // Change to red
      unselectedIconColor: '#C7C7CC'     // Change to lighter gray
    });
  }, 3000);
}

// Example 7: Configuration without colors (uses system defaults)
async function configureWithoutColors() {
  await TabsBar.configure({
    items: [
      {
        id: 'default1',
        title: 'Default 1',
        systemIcon: 'house',
      },
      {
        id: 'default2',
        title: 'Default 2',
        systemIcon: 'person',
      }
    ],
    initialId: 'default1',
    visible: true
    // No color properties - will use system defaults
  });
}

// Export all examples for testing
export {
  configureWithHexColors,
  configureWithRgbaColors,
  configureWithShortHexColors,
  configureWithAlphaHexColors,
  configureWithInvalidColors,
  dynamicColorChanges,
  configureWithoutColors
};

// Usage instructions:
console.log(`
TabsBar Color Configuration Examples:

1. Hex Colors: configureWithHexColors()
   - Uses standard 6-digit hex colors like #FF5733

2. RGBA Colors: configureWithRgbaColors()
   - Uses rgba() format with alpha transparency

3. Short Hex: configureWithShortHexColors()
   - Uses 3-digit hex colors that expand to 6-digit

4. Alpha Hex: configureWithAlphaHexColors()
   - Uses 8-digit hex colors with alpha channel

5. Invalid Colors: configureWithInvalidColors()
   - Demonstrates fallback behavior for invalid colors

6. Dynamic Changes: dynamicColorChanges()
   - Shows how to change colors dynamically

7. System Defaults: configureWithoutColors()
   - Uses system default colors when no colors specified

All configurations include proper validation and fallback handling.
Colors apply immediately and persist across tab selections.
`);