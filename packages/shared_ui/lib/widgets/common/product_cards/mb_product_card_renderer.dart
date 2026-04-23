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

    return _fallbackVariantForContext();
  }

  String? _readVariantCarrier(MBProduct product) {
    final dynamic p = product;

    final candidates = <String?>[
      _tryReadString(() => p.cardVariantId),
      _tryReadString(() => p.cardVariant),
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
    final normalized = raw.trim().toLowerCase();
    final bridged = _bridgeLegacyVariantId(normalized);

    return MBCardVariantHelper.parse(
      bridged,
      fallback: _fallbackVariantForContext(),
    );
  }

  String _bridgeLegacyVariantId(String raw) {
    switch (raw) {
    // Current family ids accidentally stored instead of full variant ids.
      case 'compact':
        return 'compact01';
      case 'price':
        return 'price01';
      case 'horizontal':
        return 'horizontal01';
      case 'premium':
        return 'premium01';
      case 'wide':
        return 'wide01';
      case 'promo':
        return 'promo01';
      case 'flash':
      case 'flashsale':
      case 'flash_sale':
        return 'flash01';

    // Old layout model bridge.
      case 'standard':
        return 'horizontal01';
      case 'deal':
        return 'flash01';
      case 'card01':
        return 'price01';
      case 'card02':
        return 'premium01';
      case 'card03':
        return 'featured01';

    // Old "featured" used to route differently by context.
      case 'featured':
        return contextType == MBProductCardRenderContext.featured
            ? 'featured01'
            : 'wide01';

      default:
        return raw;
    }
  }

  MBCardVariant _fallbackVariantForContext() {
    switch (contextType) {
      case MBProductCardRenderContext.featured:
        return MBCardVariant.featured01;
      case MBProductCardRenderContext.list:
        return MBCardVariant.horizontal01;
      case MBProductCardRenderContext.grid:
      case MBProductCardRenderContext.auto:
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