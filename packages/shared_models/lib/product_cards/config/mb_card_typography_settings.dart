// MuthoBazar Product Card Design System
// File: mb_card_typography_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_typography_settings.dart
//
// Purpose:
// Defines the typography-level styling settings used by the product card system.
//
// Typography settings represent:
// - title/subtitle/price/old-price token-based color selection
// - title/subtitle token-based text style selection
// - max line rules for title and subtitle
// - emphasis flags for title and price
//
// Important:
// - This model is serializable and safe for persistence.
// - Token fields are stored as stable string ids, not concrete TextStyle or
//   Color values. UI resolution must happen later in shared_ui.
// - This model controls style intent only. Layout structure still belongs to
//   family and variant definitions.

class MBCardTypographySettings {
  const MBCardTypographySettings({
    this.titleColorToken,
    this.subtitleColorToken,
    this.priceColorToken,
    this.oldPriceColorToken,
    this.titleStyleToken,
    this.subtitleStyleToken,
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 1,
    this.titleBold = true,
    this.priceBold = true,
  });

  factory MBCardTypographySettings.fromMap(Map<String, dynamic> map) {
    return MBCardTypographySettings(
      titleColorToken: _readNullableString(
        map['titleColorToken'] ?? map['title_color_token'],
      ),
      subtitleColorToken: _readNullableString(
        map['subtitleColorToken'] ?? map['subtitle_color_token'],
      ),
      priceColorToken: _readNullableString(
        map['priceColorToken'] ?? map['price_color_token'],
      ),
      oldPriceColorToken: _readNullableString(
        map['oldPriceColorToken'] ?? map['old_price_color_token'],
      ),
      titleStyleToken: _readNullableString(
        map['titleStyleToken'] ?? map['title_style_token'],
      ),
      subtitleStyleToken: _readNullableString(
        map['subtitleStyleToken'] ?? map['subtitle_style_token'],
      ),
      titleMaxLines: _readInt(map['titleMaxLines'] ?? map['title_max_lines'], 2),
      subtitleMaxLines: _readInt(
        map['subtitleMaxLines'] ?? map['subtitle_max_lines'],
        1,
      ),
      titleBold: _readBool(map['titleBold'] ?? map['title_bold'], true),
      priceBold: _readBool(map['priceBold'] ?? map['price_bold'], true),
    );
  }

  final String? titleColorToken;
  final String? subtitleColorToken;
  final String? priceColorToken;
  final String? oldPriceColorToken;
  final String? titleStyleToken;
  final String? subtitleStyleToken;
  final int titleMaxLines;
  final int subtitleMaxLines;
  final bool titleBold;
  final bool priceBold;

  bool get hasTitleColorToken =>
      titleColorToken != null && titleColorToken!.trim().isNotEmpty;

  bool get hasSubtitleColorToken =>
      subtitleColorToken != null && subtitleColorToken!.trim().isNotEmpty;

  bool get hasPriceColorToken =>
      priceColorToken != null && priceColorToken!.trim().isNotEmpty;

  bool get hasOldPriceColorToken =>
      oldPriceColorToken != null && oldPriceColorToken!.trim().isNotEmpty;

  bool get hasTitleStyleToken =>
      titleStyleToken != null && titleStyleToken!.trim().isNotEmpty;

  bool get hasSubtitleStyleToken =>
      subtitleStyleToken != null && subtitleStyleToken!.trim().isNotEmpty;

  MBCardTypographySettings copyWith({
    Object? titleColorToken = _sentinel,
    Object? subtitleColorToken = _sentinel,
    Object? priceColorToken = _sentinel,
    Object? oldPriceColorToken = _sentinel,
    Object? titleStyleToken = _sentinel,
    Object? subtitleStyleToken = _sentinel,
    int? titleMaxLines,
    int? subtitleMaxLines,
    bool? titleBold,
    bool? priceBold,
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
      titleStyleToken: identical(titleStyleToken, _sentinel)
          ? this.titleStyleToken
          : _normalizeNullableString(titleStyleToken as String?),
      subtitleStyleToken: identical(subtitleStyleToken, _sentinel)
          ? this.subtitleStyleToken
          : _normalizeNullableString(subtitleStyleToken as String?),
      titleMaxLines: titleMaxLines ?? this.titleMaxLines,
      subtitleMaxLines: subtitleMaxLines ?? this.subtitleMaxLines,
      titleBold: titleBold ?? this.titleBold,
      priceBold: priceBold ?? this.priceBold,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'titleColorToken': _normalizeNullableString(titleColorToken),
      'subtitleColorToken': _normalizeNullableString(subtitleColorToken),
      'priceColorToken': _normalizeNullableString(priceColorToken),
      'oldPriceColorToken': _normalizeNullableString(oldPriceColorToken),
      'titleStyleToken': _normalizeNullableString(titleStyleToken),
      'subtitleStyleToken': _normalizeNullableString(subtitleStyleToken),
      'titleMaxLines': titleMaxLines,
      'subtitleMaxLines': subtitleMaxLines,
      'titleBold': titleBold,
      'priceBold': priceBold,
    };
  }

  @override
  String toString() {
    return 'MBCardTypographySettings('
        'titleColorToken: $titleColorToken, '
        'subtitleColorToken: $subtitleColorToken, '
        'priceColorToken: $priceColorToken, '
        'oldPriceColorToken: $oldPriceColorToken, '
        'titleStyleToken: $titleStyleToken, '
        'subtitleStyleToken: $subtitleStyleToken, '
        'titleMaxLines: $titleMaxLines, '
        'subtitleMaxLines: $subtitleMaxLines, '
        'titleBold: $titleBold, '
        'priceBold: $priceBold'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardTypographySettings &&
        other.titleColorToken == titleColorToken &&
        other.subtitleColorToken == subtitleColorToken &&
        other.priceColorToken == priceColorToken &&
        other.oldPriceColorToken == oldPriceColorToken &&
        other.titleStyleToken == titleStyleToken &&
        other.subtitleStyleToken == subtitleStyleToken &&
        other.titleMaxLines == titleMaxLines &&
        other.subtitleMaxLines == subtitleMaxLines &&
        other.titleBold == titleBold &&
        other.priceBold == priceBold;
  }

  @override
  int get hashCode {
    return Object.hash(
      titleColorToken,
      subtitleColorToken,
      priceColorToken,
      oldPriceColorToken,
      titleStyleToken,
      subtitleStyleToken,
      titleMaxLines,
      subtitleMaxLines,
      titleBold,
      priceBold,
    );
  }

  static const Object _sentinel = Object();

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

  static int _readInt(Object? value, int fallback) {
    if (value == null) {
      return fallback;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString().trim()) ?? fallback;
  }
}
