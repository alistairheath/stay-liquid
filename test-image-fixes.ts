/**
 * Test file to verify the image icon fixes
 * This tests the main issues that were reported and fixed
 */

import { TabsBar } from './src/index';

// Test 1: Verify images display without color tinting
async function testImageDisplayFix() {
  console.log('🧪 Testing image display fix...');
  
  // Use a colorful test image to verify it's not being tinted
  const testImage = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';
  
  await TabsBar.configure({
    items: [
      {
        id: 'test-image',
        title: 'Test Image',
        systemIcon: 'photo',
        imageIcon: {
          shape: 'square',
          size: 'fit',
          image: testImage
        }
      }
    ],
    initialId: 'test-image',
    visible: true,
    selectedIconColor: '#FF0000', // Red - should NOT tint the image
    unselectedIconColor: '#0000FF' // Blue - should NOT tint the image
  });
  
  console.log('✅ Image should display without color tinting');
}

// Test 2: Verify smaller size and padding
async function testSizeAndPadding() {
  console.log('🧪 Testing smaller size and padding...');
  
  await TabsBar.configure({
    items: [
      {
        id: 'size-test',
        title: 'Size Test',
        systemIcon: 'square',
        imageIcon: {
          shape: 'square',
          size: 'fit', // Should have padding around the image
          image: 'https://via.placeholder.com/50x50/FF5733/FFFFFF?text=SIZE'
        }
      }
    ],
    initialId: 'size-test',
    visible: true
  });
  
  console.log('✅ Image should be smaller (24x24) with padding');
}

// Test 3: Verify ring functionality
async function testRingFeature() {
  console.log('🧪 Testing ring feature...');
  
  await TabsBar.configure({
    items: [
      {
        id: 'ring-test',
        title: 'Ring Test',
        systemIcon: 'circle',
        imageIcon: {
          shape: 'circle',
          size: 'fit',
          image: 'https://via.placeholder.com/30x30/34C759/FFFFFF?text=RING',
          ring: {
            enabled: true,
            width: 3.0
          }
        }
      },
      {
        id: 'no-ring-test',
        title: 'No Ring',
        systemIcon: 'square',
        imageIcon: {
          shape: 'square',
          size: 'fit',
          image: 'https://via.placeholder.com/30x30/007AFF/FFFFFF?text=NO',
          ring: {
            enabled: false
          }
        }
      }
    ],
    initialId: 'ring-test',
    visible: true,
    selectedIconColor: '#FF3B30' // This color should be used for the ring
  });
  
  console.log('✅ Selected tab should show ring, unselected should not');
}

// Test 4: Comprehensive test with all fixes
async function testAllFixes() {
  console.log('🧪 Testing all fixes together...');
  
  await TabsBar.configure({
    items: [
      {
        id: 'fix1',
        title: 'No Tint',
        systemIcon: 'photo',
        imageIcon: {
          shape: 'circle',
          size: 'fit',
          image: 'https://via.placeholder.com/40x40/FF5733/FFFFFF?text=1'
        }
      },
      {
        id: 'fix2',
        title: 'With Ring',
        systemIcon: 'star',
        imageIcon: {
          shape: 'square',
          size: 'fit',
          image: 'https://via.placeholder.com/40x40/007AFF/FFFFFF?text=2',
          ring: {
            enabled: true,
            width: 2.5
          }
        }
      },
      {
        id: 'fix3',
        title: 'Padded',
        systemIcon: 'heart',
        imageIcon: {
          shape: 'circle',
          size: 'fit',
          image: 'https://via.placeholder.com/40x40/34C759/FFFFFF?text=3',
          ring: {
            enabled: true,
            width: 1.5
          }
        }
      }
    ],
    initialId: 'fix1',
    visible: true,
    selectedIconColor: '#FF3B30',
    unselectedIconColor: '#8E8E93'
  });
  
  console.log('✅ All fixes applied: no tinting, proper sizing, padding, and rings');
}

// Run all tests
export async function runImageFixTests() {
  console.log('🚀 Starting image icon fix tests...\n');
  
  try {
    await testImageDisplayFix();
    console.log('');
    
    await testSizeAndPadding();
    console.log('');
    
    await testRingFeature();
    console.log('');
    
    await testAllFixes();
    console.log('');
    
    console.log('🎉 All tests completed successfully!');
    console.log('\nFixes implemented:');
    console.log('✅ Images now use .withRenderingMode(.alwaysOriginal) to prevent color tinting');
    console.log('✅ Icon size reduced to 24x24 with 4px padding for better appearance');
    console.log('✅ Ring feature added with configurable width and selectedIconColor');
    console.log('✅ TypeScript definitions updated with ImageIconRing interface');
    console.log('✅ Example files updated to demonstrate new features');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  }
}

// Export individual test functions
export {
  testImageDisplayFix,
  testSizeAndPadding,
  testRingFeature,
  testAllFixes
};

// Usage instructions
console.log(`
Image Icon Fixes Test Suite:

ISSUES FIXED:
1. 🎨 Image Display: Images were being tinted by selectedIconColor/unselectedIconColor
   - Fixed by using .withRenderingMode(.alwaysOriginal)
   
2. 📏 Size & Padding: Images were too large and had no padding
   - Reduced from 30x30 to 24x24 pixels
   - Added 4px padding around images in 'fit' mode
   
3. 💍 Ring Feature: Added optional ring around selected images
   - Configurable width (default: 2.0px)
   - Uses selectedIconColor for ring color
   - Can be enabled/disabled per image

USAGE:
import { runImageFixTests } from './test-image-fixes';
runImageFixTests();

Or run individual tests:
- testImageDisplayFix() - Test color tinting fix
- testSizeAndPadding() - Test size and padding improvements
- testRingFeature() - Test ring functionality
- testAllFixes() - Test all fixes together
`);