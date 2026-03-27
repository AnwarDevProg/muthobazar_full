import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:customer_app/app/routes/customer_app_routes.dart';
import '../../../core/widgets/common/mb_card.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_section_card.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: false,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.cartItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(MBSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 56,
                    color: MBColors.primaryOrange,
                  ),
                  MBSpacing.h(MBSpacing.md),
                  const Text(
                    'Your Cart is Empty',
                    style: MBTextStyles.sectionTitle,
                  ),
                  MBSpacing.h(MBSpacing.xs),
                  Text(
                    'Add products to continue shopping.',
                    textAlign: TextAlign.center,
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  SizedBox(
                    width: 180,
                    child: MBPrimaryButton(
                      text: 'Browse Products',
                      onPressed: () => Get.offNamed(AppRoutes.shell),
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
            const Text(
              'My Cart',
              style: MBTextStyles.pageTitle,
            ),
            MBSpacing.h(MBSpacing.sm),
            Text(
              controller.hasMixedCart
                  ? 'Your cart contains instant and scheduled items. Checkout them separately or together.'
                  : controller.hasScheduledItems
                  ? 'Review your scheduled items before placing the order.'
                  : 'Review your instant items before placing the order.',
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
            if (controller.hasInstantItems)
              CartSectionCard(
                title: 'Instant Order',
                subtitle: 'These items are for today’s order.',
                items: controller.instantItems,
                subTotal: controller.instantSubTotal,
                buttonText: 'Proceed Instant Checkout',
                isLoading: controller.isCheckingOutInstant.value,
                onCheckout: () {
                  Get.to(
                        () => const CheckoutPage(checkoutMode: 'instant'),
                  );
                },
                onIncrease: controller.increaseQty,
                onDecrease: controller.decreaseQty,
                onRemove: controller.removeItem,
              ),
            if (controller.hasInstantItems && controller.hasScheduledItems)
              MBSpacing.h(MBSpacing.lg),
            if (controller.hasScheduledItems)
              CartSectionCard(
                title: 'Scheduled Order',
                subtitle: 'These items will be purchased or arranged for your selected date.',
                items: controller.scheduledItems,
                subTotal: controller.scheduledSubTotal,
                buttonText: 'Proceed Scheduled Checkout',
                isLoading: controller.isCheckingOutScheduled.value,
                onCheckout: () {
                  Get.to(
                        () => const CheckoutPage(checkoutMode: 'scheduled'),
                  );
                },
                onIncrease: controller.increaseQty,
                onDecrease: controller.decreaseQty,
                onRemove: controller.removeItem,
              ),
            if (controller.hasMixedCart) ...[
              MBSpacing.h(MBSpacing.lg),
              MBCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mixed Cart Checkout',
                      style: MBTextStyles.sectionTitle,
                    ),
                    MBSpacing.h(MBSpacing.xs),
                    Text(
                      'Place all instant and scheduled items in one order.',
                      style: MBTextStyles.body.copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
                    MBSpacing.h(MBSpacing.md),
                    Row(
                      children: [
                        Text(
                          'Cart Total',
                          style: MBTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '৳ ${controller.cartSubTotal.toStringAsFixed(0)}',
                          style: MBTextStyles.price.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBPrimaryButton(
                      text: 'Proceed Mixed Checkout',
                      isLoading: controller.isCheckingOutAll.value,
                      onPressed: () {
                        Get.to(
                              () => const CheckoutPage(checkoutMode: 'all'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            MBSpacing.h(MBSpacing.xxl),
          ],
        );
      }),
    );
  }
}

