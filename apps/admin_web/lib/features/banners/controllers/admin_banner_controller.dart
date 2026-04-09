import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_core/media/mb_image_pipeline_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminBannerController extends GetxController {
  final AdminBannerRepository _repository = AdminBannerRepository.instance;

  final RxList<MBBanner> banners = <MBBanner>[].obs;
  final RxList<MBBanner> filteredBanners = <MBBanner>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isPickingImage = false.obs;
  final RxBool isResizingImage = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString targetTypeFilter = 'all'.obs;

  final RxnString operationError = RxnString();

  StreamSubscription<List<MBBanner>>? _bannersSubscription;

  bool get isAnyBusy =>
      isLoading.value ||
          isSaving.value ||
          isDeleting.value ||
          isPickingImage.value ||
          isResizingImage.value;

  @override
  void onInit() {
    super.onInit();
    _listenBanners();
  }

  void clearOperationError() {
    operationError.value = null;
  }

  void _setOperationError(Object error) {
    operationError.value = error.toString();
  }

  void _listenBanners() {
    _bannersSubscription?.cancel();
    isLoading.value = true;
    clearOperationError();

    _bannersSubscription = _repository.watchBanners().listen(
          (List<MBBanner> items) {
        banners.assignAll(items);
        applyFilters();
        isLoading.value = false;
      },
      onError: (Object error) {
        _setOperationError(error);
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: error.toString(),
        );
      },
    );
  }

  Future<void> refreshBanners() async {
    try {
      isLoading.value = true;
      clearOperationError();

      final List<MBBanner> items = await _repository.fetchBannersOnce();
      banners.assignAll(items);
      applyFilters();
    } catch (error) {
      _setOperationError(error);
      MBNotification.error(
        title: 'Error',
        message: error.toString(),
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

  void setTargetTypeFilter(String value) {
    targetTypeFilter.value = value;
    applyFilters();
  }

  void resetFilters() {
    searchQuery.value = '';
    statusFilter.value = 'all';
    targetTypeFilter.value = 'all';
    applyFilters();
  }

  void applyFilters() {
    final String query = searchQuery.value;
    final String status = statusFilter.value;
    final String targetType = targetTypeFilter.value;

    final List<MBBanner> result = banners.where((MBBanner banner) {
      final bool matchesQuery =
          query.isEmpty ||
              banner.titleEn.toLowerCase().contains(query) ||
              banner.titleBn.toLowerCase().contains(query) ||
              banner.subtitleEn.toLowerCase().contains(query) ||
              banner.subtitleBn.toLowerCase().contains(query) ||
              banner.buttonTextEn.toLowerCase().contains(query) ||
              banner.buttonTextBn.toLowerCase().contains(query) ||
              banner.targetType.toLowerCase().contains(query) ||
              (banner.targetRoute ?? '').toLowerCase().contains(query) ||
              (banner.externalUrl ?? '').toLowerCase().contains(query) ||
              banner.position.toLowerCase().contains(query);

      final bool matchesStatus = switch (status) {
        'active' => banner.isActive,
        'inactive' => !banner.isActive,
        _ => true,
      };

      final bool matchesTargetType = switch (targetType) {
        'all' => true,
        _ => banner.targetType.toLowerCase() == targetType.toLowerCase(),
      };

      return matchesQuery && matchesStatus && matchesTargetType;
    }).toList();

    filteredBanners.assignAll(result);
  }

  Future<int> suggestSortOrder({
    String? excludeBannerId,
  }) async {
    try {
      clearOperationError();
      return await _repository.suggestSortOrder(
        excludeBannerId: excludeBannerId,
      );
    } catch (error) {
      _setOperationError(error);
      rethrow;
    }
  }

  Future<bool> sortExists({
    required int sortOrder,
    String? excludeBannerId,
  }) async {
    try {
      clearOperationError();
      return await _repository.sortExists(
        sortOrder: sortOrder,
        excludeBannerId: excludeBannerId,
      );
    } catch (error) {
      _setOperationError(error);
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
      return await MBImagePipelineService.instance.pickOriginalImage();
    } catch (error) {
      _setOperationError(error);
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
    bool requestSquareCrop = false,
  }) async {
    if (isSaving.value || isDeleting.value || isResizingImage.value) {
      throw Exception('Another banner operation is already running.');
    }

    isResizingImage.value = true;
    clearOperationError();

    try {
      return await MBImagePipelineService.instance.prepareImageSetFromOriginal(
        original: original,
        fullMaxWidth: fullMaxWidth,
        fullMaxHeight: fullMaxHeight,
        fullJpegQuality: fullJpegQuality,
        thumbSize: thumbSize,
        thumbJpegQuality: thumbJpegQuality,
        requestSquareCrop: requestSquareCrop,
      );
    } catch (error) {
      _setOperationError(error);
      rethrow;
    } finally {
      isResizingImage.value = false;
    }
  }

  Future<void> saveBanner({
    required MBBanner banner,
    required bool isEdit,
  }) async {
    if (isSaving.value) return;

    isSaving.value = true;
    clearOperationError();

    try {
      if (isEdit) {
        await _repository.updateBanner(banner);
        MBNotification.success(
          title: 'Success',
          message: 'Banner updated successfully.',
        );
      } else {
        await _repository.createBanner(banner);
        MBNotification.success(
          title: 'Success',
          message: 'Banner created successfully.',
        );
      }
    } catch (error) {
      _setOperationError(error);
      MBNotification.error(
        title: 'Error',
        message: error.toString(),
      );
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> createBanner(MBBanner banner) async {
    await saveBanner(
      banner: banner,
      isEdit: false,
    );
  }

  Future<void> updateBanner(MBBanner banner) async {
    await saveBanner(
      banner: banner,
      isEdit: true,
    );
  }

  Future<bool> deleteBanner(
      String bannerId, {
        String? reason,
      }) async {
    if (isDeleting.value) return false;

    isDeleting.value = true;
    clearOperationError();

    try {
      await _repository.deleteBanner(
        bannerId,
        reason: reason,
      );
      MBNotification.success(
        title: 'Success',
        message: 'Banner deleted successfully.',
      );
      return true;
    } catch (error) {
      _setOperationError(error);
      MBNotification.error(
        title: 'Error',
        message: error.toString(),
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool> toggleBannerActive(
      MBBanner banner, {
        String? reason,
      }) async {
    clearOperationError();

    try {
      final bool newState = !banner.isActive;
      await _repository.setBannerActiveState(
        bannerId: banner.id,
        isActive: newState,
        reason: reason,
      );

      MBNotification.success(
        title: 'Success',
        message: newState ? 'Banner activated.' : 'Banner deactivated.',
      );
      return true;
    } catch (error) {
      _setOperationError(error);
      MBNotification.error(
        title: 'Error',
        message: error.toString(),
      );
      return false;
    }
  }

  @override
  void onClose() {
    _bannersSubscription?.cancel();
    super.onClose();
  }
}
