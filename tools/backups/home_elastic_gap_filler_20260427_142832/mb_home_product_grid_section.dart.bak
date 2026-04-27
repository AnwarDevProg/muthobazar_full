import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';

import 'gap_fillers/mb_home_card_layout_profile.dart';
import 'gap_fillers/mb_home_gap_filler_models.dart';
import 'gap_fillers/mb_home_gap_filler_resolver.dart';
import 'gap_fillers/mb_home_gap_filler_widget.dart';

// MB Home Product Grid Section
// ----------------------------
// Product-card-aware home grid with random order, full-width row cards,
// paired half-width cards, elastic height planning, and adaptive gap fillers.

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
        product.titleEn,
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
    required BuildContext context,
    required _ProductCardRow row,
    required double gap,
  }) {
    final fullWidthProduct = row.fullWidthProduct;

    if (fullWidthProduct != null) {
      return MBProductCardRenderer(
        product: fullWidthProduct,
        contextType: MBProductCardRenderContext.featured,
        featuredHeight:
            MBHomeCardLayoutProfile.resolve(fullWidthProduct).preferredHeight,
        onTap: () => onProductTap?.call(fullWidthProduct),
        onAddToCartTap: () => onAddToCart?.call(fullWidthProduct),
      );
    }

    return _HalfWidthPairRow(
      first: row.firstHalfProduct,
      second: row.secondHalfProduct,
      gap: gap,
      onProductTap: onProductTap,
      onAddToCart: onAddToCart,
    );
  }

  bool _isFullWidthProduct(MBProduct product) {
    return MBHomeCardLayoutProfile.resolve(product).isFullWidth;
  }
}

class _HalfWidthPairRow extends StatelessWidget {
  const _HalfWidthPairRow({
    required this.first,
    required this.second,
    required this.gap,
    this.onProductTap,
    this.onAddToCart,
  });

  final MBProduct first;
  final MBProduct? second;
  final double gap;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (second == null) {
      final profile = MBHomeCardLayoutProfile.resolve(first);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: profile.preferredHeight,
              child: _card(first),
            ),
          ),
          SizedBox(width: gap),
          const Expanded(child: SizedBox.shrink()),
        ],
      );
    }

    final plan = _HalfPairPlan.resolve(first: first, second: second!);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _HalfCardSlot(
            product: first,
            cardHeight: plan.firstCardHeight,
            filler: plan.firstFiller,
            onProductTap: onProductTap,
            onAddToCart: onAddToCart,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _HalfCardSlot(
            product: second!,
            cardHeight: plan.secondCardHeight,
            filler: plan.secondFiller,
            onProductTap: onProductTap,
            onAddToCart: onAddToCart,
          ),
        ),
      ],
    );
  }

  Widget _card(MBProduct product) {
    return MBProductCardRenderer(
      product: product,
      contextType: MBProductCardRenderContext.grid,
      onTap: () => onProductTap?.call(product),
      onAddToCartTap: () => onAddToCart?.call(product),
    );
  }
}

class _HalfCardSlot extends StatelessWidget {
  const _HalfCardSlot({
    required this.product,
    required this.cardHeight,
    required this.filler,
    this.onProductTap,
    this.onAddToCart,
  });

  final MBProduct product;
  final double cardHeight;
  final MBHomeGapFillerDecision? filler;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: MBProductCardRenderer(
            product: product,
            contextType: MBProductCardRenderContext.grid,
            onTap: () => onProductTap?.call(product),
            onAddToCartTap: () => onAddToCart?.call(product),
          ),
        ),
        if (filler != null)
          MBHomeGapFillerWidget(
            decision: filler!,
          ),
      ],
    );
  }
}

class _HalfPairPlan {
  const _HalfPairPlan({
    required this.firstCardHeight,
    required this.secondCardHeight,
    this.firstFiller,
    this.secondFiller,
  });

  final double firstCardHeight;
  final double secondCardHeight;
  final MBHomeGapFillerDecision? firstFiller;
  final MBHomeGapFillerDecision? secondFiller;

