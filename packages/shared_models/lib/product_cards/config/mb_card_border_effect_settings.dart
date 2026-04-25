// MuthoBazar Product Card Design System
// File: mb_card_border_effect_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_border_effect_settings.dart
//
// Purpose:
// Defines outer border and special visual effect intent for cards.

class MBCardBorderEffectSettings {
  const MBCardBorderEffectSettings({
    this.showBorder = false,
    this.borderColorToken,
    this.borderWidth = 1,
    this.borderRadiusOffset = 0,
    this.effectPreset = 'none',
    this.effectIntensity = 0,
    this.animateEffect = false,
    this.effectSpeedMs = 1200,
    this.effectColorToken,
  });

  factory MBCardBorderEffectSettings.fromMap(Map map) {
    return MBCardBorderEffectSettings(
      showBorder: _readBool(map['showBorder'] ?? map['show_border'], false),
      borderColorToken: _readNullableString(map['borderColorToken'] ?? map['border_color_token']),
      borderWidth: _readDouble(map['borderWidth'] ?? map['border_width'], 1),
      borderRadiusOffset: _readDouble(map['borderRadiusOffset'] ?? map['border_radius_offset'], 0),
      effectPreset: _readString(map['effectPreset'] ?? map['effect_preset'], 'none'),
      effectIntensity: _readDouble(map['effectIntensity'] ?? map['effect_intensity'], 0),
      animateEffect: _readBool(map['animateEffect'] ?? map['animate_effect'], false),
      effectSpeedMs: _readInt(map['effectSpeedMs'] ?? map['effect_speed_ms'], 1200),
      effectColorToken: _readNullableString(map['effectColorToken'] ?? map['effect_color_token']),
    );
  }

  final bool showBorder;
  final String? borderColorToken;
  final double borderWidth;
  final double borderRadiusOffset;
  final String effectPreset;
  final double effectIntensity;
  final bool animateEffect;
  final int effectSpeedMs;
  final String? effectColorToken;

  bool get hasBorderColorToken => borderColorToken != null && borderColorToken!.trim().isNotEmpty;
  bool get hasEffectPreset =>
      effectPreset.trim().isNotEmpty && effectPreset.trim().toLowerCase() != 'none';
  bool get hasEffectIntensity => effectIntensity > 0;
  bool get hasAnyBorderOrEffect =>
      showBorder || hasBorderColorToken || hasEffectPreset || hasEffectIntensity;

  MBCardBorderEffectSettings copyWith({
    bool? showBorder,
    Object? borderColorToken = _sentinel,
    double? borderWidth,
    double? borderRadiusOffset,
    String? effectPreset,
    double? effectIntensity,
    bool? animateEffect,
    int? effectSpeedMs,
    Object? effectColorToken = _sentinel,
  }) {
    return MBCardBorderEffectSettings(
      showBorder: showBorder ?? this.showBorder,
      borderColorToken: identical(borderColorToken, _sentinel)
          ? this.borderColorToken
          : _normalizeNullableString(borderColorToken as String?),
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadiusOffset: borderRadiusOffset ?? this.borderRadiusOffset,
      effectPreset: effectPreset ?? this.effectPreset,
      effectIntensity: effectIntensity ?? this.effectIntensity,
      animateEffect: animateEffect ?? this.animateEffect,
      effectSpeedMs: effectSpeedMs ?? this.effectSpeedMs,
      effectColorToken: identical(effectColorToken, _sentinel)
          ? this.effectColorToken
          : _normalizeNullableString(effectColorToken as String?),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'showBorder': showBorder,
      'borderColorToken': _normalizeNullableString(borderColorToken),
      'borderWidth': borderWidth,
      'borderRadiusOffset': borderRadiusOffset,
      'effectPreset': effectPreset,
      'effectIntensity': effectIntensity,
      'animateEffect': animateEffect,
      'effectSpeedMs': effectSpeedMs,
      'effectColorToken': _normalizeNullableString(effectColorToken),
    };
  }

  static const Object _sentinel = Object();
}


String? _readNullableString(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

String _readString(Object? value, String fallback) {
  return _readNullableString(value) ?? fallback;
}

bool _readBool(Object? value, bool fallback) {
  if (value == null) return fallback;
  if (value is bool) return value;

  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
    return true;
  }
  if (normalized == 'false' || normalized == '0' || normalized == 'no') {
    return false;
  }
  return fallback;
}

int _readInt(Object? value, int fallback) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? fallback;
}

double _readDouble(Object? value, double fallback) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim()) ?? fallback;
}

String? _normalizeNullableString(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
