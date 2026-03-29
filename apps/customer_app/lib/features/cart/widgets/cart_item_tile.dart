import 'package:flutter/material.dart';
import 'package:shared_models/orders/mb_cart_item.dart';
import 'package:shared_ui/shared_ui.dart';



class CartItemTile extends StatelessWidget {
  final MBCartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool isScheduled = (item.purchaseMode ?? 'instant') == 'scheduled';

    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.surface,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(color: MBColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: MBColors.primarySoft,
              borderRadius: BorderRadius.circular(MBRadius.md),
              image: item.imageUrl != null && item.imageUrl!.trim().isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(item.imageUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: item.imageUrl == null || item.imageUrl!.trim().isEmpty
                ? const Icon(
              Icons.shopping_bag_outlined,
              color: MBColors.primaryOrange,
            )
                : null,
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titleEn,
                  style: MBTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.titleBn.trim().isNotEmpty) ...[
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    item.titleBn,
                    style: MBTextStyles.caption,
                  ),
                ],
                MBSpacing.h(MBSpacing.xxs),
                Text(
                  '৳ ${item.finalUnitPrice ?? item.unitPrice}',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isScheduled) ...[
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    'Scheduled: ${item.selectedDate?.toIso8601String().split('T').first ?? '-'}'
                        '${item.selectedShift != null ? ' • ${item.selectedShift}' : ''}',
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.primaryOrange,
                    ),
                  ),
                ] else ...[
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    'Instant order',
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.primaryOrange,
                    ),
                  ),
                ],
                if (item.isEstimatedPrice) ...[
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    'Estimated price',
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.warning,
                    ),
                  ),
                ],
              ],
            ),
          ),
          MBSpacing.w(MBSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: onDecrease,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MBSpacing.sm,
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: MBTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _QtyButton(
                    icon: Icons.add,
                    onTap: onIncrease,
                  ),
                ],
              ),
              MBSpacing.h(MBSpacing.sm),
              Text(
                '৳ ${item.total.toStringAsFixed(0)}',
                style: MBTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.sm),
              SizedBox(
                width: 88,
                child: MBSecondaryButton(
                  text: 'Remove',
                  height: 36,
                  expand: true,
                  foregroundColor: MBColors.error,
                  borderColor: MBColors.error,
                  onPressed: onRemove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: MBColors.primarySoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          icon,
          size: 16,
          color: MBColors.primaryOrange,
        ),
      ),
    );
  }
}