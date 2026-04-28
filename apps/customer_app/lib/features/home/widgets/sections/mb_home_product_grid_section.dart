import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_layout_resolver.dart';

// MB Home Product Grid Section
// ----------------------------
// Saved-design-aware Home grid.
//
// Rules:
// - Shuffle products once when a fresh product list arrives.
// - Half-width cards are paired two per row.
// - Full-width cards render as full rows.
// - If a saved design exists, card height comes from saved cardDesignJson,
//   scaled against the current runtime cell width.
// - If no saved design exists, old MBProductCardRenderer layout profile is used.
// - Small remaining gaps in a half pair are filled with a subtle filler block.

class MBHomeProductGridSection extends StatefulWidget {
  const MBHomeProductGridSection({
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
  State<MBHomeProductGridSection> createState() =>
      _MBHomeProductGridSectionState();
}

class _MBHomeProductGridSectionState extends State<MBHomeProductGridSection> {
  late List<MBProduct> _orderedProducts;
  List<MBProduct>? _lastProductsRef;
  String _lastProductSignature = '';

  @override
  void initState() {
    super.initState();
    _prepareProducts(forceShuffle: true);
  }

  @override
  void didUpdateWidget(covariant MBHomeProductGridSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextSignature = _signatureFor(widget.products);
    final shouldRefreshOrder = !identical(_lastProductsRef, widget.products) ||
        _lastProductSignature != nextSignature;

    if (shouldRefreshOrder) {
      _prepareProducts(forceShuffle: true);
    }
  }

  void _prepareProducts({required bool forceShuffle}) {
    _lastProductsRef = widget.products;
    _lastProductSignature = _signatureFor(widget.products);
    _orderedProducts = List<MBProduct>.of(widget.products, growable: false);

    if (forceShuffle && _orderedProducts.length > 1) {
      _orderedProducts.shuffle(Random(DateTime.now().microsecondsSinceEpoch));
    }
  }

  String _signatureFor(List<MBProduct> products) {
    return products.map((product) {
      final config = product.effectiveCardConfig.normalized();
      return [
        product.id,
        product.titleEn,
        product.cardLayoutType,
        config.familyId,
        config.variantId,
        product.cardDesignJson?.hashCode ?? 0,
      ].join(':');
    }).join('|');
  }

  @override
  Widget build(BuildContext context) {
    if (_orderedProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MBSectionTitle(
          title: widget.section.titleEn.isNotEmpty
              ? widget.section.titleEn
              : 'Products',
          actionText: widget.section.showViewAll ? 'See All' : null,
          onTapAction: widget.onViewAllTap,
        ),
        MBSpacing.h(MBSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth =
                constraints.maxWidth.isFinite && constraints.maxWidth > 0
                    ? constraints.maxWidth
                    : MediaQuery.sizeOf(context).width -
                        (MBSpacing.pageHorizontal(context) * 2);

            return _ProductCardFlow(
              products: _orderedProducts,
              maxWidth: availableWidth,
              onProductTap: widget.onProductTap,
              onAddToCart: widget.onAddToCart,
            );
          },
        ),
      ],
    );
  }
}

class _ProductCardFlow extends StatelessWidget {
  const _ProductCardFlow({
    required this.products,
    required this.maxWidth,
    this.onProductTap,
    this.onAddToCart,
  });

  final List<MBProduct> products;
  final double maxWidth;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    const columnGap = 12.0;
    const rowGap = 14.0;

    final halfWidth = ((maxWidth - columnGap) / 2).clamp(120, maxWidth);
    final rows = _buildGaplessRows();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          _buildRow(
            row: rows[index],
            columnGap: columnGap,
            halfWidth: halfWidth.toDouble(),
            fullWidth: maxWidth,
          ),
          if (index != rows.length - 1) const SizedBox(height: rowGap),
        ],
      ],
    );
  }

  List<_ProductCardRow> _buildGaplessRows() {
    final rows = <_ProductCardRow>[];
    MBProduct? pendingHalf;
    final heldFullWidthCards = <MBProduct>[];

    void flushHeldFullWidthCards() {
      if (heldFullWidthCards.isEmpty) return;

      for (final product in heldFullWidthCards) {
        rows.add(_ProductCardRow.full(product));
      }

      heldFullWidthCards.clear();
    }

    void addHalfProduct(MBProduct product) {
      if (pendingHalf == null) {
        pendingHalf = product;
        return;
      }

      rows.add(
        _ProductCardRow.half(
          first: pendingHalf!,
          second: product,
        ),
      );

      pendingHalf = null;
      flushHeldFullWidthCards();
    }

    void addFullWidthProduct(MBProduct product) {
      if (pendingHalf == null) {
        rows.add(_ProductCardRow.full(product));
        return;
      }

      heldFullWidthCards.add(product);
    }

    for (final product in products) {
      if (_isFullWidthProduct(product)) {
        addFullWidthProduct(product);
      } else {
        addHalfProduct(product);
      }
    }

    if (pendingHalf != null && heldFullWidthCards.isNotEmpty) {
      flushHeldFullWidthCards();
      rows.add(
        _ProductCardRow.half(
          first: pendingHalf!,
          second: null,
        ),
      );
    } else {
      flushHeldFullWidthCards();

      if (pendingHalf != null) {
        rows.add(
          _ProductCardRow.half(
            first: pendingHalf!,
            second: null,
          ),
        );
      }
    }

    return rows;
  }

  Widget _buildRow({
    required _ProductCardRow row,
    required double columnGap,
    required double halfWidth,
    required double fullWidth,
  }) {
    final fullWidthProduct = row.fullWidthProduct;

    if (fullWidthProduct != null) {
      final height = _CardRuntimeHeightResolver.heightForProduct(
        product: fullWidthProduct,
        width: fullWidth,
        featured: true,
      );

      return SizedBox(
        height: height,
        child: _SavedAwareCard(
          product: fullWidthProduct,
          featured: true,
          featuredHeight: height,
          onProductTap: onProductTap,
          onAddToCart: onAddToCart,
        ),
      );
    }

    return _HalfWidthPairRow(
      first: row.firstHalfProduct,
      second: row.secondHalfProduct,
      gap: columnGap,
      halfWidth: halfWidth,
      onProductTap: onProductTap,
      onAddToCart: onAddToCart,
    );
  }

  bool _isFullWidthProduct(MBProduct product) {
    if (product.hasCardDesignJson) {
      return false;
    }

    final config = product.effectiveCardConfig.normalized();
    return config.variant.isFullWidth;
  }
}

