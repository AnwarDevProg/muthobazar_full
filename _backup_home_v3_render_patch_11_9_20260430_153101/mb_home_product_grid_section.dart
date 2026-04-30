import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_layout_resolver.dart';

// MB Home Product Grid Section
// ----------------------------
// Patch 11.8: Restore Hybrid Row Pack Algorithm.
//
// Rules:
// - Shuffle products once when a fresh product list arrives.
// - Responsive columns:
//   phone/narrow content  -> 2 columns
//   medium/tablet content -> 3 columns
//   large/tablet content  -> 4 columns
// - Half-width cards are packed into completed rows before held full-width cards.
// - Full-width cards render as their own full-row items.
// - If a full-width card appears while a half row is pending, it is held until
//   the half row is completed.
// - If the list ends with a partial half row and held full-width cards, the
//   full-width cards render first, then the final partial half row.
// - No visible filler chip is drawn in this patch. Adaptive gap filler widgets
//   can be added in the next patch.

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
    final columnCount = _columnCountForWidth(maxWidth);
    final columnGap = _columnGapFor(columnCount);
    const rowGap = 16.0;

    final slotWidth = ((maxWidth - (columnGap * (columnCount - 1))) /
            columnCount)
        .clamp(96.0, maxWidth)
        .toDouble();

    final rows = _buildHybridRows(columnCount: columnCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          _buildRow(
            row: rows[index],
            columnCount: columnCount,
            columnGap: columnGap,
            slotWidth: slotWidth,
            fullWidth: maxWidth,
          ),
          if (index != rows.length - 1) const SizedBox(height: rowGap),
        ],
      ],
    );
  }

  int _columnCountForWidth(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  double _columnGapFor(int columnCount) {
    if (columnCount >= 4) return 16;
    if (columnCount == 3) return 14;
    return 12;
  }

  List<_ProductCardRow> _buildHybridRows({
    required int columnCount,
  }) {
    final rows = <_ProductCardRow>[];
    final pendingHalfWidthCards = <MBProduct>[];
    final heldFullWidthCards = <MBProduct>[];

    void flushHeldFullWidthCards() {
      if (heldFullWidthCards.isEmpty) return;

      for (final product in heldFullWidthCards) {
        rows.add(_ProductCardRow.full(product));
      }

      heldFullWidthCards.clear();
    }

    void addCompletedHalfRow() {
      if (pendingHalfWidthCards.isEmpty) return;

      rows.add(
        _ProductCardRow.half(
          products: List<MBProduct>.of(
            pendingHalfWidthCards.take(columnCount),
            growable: false,
          ),
        ),
      );

      pendingHalfWidthCards.removeRange(
        0,
        min(columnCount, pendingHalfWidthCards.length),
      );

      // Core hybrid-row rule:
      // Full-width cards are rendered only after a half row has completed.
      flushHeldFullWidthCards();
    }

    for (final product in products) {
      if (_isFullWidthProduct(product)) {
        if (pendingHalfWidthCards.isEmpty) {
          rows.add(_ProductCardRow.full(product));
        } else {
          heldFullWidthCards.add(product);
        }
        continue;
      }

      pendingHalfWidthCards.add(product);

      if (pendingHalfWidthCards.length >= columnCount) {
        addCompletedHalfRow();
      }
    }

    // End-of-list rule:
    // If full-width cards were held but the remaining half row never completed,
    // render the full-width cards first, then the final partial half row.
    flushHeldFullWidthCards();

    if (pendingHalfWidthCards.isNotEmpty) {
      rows.add(
        _ProductCardRow.half(
          products: List<MBProduct>.of(
            pendingHalfWidthCards,
            growable: false,
          ),
        ),
      );
    }

    return rows;
  }

  Widget _buildRow({
    required _ProductCardRow row,
    required int columnCount,
    required double columnGap,
    required double slotWidth,
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
        child: _HomeProductCard(
          product: fullWidthProduct,
          featured: true,
          featuredHeight: height,
          onProductTap: onProductTap,
          onAddToCart: onAddToCart,
        ),
      );
    }

    final halfProducts = row.halfWidthProducts;
    if (halfProducts.isEmpty) return const SizedBox.shrink();

    final itemHeights = <MBProduct, double>{
      for (final product in halfProducts)
        product: _CardRuntimeHeightResolver.heightForProduct(
          product: product,
          width: slotWidth,
        ),
    };

    final rowHeight = itemHeights.values.fold<double>(
      0,
      (previous, current) => max(previous, current),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < columnCount; index++) ...[
          Expanded(
            child: index < halfProducts.length
                ? _HalfCardSlot(
                    product: halfProducts[index],
                    cardHeight: itemHeights[halfProducts[index]] ?? rowHeight,
                    rowHeight: rowHeight,
                    onProductTap: onProductTap,
                    onAddToCart: onAddToCart,
                  )
                : SizedBox(height: rowHeight),
          ),
          if (index != columnCount - 1) SizedBox(width: columnGap),
        ],
      ],
    );
  }

  bool _isFullWidthProduct(MBProduct product) {
    if (product.hasCardDesignJson) {
      return _V3SavedLayoutMetrics.fromJson(product.cardDesignJson).isFullWidth;
    }

    final config = product.effectiveCardConfig.normalized();
    return config.variant.isFullWidth;
  }
}

class _HalfCardSlot extends StatelessWidget {
  const _HalfCardSlot({
    required this.product,
    required this.cardHeight,
    required this.rowHeight,
    this.onProductTap,
    this.onAddToCart,
  });

