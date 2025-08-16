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
var TabsBarWeb = class extends WebPlugin {
  async configure(options) {
    if (options.selectedIconColor && !isValidColor(options.selectedIconColor)) {
      console.warn(`TabsBar: Invalid selectedIconColor format: ${options.selectedIconColor}`);
    }
    if (options.unselectedIconColor && !isValidColor(options.unselectedIconColor)) {
      console.warn(`TabsBar: Invalid unselectedIconColor format: ${options.unselectedIconColor}`);
    }
  }
  async show() {
  }
  async hide() {
  }
  async select(_) {
  }
  async setBadge(_) {
  }
  async getSafeAreaInsets() {
    return { top: 0, bottom: 0, left: 0, right: 0 };
  }
};
export {
  TabsBarWeb
};
//# sourceMappingURL=web-DTLT6OPN.js.map