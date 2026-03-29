import 'package:customer_app/features/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:customer_app/app/routes/customer_app_routes.dart';

import 'package:shared_models/shared_models.dart';
import 'package:customer_app/features/orders/controllers/order_controller.dart';


class CheckoutPage extends StatefulWidget {
  final String checkoutMode; // instant | scheduled | all

  const CheckoutPage({
    super.key,
    required this.checkoutMode,
  });

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

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final OrderController orderController = Get.find<OrderController>();

    final List<MBCartItem> items = widget.checkoutMode == 'instant'
        ? List<MBCartItem>.from(cartController.instantItems)
        : widget.checkoutMode == 'scheduled'
        ? List<MBCartItem>.from(cartController.scheduledItems)
        : List<MBCartItem>.from(cartController.cartItems);

    final double subTotal = items.fold<double>(
      0.0,
          (sum, item) => sum + item.total,
    );

    const double deliveryFee = 60.0;
    const double discount = 0.0;
    final double total = subTotal + deliveryFee - discount;

    return MBAppLayout(
      backgroundColor: MBColors.background,
      safeTop: true,
      safeBottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Checkout',
            style: MBTextStyles.pageTitle,
          ),
          MBSpacing.h(MBSpacing.sm),
          Text(
            widget.checkoutMode == 'instant'
                ? 'Confirm your instant order.'
                : widget.checkoutMode == 'scheduled'
                ? 'Confirm your scheduled order.'
                : 'Confirm your mixed order.',
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
                    DropdownMenuItem(
                      value: 'cod',
                      child: Text('Cash on Delivery'),
                    ),
                    DropdownMenuItem(
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
                MBSpacing.h(MBSpacing.md),
                _row('Subtotal', subTotal),
                MBSpacing.h(MBSpacing.sm),
                _row('Delivery Fee', deliveryFee),
                MBSpacing.h(MBSpacing.sm),
                _row('Discount', discount),
                const Divider(),
                _row('Total', total, isStrong: true),
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
                        onPressed: () async {
                          if (_addressController.text.trim().isEmpty) {
                            return;
                          }

                          final order = widget.checkoutMode == 'instant'
                              ? await cartController.checkoutInstant(
                            deliveryAddress:
                            _addressController.text.trim(),
                            paymentMethod: _paymentMethod,
                            deliveryFee: deliveryFee,
                            discount: discount,
                            note: _noteController.text.trim(),
                          )
                              : widget.checkoutMode == 'scheduled'
                              ? await cartController.checkoutScheduled(
                            deliveryAddress:
                            _addressController.text.trim(),
                            paymentMethod: _paymentMethod,
                            deliveryFee: deliveryFee,
                            discount: discount,
                            note: _noteController.text.trim(),
                          )
                              : await cartController.checkoutAll(
                            deliveryAddress:
                            _addressController.text.trim(),
                            paymentMethod: _paymentMethod,
                            deliveryFee: deliveryFee,
                            discount: discount,
                            note: _noteController.text.trim(),
                          );

                          if (order != null) {
                            Get.offNamed(
                              AppRoutes.orderDetails,
                              arguments: order.id,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          MBSpacing.h(MBSpacing.xxl),
        ],
      ),
    );
  }

  Widget _row(String label, double amount, {bool isStrong = false}) {
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

