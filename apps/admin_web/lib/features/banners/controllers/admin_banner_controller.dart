import 'dart:async';

import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../models/home/mb_banner.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:shared_services/shared_services.dart';
import 'admin_access_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminBannerController extends GetxController {
  final AdminBannerRepository _repository = AdminBannerRepository.instance;
  final ProfileController _profileController = Get.find<ProfileController>();
  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxList<MBBanner> banners = <MBBanner>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  StreamSubscription<List<MBBanner>>? _bannersSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenBanners();
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
          title: 'Error',
          message: 'Failed to load banners.',
        );
      },
    );
  }

  Future<void> refreshBanners() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchBannersOnce();
      banners.assignAll(items);
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh banners.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBanner(MBBanner banner) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      await _repository.createBanner(banner);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'create_banner',
        targetType: 'banner',
        targetId: banner.id,
        targetTitle: banner.titleEn,
        summary: 'Created banner "${banner.titleEn.isEmpty ? banner.id : banner.titleEn}"',
        afterData: banner.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Banner created successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to create banner.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateBanner(MBBanner banner) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final before = banners.firstWhereOrNull((e) => e.id == banner.id);

      await _repository.updateBanner(banner);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'update_banner',
        targetType: 'banner',
        targetId: banner.id,
        targetTitle: banner.titleEn,
        summary: 'Updated banner "${banner.titleEn.isEmpty ? banner.id : banner.titleEn}"',
        beforeData: before?.toMap(),
        afterData: banner.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Banner updated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update banner.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    if (isDeleting.value) return;

    try {
      isDeleting.value = true;

      final before = banners.firstWhereOrNull((e) => e.id == bannerId);

      await _repository.deleteBanner(bannerId);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'delete_banner',
        targetType: 'banner',
        targetId: bannerId,
        targetTitle: before?.titleEn ?? '',
        summary: 'Deleted banner "${before?.titleEn.isEmpty ?? true ? bannerId : before!.titleEn}"',
        beforeData: before?.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Banner deleted successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to delete banner.',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> toggleBannerActive(MBBanner banner) async {
    try {
      final updated = banner.copyWith(
        isActive: !banner.isActive,
      );

      await _repository.setBannerActiveState(
        bannerId: banner.id,
        isActive: !banner.isActive,
      );

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'toggle_banner_active',
        targetType: 'banner',
        targetId: banner.id,
        targetTitle: banner.titleEn,
        summary: updated.isActive
            ? 'Activated banner "${banner.titleEn.isEmpty ? banner.id : banner.titleEn}"'
            : 'Deactivated banner "${banner.titleEn.isEmpty ? banner.id : banner.titleEn}"',
        beforeData: banner.toMap(),
        afterData: updated.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: banner.isActive ? 'Banner deactivated.' : 'Banner activated.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update banner state.',
      );
    }
  }

  @override
  void onClose() {
    _bannersSubscription?.cancel();
    super.onClose();
  }
}












