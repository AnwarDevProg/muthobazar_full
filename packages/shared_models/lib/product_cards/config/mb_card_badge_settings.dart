// MuthoBazar Product Card Design System
// File: mb_card_badge_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_badge_settings.dart
//
// Purpose:
// Defines the badge and chip presentation settings used by the product card
// system.
//
// Badge settings represent:
// - whether a primary badge should be shown
// - whether a secondary badge should be shown
// - optional badge style preset selection
// - badge placement intent
//
// Important:
// - This model is serializable and safe for persistence.
// - Style and placement fields are stored as stable string ids, not concrete UI
//   widgets or colors. UI resolution must happen later in shared_ui.
// - This model controls badge presentation intent only. The actual badge text,
//   badge eligibility, and discount logic still depend on product data and the
//   renderer layer.

class MBCardBadgeSettings {
  const MBCardBadgeSettings({
    this.showPrimaryBadge = true,
    this.showSecondaryBadge = false,
    this.primaryBadgeStyle,
    this.secondaryBadgeStyle,
    this.badgePlacement = 'top_left',
  });

  factory MBCardBadgeSettings.fromMap(Map<String, dynamic> map) {
    return MBCardBadgeSettings(
      showPrimaryBadge: _readBool(
        map['showPrimaryBadge'] ?? map['show_primary_badge'],
        true,
      ),
      showSecondaryBadge: _readBool(
        map['showSecondaryBadge'] ?? map['show_secondary_badge'],
        false,
      ),
      primaryBadgeStyle: _readNullableString(
        map['primaryBadgeStyle'] ?? map['primary_badge_style'],
      ),
      secondaryBadgeStyle: _readNullableString(
        map['secondaryBadgeStyle'] ?? map['secondary_badge_style'],
      ),
      badgePlacement: _readString(
        map['badgePlacement'] ?? map['badge_placement'],
        'top_left',
      ),
    );
  }

  final bool showPrimaryBadge;
  final bool showSecondaryBadge;
  final String? primaryBadgeStyle;
  final String? secondaryBadgeStyle;
  final String badgePlacement;

  bool get hasPrimaryBadgeStyle =>
      primaryBadgeStyle != null && primaryBadgeStyle!.trim().isNotEmpty;

  bool get hasSecondaryBadgeStyle =>
      secondaryBadgeStyle != null && secondaryBadgeStyle!.trim().isNotEmpty;

  bool get showsAnyBadge => showPrimaryBadge || showSecondaryBadge;

  bool get isTopLeftPlacement => badgePlacement.trim().toLowerCase() == 'top_left';

  bool get isTopRightPlacement =>
      badgePlacement.trim().toLowerCase() == 'top_right';

  bool get isBottomLeftPlacement =>
      badgePlacement.trim().toLowerCase() == 'bottom_left';

  bool get isBottomRightPlacement =>
      badgePlacement.trim().toLowerCase() == 'bottom_right';

  bool get isInlinePlacement => badgePlacement.trim().toLowerCase() == 'inline';

  MBCardBadgeSettings copyWith({
    bool? showPrimaryBadge,
    bool? showSecondaryBadge,
    Object? primaryBadgeStyle = _sentinel,
    Object? secondaryBadgeStyle = _sentinel,
    String? badgePlacement,
  }) {
    return MBCardBadgeSettings(
      showPrimaryBadge: showPrimaryBadge ?? this.showPrimaryBadge,
      showSecondaryBadge: showSecondaryBadge ?? this.showSecondaryBadge,
      primaryBadgeStyle: identical(primaryBadgeStyle, _sentinel)
          ? this.primaryBadgeStyle
          : _normalizeNullableString(primaryBadgeStyle as String?),
      secondaryBadgeStyle: identical(secondaryBadgeStyle, _sentinel)
          ? this.secondaryBadgeStyle
          : _normalizeNullableString(secondaryBadgeStyle as String?),
      badgePlacement: badgePlacement ?? this.badgePlacement,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showPrimaryBadge': showPrimaryBadge,
      'showSecondaryBadge': showSecondaryBadge,
      'primaryBadgeStyle': _normalizeNullableString(primaryBadgeStyle),
      'secondaryBadgeStyle': _normalizeNullableString(secondaryBadgeStyle),
      'badgePlacement': badgePlacement,
    };
  }

  @override
  String toString() {
    return 'MBCardBadgeSettings('
        'showPrimaryBadge: $showPrimaryBadge, '
        'showSecondaryBadge: $showSecondaryBadge, '
        'primaryBadgeStyle: $primaryBadgeStyle, '
        'secondaryBadgeStyle: $secondaryBadgeStyle, '
        'badgePlacement: $badgePlacement'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardBadgeSettings &&
        other.showPrimaryBadge == showPrimaryBadge &&
        other.showSecondaryBadge == showSecondaryBadge &&
        other.primaryBadgeStyle == primaryBadgeStyle &&
        other.secondaryBadgeStyle == secondaryBadgeStyle &&
        other.badgePlacement == badgePlacement;
  }

  @override
  int get hashCode {
    return Object.hash(
      showPrimaryBadge,
      showSecondaryBadge,
      primaryBadgeStyle,
      secondaryBadgeStyle,
      badgePlacement,
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
