import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/catalog/mb_product.dart';

import 'core/mb_admin_callable_repository_base.dart';

class AdminProductRepository extends MBAdminCallableRepositoryBase<MBProduct> {
  AdminProductRepository._() : super();

  static final AdminProductRepository instance = AdminProductRepository._();

  @override
  String get collectionPath => 'products';

  CollectionReference<Map<String, dynamic>> get productsCollection => collection;

  CollectionReference<Map<String, dynamic>> get quarantineCollection =>
      firestore.collection('products_quarantine');

  @override
  MBProduct fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    final Map<String, dynamic> map = <String, dynamic>{
      ...data,
      'id': (data['id'] ?? doc.id).toString(),
    };

    try {
      return MBProduct.fromMap(map);
    } catch (error) {
      throw Exception(
        'Failed to parse product document "${doc.id}". '
            'Please check Firestore field names and types. '
            'Original error: $error',
      );
    }
  }

  @override
  List<MBProduct> sortItems(List<MBProduct> items) {
    items.sort((a, b) {
      final String aName = a.titleEn.trim().toLowerCase();
      final String bName = b.titleEn.trim().toLowerCase();
      return aName.compareTo(bName);
    });
    return items;
  }

  Map<String, dynamic> _productPayload(MBProduct product) {
    return <String, dynamic>{
      ...product.toMap(),
      'id': product.id.trim(),
      'titleEn': product.titleEn.trim(),
      'titleBn': product.titleBn.trim(),
      'shortDescriptionEn': product.shortDescriptionEn.trim(),
      'shortDescriptionBn': product.shortDescriptionBn.trim(),
      'fullDescriptionEn': product.fullDescriptionEn.trim(),
      'fullDescriptionBn': product.fullDescriptionBn.trim(),
      'thumbnailUrl': product.thumbnailUrl.trim(),
      'brandId': parseString(product.brandId),
      'categoryId': parseString(product.categoryId),
      'sku': product.sku.trim(),
      'slug': normalizeSlug(product.slug),
      'isEnabled': product.isEnabled,
      'isFeatured': product.isFeatured,
      'regularStockQty': product.regularStockQty,
      'reservedInstantQty': product.reservedInstantQty,
      'createdAt': product.createdAt?.toIso8601String(),
      'updatedAt': product.updatedAt?.toIso8601String(),
    };
  }

  Stream<List<MBProduct>> watchProducts() {
    return watchAll();
  }

  Future<List<MBProduct>> fetchProductsOnce() {
    return fetchAll(
      timeoutMessage:
      'Timed out while loading products from Firestore. '
          'Check internet connection, Firebase config, or browser console.',
    );
  }

  Stream<List<MBProduct>> watchEnabledProducts() {
    return productsCollection
        .where('isEnabled', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => sortItems(
        snapshot.docs.map((doc) => fromDoc(doc)).toList(),
      ),
    );
  }

  Future<MBProduct?> getProductById(String productId) async {
    final String id = productId.trim();
    if (id.isEmpty) return null;

    return guardFirestore(() async {
      final doc = await productsCollection.doc(id).get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while loading product details.');
        },
      );

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return MBProduct.fromMap({
        ...doc.data()!,
        'id': doc.data()!['id'] ?? doc.id,
      });
    });
  }

  Future<bool> slugExists({
    required String slug,
    String? excludeProductId,
  }) {
    return super.slugExists(
      slug: slug,
      excludeId: excludeProductId,
      timeoutMessage: 'Timed out while checking product slug uniqueness.',
    );
  }

  Future<void> createProduct(MBProduct product) async {
    await guardFirestore(() async {
      final docRef = productsCollection.doc();
      final now = DateTime.now();
      final payload = product.copyWith(
        id: docRef.id,
        createdAt: now,
        updatedAt: now,
      );

      await docRef.set(_productPayload(payload)).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while creating product.');
        },
      );
    });
  }

  Future<void> updateProduct(MBProduct product) async {
    final String productId = product.id.trim();
    if (productId.isEmpty) {
      throw Exception('Product id is required for update.');
    }

    await guardFirestore(() async {
      final payload = product.copyWith(updatedAt: DateTime.now());
      await productsCollection.doc(productId).set(
        _productPayload(payload),
        SetOptions(merge: true),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating product.');
        },
      );
    });
  }

  Future<void> setProductEnabledState({
    required String productId,
    required bool isEnabled,
  }) async {
    final String id = productId.trim();
    if (id.isEmpty) {
      throw Exception('Product id is required for status update.');
    }

    await guardFirestore(() async {
      await productsCollection.doc(id).update({
        'isEnabled': isEnabled,
        'updatedAt': DateTime.now().toIso8601String(),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating product status.');
        },
      );
    });
  }

  Future<void> increaseStock({
    required String productId,
    required int quantity,
  }) async {
    final String id = productId.trim();
    if (id.isEmpty) {
      throw Exception('Product id is required for stock increase.');
    }

    await guardFirestore(() async {
      await productsCollection.doc(id).update({
        'regularStockQty': FieldValue.increment(quantity),
        'updatedAt': DateTime.now().toIso8601String(),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while increasing stock.');
        },
      );
    });
  }

  Future<void> applyInventoryPurchase({
    required String productId,
    required int purchasedQty,
    required int scheduledDemand,
  }) async {
    final String id = productId.trim();
    if (id.isEmpty) {
      throw Exception('Product id is required for purchase inventory logic.');
    }

    await guardFirestore(() async {
      final doc = await productsCollection.doc(id).get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while loading product for inventory update.');
        },
      );

      if (!doc.exists || doc.data() == null) {
        return;
      }

      final product = MBProduct.fromMap({
        ...doc.data()!,
        'id': doc.data()!['id'] ?? doc.id,
      });

      int remaining = purchasedQty;
      if (scheduledDemand > 0) {
        final int usedForScheduled =
        remaining >= scheduledDemand ? scheduledDemand : remaining;
        remaining -= usedForScheduled;
      }

      final int updatedStock = product.regularStockQty + remaining;

      await productsCollection.doc(id).update({
        'regularStockQty': updatedStock,
        'updatedAt': DateTime.now().toIso8601String(),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while applying purchase inventory logic.');
        },
      );
    });
  }

  Future<String?> getDeleteBlockReason(String productId) async {
    final String id = productId.trim();
    if (id.isEmpty) {
      return 'Product id is required for delete.';
    }

    return null;
  }

  Future<void> moveToQuarantine({
    required MBProduct product,
    required String deletedByUid,
    required String deletedByName,
  }) async {
    if (product.id.trim().isEmpty) {
      throw Exception('Product id is required for quarantine.');
    }

    await guardFirestore(() async {
      final now = DateTime.now();
      await quarantineCollection.doc(product.id).set({
        'id': product.id,
        'productId': product.id,
        'productData': _productPayload(product),
        'deletedByUid': deletedByUid,
        'deletedByName': deletedByName,
        'deletedAt': now.toIso8601String(),
        'autoDeleteAt': now.add(const Duration(days: 30)).toIso8601String(),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while moving product to quarantine.');
        },
      );

      await productsCollection.doc(product.id).delete().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while deleting live product during quarantine.');
        },
      );
    });
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
    return guardFirestore(() async {
      final snapshot = await quarantineCollection
          .orderBy('deletedAt', descending: true)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while loading quarantine products.');
        },
      );

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': data['id'] ?? doc.id,
        };
      }).toList();
    });
  }

  Future<void> restoreFromQuarantine(String productId) async {
    final String id = productId.trim();
    if (id.isEmpty) {
      throw Exception('Product id is required for restore.');
    }

    await guardFirestore(() async {
      final doc = await quarantineCollection.doc(id).get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while loading quarantine product.');
        },
      );

      if (!doc.exists || doc.data() == null) {
        throw Exception('Quarantine product not found.');
      }

      final data = doc.data()!;
      final Map<String, dynamic> productData =
      Map<String, dynamic>.from(data['productData'] as Map? ?? const {});
      if (productData.isEmpty) {
        throw Exception('Quarantine product data is empty.');
      }

      await productsCollection.doc(id).set(productData).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while restoring product.');
        },
      );

      await quarantineCollection.doc(id).delete().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while cleaning quarantine record.');
        },
      );
    });
  }

  Future<void> hardDeleteFromQuarantine(String productId) async {
    final String id = productId.trim();
    if (id.isEmpty) {
      throw Exception('Product id is required for hard delete.');
    }

    await guardFirestore(() async {
      await quarantineCollection.doc(id).delete().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while hard deleting quarantine product.');
        },
      );
    });
  }

  Future<void> deleteProduct(String productId) async {
    final String id = productId.trim();
    if (id.isEmpty) {
      throw Exception('Product id is required for delete.');
    }

    final product = await getProductById(id);
    if (product == null) {
      return;
    }

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
