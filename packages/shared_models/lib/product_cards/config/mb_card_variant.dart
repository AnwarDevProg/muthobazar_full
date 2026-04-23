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
// Batch-integrated families in this file:
// - compact01 .. compact05
// - price01 .. price05
// - horizontal01 .. horizontal05
// - premium01 .. premium05
// - wide01 .. wide05
// - featured01 .. featured05
// - promo01 .. promo05
// - flash01 .. flash05

import 'mb_card_family.dart';

enum MBCardVariant {
  compact01,
  compact02,
  compact03,
  compact04,
  compact05,

  price01,
  price02,
  price03,
  price04,
  price05,

  horizontal01,
  horizontal02,
  horizontal03,
  horizontal04,
  horizontal05,

  premium01,
  premium02,
  premium03,
  premium04,
  premium05,

  wide01,
  wide02,
  wide03,
  wide04,
  wide05,

  featured01,
  featured02,
  featured03,
  featured04,
  featured05,

  promo01,
  promo02,
  promo03,
  promo04,
  promo05,

  flash01,
  flash02,
  flash03,
  flash04,
  flash05,
}

extension MBCardVariantX on MBCardVariant {
  String get id {
    switch (this) {
      case MBCardVariant.compact01:
        return 'compact01';
      case MBCardVariant.compact02:
        return 'compact02';
      case MBCardVariant.compact03:
        return 'compact03';
      case MBCardVariant.compact04:
        return 'compact04';
      case MBCardVariant.compact05:
        return 'compact05';

      case MBCardVariant.price01:
        return 'price01';
      case MBCardVariant.price02:
        return 'price02';
      case MBCardVariant.price03:
        return 'price03';
      case MBCardVariant.price04:
        return 'price04';
      case MBCardVariant.price05:
        return 'price05';

      case MBCardVariant.horizontal01:
        return 'horizontal01';
      case MBCardVariant.horizontal02:
        return 'horizontal02';
      case MBCardVariant.horizontal03:
        return 'horizontal03';
      case MBCardVariant.horizontal04:
        return 'horizontal04';
      case MBCardVariant.horizontal05:
        return 'horizontal05';

      case MBCardVariant.premium01:
        return 'premium01';
      case MBCardVariant.premium02:
        return 'premium02';
      case MBCardVariant.premium03:
        return 'premium03';
      case MBCardVariant.premium04:
        return 'premium04';
      case MBCardVariant.premium05:
        return 'premium05';

      case MBCardVariant.wide01:
        return 'wide01';
      case MBCardVariant.wide02:
        return 'wide02';
      case MBCardVariant.wide03:
        return 'wide03';
      case MBCardVariant.wide04:
        return 'wide04';
      case MBCardVariant.wide05:
        return 'wide05';

      case MBCardVariant.featured01:
        return 'featured01';
      case MBCardVariant.featured02:
        return 'featured02';
      case MBCardVariant.featured03:
        return 'featured03';
      case MBCardVariant.featured04:
        return 'featured04';
      case MBCardVariant.featured05:
        return 'featured05';

      case MBCardVariant.promo01:
        return 'promo01';
      case MBCardVariant.promo02:
        return 'promo02';
      case MBCardVariant.promo03:
        return 'promo03';
      case MBCardVariant.promo04:
        return 'promo04';
      case MBCardVariant.promo05:
        return 'promo05';

      case MBCardVariant.flash01:
        return 'flash01';
      case MBCardVariant.flash02:
        return 'flash02';
      case MBCardVariant.flash03:
        return 'flash03';
      case MBCardVariant.flash04:
        return 'flash04';
      case MBCardVariant.flash05:
        return 'flash05';
    }
  }

  String get label => id;

  MBCardFamily get family {
    switch (this) {
      case MBCardVariant.compact01:
      case MBCardVariant.compact02:
      case MBCardVariant.compact03:
      case MBCardVariant.compact04:
      case MBCardVariant.compact05:
        return MBCardFamily.compact;

      case MBCardVariant.price01:
      case MBCardVariant.price02:
      case MBCardVariant.price03:
      case MBCardVariant.price04:
      case MBCardVariant.price05:
        return MBCardFamily.price;

      case MBCardVariant.horizontal01:
      case MBCardVariant.horizontal02:
      case MBCardVariant.horizontal03:
      case MBCardVariant.horizontal04:
      case MBCardVariant.horizontal05:
        return MBCardFamily.horizontal;

      case MBCardVariant.premium01:
      case MBCardVariant.premium02:
      case MBCardVariant.premium03:
      case MBCardVariant.premium04:
      case MBCardVariant.premium05:
        return MBCardFamily.premium;

      case MBCardVariant.wide01:
      case MBCardVariant.wide02:
      case MBCardVariant.wide03:
      case MBCardVariant.wide04:
      case MBCardVariant.wide05:
        return MBCardFamily.wide;

      case MBCardVariant.featured01:
      case MBCardVariant.featured02:
      case MBCardVariant.featured03:
      case MBCardVariant.featured04:
      case MBCardVariant.featured05:
        return MBCardFamily.featured;

      case MBCardVariant.promo01:
      case MBCardVariant.promo02:
      case MBCardVariant.promo03:
      case MBCardVariant.promo04:
      case MBCardVariant.promo05:
        return MBCardFamily.promo;

      case MBCardVariant.flash01:
      case MBCardVariant.flash02:
      case MBCardVariant.flash03:
      case MBCardVariant.flash04:
      case MBCardVariant.flash05:
        return MBCardFamily.flashSale;
    }
  }

