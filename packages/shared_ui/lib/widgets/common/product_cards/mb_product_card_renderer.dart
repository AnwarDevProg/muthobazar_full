import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import 'mb_product_card_card01.dart';
import 'mb_product_card_card02.dart';
import 'mb_product_card_card03.dart';
import 'mb_product_card_compact.dart';
import 'mb_product_card_deal.dart';
import 'mb_product_card_featured.dart';
import 'mb_product_card_standard.dart';

enum MBProductCardRenderContext {
  grid,
  horizontal,
  featured,
  auto,
}

typedef MBProductCardBuilder = Widget Function(
    BuildContext context,
    MBProductCardRenderer renderer,
    MBProduct product,
    );

class MBProductCardRenderer extends StatelessWidget {
  const MBProductCardRenderer({
    super.key,
    required this.product,
    this.contextType = MBProductCardRenderContext.auto,
    this.onTap,
    this.onAddToCart,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showAddToCart = true,
    this.showFavorite = true,
    this.featuredHeight = 320,
  });

  final MBProduct product;
  final MBProductCardRenderContext contextType;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showAddToCart;
  final bool showFavorite;
  final double featuredHeight;

  static final Map<MBProductCardLayout, MBProductCardBuilder> _builders =
  <MBProductCardLayout, MBProductCardBuilder>{
    MBProductCardLayout.standard: (context, renderer, product) {
      return MBProductCardStandard(
        product: product,
        onTap: renderer.onTap,
        onAddToCart: renderer.onAddToCart,
        isFavorite: renderer.isFavorite,
        onFavoriteTap: renderer.onFavoriteTap,
        showAddToCart: renderer.showAddToCart,
      );
    },
    MBProductCardLayout.compact: (context, renderer, product) {
      return MBProductCardCompact(
        product: product,
        onTap: renderer.onTap,
        onAddToCart: renderer.onAddToCart,
        isFavorite: renderer.isFavorite,
        onFavoriteTap: renderer.onFavoriteTap,
        showFavorite: renderer.showFavorite,
        showAddButton: renderer.showAddToCart,
      );
    },
    MBProductCardLayout.deal: (context, renderer, product) {
      return MBProductCardDeal(
        product: product,
        onTap: renderer.onTap,
        onAddToCart: renderer.onAddToCart,
        isFavorite: renderer.isFavorite,
        onFavoriteTap: renderer.onFavoriteTap,
        showAddToCart: renderer.showAddToCart,
      );
    },
    MBProductCardLayout.featured: (context, renderer, product) {
      return MBProductCardFeatured(
        product: product,
        onTap: renderer.onTap,
        onAddToCart: renderer.onAddToCart,
        isFavorite: renderer.isFavorite,
        onFavoriteTap: renderer.onFavoriteTap,
        showAddToCart: renderer.showAddToCart,
        height: renderer.featuredHeight,
      );
    },
    MBProductCardLayout.card01: (context, renderer, product) {
      return MBProductCardCard01(
        product: product,
        onTap: renderer.onTap,
        onAddToCart: renderer.onAddToCart,
        isFavorite: renderer.isFavorite,
        onFavoriteTap: renderer.onFavoriteTap,
        showAddToCart: renderer.showAddToCart,
        showFavorite: renderer.showFavorite,
      );
    },
    MBProductCardLayout.card02: (context, renderer, product) {
      return MBProductCardCard02(
        product: product,
        onTap: renderer.onTap,
        onAddToCart: renderer.onAddToCart,
        isFavorite: renderer.isFavorite,
        onFavoriteTap: renderer.onFavoriteTap,
        showAddToCart: renderer.showAddToCart,
        showFavorite: renderer.showFavorite,
      );
    },
    MBProductCardLayout.card03: (context, renderer, product) {
      return Container(
        width: 260,
        height: 560,
        color: Colors.purple,
        alignment: Alignment.center,
        child: const Text(
          'RENDERER TEST',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    },
  };

  static final Map<MBProductCardLayout, MBProductCardLayout>
  _previewFallbackLayouts = <MBProductCardLayout, MBProductCardLayout>{
    MBProductCardLayout.card04: MBProductCardLayout.featured,
    MBProductCardLayout.card05: MBProductCardLayout.standard,
    MBProductCardLayout.card06: MBProductCardLayout.compact,
    MBProductCardLayout.card07: MBProductCardLayout.deal,
    MBProductCardLayout.card08: MBProductCardLayout.standard,
    MBProductCardLayout.card09: MBProductCardLayout.compact,
    MBProductCardLayout.card10: MBProductCardLayout.featured,
    MBProductCardLayout.card11: MBProductCardLayout.standard,
    MBProductCardLayout.card12: MBProductCardLayout.compact,
    MBProductCardLayout.card13: MBProductCardLayout.deal,
    MBProductCardLayout.card14: MBProductCardLayout.standard,
    MBProductCardLayout.card15: MBProductCardLayout.compact,
    MBProductCardLayout.card16: MBProductCardLayout.featured,
    MBProductCardLayout.card17: MBProductCardLayout.standard,
    MBProductCardLayout.card18: MBProductCardLayout.compact,
    MBProductCardLayout.card19: MBProductCardLayout.deal,
    MBProductCardLayout.card20: MBProductCardLayout.standard,
  };

  static List<MBProductCardLayout> get availableLayouts =>
      List<MBProductCardLayout>.unmodifiable(
        MBProductCardLayoutHelper.previewValues,
      );

  static List<MBProductCardLayout> get builtLayouts =>
      List<MBProductCardLayout>.unmodifiable(_builders.keys.toList());

  static bool isLayoutBuilt(MBProductCardLayout layout) {
    return _builders.containsKey(layout);
  }

  static MBProductCardLayout previewFallbackFor(MBProductCardLayout layout) {
    if (_builders.containsKey(layout)) {
      return layout;
    }

    return _previewFallbackLayouts[layout] ?? MBProductCardLayoutHelper.fallback;
  }

  static String previewFallbackLabelFor(MBProductCardLayout layout) {
    final fallback = previewFallbackFor(layout);
    if (fallback == layout) {
      return layout.label;
    }
    return '${layout.label} → ${fallback.label}';
  }

  @override
  Widget build(BuildContext context) {
    final rawLayout = MBProductCardLayoutHelper.parse(product.cardLayoutType);
    final resolvedLayout = _resolveLayout(rawLayout, contextType);
    final renderLayout = _resolveBuiltLayout(resolvedLayout);
    final builder =
        _builders[renderLayout] ?? _builders[MBProductCardLayout.standard]!;

    return builder(context, this, product);
  }

  MBProductCardLayout _resolveLayout(
      MBProductCardLayout layout,
      MBProductCardRenderContext contextType,
      ) {
    switch (contextType) {
      case MBProductCardRenderContext.grid:
        return MBProductCardLayoutHelper.gridSafeOrFallback(layout.value);
      case MBProductCardRenderContext.horizontal:
        return MBProductCardLayoutHelper.horizontalSafeOrFallback(layout.value);
      case MBProductCardRenderContext.featured:
        return _featuredSafeLayout(layout);
      case MBProductCardRenderContext.auto:
        return layout;
    }
  }

  MBProductCardLayout _resolveBuiltLayout(MBProductCardLayout layout) {
    if (_builders.containsKey(layout)) {
      return layout;
    }

    final previewFallback = _previewFallbackLayouts[layout];
    if (previewFallback != null && _builders.containsKey(previewFallback)) {
      return previewFallback;
    }

    return MBProductCardLayout.standard;
  }

  MBProductCardLayout _featuredSafeLayout(MBProductCardLayout layout) {
    switch (layout) {
      case MBProductCardLayout.featured:
        return MBProductCardLayout.featured;
      case MBProductCardLayout.deal:
        return MBProductCardLayout.deal;
      case MBProductCardLayout.standard:
      case MBProductCardLayout.compact:
      case MBProductCardLayout.card01:
      case MBProductCardLayout.card02:
      case MBProductCardLayout.card03:
        return layout;
      case MBProductCardLayout.card04:
      case MBProductCardLayout.card05:
      case MBProductCardLayout.card06:
      case MBProductCardLayout.card07:
      case MBProductCardLayout.card08:
      case MBProductCardLayout.card09:
      case MBProductCardLayout.card10:
      case MBProductCardLayout.card11:
      case MBProductCardLayout.card12:
      case MBProductCardLayout.card13:
      case MBProductCardLayout.card14:
      case MBProductCardLayout.card15:
      case MBProductCardLayout.card16:
      case MBProductCardLayout.card17:
      case MBProductCardLayout.card18:
      case MBProductCardLayout.card19:
      case MBProductCardLayout.card20:
        return previewFallbackFor(layout);
    }
  }
}
