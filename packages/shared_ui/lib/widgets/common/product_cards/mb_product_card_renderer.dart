import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import 'system/mb_card_config_resolver.dart';
import 'system/mb_product_card_variant_router.dart';

enum MBProductCardRenderContext {
  auto,
  grid,
  list,
  featured,
}

class MBProductCardRenderer extends StatelessWidget {
  const MBProductCardRenderer({
    super.key,
    required this.product,
    this.contextType = MBProductCardRenderContext.auto,
    this.featuredHeight,
    this.onTap,
    this.onAddToCartTap,
    this.trailingOverlay,
  });

  final MBProduct product;
  final MBProductCardRenderContext contextType;
  final double? featuredHeight;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCartTap;
  final Widget? trailingOverlay;

  @override
  Widget build(BuildContext context) {
    final variant = _resolveVariantFromProduct(product);
    final resolved = MBCardConfigResolver.resolveByVariant(variant);

    Widget child = MBProductCardVariantRouter.build(
      context: context,
      resolved: resolved,
      product: product,
      onTap: onTap,
      onAddToCartTap: onAddToCartTap,
      trailingOverlay: trailingOverlay,
    );

    if (featuredHeight != null && resolved.footprint.isFullWidth) {
      child = SizedBox(
        height: featuredHeight,
        child: child,
      );
    }

    return child;
  }

  MBCardVariant _resolveVariantFromProduct(MBProduct product) {
    final rawVariantId = _readVariantCarrier(product);
    if (rawVariantId != null && rawVariantId.isNotEmpty) {
      return _parseVariantId(rawVariantId);
    }

    if (contextType == MBProductCardRenderContext.featured) {
      return MBCardVariant.featured01;
    }

    return MBCardVariant.compact01;
  }

  String? _readVariantCarrier(MBProduct product) {
    final dynamic p = product;

    final candidates = <String?>[
      _tryReadString(() => p.cardLayoutType),
      _tryReadString(() => p.cardStyle),
      _tryReadString(() => p.cardType),
    ];

    for (final value in candidates) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }

    return null;
  }

  MBCardVariant _parseVariantId(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'compact01':
        return MBCardVariant.compact01;
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

    // Temporary migration bridge for older stored/layout values.
      case 'compact':
        return MBCardVariant.compact01;
      case 'card01':
        return MBCardVariant.price01;
      case 'standard':
        return MBCardVariant.horizontal01;
      case 'card02':
        return MBCardVariant.premium01;
      case 'featured':
        return contextType == MBProductCardRenderContext.featured
            ? MBCardVariant.featured01
            : MBCardVariant.wide01;
      case 'card03':
        return MBCardVariant.featured01;
      case 'deal':
        return MBCardVariant.flash01;

      default:
        return MBCardVariant.compact01;
    }
  }

  String? _tryReadString(String? Function() reader) {
    try {
      return reader();
    } catch (_) {
      return null;
    }
  }
}