// MuthoBazar Product Card Design System
// File: mb_card_meta_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_meta_settings.dart
//
// Purpose:
// Defines the supporting metadata visibility settings used by the product card
// system.
//
// Meta settings represent:
// - whether subtitle should be shown
// - whether short description should be shown
// - whether brand should be shown
// - whether unit label should be shown
// - whether stock hint should be shown
// - whether delivery hint should be shown
// - whether rating should be shown
//
// Important:
// - This model is serializable and safe for persistence.
// - This model controls metadata visibility intent only.
// - The actual metadata content still depends on the product model and the
//   renderer layer.
// - Not every card variant should expose or honor every meta setting.

class MBCardMetaSettings {
  const MBCardMetaSettings({
    this.showSubtitle = true,
    this.showShortDescription = false,
    this.showBrand = false,
    this.showUnitLabel = true,
    this.showStockHint = false,
    this.showDeliveryHint = false,
    this.showRating = false,
  });

  factory MBCardMetaSettings.fromMap(Map<String, dynamic> map) {
    return MBCardMetaSettings(
      showSubtitle: _readBool(
        map['showSubtitle'] ?? map['show_subtitle'],
        true,
      ),
      showShortDescription: _readBool(
        map['showShortDescription'] ?? map['show_short_description'],
        false,
      ),
      showBrand: _readBool(
        map['showBrand'] ?? map['show_brand'],
        false,
      ),
      showUnitLabel: _readBool(
        map['showUnitLabel'] ?? map['show_unit_label'],
        true,
      ),
      showStockHint: _readBool(
        map['showStockHint'] ?? map['show_stock_hint'],
        false,
      ),
      showDeliveryHint: _readBool(
        map['showDeliveryHint'] ?? map['show_delivery_hint'],
        false,
      ),
      showRating: _readBool(
        map['showRating'] ?? map['show_rating'],
        false,
      ),
    );
  }

  final bool showSubtitle;
  final bool showShortDescription;
  final bool showBrand;
  final bool showUnitLabel;
  final bool showStockHint;
  final bool showDeliveryHint;
  final bool showRating;

  bool get showsAnyMeta {
    return showSubtitle ||
        showShortDescription ||
        showBrand ||
        showUnitLabel ||
        showStockHint ||
        showDeliveryHint ||
        showRating;
  }

  bool get showsSecondaryText => showSubtitle || showShortDescription;

  bool get showsCommerceMeta => showStockHint || showDeliveryHint || showRating;

  MBCardMetaSettings copyWith({
    bool? showSubtitle,
    bool? showShortDescription,
    bool? showBrand,
    bool? showUnitLabel,
    bool? showStockHint,
    bool? showDeliveryHint,
    bool? showRating,
  }) {
    return MBCardMetaSettings(
      showSubtitle: showSubtitle ?? this.showSubtitle,
      showShortDescription: showShortDescription ?? this.showShortDescription,
      showBrand: showBrand ?? this.showBrand,
      showUnitLabel: showUnitLabel ?? this.showUnitLabel,
      showStockHint: showStockHint ?? this.showStockHint,
      showDeliveryHint: showDeliveryHint ?? this.showDeliveryHint,
      showRating: showRating ?? this.showRating,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showSubtitle': showSubtitle,
      'showShortDescription': showShortDescription,
      'showBrand': showBrand,
      'showUnitLabel': showUnitLabel,
      'showStockHint': showStockHint,
      'showDeliveryHint': showDeliveryHint,
      'showRating': showRating,
    };
  }

  @override
  String toString() {
    return 'MBCardMetaSettings('
        'showSubtitle: $showSubtitle, '
        'showShortDescription: $showShortDescription, '
        'showBrand: $showBrand, '
        'showUnitLabel: $showUnitLabel, '
        'showStockHint: $showStockHint, '
        'showDeliveryHint: $showDeliveryHint, '
        'showRating: $showRating'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardMetaSettings &&
        other.showSubtitle == showSubtitle &&
        other.showShortDescription == showShortDescription &&
        other.showBrand == showBrand &&
        other.showUnitLabel == showUnitLabel &&
        other.showStockHint == showStockHint &&
        other.showDeliveryHint == showDeliveryHint &&
        other.showRating == showRating;
  }

  @override
  int get hashCode {
    return Object.hash(
      showSubtitle,
      showShortDescription,
      showBrand,
      showUnitLabel,
      showStockHint,
      showDeliveryHint,
      showRating,
    );
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
