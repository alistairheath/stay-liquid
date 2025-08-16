"use strict";
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __esm = (fn, res) => function __init() {
  return fn && (res = (0, fn[__getOwnPropNames(fn)[0]])(fn = 0)), res;
};
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

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
var init_color_utils = __esm({
  "src/components/tabs/color-utils.ts"() {
    "use strict";
  }
});

// src/components/tabs/web.ts
var web_exports = {};
__export(web_exports, {
  TabsBarWeb: () => TabsBarWeb
});
var import_core, TabsBarWeb;
var init_web = __esm({
  "src/components/tabs/web.ts"() {
    "use strict";
    import_core = require("@capacitor/core");
    init_color_utils();
    TabsBarWeb = class extends import_core.WebPlugin {
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
  }
});

// src/index.ts
var index_exports = {};
__export(index_exports, {
  TabsBar: () => TabsBar
});
module.exports = __toCommonJS(index_exports);

// src/components/tabs/index.ts
var import_core2 = require("@capacitor/core");
var TabsBar = (0, import_core2.registerPlugin)("TabsBar", {
  web: () => Promise.resolve().then(() => (init_web(), web_exports)).then((m) => new m.TabsBarWeb())
});
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  TabsBar
});
//# sourceMappingURL=index.cjs.map