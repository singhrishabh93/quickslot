import 'package:equatable/equatable.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_action.dart';

/// Mirror of `SduiComponent` in server/src/sdui/sdui.types.ts.
sealed class SduiComponent extends Equatable {
  const SduiComponent();

  factory SduiComponent.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String?) {
      'screen' => SduiScreen.fromJson(json),
      'vertical_stack' => SduiVerticalStack.fromJson(json),
      'horizontal_stack' => SduiHorizontalStack.fromJson(json),
      'grid' => SduiGrid.fromJson(json),
      'spacer' => SduiSpacer.fromJson(json),
      'divider' => const SduiDivider(),
      'text' => SduiText.fromJson(json),
      'banner' => SduiBanner.fromJson(json),
      'pill' => SduiPill.fromJson(json),
      'button' => SduiButton.fromJson(json),
      'card' => SduiCard.fromJson(json),
      'user_card' => SduiUserCard.fromJson(json),
      'venue_row' => SduiVenueRow.fromJson(json),
      'venue_header' => SduiVenueHeader.fromJson(json),
      'date_chip' => SduiDateChip.fromJson(json),
      'slot_tile' => SduiSlotTile.fromJson(json),
      'booking_tile' => SduiBookingTile.fromJson(json),
      _ => SduiUnknownComponent(type: json['type'] as String? ?? 'unknown'),
    };
  }

  @override
  List<Object?> get props => [];
}

List<SduiComponent> _parseChildren(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(SduiComponent.fromJson)
      .toList(growable: false);
}

// ── primitives ───────────────────────────────────────────────────

class SduiScreen extends SduiComponent {
  const SduiScreen({this.title, required this.children});

  factory SduiScreen.fromJson(Map<String, dynamic> json) => SduiScreen(
        title: json['title'] as String?,
        children: _parseChildren(json['children']),
      );

  final String? title;
  final List<SduiComponent> children;

  @override
  List<Object?> get props => [title, children];
}

class SduiVerticalStack extends SduiComponent {
  const SduiVerticalStack({this.spacing = 0, required this.children});

  factory SduiVerticalStack.fromJson(Map<String, dynamic> json) =>
      SduiVerticalStack(
        spacing: (json['spacing'] as num?)?.toDouble() ?? 0,
        children: _parseChildren(json['children']),
      );

  final double spacing;
  final List<SduiComponent> children;

  @override
  List<Object?> get props => [spacing, children];
}

enum SduiStackAlignment { start, center, end, spaceBetween }

SduiStackAlignment _parseStackAlignment(Object? raw) => switch (raw) {
      'center' => SduiStackAlignment.center,
      'end' => SduiStackAlignment.end,
      'space_between' => SduiStackAlignment.spaceBetween,
      _ => SduiStackAlignment.start,
    };

class SduiHorizontalStack extends SduiComponent {
  const SduiHorizontalStack({
    this.spacing = 0,
    this.alignment = SduiStackAlignment.start,
    this.padding = 0,
    this.scrollable = false,
    required this.children,
  });

  factory SduiHorizontalStack.fromJson(Map<String, dynamic> json) =>
      SduiHorizontalStack(
        spacing: (json['spacing'] as num?)?.toDouble() ?? 0,
        alignment: _parseStackAlignment(json['alignment']),
        padding: (json['padding'] as num?)?.toDouble() ?? 0,
        scrollable: json['scrollable'] as bool? ?? false,
        children: _parseChildren(json['children']),
      );

  final double spacing;
  final SduiStackAlignment alignment;
  final double padding;
  final bool scrollable;
  final List<SduiComponent> children;

  @override
  List<Object?> get props =>
      [spacing, alignment, padding, scrollable, children];
}

class SduiGrid extends SduiComponent {
  const SduiGrid({
    required this.columns,
    this.spacing = 0,
    this.aspectRatio = 1.0,
    required this.children,
  });

