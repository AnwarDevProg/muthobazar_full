// MuthoBazar Product Card Design System
// File: mb_product_card_variant_router.dart
// Location: packages/shared_ui/lib/widgets/common/product_cards/system/mb_product_card_variant_router.dart
//
// Purpose:
// Central widget router for all currently available product-card variants.
//
// This file maps a resolved card config variant to the actual widget class that
// renders that design. The registry decides what a variant means. This router
// decides which widget file is instantiated for that variant.
//
// Notes:
// - Keep this file focused on routing only.
// - All variant-specific UI logic belongs in the variant widget files.
// - When a new variant is added to the system, this router must be updated.

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';


import '../variants/mb_product_card_compact01.dart';
import '../variants/mb_product_card_compact02.dart';
import '../variants/mb_product_card_compact03.dart';
import '../variants/mb_product_card_compact04.dart';
import '../variants/mb_product_card_compact05.dart';
import '../variants/mb_product_card_featured01.dart';
import '../variants/mb_product_card_featured02.dart';
import '../variants/mb_product_card_featured03.dart';
import '../variants/mb_product_card_featured04.dart';
import '../variants/mb_product_card_featured05.dart';
import '../variants/mb_product_card_flash01.dart';
import '../variants/mb_product_card_flash02.dart';
import '../variants/mb_product_card_flash03.dart';
import '../variants/mb_product_card_flash04.dart';
import '../variants/mb_product_card_flash05.dart';
import '../variants/mb_product_card_horizontal01.dart';
import '../variants/mb_product_card_horizontal02.dart';
import '../variants/mb_product_card_horizontal03.dart';
import '../variants/mb_product_card_horizontal04.dart';
import '../variants/mb_product_card_horizontal05.dart';
import '../variants/mb_product_card_premium01.dart';
import '../variants/mb_product_card_premium02.dart';
import '../variants/mb_product_card_premium03.dart';
import '../variants/mb_product_card_premium04.dart';
import '../variants/mb_product_card_premium05.dart';
import '../variants/mb_product_card_price01.dart';
import '../variants/mb_product_card_price02.dart';
import '../variants/mb_product_card_price03.dart';
import '../variants/mb_product_card_price04.dart';
import '../variants/mb_product_card_price05.dart';
import '../variants/mb_product_card_promo01.dart';
import '../variants/mb_product_card_promo02.dart';
import '../variants/mb_product_card_promo03.dart';
import '../variants/mb_product_card_promo04.dart';
import '../variants/mb_product_card_promo05.dart';
import '../variants/mb_product_card_wide01.dart';
import '../variants/mb_product_card_wide02.dart';
import '../variants/mb_product_card_wide03.dart';
import '../variants/mb_product_card_wide04.dart';
import '../variants/mb_product_card_wide05.dart';
import 'mb_card_config_resolver.dart';

class MBProductCardVariantRouter {
  const MBProductCardVariantRouter._();

  static Widget build({
    required BuildContext context,
    required MBResolvedCardConfig resolved,
    required MBProduct product,
    VoidCallback? onTap,
    VoidCallback? onAddToCartTap,
    Widget? trailingOverlay,
  }) {
    switch (resolved.variant) {
    // Compact family
      case MBCardVariant.compact01:
        return MBProductCardCompact01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.compact02:
        return MBProductCardCompact02(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.compact03:
        return MBProductCardCompact03(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.compact04:
        return MBProductCardCompact04(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.compact05:
        return MBProductCardCompact05(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

    // Price family
      case MBCardVariant.price01:
        return MBProductCardPrice01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.price02:
        return MBProductCardPrice02(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.price03:
        return MBProductCardPrice03(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.price04:
        return MBProductCardPrice04(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.price05:
        return MBProductCardPrice05(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

    // Horizontal family
      case MBCardVariant.horizontal01:
        return MBProductCardHorizontal01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.horizontal02:
        return MBProductCardHorizontal02(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.horizontal03:
        return MBProductCardHorizontal03(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.horizontal04:
        return MBProductCardHorizontal04(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.horizontal05:
        return MBProductCardHorizontal05(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

    // Premium family
      case MBCardVariant.premium01:
        return MBProductCardPremium01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.premium02:
        return MBProductCardPremium02(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.premium03:
        return MBProductCardPremium03(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.premium04:
        return MBProductCardPremium04(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.premium05:
        return MBProductCardPremium05(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

    // Wide family
      case MBCardVariant.wide01:
        return MBProductCardWide01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.wide02:
        return MBProductCardWide02(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.wide03:
        return MBProductCardWide03(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.wide04:
        return MBProductCardWide04(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.wide05:
        return MBProductCardWide05(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

    // Featured family
      case MBCardVariant.featured01:
        return MBProductCardFeatured01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.featured02:
        return MBProductCardFeatured02(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.featured03:
        return MBProductCardFeatured03(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.featured04:
        return MBProductCardFeatured04(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.featured05:
        return MBProductCardFeatured05(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

    // Promo family
      case MBCardVariant.promo01:
        return MBProductCardPromo01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.promo02:
        return MBProductCardPromo02(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.promo03:
        return MBProductCardPromo03(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.promo04:
        return MBProductCardPromo04(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.promo05:
        return MBProductCardPromo05(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

    // FlashSale family
      case MBCardVariant.flash01:
        return MBProductCardFlash01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.flash02:
        return MBProductCardFlash02(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.flash03:
        return MBProductCardFlash03(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.flash04:
        return MBProductCardFlash04(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
      case MBCardVariant.flash05:
        return MBProductCardFlash05(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
    }
  }
}