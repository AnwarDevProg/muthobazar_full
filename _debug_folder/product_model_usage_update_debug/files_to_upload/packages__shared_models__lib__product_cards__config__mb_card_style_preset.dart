// MuthoBazar Product Card Design System
// File: mb_card_style_preset.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_style_preset.dart
//
// Purpose:
// Defines a reusable curated style preset for product cards.
//
// Notes:
// - presetId is persisted inside MBCardInstanceConfig.
// - This model can be expanded later when preset registry work starts.
// - For now this file fixes the product_card_config.dart export and gives us
//   a safe model foundation for upcoming preset work.

import 'mb_card_family.dart';
import 'mb_card_render_defaults.dart';
import 'mb_card_variant.dart';

class MBCardStylePreset {
  const MBCardStylePreset({
    required this.id,
    required this.label,
    this.description,
    this.family,
    this.variant,
    this.defaults = const MBCardRenderDefaults(),
    this.isSystem = true,
    this.isEnabled = true,
    this.sortOrder = 0,
  });

  factory MBCardStylePreset.fromMap(Map map) {
    final rawFamily = _readNullableString(map['familyId'] ?? map['family']);
    final rawVariant = _readNullableString(map['variantId'] ?? map['variant']);

    return MBCardStylePreset(
      id: _readString(map['id'], 'default'),
      label: _readString(map['label'], 'Default'),
      description: _readNullableString(map['description']),
      family: rawFamily == null ? null : MBCardFamilyHelper.parse(rawFamily),
      variant: rawVariant == null ? null : MBCardVariantHelper.parse(rawVariant),
      defaults: map['defaults'] is Map
          ? MBCardRenderDefaults.fromMap(map['defaults'] as Map)
          : const MBCardRenderDefaults(),
      isSystem: _readBool(map['isSystem'] ?? map['is_system'], true),
      isEnabled: _readBool(map['isEnabled'] ?? map['is_enabled'], true),
      sortOrder: _readInt(map['sortOrder'] ?? map['sort_order'], 0),
    );
  }

  final String id;
  final String label;
  final String? description;
  final MBCardFamily? family;
  final MBCardVariant? variant;
  final MBCardRenderDefaults defaults;
  final bool isSystem;
  final bool isEnabled;
  final int sortOrder;

  String? get familyId => family?.id;
  String? get variantId => variant?.id;
  bool get hasFamily => family != null;
  bool get hasVariant => variant != null;
  bool get hasDefaults => defaults.isNotEmpty;

  MBCardStylePreset copyWith({
    String? id,
    String? label,
    Object? description = _sentinel,
    Object? family = _sentinel,
    Object? variant = _sentinel,
    MBCardRenderDefaults? defaults,
    bool? isSystem,
    bool? isEnabled,
    int? sortOrder,
  }) {
    return MBCardStylePreset(
      id: id ?? this.id,
      label: label ?? this.label,
      description: identical(description, _sentinel)
          ? this.description
          : _normalizeNullableString(description as String?),
      family: identical(family, _sentinel) ? this.family : family as MBCardFamily?,
      variant: identical(variant, _sentinel)
          ? this.variant
          : variant as MBCardVariant?,
      defaults: defaults ?? this.defaults,
      isSystem: isSystem ?? this.isSystem,
      isEnabled: isEnabled ?? this.isEnabled,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'label': label,
      'description': _normalizeNullableString(description),
      'familyId': familyId,
      'variantId': variantId,
      'defaults': defaults.toMap(),
      'isSystem': isSystem,
      'isEnabled': isEnabled,
      'sortOrder': sortOrder,
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

String? _normalizeNullableString(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
