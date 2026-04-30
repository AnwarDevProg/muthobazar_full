import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_layout_resolver.dart';

// MB Home Product Grid Section
// ----------------------------
// Patch 11.6: responsive 2/3/4-column Home grid + footprint span system.
//
// Rules:
// - Shuffle products once when a fresh product list arrives.
// - Phone/small content widths use 2 columns.
// - Tablet/wider content widths use 3 or 4 columns based on target slot width.
// - V3 cardDesignJson is treated as a design-base size, not a fixed screen size.
// - Half-width V3 cards span 1 column.
// - Full-width V3 cards span all columns.
// - Future large/double V3 cards can span 2 columns via layout.span,
//   metadata.span, footprint/double/large values.
// - V3 half cards are capped near their designed base scale on large screens,
//   so tablets add columns instead of making cards oversized.
// - Products without V3 JSON continue to use the legacy renderer fallback.

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
      _orderedProducts.shuffle(
        math.Random(DateTime.now().microsecondsSinceEpoch),
      );
    }
  }

  String _signatureFor(List<MBProduct> products) {
    return products.map((product) {
      final config = product.effectiveCardConfig.normalized();
      return <Object?>[
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
      children: <Widget>[
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

            return _ResponsiveProductCardGrid(
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

class _ResponsiveProductCardGrid extends StatelessWidget {
  const _ResponsiveProductCardGrid({
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
    final columns = _HomeGridPolicy.columnCountForWidth(maxWidth);
    final gap = _HomeGridPolicy.gapForColumns(columns);
    final columnWidth =
        ((maxWidth - (gap * (columns - 1))) / columns).clamp(80.0, maxWidth);
    final rows = _buildRows(columns: columns);

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...<Widget>[
          _ResponsiveProductCardRow(
            row: rows[rowIndex],
            columns: columns,
            columnWidth: columnWidth.toDouble(),
            gap: gap,
            onProductTap: onProductTap,
            onAddToCart: onAddToCart,
          ),
          if (rowIndex != rows.length - 1)
            SizedBox(height: _HomeGridPolicy.rowGapForColumns(columns)),
        ],
      ],
    );
  }

  List<List<_ProductGridTile>> _buildRows({required int columns}) {
    final rows = <List<_ProductGridTile>>[];
    var currentRow = <_ProductGridTile>[];
    var usedSpan = 0;

    void flushRow() {
      if (currentRow.isEmpty) return;
      rows.add(currentRow);
      currentRow = <_ProductGridTile>[];
      usedSpan = 0;
    }

    for (final product in products) {
      final span = _ProductGridTile.resolveSpan(
        product: product,
        columns: columns,
      );

      if (span >= columns) {
        flushRow();
        rows.add(<_ProductGridTile>[
          _ProductGridTile(product: product, span: columns),
        ]);
        continue;
      }

      if (usedSpan + span > columns) {
        flushRow();
      }

      currentRow.add(_ProductGridTile(product: product, span: span));
      usedSpan += span;

      if (usedSpan >= columns) {
        flushRow();
      }
    }

    flushRow();
    return rows;
  }
}

class _ResponsiveProductCardRow extends StatelessWidget {
  const _ResponsiveProductCardRow({
    required this.row,
    required this.columns,
    required this.columnWidth,
    required this.gap,
    this.onProductTap,
    this.onAddToCart,
  });

  final List<_ProductGridTile> row;
  final int columns;
  final double columnWidth;
  final double gap;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final usedSpan = row.fold<int>(0, (total, tile) => total + tile.span);
    final emptySpan = math.max(0, columns - usedSpan);
    final children = <Widget>[];

    for (var index = 0; index < row.length; index++) {
      final tile = row[index];
      final tileWidth = _tileWidthForSpan(tile.span);

      children.add(
        _ResponsiveProductCardTile(
          product: tile.product,
          span: tile.span,
          columns: columns,
          tileWidth: tileWidth,
          onProductTap: onProductTap,
          onAddToCart: onAddToCart,
        ),
      );

      if (index != row.length - 1) {
        children.add(SizedBox(width: gap));
      }
    }

    if (emptySpan > 0) {
      final emptyWidth = _tileWidthForSpan(emptySpan);
      if (children.isNotEmpty) {
        children.add(SizedBox(width: gap));
      }
      children.add(SizedBox(width: emptyWidth));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  double _tileWidthForSpan(int span) {
    final safeSpan = span.clamp(1, columns);
    return (columnWidth * safeSpan) + (gap * (safeSpan - 1));
  }
}

class _ResponsiveProductCardTile extends StatelessWidget {
  const _ResponsiveProductCardTile({
    required this.product,
    required this.span,
    required this.columns,
    required this.tileWidth,
    this.onProductTap,
    this.onAddToCart,
  });

  final MBProduct product;
  final int span;
  final int columns;
  final double tileWidth;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final metrics = _V3DesignLayoutMetrics.tryParse(product.cardDesignJson);
    final isV3 = metrics != null;
    final isFullWidth = span >= columns;
    final visualWidth = isV3
        ? metrics.visualWidthForTile(
            tileWidth: tileWidth,
            span: span,
            columns: columns,
          )
        : tileWidth;
    final visualHeight = isV3
        ? metrics.heightForVisualWidth(visualWidth)
        : _legacyHeightForWidth(
            product: product,
            width: visualWidth,
            featured: isFullWidth,
          );

    final child = SizedBox(
      width: visualWidth,
      height: visualHeight,
      child: MBProductCardRenderer(
        product: product,
        contextType: isFullWidth
            ? MBProductCardRenderContext.featured
            : MBProductCardRenderContext.grid,
        featuredHeight: isFullWidth ? visualHeight : null,
        onTap: () => onProductTap?.call(product),
        onAddToCartTap: () => onAddToCart?.call(product),
      ),
    );

    return SizedBox(
      width: tileWidth,
      height: visualHeight,
      child: Align(
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }

  double _legacyHeightForWidth({
    required MBProduct product,
    required double width,
    required bool featured,
  }) {
    final profile = MBProductCardLayoutResolver.resolve(
      product: product,
      availableWidth: width,
    );

    return profile.preferredHeight;
  }
}

class _HomeGridPolicy {
  const _HomeGridPolicy._();

  static int columnCountForWidth(double contentWidth) {
    final safeWidth = contentWidth.clamp(240.0, 2000.0).toDouble();

    if (safeWidth < 600) {
      return 2;
    }

    // Keep the half-card visual slot around the ideal 170-210px range.
    // This means many 7-8 inch tablets will already use 4 columns instead of
    // inflating a 185px V3 design card into an oversized 2-column layout.
    return (safeWidth / 210.0).ceil().clamp(3, 4).toInt();
  }

  static double gapForColumns(int columns) {
    if (columns >= 4) return 16;
    if (columns == 3) return 14;
    return 12;
  }

  static double rowGapForColumns(int columns) {
    if (columns >= 4) return 18;
    if (columns == 3) return 16;
    return 14;
  }
}

class _ProductGridTile {
  const _ProductGridTile({
    required this.product,
    required this.span,
  });

  final MBProduct product;
  final int span;

  static int resolveSpan({
    required MBProduct product,
    required int columns,
  }) {
    final metrics = _V3DesignLayoutMetrics.tryParse(product.cardDesignJson);

    if (metrics != null) {
      return metrics.spanForColumns(columns);
    }

    final config = product.effectiveCardConfig.normalized();
    if (config.variant.isFullWidth) {
      return columns;
    }

    return 1;
  }
}

class _V3DesignLayoutMetrics {
  const _V3DesignLayoutMetrics({
    required this.cardWidth,
    required this.cardHeight,
    required this.footprint,
    required this.requestedSpan,
    required this.isFullWidth,
  });

  final double cardWidth;
  final double cardHeight;
  final String footprint;
  final int? requestedSpan;
  final bool isFullWidth;

  double get aspectRatio {
    if (cardHeight <= 0) return 185 / 255;
    return cardWidth / cardHeight;
  }

  int spanForColumns(int columns) {
    if (columns <= 1) return 1;
    if (isFullWidth) return columns;

    final directSpan = requestedSpan;
    if (directSpan != null && directSpan > 0) {
      return directSpan.clamp(1, columns);
    }

    switch (footprint) {
      case 'full':
      case 'wide':
      case 'banner':
      case 'feature':
      case 'featured':
      case 'full_width':
      case 'full-width':
        return columns;
      case 'large':
      case 'double':
      case 'double_width':
      case 'double-width':
      case 'two_column':
      case 'two-column':
      case '2x':
        return math.min(2, columns);
      case 'half':
      case 'compact':
      case '':
      default:
        return 1;
    }
  }

  double visualWidthForTile({
    required double tileWidth,
    required int span,
    required int columns,
  }) {
    final safeTileWidth = tileWidth.clamp(80.0, 1400.0).toDouble();

    if (isFullWidth || span >= columns || footprint == 'full') {
      return safeTileWidth;
    }

    final maxScale = span > 1 ? 1.18 : 1.12;
    final maxWidth = (cardWidth * maxScale).clamp(80.0, 1400.0).toDouble();

    return math.min(safeTileWidth, maxWidth);
  }

  double heightForVisualWidth(double visualWidth) {
    final safeWidth = visualWidth.clamp(60.0, 1400.0).toDouble();
    final safeAspect = aspectRatio.clamp(0.25, 4.0).toDouble();
    return safeWidth / safeAspect;
  }

  static _V3DesignLayoutMetrics? tryParse(String? rawJson) {
    final source = rawJson?.trim();
    if (source == null || source.isEmpty) return null;

    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) return null;

      final root = _asStringMap(decoded);
      if (root['type']?.toString().trim() !=
          'muthobazar_card_design_advanced_v2') {
        return null;
      }

      final layout = _asStringMap(root['layout']);
      final metadata = _asStringMap(root['metadata']);
      final nodes = root['nodes'];

      if (nodes is! List || nodes.isEmpty) return null;

      final cardWidth = _readDouble(
        layout['cardWidth'],
        fallback: 185,
      ).clamp(80.0, 900.0).toDouble();

      final cardHeight = _readDouble(
        layout['cardHeight'],
        fallback: 255,
      ).clamp(80.0, 1200.0).toDouble();

      final footprint = _firstNonEmptyString(<Object?>[
        layout['footprint'],
        layout['cardFootprint'],
        layout['layoutFootprint'],
        metadata['footprint'],
        metadata['cardFootprint'],
        root['footprint'],
      ]).toLowerCase();

      final requestedSpan = _firstInt(<Object?>[
        layout['span'],
        layout['columnSpan'],
        layout['gridSpan'],
        metadata['span'],
        metadata['columnSpan'],
        metadata['gridSpan'],
        root['span'],
      ]);

      final explicitFullWidth = _firstBool(<Object?>[
        layout['isFullWidth'],
        layout['fullWidth'],
        metadata['isFullWidth'],
        metadata['fullWidth'],
        root['isFullWidth'],
        root['fullWidth'],
      ]);

      final footprintIsFull = <String>{
        'full',
        'wide',
        'banner',
        'feature',
        'featured',
        'full_width',
        'full-width',
      }.contains(footprint);

      return _V3DesignLayoutMetrics(
        cardWidth: cardWidth,
        cardHeight: cardHeight,
        footprint: footprint,
        requestedSpan: requestedSpan,
        isFullWidth: explicitFullWidth == true || footprintIsFull,
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _asStringMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }

    if (value is Map) {
      return value.map<String, dynamic>(
        (key, val) => MapEntry<String, dynamic>(key.toString(), val),
      );
    }

    return <String, dynamic>{};
  }

  static double _readDouble(Object? value, {required double fallback}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
  }

  static String _firstNonEmptyString(List<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  static int? _firstInt(List<Object?> values) {
    for (final value in values) {
      if (value is int) return value;
      if (value is num) return value.round();
      final parsed = int.tryParse(value?.toString().trim() ?? '');
      if (parsed != null) return parsed;
    }

    return null;
  }

  static bool? _firstBool(List<Object?> values) {
    for (final value in values) {
      if (value is bool) return value;
      final text = value?.toString().trim().toLowerCase();
      if (text == 'true') return true;
      if (text == 'false') return false;
    }

    return null;
  }
}
