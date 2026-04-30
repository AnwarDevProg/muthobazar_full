import 'dart:convert';
import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_layout_resolver.dart';

// MB Home Product Grid Section
// ----------------------------
// Patch 11.7: Responsive grid packing with full-width V3 footprint restore.
//
// Rules:
// - Phone/narrow Home width uses 2 columns.
// - Wider Home width uses 3 or 4 columns.
// - V3 half cards span 1 column.
// - V3 full-width cards span all columns.
// - Future large/double V3 cards may span 2 columns.
// - Full-width products are always placed on their own row.
// - Half products are packed together row-by-row.
// - Empty row space is invisible; no decorative beige filler block is drawn.
// - V3 cardDesignJson is rendered through MBProductCardRenderer only.

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

            return _ResponsiveProductCardFlow(
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

class _ResponsiveProductCardFlow extends StatelessWidget {
  const _ResponsiveProductCardFlow({
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
    final columnGap = _gapForColumns(columnCount);
    final rowGap = columnCount >= 3 ? 16.0 : 14.0;
    final safeMaxWidth = maxWidth.clamp(160.0, 1600.0).toDouble();

    final unitWidth = ((safeMaxWidth - (columnGap * (columnCount - 1))) /
            columnCount)
        .clamp(96.0, safeMaxWidth)
        .toDouble();

    final rows = _buildRows(columnCount: columnCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          _buildRow(
            row: rows[index],
            columnCount: columnCount,
            unitWidth: unitWidth,
            columnGap: columnGap,
          ),
          if (index != rows.length - 1) SizedBox(height: rowGap),
        ],
      ],
    );
  }

  List<_ProductGridRow> _buildRows({required int columnCount}) {
    final rows = <_ProductGridRow>[];
    final currentTiles = <_ProductGridTile>[];
    var occupiedColumns = 0;

    void flushCurrentRow() {
      if (currentTiles.isEmpty) return;
      rows.add(_ProductGridRow(List<_ProductGridTile>.of(currentTiles)));
      currentTiles.clear();
      occupiedColumns = 0;
    }

    for (final product in products) {
      final span = _spanForProduct(
        product: product,
        columnCount: columnCount,
      );

      if (span >= columnCount) {
        flushCurrentRow();
        rows.add(
          _ProductGridRow(<_ProductGridTile>[
            _ProductGridTile(product: product, span: columnCount),
          ]),
        );
        continue;
      }

      if (occupiedColumns + span > columnCount) {
        flushCurrentRow();
      }

      currentTiles.add(_ProductGridTile(product: product, span: span));
      occupiedColumns += span;

      if (occupiedColumns >= columnCount) {
        flushCurrentRow();
      }
    }

    flushCurrentRow();
    return rows;
  }

  Widget _buildRow({
    required _ProductGridRow row,
    required int columnCount,
    required double unitWidth,
    required double columnGap,
  }) {
    final tileWidths = <_ProductGridTile, double>{
      for (final tile in row.tiles)
        tile: _tileWidthForSpan(
          span: tile.span,
          unitWidth: unitWidth,
          columnGap: columnGap,
        ),
    };

    final tileHeights = <_ProductGridTile, double>{
      for (final tile in row.tiles)
        tile: _CardRuntimeHeightResolver.heightForProduct(
          product: tile.product,
          width: tileWidths[tile]!,
          featured: tile.span >= columnCount,
        ),
    };

    final rowHeight = tileHeights.values.fold<double>(
      0,
      (previous, current) => math.max(previous, current),
    );

    final children = <Widget>[];

    for (var index = 0; index < row.tiles.length; index++) {
      final tile = row.tiles[index];
      final tileWidth = tileWidths[tile]!;
      final tileHeight = tileHeights[tile]!;

      if (index > 0) {
        children.add(SizedBox(width: columnGap));
      }

      children.add(
        SizedBox(
          width: tileWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: tileHeight,
                child: _DirectRendererCard(
                  product: tile.product,
                  featured: tile.span >= columnCount,
                  featuredHeight: tileHeight,
                  onProductTap: onProductTap,
                  onAddToCart: onAddToCart,
                ),
              ),
              if (rowHeight > tileHeight)
                SizedBox(height: rowHeight - tileHeight),
            ],
          ),
        ),
      );
    }

    final occupiedColumns = row.tiles.fold<int>(
      0,
      (previous, tile) => previous + tile.span,
    );

    if (occupiedColumns < columnCount) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: columnGap));
      }
      children.add(const Expanded(child: SizedBox.shrink()));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  double _tileWidthForSpan({
    required int span,
    required double unitWidth,
    required double columnGap,
  }) {
    return (unitWidth * span) + (columnGap * (span - 1));
  }

  int _columnCountForWidth(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  double _gapForColumns(int columnCount) {
    if (columnCount >= 4) return 16;
    if (columnCount == 3) return 14;
    return 12;
  }

  int _spanForProduct({
    required MBProduct product,
    required int columnCount,
  }) {
    if (_isFullWidthProduct(product)) {
      return columnCount;
    }

    if (_isLargeWidthProduct(product) && columnCount >= 3) {
      return math.min(2, columnCount);
    }

    return 1;
  }

  bool _isFullWidthProduct(MBProduct product) {
    if (product.hasCardDesignJson) {
      final metrics = _SavedDesignLayoutMetrics.fromJson(
        product.cardDesignJson,
      );
      return metrics.isFullWidth;
    }

    final config = product.effectiveCardConfig.normalized();
    return config.variant.isFullWidth;
  }

  bool _isLargeWidthProduct(MBProduct product) {
    if (!product.hasCardDesignJson) {
      return false;
    }

    final metrics = _SavedDesignLayoutMetrics.fromJson(
      product.cardDesignJson,
    );

    return metrics.isLargeWidth;
  }
}

