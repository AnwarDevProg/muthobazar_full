import 'package:flutter/material.dart';
import 'package:shared_models/product_cards/config/product_card_config.dart';
import 'package:shared_models/shared_models.dart';

import 'system/mb_card_config_resolver.dart';
import 'system/mb_product_card_variant_router.dart';

// File: mb_product_card_renderer.dart
// Location:
// packages/shared_ui/lib/widgets/common/product_cards/mb_product_card_renderer.dart
//
// Purpose:
// Central product-card renderer used by customer screens such as Home/Store.
//
// Important fix:
// Older renderer logic resolved only the variant:
//
//   MBCardConfigResolver.resolveByVariant(variant)
//
// That renders the correct card type, but ignores product.cardConfig.settings.
// So admin-selected settings can be saved correctly but not appear on Home.
//
// This version resolves the full persisted product.effectiveCardConfig first.
// That allows Home/Store to render:
// - selected family
// - selected variant
// - persisted settings override
// - preset id later, when preset registry is added

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

    final variant = cardConfig?.variant ?? _resolveVariantFromProduct(product);

    final resolved = cardConfig == null
        ? MBCardConfigResolver.resolveByVariant(variant)
        : MBCardConfigResolver.resolve(cardConfig);

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

  MBCardInstanceConfig? _resolveCardConfigFromProduct(MBProduct product) {
    final effective = _tryReadCardConfig(() => product.effectiveCardConfig);

    if (_isUsableCardConfig(effective)) {
      return effective!.normalized();
    }

    final direct = _tryReadCardConfig(() => product.cardConfig);

    if (_isUsableCardConfig(direct)) {
      return direct!.normalized();
    }

    final rawVariantId = _readVariantCarrier(product);

    if (rawVariantId != null && rawVariantId.isNotEmpty) {
      final variant = _parseVariantId(rawVariantId);

      return MBCardInstanceConfig(
        family: variant.family,
        variant: variant,
      ).normalized();
    }

    return null;
  }

  bool _isUsableCardConfig(MBCardInstanceConfig? config) {
    if (config == null) {
      return false;
    }

    final normalized = config.normalized();

    if (normalized.hasPreset || normalized.hasOverrides) {
      return true;
    }

    final variantId = normalized.variantId.trim();
    final familyId = normalized.familyId.trim();

    if (variantId.isEmpty || familyId.isEmpty) {
      return false;
    }

    // Even without overrides, a non-default variant is still meaningful.
    return variantId != MBCardVariant.compact01.id ||
        familyId != MBCardFamily.compact.id;
  }

  MBCardInstanceConfig? _tryReadCardConfig(
      MBCardInstanceConfig Function() reader,
      ) {
    try {
      return reader().normalized();
    } catch (_) {
      return null;
    }
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
      _tryReadString(() => p.effectiveCardVariantId),
      _tryReadString(() => p.normalizedCardLayoutType),
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
    final bridged = _bridgeVariantId(normalized);

    return MBCardVariantHelper.parse(
      bridged,
      fallback: _fallbackVariantForContext(),
    );
  }

  String _bridgeVariantId(String raw) {
    switch (raw) {
      case 'compact':
        return MBCardVariant.compact01.id;
      case 'price':
        return MBCardVariant.price01.id;
      case 'horizontal':
        return MBCardVariant.horizontal01.id;
      case 'premium':
        return MBCardVariant.premium01.id;
      case 'wide':
        return MBCardVariant.wide01.id;
      case 'promo':
        return MBCardVariant.promo01.id;
      case 'flash':
      case 'flashsale':
      case 'flash_sale':
      case 'flash-sale':
        return MBCardVariant.flash01.id;
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
