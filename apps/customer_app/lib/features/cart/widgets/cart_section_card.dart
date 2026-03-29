import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'cart_item_tile.dart';

class CartSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<MBCartItem> items;
  final double subTotal;
  final String buttonText;
  final bool isLoading;
  final VoidCallback onCheckout;
  final void Function(MBCartItem item) onIncrease;
  final void Function(MBCartItem item) onDecrease;
  final void Function(MBCartItem item) onRemove;

  const CartSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.subTotal,
    required this.buttonText,
    required this.isLoading,
    required this.onCheckout,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MBTextStyles.sectionTitle,
          ),
          MBSpacing.h(MBSpacing.xxxs),
          Text(
            subtitle,
            style: MBTextStyles.body.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          ListView.separated(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => MBSpacing.h(MBSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return CartItemTile(
                item: item,
                onIncrease: () => onIncrease(item),
                onDecrease: () => onDecrease(item),
                onRemove: () => onRemove(item),
              );
            },
          ),
          MBSpacing.h(MBSpacing.md),
          Row(
            children: [
              Text(
                'Subtotal',
                style: MBTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '৳ ${subTotal.toStringAsFixed(0)}',
                style: MBTextStyles.price.copyWith(fontSize: 16),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.md),
          MBPrimaryButton(
            text: buttonText,
            isLoading: isLoading,
            onPressed: onCheckout,
          ),
        ],
      ),
    );
  }
}