import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

// MB Home Product Horizontal Section
// ----------------------------------
// Uses MBProductCardRenderer so each product can choose its card layout,
// while still enforcing horizontal-safe fallback behavior.

class MBHomeProductHorizontalSection extends StatelessWidget {
  const MBHomeProductHorizontalSection({
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
          height: 320,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => MBSpacing.w(MBSpacing.sm),
            itemBuilder: (context, index) {
              final product = products[index];

              return SizedBox(
                width: 210,
                child: MBProductCardRenderer(
                  product: product,
                  contextType: MBProductCardRenderContext.horizontal,
                  onTap: () => onProductTap?.call(product),
                  showAddToCart: true,
                  showFavorite: true,
                  featuredHeight: 320,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}