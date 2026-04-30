import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_layout_resolver.dart';

// MB Home Product Horizontal Section
// ----------------------------------
// Saved-design-aware horizontal product list.

class MBHomeProductHorizontalSection extends StatelessWidget {
  const MBHomeProductHorizontalSection({
    super.key,
    required this.section,
    required this.products,
    this.offers = const <MBOffer>[],
    this.onProductTap,
    this.onAddToCart,
    this.onViewAllTap,
  });

  final MBHomeSection section;
  final List<MBProduct> products;
  final List<MBOffer> offers;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;
  final VoidCallback? onViewAllTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final itemSizes = [
      for (final product in products) _itemSizeForProduct(context, product),
    ];

    final listHeight = itemSizes
        .map((size) => size.height)
        .fold<double>(260, (previous, current) => current > previous
            ? current
            : previous)
        .clamp(240, 440)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MBSectionTitle(
          title: section.titleEn.isNotEmpty ? section.titleEn : 'Products',
          actionText: section.showViewAll ? 'See All' : null,
          onTapAction: onViewAllTap,
        ),
        MBSpacing.h(MBSpacing.sm),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => MBSpacing.w(MBSpacing.sm),
            itemBuilder: (context, index) {
              final product = products[index];
              final size = itemSizes[index];

              return SizedBox(
                width: size.width,
                height: size.height,
                child: MBSavedDesignProductCard(
                  product: product,
                  fitInsideParent: false,
                  onTap: () => onProductTap?.call(product),
                  onPrimaryCtaTap: () => onAddToCart?.call(product),
                  onSecondaryCtaTap: () => onAddToCart?.call(product),
                  fallback: MBProductCardRenderer(
                    product: product,
                    contextType: _isFullWidthProduct(product)
                        ? MBProductCardRenderContext.featured
                        : MBProductCardRenderContext.grid,
                    featuredHeight:
                        _isFullWidthProduct(product) ? size.height : null,
                    onTap: () => onProductTap?.call(product),
                    onAddToCartTap: () => onAddToCart?.call(product),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Size _itemSizeForProduct(BuildContext context, MBProduct product) {
    final width = _widthForProduct(context, product);
    final height = _heightForProduct(product, width);
    return Size(width, height);
  }

  double _widthForProduct(BuildContext context, MBProduct product) {
    if (product.hasCardDesignJson) {
      return 190;
    }

    if (!_isFullWidthProduct(product)) {
      return 170;
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final available = screenWidth - (MBSpacing.pageHorizontal(context) * 2);
    return available.clamp(290.0, 360.0);
  }

  double _heightForProduct(MBProduct product, double width) {
    if (product.hasCardDesignJson) {
      final metrics = _SavedDesignLayoutMetrics.fromJson(
        product.cardDesignJson,
      );

      return metrics.heightForWidth(width);
    }

    final profile = MBProductCardLayoutResolver.resolve(
      product: product,
      availableWidth: width,
    );

    return profile.preferredHeight;
  }

  bool _isFullWidthProduct(MBProduct product) {
    final config = product.effectiveCardConfig.normalized();
    return config.variant.isFullWidth;
  }
}

class _SavedDesignLayoutMetrics {
  const _SavedDesignLayoutMetrics({
    required this.savedCardWidth,
    required this.aspectRatio,
    required this.minHeight,
    required this.maxHeight,
  });

  final double savedCardWidth;
  final double aspectRatio;
  final double minHeight;
  final double maxHeight;

  factory _SavedDesignLayoutMetrics.fromJson(String? rawJson) {
    final layout = _readLayoutMap(rawJson);

    final savedCardWidth = _readDouble(
      layout['cardWidth'],
      fallback: 220,
    ).clamp(120, 420).toDouble();

    final aspectRatio = _readDouble(
      layout['aspectRatio'],
      fallback: 0.56,
    ).clamp(0.35, 1.25).toDouble();

    final minHeight = _readDouble(
      layout['minHeight'],
      fallback: 430,
    ).clamp(120, 900).toDouble();

    final maxHeight = _readDouble(
      layout['maxHeight'],
      fallback: 520,
    ).clamp(minHeight, 1200).toDouble();

    return _SavedDesignLayoutMetrics(
      savedCardWidth: savedCardWidth,
      aspectRatio: aspectRatio,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  double heightForWidth(double runtimeWidth) {
    final safeWidth = runtimeWidth.clamp(80, 800).toDouble();
    final scale = (safeWidth / savedCardWidth).clamp(0.35, 2.5).toDouble();

    final rawHeight = safeWidth / aspectRatio;
    final scaledMinHeight = minHeight * scale;
    final scaledMaxHeight = maxHeight * scale;

    final safeMin = scaledMinHeight.clamp(80, 1200).toDouble();
    final safeMax = scaledMaxHeight.clamp(safeMin, 1400).toDouble();

    return rawHeight.clamp(safeMin, safeMax).toDouble();
  }

  static Map<String, dynamic> _readLayoutMap(String? rawJson) {
    final source = rawJson?.trim();
    if (source == null || source.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) {
        return <String, dynamic>{};
      }

      final rawLayout = decoded['layout'];
      if (rawLayout is Map<String, dynamic>) {
        return Map<String, dynamic>.from(rawLayout);
      }

      if (rawLayout is Map) {
        return rawLayout.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  static double _readDouble(
    Object? value, {
    required double fallback,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
  }
}
