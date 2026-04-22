// MuthoBazar Product Card Design System
// File: mb_card_action_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_action_settings.dart
//
// Purpose:
// Defines the commerce-action settings used by the product card system.
//
// Action settings represent:
// - whether add-to-cart is shown
// - whether quick add is shown
// - whether wishlist is shown
// - whether a details CTA is shown
// - optional CTA style preset selection
// - optional CTA color token selection
//
// Important:
// - This model is serializable and safe for persistence.
// - Style/token fields are stored as stable string ids, not concrete widgets,
//   button styles, or colors. UI resolution must happen later in shared_ui.
// - Not every card variant should expose or honor every action setting. The
//   variant definition layer should decide what is supported.

class MBCardActionSettings {
  const MBCardActionSettings({
    this.showAddToCart = false,
    this.showQuickAdd = false,
    this.showWishlist = false,
    this.showViewDetails = false,
    this.ctaStylePreset,
    this.ctaColorToken,
  });

  factory MBCardActionSettings.fromMap(Map<String, dynamic> map) {
    return MBCardActionSettings(
      showAddToCart: _readBool(
        map['showAddToCart'] ?? map['show_add_to_cart'],
        false,
      ),
      showQuickAdd: _readBool(
        map['showQuickAdd'] ?? map['show_quick_add'],
        false,
      ),
      showWishlist: _readBool(
        map['showWishlist'] ?? map['show_wishlist'],
        false,
      ),
      showViewDetails: _readBool(
        map['showViewDetails'] ?? map['show_view_details'],
        false,
      ),
      ctaStylePreset: _readNullableString(
        map['ctaStylePreset'] ?? map['cta_style_preset'],
      ),
      ctaColorToken: _readNullableString(
        map['ctaColorToken'] ?? map['cta_color_token'],
      ),
    );
  }

  final bool showAddToCart;
  final bool showQuickAdd;
  final bool showWishlist;
  final bool showViewDetails;
  final String? ctaStylePreset;
  final String? ctaColorToken;

  bool get hasCtaStylePreset =>
      ctaStylePreset != null && ctaStylePreset!.trim().isNotEmpty;

  bool get hasCtaColorToken =>
      ctaColorToken != null && ctaColorToken!.trim().isNotEmpty;

  bool get showsAnyAction =>
      showAddToCart || showQuickAdd || showWishlist || showViewDetails;

  MBCardActionSettings copyWith({
    bool? showAddToCart,
    bool? showQuickAdd,
    bool? showWishlist,
    bool? showViewDetails,
    Object? ctaStylePreset = _sentinel,
    Object? ctaColorToken = _sentinel,
  }) {
    return MBCardActionSettings(
      showAddToCart: showAddToCart ?? this.showAddToCart,
      showQuickAdd: showQuickAdd ?? this.showQuickAdd,
      showWishlist: showWishlist ?? this.showWishlist,
      showViewDetails: showViewDetails ?? this.showViewDetails,
      ctaStylePreset: identical(ctaStylePreset, _sentinel)
          ? this.ctaStylePreset
          : _normalizeNullableString(ctaStylePreset as String?),
      ctaColorToken: identical(ctaColorToken, _sentinel)
          ? this.ctaColorToken
          : _normalizeNullableString(ctaColorToken as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showAddToCart': showAddToCart,
      'showQuickAdd': showQuickAdd,
      'showWishlist': showWishlist,
      'showViewDetails': showViewDetails,
      'ctaStylePreset': _normalizeNullableString(ctaStylePreset),
      'ctaColorToken': _normalizeNullableString(ctaColorToken),
    };
  }

  @override
  String toString() {
    return 'MBCardActionSettings('
        'showAddToCart: $showAddToCart, '
        'showQuickAdd: $showQuickAdd, '
        'showWishlist: $showWishlist, '
        'showViewDetails: $showViewDetails, '
        'ctaStylePreset: $ctaStylePreset, '
        'ctaColorToken: $ctaColorToken'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardActionSettings &&
        other.showAddToCart == showAddToCart &&
        other.showQuickAdd == showQuickAdd &&
        other.showWishlist == showWishlist &&
        other.showViewDetails == showViewDetails &&
        other.ctaStylePreset == ctaStylePreset &&
        other.ctaColorToken == ctaColorToken;
  }

  @override
  int get hashCode {
    return Object.hash(
      showAddToCart,
      showQuickAdd,
      showWishlist,
      showViewDetails,
      ctaStylePreset,
      ctaColorToken,
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
