// MuthoBazar Product Card Design System
// File: mb_card_price_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_price_settings.dart
//
// Purpose:
// Defines the price-block styling and behavior settings used by the product
// card system.
//
// Price settings represent:
// - how price information should be displayed
// - whether discount badge and savings text should be shown
// - whether final price should receive stronger emphasis
// - whether currency symbol should be rendered
// - optional discount badge style preset selection
//
// Important:
// - This model is serializable and safe for persistence.
// - Mode and style fields are stored as stable string ids, not UI objects.
// - Renderers should use this model together with actual product pricing data
//   to decide how the price block should appear.
// - This model expresses display intent only. It does not calculate discounts.

import 'mb_card_price_mode.dart';

class MBCardPriceSettings {
  const MBCardPriceSettings({
    this.priceMode = MBCardPriceMode.originalAndFinal,
    this.showDiscountBadge = true,
    this.showSavingsText = false,
    this.emphasizeFinalPrice = true,
    this.showCurrencySymbol = true,
    this.discountBadgeStyle,
  });

  factory MBCardPriceSettings.fromMap(Map<String, dynamic> map) {
    return MBCardPriceSettings(
      priceMode: MBCardPriceModeHelper.parse(
        _readNullableString(map['priceMode'] ?? map['price_mode']),
        fallback: MBCardPriceMode.originalAndFinal,
      ),
      showDiscountBadge: _readBool(
        map['showDiscountBadge'] ?? map['show_discount_badge'],
        true,
      ),
      showSavingsText: _readBool(
        map['showSavingsText'] ?? map['show_savings_text'],
        false,
      ),
      emphasizeFinalPrice: _readBool(
        map['emphasizeFinalPrice'] ?? map['emphasize_final_price'],
        true,
      ),
      showCurrencySymbol: _readBool(
        map['showCurrencySymbol'] ?? map['show_currency_symbol'],
        true,
      ),
      discountBadgeStyle: _readNullableString(
        map['discountBadgeStyle'] ?? map['discount_badge_style'],
      ),
    );
  }

  final MBCardPriceMode priceMode;
  final bool showDiscountBadge;
  final bool showSavingsText;
  final bool emphasizeFinalPrice;
  final bool showCurrencySymbol;
  final String? discountBadgeStyle;

  String get priceModeId => priceMode.id;

  String get priceModeLabel => priceMode.label;

  bool get showsAnyPrice => !priceMode.hidesAllPrice;

  bool get showsFinalPrice => priceMode.showsFinalPrice;

  bool get showsOriginalPrice => priceMode.showsOriginalPrice;

  bool get showsDiscountInfo => priceMode.showsDiscountInfo;

  bool get hasDiscountBadgeStyle =>
      discountBadgeStyle != null && discountBadgeStyle!.trim().isNotEmpty;

  MBCardPriceSettings copyWith({
    MBCardPriceMode? priceMode,
    bool? showDiscountBadge,
    bool? showSavingsText,
    bool? emphasizeFinalPrice,
    bool? showCurrencySymbol,
    Object? discountBadgeStyle = _sentinel,
  }) {
    return MBCardPriceSettings(
      priceMode: priceMode ?? this.priceMode,
      showDiscountBadge: showDiscountBadge ?? this.showDiscountBadge,
      showSavingsText: showSavingsText ?? this.showSavingsText,
      emphasizeFinalPrice: emphasizeFinalPrice ?? this.emphasizeFinalPrice,
      showCurrencySymbol: showCurrencySymbol ?? this.showCurrencySymbol,
      discountBadgeStyle: identical(discountBadgeStyle, _sentinel)
          ? this.discountBadgeStyle
          : _normalizeNullableString(discountBadgeStyle as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'priceMode': priceMode.id,
      'showDiscountBadge': showDiscountBadge,
      'showSavingsText': showSavingsText,
      'emphasizeFinalPrice': emphasizeFinalPrice,
      'showCurrencySymbol': showCurrencySymbol,
      'discountBadgeStyle': _normalizeNullableString(discountBadgeStyle),
    };
  }

  @override
  String toString() {
    return 'MBCardPriceSettings('
        'priceMode: ${priceMode.id}, '
        'showDiscountBadge: $showDiscountBadge, '
        'showSavingsText: $showSavingsText, '
        'emphasizeFinalPrice: $emphasizeFinalPrice, '
        'showCurrencySymbol: $showCurrencySymbol, '
        'discountBadgeStyle: $discountBadgeStyle'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardPriceSettings &&
        other.priceMode == priceMode &&
        other.showDiscountBadge == showDiscountBadge &&
        other.showSavingsText == showSavingsText &&
        other.emphasizeFinalPrice == emphasizeFinalPrice &&
        other.showCurrencySymbol == showCurrencySymbol &&
        other.discountBadgeStyle == discountBadgeStyle;
  }

  @override
  int get hashCode {
    return Object.hash(
      priceMode,
      showDiscountBadge,
      showSavingsText,
      emphasizeFinalPrice,
      showCurrencySymbol,
      discountBadgeStyle,
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
}
