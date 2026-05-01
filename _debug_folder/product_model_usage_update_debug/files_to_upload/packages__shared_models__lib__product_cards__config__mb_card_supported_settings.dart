// MuthoBazar Product Card Design System
// File: mb_card_supported_settings.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_supported_settings.dart
//
// Purpose:
// Defines the supported-settings capability model used by the product card
// system.
//
// Supported settings represent:
// - which settings groups a card variant is allowed to expose or honor
// - a guard layer that prevents uncontrolled styling and feature sprawl
// - a serializable structure that can be used by admin/config UIs to show or
//   hide supported controls
//
// Important:
// - This model is serializable and safe for persistence or registry use.
// - This model does not store actual style values; it only declares whether a
//   settings group is supported.
// - Renderer and admin UI layers should use this model to decide what is
//   configurable for a given variant.

class MBCardSupportedSettings {
  const MBCardSupportedSettings({
    this.canChangeSurface = true,
    this.canChangeTypography = true,
    this.canChangeAccent = false,
    this.canChangeBorderEffect = false,
    this.canChangePrice = true,
    this.canChangeActions = false,
    this.canChangeMedia = false,
    this.canChangeBadges = true,
    this.canChangeMeta = true,
  });

  factory MBCardSupportedSettings.fromMap(Map<String, dynamic> map) {
    return MBCardSupportedSettings(
      canChangeSurface: _readBool(
        map['canChangeSurface'] ?? map['can_change_surface'],
        true,
      ),
      canChangeTypography: _readBool(
        map['canChangeTypography'] ?? map['can_change_typography'],
        true,
      ),
      canChangeAccent: _readBool(
        map['canChangeAccent'] ?? map['can_change_accent'],
        false,
      ),
      canChangeBorderEffect: _readBool(
        map['canChangeBorderEffect'] ?? map['can_change_border_effect'],
        false,
      ),
      canChangePrice: _readBool(
        map['canChangePrice'] ?? map['can_change_price'],
        true,
      ),
      canChangeActions: _readBool(
        map['canChangeActions'] ?? map['can_change_actions'],
        false,
      ),
      canChangeMedia: _readBool(
        map['canChangeMedia'] ?? map['can_change_media'],
        false,
      ),
      canChangeBadges: _readBool(
        map['canChangeBadges'] ?? map['can_change_badges'],
        true,
      ),
      canChangeMeta: _readBool(
        map['canChangeMeta'] ?? map['can_change_meta'],
        true,
      ),
    );
  }

  final bool canChangeSurface;
  final bool canChangeTypography;
  final bool canChangeAccent;
  final bool canChangeBorderEffect;
  final bool canChangePrice;
  final bool canChangeActions;
  final bool canChangeMedia;
  final bool canChangeBadges;
  final bool canChangeMeta;

  bool get supportsAnyCustomization {
    return canChangeSurface ||
        canChangeTypography ||
        canChangeAccent ||
        canChangeBorderEffect ||
        canChangePrice ||
        canChangeActions ||
        canChangeMedia ||
        canChangeBadges ||
        canChangeMeta;
  }

  bool get isLockedDown => !supportsAnyCustomization;

  int get enabledGroupCount {
    var count = 0;
    if (canChangeSurface) count++;
    if (canChangeTypography) count++;
    if (canChangeAccent) count++;
    if (canChangeBorderEffect) count++;
    if (canChangePrice) count++;
    if (canChangeActions) count++;
    if (canChangeMedia) count++;
    if (canChangeBadges) count++;
    if (canChangeMeta) count++;
    return count;
  }

  MBCardSupportedSettings copyWith({
    bool? canChangeSurface,
    bool? canChangeTypography,
    bool? canChangeAccent,
    bool? canChangeBorderEffect,
    bool? canChangePrice,
    bool? canChangeActions,
    bool? canChangeMedia,
    bool? canChangeBadges,
    bool? canChangeMeta,
  }) {
    return MBCardSupportedSettings(
      canChangeSurface: canChangeSurface ?? this.canChangeSurface,
      canChangeTypography: canChangeTypography ?? this.canChangeTypography,
      canChangeAccent: canChangeAccent ?? this.canChangeAccent,
      canChangeBorderEffect:
      canChangeBorderEffect ?? this.canChangeBorderEffect,
      canChangePrice: canChangePrice ?? this.canChangePrice,
      canChangeActions: canChangeActions ?? this.canChangeActions,
      canChangeMedia: canChangeMedia ?? this.canChangeMedia,
      canChangeBadges: canChangeBadges ?? this.canChangeBadges,
      canChangeMeta: canChangeMeta ?? this.canChangeMeta,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'canChangeSurface': canChangeSurface,
      'canChangeTypography': canChangeTypography,
      'canChangeAccent': canChangeAccent,
      'canChangeBorderEffect': canChangeBorderEffect,
      'canChangePrice': canChangePrice,
      'canChangeActions': canChangeActions,
      'canChangeMedia': canChangeMedia,
      'canChangeBadges': canChangeBadges,
      'canChangeMeta': canChangeMeta,
    };
  }

  @override
  String toString() {
    return 'MBCardSupportedSettings('
        'canChangeSurface: $canChangeSurface, '
        'canChangeTypography: $canChangeTypography, '
        'canChangeAccent: $canChangeAccent, '
        'canChangeBorderEffect: $canChangeBorderEffect, '
        'canChangePrice: $canChangePrice, '
        'canChangeActions: $canChangeActions, '
        'canChangeMedia: $canChangeMedia, '
        'canChangeBadges: $canChangeBadges, '
        'canChangeMeta: $canChangeMeta'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardSupportedSettings &&
        other.canChangeSurface == canChangeSurface &&
        other.canChangeTypography == canChangeTypography &&
        other.canChangeAccent == canChangeAccent &&
        other.canChangeBorderEffect == canChangeBorderEffect &&
        other.canChangePrice == canChangePrice &&
        other.canChangeActions == canChangeActions &&
        other.canChangeMedia == canChangeMedia &&
        other.canChangeBadges == canChangeBadges &&
        other.canChangeMeta == canChangeMeta;
  }

  @override
  int get hashCode {
    return Object.hash(
      canChangeSurface,
      canChangeTypography,
      canChangeAccent,
      canChangeBorderEffect,
      canChangePrice,
      canChangeActions,
      canChangeMedia,
      canChangeBadges,
      canChangeMeta,
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
