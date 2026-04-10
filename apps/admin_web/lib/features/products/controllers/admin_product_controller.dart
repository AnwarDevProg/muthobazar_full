import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';

// File: admin_product_controller.dart

class AdminProductController extends GetxController {
  AdminProductController({
    AdminProductRepository? repository,
    this.autoLoadOnInit = true,
    this.liveStreamEnabled = false,
  }) : _repository = repository ?? AdminProductRepository();

  final AdminProductRepository _repository;
  final bool autoLoadOnInit;
  final bool liveStreamEnabled;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isHardDeleting = false.obs;
  final RxBool isRestoring = false.obs;
  final RxBool isStatusUpdating = false.obs;

  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  final RxList<MBProduct> products = <MBProduct>[].obs;

  final RxString searchQuery = ''.obs;
  final RxnString selectedCategoryId = RxnString();
  final RxnString selectedBrandId = RxnString();
  final RxnBool selectedEnabled = RxnBool();

  final RxBool includeDeleted = false.obs;
  final RxBool deletedOnly = false.obs;

  final RxInt fetchLimit = 200.obs;

  Worker? _searchDebounceWorker;
  StreamSubscription<List<MBProduct>>? _productsSubscription;

  List<MBProduct> get items => products;

  bool get hasError => errorMessage.value.trim().isNotEmpty;
  bool get hasSuccess => successMessage.value.trim().isNotEmpty;
  bool get hasData => products.isNotEmpty;
  bool get isEmptyState => !isLoading.value && !hasError && products.isEmpty;

  int get totalCount => products.length;

  int get activeCount =>
      products.where((product) => product.isEnabled && !product.isDeleted).length;

  int get inactiveCount =>
      products.where((product) => !product.isEnabled && !product.isDeleted).length;

  int get deletedCount =>
      products.where((product) => product.isDeleted).length;

  int get featuredCount =>
      products.where((product) => product.isFeatured && !product.isDeleted).length;

  int get flashSaleCount =>
      products.where((product) => product.isFlashSale && !product.isDeleted).length;

  List<MBProduct> get enabledProducts =>
      products.where((product) => product.isEnabled && !product.isDeleted).toList();

  List<MBProduct> get disabledProducts =>
      products.where((product) => !product.isEnabled && !product.isDeleted).toList();

  List<MBProduct> get deletedProducts =>
      products.where((product) => product.isDeleted).toList();

  List<MBProduct> get inStockProducts =>
      products.where((product) => product.inStock && !product.isDeleted).toList();

  @override
  void onInit() {
    super.onInit();

    _searchDebounceWorker = debounce<String>(
      searchQuery,
          (_) => refreshProducts(),
      time: const Duration(milliseconds: 350),
    );

    if (autoLoadOnInit) {
      if (liveStreamEnabled) {
        startWatchingProducts();
      } else {
        unawaited(loadProducts());
      }
    }
  }

