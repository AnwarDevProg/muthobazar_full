import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

// MB Home Product Horizontal Section
// ----------------------------------
// Styled to match old MuthoBazar cards, but in a horizontal layout.

class MBHomeProductHorizontalSection extends StatelessWidget {
  final MBHomeSection section;
  final List<MBProduct> products;
  final List<MBOffer> offers;
  final void Function(MBProduct product)? onProductTap;
  final VoidCallback? onViewAllTap;

  const MBHomeProductHorizontalSection({
    super.key,
    required this.section,
    required this.products,
    this.offers = const <MBOffer>[],
    this.onProductTap,
    this.onViewAllTap,
  });

  MBResolvedPrice _resolvedPrice(MBProduct product) {
    return MBPricingResolver.resolveProduct(
      product: product,
      offers: offers,
    );
  }

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
          height: 255,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => MBSpacing.w(MBSpacing.sm),
            itemBuilder: (context, index) {
              final product = products[index];
              final resolved = _resolvedPrice(product);

              return SizedBox(
                width: 170,
                child: GestureDetector(
                  onTap: () => onProductTap?.call(product),
                  child: MBProductCard(
                    title: product.titleEn,
                    priceText: '৳${resolved.finalUnitPrice.toStringAsFixed(0)}',
                    oldPriceText: resolved.isDiscounted
                        ? '৳${resolved.basePrice.toStringAsFixed(0)}'
                        : null,
                    imageUrl: product.thumbnailUrl,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}