import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';

// MB Home Product Grid Section
// ----------------------------
// Product-card-aware home grid section.
//
// Rules:
// 1. Products are shuffled once when this section receives a fresh product list.
//    This gives a different visual order after refresh/reload without changing
//    order on every normal rebuild.
// 2. Half-width cards are rendered two per row.
// 3. Full-width cards render as full rows.
// 4. If a full-width card appears while only one half-width card is pending,
//    the full-width card is temporarily held until another half-width card is
//    found. This avoids an empty half-cell/gap before the full-width card.
// 5. If the section ends with one half-width card and one or more held
//    full-width cards, the full-width cards render first, then the final single
//    half-width card. This matches the agreed rule and prevents a gap above a
//    full-width card.
//
// Important:
// Do not replace this with MBProductCard. MBProductCard only receives text/image
// values and cannot read product.cardConfig/effectiveCardConfig.

class MBHomeProductGridSection extends StatefulWidget {
  final MBHomeSection section;
  final List<MBProduct> products;
  final List<MBOffer> offers;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;
  final VoidCallback? onViewAllTap;

  const MBHomeProductGridSection({
    super.key,
    required this.section,
    required this.products,
    this.offers = const <MBOffer>[],
    this.onProductTap,
    this.onAddToCart,
    this.onViewAllTap,
  });

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

    // Shuffle only when the parent supplies a new product list or the product
    // composition changed. This prevents random order jumping during ordinary
    // build/setState calls.
    final shouldRefreshOrder =
        !identical(_lastProductsRef, widget.products) ||
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
        product.updatedAt?.toIso8601String() ?? '',
        product.cardLayoutType,
        config.familyId,
        config.variantId,
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
        _ProductCardFlow(
          products: _orderedProducts,
          onProductTap: widget.onProductTap,
          onAddToCart: widget.onAddToCart,
        ),
      ],
    );
  }
}

class _ProductCardFlow extends StatelessWidget {
  const _ProductCardFlow({
    required this.products,
    this.onProductTap,
    this.onAddToCart,
  });

  final List<MBProduct> products;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final gap = MBSpacing.sm;
    final rows = _buildGaplessRows();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          _buildRow(
            context: context,
            row: rows[index],
            gap: gap,
          ),
          if (index != rows.length - 1) SizedBox(height: gap),
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

      // A pair is complete now, so any full-width cards that were waiting
      // behind a single pending half card can safely render after this row.
      flushHeldFullWidthCards();
    }

    void addFullWidthProduct(MBProduct product) {
      if (pendingHalf == null) {
        rows.add(_ProductCardRow.full(product));
        return;
      }

      // Do not render full-width immediately, because that would leave one
      // half-width card alone above it. Hold it until another half-width card
      // arrives. If no half card arrives before the end, it will render before
      // the final single half card.
      heldFullWidthCards.add(product);
    }

    for (final product in products) {
      if (_isFullWidthProduct(product)) {
        addFullWidthProduct(product);
      } else {
        addHalfProduct(product);
      }
    }

    // End condition:
    // If one half-width card and full-width card(s) remain, render full-width
    // first, then the single half card. This avoids a gap directly above a
    // full-width card.
    if (pendingHalf != null && heldFullWidthCards.isNotEmpty) {
      flushHeldFullWidthCards();

      rows.add(
        _ProductCardRow.half(
          first: pendingHalf!,
          second: null,
        ),
      );

      pendingHalf = null;
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
    required BuildContext context,
    required _ProductCardRow row,
    required double gap,
  }) {
    final fullWidthProduct = row.fullWidthProduct;

    if (fullWidthProduct != null) {
      return MBProductCardRenderer(
        product: fullWidthProduct,
        contextType: MBProductCardRenderContext.featured,
        featuredHeight: _fullWidthHeightForProduct(fullWidthProduct),
        onTap: () => onProductTap?.call(fullWidthProduct),
        onAddToCartTap: () => onAddToCart?.call(fullWidthProduct),
      );
    }

    final first = row.firstHalfProduct;
    final second = row.secondHalfProduct;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: MBProductCardRenderer(
            product: first,
            contextType: MBProductCardRenderContext.grid,
            onTap: () => onProductTap?.call(first),
            onAddToCartTap: () => onAddToCart?.call(first),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: second == null
              ? const SizedBox.shrink()
              : MBProductCardRenderer(
            product: second,
            contextType: MBProductCardRenderContext.grid,
            onTap: () => onProductTap?.call(second),
            onAddToCartTap: () => onAddToCart?.call(second),
          ),
        ),
      ],
    );
  }

  bool _isFullWidthProduct(MBProduct product) {
    final config = product.effectiveCardConfig.normalized();
    return config.variant.isFullWidth;
  }

  double _fullWidthHeightForProduct(MBProduct product) {
    final config = product.effectiveCardConfig.normalized();
    final familyId = config.familyId;
    final variantId = config.variantId;

    if (familyId == 'horizontal' || variantId.startsWith('horizontal')) {
      return 150;
    }

    if (familyId == 'wide' || variantId.startsWith('wide')) {
      return 255;
    }

    if (familyId == 'promo' || variantId.startsWith('promo')) {
      return 280;
    }

    if (familyId == 'featured' || variantId.startsWith('featured')) {
      return 320;
    }

    return 240;
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