  @override
  void onClose() {
    _searchDebounceWorker?.dispose();
    _productsSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadProducts({
    bool clearMessages = false,
  }) async {
    if (isLoading.value) return;

    if (clearMessages) {
      clearStatus();
    } else {
      clearError();
    }

    isLoading.value = true;

    try {
      final result = await _repository.fetchProducts(
        searchText: searchQuery.value,
        categoryId: selectedCategoryId.value,
        brandId: selectedBrandId.value,
        isEnabled: selectedEnabled.value,
        includeDeleted: includeDeleted.value,
        deletedOnly: deletedOnly.value,
        limit: fetchLimit.value,
      );

      products.assignAll(result);
    } catch (error) {
      errorMessage.value = _readableError(
        error,
        fallback: 'Failed to load products.',
      );
      products.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProducts() async {
    if (liveStreamEnabled) {
      startWatchingProducts();
      return;
    }
    await loadProducts();
  }

  void startWatchingProducts() {
    clearError();
    isLoading.value = true;

    _productsSubscription?.cancel();
    _productsSubscription = _repository
        .watchProducts(
      searchText: searchQuery.value,
      categoryId: selectedCategoryId.value,
      brandId: selectedBrandId.value,
      isEnabled: selectedEnabled.value,
      includeDeleted: includeDeleted.value,
      deletedOnly: deletedOnly.value,
      limit: fetchLimit.value,
    )
        .listen(
          (items) {
        products.assignAll(items);
        isLoading.value = false;
      },
      onError: (error) {
        errorMessage.value = _readableError(
          error,
          fallback: 'Failed to watch products.',
        );
        products.clear();
        isLoading.value = false;
      },
    );
  }

  Future<void> reloadWithLiveMode(bool enabled) async {
    await _productsSubscription?.cancel();
    _productsSubscription = null;

    if (enabled) {
      startWatchingProducts();
      return;
    }

    await loadProducts(clearMessages: false);
  }

  void setSearchQuery(String value) {
    final normalized = value.trim();
    if (searchQuery.value == normalized) return;
    searchQuery.value = normalized;
  }

  Future<void> setCategoryFilter(String? categoryId) async {
    final normalized = _normalizeNullable(categoryId);
    if (selectedCategoryId.value == normalized) return;
    selectedCategoryId.value = normalized;
    await refreshProducts();
  }

  Future<void> setBrandFilter(String? brandId) async {
    final normalized = _normalizeNullable(brandId);
    if (selectedBrandId.value == normalized) return;
    selectedBrandId.value = normalized;
    await refreshProducts();
  }

  Future<void> setEnabledFilter(bool? isEnabled) async {
    if (selectedEnabled.value == isEnabled) return;
    selectedEnabled.value = isEnabled;
    await refreshProducts();
  }

  Future<void> setIncludeDeleted(bool value) async {
    if (includeDeleted.value == value && !deletedOnly.value) return;
    includeDeleted.value = value;
    if (!value && deletedOnly.value) {
      deletedOnly.value = false;
    }
    await refreshProducts();
  }

  Future<void> setDeletedOnly(bool value) async {
    if (deletedOnly.value == value) return;
    deletedOnly.value = value;
    if (value) {
      includeDeleted.value = true;
    }
    await refreshProducts();
  }

  Future<void> setFetchLimit(int value) async {
    final normalized = value < 1 ? 1 : value;
    if (fetchLimit.value == normalized) return;
    fetchLimit.value = normalized;
    await refreshProducts();
  }

  Future<void> clearFilters({
    bool keepSearch = false,
  }) async {
    if (!keepSearch) {
      searchQuery.value = '';
    }
    selectedCategoryId.value = null;
    selectedBrandId.value = null;
    selectedEnabled.value = null;
    includeDeleted.value = false;
    deletedOnly.value = false;
    await refreshProducts();
  }

  MBProduct? findProductById(String productId) {
    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) return null;

    for (final product in products) {
      if (product.id == normalizedId) {
        return product;
      }
    }
    return null;
  }

  Future<MBProduct?> fetchProductDetails(String productId) async {
    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) return null;

    clearError();

    try {
      final product = await _repository.getProductById(normalizedId);
      if (product == null) {
        errorMessage.value = 'Product not found.';
        return null;
      }

      _upsertLocalProduct(product);
      return product;
    } catch (error) {
      errorMessage.value = _readableError(
        error,
        fallback: 'Failed to load product details.',
      );
      return null;
    }
  }

  Future<MBProduct?> saveProduct({
    required MBProduct product,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
  }) async {
    if (isSaving.value) return null;

    final isCreate = product.id.trim().isEmpty;

    clearStatus();
    isSaving.value = true;

    try {
      _validateProduct(product);

      final saved = isCreate
          ? await _repository.createProduct(
        product: product,
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
      )
          : await _repository.updateProduct(
        product: product,
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
      );

      _finalizeSuccessfulSave(
        saved,
        isCreate: isCreate,
      );
      return saved;
    } catch (error) {
      final recovered = await _tryRecoverSavedProduct(
        originalProduct: product,
        isCreate: isCreate,
      );

      if (recovered != null) {
        clearError();
        _finalizeSuccessfulSave(
          recovered,
          isCreate: isCreate,
        );
        return recovered;
      }

      errorMessage.value = _safeUiErrorMessage(
        error,
        fallback: 'Failed to save product.',
      );
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteProduct({
    required String productId,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
    String? reason,
  }) async {
    if (isDeleting.value) return false;

    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) {
      errorMessage.value = 'Product id is required for delete.';
      return false;
    }

    clearStatus();
    isDeleting.value = true;

    try {
      await _repository.softDeleteProduct(
        productId: normalizedId,
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        reason: reason,
      );

      final existing = findProductById(normalizedId);
      if (existing != null) {
        _upsertLocalProduct(
          existing.copyWith(
            isDeleted: true,
            deletedAt: DateTime.now(),
            deletedBy: actorUid,
            deleteReason: reason,
            updatedBy: actorUid,
            updatedAt: DateTime.now(),
          ),
        );
      }

      successMessage.value = 'Product deleted successfully.';
      _refreshProductsBestEffort();
      return true;
    } catch (error) {
      errorMessage.value = _readableError(
        error,
        fallback: 'Failed to delete product.',
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool> hardDeleteProduct({
    required String productId,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
    String? reason,
  }) async {
    if (isHardDeleting.value) return false;

    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) {
      errorMessage.value = 'Product id is required for hard delete.';
      return false;
    }

    clearStatus();
    isHardDeleting.value = true;

    try {
      await _repository.hardDeleteProduct(
        productId: normalizedId,
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
        reason: reason,
      );

      products.removeWhere((item) => item.id == normalizedId);

      successMessage.value = 'Product permanently deleted successfully.';
      _refreshProductsBestEffort();
      return true;
    } catch (error) {
      errorMessage.value = _readableError(
        error,
        fallback: 'Failed to permanently delete product.',
      );
      return false;
    } finally {
      isHardDeleting.value = false;
    }
  }

  Future<bool> restoreProduct({
    required String productId,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
  }) async {
    if (isRestoring.value) return false;

    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) {
      errorMessage.value = 'Product id is required for restore.';
      return false;
    }

    clearStatus();
    isRestoring.value = true;

    try {
      await _repository.restoreProduct(
        productId: normalizedId,
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
      );

      final existing = findProductById(normalizedId);
      if (existing != null) {
        _upsertLocalProduct(
          existing.copyWith(
            isDeleted: false,
            clearDeletedAt: true,
            clearDeletedBy: true,
            clearDeleteReason: true,
            updatedBy: actorUid,
            updatedAt: DateTime.now(),
          ),
        );
      }

      successMessage.value = 'Product restored successfully.';
      _refreshProductsBestEffort();
      return true;
    } catch (error) {
      errorMessage.value = _readableError(
        error,
        fallback: 'Failed to restore product.',
      );
      return false;
    } finally {
      isRestoring.value = false;
    }
  }  Future<bool> setProductEnabled({
    required String productId,
    required bool isEnabled,
    required String actorUid,
    String? actorName,
    String? actorPhone,
    String? actorRole,
  }) async {
    if (isStatusUpdating.value) return false;

    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) {
      errorMessage.value = 'Product id is required to change status.';
      return false;
    }

    clearStatus();
    isStatusUpdating.value = true;

    try {
      await _repository.setProductEnabled(
        productId: normalizedId,
        isEnabled: isEnabled,
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
      );

      final existing = findProductById(normalizedId);
      if (existing != null) {
        _upsertLocalProduct(
          existing.copyWith(
            isEnabled: isEnabled,
            updatedBy: actorUid,
            updatedAt: DateTime.now(),
          ),
        );
      }

      successMessage.value = isEnabled
          ? 'Product activated successfully.'
          : 'Product deactivated successfully.';

      _refreshProductsBestEffort();
      return true;
    } catch (error) {
      errorMessage.value = _readableError(
        error,
        fallback: 'Failed to update product status.',
      );
      return false;
    } finally {
      isStatusUpdating.value = false;
    }
  }

  Future<String> buildUniqueSlug({
    required String preferredSlug,
    String? titleFallback,
    String? excludeProductId,
  }) async {
    clearError();

    try {
      return await _repository.ensureUniqueSlug(
        preferredSlug: preferredSlug,
        titleFallback: titleFallback,
        excludeProductId: excludeProductId,
      );
    } catch (error) {
      errorMessage.value = _readableError(
        error,
        fallback: 'Failed to generate product slug.',
      );
      rethrow;
    }
  }

  void removeLocalProduct(String productId) {
    final normalizedId = productId.trim();
    if (normalizedId.isEmpty) return;

    products.removeWhere((product) => product.id == normalizedId);
  }

  void clearError() {
    errorMessage.value = '';
  }

  void clearSuccess() {
    successMessage.value = '';
  }

  void clearStatus() {
    clearError();
    clearSuccess();
  }

  void _finalizeSuccessfulSave(
      MBProduct saved, {
        required bool isCreate,
      }) {
    try {
      _upsertLocalProduct(saved);
    } catch (_) {
      // Ignore local list update failures after a successful backend save.
    }

    successMessage.value = isCreate
        ? 'Product created successfully.'
        : 'Product updated successfully.';

    _refreshProductsBestEffort();
  }

  Future<void> _reloadProductsSilently() async {
    final result = await _repository.fetchProducts(
      searchText: searchQuery.value,
      categoryId: selectedCategoryId.value,
      brandId: selectedBrandId.value,
      isEnabled: selectedEnabled.value,
      includeDeleted: includeDeleted.value,
      deletedOnly: deletedOnly.value,
      limit: fetchLimit.value,
    );

    products.assignAll(result);
  }

  Future<MBProduct?> _tryRecoverSavedProduct({
    required MBProduct originalProduct,
    required bool isCreate,
  }) async {
    for (var attempt = 0; attempt < 12; attempt++) {
      try {
        if (attempt > 0) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }

        final desiredId = originalProduct.id.trim();
        if (desiredId.isNotEmpty) {
          final byId = await _repository.getProductById(desiredId);
          if (byId != null) {
            return byId;
          }
        }

        final fetched = await _repository.fetchProducts(
          includeDeleted: true,
          deletedOnly: false,
          limit: fetchLimit.value,
        );

        final targetSlug = originalProduct.slug.trim().toLowerCase();
        final targetCode = (originalProduct.productCode ?? '').trim().toLowerCase();
        final targetSku = (originalProduct.sku ?? '').trim().toLowerCase();
        final targetTitleEn = originalProduct.titleEn.trim().toLowerCase();
        final targetTitleBn = originalProduct.titleBn.trim().toLowerCase();

        for (final item in fetched) {
          final itemSlug = item.slug.trim().toLowerCase();
          final itemCode = (item.productCode ?? '').trim().toLowerCase();
          final itemSku = (item.sku ?? '').trim().toLowerCase();
          final itemTitleEn = item.titleEn.trim().toLowerCase();
          final itemTitleBn = item.titleBn.trim().toLowerCase();

          if (targetSlug.isNotEmpty) {
            if (itemSlug == targetSlug || itemSlug.startsWith('$targetSlug-')) {
              return item;
            }
          }

          if (targetCode.isNotEmpty && itemCode == targetCode) {
            return item;
          }

          if (targetSku.isNotEmpty && itemSku == targetSku) {
            return item;
          }

          if (targetTitleEn.isNotEmpty && itemTitleEn == targetTitleEn) {
            return item;
          }

          if (!isCreate && targetTitleBn.isNotEmpty && itemTitleBn == targetTitleBn) {
            return item;
          }
        }
      } catch (_) {
        // Ignore recovery failures here and retry.
      }
    }

    return null;
  }

  void _refreshProductsBestEffort() {
    Future<void>.microtask(() async {
      try {
        if (liveStreamEnabled) {
          startWatchingProducts();
        } else {
          await _reloadProductsSilently();
        }
      } catch (_) {
        // Ignore refresh failures after successful actions.
      }
    });
  }

  void _upsertLocalProduct(MBProduct product) {
    final index = products.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      products.add(product);
    } else {
      products[index] = product;
    }

    final sorted = [...products]
      ..sort((a, b) {
        final bySort = a.sortOrder.compareTo(b.sortOrder);
        if (bySort != 0) return bySort;
        return b.updatedAt.compareTo(a.updatedAt);
      });

    products.assignAll(sorted);
  }

