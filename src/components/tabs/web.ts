import { WebPlugin } from "@capacitor/core";
import type {
  TabsBarPlugin,
  TabsBarConfigureOptions,
  SelectOptions,
  SetBadgeOptions,
  SafeAreaInsets
} from "./definitions";
import { isValidColor } from "./color-utils";

export class TabsBarWeb extends WebPlugin implements TabsBarPlugin {
  async configure(options: TabsBarConfigureOptions): Promise<void> {
    // Validate color options if provided
    if (options.selectedIconColor && !isValidColor(options.selectedIconColor)) {
      console.warn(`TabsBar: Invalid selectedIconColor format: ${options.selectedIconColor}`);
    }
    if (options.unselectedIconColor && !isValidColor(options.unselectedIconColor)) {
      console.warn(`TabsBar: Invalid unselectedIconColor format: ${options.unselectedIconColor}`);
    }
    // Web implementation is no-op, but we validate for consistency
  }
  async show(): Promise<void> {}
  async hide(): Promise<void> {}
  async select(_: SelectOptions): Promise<void> {}
  async setBadge(_: SetBadgeOptions): Promise<void> {}
  async getSafeAreaInsets(): Promise<SafeAreaInsets> {
    return { top: 0, bottom: 0, left: 0, right: 0 };
  }
}