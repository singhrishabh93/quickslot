import 'package:equatable/equatable.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_action.dart';

/// Mirror of `SduiComponent` in server/src/sdui/sdui.types.ts.
///
/// The renderer (lib/modules/sdui/widgets/sdui_renderer.dart) switches
/// on the runtime type of this sealed hierarchy. Adding a new variant
/// here forces a compile error in the renderer until you handle it —
/// that's the type-safety win.
///
/// `SduiUnknownComponent` is the forward-compat escape hatch: if the
/// server sends a component type this client doesn't recognise (e.g.
/// you ship v2 server with a component v1 client doesn't have), parsing
/// returns the unknown variant and the renderer draws a tiny placeholder
/// instead of crashing.
sealed class SduiComponent extends Equatable {
  const SduiComponent();

  factory SduiComponent.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String?) {
      'screen' => SduiScreen.fromJson(json),
      'vertical_stack' => SduiVerticalStack.fromJson(json),
      'text' => SduiText.fromJson(json),
      'banner' => SduiBanner.fromJson(json),
      'card' => SduiCard.fromJson(json),
      'venue_row' => SduiVenueRow.fromJson(json),
      _ => SduiUnknownComponent(type: json['type'] as String? ?? 'unknown'),
    };
  }

  @override
  List<Object?> get props => [];
}

// -----------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------

List<SduiComponent> _parseChildren(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(SduiComponent.fromJson)
      .toList(growable: false);
}

SduiAction? _parseAction(Object? raw) {
  if (raw is! Map<String, dynamic>) return null;
  return SduiAction.fromJson(raw);
}

// -----------------------------------------------------------------
// Component variants
// -----------------------------------------------------------------

class SduiScreen extends SduiComponent {
  const SduiScreen({this.title, required this.children});

  factory SduiScreen.fromJson(Map<String, dynamic> json) {
    return SduiScreen(
      title: json['title'] as String?,
      children: _parseChildren(json['children']),
    );
  }

  final String? title;
  final List<SduiComponent> children;

  @override
  List<Object?> get props => [title, children];
}

class SduiVerticalStack extends SduiComponent {
  const SduiVerticalStack({this.spacing = 0, required this.children});

  factory SduiVerticalStack.fromJson(Map<String, dynamic> json) {
    return SduiVerticalStack(
      spacing: (json['spacing'] as num?)?.toDouble() ?? 0,
      children: _parseChildren(json['children']),
    );
  }

  final double spacing;
  final List<SduiComponent> children;

  @override
  List<Object?> get props => [spacing, children];
}

enum SduiTextStyleVariant { title, body, caption, label }

SduiTextStyleVariant _parseTextStyle(Object? raw) {
  return switch (raw) {
    'title' => SduiTextStyleVariant.title,
    'caption' => SduiTextStyleVariant.caption,
    'label' => SduiTextStyleVariant.label,
    _ => SduiTextStyleVariant.body,
  };
}

class SduiText extends SduiComponent {
  const SduiText({
    required this.value,
    this.style = SduiTextStyleVariant.body,
  });

  factory SduiText.fromJson(Map<String, dynamic> json) {
    return SduiText(
      value: json['value'] as String? ?? '',
      style: _parseTextStyle(json['style']),
    );
  }

  final String value;
  final SduiTextStyleVariant style;

  @override
  List<Object?> get props => [value, style];
}

enum SduiBannerTone { info, warning, success }

SduiBannerTone _parseBannerTone(Object? raw) {
  return switch (raw) {
    'warning' => SduiBannerTone.warning,
    'success' => SduiBannerTone.success,
    _ => SduiBannerTone.info,
  };
}

class SduiBanner extends SduiComponent {
  const SduiBanner({required this.text, this.tone = SduiBannerTone.info});

  factory SduiBanner.fromJson(Map<String, dynamic> json) {
    return SduiBanner(
      text: json['text'] as String? ?? '',
      tone: _parseBannerTone(json['tone']),
    );
  }

  final String text;
  final SduiBannerTone tone;

  @override
  List<Object?> get props => [text, tone];
}

class SduiCard extends SduiComponent {
  const SduiCard({
    this.padding = 16,
    required this.children,
    this.onTap,
  });

  factory SduiCard.fromJson(Map<String, dynamic> json) {
    return SduiCard(
      padding: (json['padding'] as num?)?.toDouble() ?? 16,
      children: _parseChildren(json['children']),
      onTap: _parseAction(json['on_tap']),
    );
  }

  final double padding;
  final List<SduiComponent> children;
  final SduiAction? onTap;

  @override
  List<Object?> get props => [padding, children, onTap];
}

enum SduiSport { badminton, turf, unknown }

SduiSport _parseSport(Object? raw) {
  return switch (raw) {
    'badminton' => SduiSport.badminton,
    'turf' => SduiSport.turf,
    _ => SduiSport.unknown,
  };
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
    this.onTap,
  });

  factory SduiVenueRow.fromJson(Map<String, dynamic> json) {
    return SduiVenueRow(
      venueId: json['venue_id'] as String,
      name: json['name'] as String,
      sport: _parseSport(json['sport']),
      location: json['location'] as String,
      pricePerHour: (json['price_per_hour'] as num).toInt(),
      opensAtHour: (json['opens_at_hour'] as num?)?.toInt() ?? 6,
      closesAtHour: (json['closes_at_hour'] as num?)?.toInt() ?? 22,
      onTap: _parseAction(json['on_tap']),
    );
  }

  final String venueId;
  final String name;
  final SduiSport sport;
  final String location;
  final int pricePerHour;
  final int opensAtHour;
  final int closesAtHour;
  final SduiAction? onTap;

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

/// Forward-compat fallback. Server may add components that this client
/// doesn't know yet — rather than crashing, we capture the unknown type
/// and let the renderer draw a placeholder.
class SduiUnknownComponent extends SduiComponent {
  const SduiUnknownComponent({required this.type});
  final String type;

  @override
  List<Object?> get props => [type];
}
