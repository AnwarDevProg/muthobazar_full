import 'dart:async';

import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:shared_models/shared_models.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';

class OrderController extends GetxController {
  final OrderRepository _repository = OrderRepository.instance;
  final ProfileController _profileController = Get.find<ProfileController>();

  final RxList<MBOrder> orders = <MBOrder>[].obs;
  final Rxn<MBOrder> selectedOrder = Rxn<MBOrder>();

  final RxBool isLoading = true.obs;
  final RxBool isCreatingOrder = false.obs;
  final RxBool isOrderDetailsLoading = false.obs;

  StreamSubscription<List<MBOrder>>? _ordersSubscription;

  bool get isLoggedIn => _profileController.isLoggedIn;
  String get userId => _profileController.user.value.id;
  MBUserProfile get currentUser => _profileController.user.value;

  @override
  void onInit() {
    super.onInit();
    _listenOrders();
  }

  void _listenOrders() {
    _ordersSubscription?.cancel();

    if (!isLoggedIn) {
      orders.clear();
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    _ordersSubscription = _repository.watchUserOrders(userId).listen(
          (items) {
        orders.assignAll(items);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load orders.',
        );
      },
    );
  }

  Future<void> refreshOrders() async {
    if (!isLoggedIn) return;

    try {
      isLoading.value = true;
      final items = await _repository.fetchUserOrdersOnce(userId);
      orders.assignAll(items);
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh orders.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<MBOrder?> createOrderFromCart({
    required List<MBCartItem> cartItems,
    String paymentMethod = 'cod',
    double deliveryFee = 0.0,
    double discount = 0.0,
    String? deliveryAddress,
    String? note,
  }) async {
    if (!isLoggedIn) {
      MBNotification.warning(
        title: 'Login Required',
        message: 'Please login first to place an order.',
      );
      return null;
    }

    if (cartItems.isEmpty) {
      MBNotification.warning(
        title: 'Empty Cart',
        message: 'No items found in cart.',
      );
      return null;
    }

    try {
      isCreatingOrder.value = true;

      final order = await _repository.createOrderFromCart(
        userId: userId,
        user: currentUser,
        cartItems: cartItems,
        paymentMethod: paymentMethod,
        deliveryFee: deliveryFee,
        discount: discount,
        deliveryAddress: deliveryAddress,
        note: note,
      );

      selectedOrder.value = order;

      MBNotification.success(
        title: 'Order Created',
        message: 'Your order has been placed successfully.',
      );

      return order;
    } catch (_) {
      MBNotification.error(
        title: 'Order Failed',
        message: 'Failed to create order. Please try again.',
      );
      return null;
    } finally {
      isCreatingOrder.value = false;
    }
  }

  Future<void> loadOrderDetails(String orderId) async {
    try {
      isOrderDetailsLoading.value = true;
      final order = await _repository.fetchOrderById(orderId);

      if (order == null) {
        MBNotification.warning(
          title: 'Not Found',
          message: 'Order not found.',
        );
        return;
      }

      selectedOrder.value = order;
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to load order details.',
      );
    } finally {
      isOrderDetailsLoading.value = false;
    }
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    super.onClose();
  }
}

