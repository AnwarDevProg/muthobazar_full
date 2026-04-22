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

  static const List<MBProductCardLayout> availableLayouts = <MBProductCardLayout>[
    MBProductCardLayout.standard,
    MBProductCardLayout.compact,
    MBProductCardLayout.deal,
    MBProductCardLayout.featured,
    MBProductCardLayout.card01,
    MBProductCardLayout.card02,
    MBProductCardLayout.card03,
  ];

  static MBProductCardLayout previewFallbackFor(MBProductCardLayout layout) {
    switch (layout) {
      case MBProductCardLayout.standard:
      case MBProductCardLayout.compact:
      case MBProductCardLayout.deal:
      case MBProductCardLayout.featured:
      case MBProductCardLayout.card01:
      case MBProductCardLayout.card02:
      case MBProductCardLayout.card03:
        return layout;
    }
  }

  static String previewFallbackLabelFor(MBProductCardLayout layout) {
    return previewFallbackFor(layout).label;
  }

  @override
  Widget build(BuildContext context) {
    final layout = _resolveLayoutFromProduct(product);
    final variant = _layoutToVariant(layout, contextType: contextType);
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

  static MBProductCardLayout _resolveLayoutFromProduct(MBProduct product) {
    final dynamic p = product;

    final rawCandidates = <Object?>[
      _tryRead(() => p.cardLayoutType),
      _tryRead(() => p.cardStyle),
      _tryRead(() => p.cardType),
    ];

    for (final raw in rawCandidates) {
      final normalized = raw?.toString().trim();
      if (normalized != null && normalized.isNotEmpty) {
        return MBProductCardLayoutHelper.parse(normalized);
      }
    }

    return MBProductCardLayout.compact;
  }

  static MBCardVariant _layoutToVariant(
      MBProductCardLayout layout, {
        required MBProductCardRenderContext contextType,
      }) {
    switch (layout) {
      case MBProductCardLayout.compact:
        return MBCardVariant.compact01;
      case MBProductCardLayout.card01:
        return MBCardVariant.price01;
      case MBProductCardLayout.standard:
        return MBCardVariant.horizontal01;
      case MBProductCardLayout.card02:
        return MBCardVariant.premium01;
      case MBProductCardLayout.featured:
        return contextType == MBProductCardRenderContext.featured
            ? MBCardVariant.featured01
            : MBCardVariant.wide01;
      case MBProductCardLayout.card03:
        return MBCardVariant.featured01;
      case MBProductCardLayout.deal:
        return MBCardVariant.flash01;
    }
  }

  static Object? _tryRead(Object? Function() reader) {
    try {
      return reader();
    } catch (_) {
      return null;
    }
  }
}