  factory SduiGrid.fromJson(Map<String, dynamic> json) => SduiGrid(
        columns: (json['columns'] as num).toInt(),
        spacing: (json['spacing'] as num?)?.toDouble() ?? 0,
        aspectRatio: (json['aspect_ratio'] as num?)?.toDouble() ?? 1.0,
        children: _parseChildren(json['children']),
      );

  final int columns;
  final double spacing;
  final double aspectRatio;
  final List<SduiComponent> children;

  @override
  List<Object?> get props => [columns, spacing, aspectRatio, children];
}

class SduiSpacer extends SduiComponent {
  const SduiSpacer({required this.height});
  factory SduiSpacer.fromJson(Map<String, dynamic> json) =>
      SduiSpacer(height: (json['height'] as num).toDouble());
  final double height;
  @override
  List<Object?> get props => [height];
}

class SduiDivider extends SduiComponent {
  const SduiDivider();
}

enum SduiTextStyleVariant { display, title, body, caption, label }

SduiTextStyleVariant _parseTextStyle(Object? raw) => switch (raw) {
      'display' => SduiTextStyleVariant.display,
      'title' => SduiTextStyleVariant.title,
      'caption' => SduiTextStyleVariant.caption,
      'label' => SduiTextStyleVariant.label,
      _ => SduiTextStyleVariant.body,
    };

enum SduiTextColor { defaultColor, subtle, primary, danger }

SduiTextColor _parseTextColor(Object? raw) => switch (raw) {
      'subtle' => SduiTextColor.subtle,
      'primary' => SduiTextColor.primary,
      'danger' => SduiTextColor.danger,
      _ => SduiTextColor.defaultColor,
    };

enum SduiTextAlignment { start, center, end }

SduiTextAlignment _parseTextAlignment(Object? raw) => switch (raw) {
      'center' => SduiTextAlignment.center,
      'end' => SduiTextAlignment.end,
      _ => SduiTextAlignment.start,
    };

class SduiText extends SduiComponent {
  const SduiText({
    required this.value,
    this.style = SduiTextStyleVariant.body,
    this.color = SduiTextColor.defaultColor,
    this.alignment = SduiTextAlignment.start,
  });

  factory SduiText.fromJson(Map<String, dynamic> json) => SduiText(
        value: json['value'] as String? ?? '',
        style: _parseTextStyle(json['style']),
        color: _parseTextColor(json['color']),
        alignment: _parseTextAlignment(json['alignment']),
      );

  final String value;
  final SduiTextStyleVariant style;
  final SduiTextColor color;
  final SduiTextAlignment alignment;

  @override
  List<Object?> get props => [value, style, color, alignment];
}

enum SduiBannerTone { info, warning, success }

SduiBannerTone _parseBannerTone(Object? raw) => switch (raw) {
      'warning' => SduiBannerTone.warning,
      'success' => SduiBannerTone.success,
      _ => SduiBannerTone.info,
    };

class SduiBanner extends SduiComponent {
  const SduiBanner({required this.text, this.tone = SduiBannerTone.info});

  factory SduiBanner.fromJson(Map<String, dynamic> json) => SduiBanner(
        text: json['text'] as String? ?? '',
        tone: _parseBannerTone(json['tone']),
      );

  final String text;
  final SduiBannerTone tone;

  @override
  List<Object?> get props => [text, tone];
}

enum SduiPillTone { neutral, success, danger, info }

SduiPillTone _parsePillTone(Object? raw) => switch (raw) {
      'success' => SduiPillTone.success,
      'danger' => SduiPillTone.danger,
      'info' => SduiPillTone.info,
      _ => SduiPillTone.neutral,
    };

class SduiPill extends SduiComponent {
  const SduiPill({required this.label, this.tone = SduiPillTone.neutral});

  factory SduiPill.fromJson(Map<String, dynamic> json) => SduiPill(
        label: json['label'] as String? ?? '',
        tone: _parsePillTone(json['tone']),
      );

  final String label;
  final SduiPillTone tone;

  @override
  List<Object?> get props => [label, tone];
}

