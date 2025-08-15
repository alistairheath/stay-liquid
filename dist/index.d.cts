type BadgeValue = number | "dot" | null;
interface TabItem {
    /** Unique id you use in your router (e.g., 'home') */
    id: string;
    /** Title shown under the icon (optional if you want icon-only) */
    title?: string;
    /** SF Symbol name (e.g., 'house', 'sparkles') */
    systemIcon?: string;
    /** Or provide an asset name bundled on iOS (selected/unselected are tinted by system) */
    image?: string;
    /** Optional badge number or 'dot' */
    badge?: BadgeValue;
}
interface TabsBarConfigureOptions {
    items: TabItem[];
    /** Which tab is selected initially */
    initialId?: string;
    /** Show immediately (default true) */
    visible?: boolean;
}
interface SelectOptions {
    id: string;
}
interface SetBadgeOptions {
    id: string;
    value: BadgeValue;
}
interface SafeAreaInsets {
    top: number;
    bottom: number;
    left: number;
    right: number;
}
interface TabsBarPlugin {
    configure(options: TabsBarConfigureOptions): Promise<void>;
    show(): Promise<void>;
    hide(): Promise<void>;
    select(options: SelectOptions): Promise<void>;
    setBadge(options: SetBadgeOptions): Promise<void>;
    getSafeAreaInsets(): Promise<SafeAreaInsets>;
    /** Fires when user taps a tab */
    addListener(eventName: "selected", listenerFunc: (ev: {
        id: string;
    }) => void): Promise<{
        remove: () => void;
    }>;
}

/** Named export for the TabsBar plugin within the larger library */
declare const TabsBar: TabsBarPlugin;

export { type BadgeValue, type SafeAreaInsets, type SelectOptions, type SetBadgeOptions, type TabItem, TabsBar, type TabsBarConfigureOptions, type TabsBarPlugin };