  void _validateProduct(MBProduct product) {
    if (product.titleEn.trim().isEmpty) {
      throw const AdminProductControllerException(
        message: 'English product title is required.',
      );
    }

    if (product.titleBn.trim().isEmpty) {
      throw const AdminProductControllerException(
        message: 'Bangla product title is required.',
      );
    }

    if (product.price < 0) {
      throw const AdminProductControllerException(
        message: 'Price cannot be negative.',
      );
    }

    if (product.salePrice != null && product.salePrice! < 0) {
      throw const AdminProductControllerException(
        message: 'Sale price cannot be negative.',
      );
    }

    if (product.costPrice != null && product.costPrice! < 0) {
      throw const AdminProductControllerException(
        message: 'Cost price cannot be negative.',
      );
    }

    if (product.minOrderQty != null && product.minOrderQty! < 0) {
      throw const AdminProductControllerException(
        message: 'Minimum order quantity cannot be negative.',
      );
    }

    if (product.maxOrderQty != null && product.maxOrderQty! < 0) {
      throw const AdminProductControllerException(
        message: 'Maximum order quantity cannot be negative.',
      );
    }

    if (product.stepQty != null && product.stepQty! < 0) {
      throw const AdminProductControllerException(
        message: 'Step quantity cannot be negative.',
      );
    }

    if (product.salePrice != null && product.salePrice! >= product.price) {
      throw const AdminProductControllerException(
        message: 'Sale price must be smaller than regular price.',
      );
    }

    if (product.maxOrderQty != null &&
        product.minOrderQty != null &&
        product.maxOrderQty! < product.minOrderQty!) {
      throw const AdminProductControllerException(
        message:
        'Maximum order quantity cannot be smaller than minimum order quantity.',
      );
    }
  }

  String _safeUiErrorMessage(
      Object error, {
        required String fallback,
      }) {
    final raw = _readableError(error, fallback: fallback).trim();
    final lower = raw.toLowerCase();

    if (raw.isEmpty) return fallback;
    if (lower.contains('stack overflow')) return fallback;
    if (lower.contains('firebase_functions/internal')) return fallback;
    if (lower.contains('internal')) return fallback;
    if (raw.length > 300) return fallback;

    return raw;
  }

  String _readableError(
      Object error, {
        required String fallback,
      }) {
    if (error is AdminProductControllerException) {
      return error.message;
    }

    if (error is AdminProductRepositoryException) {
      return error.message;
    }

    final raw = error.toString().trim();
    if (raw.isEmpty) return fallback;
    return raw;
  }

  String? _normalizeNullable(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}

class AdminProductControllerException implements Exception {
  const AdminProductControllerException({
    required this.message,
  });

  final String message;

  @override
  String toString() => 'AdminProductControllerException: $message';
}