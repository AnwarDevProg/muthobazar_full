import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class OrderItemTile extends StatelessWidget {
  final MBOrderItem item;

  const OrderItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.surface,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
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
                  'Qty: ${item.quantity} • ৳ ${item.effectiveUnitPrice.toStringAsFixed(0)}',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
                if (item.orderType == 'scheduled' && item.deliveryDate != null) ...[
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    'Scheduled: ${item.deliveryDate!.toIso8601String().split('T').first}'
                        '${item.deliveryShift != null ? ' • ${item.deliveryShift}' : ''}',
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
          Text(
            '৳ ${item.totalPrice.toStringAsFixed(0)}',
            style: MBTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: MBColors.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}