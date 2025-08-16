/**
 * Color validation utilities for TabsBar configuration
 */

/**
 * Validates if a string is a valid hex color code
 * @param color - The color string to validate
 * @returns true if valid hex color, false otherwise
 */
export function isValidHexColor(color: string): boolean {
  const hexRegex = /^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$/;
  return hexRegex.test(color);
}

/**
 * Validates if a string is a valid RGBA color code
 * @param color - The color string to validate
 * @returns true if valid RGBA color, false otherwise
 */
export function isValidRgbaColor(color: string): boolean {
  const rgbaRegex = /^rgba?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*(?:,\s*([01](?:\.\d+)?))?\s*\)$/i;
  
  const match = color.match(rgbaRegex);
  if (!match) return false;
  
  const [, r, g, b, a] = match;
  const red = parseFloat(r);
  const green = parseFloat(g);
  const blue = parseFloat(b);
  const alpha = a ? parseFloat(a) : 1;
  
  return (
    red >= 0 && red <= 255 &&
    green >= 0 && green <= 255 &&
    blue >= 0 && blue <= 255 &&
    alpha >= 0 && alpha <= 1
  );
}

/**
 * Validates if a string is a valid color (hex or RGBA)
 * @param color - The color string to validate
 * @returns true if valid color format, false otherwise
 */
export function isValidColor(color: string): boolean {
  if (!color || typeof color !== 'string') return false;
  return isValidHexColor(color) || isValidRgbaColor(color);
}

/**
 * Converts hex color to RGBA format
 * @param hex - Hex color string (e.g., "#FF5733" or "#F57")
 * @param alpha - Optional alpha value (0-1), defaults to 1
 * @returns RGBA color string or null if invalid hex
 */
export function hexToRgba(hex: string, alpha: number = 1): string | null {
  if (!isValidHexColor(hex)) return null;
  
  // Remove # if present
  hex = hex.replace('#', '');
  
  // Handle 3-digit hex
  if (hex.length === 3) {
    hex = hex.split('').map(char => char + char).join('');
  }
  
  // Handle 8-digit hex (with alpha)
  if (hex.length === 8) {
    const alphaHex = hex.slice(6, 8);
    alpha = parseInt(alphaHex, 16) / 255;
    hex = hex.slice(0, 6);
  }
  
  const r = parseInt(hex.slice(0, 2), 16);
  const g = parseInt(hex.slice(2, 4), 16);
  const b = parseInt(hex.slice(4, 6), 16);
  
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

/**
 * Normalizes a color string to a consistent format for native processing
 * @param color - Color string in hex or RGBA format
 * @returns Normalized color object with r, g, b, a values (0-1 range) or null if invalid
 */
export function normalizeColor(color: string): { r: number; g: number; b: number; a: number } | null {
  if (!color || typeof color !== 'string') return null;
  
  if (isValidHexColor(color)) {
    const rgba = hexToRgba(color);
    if (!rgba) return null;
    color = rgba;
  }
  
  if (isValidRgbaColor(color)) {
    const match = color.match(/^rgba?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*(?:,\s*([01](?:\.\d+)?))?\s*\)$/i);
    if (!match) return null;
    
    const [, r, g, b, a] = match;
    return {
      r: parseFloat(r) / 255,
      g: parseFloat(g) / 255,
      b: parseFloat(b) / 255,
      a: a ? parseFloat(a) : 1
    };
  }
  
  return null;
}