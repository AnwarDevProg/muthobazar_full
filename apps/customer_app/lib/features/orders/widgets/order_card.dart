import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';


class OrderCard extends StatelessWidget {
  final MBOrder order;

  const OrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return MBCard(
      padding: const EdgeInsets.all(MBSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        onTap: () => Get.toNamed(
          AppRoutes.orderDetails,
          arguments: order.id,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Badge(
                  label: _prettyOrderType(order.orderType),
                  foregroundColor: Colors.white,
                  backgroundColor: MBColors.primaryOrange,
                ),
                MBSpacing.w(MBSpacing.sm),
                _Badge(
                  label: _prettyOrderStatus(order.orderStatus),
                  foregroundColor: MBColors.textPrimary,
                  backgroundColor: MBColors.primarySoft,
                ),
                const Spacer(),
                Text(
                  order.createdAt.toIso8601String().split('T').first,
                  style: MBTextStyles.caption,
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Text(
              'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',
              style: MBTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.xxxs),
            Text(
              '${order.totalItemsCount} item(s)',
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
            if (order.scheduledFor != null) ...[
              MBSpacing.h(MBSpacing.xxxs),
              Text(
                'Delivery: ${order.scheduledFor!.toIso8601String().split('T').first}'
                    '${order.scheduledShift != null ? ' • ${order.scheduledShift}' : ''}',
                style: MBTextStyles.caption.copyWith(
                  color: MBColors.primaryOrange,
                ),
              ),
            ],
            MBSpacing.h(MBSpacing.sm),
            Row(
              children: [
                Text(
                  '৳ ${order.totalAmount.toStringAsFixed(0)}',
                  style: MBTextStyles.price,
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: MBColors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _prettyOrderType(String type) {
    switch (type) {
      case 'scheduled':
        return 'Scheduled Order';
      case 'mixed':
        return 'Mixed Order';
      default:
        return 'Instant Order';
    }
  }

  String _prettyOrderStatus(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'ready':
        return 'Ready';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

  const _Badge({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.sm,
        vertical: MBSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: MBTextStyles.caption.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}