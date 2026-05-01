// MuthoBazar Product Card Design System
// File: mb_card_price_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_price_settings.dart
//
// Purpose:
// Defines price-block styling and behavior settings.

import 'mb_card_price_mode.dart';

class MBCardPriceSettings {
  const MBCardPriceSettings({
    this.priceMode = MBCardPriceMode.originalAndFinal,
    this.showDiscountBadge = true,
    this.showSavingsText = false,
    this.emphasizeFinalPrice = true,
    this.showCurrencySymbol = true,
    this.showOriginalPriceWhenSaleActive = true,
    this.savingsDisplayMode = 'percent',
    this.showPriceBadge = false,
    this.discountBadgeStyle,
    this.priceBadgeStyleToken,
    this.priceBadgeBackgroundToken,
    this.priceBadgeTextColorToken,
    this.finalPricePrefix,
    this.finalPriceSuffix,
  });

  factory MBCardPriceSettings.fromMap(Map map) {
    return MBCardPriceSettings(
      priceMode: MBCardPriceModeHelper.parse(
        _readNullableString(map['priceMode'] ?? map['price_mode']),
        fallback: MBCardPriceMode.originalAndFinal,
      ),
      showDiscountBadge: _readBool(map['showDiscountBadge'] ?? map['show_discount_badge'], true),
      showSavingsText: _readBool(map['showSavingsText'] ?? map['show_savings_text'], false),
      emphasizeFinalPrice: _readBool(map['emphasizeFinalPrice'] ?? map['emphasize_final_price'], true),
      showCurrencySymbol: _readBool(map['showCurrencySymbol'] ?? map['show_currency_symbol'], true),
      showOriginalPriceWhenSaleActive: _readBool(
        map['showOriginalPriceWhenSaleActive'] ??
            map['show_original_price_when_sale_active'],
        true,
      ),
      savingsDisplayMode: _readString(map['savingsDisplayMode'] ?? map['savings_display_mode'], 'percent'),
      showPriceBadge: _readBool(map['showPriceBadge'] ?? map['show_price_badge'], false),
      discountBadgeStyle: _readNullableString(map['discountBadgeStyle'] ?? map['discount_badge_style']),
      priceBadgeStyleToken: _readNullableString(map['priceBadgeStyleToken'] ?? map['price_badge_style_token']),
      priceBadgeBackgroundToken: _readNullableString(map['priceBadgeBackgroundToken'] ?? map['price_badge_background_token']),
      priceBadgeTextColorToken: _readNullableString(map['priceBadgeTextColorToken'] ?? map['price_badge_text_color_token']),
      finalPricePrefix: _readNullableString(map['finalPricePrefix'] ?? map['final_price_prefix']),
      finalPriceSuffix: _readNullableString(map['finalPriceSuffix'] ?? map['final_price_suffix']),
    );
  }

  final MBCardPriceMode priceMode;
  final bool showDiscountBadge;
  final bool showSavingsText;
  final bool emphasizeFinalPrice;
  final bool showCurrencySymbol;
  final bool showOriginalPriceWhenSaleActive;
  final String savingsDisplayMode;
  final bool showPriceBadge;
  final String? discountBadgeStyle;
  final String? priceBadgeStyleToken;
  final String? priceBadgeBackgroundToken;
  final String? priceBadgeTextColorToken;
  final String? finalPricePrefix;
  final String? finalPriceSuffix;

  String get priceModeId => priceMode.id;
  String get priceModeLabel => priceMode.label;
  bool get showsAnyPrice => !priceMode.hidesAllPrice;
  bool get showsFinalPrice => priceMode.showsFinalPrice;
  bool get showsOriginalPrice =>
      priceMode.showsOriginalPrice && showOriginalPriceWhenSaleActive;
  bool get showsDiscountInfo => priceMode.showsDiscountInfo;
  bool get hasDiscountBadgeStyle => discountBadgeStyle != null && discountBadgeStyle!.trim().isNotEmpty;
  bool get savesAsPercent => savingsDisplayMode.trim().toLowerCase() == 'percent';
  bool get savesAsAmount => savingsDisplayMode.trim().toLowerCase() == 'amount';
  bool get savesAsBoth => savingsDisplayMode.trim().toLowerCase() == 'both';

