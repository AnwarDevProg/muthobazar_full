// MuthoBazar Product Card Design System
// File: mb_card_typography_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_typography_settings.dart
//
// Purpose:
// Defines token-based typography settings for product-card text elements.
// It supports compact cards that need auto-shrink titles and future premium,
// flash, horizontal, and info-rich card families.

class MBCardTypographySettings {
  const MBCardTypographySettings({
    this.titleColorToken,
    this.subtitleColorToken,
    this.priceColorToken,
    this.oldPriceColorToken,
    this.metaColorToken,
    this.titleStyleToken,
    this.subtitleStyleToken,
    this.priceStyleToken,
    this.metaStyleToken,
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 1,
    this.titleMinFontSize = 10,
    this.subtitleMinFontSize = 10,
    this.titleFontSize,
    this.subtitleFontSize,
    this.priceFontSize,
    this.oldPriceFontSize,
    this.titleAutoShrink = false,
    this.subtitleAutoShrink = false,
    this.titleBold = true,
    this.priceBold = true,
    this.italicTitle = false,
    this.italicSubtitle = false,
    this.titleLineHeight,
    this.subtitleLineHeight,
    this.priceLineHeight,
  });

  factory MBCardTypographySettings.fromMap(Map map) {
    return MBCardTypographySettings(
      titleColorToken: _readNullableString(map['titleColorToken'] ?? map['title_color_token']),
      subtitleColorToken: _readNullableString(map['subtitleColorToken'] ?? map['subtitle_color_token']),
      priceColorToken: _readNullableString(map['priceColorToken'] ?? map['price_color_token']),
      oldPriceColorToken: _readNullableString(map['oldPriceColorToken'] ?? map['old_price_color_token']),
      metaColorToken: _readNullableString(map['metaColorToken'] ?? map['meta_color_token']),
      titleStyleToken: _readNullableString(map['titleStyleToken'] ?? map['title_style_token']),
      subtitleStyleToken: _readNullableString(map['subtitleStyleToken'] ?? map['subtitle_style_token']),
      priceStyleToken: _readNullableString(map['priceStyleToken'] ?? map['price_style_token']),
      metaStyleToken: _readNullableString(map['metaStyleToken'] ?? map['meta_style_token']),
      titleMaxLines: _readInt(map['titleMaxLines'] ?? map['title_max_lines'], 2),
      subtitleMaxLines: _readInt(map['subtitleMaxLines'] ?? map['subtitle_max_lines'], 1),
      titleMinFontSize: _readDouble(map['titleMinFontSize'] ?? map['title_min_font_size'], 10),
      subtitleMinFontSize: _readDouble(map['subtitleMinFontSize'] ?? map['subtitle_min_font_size'], 10),
      titleFontSize: _readNullableDouble(map['titleFontSize'] ?? map['title_font_size']),
      subtitleFontSize: _readNullableDouble(map['subtitleFontSize'] ?? map['subtitle_font_size']),
      priceFontSize: _readNullableDouble(map['priceFontSize'] ?? map['price_font_size']),
      oldPriceFontSize: _readNullableDouble(map['oldPriceFontSize'] ?? map['old_price_font_size']),
      titleAutoShrink: _readBool(map['titleAutoShrink'] ?? map['title_auto_shrink'], false),
      subtitleAutoShrink: _readBool(map['subtitleAutoShrink'] ?? map['subtitle_auto_shrink'], false),
      titleBold: _readBool(map['titleBold'] ?? map['title_bold'], true),
      priceBold: _readBool(map['priceBold'] ?? map['price_bold'], true),
      italicTitle: _readBool(map['italicTitle'] ?? map['italic_title'], false),
      italicSubtitle: _readBool(map['italicSubtitle'] ?? map['italic_subtitle'], false),
      titleLineHeight: _readNullableDouble(map['titleLineHeight'] ?? map['title_line_height']),
      subtitleLineHeight: _readNullableDouble(map['subtitleLineHeight'] ?? map['subtitle_line_height']),
      priceLineHeight: _readNullableDouble(map['priceLineHeight'] ?? map['price_line_height']),
    );
  }

  final String? titleColorToken;
  final String? subtitleColorToken;
  final String? priceColorToken;
  final String? oldPriceColorToken;
  final String? metaColorToken;
  final String? titleStyleToken;
  final String? subtitleStyleToken;
  final String? priceStyleToken;
  final String? metaStyleToken;
  final int titleMaxLines;
  final int subtitleMaxLines;
  final double titleMinFontSize;
  final double subtitleMinFontSize;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final double? priceFontSize;
  final double? oldPriceFontSize;
  final bool titleAutoShrink;
  final bool subtitleAutoShrink;
  final bool titleBold;
  final bool priceBold;
  final bool italicTitle;
  final bool italicSubtitle;
  final double? titleLineHeight;
  final double? subtitleLineHeight;
  final double? priceLineHeight;

  bool get hasTitleColorToken => titleColorToken != null && titleColorToken!.trim().isNotEmpty;
  bool get hasSubtitleColorToken => subtitleColorToken != null && subtitleColorToken!.trim().isNotEmpty;
  bool get hasPriceColorToken => priceColorToken != null && priceColorToken!.trim().isNotEmpty;
  bool get hasOldPriceColorToken => oldPriceColorToken != null && oldPriceColorToken!.trim().isNotEmpty;

