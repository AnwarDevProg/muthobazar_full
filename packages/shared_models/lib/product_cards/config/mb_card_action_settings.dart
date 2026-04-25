// MuthoBazar Product Card Design System
// File: mb_card_action_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_action_settings.dart
//
// Purpose:
// Defines commerce action visibility and styling settings.

class MBCardActionSettings {
  const MBCardActionSettings({
    this.showAddToCart = false,
    this.showBuyNow = false,
    this.showQuickAdd = false,
    this.showWishlist = false,
    this.showViewDetails = false,
    this.showCompare = false,
    this.showShare = false,
    this.ctaText,
    this.ctaStylePreset,
    this.ctaColorToken,
    this.ctaTextColorToken,
    this.ctaIcon,
    this.primaryCtaPosition = 'bottom_right',
  });

  factory MBCardActionSettings.fromMap(Map map) {
    return MBCardActionSettings(
      showAddToCart: _readBool(map['showAddToCart'] ?? map['show_add_to_cart'], false),
      showBuyNow: _readBool(map['showBuyNow'] ?? map['show_buy_now'], false),
      showQuickAdd: _readBool(map['showQuickAdd'] ?? map['show_quick_add'], false),
      showWishlist: _readBool(map['showWishlist'] ?? map['show_wishlist'], false),
      showViewDetails: _readBool(map['showViewDetails'] ?? map['show_view_details'], false),
      showCompare: _readBool(map['showCompare'] ?? map['show_compare'], false),
      showShare: _readBool(map['showShare'] ?? map['show_share'], false),
      ctaText: _readNullableString(map['ctaText'] ?? map['cta_text']),
      ctaStylePreset: _readNullableString(map['ctaStylePreset'] ?? map['cta_style_preset']),
      ctaColorToken: _readNullableString(map['ctaColorToken'] ?? map['cta_color_token']),
      ctaTextColorToken: _readNullableString(map['ctaTextColorToken'] ?? map['cta_text_color_token']),
      ctaIcon: _readNullableString(map['ctaIcon'] ?? map['cta_icon']),
      primaryCtaPosition: _readString(map['primaryCtaPosition'] ?? map['primary_cta_position'], 'bottom_right'),
    );
  }

  final bool showAddToCart;
  final bool showBuyNow;
  final bool showQuickAdd;
  final bool showWishlist;
  final bool showViewDetails;
  final bool showCompare;
  final bool showShare;
  final String? ctaText;
  final String? ctaStylePreset;
  final String? ctaColorToken;
  final String? ctaTextColorToken;
  final String? ctaIcon;
  final String primaryCtaPosition;

  bool get hasCtaStylePreset => ctaStylePreset != null && ctaStylePreset!.trim().isNotEmpty;
  bool get hasCtaColorToken => ctaColorToken != null && ctaColorToken!.trim().isNotEmpty;
  bool get showsAnyAction =>
      showAddToCart ||
      showBuyNow ||
      showQuickAdd ||
      showWishlist ||
      showViewDetails ||
      showCompare ||
      showShare;

  String get effectiveCtaText {
    final custom = ctaText?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    if (showBuyNow) return 'Buy';
    if (showAddToCart) return 'Add';
    if (showViewDetails) return 'View';
    return 'Buy';
  }

  MBCardActionSettings copyWith({
    bool? showAddToCart,
    bool? showBuyNow,
    bool? showQuickAdd,
    bool? showWishlist,
    bool? showViewDetails,
    bool? showCompare,
    bool? showShare,
    Object? ctaText = _sentinel,
    Object? ctaStylePreset = _sentinel,
    Object? ctaColorToken = _sentinel,
    Object? ctaTextColorToken = _sentinel,
    Object? ctaIcon = _sentinel,
    String? primaryCtaPosition,
  }) {
    return MBCardActionSettings(
      showAddToCart: showAddToCart ?? this.showAddToCart,
      showBuyNow: showBuyNow ?? this.showBuyNow,
      showQuickAdd: showQuickAdd ?? this.showQuickAdd,
      showWishlist: showWishlist ?? this.showWishlist,
      showViewDetails: showViewDetails ?? this.showViewDetails,
      showCompare: showCompare ?? this.showCompare,
      showShare: showShare ?? this.showShare,
      ctaText: identical(ctaText, _sentinel)
          ? this.ctaText
          : _normalizeNullableString(ctaText as String?),
      ctaStylePreset: identical(ctaStylePreset, _sentinel)
          ? this.ctaStylePreset
          : _normalizeNullableString(ctaStylePreset as String?),
      ctaColorToken: identical(ctaColorToken, _sentinel)
          ? this.ctaColorToken
          : _normalizeNullableString(ctaColorToken as String?),
      ctaTextColorToken: identical(ctaTextColorToken, _sentinel)
          ? this.ctaTextColorToken
          : _normalizeNullableString(ctaTextColorToken as String?),
      ctaIcon: identical(ctaIcon, _sentinel)
          ? this.ctaIcon
          : _normalizeNullableString(ctaIcon as String?),
      primaryCtaPosition: primaryCtaPosition ?? this.primaryCtaPosition,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'showAddToCart': showAddToCart,
      'showBuyNow': showBuyNow,
      'showQuickAdd': showQuickAdd,
      'showWishlist': showWishlist,
      'showViewDetails': showViewDetails,
      'showCompare': showCompare,
      'showShare': showShare,
      'ctaText': _normalizeNullableString(ctaText),
      'ctaStylePreset': _normalizeNullableString(ctaStylePreset),
      'ctaColorToken': _normalizeNullableString(ctaColorToken),
      'ctaTextColorToken': _normalizeNullableString(ctaTextColorToken),
      'ctaIcon': _normalizeNullableString(ctaIcon),
      'primaryCtaPosition': primaryCtaPosition,
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
