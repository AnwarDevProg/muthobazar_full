import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';

import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_layout_resolver.dart';

import 'package:shared_ui/widgets/common/product_cards/system/mb_responsive_card_grid_resolver.dart';
// MB Home Product Grid Section
// ----------------------------
// Patch 11.9: Adaptive gap filler widgets.
//
// Layout rules:
// - Shuffle products once when a fresh product list arrives.
// - Responsive columns: phone = 2, small tablet = 3, tablet = 4.
// - V3 cardDesignJson is rendered through MBProductCardRenderer only.
// - Half-width cards fill completed rows before held full-width rows render.
// - Full-width cards span the complete row.
// - For each completed half row, shorter cards keep their preferred height and
//   the remaining row gap is filled with an adaptive filler when possible.
// - Fillers are selected by safe height range + priority + fit quality.
// - Very small gaps become decorative spacers; no product card height is
//   distorted in this first adaptive-filler implementation.

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
    final columnCount = _resolveColumnCount(maxWidth);
    final columnGap = _resolveColumnGap(maxWidth);
    final rowGap = _resolveRowGap(maxWidth);
    final tileWidth = _resolveTileWidth(
      maxWidth: maxWidth,
      columnCount: columnCount,
      columnGap: columnGap,
    );

    final rows = _buildHybridRows(columnCount: columnCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < rows.length; index++) ...<Widget>[
          _buildRow(
            row: rows[index],
            columnCount: columnCount,
            columnGap: columnGap,
            tileWidth: tileWidth,
            fullWidth: maxWidth,
          ),
          if (index != rows.length - 1) SizedBox(height: rowGap),
        ],
      ],
    );
  }

  List<_ProductCardRow> _buildHybridRows({required int columnCount}) {
    final rows = <_ProductCardRow>[];
    final pendingHalf = <MBProduct>[];
    final heldFullWidthCards = <MBProduct>[];

    void flushPendingHalfRowIfComplete() {
      if (pendingHalf.length < columnCount) return;
      rows.add(_ProductCardRow.half(List<MBProduct>.of(pendingHalf)));
      pendingHalf.clear();

      if (heldFullWidthCards.isNotEmpty) {
        for (final product in heldFullWidthCards) {
          rows.add(_ProductCardRow.full(product));
        }
        heldFullWidthCards.clear();
      }
    }

    void addHalfProduct(MBProduct product) {
      pendingHalf.add(product);
      flushPendingHalfRowIfComplete();
    }

    void addFullWidthProduct(MBProduct product) {
      if (pendingHalf.isEmpty) {
        rows.add(_ProductCardRow.full(product));
        return;
      }

      // Hybrid row-pack rule:
      // do not let a full-width card break an unfinished half-card row.
      heldFullWidthCards.add(product);
    }

    for (final product in products) {
      final footprint = _ProductFootprintResolver.resolve(product);
      if (footprint.isFullWidth) {
        addFullWidthProduct(product);
      } else {
        addHalfProduct(product);
      }
    }

    // If the list ends while a half row is incomplete and one or more full-width
    // rows are waiting, render held full-width cards first, then the final
    // partial half row. This follows the agreed hybrid row-pack rule.
    if (pendingHalf.isNotEmpty && heldFullWidthCards.isNotEmpty) {
      for (final product in heldFullWidthCards) {
        rows.add(_ProductCardRow.full(product));
      }
      heldFullWidthCards.clear();
    }

    if (pendingHalf.isNotEmpty) {
      rows.add(_ProductCardRow.half(List<MBProduct>.of(pendingHalf)));
      pendingHalf.clear();
    }

    if (heldFullWidthCards.isNotEmpty) {
      for (final product in heldFullWidthCards) {
        rows.add(_ProductCardRow.full(product));
      }
      heldFullWidthCards.clear();
    }

    return rows;
  }

  Widget _buildRow({
    required _ProductCardRow row,
    required int columnCount,
    required double columnGap,
    required double tileWidth,
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
        child: _RuntimeProductCard(
          product: fullWidthProduct,
          featured: true,
          featuredHeight: height,
          onProductTap: onProductTap,
          onAddToCart: onAddToCart,
        ),
      );
    }

    return _HalfWidthRow(
      products: row.halfProducts,
      columnCount: columnCount,
      columnGap: columnGap,
      tileWidth: tileWidth,
      onProductTap: onProductTap,
      onAddToCart: onAddToCart,
    );
  }

  static int _resolveColumnCount(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  static double _resolveColumnGap(double width) {
    if (width >= 900) return 16;
    if (width >= 600) return 14;
    return 12;
  }

  static double _resolveRowGap(double width) {
    if (width >= 900) return 18;
    if (width >= 600) return 16;
    return 14;
  }

  static double _resolveTileWidth({
    required double maxWidth,
    required int columnCount,
    required double columnGap,
  }) {
    final gapTotal = columnGap * (columnCount - 1);
    return ((maxWidth - gapTotal) / columnCount)
        .clamp(96.0, maxWidth)
        .toDouble();
  }
}

