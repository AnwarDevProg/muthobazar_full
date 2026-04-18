import 'dart:async';

import 'package:customer_app/features/orders/controllers/order_controller.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';

// File: cart_controller.dart

class MBCartPriceBreakdown {
  const MBCartPriceBreakdown({
    required this.baseSubTotal,
    required this.payableSubTotal,
    required this.lineDiscountTotal,
  });

  final double baseSubTotal;
  final double payableSubTotal;
  final double lineDiscountTotal;

  double get effectiveSubTotal => payableSubTotal;
}

class CartController extends GetxController {
  final CartRepository _repository = CartRepository.instance;
  final OrderController _orderController = Get.find();

  final RxList<MBCartItem> cartItems = <MBCartItem>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isCheckingOutInstant = false.obs;
  final RxBool isCheckingOutScheduled = false.obs;
  final RxBool isCheckingOutAll = false.obs;

  StreamSubscription<List<MBCartItem>>? _cartSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenCart();
  }

  void _listenCart() {
    _cartSubscription?.cancel();
    isLoading.value = true;

    _cartSubscription = _repository.watchCart().listen(
          (items) {
        cartItems.assignAll(items);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Cart Error',
          message: 'Failed to load cart.',
        );
      },
    );
  }

  List<MBCartItem> get instantItems => cartItems
      .where((e) => (e.purchaseMode ?? 'instant') == 'instant')
      .toList();

  List<MBCartItem> get scheduledItems => cartItems
      .where((e) => (e.purchaseMode ?? 'instant') == 'scheduled')
      .toList();

  bool get hasInstantItems => instantItems.isNotEmpty;
  bool get hasScheduledItems => scheduledItems.isNotEmpty;
  bool get hasMixedCart => hasInstantItems && hasScheduledItems;

  double _lineBaseTotal(MBCartItem item) => item.unitPrice * item.quantity;

  double _linePayableTotal(MBCartItem item) => item.total;

  MBCartPriceBreakdown _buildBreakdown(List<MBCartItem> items) {
    final baseSubTotal = items.fold<double>(
      0.0,
          (sum, item) => sum + _lineBaseTotal(item),
    );

    final payableSubTotal = items.fold<double>(
      0.0,
          (sum, item) => sum + _linePayableTotal(item),
    );

    final lineDiscountTotal = (baseSubTotal - payableSubTotal) < 0
        ? 0.0
        : (baseSubTotal - payableSubTotal);

    return MBCartPriceBreakdown(
      baseSubTotal: baseSubTotal,
      payableSubTotal: payableSubTotal,
      lineDiscountTotal: lineDiscountTotal,
    );
  }

  MBCartPriceBreakdown get instantPricing => _buildBreakdown(instantItems);

  MBCartPriceBreakdown get scheduledPricing => _buildBreakdown(scheduledItems);

  MBCartPriceBreakdown get cartPricing => _buildBreakdown(cartItems);

  double get instantBaseSubTotal => instantPricing.baseSubTotal;
  double get instantSubTotal => instantPricing.payableSubTotal;
  double get instantDiscountTotal => instantPricing.lineDiscountTotal;

  double get scheduledBaseSubTotal => scheduledPricing.baseSubTotal;
  double get scheduledSubTotal => scheduledPricing.payableSubTotal;
  double get scheduledDiscountTotal => scheduledPricing.lineDiscountTotal;

  double get cartBaseSubTotal => cartPricing.baseSubTotal;
  double get cartSubTotal => cartPricing.payableSubTotal;
  double get cartDiscountTotal => cartPricing.lineDiscountTotal;

  void addItem(MBCartItem item) {
    _repository.addItem(item);
    MBNotification.success(
      title: 'Added to Cart',
      message: 'Item added successfully.',
    );
  }

  void removeItem(MBCartItem item) {
    _repository.removeItem(item);
    MBNotification.info(
      title: 'Removed',
      message: 'Item removed from cart.',
    );
  }

  void increaseQty(MBCartItem item) {
    _repository.updateItem(
      item.copyWith(quantity: item.quantity + 1),
    );
  }

  void decreaseQty(MBCartItem item) {
    if (item.quantity <= 1) {
      removeItem(item);
      return;
    }

    _repository.updateItem(
      item.copyWith(quantity: item.quantity - 1),
    );
  }

  Future<dynamic> checkoutInstant({
    required String deliveryAddress,
    String paymentMethod = 'cod',
    String? note,
    double deliveryFee = 0.0,
    double discount = 0.0,
  }) async {
    if (instantItems.isEmpty) {
      MBNotification.warning(
        title: 'No Instant Items',
        message: 'No instant order items found.',
      );
      return null;
    }

    try {
      isCheckingOutInstant.value = true;

      final order = await _orderController.createOrderFromCart(
        cartItems: instantItems,
        paymentMethod: paymentMethod,
        deliveryFee: deliveryFee,
        discount: discount,
        deliveryAddress: deliveryAddress,
        note: note,
      );

      if (order != null) {
        _repository.clearItemsByMode('instant');
      }

      return order;
    } finally {
      isCheckingOutInstant.value = false;
    }
  }

  Future<dynamic> checkoutScheduled({
    required String deliveryAddress,
    String paymentMethod = 'cod',
    String? note,
    double deliveryFee = 0.0,
    double discount = 0.0,
  }) async {
    if (scheduledItems.isEmpty) {
      MBNotification.warning(
        title: 'No Scheduled Items',
        message: 'No scheduled order items found.',
      );
      return null;
    }

    try {
      isCheckingOutScheduled.value = true;

      final order = await _orderController.createOrderFromCart(
        cartItems: scheduledItems,
        paymentMethod: paymentMethod,
        deliveryFee: deliveryFee,
        discount: discount,
        deliveryAddress: deliveryAddress,
        note: note,
      );

      if (order != null) {
        _repository.clearItemsByMode('scheduled');
      }

      return order;
    } finally {
      isCheckingOutScheduled.value = false;
    }
  }

  Future<dynamic> checkoutAll({
    required String deliveryAddress,
    String paymentMethod = 'cod',
    String? note,
    double deliveryFee = 0.0,
    double discount = 0.0,
  }) async {
    if (cartItems.isEmpty) {
      MBNotification.warning(
        title: 'Cart Empty',
        message: 'No items found in cart.',
      );
      return null;
    }

    try {
      isCheckingOutAll.value = true;

      final order = await _orderController.createOrderFromCart(
        cartItems: cartItems,
        paymentMethod: paymentMethod,
        deliveryFee: deliveryFee,
        discount: discount,
        deliveryAddress: deliveryAddress,
        note: note,
      );

      if (order != null) {
        _repository.clearCart();
      }

      return order;
    } finally {
      isCheckingOutAll.value = false;
    }
  }

  @override
  void onClose() {
    _cartSubscription?.cancel();
    super.onClose();
  }
}