  final MBProduct product;
  final double cardHeight;
  final double rowHeight;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final safeCardHeight = cardHeight.clamp(1.0, rowHeight).toDouble();

    return SizedBox(
      height: rowHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: safeCardHeight,
            child: _HomeProductCard(
              product: product,
              onProductTap: onProductTap,
              onAddToCart: onAddToCart,
            ),
          ),
          if (rowHeight > safeCardHeight)
            SizedBox(height: rowHeight - safeCardHeight),
        ],
      ),
    );
  }
}

class _HomeProductCard extends StatelessWidget {
  const _HomeProductCard({
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
    return MBProductCardRenderer(
      product: product,
      contextType: featured
          ? MBProductCardRenderContext.featured
          : MBProductCardRenderContext.grid,
      featuredHeight: featured ? featuredHeight : null,
      onTap: () => onProductTap?.call(product),
      onAddToCartTap: () => onAddToCart?.call(product),
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
      final metrics = _V3SavedLayoutMetrics.fromJson(product.cardDesignJson);
      return metrics.heightForWidth(width);
    }

    final profile = MBProductCardLayoutResolver.resolve(
      product: product,
      availableWidth: width,
    );

    return featured ? profile.preferredHeight : profile.preferredHeight;
  }
}

class _V3SavedLayoutMetrics {
  const _V3SavedLayoutMetrics({
    required this.cardWidth,
    required this.cardHeight,
    required this.cardLayoutType,
    required this.templateId,
    required this.designFamilyId,
    required this.footprint,
    required this.columnSpan,
  });

  final double cardWidth;
  final double cardHeight;
  final String cardLayoutType;
  final String templateId;
  final String designFamilyId;
  final String footprint;
  final int? columnSpan;

  bool get isFullWidth {
    final tokens = <String>[
      cardLayoutType,
      templateId,
      designFamilyId,
      footprint,
    ].join(' ').toLowerCase();

    if (columnSpan != null && columnSpan! >= 2) return true;

    if (tokens.contains('full') ||
        tokens.contains('wide') ||
        tokens.contains('banner') ||
        tokens.contains('feature') ||
        tokens.contains('horizontal')) {
      return true;
    }

    // V3 half cards normally use 185/192. Full-row templates normally use
    // roughly 392. Treat very wide saved designs as full-width cards.
    return cardWidth >= 300;
  }

  double heightForWidth(double runtimeWidth) {
    final safeDesignWidth = cardWidth.clamp(80.0, 900.0).toDouble();
    final safeDesignHeight = cardHeight.clamp(80.0, 1200.0).toDouble();
    final safeRuntimeWidth = runtimeWidth.clamp(80.0, 1200.0).toDouble();

    final aspectHeight = safeRuntimeWidth * (safeDesignHeight / safeDesignWidth);
    return aspectHeight.clamp(80.0, 1400.0).toDouble();
  }

  factory _V3SavedLayoutMetrics.fromJson(String? rawJson) {
    final root = _readRootMap(rawJson);
    final layout = _asStringMap(root['layout']);
    final metadata = _asStringMap(root['metadata']);

    final cardWidth = _readDouble(
      layout['cardWidth'],
      fallback: 185,
    ).clamp(80.0, 900.0).toDouble();

    final cardHeight = _readDouble(
      layout['cardHeight'],
      fallback: 255,
    ).clamp(80.0, 1200.0).toDouble();

    final cardLayoutType = _firstNonEmptyString([
      layout['cardLayoutType'],
      metadata['cardLayoutType'],
      root['templateId'],
    ]);

    return _V3SavedLayoutMetrics(
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      cardLayoutType: cardLayoutType,
      templateId: root['templateId']?.toString().trim() ?? '',
      designFamilyId: root['designFamilyId']?.toString().trim() ?? '',
      footprint: _firstNonEmptyString([
        layout['footprint'],
        layout['cardFootprint'],
        metadata['footprint'],
        metadata['cardFootprint'],
      ]),
      columnSpan: _readNullableInt(
        layout['columnSpan'] ??
            layout['gridColumnSpan'] ??
            metadata['columnSpan'] ??
            metadata['gridColumnSpan'],
      ),
    );
  }

  static Map<String, dynamic> _readRootMap(String? rawJson) {
    final source = rawJson?.trim();
    if (source == null || source.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(source);
      return _asStringMap(decoded);
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}

class _ProductCardRow {
  const _ProductCardRow._({
    this.fullWidthProduct,
    this.halfWidthProducts = const <MBProduct>[],
  });

  factory _ProductCardRow.full(MBProduct product) {
    return _ProductCardRow._(
      fullWidthProduct: product,
    );
  }

  factory _ProductCardRow.half({
    required List<MBProduct> products,
  }) {
    return _ProductCardRow._(
      halfWidthProducts: products,
    );
  }

  final MBProduct? fullWidthProduct;
  final List<MBProduct> halfWidthProducts;
}

Map<String, dynamic> _asStringMap(Object? source) {
  if (source is Map<String, dynamic>) return Map<String, dynamic>.from(source);
  if (source is Map) {
    return source.map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }
  return <String, dynamic>{};
}

double _readDouble(
  Object? value, {
  required double fallback,
}) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

int? _readNullableInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString().trim() ?? '');
}

String _firstNonEmptyString(List<Object?> values) {
  for (final value in values) {
    final normalized = value?.toString().trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
  }
  return '';
}