enum SduiButtonVariant { filled, outlined, text }

SduiButtonVariant _parseButtonVariant(Object? raw) => switch (raw) {
      'outlined' => SduiButtonVariant.outlined,
      'text' => SduiButtonVariant.text,
      _ => SduiButtonVariant.filled,
    };

class SduiButton extends SduiComponent {
  const SduiButton({
    required this.label,
    required this.onTap,
    this.variant = SduiButtonVariant.filled,
    this.icon,
    this.fullWidth = false,
    this.loading = false,
  });

  factory SduiButton.fromJson(Map<String, dynamic> json) => SduiButton(
        label: json['label'] as String,
        variant: _parseButtonVariant(json['variant']),
        icon: json['icon'] as String?,
        fullWidth: json['full_width'] as bool? ?? false,
        loading: json['loading'] as bool? ?? false,
        onTap: SduiAction.parseList(json['on_tap']),
      );

  final String label;
  final SduiButtonVariant variant;
  final String? icon;
  final bool fullWidth;
  final bool loading;
  final List<SduiAction> onTap;

  @override
  List<Object?> get props => [label, variant, icon, fullWidth, loading, onTap];
}

class SduiCard extends SduiComponent {
  const SduiCard({
    this.padding = 16,
    required this.children,
    this.onTap = const [],
  });

  factory SduiCard.fromJson(Map<String, dynamic> json) => SduiCard(
        padding: (json['padding'] as num?)?.toDouble() ?? 16,
        children: _parseChildren(json['children']),
        onTap: SduiAction.parseList(json['on_tap']),
      );

  final double padding;
  final List<SduiComponent> children;
  final List<SduiAction> onTap;

  @override
  List<Object?> get props => [padding, children, onTap];
}

// ── domain components ────────────────────────────────────────────

enum SduiSport { badminton, turf, unknown }

SduiSport _parseSport(Object? raw) => switch (raw) {
      'badminton' => SduiSport.badminton,
      'turf' => SduiSport.turf,
      _ => SduiSport.unknown,
    };

class SduiUserCard extends SduiComponent {
  const SduiUserCard({
    required this.userId,
    required this.name,
    required this.email,
    required this.onTap,
  });

  factory SduiUserCard.fromJson(Map<String, dynamic> json) => SduiUserCard(
        userId: json['user_id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        onTap: SduiAction.parseList(json['on_tap']),
      );

  final String userId;
  final String name;
  final String email;
  final List<SduiAction> onTap;

  @override
  List<Object?> get props => [userId, name, email, onTap];
}

class SduiVenueRow extends SduiComponent {
  const SduiVenueRow({
    required this.venueId,
    required this.name,
    required this.sport,
    required this.location,
    required this.pricePerHour,
    required this.opensAtHour,
    required this.closesAtHour,
    this.onTap = const [],
  });

  factory SduiVenueRow.fromJson(Map<String, dynamic> json) => SduiVenueRow(
        venueId: json['venue_id'] as String,
        name: json['name'] as String,
        sport: _parseSport(json['sport']),
        location: json['location'] as String,
        pricePerHour: (json['price_per_hour'] as num).toInt(),
        opensAtHour: (json['opens_at_hour'] as num?)?.toInt() ?? 6,
        closesAtHour: (json['closes_at_hour'] as num?)?.toInt() ?? 22,
        onTap: SduiAction.parseList(json['on_tap']),
      );

  final String venueId;
  final String name;
  final SduiSport sport;
  final String location;
  final int pricePerHour;
  final int opensAtHour;
  final int closesAtHour;
  final List<SduiAction> onTap;

  @override
  List<Object?> get props => [
        venueId,
        name,
        sport,
        location,
        pricePerHour,
        opensAtHour,
        closesAtHour,
        onTap,
      ];
}

class SduiVenueHeader extends SduiComponent {
  const SduiVenueHeader({
    required this.name,
    required this.sport,
    required this.location,
    required this.pricePerHour,
    required this.opensAtHour,
    required this.closesAtHour,
  });

