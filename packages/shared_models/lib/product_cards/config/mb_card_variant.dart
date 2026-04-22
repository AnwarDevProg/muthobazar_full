// File: mb_card_variant.dart
//
// Stable product-card variant ids used across shared_models, shared_ui,
// customer preview-lab flows, and later admin configuration.
//
// Design rule:
// - Family defines behavior and layout meaning.
// - Variant defines the fixed visual composition inside that family.
// - Persist stable string ids, not display labels.
//
// Current starter set includes the original 8 variants, and compact02 is the
// first extension inside the compact family.

import 'mb_card_family.dart';

enum MBCardVariant {
  compact01,
  compact02,
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
      case MBCardVariant.compact02:
        return 'compact02';
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
        return 'compact01';
      case MBCardVariant.compact02:
        return 'compact02';
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

  MBCardFamily get family {
    switch (this) {
      case MBCardVariant.compact01:
      case MBCardVariant.compact02:
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

  String get familyId {
    switch (this) {
      case MBCardVariant.compact01:
      case MBCardVariant.compact02:
        return 'compact';
      case MBCardVariant.price01:
        return 'price';
      case MBCardVariant.horizontal01:
        return 'horizontal';
      case MBCardVariant.premium01:
        return 'premium';
      case MBCardVariant.wide01:
        return 'wide';
      case MBCardVariant.featured01:
        return 'featured';
      case MBCardVariant.promo01:
        return 'promo';
      case MBCardVariant.flash01:
        return 'flash_sale';
    }
  }

  bool get isFullWidth {
    switch (this) {
      case MBCardVariant.horizontal01:
      case MBCardVariant.wide01:
      case MBCardVariant.featured01:
      case MBCardVariant.promo01:
        return true;
      case MBCardVariant.compact01:
      case MBCardVariant.compact02:
      case MBCardVariant.price01:
      case MBCardVariant.premium01:
      case MBCardVariant.flash01:
        return false;
    }
  }
}

class MBCardVariantHelper {
  const MBCardVariantHelper._();

  static const MBCardVariant defaultFallback = MBCardVariant.compact01;

  static List<MBCardVariant> get values =>
      List<MBCardVariant>.unmodifiable(MBCardVariant.values);

  static List<String> get allowedIds =>
      values.map((item) => item.id).toList(growable: false);

  static MBCardVariant parse(
      dynamic raw, {
        MBCardVariant fallback = defaultFallback,
      }) {
    final normalized = _normalize(raw);

    switch (normalized) {
      case 'compact01':
        return MBCardVariant.compact01;
      case 'compact02':
        return MBCardVariant.compact02;
      case 'price01':
        return MBCardVariant.price01;
      case 'horizontal01':
        return MBCardVariant.horizontal01;
      case 'premium01':
        return MBCardVariant.premium01;
      case 'wide01':
        return MBCardVariant.wide01;
      case 'featured01':
        return MBCardVariant.featured01;
      case 'promo01':
        return MBCardVariant.promo01;
      case 'flash01':
        return MBCardVariant.flash01;
      default:
        return fallback;
    }
  }

  static String normalize(
      dynamic raw, {
        MBCardVariant fallback = defaultFallback,
      }) {
    return parse(raw, fallback: fallback).id;
  }

  static bool isValid(dynamic raw) {
    final normalized = _normalize(raw);
    return allowedIds.contains(normalized);
  }

  static String _normalize(dynamic raw) {
    return raw?.toString().trim().toLowerCase() ?? '';
  }
}