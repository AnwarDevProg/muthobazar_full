// MuthoBazar Product Card Design System
// File: mb_card_variant_definition.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_variant_definition.dart
//
// Purpose:
// Defines the registry-ready card variant definition model used by the product
// card system.
//
// A card variant definition represents:
// - which stable variant is being described
// - which family it belongs to
// - which footprint it should use by default
// - which default settings override bundle should apply
// - which settings groups are supported for customization
//
// Important:
// - This model is serializable and safe for persistence or static registry use.
// - This model is intended to be used by the future registry/resolver layer.
// - The actual widget builder is intentionally not included here because this
//   file belongs to shared_models, not shared_ui.

import 'mb_card_family.dart';
import 'mb_card_footprint.dart';
import 'mb_card_settings_override.dart';
import 'mb_card_supported_settings.dart';
import 'mb_card_variant.dart';

class MBCardVariantDefinition {
  const MBCardVariantDefinition({
    required this.variant,
    required this.family,
    required this.footprint,
    this.defaults = const MBCardSettingsOverride(),
    this.supportedSettings = const MBCardSupportedSettings(),
  });

  factory MBCardVariantDefinition.fromMap(Map<String, dynamic> map) {
    final parsedVariant = MBCardVariantHelper.parse(
      _readNullableString(map['variantId']) ?? _readNullableString(map['variant']),
      fallback: MBCardVariant.compact01,
    );
    final parsedFamily = MBCardFamilyHelper.parse(
      _readNullableString(map['familyId']) ?? _readNullableString(map['family']),
      fallback: parsedVariant.family,
    );

    return MBCardVariantDefinition(
      variant: parsedVariant,
      family: parsedFamily,
      footprint: MBCardFootprintHelper.parse(
        _readNullableString(map['footprintId']) ??
            _readNullableString(map['footprint']),
        fallback: parsedFamily.prefersFullWidthByDefault
            ? MBCardFootprint.fullWidth
            : MBCardFootprint.halfWidth,
      ),
      defaults: _readDefaults(map['defaults']),
      supportedSettings: _readSupportedSettings(
        map['supportedSettings'] ?? map['supported_settings'],
      ),
    );
  }

  final MBCardVariant variant;
  final MBCardFamily family;
  final MBCardFootprint footprint;
  final MBCardSettingsOverride defaults;
  final MBCardSupportedSettings supportedSettings;

  String get variantId => variant.id;

  String get familyId => family.id;

  String get footprintId => footprint.id;

  String get variantLabel => variant.label;

  String get familyLabel => family.label;

  String get footprintLabel => footprint.label;

  bool get isFamilyAligned => variant.family == family;

  bool get hasDefaults => defaults.isNotEmpty;

  bool get supportsAnyCustomization => supportedSettings.supportsAnyCustomization;

  MBCardVariantDefinition copyWith({
    MBCardVariant? variant,
    MBCardFamily? family,
    MBCardFootprint? footprint,
    MBCardSettingsOverride? defaults,
    MBCardSupportedSettings? supportedSettings,
  }) {
    return MBCardVariantDefinition(
      variant: variant ?? this.variant,
      family: family ?? this.family,
      footprint: footprint ?? this.footprint,
      defaults: defaults ?? this.defaults,
      supportedSettings: supportedSettings ?? this.supportedSettings,
    );
  }

  MBCardVariantDefinition normalized() {
    final normalizedVariant = variant;
    final normalizedFamily = normalizedVariant.family;

    return MBCardVariantDefinition(
      variant: normalizedVariant,
      family: normalizedFamily,
      footprint: footprint,
      defaults: defaults,
      supportedSettings: supportedSettings,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'variantId': variant.id,
      'familyId': family.id,
      'footprintId': footprint.id,
      'defaults': defaults.toMap(),
      'supportedSettings': supportedSettings.toMap(),
    };
  }

  @override
  String toString() {
    return 'MBCardVariantDefinition('
        'variantId: ${variant.id}, '
        'familyId: ${family.id}, '
        'footprintId: ${footprint.id}, '
        'hasDefaults: $hasDefaults, '
        'supportsAnyCustomization: $supportsAnyCustomization'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBCardVariantDefinition &&
        other.variant == variant &&
        other.family == family &&
        other.footprint == footprint &&
        other.defaults == defaults &&
        other.supportedSettings == supportedSettings;
  }

  @override
  int get hashCode {
    return Object.hash(
      variant,
      family,
      footprint,
      defaults,
      supportedSettings,
    );
  }

  static MBCardSettingsOverride _readDefaults(Object? value) {
    if (value is Map<String, dynamic>) {
      return MBCardSettingsOverride.fromMap(value);
    }
    if (value is Map) {
      return MBCardSettingsOverride.fromMap(
        value.map((key, val) => MapEntry(key.toString(), val)),
      );
    }
    return const MBCardSettingsOverride();
  }

  static MBCardSupportedSettings _readSupportedSettings(Object? value) {
    if (value is Map<String, dynamic>) {
      return MBCardSupportedSettings.fromMap(value);
    }
    if (value is Map) {
      return MBCardSupportedSettings.fromMap(
        value.map((key, val) => MapEntry(key.toString(), val)),
      );
    }
    return const MBCardSupportedSettings();
  }

  static String? _readNullableString(Object? value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
