import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

// MB Home Product Grid Section
// ----------------------------
// Styled to match old approved product section layout using MBProductCard.

class MBHomeProductGridSection extends StatelessWidget {
  final MBHomeSection section;
  final List<MBProduct> products;
  final void Function(MBProduct product)? onProductTap;
  final VoidCallback? onViewAllTap;

  const MBHomeProductGridSection({
    super.key,
    required this.section,
    required this.products,
    this.onProductTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final productGrid = MBLayoutGrid.homeProducts(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MBSectionTitle(
          title: section.titleEn.isNotEmpty ? section.titleEn : 'Products',
          actionText: section.showViewAll ? 'See All' : null,
          onTapAction: onViewAllTap,
        ),
        MBSpacing.h(MBSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: MBLayoutGrid.delegate(config: productGrid),
          itemBuilder: (_, index) {
            final product = products[index];

            return GestureDetector(
              onTap: () => onProductTap?.call(product),
              child: MBProductCard(
                title: product.titleEn,
                priceText: '৳${product.effectivePrice.toStringAsFixed(0)}',
                oldPriceText: product.hasDiscount
                    ? '৳${product.price.toStringAsFixed(0)}'
                    : null,
                imageUrl: product.thumbnailUrl,
              ),
            );
          },
        ),
      ],
    );
  }
}