// MuthoBazar Product Card Design System
// File: mb_card_border_effect_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_border_effect_settings.dart
//
// Purpose:
// Defines the border and outer-effect styling settings used by the product card
// system.
//
// Border/effect settings represent:
// - optional border visibility
// - border color token selection
// - border width
// - effect preset selection
// - effect intensity
//
// Important:
// - This model is serializable and safe for persistence.
// - Token and preset fields are stored as stable string ids, not concrete UI
//   objects, colors, glows, shaders, or animations. UI resolution must happen
//   later in shared_ui.
// - This model expresses style intent only. Exact visual rendering belongs to
//   the resolver and widget layer.

class MBCardBorderEffectSettings {
  const MBCardBorderEffectSettings({
    this.showBorder = false,
    this.borderColorToken,
    this.borderWidth = 1,
    this.effectPreset = 'none',
    this.effectIntensity = 0,
  });

  factory MBCardBorderEffectSettings.fromMap(Map<String, dynamic> map) {
    return MBCardBorderEffectSettings(
      showBorder: _readBool(map['showBorder'] ?? map['show_border'], false),
      borderColorToken: _readNullableString(
        map['borderColorToken'] ?? map['border_color_token'],
      ),
      borderWidth: _readDouble(map['borderWidth'] ?? map['border_width'], 1),
      effectPreset: _readString(
        map['effectPreset'] ?? map['effect_preset'],
        'none',
      ),
      effectIntensity: _readDouble(
        map['effectIntensity'] ?? map['effect_intensity'],
        0,
      ),
    );
  }

  final bool showBorder;
  final String? borderColorToken;
  final double borderWidth;
  final String effectPreset;
  final double effectIntensity;

  bool get hasBorderColorToken =>
      borderColorToken != null && borderColorToken!.trim().isNotEmpty;

  bool get hasEffectPreset =>
      effectPreset.trim().isNotEmpty && effectPreset.trim().toLowerCase() != 'none';

  bool get hasEffectIntensity => effectIntensity > 0;

  bool get hasAnyBorderOrEffect =>
      showBorder || hasBorderColorToken || hasEffectPreset || hasEffectIntensity;

  MBCardBorderEffectSettings copyWith({
    bool? showBorder,
    Object? borderColorToken = _sentinel,
    double? borderWidth,
    String? effectPreset,
    double? effectIntensity,
  }) {
    return MBCardBorderEffectSettings(
      showBorder: showBorder ?? this.showBorder,
      borderColorToken: identical(borderColorToken, _sentinel)
          ? this.borderColorToken
          : _normalizeNullableString(borderColorToken as String?),
      borderWidth: borderWidth ?? this.borderWidth,
      effectPreset: effectPreset ?? this.effectPreset,
      effectIntensity: effectIntensity ?? this.effectIntensity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showBorder': showBorder,
      'borderColorToken': _normalizeNullableString(borderColorToken),
      'borderWidth': borderWidth,
      'effectPreset': effectPreset,
      'effectIntensity': effectIntensity,
    };
  }

  @override
  String toString() {
    return 'MBCardBorderEffectSettings('
        'showBorder: $showBorder, '
        'borderColorToken: $borderColorToken, '
        'borderWidth: $borderWidth, '
        'effectPreset: $effectPreset, '
        'effectIntensity: $effectIntensity'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardBorderEffectSettings &&
        other.showBorder == showBorder &&
        other.borderColorToken == borderColorToken &&
        other.borderWidth == borderWidth &&
        other.effectPreset == effectPreset &&
        other.effectIntensity == effectIntensity;
  }

  @override
  int get hashCode {
    return Object.hash(
      showBorder,
      borderColorToken,
      borderWidth,
      effectPreset,
      effectIntensity,
    );
  }

  static const Object _sentinel = Object();

  static String _readString(Object? value, String fallback) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return fallback;
    }
    return normalized;
  }

  static String? _readNullableString(Object? value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static String? _normalizeNullableString(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static bool _readBool(Object? value, bool fallback) {
    if (value == null) {
      return fallback;
    }
    if (value is bool) {
      return value;
    }

    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
    return fallback;
  }

  static double _readDouble(Object? value, double fallback) {
    if (value == null) {
      return fallback;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString().trim()) ?? fallback;
  }
}
