import 'package:flutter/material.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../core/responsive/mb_layout_grid.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final grid = MBLayoutGrid.products(context);

    return MBAppLayout(
      backgroundColor: MBColors.background,
      appBar: AppBar(
        title: Text(
          'Wishlist',
          style: MBAppText.sectionTitle(context),
        ),
      ),
      child: Padding(
        padding: MBScreenPadding.page(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved for later',
              style: MBAppText.headline3(context).copyWith(
                color: MBColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xxxs),
            Text(
              'Keep your favorite products here and move them to cart anytime.',
              style: MBAppText.bodySmall(context).copyWith(
                color: MBColors.textSecondary,
              ),
            ),
            MBSpacing.h(MBSpacing.sectionGap(context)),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _wishlistItems.length,
              gridDelegate: MBLayoutGrid.delegate(config: grid),
              itemBuilder: (context, index) {
                final item = _wishlistItems[index];
                return _WishlistProductCard(item: item);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistProductCard extends StatelessWidget {
  final _WishlistItem item;

  const _WishlistProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MBColors.card,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MBColors.primaryOrange.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(MBRadius.lg),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.favorite_border,
                      size: 40,
                      color: MBColors.primaryOrange.withValues(alpha: 0.80),
                    ),
                  ),
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: MBColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(MBSpacing.cardPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MBAppText.caption(context).copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MBAppText.body(context).copyWith(
                    color: MBColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                MBSpacing.h(MBSpacing.xs),
                Text(
                  item.price,
                  style: MBAppText.sectionTitle(context).copyWith(
                    color: MBColors.primaryOrange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistItem {
  final String title;
  final String category;
  final String price;

  const _WishlistItem({
    required this.title,
    required this.category,
    required this.price,
  });
}

const List<_WishlistItem> _wishlistItems = [
  _WishlistItem(
    title: 'Natural Honey Jar 500g',
    category: 'Health Food',
    price: '৳ 390',
  ),
  _WishlistItem(
    title: 'Daily Care Shampoo 340ml',
    category: 'Personal Care',
    price: '৳ 275',
  ),
  _WishlistItem(
    title: 'Premium Olive Oil 500ml',
    category: 'Groceries',
    price: '৳ 540',
  ),
  _WishlistItem(
    title: 'Baby Skin Lotion 200ml',
    category: 'Baby Care',
    price: '৳ 320',
  ),
];