  String get familyId => family.id;

  bool get isFullWidth {
    switch (this) {
      case MBCardVariant.horizontal01:
      case MBCardVariant.horizontal02:
      case MBCardVariant.horizontal03:
      case MBCardVariant.horizontal04:
      case MBCardVariant.horizontal05:
      case MBCardVariant.wide01:
      case MBCardVariant.wide02:
      case MBCardVariant.wide03:
      case MBCardVariant.wide04:
      case MBCardVariant.wide05:
      case MBCardVariant.featured01:
      case MBCardVariant.featured02:
      case MBCardVariant.featured03:
      case MBCardVariant.featured04:
      case MBCardVariant.featured05:
      case MBCardVariant.promo01:
      case MBCardVariant.promo02:
      case MBCardVariant.promo03:
      case MBCardVariant.promo04:
      case MBCardVariant.promo05:
        return true;

      case MBCardVariant.compact01:
      case MBCardVariant.compact02:
      case MBCardVariant.compact03:
      case MBCardVariant.compact04:
      case MBCardVariant.compact05:
      case MBCardVariant.price01:
      case MBCardVariant.price02:
      case MBCardVariant.price03:
      case MBCardVariant.price04:
      case MBCardVariant.price05:
      case MBCardVariant.premium01:
      case MBCardVariant.premium02:
      case MBCardVariant.premium03:
      case MBCardVariant.premium04:
      case MBCardVariant.premium05:
      case MBCardVariant.flash01:
      case MBCardVariant.flash02:
      case MBCardVariant.flash03:
      case MBCardVariant.flash04:
      case MBCardVariant.flash05:
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
      case 'compact03':
        return MBCardVariant.compact03;
      case 'compact04':
        return MBCardVariant.compact04;
      case 'compact05':
        return MBCardVariant.compact05;

      case 'price01':
        return MBCardVariant.price01;
      case 'price02':
        return MBCardVariant.price02;
      case 'price03':
        return MBCardVariant.price03;
      case 'price04':
        return MBCardVariant.price04;
      case 'price05':
        return MBCardVariant.price05;

      case 'horizontal01':
        return MBCardVariant.horizontal01;
      case 'horizontal02':
        return MBCardVariant.horizontal02;
      case 'horizontal03':
        return MBCardVariant.horizontal03;
      case 'horizontal04':
        return MBCardVariant.horizontal04;
      case 'horizontal05':
        return MBCardVariant.horizontal05;

      case 'premium01':
        return MBCardVariant.premium01;
      case 'premium02':
        return MBCardVariant.premium02;
      case 'premium03':
        return MBCardVariant.premium03;
      case 'premium04':
        return MBCardVariant.premium04;
      case 'premium05':
        return MBCardVariant.premium05;

      case 'wide01':
        return MBCardVariant.wide01;
      case 'wide02':
        return MBCardVariant.wide02;
      case 'wide03':
        return MBCardVariant.wide03;
      case 'wide04':
        return MBCardVariant.wide04;
      case 'wide05':
        return MBCardVariant.wide05;

      case 'featured01':
        return MBCardVariant.featured01;
      case 'featured02':
        return MBCardVariant.featured02;
      case 'featured03':
        return MBCardVariant.featured03;
      case 'featured04':
        return MBCardVariant.featured04;
      case 'featured05':
        return MBCardVariant.featured05;

      case 'promo01':
        return MBCardVariant.promo01;
      case 'promo02':
        return MBCardVariant.promo02;
      case 'promo03':
        return MBCardVariant.promo03;
      case 'promo04':
        return MBCardVariant.promo04;
      case 'promo05':
        return MBCardVariant.promo05;

      case 'flash01':
        return MBCardVariant.flash01;
      case 'flash02':
        return MBCardVariant.flash02;
      case 'flash03':
        return MBCardVariant.flash03;
      case 'flash04':
        return MBCardVariant.flash04;
      case 'flash05':
        return MBCardVariant.flash05;

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