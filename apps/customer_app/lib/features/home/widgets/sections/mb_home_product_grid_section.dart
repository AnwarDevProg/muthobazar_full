import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

// MB Home Product Grid Section
// ----------------------------
// Uses MBProductCardRenderer so each product can choose its card layout,
// while still enforcing grid-safe fallback behavior.

class MBHomeProductGridSection extends StatelessWidget {
  const MBHomeProductGridSection({
    super.key,
    required this.section,
    required this.products,
    this.onProductTap,
    this.onViewAllTap,
  });

  final MBHomeSection section;
  final List<MBProduct> products;
  final void Function(MBProduct product)? onProductTap;
  final VoidCallback? onViewAllTap;

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
          itemBuilder: (context, index) {
            final product = products[index];

            return MBProductCardRenderer(
              product: product,
              contextType: MBProductCardRenderContext.grid,
              onTap: () => onProductTap?.call(product),
              showAddToCart: true,
              showFavorite: true,
            );
          },
        ),
      ],
    );
  }
}