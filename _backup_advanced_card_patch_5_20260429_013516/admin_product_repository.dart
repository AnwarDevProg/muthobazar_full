import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_models/shared_models.dart';

// File: admin_product_repository.dart

class AdminProductRepository {
  AdminProductRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    FirebaseStorage? storage,
    this.useCallableWrites = true,
    this.productsCollectionPath = 'products',
    this.createCallableName = 'adminCreateProduct',
    this.updateCallableName = 'adminUpdateProduct',
    this.deleteCallableName = 'adminDeleteProduct',
    this.restoreCallableName = 'adminRestoreProduct',
    this.setEnabledCallableName = 'adminSetProductEnabled',
    this.hardDeleteCallableName = 'adminHardDeleteProduct',
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1'),
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;

  final bool useCallableWrites;
  final String productsCollectionPath;
  final String createCallableName;
  final String updateCallableName;
  final String deleteCallableName;
  final String restoreCallableName;
  final String setEnabledCallableName;
  final String hardDeleteCallableName;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection(productsCollectionPath);

  FirebaseStorage get storage => _storage;

  Future<List<MBProduct>> fetchProducts({
    String searchText = '',
    String? categoryId,
    String? brandId,
    bool? isEnabled,
    bool includeDeleted = false,
    bool deletedOnly = false,
    int limit = 200,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _productsRef;

      if (deletedOnly) {
        query = query.where('isDeleted', isEqualTo: true);
      } else if (!includeDeleted) {
        query = query.where('isDeleted', isEqualTo: false);
      }

      if (categoryId != null && categoryId.trim().isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId.trim());
      }

      if (brandId != null && brandId.trim().isNotEmpty) {
        query = query.where('brandId', isEqualTo: brandId.trim());
      }

      if (isEnabled != null) {
        query = query.where('isEnabled', isEqualTo: isEnabled);
      }

      query = query.orderBy('sortOrder').orderBy('updatedAt', descending: true);

      final snapshot = await query.limit(limit).get();

      var products = snapshot.docs
          .map((doc) => _productFromDocument(doc))
          .where((product) => product.id.trim().isNotEmpty)
          .toList();

      final normalizedSearch = searchText.trim().toLowerCase();
      if (normalizedSearch.isNotEmpty) {
        products = products.where((product) {
          return _matchesSearch(product, normalizedSearch);
        }).toList();
      }

      return products;
    } catch (error, stackTrace) {
      throw AdminProductRepositoryException(
        message: 'Failed to fetch products.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Stream<List<MBProduct>> watchProducts({
    String searchText = '',
    String? categoryId,
    String? brandId,
    bool? isEnabled,
    bool includeDeleted = false,
    bool deletedOnly = false,
    int limit = 200,
  }) {
    Query<Map<String, dynamic>> query = _productsRef;

    if (deletedOnly) {
      query = query.where('isDeleted', isEqualTo: true);
    } else if (!includeDeleted) {
      query = query.where('isDeleted', isEqualTo: false);
    }

    if (categoryId != null && categoryId.trim().isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId.trim());
    }

    if (brandId != null && brandId.trim().isNotEmpty) {
      query = query.where('brandId', isEqualTo: brandId.trim());
    }

    if (isEnabled != null) {
      query = query.where('isEnabled', isEqualTo: isEnabled);
    }

    query = query.orderBy('sortOrder').orderBy('updatedAt', descending: true);

    final normalizedSearch = searchText.trim().toLowerCase();

