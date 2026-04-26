import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';

// MB Home Product Horizontal Section
// ----------------------------------
// Product-card-aware horizontal list.
//
// Full-width variants receive a wider item width in the horizontal scroller so
// they are not squeezed into compact-card width.

class MBHomeProductHorizontalSection extends StatelessWidget {
  final MBHomeSection section;
  final List<MBProduct> products;
  final List<MBOffer> offers;
  final void Function(MBProduct product)? onProductTap;
  final void Function(MBProduct product)? onAddToCart;
  final VoidCallback? onViewAllTap;

  const MBHomeProductHorizontalSection({
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
        SizedBox(
          height: 265,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => MBSpacing.w(MBSpacing.sm),
            itemBuilder: (context, index) {
              final product = products[index];
              final isFullWidth = _isFullWidthProduct(product);

              return SizedBox(
                width: _widthForProduct(context, product),
                child: MBProductCardRenderer(
                  product: product,
                  contextType: isFullWidth
                      ? MBProductCardRenderContext.featured
                      : MBProductCardRenderContext.grid,
                  featuredHeight: isFullWidth ? 245 : null,
                  onTap: () => onProductTap?.call(product),
                  onAddToCartTap: () => onAddToCart?.call(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isFullWidthProduct(MBProduct product) {
    final config = product.effectiveCardConfig.normalized();
    return config.variant.isFullWidth;
  }

  double _widthForProduct(BuildContext context, MBProduct product) {
    if (!_isFullWidthProduct(product)) {
      return 170;
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final available = screenWidth - (MBSpacing.pageHorizontal(context) * 2);

    return available.clamp(290.0, 360.0);
  }
}
