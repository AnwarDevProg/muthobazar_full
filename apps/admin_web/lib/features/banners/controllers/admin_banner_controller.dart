import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminBannerController extends GetxController {
  AdminBannerController({
    AdminBannerRepository? repository,
  }) : _repository = repository ?? AdminBannerRepository.instance;

  final AdminBannerRepository _repository;

  final RxList<MBBanner> banners = <MBBanner>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString targetTypeFilter = 'all'.obs;

  StreamSubscription<List<MBBanner>>? _bannersSubscription;

  List<MBBanner> get filteredBanners {
    final String query = searchQuery.value.trim().toLowerCase();
    final String status = statusFilter.value.trim().toLowerCase();
    final String targetType = targetTypeFilter.value.trim().toLowerCase();

    return banners.where((banner) {
      final bool matchesQuery =
          query.isEmpty ||
              banner.titleEn.toLowerCase().contains(query) ||
              banner.titleBn.toLowerCase().contains(query) ||
              banner.subtitleEn.toLowerCase().contains(query) ||
              banner.subtitleBn.toLowerCase().contains(query) ||
              (banner.targetId ?? '').toLowerCase().contains(query) ||
              (banner.targetRoute ?? '').toLowerCase().contains(query) ||
              banner.targetType.toLowerCase().contains(query);

      final bool matchesStatus = switch (status) {
        'all' => true,
        'active' => banner.isAvailable,
        'inactive' => !banner.isActive,
        'scheduledout' => banner.isActive && !banner.isWithinSchedule,
        _ => true,
      };

      final bool matchesTargetType =
      targetType == 'all' ? true : banner.targetType.toLowerCase() == targetType;

      return matchesQuery && matchesStatus && matchesTargetType;
    }).toList()
      ..sort((a, b) {
        final int sortCompare = a.sortOrder.compareTo(b.sortOrder);
        if (sortCompare != 0) return sortCompare;

        final String aTitle = a.titleEn.trim().toLowerCase();
        final String bTitle = b.titleEn.trim().toLowerCase();
        return aTitle.compareTo(bTitle);
      });
  }

  @override
  void onInit() {
    super.onInit();
    _listenBanners();
  }

  @override
  void onClose() {
    _bannersSubscription?.cancel();
    super.onClose();
  }

  void _listenBanners() {
    _bannersSubscription?.cancel();
    isLoading.value = true;

    _bannersSubscription = _repository.watchBanners().listen(
          (items) {
        banners.assignAll(items);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Load Failed',
          message: 'Unable to load banners.',
        );
      },
    );
  }

  Future<void> refreshBanners() async {
    try {
      isLoading.value = true;
      final List<MBBanner> items = await _repository.fetchBannersOnce();
      banners.assignAll(items);
    } catch (_) {
      MBNotification.error(
        title: 'Refresh Failed',
        message: 'Unable to refresh banners.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
  }

  void setTargetTypeFilter(String value) {
    targetTypeFilter.value = value;
  }

  void resetFilters() {
    searchQuery.value = '';
    statusFilter.value = 'all';
    targetTypeFilter.value = 'all';
  }

  Future<void> createBanner(MBBanner banner) async {
    if (!_validateBanner(banner)) return;

    try {
      isSaving.value = true;
      await _repository.createBanner(_sanitizeBannerForSave(banner));

      MBNotification.success(
        title: 'Banner Created',
        message: 'The banner has been created successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Create Failed',
        message: 'Unable to create banner.',
      );
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateBanner(MBBanner banner) async {
    if (banner.id.trim().isEmpty) {
      MBNotification.error(
        title: 'Update Failed',
        message: 'Banner id is missing.',
      );
      return;
    }

    if (!_validateBanner(banner)) return;

    try {
      isSaving.value = true;
      await _repository.updateBanner(_sanitizeBannerForSave(banner));

      MBNotification.success(
        title: 'Banner Updated',
        message: 'The banner has been updated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Update Failed',
        message: 'Unable to update banner.',
      );
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    final String id = bannerId.trim();
    if (id.isEmpty) {
      MBNotification.error(
        title: 'Delete Failed',
        message: 'Banner id is missing.',
      );
      return;
    }

    try {
      isSaving.value = true;
      await _repository.deleteBanner(id);

      MBNotification.success(
        title: 'Banner Deleted',
        message: 'The banner has been deleted successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Delete Failed',
        message: 'Unable to delete banner.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleBannerActive(MBBanner banner) async {
    if (banner.id.trim().isEmpty) {
      MBNotification.error(
        title: 'Update Failed',
        message: 'Banner id is missing.',
      );
      return;
    }

    try {
      await _repository.setBannerActiveState(
        bannerId: banner.id,
        isActive: !banner.isActive,
      );

      MBNotification.success(
        title: 'Banner Updated',
        message: !banner.isActive
            ? 'Banner has been activated.'
            : 'Banner has been deactivated.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Update Failed',
        message: 'Unable to change banner status.',
      );
    }
  }

  bool _validateBanner(MBBanner banner) {
    if (banner.imageUrl.trim().isEmpty) {
      MBNotification.error(
        title: 'Validation Error',
        message: 'Image URL is required.',
      );
      return false;
    }

    if (banner.sortOrder < 0) {
      MBNotification.error(
        title: 'Validation Error',
        message: 'Sort order cannot be negative.',
      );
      return false;
    }

    if (banner.startAt != null &&
        banner.endAt != null &&
        banner.endAt!.isBefore(banner.startAt!)) {
      MBNotification.error(
        title: 'Validation Error',
        message: 'End date cannot be earlier than start date.',
      );
      return false;
    }

    final String targetType = banner.targetType.trim().toLowerCase();

    if (targetType == 'product' ||
        targetType == 'category' ||
        targetType == 'brand' ||
        targetType == 'offer') {
      if ((banner.targetId ?? '').trim().isEmpty) {
        MBNotification.error(
          title: 'Validation Error',
          message: 'Target ID is required for the selected target type.',
        );
        return false;
      }
    }

    if (targetType == 'route' && (banner.targetRoute ?? '').trim().isEmpty) {
      MBNotification.error(
        title: 'Validation Error',
        message: 'Target Route is required when target type is route.',
      );
      return false;
    }

    if (targetType == 'external' && (banner.externalUrl ?? '').trim().isEmpty) {
      MBNotification.error(
        title: 'Validation Error',
        message: 'External URL is required when target type is external.',
      );
      return false;
    }

    return true;
  }

  MBBanner _sanitizeBannerForSave(MBBanner banner) {
    final String targetType = banner.targetType.trim().toLowerCase();

    return banner.copyWith(
      titleEn: banner.titleEn.trim(),
      titleBn: banner.titleBn.trim(),
      subtitleEn: banner.subtitleEn.trim(),
      subtitleBn: banner.subtitleBn.trim(),
      buttonTextEn: banner.buttonTextEn.trim(),
      buttonTextBn: banner.buttonTextBn.trim(),
      imageUrl: banner.imageUrl.trim(),
      mobileImageUrl: banner.mobileImageUrl.trim(),
      targetType: targetType.isEmpty ? 'none' : targetType,
      targetId: _normalizedOrNull(
        keepsValue: targetType == 'product' ||
            targetType == 'category' ||
            targetType == 'brand' ||
            targetType == 'offer',
        value: banner.targetId,
      ),
      clearTargetId: !(targetType == 'product' ||
          targetType == 'category' ||
          targetType == 'brand' ||
          targetType == 'offer'),
      targetRoute: _normalizedOrNull(
        keepsValue: targetType == 'route',
        value: banner.targetRoute,
      ),
      clearTargetRoute: targetType != 'route',
      externalUrl: _normalizedOrNull(
        keepsValue: targetType == 'external',
        value: banner.externalUrl,
      ),
      clearExternalUrl: targetType != 'external',
    );
  }

  String? _normalizedOrNull({
    required bool keepsValue,
    required String? value,
  }) {
    if (!keepsValue) return null;
    final String trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}