  factory SduiVenueHeader.fromJson(Map<String, dynamic> json) =>
      SduiVenueHeader(
        name: json['name'] as String,
        sport: _parseSport(json['sport']),
        location: json['location'] as String,
        pricePerHour: (json['price_per_hour'] as num).toInt(),
        opensAtHour: (json['opens_at_hour'] as num?)?.toInt() ?? 6,
        closesAtHour: (json['closes_at_hour'] as num?)?.toInt() ?? 22,
      );

  final String name;
  final SduiSport sport;
  final String location;
  final int pricePerHour;
  final int opensAtHour;
  final int closesAtHour;

  @override
  List<Object?> get props =>
      [name, sport, location, pricePerHour, opensAtHour, closesAtHour];
}

class SduiDateChip extends SduiComponent {
  const SduiDateChip({
    required this.dayLabel,
    required this.dateLabel,
    this.selected = false,
    required this.onTap,
  });

  factory SduiDateChip.fromJson(Map<String, dynamic> json) => SduiDateChip(
        dayLabel: json['day_label'] as String,
        dateLabel: json['date_label'] as String,
        selected: json['selected'] as bool? ?? false,
        onTap: SduiAction.parseList(json['on_tap']),
      );

  final String dayLabel;
  final String dateLabel;
  final bool selected;
  final List<SduiAction> onTap;

  @override
  List<Object?> get props => [dayLabel, dateLabel, selected, onTap];
}

enum SduiSlotStatus { open, booked }

SduiSlotStatus _parseSlotStatus(Object? raw) =>
    raw == 'booked' ? SduiSlotStatus.booked : SduiSlotStatus.open;

class SduiSlotTile extends SduiComponent {
  const SduiSlotTile({
    required this.hour,
    required this.status,
    required this.slotStartUtc,
    this.onTap = const [],
  });

  factory SduiSlotTile.fromJson(Map<String, dynamic> json) => SduiSlotTile(
        hour: (json['hour'] as num).toInt(),
        status: _parseSlotStatus(json['status']),
        slotStartUtc: json['slot_start_utc'] as String,
        onTap: SduiAction.parseList(json['on_tap']),
      );

  final int hour;
  final SduiSlotStatus status;
  final String slotStartUtc;
  final List<SduiAction> onTap;

  @override
  List<Object?> get props => [hour, status, slotStartUtc, onTap];
}

enum SduiBookingStatus { confirmed, cancelled }

SduiBookingStatus _parseBookingStatus(Object? raw) => raw == 'cancelled'
    ? SduiBookingStatus.cancelled
    : SduiBookingStatus.confirmed;

class SduiBookingTile extends SduiComponent {
  const SduiBookingTile({
    required this.bookingId,
    required this.venueName,
    this.sport,
    this.location,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    this.cancelAction = const [],
  });

  factory SduiBookingTile.fromJson(Map<String, dynamic> json) =>
      SduiBookingTile(
        bookingId: json['booking_id'] as String,
        venueName: json['venue_name'] as String,
        sport: json['sport'] != null ? _parseSport(json['sport']) : null,
        location: json['location'] as String?,
        dateLabel: json['date_label'] as String,
        timeLabel: json['time_label'] as String,
        status: _parseBookingStatus(json['status']),
        cancelAction: SduiAction.parseList(json['cancel_action']),
      );

  final String bookingId;
  final String venueName;
  final SduiSport? sport;
  final String? location;
  final String dateLabel;
  final String timeLabel;
  final SduiBookingStatus status;
  final List<SduiAction> cancelAction;

  @override
  List<Object?> get props => [
        bookingId,
        venueName,
        sport,
        location,
        dateLabel,
        timeLabel,
        status,
        cancelAction,
      ];
}

class SduiUnknownComponent extends SduiComponent {
  const SduiUnknownComponent({required this.type});
  final String type;

  @override
  List<Object?> get props => [type];
}
