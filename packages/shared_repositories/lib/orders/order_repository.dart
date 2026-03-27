import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/catalog/mb_cart_item.dart';
import '../../../models/commerce/mb_order.dart';
import '../../../models/commerce/mb_order_item.dart';
import '../../../models/user_model.dart';

class OrderRepository {
  OrderRepository._();

  static final OrderRepository instance = OrderRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get ordersCollection =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get scheduledDemandCollection =>
      _firestore.collection('scheduled_demand');

  String detectOrderType(List<MBCartItem> items) {
    final hasInstant = items.any((e) => (e.purchaseMode ?? 'instant') == 'instant');
    final hasScheduled =
    items.any((e) => (e.purchaseMode ?? 'instant') == 'scheduled');

    if (hasInstant && hasScheduled) return 'mixed';
    if (hasScheduled) return 'scheduled';
    return 'instant';
  }

  DateTime? resolveScheduledFor(List<MBCartItem> items) {
    final scheduledItems =
    items.where((e) => (e.purchaseMode ?? 'instant') == 'scheduled').toList();

    if (scheduledItems.isEmpty) return null;

    scheduledItems.sort((a, b) {
      final aDate = a.selectedDate ?? DateTime.now();
      final bDate = b.selectedDate ?? DateTime.now();
      return aDate.compareTo(bDate);
    });

    return scheduledItems.first.selectedDate;
  }

  String? resolveScheduledShift(List<MBCartItem> items) {
    final scheduledItems =
    items.where((e) => (e.purchaseMode ?? 'instant') == 'scheduled').toList();

    if (scheduledItems.isEmpty) return null;
    return scheduledItems.first.selectedShift;
  }

  double calculateSubTotal(List<MBCartItem> items) {
    return items.fold<double>(0.0, (sum, item) => sum + item.total);
  }

  Future<MBOrder> createOrderFromCart({
    required String userId,
    required UserModel user,
    required List<MBCartItem> cartItems,
    String paymentMethod = 'cod',
    double deliveryFee = 0.0,
    double discount = 0.0,
    String? deliveryAddress,
    String? note,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('Cart is empty.');
    }

    final doc = ordersCollection.doc();
    final now = DateTime.now();

    final orderItems = cartItems.map(MBOrderItem.fromCartItem).toList();
    final subTotal = calculateSubTotal(cartItems);
    final totalAmount = subTotal + deliveryFee - discount;
    final orderType = detectOrderType(cartItems);
    final scheduledFor = resolveScheduledFor(cartItems);
    final scheduledShift = resolveScheduledShift(cartItems);

    final order = MBOrder(
      id: doc.id,
      userId: userId,
      customerName: user.fullName,
      customerPhone: user.phoneNumber,
      customerEmail: user.email.trim().isEmpty ? null : user.email.trim(),
      items: orderItems,
      subTotal: subTotal,
      deliveryFee: deliveryFee,
      discount: discount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: 'pending',
      orderStatus: 'pending',
      orderType: orderType,
      deliveryAddress: deliveryAddress,
      note: note,
      scheduledFor: scheduledFor,
      scheduledShift: scheduledShift,
      createdAt: now,
      updatedAt: now,
    );

    final batch = _firestore.batch();

    batch.set(doc, order.toMap());

    for (final item in orderItems) {
      if (item.orderType == 'scheduled' && item.deliveryDate != null) {
        final key =
            '${item.productId}_${item.deliveryDate!.toIso8601String().split('T').first}';
        final demandRef = scheduledDemandCollection.doc(key);

        batch.set(
          demandRef,
          {
            'id': key,
            'productId': item.productId,
            'productTitleEn': item.titleEn,
            'productTitleBn': item.titleBn,
            'date': item.deliveryDate!.toIso8601String().split('T').first,
            'totalQty': FieldValue.increment(item.quantity),
            'updatedAt': now.toIso8601String(),
          },
          SetOptions(merge: true),
        );
      }
    }

    await batch.commit();

    return order;
  }

  Stream<List<MBOrder>> watchUserOrders(String userId) {
    return ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MBOrder.fromMap({
          ...data,
          'id': data['id'] ?? doc.id,
        });
      }).toList();
    });
  }

  Future<List<MBOrder>> fetchUserOrdersOnce(String userId) async {
    final snapshot = await ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MBOrder.fromMap({
        ...data,
        'id': data['id'] ?? doc.id,
      });
    }).toList();
  }

  Future<MBOrder?> fetchOrderById(String orderId) async {
    final doc = await ordersCollection.doc(orderId).get();
    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    return MBOrder.fromMap({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String orderStatus,
  }) async {
    await ordersCollection.doc(orderId).set({
      'orderStatus': orderStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {
    await ordersCollection.doc(orderId).set({
      'paymentStatus': paymentStatus,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}