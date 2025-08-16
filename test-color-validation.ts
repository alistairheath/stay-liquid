/**
 * Test file for color validation utilities
 * Run this to verify color parsing and validation works correctly
 */

import { 
  isValidHexColor, 
  isValidRgbaColor, 
  isValidColor, 
  hexToRgba, 
  normalizeColor 
} from './src/components/tabs/color-utils';

// Test cases for hex color validation
const hexTestCases = [
  // Valid hex colors
  { color: '#FF5733', expected: true, description: '6-digit hex with #' },
  { color: '#F57', expected: true, description: '3-digit hex with #' },
  { color: '#FF5733FF', expected: true, description: '8-digit hex with alpha' },
  { color: 'FF5733', expected: false, description: '6-digit hex without #' },
  
  // Invalid hex colors
  { color: '#GG5733', expected: false, description: 'Invalid hex characters' },
  { color: '#FF57', expected: false, description: 'Invalid length (4 digits)' },
  { color: '#FF573', expected: false, description: 'Invalid length (5 digits)' },
  { color: '', expected: false, description: 'Empty string' },
  { color: '#', expected: false, description: 'Just hash symbol' }
];

// Test cases for RGBA color validation
const rgbaTestCases = [
  // Valid RGBA colors
  { color: 'rgba(255, 87, 51, 1)', expected: true, description: 'Standard RGBA' },
  { color: 'rgba(255, 87, 51, 0.8)', expected: true, description: 'RGBA with decimal alpha' },
  { color: 'rgb(255, 87, 51)', expected: true, description: 'RGB without alpha' },
  { color: 'rgba(0, 0, 0, 0)', expected: true, description: 'Transparent black' },
  { color: 'RGBA(255, 87, 51, 1)', expected: true, description: 'Uppercase RGBA' },
  
  // Invalid RGBA colors
  { color: 'rgba(256, 87, 51, 1)', expected: false, description: 'Red value > 255' },
  { color: 'rgba(255, 87, 51, 1.5)', expected: false, description: 'Alpha > 1' },
  { color: 'rgba(255, 87, 51, -0.1)', expected: false, description: 'Negative alpha' },
  { color: 'rgba(255, 87)', expected: false, description: 'Missing values' },
  { color: 'rgba(255, 87, 51, 1, 1)', expected: false, description: 'Too many values' }
];

// Test cases for hex to RGBA conversion
const hexToRgbaTestCases = [
  { hex: '#FF5733', expected: 'rgba(255, 87, 51, 1)', description: '6-digit hex' },
  { hex: '#F57', expected: 'rgba(255, 85, 119, 1)', description: '3-digit hex expansion' },
  { hex: '#FF573380', expected: 'rgba(255, 87, 51, 0.5019607843137255)', description: '8-digit hex with alpha' },
  { hex: 'invalid', expected: null, description: 'Invalid hex' }
];

// Test cases for color normalization
const normalizeTestCases = [
  { 
    color: '#FF5733', 
    expected: { r: 1, g: 0.3411764705882353, b: 0.2, a: 1 }, 
    description: 'Hex to normalized' 
  },
  { 
    color: 'rgba(255, 87, 51, 0.8)', 
    expected: { r: 1, g: 0.3411764705882353, b: 0.2, a: 0.8 }, 
    description: 'RGBA to normalized' 
  },
  { 
    color: 'invalid-color', 
    expected: null, 
    description: 'Invalid color' 
  }
];

// Run tests
function runTests() {
  console.log('🧪 Running Color Validation Tests\n');
  
  let totalTests = 0;
  let passedTests = 0;
  
  // Test hex validation
  console.log('📋 Testing Hex Color Validation:');
  hexTestCases.forEach(testCase => {
    totalTests++;
    const result = isValidHexColor(testCase.color);
    const passed = result === testCase.expected;
    if (passed) passedTests++;
    
    console.log(`${passed ? '✅' : '❌'} ${testCase.description}: "${testCase.color}" -> ${result} (expected: ${testCase.expected})`);
  });
  
  console.log('\n📋 Testing RGBA Color Validation:');
  rgbaTestCases.forEach(testCase => {
    totalTests++;
    const result = isValidRgbaColor(testCase.color);
    const passed = result === testCase.expected;
    if (passed) passedTests++;
    
    console.log(`${passed ? '✅' : '❌'} ${testCase.description}: "${testCase.color}" -> ${result} (expected: ${testCase.expected})`);
  });
  
  console.log('\n📋 Testing General Color Validation:');
  const generalTestCases = [
    ...hexTestCases.map(tc => ({ ...tc, color: tc.color })),
    ...rgbaTestCases.map(tc => ({ ...tc, color: tc.color }))
  ];
  
  generalTestCases.forEach(testCase => {
    totalTests++;
    const result = isValidColor(testCase.color);
    const passed = result === testCase.expected;
    if (passed) passedTests++;
    
    console.log(`${passed ? '✅' : '❌'} ${testCase.description}: "${testCase.color}" -> ${result} (expected: ${testCase.expected})`);
  });
  
  console.log('\n📋 Testing Hex to RGBA Conversion:');
  hexToRgbaTestCases.forEach(testCase => {
    totalTests++;
    const result = hexToRgba(testCase.hex);
    const passed = result === testCase.expected;
    if (passed) passedTests++;
    
    console.log(`${passed ? '✅' : '❌'} ${testCase.description}: "${testCase.hex}" -> ${result} (expected: ${testCase.expected})`);
  });
  
  console.log('\n📋 Testing Color Normalization:');
  normalizeTestCases.forEach(testCase => {
    totalTests++;
    const result = normalizeColor(testCase.color);
    const passed = JSON.stringify(result) === JSON.stringify(testCase.expected);
    if (passed) passedTests++;
    
    console.log(`${passed ? '✅' : '❌'} ${testCase.description}: "${testCase.color}"`);
    console.log(`   Result: ${JSON.stringify(result)}`);
    console.log(`   Expected: ${JSON.stringify(testCase.expected)}`);
  });
  
  // Summary
  console.log(`\n📊 Test Summary:`);
  console.log(`Total Tests: ${totalTests}`);
  console.log(`Passed: ${passedTests}`);
  console.log(`Failed: ${totalTests - passedTests}`);
  console.log(`Success Rate: ${((passedTests / totalTests) * 100).toFixed(1)}%`);
  
  if (passedTests === totalTests) {
    console.log('\n🎉 All tests passed! Color validation is working correctly.');
  } else {
    console.log('\n⚠️  Some tests failed. Please check the implementation.');
  }
}

// Export for use in other files
export { runTests };

// Run tests if this file is executed directly (Node.js environment)
if (typeof window === 'undefined') {
  runTests();
}