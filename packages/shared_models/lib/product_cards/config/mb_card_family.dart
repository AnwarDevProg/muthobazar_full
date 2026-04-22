// MuthoBazar Product Card Design System
// File: mb_card_family.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_family.dart
//
// Purpose:
// Defines the structural card family groups used by the product card system.
//
// A card family represents:
// - layout behavior
// - footprint intent
// - content priority
// - general rendering purpose
//
// Important:
// - These values are intended to be stable for persistence and cross-layer usage.
// - Firestore or JSON should store the stable string id, not the enum index.
// - UI layers should use this enum to resolve structural behavior and variant grouping.

enum MBCardFamily {
  compact,
  price,
  horizontal,
  premium,
  wide,
  featured,
  promo,
  flashSale,
  combo,
  variant,
  minimal,
  infoRich,
}

extension MBCardFamilyX on MBCardFamily {
  String get id {
    switch (this) {
      case MBCardFamily.compact:
        return 'compact';
      case MBCardFamily.price:
        return 'price';
      case MBCardFamily.horizontal:
        return 'horizontal';
      case MBCardFamily.premium:
        return 'premium';
      case MBCardFamily.wide:
        return 'wide';
      case MBCardFamily.featured:
        return 'featured';
      case MBCardFamily.promo:
        return 'promo';
      case MBCardFamily.flashSale:
        return 'flash_sale';
      case MBCardFamily.combo:
        return 'combo';
      case MBCardFamily.variant:
        return 'variant';
      case MBCardFamily.minimal:
        return 'minimal';
      case MBCardFamily.infoRich:
        return 'info_rich';
    }
  }

  String get label {
    switch (this) {
      case MBCardFamily.compact:
        return 'Compact';
      case MBCardFamily.price:
        return 'Price';
      case MBCardFamily.horizontal:
        return 'Horizontal';
      case MBCardFamily.premium:
        return 'Premium';
      case MBCardFamily.wide:
        return 'Wide';
      case MBCardFamily.featured:
        return 'Featured';
      case MBCardFamily.promo:
        return 'Promo';
      case MBCardFamily.flashSale:
        return 'Flash Sale';
      case MBCardFamily.combo:
        return 'Combo';
      case MBCardFamily.variant:
        return 'Variant';
      case MBCardFamily.minimal:
        return 'Minimal';
      case MBCardFamily.infoRich:
        return 'Info Rich';
    }
  }

  bool get isCoreStarterFamily {
    switch (this) {
      case MBCardFamily.compact:
      case MBCardFamily.price:
      case MBCardFamily.horizontal:
      case MBCardFamily.premium:
      case MBCardFamily.wide:
      case MBCardFamily.featured:
      case MBCardFamily.promo:
      case MBCardFamily.flashSale:
        return true;
      case MBCardFamily.combo:
      case MBCardFamily.variant:
      case MBCardFamily.minimal:
      case MBCardFamily.infoRich:
        return false;
    }
  }

  bool get isExtendedFamily => !isCoreStarterFamily;

  bool get prefersFullWidthByDefault {
    switch (this) {
      case MBCardFamily.horizontal:
      case MBCardFamily.wide:
      case MBCardFamily.featured:
      case MBCardFamily.promo:
      case MBCardFamily.combo:
        return true;
      case MBCardFamily.compact:
      case MBCardFamily.price:
      case MBCardFamily.premium:
      case MBCardFamily.flashSale:
      case MBCardFamily.variant:
      case MBCardFamily.minimal:
      case MBCardFamily.infoRich:
        return false;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'isCoreStarterFamily': isCoreStarterFamily,
      'prefersFullWidthByDefault': prefersFullWidthByDefault,
    };
  }
}

class MBCardFamilyHelper {
  const MBCardFamilyHelper._();

  static const List<MBCardFamily> values = MBCardFamily.values;

  static const List<MBCardFamily> starterFamilies = <MBCardFamily>[
    MBCardFamily.compact,
    MBCardFamily.price,
    MBCardFamily.horizontal,
    MBCardFamily.premium,
    MBCardFamily.wide,
    MBCardFamily.featured,
    MBCardFamily.promo,
    MBCardFamily.flashSale,
  ];

  static const List<MBCardFamily> extendedFamilies = <MBCardFamily>[
    MBCardFamily.combo,
    MBCardFamily.variant,
    MBCardFamily.minimal,
    MBCardFamily.infoRich,
  ];

  static MBCardFamily parse(
      String? raw, {
        MBCardFamily fallback = MBCardFamily.compact,
      }) {
    if (raw == null) {
      return fallback;
    }

    final normalized = _normalize(raw);
    if (normalized.isEmpty) {
      return fallback;
    }

    for (final family in MBCardFamily.values) {
      if (_normalize(family.id) == normalized) {
        return family;
      }
      if (_normalize(family.label) == normalized) {
        return family;
      }
      if (_normalize(family.name) == normalized) {
        return family;
      }
    }

    switch (normalized) {
      case 'flashsale':
      case 'flash_sale':
      case 'flash-sale':
        return MBCardFamily.flashSale;
      case 'inforich':
      case 'info_rich':
      case 'info-rich':
        return MBCardFamily.infoRich;
      default:
        return fallback;
    }
  }

  static bool isValidId(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return false;
    }

    final normalized = _normalize(raw);
    for (final family in MBCardFamily.values) {
      if (_normalize(family.id) == normalized) {
        return true;
      }
    }
    return false;
  }

  static List<String> ids() {
    return MBCardFamily.values.map((family) => family.id).toList(growable: false);
  }

  static List<String> labels() {
    return MBCardFamily.values
        .map((family) => family.label)
        .toList(growable: false);
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }
}
