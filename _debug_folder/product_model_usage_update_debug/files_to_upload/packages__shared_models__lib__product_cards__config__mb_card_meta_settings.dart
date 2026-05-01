// MuthoBazar Product Card Design System
// File: mb_card_meta_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_meta_settings.dart
//
// Purpose:
// Defines supporting metadata visibility settings.

class MBCardMetaSettings {
  const MBCardMetaSettings({
    this.showSubtitle = true,
    this.showShortDescription = false,
    this.showBrand = false,
    this.showCategory = false,
    this.showUnitLabel = false,
    this.showStockHint = false,
    this.showDeliveryHint = false,
    this.showRating = false,
    this.showReviewCount = false,
    this.showSku = false,
    this.showProductCode = false,
  });

  factory MBCardMetaSettings.fromMap(Map map) {
    return MBCardMetaSettings(
      showSubtitle: _readBool(map['showSubtitle'] ?? map['show_subtitle'], true),
      showShortDescription: _readBool(map['showShortDescription'] ?? map['show_short_description'], false),
      showBrand: _readBool(map['showBrand'] ?? map['show_brand'], false),
      showCategory: _readBool(map['showCategory'] ?? map['show_category'], false),
      showUnitLabel: _readBool(map['showUnitLabel'] ?? map['show_unit_label'], false),
      showStockHint: _readBool(map['showStockHint'] ?? map['show_stock_hint'], false),
      showDeliveryHint: _readBool(map['showDeliveryHint'] ?? map['show_delivery_hint'], false),
      showRating: _readBool(map['showRating'] ?? map['show_rating'], false),
      showReviewCount: _readBool(map['showReviewCount'] ?? map['show_review_count'], false),
      showSku: _readBool(map['showSku'] ?? map['show_sku'], false),
      showProductCode: _readBool(map['showProductCode'] ?? map['show_product_code'], false),
    );
  }

  final bool showSubtitle;
  final bool showShortDescription;
  final bool showBrand;
  final bool showCategory;
  final bool showUnitLabel;
  final bool showStockHint;
  final bool showDeliveryHint;
  final bool showRating;
  final bool showReviewCount;
  final bool showSku;
  final bool showProductCode;

  bool get showsAnyMeta =>
      showSubtitle ||
      showShortDescription ||
      showBrand ||
      showCategory ||
      showUnitLabel ||
      showStockHint ||
      showDeliveryHint ||
      showRating ||
      showReviewCount ||
      showSku ||
      showProductCode;

  MBCardMetaSettings copyWith({
    bool? showSubtitle,
    bool? showShortDescription,
    bool? showBrand,
    bool? showCategory,
    bool? showUnitLabel,
    bool? showStockHint,
    bool? showDeliveryHint,
    bool? showRating,
    bool? showReviewCount,
    bool? showSku,
    bool? showProductCode,
  }) {
    return MBCardMetaSettings(
      showSubtitle: showSubtitle ?? this.showSubtitle,
      showShortDescription: showShortDescription ?? this.showShortDescription,
      showBrand: showBrand ?? this.showBrand,
      showCategory: showCategory ?? this.showCategory,
      showUnitLabel: showUnitLabel ?? this.showUnitLabel,
      showStockHint: showStockHint ?? this.showStockHint,
      showDeliveryHint: showDeliveryHint ?? this.showDeliveryHint,
      showRating: showRating ?? this.showRating,
      showReviewCount: showReviewCount ?? this.showReviewCount,
      showSku: showSku ?? this.showSku,
      showProductCode: showProductCode ?? this.showProductCode,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'showSubtitle': showSubtitle,
      'showShortDescription': showShortDescription,
      'showBrand': showBrand,
      'showCategory': showCategory,
      'showUnitLabel': showUnitLabel,
      'showStockHint': showStockHint,
      'showDeliveryHint': showDeliveryHint,
      'showRating': showRating,
      'showReviewCount': showReviewCount,
      'showSku': showSku,
      'showProductCode': showProductCode,
    };
  }
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
