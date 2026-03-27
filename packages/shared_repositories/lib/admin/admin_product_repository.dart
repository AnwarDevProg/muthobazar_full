import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/catalog/mb_product.dart';

class AdminProductRepository {
  AdminProductRepository._();

  static final AdminProductRepository instance =
  AdminProductRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get productsCollection =>
      _db.collection('products');

  CollectionReference<Map<String, dynamic>> get quarantineCollection =>
      _db.collection('products_quarantine');

  // =========================================================
  // CREATE
  // =========================================================

  Future<void> createProduct(MBProduct product) async {
    final doc = productsCollection.doc();
    final now = DateTime.now();

    final payload = product.copyWith(
      id: doc.id,
      createdAt: now,
      updatedAt: now,
    );

    await doc.set(payload.toMap());
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<void> updateProduct(MBProduct product) async {
    if (product.id.trim().isEmpty) {
      throw Exception('Product id is required for update.');
    }

    final now = DateTime.now();

    await productsCollection.doc(product.id).set(
      product.copyWith(updatedAt: now).toMap(),
      SetOptions(merge: true),
    );
  }

  // =========================================================
  // ENABLE / DISABLE
  // =========================================================

  Future<void> setProductEnabledState({
    required String productId,
    required bool isEnabled,
  }) async {
    await productsCollection.doc(productId).update({
      'isEnabled': isEnabled,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // =========================================================
  // STOCK INCREASE
  // =========================================================

  Future<void> increaseStock({
    required String productId,
    required int quantity,
  }) async {
    await productsCollection.doc(productId).update({
      'regularStockQty': FieldValue.increment(quantity),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // =========================================================
  // APPLY PURCHASE LOGIC
  // =========================================================

  Future<void> applyInventoryPurchase({
    required String productId,
    required int purchasedQty,
    required int scheduledDemand,
  }) async {
    final doc = await productsCollection.doc(productId).get();

    if (!doc.exists || doc.data() == null) return;

    final product = MBProduct.fromMap(doc.data());

    int remaining = purchasedQty;

    if (scheduledDemand > 0) {
      final usedForScheduled =
      remaining >= scheduledDemand ? scheduledDemand : remaining;

      remaining -= usedForScheduled;
    }

    final updatedStock = product.regularStockQty + remaining;

    await productsCollection.doc(productId).update({
      'regularStockQty': updatedStock,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // =========================================================
  // WATCH PRODUCTS
  // =========================================================

  Stream<List<MBProduct>> watchProducts() {
    return productsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => MBProduct.fromMap({
        ...doc.data(),
        'id': doc.data()['id'] ?? doc.id,
      }))
          .toList(),
    );
  }

  Future<List<MBProduct>> fetchProductsOnce() async {
    final snapshot =
    await productsCollection.orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) => MBProduct.fromMap({
      ...doc.data(),
      'id': doc.data()['id'] ?? doc.id,
    }))
        .toList();
  }

  Stream<List<MBProduct>> watchEnabledProducts() {
    return productsCollection
        .where('isEnabled', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => MBProduct.fromMap({
        ...doc.data(),
        'id': doc.data()['id'] ?? doc.id,
      }))
          .toList(),
    );
  }

  Future<MBProduct?> getProductById(String productId) async {
    final doc = await productsCollection.doc(productId).get();

    if (!doc.exists || doc.data() == null) return null;

    return MBProduct.fromMap({
      ...doc.data()!,
      'id': doc.data()!['id'] ?? doc.id,
    });
  }

  // =========================================================
  // QUARANTINE FLOW
  // =========================================================

  Future<void> moveToQuarantine({
    required MBProduct product,
    required String deletedByUid,
    required String deletedByName,
  }) async {
    if (product.id.trim().isEmpty) {
      throw Exception('Product id is required for quarantine.');
    }

    final now = DateTime.now();

    await quarantineCollection.doc(product.id).set({
      'id': product.id,
      'productId': product.id,
      'productData': product.toMap(),
      'deletedByUid': deletedByUid,
      'deletedByName': deletedByName,
      'deletedAt': now.toIso8601String(),
      'autoDeleteAt': now.add(const Duration(days: 30)).toIso8601String(),
    });

    await productsCollection.doc(product.id).delete();
  }

  Stream<List<Map<String, dynamic>>> watchQuarantineProducts() {
    return quarantineCollection
        .orderBy('deletedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': data['id'] ?? doc.id,
        };
      }).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> fetchQuarantineProductsOnce() async {
    final snapshot =
    await quarantineCollection.orderBy('deletedAt', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'id': data['id'] ?? doc.id,
      };
    }).toList();
  }

  Future<void> restoreFromQuarantine(String productId) async {
    final doc = await quarantineCollection.doc(productId).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('Quarantine product not found.');
    }

    final data = doc.data()!;
    final productData =
    Map<String, dynamic>.from(data['productData'] as Map? ?? const {});

    if (productData.isEmpty) {
      throw Exception('Quarantine product data is empty.');
    }

    await productsCollection.doc(productId).set(productData);
    await quarantineCollection.doc(productId).delete();
  }

  Future<void> hardDeleteFromQuarantine(String productId) async {
    await quarantineCollection.doc(productId).delete();
  }

  // Alias support if older controller/references use different method names
  Future<void> deleteProduct(String productId) async {
    final doc = await productsCollection.doc(productId).get();
    if (!doc.exists || doc.data() == null) return;

    final product = MBProduct.fromMap({
      ...doc.data()!,
      'id': doc.data()!['id'] ?? doc.id,
    });

    await moveToQuarantine(
      product: product,
      deletedByUid: '',
      deletedByName: '',
    );
  }

  Future<void> restoreProduct(String productId) async {
    await restoreFromQuarantine(productId);
  }
}











