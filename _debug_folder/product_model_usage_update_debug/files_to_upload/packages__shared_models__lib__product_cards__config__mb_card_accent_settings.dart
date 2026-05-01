// MuthoBazar Product Card Design System
// File: mb_card_accent_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_accent_settings.dart
//
// Purpose:
// Defines accent styling intent: accent bars, promo strip, decorations, and
// optional indicator-dot tokens until dedicated indicator settings are used.

class MBCardAccentSettings {
  const MBCardAccentSettings({
    this.accentBarPosition = 'none',
    this.accentColorToken,
    this.showAccentBar = false,
    this.showPromoStrip = false,
    this.promoStripStyle,
    this.promoStripColorToken,
    this.themeDecorationPreset,
    this.accentIntensity = 1,
    this.showIndicatorDots,
    this.indicatorDotColorToken,
    this.indicatorDotCount,
  });

  factory MBCardAccentSettings.fromMap(Map map) {
    return MBCardAccentSettings(
      accentBarPosition: _readString(map['accentBarPosition'] ?? map['accent_bar_position'], 'none'),
      accentColorToken: _readNullableString(map['accentColorToken'] ?? map['accent_color_token']),
      showAccentBar: _readBool(map['showAccentBar'] ?? map['show_accent_bar'], false),
      showPromoStrip: _readBool(map['showPromoStrip'] ?? map['show_promo_strip'], false),
      promoStripStyle: _readNullableString(map['promoStripStyle'] ?? map['promo_strip_style']),
      promoStripColorToken: _readNullableString(map['promoStripColorToken'] ?? map['promo_strip_color_token']),
      themeDecorationPreset: _readNullableString(map['themeDecorationPreset'] ?? map['theme_decoration_preset']),
      accentIntensity: _readDouble(map['accentIntensity'] ?? map['accent_intensity'], 1),
      showIndicatorDots: _readNullableBool(map['showIndicatorDots'] ?? map['show_indicator_dots']),
      indicatorDotColorToken: _readNullableString(map['indicatorDotColorToken'] ?? map['indicator_dot_color_token']),
      indicatorDotCount: _readNullableInt(map['indicatorDotCount'] ?? map['indicator_dot_count']),
    );
  }

  final String accentBarPosition;
  final String? accentColorToken;
  final bool showAccentBar;
  final bool showPromoStrip;
  final String? promoStripStyle;
  final String? promoStripColorToken;
  final String? themeDecorationPreset;
  final double accentIntensity;
  final bool? showIndicatorDots;
  final String? indicatorDotColorToken;
  final int? indicatorDotCount;

  bool get hasAccentColorToken => accentColorToken != null && accentColorToken!.trim().isNotEmpty;
  bool get hasPromoStripStyle => promoStripStyle != null && promoStripStyle!.trim().isNotEmpty;
  bool get hasPromoStripColorToken => promoStripColorToken != null && promoStripColorToken!.trim().isNotEmpty;
  bool get hasThemeDecorationPreset => themeDecorationPreset != null && themeDecorationPreset!.trim().isNotEmpty;
  bool get hasAnyAccent =>
      showAccentBar ||
      showPromoStrip ||
      hasAccentColorToken ||
      hasPromoStripStyle ||
      hasPromoStripColorToken ||
      hasThemeDecorationPreset;

  MBCardAccentSettings copyWith({
    String? accentBarPosition,
    Object? accentColorToken = _sentinel,
    bool? showAccentBar,
    bool? showPromoStrip,
    Object? promoStripStyle = _sentinel,
    Object? promoStripColorToken = _sentinel,
    Object? themeDecorationPreset = _sentinel,
    double? accentIntensity,
    Object? showIndicatorDots = _sentinel,
    Object? indicatorDotColorToken = _sentinel,
    Object? indicatorDotCount = _sentinel,
  }) {
    return MBCardAccentSettings(
      accentBarPosition: accentBarPosition ?? this.accentBarPosition,
      accentColorToken: identical(accentColorToken, _sentinel)
          ? this.accentColorToken
          : _normalizeNullableString(accentColorToken as String?),
      showAccentBar: showAccentBar ?? this.showAccentBar,
      showPromoStrip: showPromoStrip ?? this.showPromoStrip,
      promoStripStyle: identical(promoStripStyle, _sentinel)
          ? this.promoStripStyle
          : _normalizeNullableString(promoStripStyle as String?),
      promoStripColorToken: identical(promoStripColorToken, _sentinel)
          ? this.promoStripColorToken
          : _normalizeNullableString(promoStripColorToken as String?),
      themeDecorationPreset: identical(themeDecorationPreset, _sentinel)
          ? this.themeDecorationPreset
          : _normalizeNullableString(themeDecorationPreset as String?),
      accentIntensity: accentIntensity ?? this.accentIntensity,
      showIndicatorDots: identical(showIndicatorDots, _sentinel)
          ? this.showIndicatorDots
          : _readNullableBool(showIndicatorDots),
      indicatorDotColorToken: identical(indicatorDotColorToken, _sentinel)
          ? this.indicatorDotColorToken
          : _normalizeNullableString(indicatorDotColorToken as String?),
      indicatorDotCount: identical(indicatorDotCount, _sentinel)
          ? this.indicatorDotCount
          : _readNullableInt(indicatorDotCount),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'accentBarPosition': accentBarPosition,
      'accentColorToken': _normalizeNullableString(accentColorToken),
      'showAccentBar': showAccentBar,
      'showPromoStrip': showPromoStrip,
      'promoStripStyle': _normalizeNullableString(promoStripStyle),
      'promoStripColorToken': _normalizeNullableString(promoStripColorToken),
      'themeDecorationPreset': _normalizeNullableString(themeDecorationPreset),
      'accentIntensity': accentIntensity,
      'showIndicatorDots': showIndicatorDots,
      'indicatorDotColorToken': _normalizeNullableString(indicatorDotColorToken),
      'indicatorDotCount': indicatorDotCount,
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


bool? _readNullableBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == 'true' || normalized == '1' || normalized == 'yes') return true;
  if (normalized == 'false' || normalized == '0' || normalized == 'no') return false;
  return null;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}
