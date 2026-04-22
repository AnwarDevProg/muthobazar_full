// MuthoBazar Product Card Design System
// File: mb_card_variant.dart
// Location: packages/shared_models/lib/product_cards/config/mb_card_variant.dart
//
// Purpose:
// Defines the concrete card variant ids used by the product card system.
//
// A card variant represents:
// - a specific visual composition inside a card family
// - a stable persisted identifier for config and Firestore storage
// - a registry key for renderer resolution in shared_ui
//
// Important:
// - Persist the stable string id, never the enum index.
// - Family controls layout behavior; variant controls exact design pattern.
// - This file intentionally includes starter v1 variants first and can be
//   extended in future phases.

import 'mb_card_family.dart';

enum MBCardVariant {
  compact01,
  price01,
  horizontal01,
  premium01,
  wide01,
  featured01,
  promo01,
  flash01,
}

extension MBCardVariantX on MBCardVariant {
  String get id {
    switch (this) {
      case MBCardVariant.compact01:
        return 'compact01';
      case MBCardVariant.price01:
        return 'price01';
      case MBCardVariant.horizontal01:
        return 'horizontal01';
      case MBCardVariant.premium01:
        return 'premium01';
      case MBCardVariant.wide01:
        return 'wide01';
      case MBCardVariant.featured01:
        return 'featured01';
      case MBCardVariant.promo01:
        return 'promo01';
      case MBCardVariant.flash01:
        return 'flash01';
    }
  }

  String get label {
    switch (this) {
      case MBCardVariant.compact01:
        return 'Compact 01';
      case MBCardVariant.price01:
        return 'Price 01';
      case MBCardVariant.horizontal01:
        return 'Horizontal 01';
      case MBCardVariant.premium01:
        return 'Premium 01';
      case MBCardVariant.wide01:
        return 'Wide 01';
      case MBCardVariant.featured01:
        return 'Featured 01';
      case MBCardVariant.promo01:
        return 'Promo 01';
      case MBCardVariant.flash01:
        return 'Flash 01';
    }
  }

  MBCardFamily get family {
    switch (this) {
      case MBCardVariant.compact01:
        return MBCardFamily.compact;
      case MBCardVariant.price01:
        return MBCardFamily.price;
      case MBCardVariant.horizontal01:
        return MBCardFamily.horizontal;
      case MBCardVariant.premium01:
        return MBCardFamily.premium;
      case MBCardVariant.wide01:
        return MBCardFamily.wide;
      case MBCardVariant.featured01:
        return MBCardFamily.featured;
      case MBCardVariant.promo01:
        return MBCardFamily.promo;
      case MBCardVariant.flash01:
        return MBCardFamily.flashSale;
    }
  }

  bool get isStarterVariant => true;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'familyId': family.id,
      'familyLabel': family.label,
      'isStarterVariant': isStarterVariant,
    };
  }
}

class MBCardVariantHelper {
  const MBCardVariantHelper._();

  static const List<MBCardVariant> values = MBCardVariant.values;

  static const List<MBCardVariant> starterVariants = <MBCardVariant>[
    MBCardVariant.compact01,
    MBCardVariant.price01,
    MBCardVariant.horizontal01,
    MBCardVariant.premium01,
    MBCardVariant.wide01,
    MBCardVariant.featured01,
    MBCardVariant.promo01,
    MBCardVariant.flash01,
  ];

  static MBCardVariant parse(
      String? raw, {
        MBCardVariant fallback = MBCardVariant.compact01,
      }) {
    if (raw == null) {
      return fallback;
    }

    final normalized = _normalize(raw);
    if (normalized.isEmpty) {
      return fallback;
    }

    for (final variant in MBCardVariant.values) {
      if (_normalize(variant.id) == normalized) {
        return variant;
      }
      if (_normalize(variant.label) == normalized) {
        return variant;
      }
      if (_normalize(variant.name) == normalized) {
        return variant;
      }
    }

    switch (normalized) {
      case 'flash_01':
      case 'flash-01':
        return MBCardVariant.flash01;
      default:
        return fallback;
    }
  }

  static bool isValidId(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return false;
    }

    final normalized = _normalize(raw);
    for (final variant in MBCardVariant.values) {
      if (_normalize(variant.id) == normalized) {
        return true;
      }
    }
    return false;
  }

  static List<String> ids() {
    return MBCardVariant.values
        .map((variant) => variant.id)
        .toList(growable: false);
  }

  static List<String> labels() {
    return MBCardVariant.values
        .map((variant) => variant.label)
        .toList(growable: false);
  }

  static List<MBCardVariant> byFamily(MBCardFamily family) {
    return MBCardVariant.values
        .where((variant) => variant.family == family)
        .toList(growable: false);
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }
}
