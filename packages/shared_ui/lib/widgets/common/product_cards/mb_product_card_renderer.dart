import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import 'system/mb_card_config_resolver.dart';
import 'system/mb_product_card_variant_router.dart';

// File: mb_product_card_renderer.dart
//
// Product Card Renderer
// ---------------------
// Purpose:
// - Central renderer for customer/admin product cards.
// - Reads the product-level persisted card configuration first.
// - Applies both the selected card variant and saved per-product card settings.
// - Keeps a legacy bridge for older values such as standard, deal, featured,
//   card01, card02, and card03.
//
// Card source of truth:
// - New source: product.effectiveCardConfig.
// - Legacy fallback: product.cardLayoutType and older dynamic carrier names.
//
// Footprint behavior:
// - Each resolved card variant carries its own footprint.
// - Full-width variants can receive featuredHeight when used in featured areas.
// - Half/grid cards keep their natural size from the parent grid/list layout.
//
// Behavior:
// - Tap and add-to-cart callbacks are forwarded to the selected card widget.
// - trailingOverlay is forwarded for admin/customer overlays.
// - contextType is now only a fallback helper when older products do not contain
//   a valid saved product-card variant.

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
    final cardConfig = _resolveCardConfigFromProduct(product);
    final resolved = MBCardConfigResolver.resolveByVariant(
      cardConfig.variant,
      settings: cardConfig.settings,
    );

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

  MBCardInstanceConfig _resolveCardConfigFromProduct(MBProduct product) {
    try {
      final config = product.effectiveCardConfig.normalized();
      final variant = _parseVariantId(config.variantId);

      return MBCardInstanceConfig(
        family: variant.family,
        variant: variant,
        presetId: config.presetId,
        settings: config.settings,
      ).normalized();
    } catch (_) {
      final variant = _resolveLegacyVariantFromProduct(product);

      return MBCardInstanceConfig(
        family: variant.family,
        variant: variant,
      ).normalized();
    }
  }

  MBCardVariant _resolveLegacyVariantFromProduct(MBProduct product) {
    final rawVariantId = _readLegacyVariantCarrier(product);

    if (rawVariantId != null && rawVariantId.isNotEmpty) {
      return _parseVariantId(rawVariantId);
    }

    return _fallbackVariantForContext();
  }

  String? _readLegacyVariantCarrier(MBProduct product) {
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
    // Empty/default values.
      case '':
      case 'standard':
      case 'default':
        return 'compact01';

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
      case 'flash-sale':
        return 'flash01';

    // Old layout model bridge.
      case 'deal':
        return 'promo01';
      case 'card01':
        return 'price01';
      case 'card02':
        return 'premium01';
      case 'card03':
        return 'featured01';
      case 'featured':
        return 'featured01';

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
