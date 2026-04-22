// MuthoBazar Product Card Design System
// File: mb_card_accent_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_accent_settings.dart
//
// Purpose:
// Defines the accent-level styling settings used by the product card system.
//
// Accent settings represent:
// - optional accent bar usage and placement
// - accent color token selection
// - optional promo strip usage and style selection
// - optional theme decoration preset selection
//
// Important:
// - This model is serializable and safe for persistence.
// - Token and preset fields are stored as stable string ids, not concrete UI
//   values. UI resolution must happen later in shared_ui.
// - This model controls accent intent only. Exact rendering belongs to the
//   renderer/resolver layer.

class MBCardAccentSettings {
  const MBCardAccentSettings({
    this.accentBarPosition = 'none',
    this.accentColorToken,
    this.showAccentBar = false,
    this.showPromoStrip = false,
    this.promoStripStyle,
    this.promoStripColorToken,
    this.themeDecorationPreset,
  });

  factory MBCardAccentSettings.fromMap(Map<String, dynamic> map) {
    return MBCardAccentSettings(
      accentBarPosition: _readString(
        map['accentBarPosition'] ?? map['accent_bar_position'],
        'none',
      ),
      accentColorToken: _readNullableString(
        map['accentColorToken'] ?? map['accent_color_token'],
      ),
      showAccentBar: _readBool(
        map['showAccentBar'] ?? map['show_accent_bar'],
        false,
      ),
      showPromoStrip: _readBool(
        map['showPromoStrip'] ?? map['show_promo_strip'],
        false,
      ),
      promoStripStyle: _readNullableString(
        map['promoStripStyle'] ?? map['promo_strip_style'],
      ),
      promoStripColorToken: _readNullableString(
        map['promoStripColorToken'] ?? map['promo_strip_color_token'],
      ),
      themeDecorationPreset: _readNullableString(
        map['themeDecorationPreset'] ?? map['theme_decoration_preset'],
      ),
    );
  }

  final String accentBarPosition;
  final String? accentColorToken;
  final bool showAccentBar;
  final bool showPromoStrip;
  final String? promoStripStyle;
  final String? promoStripColorToken;
  final String? themeDecorationPreset;

  bool get hasAccentColorToken =>
      accentColorToken != null && accentColorToken!.trim().isNotEmpty;

  bool get hasPromoStripStyle =>
      promoStripStyle != null && promoStripStyle!.trim().isNotEmpty;

  bool get hasPromoStripColorToken =>
      promoStripColorToken != null && promoStripColorToken!.trim().isNotEmpty;

  bool get hasThemeDecorationPreset =>
      themeDecorationPreset != null &&
          themeDecorationPreset!.trim().isNotEmpty;

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
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accentBarPosition': accentBarPosition,
      'accentColorToken': _normalizeNullableString(accentColorToken),
      'showAccentBar': showAccentBar,
      'showPromoStrip': showPromoStrip,
      'promoStripStyle': _normalizeNullableString(promoStripStyle),
      'promoStripColorToken': _normalizeNullableString(promoStripColorToken),
      'themeDecorationPreset': _normalizeNullableString(themeDecorationPreset),
    };
  }

  @override
  String toString() {
    return 'MBCardAccentSettings('
        'accentBarPosition: $accentBarPosition, '
        'accentColorToken: $accentColorToken, '
        'showAccentBar: $showAccentBar, '
        'showPromoStrip: $showPromoStrip, '
        'promoStripStyle: $promoStripStyle, '
        'promoStripColorToken: $promoStripColorToken, '
        'themeDecorationPreset: $themeDecorationPreset'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardAccentSettings &&
        other.accentBarPosition == accentBarPosition &&
        other.accentColorToken == accentColorToken &&
        other.showAccentBar == showAccentBar &&
        other.showPromoStrip == showPromoStrip &&
        other.promoStripStyle == promoStripStyle &&
        other.promoStripColorToken == promoStripColorToken &&
        other.themeDecorationPreset == themeDecorationPreset;
  }

  @override
  int get hashCode {
    return Object.hash(
      accentBarPosition,
      accentColorToken,
      showAccentBar,
      showPromoStrip,
      promoStripStyle,
      promoStripColorToken,
      themeDecorationPreset,
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
}