class _HalfWidthRow extends StatelessWidget {
  const _HalfWidthRow({
    required this.products,
    required this.columnCount,
    required this.columnGap,
    required this.tileWidth,
    this.onProductTap,
    this.onAddToCart,
  });

  final List<MBProduct> products;
  final int columnCount;
  final double columnGap;
  final double tileWidth;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final cardHeights = <MBProduct, double>{
      for (final product in products)
        product: _CardRuntimeHeightResolver.heightForProduct(
          product: product,
          width: tileWidth,
        ),
    };

    final rowHeight = cardHeights.values.fold<double>(
      0,
      (previous, current) => math.max(previous, current),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var index = 0; index < columnCount; index++) ...<Widget>[
          Expanded(
            child: index < products.length
                ? _HalfCardSlot(
                    product: products[index],
                    cardHeight: cardHeights[products[index]] ?? rowHeight,
                    rowHeight: rowHeight,
                    slotIndex: index,
                    onProductTap: onProductTap,
                    onAddToCart: onAddToCart,
                  )
                : const SizedBox.shrink(),
          ),
          if (index != columnCount - 1) SizedBox(width: columnGap),
        ],
      ],
    );
  }
}

class _HalfCardSlot extends StatelessWidget {
  const _HalfCardSlot({
    required this.product,
    required this.cardHeight,
    required this.rowHeight,
    required this.slotIndex,
    this.onProductTap,
    this.onAddToCart,
  });

  final MBProduct product;
  final double cardHeight;
  final double rowHeight;
  final int slotIndex;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final gapHeight = math.max(0.0, rowHeight - cardHeight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: cardHeight,
          child: _RuntimeProductCard(
            product: product,
            onProductTap: onProductTap,
            onAddToCart: onAddToCart,
          ),
        ),
        if (gapHeight > 0)
          _AdaptiveGapFillerHost(
            product: product,
            gapHeight: gapHeight,
            slotIndex: slotIndex,
          ),
      ],
    );
  }
}

class _AdaptiveGapFillerHost extends StatelessWidget {
  const _AdaptiveGapFillerHost({
    required this.product,
    required this.gapHeight,
    required this.slotIndex,
  });

  final MBProduct product;
  final double gapHeight;
  final int slotIndex;

  @override
  Widget build(BuildContext context) {
    final gap = gapHeight.clamp(0.0, 400.0).toDouble();
    if (gap < 8) return SizedBox(height: gap);

    final filler = _GapFillerResolver.resolve(
      product: product,
      gapHeight: gap,
      slotIndex: slotIndex,
    );

    if (filler == null) {
      return SizedBox(
        height: gap,
        child: _DecorativeGapStrip(height: gap),
      );
    }

    return SizedBox(
      height: gap,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _GapFillerWidget(
          definition: filler,
          product: product,
          actualHeight: math.max(0, gap - 8).toDouble(),
        ),
      ),
    );
  }
}

class _GapFillerWidget extends StatelessWidget {
  const _GapFillerWidget({
    required this.definition,
    required this.product,
    required this.actualHeight,
  });

  final _GapFillerDefinition definition;
  final MBProduct product;
  final double actualHeight;

