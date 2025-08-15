import { registerPlugin } from "@capacitor/core";
import type { TabsBarPlugin } from "./definitions";

export * from "./definitions";

/** Named export for the TabsBar plugin within the larger library */
export const TabsBar = registerPlugin<TabsBarPlugin>("TabsBar", {
  web: () => import("./web").then(m => new m.TabsBarWeb()),
});