import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_core/media/mb_image_pipeline_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminBrandController extends GetxController {
  final AdminBrandRepository _repository = AdminBrandRepository.instance;

  final RxList<MBBrand> brands = <MBBrand>[].obs;
  final RxList<MBBrand> filteredBrands = <MBBrand>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isPickingImage = false.obs;
  final RxBool isResizingImage = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString featuredFilter = 'all'.obs;
  final RxString homeFilter = 'all'.obs;

  final RxnString operationError = RxnString();

  StreamSubscription<List<MBBrand>>? _brandsSubscription;

  bool get isAnyBusy =>
      isLoading.value ||
          isSaving.value ||
          isDeleting.value ||
          isPickingImage.value ||
          isResizingImage.value;

  @override
  void onInit() {
    super.onInit();
    _listenBrands();
  }

  void clearOperationError() {
    operationError.value = null;
  }

  void _setOperationError(Object error) {
    operationError.value = error.toString();
  }

  void _listenBrands() {
    _brandsSubscription?.cancel();
    isLoading.value = true;
    clearOperationError();

    _brandsSubscription = _repository.watchBrands().listen(
          (items) {
        brands.assignAll(items);
        applyFilters();
        isLoading.value = false;
      },
      onError: (error) {
        _setOperationError(error);
        isLoading.value = false;

        MBNotification.error(
          title: 'Error',
          message: error.toString(),
        );
      },
    );
  }

  Future<void> refreshBrands() async {
    try {
      isLoading.value = true;
      clearOperationError();

      final items = await _repository.fetchBrandsOnce();
      brands.assignAll(items);
      applyFilters();
    } catch (e) {
      _setOperationError(e);

      MBNotification.error(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value.trim().toLowerCase();
    applyFilters();
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
    applyFilters();
  }

  void setFeaturedFilter(String value) {
    featuredFilter.value = value;
    applyFilters();
  }

  void setHomeFilter(String value) {
    homeFilter.value = value;
    applyFilters();
  }

  void resetFilters() {
    searchQuery.value = '';
    statusFilter.value = 'all';
    featuredFilter.value = 'all';
    homeFilter.value = 'all';
    applyFilters();
  }

  void applyFilters() {
    final query = searchQuery.value;
    final status = statusFilter.value;
    final featured = featuredFilter.value;
    final home = homeFilter.value;

    final result = brands.where((brand) {
      final matchesQuery = query.isEmpty ||
          brand.nameEn.toLowerCase().contains(query) ||
          brand.nameBn.toLowerCase().contains(query) ||
          brand.slug.toLowerCase().contains(query) ||
          brand.descriptionEn.toLowerCase().contains(query) ||
          brand.descriptionBn.toLowerCase().contains(query);

      final matchesStatus = switch (status) {
        'active' => brand.isActive,
        'inactive' => !brand.isActive,
        _ => true,
      };

      final matchesFeatured = switch (featured) {
        'featured' => brand.isFeatured,
        'notFeatured' => !brand.isFeatured,
        _ => true,
      };

      final matchesHome = switch (home) {
        'showOnHome' => brand.showOnHome,
        'hideFromHome' => !brand.showOnHome,
        _ => true,
      };

      return matchesQuery &&
          matchesStatus &&
          matchesFeatured &&
          matchesHome;
    }).toList();

    filteredBrands.assignAll(result);
  }

  String normalizeSlug(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .replaceAll(RegExp(r'-{2,}'), '-');
  }

  Future<int> suggestSortOrder({
    String? excludeBrandId,
  }) async {
    try {
      clearOperationError();
      return await _repository.suggestSortOrder(
        excludeBrandId: excludeBrandId,
      );
    } catch (e) {
      _setOperationError(e);
      rethrow;
    }
  }

  Future<bool> slugExists({
    required String slug,
    String? excludeBrandId,
  }) async {
    try {
      clearOperationError();
      return await _repository.slugExists(
        slug: normalizeSlug(slug),
        excludeBrandId: excludeBrandId,
      );
    } catch (e) {
      _setOperationError(e);
      rethrow;
    }
  }

  Future<bool> sortExists({
    required int sortOrder,
    String? excludeBrandId,
  }) async {
    try {
      clearOperationError();
      return await _repository.sortExists(
        sortOrder: sortOrder,
        excludeBrandId: excludeBrandId,
      );
    } catch (e) {
      _setOperationError(e);
      rethrow;
    }
  }

  Future<String?> getDeleteBlockReason({
    required String brandId,
  }) async {
    try {
      clearOperationError();
      return await _repository.getDeleteBlockReason(brandId);
    } catch (e) {
      _setOperationError(e);
      rethrow;
    }
  }

  Future<MBOriginalPickedImage?> pickOriginalImage() async {
    if (isSaving.value || isDeleting.value || isPickingImage.value) {
      return null;
    }

    isPickingImage.value = true;
    clearOperationError();

    try {
      final result = await MBImagePipelineService.instance.pickOriginalImage();
      return result;
    } catch (e) {
      _setOperationError(e);
      rethrow;
    } finally {
      isPickingImage.value = false;
    }
  }

  Future<MBPreparedImageSet> resizeSelectedImage({
    required MBOriginalPickedImage original,
    required int fullMaxWidth,
    required int fullMaxHeight,
    required int fullJpegQuality,
    required int thumbSize,
    required int thumbJpegQuality,
    bool requestSquareCrop = true,
  }) async {
    if (isSaving.value || isDeleting.value || isResizingImage.value) {
      throw Exception('Another brand operation is already running.');
    }

    isResizingImage.value = true;
    clearOperationError();

    try {
      final result = await MBImagePipelineService.instance
          .prepareImageSetFromOriginal(
        original: original,
        fullMaxWidth: fullMaxWidth,
        fullMaxHeight: fullMaxHeight,
        fullJpegQuality: fullJpegQuality,
        thumbSize: thumbSize,
        thumbJpegQuality: thumbJpegQuality,
        requestSquareCrop: requestSquareCrop,
      );

      return result;
    } catch (e) {
      _setOperationError(e);
      rethrow;
    } finally {
      isResizingImage.value = false;
    }
  }

  Future<void> saveBrand({
    required MBBrand brand,
    required bool isEdit,
  }) async {
    if (isSaving.value) return;

    isSaving.value = true;
    clearOperationError();

    try {
      if (isEdit) {
        await _repository.updateBrand(brand);
        MBNotification.success(
          title: 'Success',
          message: 'Brand updated successfully.',
        );
      } else {
        await _repository.createBrand(brand);
        MBNotification.success(
          title: 'Success',
          message: 'Brand created successfully.',
        );
      }
    } catch (e) {
      _setOperationError(e);

      MBNotification.error(
        title: 'Error',
        message: e.toString(),
      );

      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> createBrand(MBBrand brand) async {
    await saveBrand(
      brand: brand,
      isEdit: false,
    );
  }

  Future<void> updateBrand(MBBrand brand) async {
    await saveBrand(
      brand: brand,
      isEdit: true,
    );
  }

  Future<bool> deleteBrand(
      String brandId, {
        String? reason,
      }) async {
    if (isDeleting.value) return false;

    isDeleting.value = true;
    clearOperationError();

    try {
      final blockReason = await _repository.getDeleteBlockReason(brandId);
      if (blockReason != null && blockReason.trim().isNotEmpty) {
        throw Exception(blockReason);
      }

      await _repository.deleteBrand(
        brandId,
        reason: reason,
      );

      MBNotification.success(
        title: 'Success',
        message: 'Brand deleted successfully.',
      );

      return true;
    } catch (e) {
      _setOperationError(e);

      MBNotification.error(
        title: 'Error',
        message: e.toString(),
      );

      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool> deleteBrandModel({
    required MBBrand brand,
    String? reason,
  }) async {
    return deleteBrand(
      brand.id,
      reason: reason,
    );
  }

  Future<bool> toggleBrandActive(
      MBBrand brand, {
        String? reason,
      }) async {
    clearOperationError();

    try {
      final bool newState = !brand.isActive;

      await _repository.setBrandActiveState(
        brandId: brand.id,
        isActive: newState,
        reason: reason,
      );

      MBNotification.success(
        title: 'Success',
        message: newState ? 'Brand activated.' : 'Brand deactivated.',
      );

      return true;
    } catch (e) {
      _setOperationError(e);

      MBNotification.error(
        title: 'Error',
        message: e.toString(),
      );

      return false;
    }
  }

  @override
  void onClose() {
    _brandsSubscription?.cancel();
    super.onClose();
  }
}