  @override
  Widget build(BuildContext context) {
    final height = actualHeight.clamp(0.0, 300.0).toDouble();
    if (height < 12) return _DecorativeGapStrip(height: height);

    switch (definition.kind) {
      case _GapFillerKind.decorative:
        return _DecorativeGapStrip(height: height);
      case _GapFillerKind.micro:
        return _MicroGapFiller(height: height, definition: definition);
      case _GapFillerKind.delivery:
        return _DeliveryGapFiller(height: height, definition: definition);
      case _GapFillerKind.offer:
        return _OfferGapFiller(height: height, definition: definition);
      case _GapFillerKind.category:
        return _CategoryGapFiller(
          height: height,
          definition: definition,
          product: product,
        );
    }
  }
}

class _DecorativeGapStrip extends StatelessWidget {
  const _DecorativeGapStrip({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    if (height <= 0) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: height.clamp(4.0, 24.0).toDouble(),
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: <Color>[
              const Color(0xFFFF6500).withValues(alpha: 0.12),
              const Color(0xFFFF9A3D).withValues(alpha: 0.04),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicroGapFiller extends StatelessWidget {
  const _MicroGapFiller({required this.height, required this.definition});

  final double height;
  final _GapFillerDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFFD8BE).withValues(alpha: 0.75),
        ),
      ),
      child: Text(
        definition.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: const Color(0xFFFF6500),
          fontSize: height < 32 ? 9 : 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DeliveryGapFiller extends StatelessWidget {
  const _DeliveryGapFiller({required this.height, required this.definition});

  final double height;
  final _GapFillerDefinition definition;

  @override
  Widget build(BuildContext context) {
    return _RoundedFillerSurface(
      height: height,
      background: const Color(0xFFEAF3FF),
      foreground: const Color(0xFF1463C2),
      icon: Icons.local_shipping_rounded,
      title: definition.label,
      subtitle: height >= 62 ? 'Fast delivery available' : null,
    );
  }
}

class _OfferGapFiller extends StatelessWidget {
  const _OfferGapFiller({required this.height, required this.definition});

  final double height;
  final _GapFillerDefinition definition;

  @override
  Widget build(BuildContext context) {
    return _RoundedFillerSurface(
      height: height,
      background: const Color(0xFFFFF4EC),
      foreground: const Color(0xFFFF6500),
      icon: Icons.local_offer_rounded,
      title: definition.label,
      subtitle: height >= 70 ? 'Limited time deal' : null,
    );
  }
}

class _CategoryGapFiller extends StatelessWidget {
  const _CategoryGapFiller({
    required this.height,
    required this.definition,
    required this.product,
  });

  final double height;
  final _GapFillerDefinition definition;
  final MBProduct product;

  @override
  Widget build(BuildContext context) {
    final category = _tryReadString(
      () => (product as dynamic).categoryNameEn,
      fallback: 'Fresh picks',
    );

    return _RoundedFillerSurface(
      height: height,
      background: const Color(0xFFEAFBF0),
      foreground: const Color(0xFF12803B),
      icon: Icons.eco_rounded,
      title: category.isEmpty ? definition.label : category,
      subtitle: height >= 86 ? 'More from this category' : null,
    );
  }
}

class _RoundedFillerSurface extends StatelessWidget {
  const _RoundedFillerSurface({
    required this.height,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final double height;
  final Color background;
  final Color foreground;
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final compact = height < 58;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(height < 54 ? 999 : 18),
        border: Border.all(color: foreground.withValues(alpha: 0.14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: foreground.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: compact ? 22 : 28,
            height: compact ? 22 : 28,
            decoration: BoxDecoration(
              color: foreground.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: foreground, size: compact ? 13 : 16),
          ),
          SizedBox(width: compact ? 6 : 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: compact ? 10 : 11.5,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                if (subtitle != null && !compact) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground.withValues(alpha: 0.72),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RuntimeProductCard extends StatelessWidget {
  const _RuntimeProductCard({
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
    final v3Metrics = _V3DesignLayoutMetrics.tryParse(product.cardDesignJson);
    if (v3Metrics != null) {
      return v3Metrics.heightForWidth(width);
    }

    final profile = MBProductCardLayoutResolver.resolve(
      product: product,
      availableWidth: width,
    );

    return profile.preferredHeight;
  }
}

class _V3DesignLayoutMetrics {
  const _V3DesignLayoutMetrics({
    required this.cardWidth,
    required this.cardHeight,
    required this.layoutType,
    required this.footprint,
  });

  final double cardWidth;
  final double cardHeight;
  final String layoutType;
  final String footprint;

  double get aspectRatio => cardWidth <= 0 ? 0.72 : cardWidth / cardHeight;

  double heightForWidth(double runtimeWidth) {
    final safeWidth = runtimeWidth.clamp(80.0, 1200.0).toDouble();
    final rawHeight = safeWidth / aspectRatio.clamp(0.25, 4.0);
    return rawHeight.clamp(90.0, 1200.0).toDouble();
  }

  bool get isFullWidth {
    final normalizedFootprint = footprint.trim().toLowerCase();
    final normalizedLayout = layoutType.trim().toLowerCase();

    if (normalizedFootprint == 'full' ||
        normalizedFootprint == 'full_width' ||
        normalizedFootprint == 'wide' ||
        normalizedFootprint == 'banner' ||
        normalizedFootprint == 'hero') {
      return true;
    }

    if (normalizedLayout.contains('full') ||
        normalizedLayout.contains('wide') ||
        normalizedLayout.contains('banner') ||
        normalizedLayout.contains('horizontal') ||
        normalizedLayout.contains('feature')) {
      return true;
    }

    return cardWidth >= 300;
  }

  static _V3DesignLayoutMetrics? tryParse(String? rawJson) {
    final source = rawJson?.trim();
    if (source == null || source.isEmpty) return null;

    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) return null;
      final root = _stringKeyedMap(decoded);
      final layout = _stringKeyedMap(root['layout']);
      final metadata = _stringKeyedMap(root['metadata']);

      final cardWidth = _readDouble(layout['cardWidth'], fallback: 185)
          .clamp(80.0, 900.0)
          .toDouble();
      final cardHeight = _readDouble(layout['cardHeight'], fallback: 255)
          .clamp(80.0, 1200.0)
          .toDouble();
      final layoutType = _firstNonEmptyString(<Object?>[
        layout['cardLayoutType'],
        metadata['cardLayoutType'],
        root['templateId'],
      ]);
      final footprint = _firstNonEmptyString(<Object?>[
        layout['footprint'],
        metadata['footprint'],
        root['footprint'],
      ]);

      return _V3DesignLayoutMetrics(
        cardWidth: cardWidth,
        cardHeight: cardHeight,
        layoutType: layoutType,
        footprint: footprint,
      );
    } catch (_) {
      return null;
    }
  }
}

class _ProductFootprintResolver {
  const _ProductFootprintResolver._();

  static _ProductFootprint resolve(MBProduct product) {
    final v3Metrics = _V3DesignLayoutMetrics.tryParse(product.cardDesignJson);
    if (v3Metrics != null) {
      return v3Metrics.isFullWidth
          ? _ProductFootprint.full
          : _ProductFootprint.half;
    }

    final config = product.effectiveCardConfig.normalized();
    return config.variant.isFullWidth
        ? _ProductFootprint.full
        : _ProductFootprint.half;
  }
}

class _ProductFootprint {
  const _ProductFootprint._({required this.columnSpan});

  static const _ProductFootprint half = _ProductFootprint._(columnSpan: 1);
  static const _ProductFootprint full = _ProductFootprint._(columnSpan: 999);

  final int columnSpan;

  bool get isFullWidth => columnSpan >= 999;
}

class _ProductCardRow {
  const _ProductCardRow._({
    required this.halfProducts,
    this.fullWidthProduct,
  });

  factory _ProductCardRow.half(List<MBProduct> products) {
    return _ProductCardRow._(
      halfProducts: List<MBProduct>.of(products, growable: false),
    );
  }

  factory _ProductCardRow.full(MBProduct product) {
    return _ProductCardRow._(
      halfProducts: const <MBProduct>[],
      fullWidthProduct: product,
    );
  }

  final List<MBProduct> halfProducts;
  final MBProduct? fullWidthProduct;
}

enum _GapFillerKind {
  decorative,
  micro,
  delivery,
  offer,
  category,
}

class _GapFillerDefinition {
  const _GapFillerDefinition({
    required this.id,
    required this.kind,
    required this.label,
    required this.preferredHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.priority,
    this.isDecorativeOnly = false,
    this.isTappable = false,
  });

  final String id;
  final _GapFillerKind kind;
  final String label;
  final double preferredHeight;
  final double minHeight;
  final double maxHeight;
  final int priority;
  final bool isDecorativeOnly;
  final bool isTappable;

  bool canFit(double height) => minHeight <= height && height <= maxHeight;

  double scoreFor(double height) {
    final resizeDistance = (preferredHeight - height).abs();
    final resizeRatio = preferredHeight <= 0 ? 1.0 : resizeDistance / preferredHeight;
    final tapPenalty = isTappable && height < 44 ? 600 : 0;
    final decorativePenalty = isDecorativeOnly ? 250 : 0;
    return (priority * 1000) +
        (resizeDistance * 6) +
        (resizeRatio * 120) +
        tapPenalty +
        decorativePenalty;
  }
}

class _GapFillerResolver {
  const _GapFillerResolver._();

  static const List<_GapFillerDefinition> _definitions = <_GapFillerDefinition>[
    _GapFillerDefinition(
      id: 'decorative_line',
      kind: _GapFillerKind.decorative,
      label: '',
      preferredHeight: 16,
      minHeight: 8,
      maxHeight: 28,
      priority: 4,
      isDecorativeOnly: true,
    ),
    _GapFillerDefinition(
      id: 'micro_flash',
      kind: _GapFillerKind.micro,
      label: 'Fresh deal',
      preferredHeight: 36,
      minHeight: 26,
      maxHeight: 43,
      priority: 3,
      isDecorativeOnly: true,
    ),
    _GapFillerDefinition(
      id: 'delivery_chip',
      kind: _GapFillerKind.delivery,
      label: 'Fast delivery',
      preferredHeight: 56,
      minHeight: 44,
      maxHeight: 66,
      priority: 2,
      isTappable: true,
    ),
    _GapFillerDefinition(
      id: 'offer_chip',
      kind: _GapFillerKind.offer,
      label: 'Save more today',
      preferredHeight: 76,
      minHeight: 62,
      maxHeight: 92,
      priority: 1,
      isTappable: true,
    ),
    _GapFillerDefinition(
      id: 'category_chip',
      kind: _GapFillerKind.category,
      label: 'More fresh picks',
      preferredHeight: 104,
      minHeight: 86,
      maxHeight: 128,
      priority: 3,
      isTappable: true,
    ),
  ];

  static _GapFillerDefinition? resolve({
    required MBProduct product,
    required double gapHeight,
    required int slotIndex,
  }) {
    final usableHeight = math.max(0.0, gapHeight - 8);
    if (usableHeight < 8) return null;

    final candidates = _definitions
        .where((definition) => definition.canFit(usableHeight))
        .toList(growable: false);

    if (candidates.isEmpty) {
      if (usableHeight <= 28) return _definitions.first;
      return null;
    }

    candidates.sort((a, b) {
      final scoreA = a.scoreFor(usableHeight);
      final scoreB = b.scoreFor(usableHeight);
      final scoreCompare = scoreA.compareTo(scoreB);
      if (scoreCompare != 0) return scoreCompare;
      return a.id.compareTo(b.id);
    });

    return candidates.first;
  }
}

Map<String, dynamic> _stringKeyedMap(Object? source) {
  if (source is Map<String, dynamic>) return Map<String, dynamic>.from(source);
  if (source is Map) {
    return source.map<String, dynamic>(
      (key, value) => MapEntry<String, dynamic>(key.toString(), value),
    );
  }
  return <String, dynamic>{};
}

double _readDouble(Object? value, {required double fallback}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

String _firstNonEmptyString(List<Object?> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return '';
}

String _tryReadString(Object? Function() reader, {String fallback = ''}) {
  try {
    final value = reader();
    return value?.toString().trim() ?? fallback;
  } catch (_) {
    return fallback;
  }
}


