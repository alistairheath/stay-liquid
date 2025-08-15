// src/components/tabs/index.ts
import { registerPlugin } from "@capacitor/core";
var TabsBar = registerPlugin("TabsBar", {
  web: () => import("./web-3WV5UORC.js").then((m) => new m.TabsBarWeb())
});
export {
  TabsBar
};
//# sourceMappingURL=index.js.map