class _DirectRendererCard extends StatelessWidget {
  const _DirectRendererCard({
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
    required this.savedCardHeight,
    required this.cardLayoutType,
    required this.footprint,
    required this.span,
  });

  final double savedCardWidth;
  final double savedCardHeight;
  final String cardLayoutType;
  final String footprint;
  final int? span;

  bool get isFullWidth {
    if (span != null && span! >= 99) return true;

    final value = '$cardLayoutType $footprint'.toLowerCase();

    if (footprint == 'full' ||
        footprint == 'full_width' ||
        footprint == 'wide') {
      return true;
    }

    if (value.contains('full_width') ||
        value.contains('full-width') ||
        value.contains('feature_full') ||
        value.contains('feature-full') ||
        value.contains('wide') ||
        value.contains('banner') ||
        value.contains('horizontal')) {
      return true;
    }

    // Important for V3 JSON: full-width cards normally have a design base
    // width around 392 px. Half cards are usually around 185/192 px.
    return savedCardWidth >= 300;
  }

  bool get isLargeWidth {
    final value = '$cardLayoutType $footprint'.toLowerCase();

    if (span != null && span! >= 2 && span! < 99) return true;

    if (footprint == 'large' ||
        footprint == 'double' ||
        footprint == 'two_col' ||
        footprint == 'two_column') {
      return true;
    }

    if (value.contains('large') ||
        value.contains('double') ||
        value.contains('two_col') ||
        value.contains('two-column')) {
      return true;
    }

    return savedCardWidth >= 260 && savedCardWidth < 300;
  }

  factory _SavedDesignLayoutMetrics.fromJson(String? rawJson) {
    final root = _readRootMap(rawJson);
    final layout = _readStringMap(root['layout']);
    final metadata = _readStringMap(root['metadata']);

    final savedCardWidth = _readDouble(
      layout['cardWidth'],
      fallback: 185,
    ).clamp(80, 900).toDouble();

    final savedCardHeight = _readDouble(
      layout['cardHeight'],
      fallback: 255,
    ).clamp(80, 1200).toDouble();

    final cardLayoutType = _firstNotEmpty(<Object?>[
      layout['cardLayoutType'],
      metadata['cardLayoutType'],
      root['templateId'],
      root['cardLayoutType'],
    ]);

    final footprint = _firstNotEmpty(<Object?>[
      layout['footprint'],
      layout['gridFootprint'],
      metadata['footprint'],
      metadata['gridFootprint'],
      root['footprint'],
      root['gridFootprint'],
    ]).toLowerCase();

    final span = _readNullableInt(
      layout['span'] ??
          layout['gridSpan'] ??
          metadata['span'] ??
          metadata['gridSpan'] ??
          root['span'] ??
          root['gridSpan'],
    );

    return _SavedDesignLayoutMetrics(
      savedCardWidth: savedCardWidth,
      savedCardHeight: savedCardHeight,
      cardLayoutType: cardLayoutType,
      footprint: footprint,
      span: span,
    );
  }

  double heightForWidth(double runtimeWidth) {
    final safeWidth = runtimeWidth.clamp(80, 1600).toDouble();
    final scale = safeWidth / savedCardWidth;
    final rawHeight = savedCardHeight * scale;

    return rawHeight.clamp(80, 1200).toDouble();
  }

  static Map<String, dynamic> _readRootMap(String? rawJson) {
    final source = rawJson?.trim();
    if (source == null || source.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }

      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  static Map<String, dynamic> _readStringMap(Object? source) {
    if (source is Map<String, dynamic>) {
      return Map<String, dynamic>.from(source);
    }

    if (source is Map) {
      return source.map(
        (key, value) => MapEntry(key.toString(), value),
      );
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

  static int? _readNullableInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();

    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) return null;
    if (normalized.toLowerCase() == 'full') return 99;

    return int.tryParse(normalized);
  }

  static String _firstNotEmpty(List<Object?> values) {
    for (final value in values) {
      final normalized = value?.toString().trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return '';
  }
}

class _ProductGridRow {
  const _ProductGridRow(this.tiles);

  final List<_ProductGridTile> tiles;
}

class _ProductGridTile {
  const _ProductGridTile({
    required this.product,
    required this.span,
  });

  final MBProduct product;
  final int span;
}