  static _HalfPairPlan resolve({
    required MBProduct first,
    required MBProduct second,
  }) {
    final firstProfile = MBHomeCardLayoutProfile.resolve(first);
    final secondProfile = MBHomeCardLayoutProfile.resolve(second);

    final firstPreferred = firstProfile.preferredHeight;
    final secondPreferred = secondProfile.preferredHeight;

    if ((firstPreferred - secondPreferred).abs() < 1) {
      return _HalfPairPlan(
        firstCardHeight: firstPreferred,
        secondCardHeight: secondPreferred,
      );
    }

    final firstIsShorter = firstPreferred < secondPreferred;
    final shortProfile = firstIsShorter ? firstProfile : secondProfile;
    final tallProfile = firstIsShorter ? secondProfile : firstProfile;

    final initialGap = tallProfile.preferredHeight - shortProfile.preferredHeight;

    final directFiller = MBHomeGapFillerResolver.resolve(initialGap);
    if (directFiller != null) {
      return _buildPlan(
        firstIsShorter: firstIsShorter,
        firstHeight: firstPreferred,
        secondHeight: secondPreferred,
        filler: directFiller,
      );
    }

    final elastic = _resolveElasticPlan(
      firstIsShorter: firstIsShorter,
      firstProfile: firstProfile,
      secondProfile: secondProfile,
    );

    if (elastic != null) {
      return elastic;
    }

    return _HalfPairPlan(
      firstCardHeight: firstPreferred,
      secondCardHeight: secondPreferred,
    );
  }

  static _HalfPairPlan? _resolveElasticPlan({
    required bool firstIsShorter,
    required MBHomeCardLayoutProfile firstProfile,
    required MBHomeCardLayoutProfile secondProfile,
  }) {
    final shortProfile = firstIsShorter ? firstProfile : secondProfile;
    final tallProfile = firstIsShorter ? secondProfile : firstProfile;

    final initialGap = tallProfile.preferredHeight - shortProfile.preferredHeight;
    final maxAdjustment = shortProfile.maxExpand + tallProfile.maxShrink;

    _HalfPairPlan? bestPlan;
    double? bestScore;

    final maxWholeGap = initialGap.floor();

    for (var targetGap = 0; targetGap <= maxWholeGap; targetGap++) {
      final adjustmentNeeded = initialGap - targetGap;

      if (adjustmentNeeded < 0 || adjustmentNeeded > maxAdjustment) {
        continue;
      }

      final filler = MBHomeGapFillerResolver.resolve(targetGap.toDouble());
      final canAbsorbTinyGap = targetGap <= 8;

      if (filler == null && !canAbsorbTinyGap) {
        continue;
      }

      final heights = _distributeAdjustment(
        firstIsShorter: firstIsShorter,
        firstProfile: firstProfile,
        secondProfile: secondProfile,
        adjustmentNeeded: adjustmentNeeded,
      );

      if (heights == null) {
        continue;
      }

      final elasticPenalty = adjustmentNeeded * 65;
      final fillerScore = filler?.score ?? 650;
      final score = elasticPenalty + fillerScore;

      if (bestScore == null || score < bestScore) {
        bestScore = score;
        bestPlan = _buildPlan(
          firstIsShorter: firstIsShorter,
          firstHeight: heights.firstHeight,
          secondHeight: heights.secondHeight,
          filler: filler,
        );
      }
    }

    return bestPlan;
  }

  static _ElasticHeights? _distributeAdjustment({
    required bool firstIsShorter,
    required MBHomeCardLayoutProfile firstProfile,
    required MBHomeCardLayoutProfile secondProfile,
    required double adjustmentNeeded,
  }) {
    final shortProfile = firstIsShorter ? firstProfile : secondProfile;
    final tallProfile = firstIsShorter ? secondProfile : firstProfile;

    var remaining = adjustmentNeeded;

    var expandShort = min(shortProfile.maxExpand, remaining * 0.62);
    remaining -= expandShort;

    var shrinkTall = min(tallProfile.maxShrink, remaining);
    remaining -= shrinkTall;

    if (remaining > 0.01) {
      final extraExpand = min(shortProfile.maxExpand - expandShort, remaining);
      expandShort += extraExpand;
      remaining -= extraExpand;
    }

    if (remaining > 0.01) {
      final extraShrink = min(tallProfile.maxShrink - shrinkTall, remaining);
      shrinkTall += extraShrink;
      remaining -= extraShrink;
    }

    if (remaining > 0.01) {
      return null;
    }

    final shortHeight = shortProfile.preferredHeight + expandShort;
    final tallHeight = tallProfile.preferredHeight - shrinkTall;

    if (firstIsShorter) {
      return _ElasticHeights(
        firstHeight: shortHeight,
        secondHeight: tallHeight,
      );
    }

    return _ElasticHeights(
      firstHeight: tallHeight,
      secondHeight: shortHeight,
    );
  }

  static _HalfPairPlan _buildPlan({
    required bool firstIsShorter,
    required double firstHeight,
    required double secondHeight,
    required MBHomeGapFillerDecision? filler,
  }) {
    return _HalfPairPlan(
      firstCardHeight: firstHeight,
      secondCardHeight: secondHeight,
      firstFiller: firstIsShorter ? filler : null,
      secondFiller: firstIsShorter ? null : filler,
    );
  }
}

class _ElasticHeights {
  const _ElasticHeights({
    required this.firstHeight,
    required this.secondHeight,
  });

  final double firstHeight;
  final double secondHeight;
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