  MBCardPriceSettings copyWith({
    MBCardPriceMode? priceMode,
    bool? showDiscountBadge,
    bool? showSavingsText,
    bool? emphasizeFinalPrice,
    bool? showCurrencySymbol,
    bool? showOriginalPriceWhenSaleActive,
    String? savingsDisplayMode,
    bool? showPriceBadge,
    Object? discountBadgeStyle = _sentinel,
    Object? priceBadgeStyleToken = _sentinel,
    Object? priceBadgeBackgroundToken = _sentinel,
    Object? priceBadgeTextColorToken = _sentinel,
    Object? finalPricePrefix = _sentinel,
    Object? finalPriceSuffix = _sentinel,
  }) {
    return MBCardPriceSettings(
      priceMode: priceMode ?? this.priceMode,
      showDiscountBadge: showDiscountBadge ?? this.showDiscountBadge,
      showSavingsText: showSavingsText ?? this.showSavingsText,
      emphasizeFinalPrice: emphasizeFinalPrice ?? this.emphasizeFinalPrice,
      showCurrencySymbol: showCurrencySymbol ?? this.showCurrencySymbol,
      showOriginalPriceWhenSaleActive:
          showOriginalPriceWhenSaleActive ?? this.showOriginalPriceWhenSaleActive,
      savingsDisplayMode: savingsDisplayMode ?? this.savingsDisplayMode,
      showPriceBadge: showPriceBadge ?? this.showPriceBadge,
      discountBadgeStyle: identical(discountBadgeStyle, _sentinel)
          ? this.discountBadgeStyle
          : _normalizeNullableString(discountBadgeStyle as String?),
      priceBadgeStyleToken: identical(priceBadgeStyleToken, _sentinel)
          ? this.priceBadgeStyleToken
          : _normalizeNullableString(priceBadgeStyleToken as String?),
      priceBadgeBackgroundToken: identical(priceBadgeBackgroundToken, _sentinel)
          ? this.priceBadgeBackgroundToken
          : _normalizeNullableString(priceBadgeBackgroundToken as String?),
      priceBadgeTextColorToken: identical(priceBadgeTextColorToken, _sentinel)
          ? this.priceBadgeTextColorToken
          : _normalizeNullableString(priceBadgeTextColorToken as String?),
      finalPricePrefix: identical(finalPricePrefix, _sentinel)
          ? this.finalPricePrefix
          : _normalizeNullableString(finalPricePrefix as String?),
      finalPriceSuffix: identical(finalPriceSuffix, _sentinel)
          ? this.finalPriceSuffix
          : _normalizeNullableString(finalPriceSuffix as String?),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'priceMode': priceMode.id,
      'showDiscountBadge': showDiscountBadge,
      'showSavingsText': showSavingsText,
      'emphasizeFinalPrice': emphasizeFinalPrice,
      'showCurrencySymbol': showCurrencySymbol,
      'showOriginalPriceWhenSaleActive': showOriginalPriceWhenSaleActive,
      'savingsDisplayMode': savingsDisplayMode,
      'showPriceBadge': showPriceBadge,
      'discountBadgeStyle': _normalizeNullableString(discountBadgeStyle),
      'priceBadgeStyleToken': _normalizeNullableString(priceBadgeStyleToken),
      'priceBadgeBackgroundToken': _normalizeNullableString(priceBadgeBackgroundToken),
      'priceBadgeTextColorToken': _normalizeNullableString(priceBadgeTextColorToken),
      'finalPricePrefix': _normalizeNullableString(finalPricePrefix),
      'finalPriceSuffix': _normalizeNullableString(finalPriceSuffix),
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
