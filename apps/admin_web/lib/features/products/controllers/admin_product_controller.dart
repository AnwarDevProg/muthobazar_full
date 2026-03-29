import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';

class AdminProductController extends GetxController {
  AdminProductController({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isQuarantineLoading = false.obs;

  final RxList<MBProduct> products = <MBProduct>[].obs;
  final RxList<MBProduct> filteredProducts = <MBProduct>[].obs;
  final RxList<Map<String, dynamic>> quarantineProducts =
      <Map<String, dynamic>>[].obs;

  final RxList<AdminLookupOption> categories = <AdminLookupOption>[].obs;
  final RxList<AdminLookupOption> brands = <AdminLookupOption>[].obs;

  final TextEditingController searchController = TextEditingController();

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString categoryFilter = 'all'.obs;
  final RxString brandFilter = 'all'.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _productsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _quarantineSub;

  CollectionReference<Map<String, dynamic>> get productsCollection =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get categoriesCollection =>
      _firestore.collection('categories');

  CollectionReference<Map<String, dynamic>> get brandsCollection =>
      _firestore.collection('brands');

  CollectionReference<Map<String, dynamic>> get quarantineCollection =>
      _firestore.collection('product_quarantine');

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    _productsSub?.cancel();
    _quarantineSub?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadCategories(),
        loadBrands(),
      ]);
      _listenToProducts();
      _listenToQuarantineProducts();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    final query = await categoriesCollection
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();

