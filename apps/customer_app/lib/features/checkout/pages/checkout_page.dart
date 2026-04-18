import 'package:customer_app/app/routes/customer_app_routes.dart';
import 'package:customer_app/features/cart/controllers/cart_controller.dart';
import 'package:customer_app/features/orders/controllers/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

// File: checkout_page.dart

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.checkoutMode,
  });

  final String checkoutMode; // instant | scheduled | all

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late final TextEditingController _addressController;
  late final TextEditingController _noteController;

  String _paymentMethod = 'cod';

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<MBCartItem> _itemsForMode(CartController cartController) {
    switch (widget.checkoutMode) {
      case 'instant':
        return List<MBCartItem>.from(cartController.instantItems);
      case 'scheduled':
        return List<MBCartItem>.from(cartController.scheduledItems);
      default:
        return List<MBCartItem>.from(cartController.cartItems);
    }
  }

  MBCartPriceBreakdown _pricingForMode(CartController cartController) {
    switch (widget.checkoutMode) {
      case 'instant':
        return cartController.instantPricing;
      case 'scheduled':
        return cartController.scheduledPricing;
      default:
        return cartController.cartPricing;
    }
  }

  String _modeSubtitle() {
    switch (widget.checkoutMode) {
      case 'instant':
        return 'Confirm your instant order.';
      case 'scheduled':
        return 'Confirm your scheduled order.';
      default:
        return 'Confirm your mixed order.';
    }
  }

  Future<void> _placeOrder({
    required CartController cartController,
    required double deliveryFee,
    required double promoDiscount,
  }) async {
    final address = _addressController.text.trim();
    final note = _noteController.text.trim();

    if (address.isEmpty) {
      MBNotification.warning(
        title: 'Address Required',
        message: 'Please enter a delivery address.',
      );
      return;
    }

    final order = widget.checkoutMode == 'instant'
        ? await cartController.checkoutInstant(
      deliveryAddress: address,
      paymentMethod: _paymentMethod,
      deliveryFee: deliveryFee,
      discount: promoDiscount,
      note: note.isEmpty ? null : note,
    )
        : widget.checkoutMode == 'scheduled'
        ? await cartController.checkoutScheduled(
      deliveryAddress: address,
      paymentMethod: _paymentMethod,
      deliveryFee: deliveryFee,
      discount: promoDiscount,
      note: note.isEmpty ? null : note,
    )
        : await cartController.checkoutAll(
      deliveryAddress: address,
      paymentMethod: _paymentMethod,
      deliveryFee: deliveryFee,
      discount: promoDiscount,
      note: note.isEmpty ? null : note,
    );

    if (order != null) {
      Get.offNamed(
        AppRoutes.orderDetails,
        arguments: order.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();
    final OrderController orderController = Get.find();

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: false,
      child: Obx(() {
        final items = _itemsForMode(cartController);
        final pricing = _pricingForMode(cartController);

        const double deliveryFee = 60.0;
        const double promoDiscount = 0.0; // Promo code layer comes later.

        final double total =
            pricing.payableSubTotal + deliveryFee - promoDiscount;
        final int estimatedCount =
            items.where((item) => item.isEstimatedPrice).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Checkout',
              style: MBTextStyles.pageTitle,
            ),
            MBSpacing.h(MBSpacing.sm),
            Text(
              _modeSubtitle(),
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
            MBSpacing.h(MBSpacing.lg),

            MBCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Address',
                    style: MBTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.sm),
                  MBTextField(
                    controller: _addressController,
                    hintText: 'Enter delivery address',
                    maxLines: 3,
                  ),
                  MBSpacing.h(MBSpacing.md),
                  Text(
                    'Order Note',
                    style: MBTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.sm),
                  MBTextField(
                    controller: _noteController,
                    hintText: 'Optional note',
                    maxLines: 2,
                  ),
                  MBSpacing.h(MBSpacing.md),
                  Text(
                    'Payment Method',
                    style: MBTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Select payment method',
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'cod',
                        child: Text('Cash on Delivery'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'online',
                        child: Text('Online Payment'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value ?? 'cod';
                      });
                    },
                  ),
                ],
              ),
            ),

            MBSpacing.h(MBSpacing.lg),

            MBCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: MBTextStyles.sectionTitle,
                  ),
                  MBSpacing.h(MBSpacing.md),
                  Text(
                    '${items.length} cart line(s)',
                    style: MBTextStyles.body.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  if (estimatedCount > 0) ...[
                    MBSpacing.h(MBSpacing.xs),
                    Text(
                      '$estimatedCount line(s) use estimated pricing.',
                      style: MBTextStyles.bodySmall.copyWith(
                        color: MBColors.textSecondary,
                      ),
                    ),
                  ],
                  MBSpacing.h(MBSpacing.md),
                  _row('Base Subtotal', pricing.baseSubTotal),
                  MBSpacing.h(MBSpacing.sm),
                  _row(
                    'Item Discount',
                    pricing.lineDiscountTotal,
                    isNegative: true,
                  ),
                  MBSpacing.h(MBSpacing.sm),
                  _row('Payable Subtotal', pricing.payableSubTotal),
                  MBSpacing.h(MBSpacing.sm),
                  _row('Delivery Fee', deliveryFee),
                  MBSpacing.h(MBSpacing.sm),
                  _row(
                    'Promo Discount',
                    promoDiscount,
                    isNegative: true,
                  ),
                  const Divider(),
                  _row('Total', total, isStrong: true),
                  MBSpacing.h(MBSpacing.md),
                  Text(
                    'Native sale / item-level discount is already included above. Promo code discount will be added here after promo validation is implemented.',
                    style: MBTextStyles.bodySmall.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: MBSecondaryButton(
                          text: 'Back',
                          onPressed: () => Get.back(),
                        ),
                      ),
                      MBSpacing.w(MBSpacing.md),
                      Expanded(
                        child: MBPrimaryButton(
                          text: 'Place Order',
                          isLoading: orderController.isCreatingOrder.value,
                          onPressed: items.isEmpty
                              ? null
                              : () => _placeOrder(
                            cartController: cartController,
                            deliveryFee: deliveryFee,
                            promoDiscount: promoDiscount,
                          ),
                        ),
                      ),
                    ],
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

  Widget _row(
      String label,
      double amount, {
        bool isStrong = false,
        bool isNegative = false,
      }) {
    final displayAmount =
    isNegative ? '-৳ ${amount.toStringAsFixed(0)}' : '৳ ${amount.toStringAsFixed(0)}';

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
          displayAmount,
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