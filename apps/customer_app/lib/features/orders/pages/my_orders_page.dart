import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:customer_app/features/orders/controllers/order_controller.dart';
import '../widgets/order_card.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: false,
      onRefresh: controller.refreshOrders,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(MBSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 56,
                    color: MBColors.primaryOrange,
                  ),
                  MBSpacing.h(MBSpacing.md),
                  Text(
                    'No Orders Yet',
                    style: MBTextStyles.sectionTitle,
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    'Your placed orders will appear here.',
                    textAlign: TextAlign.center,
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Orders',
              style: MBTextStyles.pageTitle,
            ),
            MBSpacing.h(MBSpacing.sm),
            Text(
              'Track instant and scheduled orders from one place.',
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
            ListView.separated(
              itemCount: controller.orders.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => MBSpacing.h(MBSpacing.md),
              itemBuilder: (context, index) {
                final order = controller.orders[index];
                return OrderCard(order: order);
              },
            ),
            MBSpacing.h(MBSpacing.xxl),
          ],
        );
      }),
    );
  }
}