    return query.limit(limit).snapshots().map((snapshot) {
      var products = snapshot.docs
          .map((doc) => _productFromDocument(doc))
          .where((product) => product.id.trim().isNotEmpty)
          .toList();

      if (normalizedSearch.isNotEmpty) {
        products = products.where((product) {
          return _matchesSearch(product, normalizedSearch);
        }).toList();
      }

      return products;
    });
  }

  Future<MBProduct?> getProductById(String productId) async {
    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) return null;

    try {
      final doc = await _productsRef.doc(normalizedId).get();
      if (!doc.exists || doc.data() == null) return null;
      return _productFromDocument(doc);
    } catch (error, stackTrace) {
      throw AdminProductRepositoryException(
        message: 'Failed to load product details.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<MBProduct?> getProductByIdOrNull(String productId) async {
    try {
      return await getProductById(productId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> slugExists(
      String slug, {
        String? excludeProductId,
      }) async {
    final normalizedSlug = _normalizeSlug(slug);
    if (normalizedSlug.isEmpty) return false;

    try {
      final snapshot =
      await _productsRef.where('slug', isEqualTo: normalizedSlug).limit(5).get();

      for (final doc in snapshot.docs) {
        if (excludeProductId != null && doc.id == excludeProductId.trim()) {
          continue;
        }
        return true;
      }
      return false;
    } catch (error, stackTrace) {
      throw AdminProductRepositoryException(
        message: 'Failed to validate product slug.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String> ensureUniqueSlug({
    required String preferredSlug,
    String? titleFallback,
    String? excludeProductId,
  }) async {
    var baseSlug = _normalizeSlug(preferredSlug);
    if (baseSlug.isEmpty) {
      baseSlug = _normalizeSlug(titleFallback ?? 'product');
    }
    if (baseSlug.isEmpty) {
      baseSlug = 'product';
    }

    if (!await slugExists(baseSlug, excludeProductId: excludeProductId)) {
      return baseSlug;
    }

    for (var index = 2; index <= 9999; index++) {
      final candidate = '$baseSlug-$index';
      if (!await slugExists(candidate, excludeProductId: excludeProductId)) {
        return candidate;
      }
    }

    throw AdminProductRepositoryException(
      message: 'Could not generate a unique slug for the product.',
    );
  }

  Future<MBProduct> createProduct({
    required MBProduct product,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
  }) async {
    try {
      final normalized = await prepareProductForWrite(
        product: product,
        actorUid: actorUid,
        isCreate: true,
      );

      if (useCallableWrites) {
        return _createViaCallable(
          product: normalized,
          actorUid: actorUid,
          actorName: actorName,
          actorPhone: actorPhone,
          actorRole: actorRole,
        );
      }

      return _createDirect(normalized);
    } catch (error, stackTrace) {
      if (error is AdminProductRepositoryException) rethrow;
      throw AdminProductRepositoryException(
        message: 'Failed to create product.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<MBProduct> updateProduct({
    required MBProduct product,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
  }) async {
    final productId = product.id.trim();
    if (productId.isEmpty) {
      throw AdminProductRepositoryException(
        message: 'Product id is required for update.',
      );
    }

    try {
      final normalized = await prepareProductForWrite(
        product: product,
        actorUid: actorUid,
        isCreate: false,
      );

      if (useCallableWrites) {
        return _updateViaCallable(
          product: normalized,
          actorUid: actorUid,
          actorName: actorName,
          actorPhone: actorPhone,
          actorRole: actorRole,
        );
      }

      return _updateDirect(normalized);
    } catch (error, stackTrace) {
      if (error is AdminProductRepositoryException) rethrow;
      throw AdminProductRepositoryException(
        message: 'Failed to update product.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> softDeleteProduct({
    required String productId,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
    String? reason,
  }) async {
    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) {
      throw AdminProductRepositoryException(
        message: 'Product id is required for delete.',
      );
    }

    try {
      if (useCallableWrites) {
        final callable = _functions.httpsCallable(deleteCallableName);
        await callable.call(<String, dynamic>{
          'productId': normalizedId,
          'reason': reason,
          'actorUid': actorUid,
          'actorName': actorName,
          'actorPhone': actorPhone,
          'actorRole': actorRole,
        });
        return;
      }

      await _productsRef.doc(normalizedId).set({
        'isDeleted': true,
        'deletedAt': DateTime.now().toIso8601String(),
        'deletedBy': actorUid,
        'deleteReason': reason,
        'updatedBy': actorUid,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      throw AdminProductRepositoryException(
        message: 'Failed to delete product.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> restoreProduct({
    required String productId,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
  }) async {
    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) {
      throw AdminProductRepositoryException(
        message: 'Product id is required for restore.',
      );
    }

    try {
      if (useCallableWrites) {
        final callable = _functions.httpsCallable(restoreCallableName);
        await callable.call(<String, dynamic>{
          'productId': normalizedId,
          'actorUid': actorUid,
          'actorName': actorName,
          'actorPhone': actorPhone,
          'actorRole': actorRole,
        });
        return;
      }

      await _productsRef.doc(normalizedId).set({
        'isDeleted': false,
        'deletedAt': null,
        'deletedBy': null,
        'deleteReason': null,
        'updatedBy': actorUid,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      throw AdminProductRepositoryException(
        message: 'Failed to restore product.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> hardDeleteProduct({
    required String productId,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
    String? reason,
  }) async {
    final normalizedId = productId.trim();

    if (normalizedId.isEmpty) {
      throw AdminProductRepositoryException(
        message: 'Product id is required for hard delete.',
      );
    }

    try {
      if (useCallableWrites) {
        final callable = _functions.httpsCallable(hardDeleteCallableName);

        await callable.call(<String, dynamic>{
          'productId': normalizedId,
          'reason': reason,
          'actorUid': actorUid,
          'actorName': actorName,
          'actorPhone': actorPhone,
          'actorRole': actorRole,
        });

        return;
      }

      await _productsRef.doc(normalizedId).delete();
    } catch (error, stackTrace) {
      throw AdminProductRepositoryException(
        message: 'Failed to hard delete product.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> setProductEnabled({
    required String productId,
    required bool isEnabled,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
  }) async {
    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) {
      throw AdminProductRepositoryException(
        message: 'Product id is required to change product status.',
      );
    }

    try {
      if (useCallableWrites) {
        final callable = _functions.httpsCallable(setEnabledCallableName);
        await callable.call(<String, dynamic>{
          'productId': normalizedId,
          'isEnabled': isEnabled,
          'actorUid': actorUid,
          'actorName': actorName,
          'actorPhone': actorPhone,
          'actorRole': actorRole,
        });
        return;
      }

      await _productsRef.doc(normalizedId).set({
        'isEnabled': isEnabled,
        'updatedBy': actorUid,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      throw AdminProductRepositoryException(
        message: 'Failed to update product status.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<MBProduct> prepareProductForWrite({
    required MBProduct product,
    required String actorUid,
    required bool isCreate,
  }) async {
    final now = DateTime.now();
    final productId =
    product.id.trim().isEmpty ? _productsRef.doc().id : product.id.trim();

    final uniqueSlug = await ensureUniqueSlug(
      preferredSlug: product.slug,
      titleFallback: product.titleEn,
      excludeProductId: isCreate ? null : productId,
    );

    final normalizedMediaItems = _normalizeMediaItems(
      product.mediaItems,
      fallbackThumbnailUrl: product.thumbnailUrl,
      fallbackImageUrls: product.imageUrls,
    );

    final resolvedThumbnailUrl = _resolveThumbnailUrl(
      explicitThumbnailUrl: product.thumbnailUrl,
      mediaItems: normalizedMediaItems,
    );

    final resolvedImageUrls = _resolveImageUrls(
      explicitImageUrls: product.imageUrls,
      mediaItems: normalizedMediaItems,
    );

    return product.copyWith(
      id: productId,
      slug: uniqueSlug,
      mediaItems: normalizedMediaItems,
      thumbnailUrl: resolvedThumbnailUrl,
      imageUrls: resolvedImageUrls,
      createdBy: isCreate ? actorUid : null,
      updatedBy: actorUid,
      createdAt: isCreate ? now : product.createdAt,
      updatedAt: now,
    );
  }  Future<MBProduct> _createViaCallable({
    required MBProduct product,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
  }) async {
    final callable = _functions.httpsCallable(createCallableName);

    final response = await callable.call(<String, dynamic>{
      'product': product.toMap(),
      'actorUid': actorUid,
      'actorName': actorName,
      'actorPhone': actorPhone,
      'actorRole': actorRole,
    });

    final responseProductId = _extractProductId(response.data) ?? product.id;

    final productData = _extractProductMap(response.data);
    if (productData != null) {
      final parsed = _tryParseProductMap(
        productData,
        fallbackId: responseProductId,
      );
      if (parsed != null) {
        return parsed;
      }
    }

    final saved = await getProductByIdOrNull(responseProductId);
    if (saved != null) {
      return saved;
    }

    return product.copyWith(id: responseProductId);
  }

  Future<MBProduct> _updateViaCallable({
    required MBProduct product,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
  }) async {
    final callable = _functions.httpsCallable(updateCallableName);

    final response = await callable.call(<String, dynamic>{
      'product': product.toMap(),
      'actorUid': actorUid,
      'actorName': actorName,
      'actorPhone': actorPhone,
      'actorRole': actorRole,
    });

    final responseProductId = _extractProductId(response.data) ?? product.id;

    final productData = _extractProductMap(response.data);
    if (productData != null) {
      final parsed = _tryParseProductMap(
        productData,
        fallbackId: responseProductId,
      );
      if (parsed != null) {
        return parsed;
      }
    }

    final saved = await getProductByIdOrNull(responseProductId);
    if (saved != null) {
      return saved;
    }

    return product.copyWith(id: responseProductId);
  }

  Future<MBProduct> _createDirect(MBProduct product) async {
    await _productsRef.doc(product.id).set(
      product.toMap(),
      SetOptions(merge: true),
    );

    final saved = await getProductByIdOrNull(product.id);
    return saved ?? product;
  }

  Future<MBProduct> _updateDirect(MBProduct product) async {
    await _productsRef.doc(product.id).set(
      product.toMap(),
      SetOptions(merge: true),
    );

    final saved = await getProductByIdOrNull(product.id);
    return saved ?? product;
  }

  MBProduct _productFromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final raw = doc.data() ?? const <String, dynamic>{};
    final normalized = _normalizeFirestoreMap(raw);
    normalized['id'] = (normalized['id'] ?? doc.id).toString();
    return MBProduct.fromMap(normalized);
  }

  MBProduct? _tryParseProductMap(
      Map<String, dynamic> map, {
        String? fallbackId,
      }) {
    try {
      final normalized = Map<String, dynamic>.from(map);

      final normalizedId = (normalized['id'] ?? '').toString().trim();
      if (normalizedId.isEmpty &&
          fallbackId != null &&
          fallbackId.trim().isNotEmpty) {
        normalized['id'] = fallbackId.trim();
      }

      return MBProduct.fromMap(normalized);
    } catch (_) {
      return null;
    }
  }

  bool _matchesSearch(MBProduct product, String normalizedSearch) {
    final haystacks = <String>[
      product.id,
      product.slug,
      product.productCode ?? '',
      product.sku ?? '',
      product.titleEn,
      product.titleBn,
      product.categoryNameEn ?? '',
      product.categoryNameBn ?? '',
      product.brandNameEn ?? '',
      product.brandNameBn ?? '',
      ...product.tags,
      ...product.keywords,
    ];

    for (final value in haystacks) {
      if (value.toLowerCase().contains(normalizedSearch)) {
        return true;
      }
    }

    return false;
  }

  List<MBProductMedia> _normalizeMediaItems(
      List<MBProductMedia> mediaItems, {
        required String fallbackThumbnailUrl,
        required List<String> fallbackImageUrls,
      }) {
    if (mediaItems.isNotEmpty) {
      final items = [...mediaItems]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      var hasPrimary = items.any((item) => item.isPrimary);
      if (!hasPrimary) {
        for (var index = 0; index < items.length; index++) {
          final item = items[index];
          if (index == 0) {
            items[index] = item.copyWith(isPrimary: true);
            hasPrimary = true;
          }
        }
      }

      return items;
    }

    final generated = <MBProductMedia>[];

    if (fallbackThumbnailUrl.trim().isNotEmpty) {
      generated.add(
        MBProductMedia.fromLegacyUrl(
          fallbackThumbnailUrl.trim(),
          id: 'thumbnail',
          role: 'thumbnail',
          sortOrder: 0,
          isPrimary: true,
        ),
      );
    }

    for (var index = 0; index < fallbackImageUrls.length; index++) {
      final url = fallbackImageUrls[index].trim();
      if (url.isEmpty) continue;
      if (url == fallbackThumbnailUrl.trim()) continue;

      generated.add(
        MBProductMedia.fromLegacyUrl(
          url,
          id: 'gallery_$index',
          role: 'gallery',
          sortOrder: index + 1,
          isPrimary: generated.isEmpty && index == 0,
        ),
      );
    }

    return generated;
  }

  String _resolveThumbnailUrl({
    required String explicitThumbnailUrl,
    required List<MBProductMedia> mediaItems,
  }) {
    final normalizedExplicit = explicitThumbnailUrl.trim();
    if (normalizedExplicit.isNotEmpty) return normalizedExplicit;

    for (final item in mediaItems) {
      if (!item.isEnabled) continue;
      if (item.role == 'thumbnail' || item.isPrimary) {
        final url = item.url.trim();
        if (url.isNotEmpty) return url;
      }
    }

    for (final item in mediaItems) {
      if (!item.isEnabled) continue;
      final url = item.url.trim();
      if (url.isNotEmpty) return url;
    }

    return '';
  }

  List<String> _resolveImageUrls({
    required List<String> explicitImageUrls,
    required List<MBProductMedia> mediaItems,
  }) {
    if (explicitImageUrls.isNotEmpty) {
      return explicitImageUrls
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();
    }

    return mediaItems
        .where((item) => item.isEnabled && item.type == 'image')
        .map((item) => item.url.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  Map<String, dynamic>? _extractProductMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['product'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['product'] as Map<String, dynamic>);
      }

      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        if (nestedData['product'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(
            nestedData['product'] as Map<String, dynamic>,
          );
        }

        if (nestedData.containsKey('id') && nestedData.containsKey('titleEn')) {
          return Map<String, dynamic>.from(nestedData);
        }
      }

      if (data.containsKey('id') && data.containsKey('titleEn')) {
        return Map<String, dynamic>.from(data);
      }

      return null;
    }

    if (data is Map) {
      final mapped = Map<String, dynamic>.from(data);
      return _extractProductMap(mapped);
    }

    return null;
  }

  String? _extractProductId(dynamic data) {
    if (data is Map<String, dynamic>) {
      final directId = data['productId'] ?? data['id'];
      if (directId != null && directId.toString().trim().isNotEmpty) {
        return directId.toString().trim();
      }

      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        final nestedId = nested['productId'] ?? nested['id'];
        if (nestedId != null && nestedId.toString().trim().isNotEmpty) {
          return nestedId.toString().trim();
        }
      }

      return null;
    }

    if (data is Map) {
      final mapped = Map<String, dynamic>.from(data);
      return _extractProductId(mapped);
    }

    return null;
  }
}

class AdminProductRepositoryException implements Exception {
  const AdminProductRepositoryException({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    if (cause == null) return 'AdminProductRepositoryException: $message';
    return 'AdminProductRepositoryException: $message Cause: $cause';
  }
}




String _normalizeSlug(String input) {
  var value = input.trim().toLowerCase();
  value = value.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  value = value.replaceAll(RegExp(r'-+'), '-');
  value = value.replaceAll(RegExp(r'^-|-$'), '');
  return value;
}

Map<String, dynamic> _normalizeFirestoreMap(Map<String, dynamic> source) {
  final result = <String, dynamic>{};

  source.forEach((key, value) {
    result[key] = _normalizeFirestoreValue(value);
  });

  return result;
}

dynamic _normalizeFirestoreValue(dynamic value) {
  if (value is Timestamp) {
    return value.toDate().toIso8601String();
  }

  if (value is Map<String, dynamic>) {
    return _normalizeFirestoreMap(value);
  }

  if (value is Map) {
    return _normalizeFirestoreMap(Map<String, dynamic>.from(value));
  }

  if (value is List) {
    return value.map(_normalizeFirestoreValue).toList();
  }

  return value;
}