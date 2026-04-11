import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

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

  @override
  Widget build(BuildContext context) {
    final layout = MBProductCardLayoutHelper.parse(product.cardLayoutType);
    final resolved = _resolveLayout(layout, contextType);

    switch (resolved) {
      case MBProductCardLayout.compact:
        return MBProductCardCompact(
          product: product,
          onTap: onTap,
          onAddToCart: onAddToCart,
          isFavorite: isFavorite,
          onFavoriteTap: onFavoriteTap,
          showFavorite: showFavorite,
          showAddButton: showAddToCart,
        );

      case MBProductCardLayout.deal:
        return MBProductCardDeal(
          product: product,
          onTap: onTap,
          onAddToCart: onAddToCart,
          isFavorite: isFavorite,
          onFavoriteTap: onFavoriteTap,
          showAddToCart: showAddToCart,
        );

      case MBProductCardLayout.featured:
        return MBProductCardFeatured(
          product: product,
          onTap: onTap,
          onAddToCart: onAddToCart,
          isFavorite: isFavorite,
          onFavoriteTap: onFavoriteTap,
          showAddToCart: showAddToCart,
          height: featuredHeight,
        );

      case MBProductCardLayout.standard:
        return MBProductCardStandard(
          product: product,
          onTap: onTap,
          onAddToCart: onAddToCart,
          isFavorite: isFavorite,
          onFavoriteTap: onFavoriteTap,
          showAddToCart: showAddToCart,
        );
    }
  }

  MBProductCardLayout _resolveLayout(
      MBProductCardLayout layout,
      MBProductCardRenderContext contextType,
      ) {
    switch (contextType) {
      case MBProductCardRenderContext.grid:
        return _gridSafeLayout(layout);

      case MBProductCardRenderContext.horizontal:
        return _horizontalSafeLayout(layout);

      case MBProductCardRenderContext.featured:
        return _featuredSafeLayout(layout);

      case MBProductCardRenderContext.auto:
        return layout;
    }
  }

  MBProductCardLayout _gridSafeLayout(MBProductCardLayout layout) {
    switch (layout) {
      case MBProductCardLayout.standard:
      case MBProductCardLayout.compact:
      case MBProductCardLayout.deal:
        return layout;
      case MBProductCardLayout.featured:
        return MBProductCardLayout.standard;
    }
  }

  MBProductCardLayout _horizontalSafeLayout(MBProductCardLayout layout) {
    switch (layout) {
      case MBProductCardLayout.standard:
      case MBProductCardLayout.compact:
      case MBProductCardLayout.deal:
      case MBProductCardLayout.featured:
        return layout;
    }
  }

  MBProductCardLayout _featuredSafeLayout(MBProductCardLayout layout) {
    switch (layout) {
      case MBProductCardLayout.featured:
        return MBProductCardLayout.featured;
      case MBProductCardLayout.deal:
        return MBProductCardLayout.deal;
      case MBProductCardLayout.compact:
      case MBProductCardLayout.standard:
        return MBProductCardLayout.standard;
    }
  }
}