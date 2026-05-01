import 'dart:async';

import 'package:flutter/foundation.dart';
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

  // DEBUG START: save / validation tracing
  final RxBool debugTracingEnabled = true.obs;
  final RxList<String> saveDebugLines = <String>[].obs;
  final RxList<String> lastValidationErrors = <String>[].obs;
  final RxList<String> lastValidationWarnings = <String>[].obs;

  String get saveDebugText => saveDebugLines.join('\n');
  bool get hasSaveDebug => saveDebugLines.isNotEmpty;

  void clearSaveDebug() {
    saveDebugLines.clear();
    lastValidationErrors.clear();
    lastValidationWarnings.clear();
  }

  void _debug(String message) {
    final line =
        '[${DateTime.now().toIso8601String()}] AdminProductController: $message';
    saveDebugLines.add(line);

    if (debugTracingEnabled.value) {
      debugPrint(line);
    }
  }
  // DEBUG END

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
  int get deletedCount => products.where((product) => product.isDeleted).length;
  int get featuredCount =>
      products.where((product) => product.isFeatured && !product.isDeleted).length;
  int get flashSaleCount =>
      products.where((product) => product.isFlashSale && !product.isDeleted).length;

  int get standardCardCount => products
      .where(
        (product) =>
    product.normalizedCardLayoutType ==
        MBProductCardLayout.standard.value &&
        !product.isDeleted,
  )
      .length;

  int get compactCardCount => products
      .where(
        (product) =>
    product.normalizedCardLayoutType ==
        MBProductCardLayout.compact.value &&
        !product.isDeleted,
  )
      .length;

  int get dealCardCount => products
      .where(
        (product) =>
    product.normalizedCardLayoutType == MBProductCardLayout.deal.value &&
        !product.isDeleted,
  )
      .length;

  int get featuredCardCount => products
      .where(
        (product) =>
    product.normalizedCardLayoutType ==
        MBProductCardLayout.featured.value &&
        !product.isDeleted,
  )
      .length;

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

    _searchDebounceWorker = debounce(
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

      products.assignAll(result.map(_normalizeProduct));
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
        products.assignAll(items.map(_normalizeProduct));
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

      final normalized = _normalizeProduct(product);
      _upsertLocalProduct(normalized);
      return normalized;
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

    final preparedProduct = _normalizeProduct(product);
    final isCreate = preparedProduct.id.trim().isEmpty;

    clearStatus();
    clearSaveDebug();
    isSaving.value = true;

    _debug('SAVE START');
    _debug(_buildProductSummary(preparedProduct));

    try {
      final report = _buildValidationReport(preparedProduct);

      lastValidationErrors.assignAll(report.blockingIssues);
      lastValidationWarnings.assignAll(report.warnings);

      if (report.blockingIssues.isNotEmpty) {
        for (final issue in report.blockingIssues) {
          _debug('BLOCKING: $issue');
        }
      }

      if (report.warnings.isNotEmpty) {
        for (final warning in report.warnings) {
          _debug('WARNING: $warning');
        }
      }

      if (report.blockingIssues.isNotEmpty) {
        errorMessage.value = report.blockingIssues.first;
        _debug('SAVE STOPPED BY VALIDATION');
        return null;
      }

      _debug(isCreate ? 'CREATE CALL START' : 'UPDATE CALL START');

      final saved = isCreate
          ? await _repository.createProduct(
        product: preparedProduct,
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
      )
          : await _repository.updateProduct(
        product: preparedProduct,
        actorUid: actorUid,
        actorName: actorName,
        actorPhone: actorPhone,
        actorRole: actorRole,
      );

      final normalizedSaved = _normalizeProduct(saved);
      _debug('SAVE SUCCESS: id=${normalizedSaved.id}');
      _finalizeSuccessfulSave(
        normalizedSaved,
        isCreate: isCreate,
      );
      return normalizedSaved;
    } catch (error, stackTrace) {
      _debug('SAVE EXCEPTION: ${error.runtimeType}');
      _debug('SAVE EXCEPTION MESSAGE: ${error.toString()}');
      _debug('STACK TRACE: $stackTrace');

      final recovered = await _tryRecoverSavedProduct(
        originalProduct: preparedProduct,
        isCreate: isCreate,
      );

      if (recovered != null) {
        _debug('RECOVERY SUCCESS: id=${recovered.id}');
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
      _debug('FINAL UI ERROR: ${errorMessage.value}');
      return null;
    } finally {
      isSaving.value = false;
      _debug('SAVE END');
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
          _normalizeProduct(
            existing.copyWith(
              isDeleted: true,
              deletedAt: DateTime.now(),
              deletedBy: actorUid,
              deleteReason: reason,
              updatedBy: actorUid,
              updatedAt: DateTime.now(),
            ),
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
          _normalizeProduct(
            existing.copyWith(
              isDeleted: false,
              clearDeletedAt: true,
              clearDeletedBy: true,
              clearDeleteReason: true,
              updatedBy: actorUid,
              updatedAt: DateTime.now(),
            ),
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
  }

  Future<bool> setProductEnabled({
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
          _normalizeProduct(
            existing.copyWith(
              isEnabled: isEnabled,
              updatedBy: actorUid,
              updatedAt: DateTime.now(),
            ),
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

    products.assignAll(result.map(_normalizeProduct));
  }

  Future<MBProduct?> _tryRecoverSavedProduct({
    required MBProduct originalProduct,
    required bool isCreate,
  }) async {
    for (var attempt = 0; attempt < 12; attempt++) {
      try {
        if (attempt > 0) {
          await Future.delayed(const Duration(milliseconds: 500));
        }

        final desiredId = originalProduct.id.trim();
        if (desiredId.isNotEmpty) {
          final byId = await _repository.getProductById(desiredId);
          if (byId != null) {
            return _normalizeProduct(byId);
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
              return _normalizeProduct(item);
            }
          }

          if (targetCode.isNotEmpty && itemCode == targetCode) {
            return _normalizeProduct(item);
          }

          if (targetSku.isNotEmpty && itemSku == targetSku) {
            return _normalizeProduct(item);
          }

          if (targetTitleEn.isNotEmpty && itemTitleEn == targetTitleEn) {
            return _normalizeProduct(item);
          }

          if (!isCreate &&
              targetTitleBn.isNotEmpty &&
              itemTitleBn == targetTitleBn) {
            return _normalizeProduct(item);
          }
        }
      } catch (_) {
        // Ignore recovery failures here and retry.
      }
    }

    return null;
  }

  void _refreshProductsBestEffort() {
    Future.microtask(() async {
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
    final normalized = _normalizeProduct(product);
    final index = products.indexWhere((item) => item.id == normalized.id);

    if (index == -1) {
      products.add(normalized);
    } else {
      products[index] = normalized;
    }

    final sorted = [...products]
      ..sort((a, b) {
        final bySort = a.sortOrder.compareTo(b.sortOrder);
        if (bySort != 0) return bySort;
        return b.updatedAt.compareTo(a.updatedAt);
      });

    products.assignAll(sorted);
  }

  ProductValidationReport _buildValidationReport(MBProduct product) {
    final blocking = <String>[];
    final warnings = <String>[];

    _validateBasicProductFields(product, blocking, warnings);
    _validateProductWindows(product, blocking, warnings);
    _validateProductOperationalRules(product, blocking, warnings);
    _validateProductTypeOwnership(product, blocking, warnings);

    final normalizedProductType = product.productType.trim().toLowerCase();
    final isVariableProduct = normalizedProductType == 'variable';

    if (isVariableProduct) {
      _validateAttributes(product.attributes, blocking, warnings);
      _validateVariations(product, blocking, warnings);
    } else {
      if (product.attributes.isNotEmpty) {
        warnings.add(
          'Attributes are present, but this product type is not variable.',
        );
      }

      if (product.variations.isNotEmpty) {
        warnings.add(
          'Variations are present, but this product type is not variable.',
        );
      }
    }

    _validatePurchaseOptions(product, blocking, warnings);

    return ProductValidationReport(
      blockingIssues: blocking,
      warnings: warnings,
    );
  }

  void _validateBasicProductFields(
      MBProduct product,
      List<String> blocking,
      List<String> warnings,
      ) {
    if (product.titleEn.trim().isEmpty) {
      blocking.add('English product title is required.');
    }

    if (product.titleBn.trim().isEmpty) {
      blocking.add('Bangla product title is required.');
    }

    if (product.slug.trim().isEmpty) {
      blocking.add('Product slug is required.');
    }

    if (product.price < 0) {
      blocking.add('Price cannot be negative.');
    }

    if (product.salePrice != null && product.salePrice! < 0) {
      blocking.add('Sale price cannot be negative.');
    }

    if (product.costPrice != null && product.costPrice! < 0) {
      blocking.add('Cost price cannot be negative.');
    }

    if (product.estimatedSchedulePrice != null &&
        product.estimatedSchedulePrice! < 0) {
      blocking.add('Estimated schedule price cannot be negative.');
    }

    if (product.stockQty < 0) {
      blocking.add('Stock quantity cannot be negative.');
    }

    if (product.regularStockQty < 0) {
      blocking.add('Regular stock quantity cannot be negative.');
    }

    if (product.reservedInstantQty < 0) {
      blocking.add('Reserved instant quantity cannot be negative.');
    }

    if (product.todayInstantCap < 0) {
      blocking.add('Today instant cap cannot be negative.');
    }

    if (product.todayInstantSold < 0) {
      blocking.add('Today instant sold cannot be negative.');
    }

    if (product.maxScheduleQtyPerDay < 0) {
      blocking.add('Maximum schedule quantity per day cannot be negative.');
    }

    if (product.minScheduleNoticeHours < 0) {
      blocking.add('Minimum schedule notice hours cannot be negative.');
    }

    if (product.reorderLevel < 0) {
      blocking.add('Reorder level cannot be negative.');
    }

    if (product.sortOrder < 0) {
      blocking.add('Sort order cannot be negative.');
    }

    if (product.quantityValue < 0) {
      blocking.add('Quantity value cannot be negative.');
    }

    if (product.tolerance < 0) {
      blocking.add('Tolerance cannot be negative.');
    }

    if (product.minOrderQty != null && product.minOrderQty! < 0) {
      blocking.add('Minimum order quantity cannot be negative.');
    }

    if (product.maxOrderQty != null && product.maxOrderQty! < 0) {
      blocking.add('Maximum order quantity cannot be negative.');
    }

    if (product.stepQty != null && product.stepQty! < 0) {
      blocking.add('Step quantity cannot be negative.');
    }

    if (product.salePrice != null && product.salePrice! >= product.price) {
      blocking.add('Sale price must be smaller than regular price.');
    }

    if (product.maxOrderQty != null &&
        product.minOrderQty != null &&
        product.maxOrderQty! < product.minOrderQty!) {
      blocking.add(
        'Maximum order quantity cannot be smaller than minimum order quantity.',
      );
    }

    // Compatibility-safe for current dialogs:
    // warn for zero, do not block save yet.
    if (product.minOrderQty != null && product.minOrderQty == 0) {
      warnings.add(
        'Minimum order quantity is 0. Current dialog may be serializing blank as zero.',
      );
    }

    if (product.maxOrderQty != null && product.maxOrderQty == 0) {
      warnings.add(
        'Maximum order quantity is 0. Current dialog may be serializing blank as zero.',
      );
    }

    if (product.stepQty != null && product.stepQty == 0) {
      warnings.add(
        'Step quantity is 0. Current dialog may be serializing blank as zero.',
      );
    }
  }

  void _validateProductWindows(
      MBProduct product,
      List<String> blocking,
      List<String> warnings,
      ) {
    final saleStartsAt = product.saleStartsAt;
    final saleEndsAt = product.saleEndsAt;

    if (saleStartsAt != null &&
        saleEndsAt != null &&
        saleStartsAt.isAfter(saleEndsAt)) {
      blocking.add('Sale start date must be before sale end date.');
    }

    final publishAt = product.publishAt;
    final unpublishAt = product.unpublishAt;

    if (publishAt != null &&
        unpublishAt != null &&
        publishAt.isAfter(unpublishAt)) {
      blocking.add('Publish date must be before unpublish date.');
    }
  }

  void _validateProductOperationalRules(
      MBProduct product,
      List<String> blocking,
      List<String> warnings,
      ) {
    final cutoffTime = (product.instantCutoffTime ?? '').trim();
    if (cutoffTime.isNotEmpty && !_isValidTime24h(cutoffTime)) {
      blocking.add('Instant cutoff time must use HH:mm format.');
    }

    if (product.trackInventory &&
        product.regularStockQty < product.reservedInstantQty) {
      warnings.add(
        'Reserved instant quantity is greater than regular stock quantity.',
      );
    }

    if (product.todayInstantSold > product.todayInstantCap) {
      blocking.add('Today instant sold cannot be greater than today instant cap.');
    }

    if (product.productType.trim().toLowerCase() == 'variable' &&
        product.variations.isEmpty) {
      blocking.add('Variable products must have at least one variation.');
    }
  }

  void _validateAttributes(
      List<MBProductAttribute> attributes,
      List<String> blocking,
      List<String> warnings,
      ) {
    final seenAttributeIds = <String>{};
    final seenAttributeCodes = <String>{};

    for (var index = 0; index < attributes.length; index++) {
      final attribute = attributes[index];
      final label = _attributeLabel(attribute, index);

      final attributeId = attribute.id.trim();
      if (attributeId.isEmpty) {
        blocking.add('$label must have an id.');
      } else if (!seenAttributeIds.add(_normalizedKey(attributeId))) {
        blocking.add('Duplicate attribute id found: $attributeId.');
      }

      if (attribute.nameEn.trim().isEmpty) {
        blocking.add('$label must have an English name.');
      }

      if (attribute.nameBn.trim().isEmpty) {
        warnings.add('$label does not have a Bangla name.');
      }

      final code = attribute.code.trim();
      if (code.isNotEmpty && !seenAttributeCodes.add(_normalizedKey(code))) {
        blocking.add('Duplicate attribute code found: $code.');
      }

      if (attribute.useForVariation && attribute.values.isEmpty) {
        blocking.add(
          '$label is marked for variation but has no attribute values.',
        );
      }

      final seenValueIds = <String>{};
      final seenValueKeys = <String>{};
      var hasEnabledValue = false;

      for (var valueIndex = 0; valueIndex < attribute.values.length; valueIndex++) {
        final value = attribute.values[valueIndex];
        final valueLabel = '$label -> value ${valueIndex + 1}';

        final valueId = value.id.trim();
        if (valueId.isEmpty) {
          blocking.add('$valueLabel must have an id.');
        } else if (!seenValueIds.add(_normalizedKey(valueId))) {
          blocking.add('$label contains duplicate attribute value id: $valueId.');
        }

        final rawValue = value.value.trim();
        if (rawValue.isEmpty) {
          blocking.add('$valueLabel must have a value.');
        } else if (!seenValueKeys.add(_normalizedKey(rawValue))) {
          blocking.add('$label contains duplicate attribute value: $rawValue.');
        }

        if (value.isEnabled) {
          hasEnabledValue = true;
        }

        if (attribute.displayType.trim().toLowerCase() == 'color' &&
            value.isEnabled &&
            (value.colorHex ?? '').trim().isEmpty) {
          warnings.add('$valueLabel should have a color hex for color display.');
        }

        if (attribute.displayType.trim().toLowerCase() == 'image' &&
            value.isEnabled &&
            (value.imageUrl ?? '').trim().isEmpty) {
          warnings.add('$valueLabel should have an image URL for image display.');
        }
      }

      if (attribute.useForVariation && !hasEnabledValue) {
        blocking.add(
          '$label must have at least one enabled value for variation use.',
        );
      }
    }
  }

  void _validateVariations(
      MBProduct product,
      List<String> blocking,
      List<String> warnings,
      ) {
    final variations = product.variations;
    if (variations.isEmpty) return;

    final seenVariationIds = <String>{};
    final seenVariationSkus = <String>{};
    final seenVariationBarcodes = <String>{};
    final seenVariationSignatures = <String>{};
    var defaultVariationCount = 0;

    final variationAttributes =
    product.attributes.where((attribute) => attribute.useForVariation).toList();

    for (var index = 0; index < variations.length; index++) {
      final variation = variations[index];
      final label = _variationLabel(variation, index);

      final variationId = variation.id.trim();
      if (variationId.isEmpty) {
        blocking.add('$label must have an id.');
      } else if (!seenVariationIds.add(_normalizedKey(variationId))) {
        blocking.add('Duplicate variation id found: $variationId.');
      }

      if (variation.price < 0) {
        blocking.add('$label price cannot be negative.');
      }

      if (variation.salePrice != null && variation.salePrice! < 0) {
        blocking.add('$label sale price cannot be negative.');
      }

      if (variation.costPrice != null && variation.costPrice! < 0) {
        blocking.add('$label cost price cannot be negative.');
      }

      if (variation.salePrice != null && variation.salePrice! >= variation.price) {
        blocking.add(
          '$label sale price must be smaller than regular variation price.',
        );
      }

      if (variation.stockQty < 0) {
        blocking.add('$label stock quantity cannot be negative.');
      }

      if (variation.reservedQty < 0) {
        blocking.add('$label reserved quantity cannot be negative.');
      }

      if (variation.trackInventory &&
          !variation.allowBackorder &&
          variation.reservedQty > variation.stockQty) {
        warnings.add(
          '$label reserved quantity is greater than variation stock quantity.',
        );
      }

      final sku = variation.sku.trim();
      if (sku.isNotEmpty && !seenVariationSkus.add(_normalizedKey(sku))) {
        blocking.add('Duplicate variation SKU found: $sku.');
      }

      final barcode = (variation.barcode ?? '').trim();
      if (barcode.isNotEmpty &&
          !seenVariationBarcodes.add(_normalizedKey(barcode))) {
        blocking.add('Duplicate variation barcode found: $barcode.');
      }

      if (variation.isDefault) {
        defaultVariationCount++;
        if (!variation.isEnabled) {
          blocking.add('Default variation must be enabled.');
        }
      }

      if (variationAttributes.isNotEmpty) {
        if (variation.attributeValues.isEmpty) {
          blocking.add(
            '$label must include attribute values for variation attributes.',
          );
        }

        final signatureParts = <String>[];

        for (final attribute in variationAttributes) {
          final value = _resolveVariationAttributeValue(
            variation: variation,
            attribute: attribute,
          );

          if (value.trim().isEmpty) {
            blocking.add(
              '$label is missing a value for variation attribute "${attribute.nameEn}".',
            );
          } else {
            signatureParts.add(
              '${_normalizedKey(attribute.id)}=${_normalizedKey(value)}',
            );
          }
        }

        final signature = signatureParts.join('|');
        if (signature.isNotEmpty && !seenVariationSignatures.add(signature)) {
          blocking.add(
            'Duplicate variation combination found for the same attribute values.',
          );
        }
      }
    }

    if (defaultVariationCount > 1) {
      blocking.add('Only one variation can be marked as default.');
    }
  }

  void _validatePurchaseOptions(
      MBProduct product,
      List<String> blocking,
      List<String> warnings,
      ) {
    final purchaseOptions = product.purchaseOptions;
    if (purchaseOptions.isEmpty) return;

    final seenOptionIds = <String>{};
    final seenDefaultKeys = <String>{};
    var defaultOptionCount = 0;

    for (var index = 0; index < purchaseOptions.length; index++) {
      final option = purchaseOptions[index];
      final label = _purchaseOptionLabel(option, index);

      final optionId = option.id.trim();
      if (optionId.isEmpty) {
        blocking.add('$label must have an id.');
      } else if (!seenOptionIds.add(_normalizedKey(optionId))) {
        blocking.add('Duplicate purchase option id found: $optionId.');
      }

      if (option.mode.trim().isEmpty) {
        blocking.add('$label must have a mode.');
      }

      if (option.labelEn.trim().isEmpty) {
        blocking.add('$label must have an English label.');
      }

      if (option.price < 0) {
        blocking.add('$label price cannot be negative.');
      }

      if (option.salePrice != null && option.salePrice! < 0) {
        blocking.add('$label sale price cannot be negative.');
      }

      if (option.salePrice != null && option.salePrice! >= option.price) {
        blocking.add('$label sale price must be smaller than regular price.');
      }

      if (option.minScheduleDays < 0) {
        blocking.add('$label minimum schedule days cannot be negative.');
      }

      if (option.maxScheduleDays < 0) {
        blocking.add('$label maximum schedule days cannot be negative.');
      }

      if (option.maxScheduleDays < option.minScheduleDays) {
        blocking.add(
          '$label maximum schedule days cannot be smaller than minimum schedule days.',
        );
      }

      if (option.maxQtyPerOrder != null && option.maxQtyPerOrder! < 0) {
        blocking.add('$label max quantity per order cannot be negative.');
      }

      final cutoffTime = (option.cutoffTime ?? '').trim();
      if (cutoffTime.isNotEmpty && !_isValidTime24h(cutoffTime)) {
        blocking.add('$label cutoff time must use HH:mm format.');
      }

      final seenShifts = <String>{};
      for (final shift in option.availableShifts) {
        final normalizedShift = _normalizedKey(shift);
        if (normalizedShift.isEmpty) {
          blocking.add('$label contains an empty available shift.');
        } else if (!seenShifts.add(normalizedShift)) {
          blocking.add('$label contains duplicate available shifts.');
        }
      }

      final normalizedMode = _normalizedKey(option.mode);

      if (option.supportsDateSelection) {
        if (!product.supportsScheduledOrder) {
          warnings.add(
            '$label supports date selection, but the product does not support scheduled order.',
          );
        }

        if (option.availableShifts.isEmpty) {
          warnings.add(
            '$label should define available shifts when date selection is enabled.',
          );
        }
      }

      if (normalizedMode == 'scheduled' && !product.supportsScheduledOrder) {
        warnings.add(
          '$label is scheduled-only, but the product does not support scheduled order.',
        );
      }

      if (normalizedMode == 'instant' && !product.supportsInstantOrder) {
        warnings.add(
          '$label is instant-only, but the product does not support instant order.',
        );
      }

      if (option.isDefault) {
        defaultOptionCount++;
        if (!option.isEnabled) {
          blocking.add('Default purchase option must be enabled.');
        }

        final defaultKey =
        normalizedMode.isEmpty ? _normalizedKey(optionId) : normalizedMode;
        if (!seenDefaultKeys.add(defaultKey)) {
          blocking.add(
            'Only one default purchase option is allowed per purchase mode.',
          );
        }
      }
    }

    if (defaultOptionCount > 1) {
      blocking.add('Only one purchase option can be marked as default.');
    }
  }

  String _resolveVariationAttributeValue({
    required MBProductVariation variation,
    required MBProductAttribute attribute,
  }) {
    final byId = variation.attributeValues[attribute.id]?.trim() ?? '';
    if (byId.isNotEmpty) return byId;

    final code = attribute.code.trim();
    if (code.isEmpty) return '';

    return variation.attributeValues[code]?.trim() ?? '';
  }

  String _attributeLabel(MBProductAttribute attribute, int index) {
    final english = attribute.nameEn.trim();
    if (english.isNotEmpty) {
      return 'Attribute "${attribute.nameEn}"';
    }

    final id = attribute.id.trim();
    if (id.isNotEmpty) {
      return 'Attribute "$id"';
    }

    return 'Attribute ${index + 1}';
  }

  String _variationLabel(MBProductVariation variation, int index) {
    final english = variation.titleEn.trim();
    if (english.isNotEmpty) {
      return 'Variation "${variation.titleEn}"';
    }

    final sku = variation.sku.trim();
    if (sku.isNotEmpty) {
      return 'Variation "$sku"';
    }

    final id = variation.id.trim();
    if (id.isNotEmpty) {
      return 'Variation "$id"';
    }

    return 'Variation ${index + 1}';
  }

  String _purchaseOptionLabel(MBProductPurchaseOption option, int index) {
    final english = option.labelEn.trim();
    if (english.isNotEmpty) {
      return 'Purchase option "${option.labelEn}"';
    }

    final id = option.id.trim();
    if (id.isNotEmpty) {
      return 'Purchase option "$id"';
    }

    return 'Purchase option ${index + 1}';
  }

  bool _isValidTime24h(String value) {
    final normalized = value.trim();
    final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(normalized);
    return match != null;
  }

  String _normalizedKey(String value) => value.trim().toLowerCase();

  String _buildProductSummary(MBProduct product) {
    return [
      'id=${product.id.isEmpty ? '<new>' : product.id}',
      'type=${product.productType}',
      'titleEn="${product.titleEn}"',
      'slug="${product.slug}"',
      'price=${product.price}',
      'salePrice=${product.salePrice}',
      'stockQty=${product.stockQty}',
      'regularStockQty=${product.regularStockQty}',
      'reservedInstantQty=${product.reservedInstantQty}',
      'todayInstantCap=${product.todayInstantCap}',
      'todayInstantSold=${product.todayInstantSold}',
      'minOrderQty=${product.minOrderQty}',
      'maxOrderQty=${product.maxOrderQty}',
      'stepQty=${product.stepQty}',
      'media=${product.mediaItems.length}',
      'attributes=${product.attributes.length}',
      'variations=${product.variations.length}',
      'purchaseOptions=${product.purchaseOptions.length}',
    ].join(' | ');
  }

  MBProduct _normalizeProduct(MBProduct product) {
    final cardConfig = product.effectiveCardConfig.normalized();

    return product.copyWith(
      cardLayoutType: cardConfig.variantId,
      cardConfig: cardConfig,
    );
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


  bool _isVariableProductType(MBProduct product) {
    return product.productType.trim().toLowerCase() == 'variable';
  }

  MBProductVariation? _primaryVariationForValidation(MBProduct product) {
    for (final item in product.variations) {
      if (item.isEnabled && item.isDefault) {
        return item;
      }
    }

    for (final item in product.variations) {
      if (item.isEnabled) {
        return item;
      }
    }

    if (product.variations.isNotEmpty) {
      return product.variations.first;
    }

    return null;
  }

  void _validateProductTypeOwnership(
      MBProduct product,
      List<String> blocking,
      List<String> warnings,
      ) {
    final isVariable = _isVariableProductType(product);

    if (isVariable) {
      if (product.variations.isEmpty) {
        blocking.add('Variable products must have at least one variation.');
      }

      if (product.mediaItems.isNotEmpty) {
        warnings.add(
          'Variable product still has product-level media. Media ownership should be variation-level.',
        );
      }

      if (product.attributes.isEmpty) {
        warnings.add(
          'Variable product has no attributes yet. Variation mapping may become unclear.',
        );
      }

      final primaryVariation = _primaryVariationForValidation(product);

      final hasVariationImage = product.variations.any(
            (item) => item.imageUrl.trim().isNotEmpty,
      );
      if (!hasVariationImage) {
        warnings.add(
          'Variable product has no variation image. Preview/root thumbnail compatibility may be weak.',
        );
      }

      final hasVariationPrice = product.variations.any(
            (item) => item.price > 0,
      );
      if (!hasVariationPrice) {
        warnings.add(
          'Variable product has no variation price greater than zero.',
        );
      }

      if (primaryVariation == null) {
        warnings.add(
          'Variable product has no primary/default variation selected yet.',
        );
      }
    } else {
      if (product.attributes.isNotEmpty) {
        warnings.add(
          'Non-variable product still has attributes. These are currently hidden in the shell.',
        );
      }

      if (product.variations.isNotEmpty) {
        warnings.add(
          'Non-variable product still has variations. These are currently hidden in the shell.',
        );
      }

      if (product.mediaItems.isEmpty) {
        warnings.add(
          'Non-variable product has no product-level media.',
        );
      }
    }
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

class ProductValidationReport {
  const ProductValidationReport({
    required this.blockingIssues,
    required this.warnings,
  });

  final List<String> blockingIssues;
  final List<String> warnings;
}

class AdminProductControllerException implements Exception {
  const AdminProductControllerException({
    required this.message,
  });

  final String message;

  @override
  String toString() => 'AdminProductControllerException: $message';
}
