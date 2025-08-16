export type BadgeValue = number | "dot" | null;

/** Shape options for image icon containers */
export type ImageIconShape = "circle" | "square";

/** Size behavior options for image scaling */
export type ImageIconSize = "cover" | "stretch" | "fit";

/** Ring configuration for selected image icons */
export interface ImageIconRing {
  /** Whether to show ring around selected image */
  enabled: boolean;
  /** Width of the ring in pixels (default: 2.0) */
  width?: number;
}

/** Image icon configuration object */
export interface ImageIcon {
  /** Shape of the icon container */
  shape: ImageIconShape;
  /** Image scaling behavior */
  size: ImageIconSize;
  /** Image source - either base64 data URI or HTTP/HTTPS URL */
  image: string;
  /** Optional ring configuration for selected state */
  ring?: ImageIconRing;
}

/** Loading state for remote images */
export type ImageLoadingState = "loading" | "loaded" | "error";

export interface TabItem {
  /** Unique id you use in your router (e.g., 'home') */
  id: string;
  /** Title shown under the icon (optional if you want icon-only) */
  title?: string;
  /** SF Symbol name (e.g., 'house', 'sparkles') - fallback when imageIcon fails */
  systemIcon?: string;
  /** Or provide an asset name bundled on iOS (selected/unselected are tinted by system) */
  image?: string;
  /** Enhanced image icon with shape, size, and remote/base64 support */
  imageIcon?: ImageIcon;
  /** Optional badge number or 'dot' */
  badge?: BadgeValue;
}

export interface TabsBarConfigureOptions {
  items: TabItem[];
  /** Which tab is selected initially */
  initialId?: string;
  /** Show immediately (default true) */
  visible?: boolean;
  /** Color for the selected tab icon (hex or RGBA format) */
  selectedIconColor?: string;
  /** Color for unselected tab icons (hex or RGBA format) */
  unselectedIconColor?: string;
}

export interface SelectOptions {
  id: string;
}

export interface SetBadgeOptions {
  id: string;
  value: BadgeValue;
}

export interface SafeAreaInsets {
  top: number; bottom: number; left: number; right: number;
}

export interface TabsBarPlugin {
  configure(options: TabsBarConfigureOptions): Promise<void>;
  show(): Promise<void>;
  hide(): Promise<void>;
  select(options: SelectOptions): Promise<void>;
  setBadge(options: SetBadgeOptions): Promise<void>;
  getSafeAreaInsets(): Promise<SafeAreaInsets>;

  /** Fires when user taps a tab */
  addListener(
    eventName: "selected",
    listenerFunc: (ev: { id: string }) => void
  ): Promise<{ remove: () => void }>;
}