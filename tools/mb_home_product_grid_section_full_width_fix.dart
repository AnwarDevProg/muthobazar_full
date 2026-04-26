import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';

// MB Home Product Grid Section
// ----------------------------
// Product-card-aware home grid section.
//
// The previous GridView forced every product into the same half-width cell.
// Full-width variants like horizontal03 and wide04 therefore rendered as
// half-width cards. This layout manually groups half-width cards two per row
// and gives full-width variants the entire row.

class MBHomeProductGridSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MBSectionTitle(
          title: section.titleEn.isNotEmpty ? section.titleEn : 'Products',
          actionText: section.showViewAll ? 'See All' : null,
          onTapAction: onViewAllTap,
        ),
        MBSpacing.h(MBSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            return _ProductCardFlow(
              products: products,
              maxWidth: constraints.maxWidth,
              onProductTap: onProductTap,
              onAddToCart: onAddToCart,
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
    final gap = MBSpacing.sm;
    final rows = _buildRows();

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

  List<_ProductCardRow> _buildRows() {
    final rows = <_ProductCardRow>[];
    final halfQueue = <MBProduct>[];

    void flushHalfQueue() {
      while (halfQueue.isNotEmpty) {
        final first = halfQueue.removeAt(0);
        final second = halfQueue.isEmpty ? null : halfQueue.removeAt(0);

        rows.add(
          _ProductCardRow.half(
            first: first,
            second: second,
          ),
        );
      }
    }

    for (final product in products) {
      if (_isFullWidthProduct(product)) {
        flushHalfQueue();
        rows.add(_ProductCardRow.full(product));
      } else {
        halfQueue.add(product);

        if (halfQueue.length == 2) {
          flushHalfQueue();
        }
      }
    }

    flushHalfQueue();
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
