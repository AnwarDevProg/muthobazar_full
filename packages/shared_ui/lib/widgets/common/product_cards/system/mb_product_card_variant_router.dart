import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../variants/mb_product_card_compact01.dart';
import '../variants/mb_product_card_compact02.dart';
import '../variants/mb_product_card_featured01.dart';
import '../variants/mb_product_card_flash01.dart';
import '../variants/mb_product_card_horizontal01.dart';
import '../variants/mb_product_card_premium01.dart';
import '../variants/mb_product_card_price01.dart';
import '../variants/mb_product_card_promo01.dart';
import '../variants/mb_product_card_wide01.dart';
import 'mb_card_config_resolver.dart';

typedef MBProductCardVariantBuilder = Widget Function({
required BuildContext context,
required MBResolvedCardConfig resolved,
required MBProduct product,
VoidCallback? onTap,
VoidCallback? onAddToCartTap,
Widget? trailingOverlay,
});

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

      case MBCardVariant.price01:
        return MBProductCardPrice01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

      case MBCardVariant.horizontal01:
        return MBProductCardHorizontal01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

      case MBCardVariant.premium01:
        return MBProductCardPremium01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

      case MBCardVariant.wide01:
        return MBProductCardWide01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

      case MBCardVariant.featured01:
        return MBProductCardFeatured01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

      case MBCardVariant.promo01:
        return MBProductCardPromo01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );

      case MBCardVariant.flash01:
        return MBProductCardFlash01(
          product: product,
          resolved: resolved,
          onTap: onTap,
          onAddToCartTap: onAddToCartTap,
          trailingOverlay: trailingOverlay,
        );
    }
  }

  static bool supports(MBCardVariant variant) {
    switch (variant) {
      case MBCardVariant.compact01:
      case MBCardVariant.compact02:
      case MBCardVariant.price01:
      case MBCardVariant.horizontal01:
      case MBCardVariant.premium01:
      case MBCardVariant.wide01:
      case MBCardVariant.featured01:
      case MBCardVariant.promo01:
      case MBCardVariant.flash01:
        return true;
    }
  }

  static List<MBCardVariant> supportedVariants() {
    return const <MBCardVariant>[
      MBCardVariant.compact01,
      MBCardVariant.compact02,
      MBCardVariant.price01,
      MBCardVariant.horizontal01,
      MBCardVariant.premium01,
      MBCardVariant.wide01,
      MBCardVariant.featured01,
      MBCardVariant.promo01,
      MBCardVariant.flash01,
    ];
  }
}