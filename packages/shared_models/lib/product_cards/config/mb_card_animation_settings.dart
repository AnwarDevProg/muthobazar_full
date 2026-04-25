// MuthoBazar Product Card Design System
// File: mb_card_animation_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_animation_settings.dart
//
// Purpose:
// Defines optional hover/tap/animation settings for cards.

class MBCardAnimationSettings {
  const MBCardAnimationSettings({
    this.enableHoverLift,
    this.enableTapScale,
    this.enableGlowAnimation,
    this.enableImageZoomOnHover,
    this.animationDurationMs,
  });

  factory MBCardAnimationSettings.fromMap(Map map) {
    return MBCardAnimationSettings(
      enableHoverLift: _readNullableBool(
        map['enableHoverLift'] ?? map['enable_hover_lift'],
      ),
      enableTapScale: _readNullableBool(
        map['enableTapScale'] ?? map['enable_tap_scale'],
      ),
      enableGlowAnimation: _readNullableBool(
        map['enableGlowAnimation'] ?? map['enable_glow_animation'],
      ),
      enableImageZoomOnHover: _readNullableBool(
        map['enableImageZoomOnHover'] ?? map['enable_image_zoom_on_hover'],
      ),
      animationDurationMs: _readNullableInt(
        map['animationDurationMs'] ?? map['animation_duration_ms'],
      ),
    );
  }

  final bool? enableHoverLift;
  final bool? enableTapScale;
  final bool? enableGlowAnimation;
  final bool? enableImageZoomOnHover;
  final int? animationDurationMs;

  bool get isEmpty => toMap().isEmpty;
  bool get isNotEmpty => !isEmpty;

  Map<String, Object?> toMap() {
    return _cleanMap({
      'enableHoverLift': enableHoverLift,
      'enableTapScale': enableTapScale,
      'enableGlowAnimation': enableGlowAnimation,
      'enableImageZoomOnHover': enableImageZoomOnHover,
      'animationDurationMs': animationDurationMs,
    });
  }
}


String? _readNullableString(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

bool? _readNullableBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;

  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return null;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

double? _readNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}

Map<String, Object?> _cleanMap(Map<String, Object?> map) {
  return Map<String, Object?>.fromEntries(
    map.entries.where((entry) => entry.value != null),
  );
}
