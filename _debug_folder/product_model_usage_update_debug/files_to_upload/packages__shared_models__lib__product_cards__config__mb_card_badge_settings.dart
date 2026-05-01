// MuthoBazar Product Card Design System
// File: mb_card_badge_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_badge_settings.dart
//
// Purpose:
// Defines badge/chip/ribbon-like tag presentation settings.

class MBCardBadgeSettings {
  const MBCardBadgeSettings({
    this.showPrimaryBadge = true,
    this.showSecondaryBadge = false,
    this.showDiscountBadge = false,
    this.showNewBadge = false,
    this.showBestSellerBadge = false,
    this.showFlashBadge = false,
    this.primaryBadgeText,
    this.secondaryBadgeText,
    this.primaryBadgeStyle,
    this.secondaryBadgeStyle,
    this.badgePlacement = 'top_left',
    this.badgeColorToken,
    this.badgeTextColorToken,
    this.discountBadgeTextMode = 'percent',
  });

  factory MBCardBadgeSettings.fromMap(Map map) {
    return MBCardBadgeSettings(
      showPrimaryBadge: _readBool(map['showPrimaryBadge'] ?? map['show_primary_badge'], true),
      showSecondaryBadge: _readBool(map['showSecondaryBadge'] ?? map['show_secondary_badge'], false),
      showDiscountBadge: _readBool(map['showDiscountBadge'] ?? map['show_discount_badge'], false),
      showNewBadge: _readBool(map['showNewBadge'] ?? map['show_new_badge'], false),
      showBestSellerBadge: _readBool(map['showBestSellerBadge'] ?? map['show_best_seller_badge'], false),
      showFlashBadge: _readBool(map['showFlashBadge'] ?? map['show_flash_badge'], false),
      primaryBadgeText: _readNullableString(map['primaryBadgeText'] ?? map['primary_badge_text']),
      secondaryBadgeText: _readNullableString(map['secondaryBadgeText'] ?? map['secondary_badge_text']),
      primaryBadgeStyle: _readNullableString(map['primaryBadgeStyle'] ?? map['primary_badge_style']),
      secondaryBadgeStyle: _readNullableString(map['secondaryBadgeStyle'] ?? map['secondary_badge_style']),
      badgePlacement: _readString(map['badgePlacement'] ?? map['badge_placement'], 'top_left'),
      badgeColorToken: _readNullableString(map['badgeColorToken'] ?? map['badge_color_token']),
      badgeTextColorToken: _readNullableString(map['badgeTextColorToken'] ?? map['badge_text_color_token']),
      discountBadgeTextMode: _readString(map['discountBadgeTextMode'] ?? map['discount_badge_text_mode'], 'percent'),
    );
  }

  final bool showPrimaryBadge;
  final bool showSecondaryBadge;
  final bool showDiscountBadge;
  final bool showNewBadge;
  final bool showBestSellerBadge;
  final bool showFlashBadge;
  final String? primaryBadgeText;
  final String? secondaryBadgeText;
  final String? primaryBadgeStyle;
  final String? secondaryBadgeStyle;
  final String badgePlacement;
  final String? badgeColorToken;
  final String? badgeTextColorToken;
  final String discountBadgeTextMode;

  bool get hasPrimaryBadgeStyle => primaryBadgeStyle != null && primaryBadgeStyle!.trim().isNotEmpty;
  bool get hasSecondaryBadgeStyle => secondaryBadgeStyle != null && secondaryBadgeStyle!.trim().isNotEmpty;
  bool get showsAnyBadge =>
      showPrimaryBadge ||
      showSecondaryBadge ||
      showDiscountBadge ||
      showNewBadge ||
      showBestSellerBadge ||
      showFlashBadge;
  bool get isTopLeftPlacement => badgePlacement.trim().toLowerCase() == 'top_left';
  bool get isTopRightPlacement => badgePlacement.trim().toLowerCase() == 'top_right';
  bool get isBottomLeftPlacement => badgePlacement.trim().toLowerCase() == 'bottom_left';
  bool get isBottomRightPlacement => badgePlacement.trim().toLowerCase() == 'bottom_right';
  bool get isInlinePlacement => badgePlacement.trim().toLowerCase() == 'inline';

  MBCardBadgeSettings copyWith({
    bool? showPrimaryBadge,
    bool? showSecondaryBadge,
    bool? showDiscountBadge,
    bool? showNewBadge,
    bool? showBestSellerBadge,
    bool? showFlashBadge,
    Object? primaryBadgeText = _sentinel,
    Object? secondaryBadgeText = _sentinel,
    Object? primaryBadgeStyle = _sentinel,
    Object? secondaryBadgeStyle = _sentinel,
    String? badgePlacement,
    Object? badgeColorToken = _sentinel,
    Object? badgeTextColorToken = _sentinel,
    String? discountBadgeTextMode,
  }) {
    return MBCardBadgeSettings(
      showPrimaryBadge: showPrimaryBadge ?? this.showPrimaryBadge,
      showSecondaryBadge: showSecondaryBadge ?? this.showSecondaryBadge,
      showDiscountBadge: showDiscountBadge ?? this.showDiscountBadge,
      showNewBadge: showNewBadge ?? this.showNewBadge,
      showBestSellerBadge: showBestSellerBadge ?? this.showBestSellerBadge,
      showFlashBadge: showFlashBadge ?? this.showFlashBadge,
      primaryBadgeText: identical(primaryBadgeText, _sentinel)
          ? this.primaryBadgeText
          : _normalizeNullableString(primaryBadgeText as String?),
      secondaryBadgeText: identical(secondaryBadgeText, _sentinel)
          ? this.secondaryBadgeText
          : _normalizeNullableString(secondaryBadgeText as String?),
      primaryBadgeStyle: identical(primaryBadgeStyle, _sentinel)
          ? this.primaryBadgeStyle
          : _normalizeNullableString(primaryBadgeStyle as String?),
      secondaryBadgeStyle: identical(secondaryBadgeStyle, _sentinel)
          ? this.secondaryBadgeStyle
          : _normalizeNullableString(secondaryBadgeStyle as String?),
      badgePlacement: badgePlacement ?? this.badgePlacement,
      badgeColorToken: identical(badgeColorToken, _sentinel)
          ? this.badgeColorToken
          : _normalizeNullableString(badgeColorToken as String?),
      badgeTextColorToken: identical(badgeTextColorToken, _sentinel)
          ? this.badgeTextColorToken
          : _normalizeNullableString(badgeTextColorToken as String?),
      discountBadgeTextMode: discountBadgeTextMode ?? this.discountBadgeTextMode,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'showPrimaryBadge': showPrimaryBadge,
      'showSecondaryBadge': showSecondaryBadge,
      'showDiscountBadge': showDiscountBadge,
      'showNewBadge': showNewBadge,
      'showBestSellerBadge': showBestSellerBadge,
      'showFlashBadge': showFlashBadge,
      'primaryBadgeText': _normalizeNullableString(primaryBadgeText),
      'secondaryBadgeText': _normalizeNullableString(secondaryBadgeText),
      'primaryBadgeStyle': _normalizeNullableString(primaryBadgeStyle),
      'secondaryBadgeStyle': _normalizeNullableString(secondaryBadgeStyle),
      'badgePlacement': badgePlacement,
      'badgeColorToken': _normalizeNullableString(badgeColorToken),
      'badgeTextColorToken': _normalizeNullableString(badgeTextColorToken),
      'discountBadgeTextMode': discountBadgeTextMode,
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
