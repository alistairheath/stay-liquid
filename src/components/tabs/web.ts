import { WebPlugin } from "@capacitor/core";
import type {
  TabsBarPlugin,
  TabsBarConfigureOptions,
  SelectOptions,
  SetBadgeOptions,
  SafeAreaInsets
} from "./definitions";

export class TabsBarWeb extends WebPlugin implements TabsBarPlugin {
  async configure(_: TabsBarConfigureOptions): Promise<void> { /* no-op */ }
  async show(): Promise<void> {}
  async hide(): Promise<void> {}
  async select(_: SelectOptions): Promise<void> {}
  async setBadge(_: SetBadgeOptions): Promise<void> {}
  async getSafeAreaInsets(): Promise<SafeAreaInsets> {
    return { top: 0, bottom: 0, left: 0, right: 0 };
  }
}