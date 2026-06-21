// =================================================================
// SDUI contract — keep in sync with lib/data/sdui/sdui_component.dart
// =================================================================
//
// Both backend and Flutter client agree on this catalog of component
// + action types. Any drift between the two breaks the UI silently.
//
// To add a new component:
//   1. Add the interface here and to the SduiComponent union
//   2. Mirror it in sdui_component.dart with a matching fromJson
//   3. Add a render branch in sdui_renderer.dart
//   4. Bump SDUI_VERSION if older clients can't render it
//
// Forward compatibility: clients fall back to "unknown" for any type
// they don't recognise, so adding a new component server-side doesn't
// crash old clients — they just skip it.

export const SDUI_VERSION = 1;

// -----------------------------------------------------------------
// Components
// -----------------------------------------------------------------

export type SduiComponent =
  | ScreenComponent
  | VerticalStackComponent
  | TextComponent
  | BannerComponent
  | CardComponent
  | VenueRowComponent;

export interface ScreenComponent {
  type: 'screen';
  /** Shown in the app bar. Optional. */
  title?: string;
  children: SduiComponent[];
}

export interface VerticalStackComponent {
  type: 'vertical_stack';
  /** Gap between children in logical pixels. Defaults to 0. */
  spacing?: number;
  children: SduiComponent[];
}

export type TextStyle = 'title' | 'body' | 'caption' | 'label';

export interface TextComponent {
  type: 'text';
  value: string;
  /** Maps to Theme.textTheme on the client. Defaults to 'body'. */
  style?: TextStyle;
}

export type BannerTone = 'info' | 'warning' | 'success';

export interface BannerComponent {
  type: 'banner';
  text: string;
  /** Colour tone applied by the client. Defaults to 'info'. */
  tone?: BannerTone;
}

export interface CardComponent {
  type: 'card';
  /** Inner padding in logical pixels. Defaults to 16. */
  padding?: number;
  children: SduiComponent[];
  /** Optional tap action — if set, the whole card becomes tappable. */
  on_tap?: SduiAction;
}

/**
 * Domain-aware card for one venue. Defined as a single component
 * rather than composed from primitives because the layout of "a venue
 * card" is a unit that evolves together. Swiggy/Zomato make the same
 * call for restaurant_card.
 */
export interface VenueRowComponent {
  type: 'venue_row';
  venue_id: string;
  name: string;
  sport: 'badminton' | 'turf';
  location: string;
  price_per_hour: number;
  opens_at_hour: number;
  closes_at_hour: number;
  on_tap?: SduiAction;
}

// -----------------------------------------------------------------
// Actions
// -----------------------------------------------------------------

export type SduiAction = NavigateAction | ReloadAction;

export interface NavigateAction {
  action: 'navigate';
  /** Route path, e.g. '/venue-detail'. */
  to: string;
  /** Optional path/query params forwarded to the destination. */
  params?: Record<string, string>;
}

export interface ReloadAction {
  action: 'reload';
}
