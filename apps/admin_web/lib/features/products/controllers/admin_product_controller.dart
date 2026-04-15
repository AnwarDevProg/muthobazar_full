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
    product.normalizedCardLayoutType ==
        MBProductCardLayout.deal.value &&
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
    isSaving.value = true;

    try {
      _validateProduct(preparedProduct);

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
      _finalizeSuccessfulSave(
        normalizedSaved,
        isCreate: isCreate,
      );
      return normalizedSaved;
    } catch (error) {
      final recovered = await _tryRecoverSavedProduct(
        originalProduct: preparedProduct,
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

          if (!isCreate && targetTitleBn.isNotEmpty && itemTitleBn == targetTitleBn) {
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

  void _validateProduct(MBProduct product) {
    _validateBasicProductFields(product);
    _validateProductWindows(product);
    _validateProductOperationalRules(product);
    _validateAttributes(product.attributes);
    _validateVariations(product);
    _validatePurchaseOptions(product);
  }

  void _validateBasicProductFields(MBProduct product) {
    if (product.titleEn.trim().isEmpty) {
      _throwValidation('English product title is required.');
    }

    if (product.titleBn.trim().isEmpty) {
      _throwValidation('Bangla product title is required.');
    }

    if (product.slug.trim().isEmpty) {
      _throwValidation('Product slug is required.');
    }

    if (product.price < 0) {
      _throwValidation('Price cannot be negative.');
    }

    if (product.salePrice != null && product.salePrice! < 0) {
      _throwValidation('Sale price cannot be negative.');
    }

    if (product.costPrice != null && product.costPrice! < 0) {
      _throwValidation('Cost price cannot be negative.');
    }

    if (product.estimatedSchedulePrice != null &&
        product.estimatedSchedulePrice! < 0) {
      _throwValidation('Estimated schedule price cannot be negative.');
    }

    if (product.stockQty < 0) {
      _throwValidation('Stock quantity cannot be negative.');
    }

    if (product.regularStockQty < 0) {
      _throwValidation('Regular stock quantity cannot be negative.');
    }

    if (product.reservedInstantQty < 0) {
      _throwValidation('Reserved instant quantity cannot be negative.');
    }

    if (product.todayInstantCap < 0) {
      _throwValidation('Today instant cap cannot be negative.');
    }

    if (product.todayInstantSold < 0) {
      _throwValidation('Today instant sold cannot be negative.');
    }

    if (product.maxScheduleQtyPerDay < 0) {
      _throwValidation('Maximum schedule quantity per day cannot be negative.');
    }

    if (product.minScheduleNoticeHours < 0) {
      _throwValidation('Minimum schedule notice hours cannot be negative.');
    }

    if (product.reorderLevel < 0) {
      _throwValidation('Reorder level cannot be negative.');
    }

    if (product.sortOrder < 0) {
      _throwValidation('Sort order cannot be negative.');
    }

    if (product.quantityValue < 0) {
      _throwValidation('Quantity value cannot be negative.');
    }

    if (product.tolerance < 0) {
      _throwValidation('Tolerance cannot be negative.');
    }

    if (product.minOrderQty != null && product.minOrderQty! < 0) {
      _throwValidation('Minimum order quantity cannot be negative.');
    }

    if (product.maxOrderQty != null && product.maxOrderQty! < 0) {
      _throwValidation('Maximum order quantity cannot be negative.');
    }

    if (product.stepQty != null && product.stepQty! < 0) {
      _throwValidation('Step quantity cannot be negative.');
    }

    if (product.salePrice != null && product.salePrice! >= product.price) {
      _throwValidation('Sale price must be smaller than regular price.');
    }

    if (product.maxOrderQty != null &&
        product.minOrderQty != null &&
        product.maxOrderQty! < product.minOrderQty!) {
      _throwValidation(
        'Maximum order quantity cannot be smaller than minimum order quantity.',
      );
    }

    if (product.minOrderQty != null && product.minOrderQty! == 0) {
      _throwValidation('Minimum order quantity must be greater than zero.');
    }

    if (product.maxOrderQty != null && product.maxOrderQty! == 0) {
      _throwValidation('Maximum order quantity must be greater than zero.');
    }

    if (product.stepQty != null && product.stepQty! == 0) {
      _throwValidation('Step quantity must be greater than zero.');
    }
  }

  void _validateProductWindows(MBProduct product) {
    final saleStartsAt = product.saleStartsAt;
    final saleEndsAt = product.saleEndsAt;

    if (saleStartsAt != null &&
        saleEndsAt != null &&
        saleStartsAt.isAfter(saleEndsAt)) {
      _throwValidation('Sale start date must be before sale end date.');
    }

    final publishAt = product.publishAt;
    final unpublishAt = product.unpublishAt;

    if (publishAt != null &&
        unpublishAt != null &&
        publishAt.isAfter(unpublishAt)) {
      _throwValidation('Publish date must be before unpublish date.');
    }
  }

  void _validateProductOperationalRules(MBProduct product) {
    final cutoffTime = (product.instantCutoffTime ?? '').trim();
    if (cutoffTime.isNotEmpty && !_isValidTime24h(cutoffTime)) {
      _throwValidation('Instant cutoff time must use HH:mm format.');
    }

    if (product.trackInventory &&
        product.regularStockQty < product.reservedInstantQty) {
      _throwValidation(
        'Reserved instant quantity cannot exceed regular stock quantity.',
      );
    }

    if (product.todayInstantSold > product.todayInstantCap) {
      _throwValidation(
        'Today instant sold cannot be greater than today instant cap.',
      );
    }

    if (product.productType.trim().toLowerCase() == 'variable' &&
        product.variations.isEmpty) {
      _throwValidation(
        'Variable products must have at least one variation.',
      );
    }
  }

  void _validateAttributes(List<MBProductAttribute> attributes) {
    final seenAttributeIds = <String>{};
    final seenAttributeCodes = <String>{};

    for (var index = 0; index < attributes.length; index++) {
      final attribute = attributes[index];
      final label = _attributeLabel(attribute, index);

      final attributeId = attribute.id.trim();
      if (attributeId.isEmpty) {
        _throwValidation('$label must have an id.');
      }

      if (!seenAttributeIds.add(_normalizedKey(attributeId))) {
        _throwValidation('Duplicate attribute id found: $attributeId.');
      }

      if (attribute.nameEn.trim().isEmpty) {
        _throwValidation('$label must have an English name.');
      }

      if (attribute.nameBn.trim().isEmpty) {
        _throwValidation('$label must have a Bangla name.');
      }

      final code = attribute.code.trim();
      if (code.isNotEmpty && !seenAttributeCodes.add(_normalizedKey(code))) {
        _throwValidation('Duplicate attribute code found: $code.');
      }

      if (attribute.useForVariation && attribute.values.isEmpty) {
        _throwValidation(
          '$label is marked for variation but has no attribute values.',
        );
      }

      final seenValueIds = <String>{};
      final seenValueKeys = <String>{};
      var hasEnabledValue = false;

      for (var valueIndex = 0;
      valueIndex < attribute.values.length;
      valueIndex++) {
        final value = attribute.values[valueIndex];
        final valueLabel = '$label → value ${valueIndex + 1}';

        final valueId = value.id.trim();
        if (valueId.isEmpty) {
          _throwValidation('$valueLabel must have an id.');
        }

        if (!seenValueIds.add(_normalizedKey(valueId))) {
          _throwValidation(
            '$label contains duplicate attribute value id: $valueId.',
          );
        }

        final rawValue = value.value.trim();
        if (rawValue.isEmpty) {
          _throwValidation('$valueLabel must have a value.');
        }

        final valueKey = _normalizedKey(rawValue);
        if (!seenValueKeys.add(valueKey)) {
          _throwValidation(
            '$label contains duplicate attribute value: $rawValue.',
          );
        }

        if (value.isEnabled) {
          hasEnabledValue = true;
        }

        if (attribute.displayType.trim().toLowerCase() == 'color' &&
            value.isEnabled &&
            (value.colorHex ?? '').trim().isEmpty) {
          _throwValidation(
            '$valueLabel must have a color hex for color display type.',
          );
        }

        if (attribute.displayType.trim().toLowerCase() == 'image' &&
            value.isEnabled &&
            (value.imageUrl ?? '').trim().isEmpty) {
          _throwValidation(
            '$valueLabel must have an image URL for image display type.',
          );
        }
      }

      if (attribute.useForVariation && !hasEnabledValue) {
        _throwValidation(
          '$label must have at least one enabled value for variation use.',
        );
      }
    }
  }

  void _validateVariations(MBProduct product) {
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
        _throwValidation('$label must have an id.');
      }

      if (!seenVariationIds.add(_normalizedKey(variationId))) {
        _throwValidation('Duplicate variation id found: $variationId.');
      }

      if (variation.price < 0) {
        _throwValidation('$label price cannot be negative.');
      }

      if (variation.salePrice != null && variation.salePrice! < 0) {
        _throwValidation('$label sale price cannot be negative.');
      }

      if (variation.costPrice != null && variation.costPrice! < 0) {
        _throwValidation('$label cost price cannot be negative.');
      }

      if (variation.salePrice != null &&
          variation.salePrice! >= variation.price) {
        _throwValidation(
          '$label sale price must be smaller than regular variation price.',
        );
      }

      if (variation.stockQty < 0) {
        _throwValidation('$label stock quantity cannot be negative.');
      }

      if (variation.reservedQty < 0) {
        _throwValidation('$label reserved quantity cannot be negative.');
      }

      if (variation.trackInventory &&
          !variation.allowBackorder &&
          variation.reservedQty > variation.stockQty) {
        _throwValidation(
          '$label reserved quantity cannot exceed variation stock quantity.',
        );
      }

      final sku = variation.sku.trim();
      if (sku.isNotEmpty && !seenVariationSkus.add(_normalizedKey(sku))) {
        _throwValidation('Duplicate variation SKU found: $sku.');
      }

      final barcode = (variation.barcode ?? '').trim();
      if (barcode.isNotEmpty &&
          !seenVariationBarcodes.add(_normalizedKey(barcode))) {
        _throwValidation('Duplicate variation barcode found: $barcode.');
      }

      if (variation.isDefault) {
        defaultVariationCount++;
        if (!variation.isEnabled) {
          _throwValidation('Default variation must be enabled.');
        }
      }

      if (variationAttributes.isNotEmpty) {
        if (variation.attributeValues.isEmpty) {
          _throwValidation(
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
            _throwValidation(
              '$label is missing a value for variation attribute "${attribute.nameEn}".',
            );
          }

          signatureParts.add(
            '${_normalizedKey(attribute.id)}=${_normalizedKey(value)}',
          );
        }

        final signature = signatureParts.join('|');
        if (signature.isNotEmpty && !seenVariationSignatures.add(signature)) {
          _throwValidation(
            'Duplicate variation combination found for the same attribute values.',
          );
        }
      }
    }

    if (defaultVariationCount > 1) {
      _throwValidation('Only one variation can be marked as default.');
    }
  }

  void _validatePurchaseOptions(MBProduct product) {
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
        _throwValidation('$label must have an id.');
      }

      if (!seenOptionIds.add(_normalizedKey(optionId))) {
        _throwValidation('Duplicate purchase option id found: $optionId.');
      }

      if (option.mode.trim().isEmpty) {
        _throwValidation('$label must have a mode.');
      }

      if (option.labelEn.trim().isEmpty) {
        _throwValidation('$label must have an English label.');
      }

      if (option.price < 0) {
        _throwValidation('$label price cannot be negative.');
      }

      if (option.salePrice != null && option.salePrice! < 0) {
        _throwValidation('$label sale price cannot be negative.');
      }

      if (option.salePrice != null && option.salePrice! >= option.price) {
        _throwValidation('$label sale price must be smaller than regular price.');
      }

      if (option.minScheduleDays < 0) {
        _throwValidation('$label minimum schedule days cannot be negative.');
      }

      if (option.maxScheduleDays < 0) {
        _throwValidation('$label maximum schedule days cannot be negative.');
      }

      if (option.maxScheduleDays < option.minScheduleDays) {
        _throwValidation(
          '$label maximum schedule days cannot be smaller than minimum schedule days.',
        );
      }

      if (option.maxQtyPerOrder != null && option.maxQtyPerOrder! <= 0) {
        _throwValidation('$label max quantity per order must be greater than zero.');
      }

      final cutoffTime = (option.cutoffTime ?? '').trim();
      if (cutoffTime.isNotEmpty && !_isValidTime24h(cutoffTime)) {
        _throwValidation('$label cutoff time must use HH:mm format.');
      }

      final seenShifts = <String>{};
      for (final shift in option.availableShifts) {
        final normalizedShift = _normalizedKey(shift);
        if (normalizedShift.isEmpty) {
          _throwValidation('$label contains an empty available shift.');
        }
        if (!seenShifts.add(normalizedShift)) {
          _throwValidation('$label contains duplicate available shifts.');
        }
      }

      final normalizedMode = _normalizedKey(option.mode);

      if (option.supportsDateSelection) {
        if (!product.supportsScheduledOrder) {
          _throwValidation(
            '$label supports date selection but the product does not support scheduled order.',
          );
        }

        if (option.availableShifts.isEmpty) {
          _throwValidation(
            '$label must define available shifts when date selection is enabled.',
          );
        }
      }

      if (normalizedMode == 'scheduled' && !product.supportsScheduledOrder) {
        _throwValidation(
          '$label is scheduled-only, but the product does not support scheduled order.',
        );
      }

      if (normalizedMode == 'instant' && !product.supportsInstantOrder) {
        _throwValidation(
          '$label is instant-only, but the product does not support instant order.',
        );
      }

      if (option.isDefault) {
        defaultOptionCount++;
        if (!option.isEnabled) {
          _throwValidation('Default purchase option must be enabled.');
        }

        final defaultKey = normalizedMode.isEmpty
            ? _normalizedKey(optionId)
            : normalizedMode;
        if (!seenDefaultKeys.add(defaultKey)) {
          _throwValidation(
            'Only one default purchase option is allowed per purchase mode.',
          );
        }
      }
    }

    if (defaultOptionCount > 1) {
      _throwValidation('Only one purchase option can be marked as default.');
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

  Never _throwValidation(String message) {
    throw AdminProductControllerException(message: message);
  }

  MBProduct _normalizeProduct(MBProduct product) {
    return product.copyWith(
      cardLayoutType: MBProductCardLayoutHelper.normalize(
        product.cardLayoutType,
      ),
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