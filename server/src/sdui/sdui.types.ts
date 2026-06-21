// =================================================================
// SDUI contract v2 — keep in sync with lib/data/sdui/sdui_component.dart
// =================================================================
// All four screens of the app are now described by these types.
// Bump SDUI_VERSION when shipping a new client capable of new
// component/action types so older clients can fall back gracefully.

export const SDUI_VERSION = 2;

// ─────────────────────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────────────────────

export type SduiComponent =
  | ScreenComponent
  | VerticalStackComponent
  | HorizontalStackComponent
  | GridComponent
  | SpacerComponent
  | DividerComponent
  | TextComponent
  | BannerComponent
  | PillComponent
  | ButtonComponent
  | CardComponent
  | UserCardComponent
  | VenueRowComponent
  | VenueHeaderComponent
  | DateChipComponent
  | SlotTileComponent
  | BookingTileComponent;

export interface ScreenComponent {
  type: 'screen';
  title?: string;
  children: SduiComponent[];
}

export interface VerticalStackComponent {
  type: 'vertical_stack';
  spacing?: number;
  children: SduiComponent[];
}

export type StackAlignment = 'start' | 'center' | 'end' | 'space_between';

export interface HorizontalStackComponent {
  type: 'horizontal_stack';
  spacing?: number;
  alignment?: StackAlignment;
  children: SduiComponent[];
  /** Optional horizontal padding around the stack. */
  padding?: number;
  /** If true, wrap in a horizontal scroll view. */
  scrollable?: boolean;
}

export interface GridComponent {
  type: 'grid';
  columns: number;
  spacing?: number;
  /** child aspect ratio (width / height). Defaults to 1.0. */
  aspect_ratio?: number;
  children: SduiComponent[];
}

export interface SpacerComponent {
  type: 'spacer';
  height: number;
}

export interface DividerComponent {
  type: 'divider';
}

export type TextStyle = 'display' | 'title' | 'body' | 'caption' | 'label';
export type TextColor = 'default' | 'subtle' | 'primary' | 'danger';
export type TextAlignment = 'start' | 'center' | 'end';

export interface TextComponent {
  type: 'text';
  value: string;
  style?: TextStyle;
  color?: TextColor;
  alignment?: TextAlignment;
}

export type BannerTone = 'info' | 'warning' | 'success';

export interface BannerComponent {
  type: 'banner';
  text: string;
  tone?: BannerTone;
}

export type PillTone = 'neutral' | 'success' | 'danger' | 'info';

export interface PillComponent {
  type: 'pill';
  label: string;
  tone?: PillTone;
}

export type ButtonVariant = 'filled' | 'outlined' | 'text';

export interface ButtonComponent {
  type: 'button';
  label: string;
  variant?: ButtonVariant;
  /** Optional icon name (Material icon string). */
  icon?: string;
  full_width?: boolean;
  on_tap: SduiAction[];
  /** If true, button shows a spinner. Useful while server-side state machine is mid-flight. */
  loading?: boolean;
}

export interface CardComponent {
  type: 'card';
  padding?: number;
  children: SduiComponent[];
  on_tap?: SduiAction[];
}

// ── Domain-aware components ──────────────────────────────────────

export interface UserCardComponent {
  type: 'user_card';
  user_id: string;
  name: string;
  email: string;
  on_tap: SduiAction[];
}

export interface VenueRowComponent {
  type: 'venue_row';
  venue_id: string;
  name: string;
  sport: 'badminton' | 'turf';
  location: string;
  price_per_hour: number;
  opens_at_hour: number;
  closes_at_hour: number;
  on_tap?: SduiAction[];
}

export interface VenueHeaderComponent {
  type: 'venue_header';
  name: string;
  sport: 'badminton' | 'turf';
  location: string;
  price_per_hour: number;
  opens_at_hour: number;
  closes_at_hour: number;
}

export interface DateChipComponent {
  type: 'date_chip';
  day_label: string; // "WED"
  date_label: string; // "10"
  selected?: boolean;
  on_tap: SduiAction[];
}

export type SlotStatus = 'open' | 'booked';

export interface SlotTileComponent {
  type: 'slot_tile';
  hour: number; // 6..21
  status: SlotStatus;
  slot_start_utc: string; // ISO string
  on_tap?: SduiAction[];
}

export type BookingStatus = 'confirmed' | 'cancelled';

export interface BookingTileComponent {
  type: 'booking_tile';
  booking_id: string;
  venue_name: string;
  sport?: 'badminton' | 'turf';
  location?: string;
  date_label: string; // "WED · 11 JUN"
  time_label: string; // "10:00 → 11:00"
  status: BookingStatus;
  cancel_action?: SduiAction[];
}

// ─────────────────────────────────────────────────────────────────
// Actions
// ─────────────────────────────────────────────────────────────────

export type SduiAction =
  | NavigateAction
  | ReplaceAllAction
  | NavigateBackAction
  | ReloadAction
  | SetSessionAction
  | ClearSessionAction
  | OpenSheetAction
  | CloseSheetAction
  | ShowDialogAction
  | ShowSnackbarAction
  | ApiCallAction;

export interface NavigateAction {
  action: 'navigate';
  to: string;
  params?: Record<string, string>;
}

export interface ReplaceAllAction {
  action: 'replace_all';
  to: string;
  params?: Record<string, string>;
}

export interface NavigateBackAction {
  action: 'navigate_back';
}

export interface ReloadAction {
  action: 'reload';
}

export interface SetSessionAction {
  action: 'set_session';
  user_id: string;
  name: string;
}

export interface ClearSessionAction {
  action: 'clear_session';
}

export interface OpenSheetAction {
  action: 'open_sheet';
  /** URL the renderer hits to fetch the sheet's SDUI tree. */
  url: string;
}

export interface CloseSheetAction {
  action: 'close_sheet';
}

export interface ShowDialogAction {
  action: 'show_dialog';
  url: string;
}

export type SnackbarTone = 'info' | 'success' | 'danger';

export interface ShowSnackbarAction {
  action: 'show_snackbar';
  text: string;
  tone?: SnackbarTone;
}

export type HttpMethod = 'POST' | 'PUT' | 'PATCH' | 'DELETE';

/**
 * Fire-and-forget HTTP request with branched continuations.
 *
 *   on_success: chain to run on 2xx
 *   on_conflict: chain to run on 409 (the SLOT_TAKEN path)
 *   on_error: chain to run on any other non-2xx / network error
 *
 * Authentication: the client sends X-User-Id from session automatically,
 * same as native REST.
 */
export interface ApiCallAction {
  action: 'api_call';
  method: HttpMethod;
  url: string;
  body?: Record<string, unknown>;
  on_success?: SduiAction[];
  on_conflict?: SduiAction[];
  on_error?: SduiAction[];
}