class _HalfWidthPairRow extends StatelessWidget {
  const _HalfWidthPairRow({
    required this.first,
    required this.second,
    required this.gap,
    required this.halfWidth,
    this.onProductTap,
    this.onAddToCart,
  });

  final MBProduct first;
  final MBProduct? second;
  final double gap;
  final double halfWidth;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final firstHeight = _CardRuntimeHeightResolver.heightForProduct(
      product: first,
      width: halfWidth,
    );

    if (second == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _HalfCardSlot(
              product: first,
              cardHeight: firstHeight,
              fillerHeight: 0,
              onProductTap: onProductTap,
              onAddToCart: onAddToCart,
            ),
          ),
          SizedBox(width: gap),
          const Expanded(child: SizedBox.shrink()),
        ],
      );
    }

    final secondHeight = _CardRuntimeHeightResolver.heightForProduct(
      product: second!,
      width: halfWidth,
    );

    final rowHeight = max(firstHeight, secondHeight);
    final firstFiller = max(0.0, rowHeight - firstHeight);
    final secondFiller = max(0.0, rowHeight - secondHeight);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _HalfCardSlot(
            product: first,
            cardHeight: firstHeight,
            fillerHeight: firstFiller,
            onProductTap: onProductTap,
            onAddToCart: onAddToCart,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _HalfCardSlot(
            product: second!,
            cardHeight: secondHeight,
            fillerHeight: secondFiller,
            onProductTap: onProductTap,
            onAddToCart: onAddToCart,
          ),
        ),
      ],
    );
  }
}

class _HalfCardSlot extends StatelessWidget {
  const _HalfCardSlot({
    required this.product,
    required this.cardHeight,
    required this.fillerHeight,
    this.onProductTap,
    this.onAddToCart,
  });

  final MBProduct product;
  final double cardHeight;
  final double fillerHeight;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: cardHeight,
          child: _SavedAwareCard(
            product: product,
            onProductTap: onProductTap,
            onAddToCart: onAddToCart,
          ),
        ),
        if (fillerHeight > 8)
          Container(
            height: fillerHeight,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF7A00).withValues(alpha: 0.12),
                  const Color(0xFFFF7A00).withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          )
        else if (fillerHeight > 0)
          SizedBox(height: fillerHeight),
      ],
    );
  }
}

class _SavedAwareCard extends StatelessWidget {
  const _SavedAwareCard({
    required this.product,
    this.featured = false,
    this.featuredHeight,
    this.onProductTap,
    this.onAddToCart,
  });

  final MBProduct product;
  final bool featured;
  final double? featuredHeight;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return MBSavedDesignProductCard(
      product: product,
      fitInsideParent: false,
      onTap: () => onProductTap?.call(product),
      onPrimaryCtaTap: () => onAddToCart?.call(product),
      onSecondaryCtaTap: () => onAddToCart?.call(product),
      fallback: MBProductCardRenderer(
        product: product,
        contextType: featured
            ? MBProductCardRenderContext.featured
            : MBProductCardRenderContext.grid,
        featuredHeight: featured ? featuredHeight : null,
        onTap: () => onProductTap?.call(product),
        onAddToCartTap: () => onAddToCart?.call(product),
      ),
    );
  }
}

class _CardRuntimeHeightResolver {
  const _CardRuntimeHeightResolver._();

  static double heightForProduct({
    required MBProduct product,
    required double width,
    bool featured = false,
  }) {
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

    return featured ? profile.preferredHeight : profile.preferredHeight;
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

class _ProductCardRow {
  const _ProductCardRow._({
    this.fullWidthProduct,
    required this.firstHalfProduct,
    this.secondHalfProduct,
  });

  factory _ProductCardRow.full(MBProduct product) {
    return _ProductCardRow._(
      fullWidthProduct: product,
      firstHalfProduct: product,
    );
  }

  factory _ProductCardRow.half({
    required MBProduct first,
    MBProduct? second,
  }) {
    return _ProductCardRow._(
      firstHalfProduct: first,
      secondHalfProduct: second,
    );
  }

  final MBProduct? fullWidthProduct;
  final MBProduct firstHalfProduct;
  final MBProduct? secondHalfProduct;
}
