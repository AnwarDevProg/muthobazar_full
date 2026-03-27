import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../core/widgets/common/mb_card.dart';
import 'package:customer_app/features/orders/controllers/order_controller.dart';
import '../widgets/order_item_tile.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  void initState() {
    super.initState();

    final String orderId = (Get.arguments ?? '').toString();
    if (orderId.isNotEmpty) {
      Future.microtask(() {
        Get.find<OrderController>().loadOrderDetails(orderId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: false,
      child: Obx(() {
        if (controller.isOrderDetailsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final order = controller.selectedOrder.value;
        if (order == null) {
          return const Center(
            child: Text(
              'Order not found.',
              style: MBTextStyles.body,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: MBTextStyles.pageTitle,
            ),
            MBSpacing.h(MBSpacing.md),
            MBCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: MBTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xxs),
                  Text(
                    'Status: ${order.orderStatus}',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xxs),
                  Text(
                    'Payment: ${order.paymentStatus}',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  if (order.scheduledFor != null) ...[
                    MBSpacing.h(MBSpacing.xxs),
                    Text(
                      'Scheduled For: ${order.scheduledFor!.toIso8601String().split('T').first}'
                          '${order.scheduledShift != null ? ' • ${order.scheduledShift}' : ''}',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.primaryOrange,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
            const Text(
              'Items',
              style: MBTextStyles.sectionTitle,
            ),
            MBSpacing.h(MBSpacing.md),
            ListView.separated(
              itemCount: order.items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => MBSpacing.h(MBSpacing.sm),
              itemBuilder: (context, index) {
                return OrderItemTile(item: order.items[index]);
              },
            ),
            MBSpacing.h(MBSpacing.lg),
            MBCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow('Subtotal', order.subTotal),
                  MBSpacing.h(MBSpacing.sm),
                  _summaryRow('Delivery Fee', order.deliveryFee),
                  MBSpacing.h(MBSpacing.sm),
                  _summaryRow('Discount', order.discount),
                  const Divider(),
                  _summaryRow(
                    'Total',
                    order.totalAmount,
                    isStrong: true,
                  ),
                ],
              ),
            ),
            MBSpacing.h(MBSpacing.xxl),
          ],
        );
      }),
    );
  }

  Widget _summaryRow(
      String label,
      double amount, {
        bool isStrong = false,
      }) {
    return Row(
      children: [
        Text(
          label,
          style: isStrong
              ? MBTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)
              : MBTextStyles.body,
        ),
        const Spacer(),
        Text(
          '৳ ${amount.toStringAsFixed(0)}',
          style: isStrong
              ? MBTextStyles.price.copyWith(fontSize: 16)
              : MBTextStyles.body.copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

