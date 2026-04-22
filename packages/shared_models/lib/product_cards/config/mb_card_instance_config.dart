// MuthoBazar Product Card Design System
// File: mb_card_instance_config.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_instance_config.dart
//
// Purpose:
// Defines the main per-card instance configuration object used by the product
// card system.
//
// A card instance config represents:
// - which card family is selected
// - which exact variant is selected
// - which optional preset is applied
// - which instance-level settings override is applied
//
// Important:
// - This model is intended to be serializable and safe for persistence.
// - Persist family/variant/preset using stable ids, never enum indexes.
// - The UI layer should later resolve this config into a fully merged render
//   configuration using defaults + family + variant + preset + overrides.

import 'mb_card_family.dart';
import 'mb_card_variant.dart';
import 'mb_card_settings_override.dart';

class MBCardInstanceConfig {
  const MBCardInstanceConfig({
    required this.family,
    required this.variant,
    this.presetId,
    this.settings = const MBCardSettingsOverride(),
  });

  factory MBCardInstanceConfig.fromMap(Map<String, dynamic> map) {
    return MBCardInstanceConfig(
      family: MBCardFamilyHelper.parse(
        _readNullableString(map['familyId']) ?? _readNullableString(map['family']),
        fallback: MBCardFamily.compact,
      ),
      variant: MBCardVariantHelper.parse(
        _readNullableString(map['variantId']) ?? _readNullableString(map['variant']),
        fallback: MBCardVariant.compact01,
      ),
      presetId: _readNullableString(map['presetId']),
      settings: _readSettings(map['settings']),
    );
  }

  final MBCardFamily family;
  final MBCardVariant variant;
  final String? presetId;
  final MBCardSettingsOverride settings;

  String get familyId => family.id;

  String get variantId => variant.id;

  String get familyLabel => family.label;

  String get variantLabel => variant.label;

  bool get hasPreset => presetId != null && presetId!.trim().isNotEmpty;

  bool get hasOverrides => !settings.isEmpty;

  bool get isFamilyVariantAligned => variant.family == family;

  MBCardInstanceConfig copyWith({
    MBCardFamily? family,
    MBCardVariant? variant,
    Object? presetId = _sentinel,
    MBCardSettingsOverride? settings,
  }) {
    return MBCardInstanceConfig(
      family: family ?? this.family,
      variant: variant ?? this.variant,
      presetId: identical(presetId, _sentinel)
          ? this.presetId
          : _normalizeNullableString(presetId as String?),
      settings: settings ?? this.settings,
    );
  }

  MBCardInstanceConfig normalized() {
    final normalizedVariant = variant;
    final normalizedFamily = normalizedVariant.family;

    return MBCardInstanceConfig(
      family: normalizedFamily,
      variant: normalizedVariant,
      presetId: _normalizeNullableString(presetId),
      settings: settings,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'familyId': family.id,
      'variantId': variant.id,
      'presetId': _normalizeNullableString(presetId),
      'settings': settings.toMap(),
    };
  }

  @override
  String toString() {
    return 'MBCardInstanceConfig('
        'familyId: ${family.id}, '
        'variantId: ${variant.id}, '
        'presetId: $presetId, '
        'hasOverrides: $hasOverrides'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardInstanceConfig &&
        other.family == family &&
        other.variant == variant &&
        other.presetId == presetId &&
        other.settings == settings;
  }

  @override
  int get hashCode {
    return Object.hash(
      family,
      variant,
      presetId,
      settings,
    );
  }

  static const Object _sentinel = Object();

  static MBCardSettingsOverride _readSettings(Object? value) {
    if (value is Map<String, dynamic>) {
      return MBCardSettingsOverride.fromMap(value);
    }
    if (value is Map) {
      return MBCardSettingsOverride.fromMap(
        value.map(
              (key, val) => MapEntry(key.toString(), val),
        ),
      );
    }
    return const MBCardSettingsOverride();
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
}