  MBCardTypographySettings copyWith({
    Object? titleColorToken = _sentinel,
    Object? subtitleColorToken = _sentinel,
    Object? priceColorToken = _sentinel,
    Object? oldPriceColorToken = _sentinel,
    Object? metaColorToken = _sentinel,
    Object? titleStyleToken = _sentinel,
    Object? subtitleStyleToken = _sentinel,
    Object? priceStyleToken = _sentinel,
    Object? metaStyleToken = _sentinel,
    int? titleMaxLines,
    int? subtitleMaxLines,
    double? titleMinFontSize,
    double? subtitleMinFontSize,
    Object? titleFontSize = _sentinel,
    Object? subtitleFontSize = _sentinel,
    Object? priceFontSize = _sentinel,
    Object? oldPriceFontSize = _sentinel,
    bool? titleAutoShrink,
    bool? subtitleAutoShrink,
    bool? titleBold,
    bool? priceBold,
    bool? italicTitle,
    bool? italicSubtitle,
    Object? titleLineHeight = _sentinel,
    Object? subtitleLineHeight = _sentinel,
    Object? priceLineHeight = _sentinel,
  }) {
    return MBCardTypographySettings(
      titleColorToken: identical(titleColorToken, _sentinel)
          ? this.titleColorToken
          : _normalizeNullableString(titleColorToken as String?),
      subtitleColorToken: identical(subtitleColorToken, _sentinel)
          ? this.subtitleColorToken
          : _normalizeNullableString(subtitleColorToken as String?),
      priceColorToken: identical(priceColorToken, _sentinel)
          ? this.priceColorToken
          : _normalizeNullableString(priceColorToken as String?),
      oldPriceColorToken: identical(oldPriceColorToken, _sentinel)
          ? this.oldPriceColorToken
          : _normalizeNullableString(oldPriceColorToken as String?),
      metaColorToken: identical(metaColorToken, _sentinel)
          ? this.metaColorToken
          : _normalizeNullableString(metaColorToken as String?),
      titleStyleToken: identical(titleStyleToken, _sentinel)
          ? this.titleStyleToken
          : _normalizeNullableString(titleStyleToken as String?),
      subtitleStyleToken: identical(subtitleStyleToken, _sentinel)
          ? this.subtitleStyleToken
          : _normalizeNullableString(subtitleStyleToken as String?),
      priceStyleToken: identical(priceStyleToken, _sentinel)
          ? this.priceStyleToken
          : _normalizeNullableString(priceStyleToken as String?),
      metaStyleToken: identical(metaStyleToken, _sentinel)
          ? this.metaStyleToken
          : _normalizeNullableString(metaStyleToken as String?),
      titleMaxLines: titleMaxLines ?? this.titleMaxLines,
      subtitleMaxLines: subtitleMaxLines ?? this.subtitleMaxLines,
      titleMinFontSize: titleMinFontSize ?? this.titleMinFontSize,
      subtitleMinFontSize: subtitleMinFontSize ?? this.subtitleMinFontSize,
      titleFontSize: identical(titleFontSize, _sentinel)
          ? this.titleFontSize
          : _readNullableDouble(titleFontSize),
      subtitleFontSize: identical(subtitleFontSize, _sentinel)
          ? this.subtitleFontSize
          : _readNullableDouble(subtitleFontSize),
      priceFontSize: identical(priceFontSize, _sentinel)
          ? this.priceFontSize
          : _readNullableDouble(priceFontSize),
      oldPriceFontSize: identical(oldPriceFontSize, _sentinel)
          ? this.oldPriceFontSize
          : _readNullableDouble(oldPriceFontSize),
      titleAutoShrink: titleAutoShrink ?? this.titleAutoShrink,
      subtitleAutoShrink: subtitleAutoShrink ?? this.subtitleAutoShrink,
      titleBold: titleBold ?? this.titleBold,
      priceBold: priceBold ?? this.priceBold,
      italicTitle: italicTitle ?? this.italicTitle,
      italicSubtitle: italicSubtitle ?? this.italicSubtitle,
      titleLineHeight: identical(titleLineHeight, _sentinel)
          ? this.titleLineHeight
          : _readNullableDouble(titleLineHeight),
      subtitleLineHeight: identical(subtitleLineHeight, _sentinel)
          ? this.subtitleLineHeight
          : _readNullableDouble(subtitleLineHeight),
      priceLineHeight: identical(priceLineHeight, _sentinel)
          ? this.priceLineHeight
          : _readNullableDouble(priceLineHeight),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'titleColorToken': _normalizeNullableString(titleColorToken),
      'subtitleColorToken': _normalizeNullableString(subtitleColorToken),
      'priceColorToken': _normalizeNullableString(priceColorToken),
      'oldPriceColorToken': _normalizeNullableString(oldPriceColorToken),
      'metaColorToken': _normalizeNullableString(metaColorToken),
      'titleStyleToken': _normalizeNullableString(titleStyleToken),
      'subtitleStyleToken': _normalizeNullableString(subtitleStyleToken),
      'priceStyleToken': _normalizeNullableString(priceStyleToken),
      'metaStyleToken': _normalizeNullableString(metaStyleToken),
      'titleMaxLines': titleMaxLines,
      'subtitleMaxLines': subtitleMaxLines,
      'titleMinFontSize': titleMinFontSize,
      'subtitleMinFontSize': subtitleMinFontSize,
      'titleFontSize': titleFontSize,
      'subtitleFontSize': subtitleFontSize,
      'priceFontSize': priceFontSize,
      'oldPriceFontSize': oldPriceFontSize,
      'titleAutoShrink': titleAutoShrink,
      'subtitleAutoShrink': subtitleAutoShrink,
      'titleBold': titleBold,
      'priceBold': priceBold,
      'italicTitle': italicTitle,
      'italicSubtitle': italicSubtitle,
      'titleLineHeight': titleLineHeight,
      'subtitleLineHeight': subtitleLineHeight,
      'priceLineHeight': priceLineHeight,
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


double? _readNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}