    categories.assignAll(
      query.docs.map((doc) {
        final data = doc.data();
        return AdminLookupOption(
          id: doc.id,
          name: (data['name'] ?? data['titleEn'] ?? '').toString(),
        );
      }).toList(),
    );
  }

  Future<void> loadBrands() async {
    final query = await brandsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();

    brands.assignAll(
      query.docs.map((doc) {
        final data = doc.data();
        return AdminLookupOption(
          id: doc.id,
          name: (data['name'] ?? data['titleEn'] ?? '').toString(),
        );
      }).toList(),
    );
  }

  void _listenToProducts() {
    _productsSub?.cancel();

    _productsSub = productsCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final items = snapshot.docs
          .map((doc) => MBProduct.fromMap(doc.data()))
          .where((e) => e.id.isNotEmpty)
          .toList();

      products.assignAll(items);
      applyFilters();
    });
  }

  void _listenToQuarantineProducts() {
    isQuarantineLoading.value = true;
    _quarantineSub?.cancel();

    _quarantineSub = quarantineCollection
        .orderBy('deletedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        quarantineProducts.assignAll(
          snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data());
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
        isQuarantineLoading.value = false;
      },
      onError: (_) {
        isQuarantineLoading.value = false;
      },
    );
  }

  void setSearchQuery(String value) {
    searchQuery.value = value.trim().toLowerCase();
    applyFilters();
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
    applyFilters();
  }

  void setCategoryFilter(String value) {
    categoryFilter.value = value;
    applyFilters();
  }

  void setBrandFilter(String value) {
    brandFilter.value = value;
    applyFilters();
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    statusFilter.value = 'all';
    categoryFilter.value = 'all';
    brandFilter.value = 'all';
    applyFilters();
  }

  void applyFilters() {
    final query = searchQuery.value;
    final status = statusFilter.value;
    final category = categoryFilter.value;
    final brand = brandFilter.value;

    final result = products.where((product) {
      final matchesQuery = query.isEmpty ||
          product.titleEn.toLowerCase().contains(query) ||
          product.titleBn.toLowerCase().contains(query) ||
          (product.sku ?? '').toLowerCase().contains(query) ||
          (product.productCode ?? '').toLowerCase().contains(query) ||
          product.tags.any((e) => e.toLowerCase().contains(query)) ||
          product.keywords.any((e) => e.toLowerCase().contains(query));

      final matchesStatus = switch (status) {
        'enabled' => product.isEnabled,
        'disabled' => !product.isEnabled,
        'featured' => product.isFeatured,
        'bestSeller' => product.isBestSeller,
        'newArrival' => product.isNewArrival,
        'flashSale' => product.isFlashSale,
        'withAttributes' => product.hasAttributes,
        'withVariations' => product.hasVariations,
        'withPurchaseOptions' => product.hasPurchaseOptions,
        'inStock' => product.inStock,
        'outOfStock' => !product.inStock,
        _ => true,
      };

      final matchesCategory =
          category == 'all' || (product.categoryId ?? '') == category;

      final matchesBrand = brand == 'all' || (product.brandId ?? '') == brand;

      return matchesQuery && matchesStatus && matchesCategory && matchesBrand;
    }).toList();

    filteredProducts.assignAll(result);
  }

  Future<void> createProduct({
    required MBProduct product,
    AdminPickedImageFile? thumbnailFile,
    List<AdminPickedImageFile> galleryFiles = const <AdminPickedImageFile>[],
    Map<String, AdminPickedImageFile> variationImageFiles =
    const <String, AdminPickedImageFile>{},
  }) async {
    try {
      isSaving.value = true;

      final doc = productsCollection.doc();
      final productId = doc.id;

      final thumbnailUrl = await _uploadOptionalImage(
        productId: productId,
        folder: 'thumbnail',
        file: thumbnailFile,
      );

      final galleryUrls = await _uploadGalleryImages(
        productId: productId,
        files: galleryFiles,
      );

      final processedVariations = await _uploadVariationImages(
        productId: productId,
        variations: product.variations,
        variationImageFiles: variationImageFiles,
      );

      final newProduct = product.copyWith(
        id: productId,
        thumbnailUrl: thumbnailUrl ?? product.thumbnailUrl,
        imageUrls: galleryUrls.isEmpty ? product.imageUrls : galleryUrls,
        variations: processedVariations,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await doc.set(newProduct.toMap());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateProduct({
    required MBProduct existing,
    required MBProduct product,
    AdminPickedImageFile? thumbnailFile,
    List<AdminPickedImageFile> galleryFiles = const <AdminPickedImageFile>[],
    Map<String, AdminPickedImageFile> variationImageFiles =
    const <String, AdminPickedImageFile>{},
  }) async {
    try {
      isSaving.value = true;

      String thumbnailUrl = product.thumbnailUrl;
      List<String> imageUrls = List<String>.from(product.imageUrls);

      if (thumbnailFile != null) {
        final uploaded = await _uploadOptionalImage(
          productId: existing.id,
          folder: 'thumbnail',
          file: thumbnailFile,
        );
        if (uploaded != null && uploaded.isNotEmpty) {
          thumbnailUrl = uploaded;
        }
      }

      if (galleryFiles.isNotEmpty) {
        imageUrls = await _uploadGalleryImages(
          productId: existing.id,
          files: galleryFiles,
        );
      }

      final processedVariations = await _uploadVariationImages(
        productId: existing.id,
        variations: product.variations,
        variationImageFiles: variationImageFiles,
      );

      final updated = product.copyWith(
        id: existing.id,
        thumbnailUrl: thumbnailUrl,
        imageUrls: imageUrls,
        variations: processedVariations,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      await productsCollection.doc(existing.id).set(updated.toMap());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleEnabled(MBProduct product, bool value) async {
    final updated = product.copyWith(
      isEnabled: value,
      updatedAt: DateTime.now(),
    );

    await productsCollection.doc(product.id).set(updated.toMap());
  }

  Future<void> softDisableProduct(MBProduct product) async {
    final updated = product.copyWith(
      isEnabled: false,
      updatedAt: DateTime.now(),
    );

    await productsCollection.doc(product.id).set(updated.toMap());
  }

  Future<void> softDeleteProduct(MBProduct product) async {
    final now = DateTime.now();
    final deleteAfterAt = now.add(const Duration(days: 30));

    final quarantineDoc = quarantineCollection.doc(product.id);

    await _firestore.runTransaction((transaction) async {
      transaction.set(quarantineDoc, {
        'id': product.id,
        'productData': product.toMap(),
        'deletedAt': now.toIso8601String(),
        'deleteAfterAt': deleteAfterAt.toIso8601String(),
      });

      transaction.delete(productsCollection.doc(product.id));
    });
  }

  Future<void> restoreProduct(String productId) async {
    final quarantineDoc = await quarantineCollection.doc(productId).get();
    if (!quarantineDoc.exists) return;

    final data = quarantineDoc.data();
    if (data == null) return;

    final productData =
    Map<String, dynamic>.from(data['productData'] as Map<String, dynamic>? ?? {});

    final restored = MBProduct.fromMap(productData).copyWith(
      updatedAt: DateTime.now(),
    );

    await _firestore.runTransaction((transaction) async {
      transaction.set(productsCollection.doc(productId), restored.toMap());
      transaction.delete(quarantineCollection.doc(productId));
    });
  }

  Future<void> hardDeleteQuarantineProduct(String productId) async {
    await quarantineCollection.doc(productId).delete();
  }

  Future<void> deleteProduct(MBProduct product) async {
    await productsCollection.doc(product.id).delete();
  }

  Future<String?> _uploadOptionalImage({
    required String productId,
    required String folder,
    required AdminPickedImageFile? file,
  }) async {
    if (file == null || file.bytes == null) return null;

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final ref = _storage.ref().child('products/$productId/$folder/$fileName');

    await ref.putData(
      file.bytes!,
      SettableMetadata(contentType: file.mimeType),
    );

    return ref.getDownloadURL();
  }

  Future<List<String>> _uploadGalleryImages({
    required String productId,
    required List<AdminPickedImageFile> files,
  }) async {
    if (files.isEmpty) return <String>[];

    final urls = <String>[];

    for (final file in files) {
      if (file.bytes == null) continue;

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = _storage.ref().child('products/$productId/gallery/$fileName');

      await ref.putData(
        file.bytes!,
        SettableMetadata(contentType: file.mimeType),
      );

      urls.add(await ref.getDownloadURL());
    }

    return urls;
  }

  Future<List<MBProductVariation>> _uploadVariationImages({
    required String productId,
    required List<MBProductVariation> variations,
    required Map<String, AdminPickedImageFile> variationImageFiles,
  }) async {
    if (variations.isEmpty) return variations;

    final result = <MBProductVariation>[];

    for (final variation in variations) {
      final imageFile = variationImageFiles[variation.id];

      if (imageFile == null || imageFile.bytes == null) {
        result.add(variation);
        continue;
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final ref = _storage
          .ref()
          .child('products/$productId/variations/${variation.id}/$fileName');

      await ref.putData(
        imageFile.bytes!,
        SettableMetadata(contentType: imageFile.mimeType),
      );

      final imageUrl = await ref.getDownloadURL();
      result.add(variation.copyWith(imageUrl: imageUrl));
    }

    return result;
  }
}

class AdminLookupOption {
  AdminLookupOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class AdminPickedImageFile {
  AdminPickedImageFile({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  final String name;
  final Uint8List? bytes;
  final String mimeType;
}