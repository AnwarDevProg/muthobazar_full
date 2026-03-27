import 'dart:async';

import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../models/catalog/mb_brand.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:shared_services/shared_services.dart';
import 'admin_access_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminBrandController extends GetxController {
  final AdminBrandRepository _repository = AdminBrandRepository.instance;
  final ProfileController _profileController = Get.find<ProfileController>();
  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxList<MBBrand> brands = <MBBrand>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  StreamSubscription<List<MBBrand>>? _brandsSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenBrands();
  }

  void _listenBrands() {
    _brandsSubscription?.cancel();
    isLoading.value = true;

    _brandsSubscription = _repository.watchBrands().listen(
          (items) {
        brands.assignAll(items);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load brands.',
        );
      },
    );
  }

  Future<void> refreshBrands() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchBrandsOnce();
      brands.assignAll(items);
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh brands.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBrand(MBBrand brand) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      await _repository.createBrand(brand);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'create_brand',
        targetType: 'brand',
        targetId: brand.id,
        targetTitle: brand.nameEn,
        summary: 'Created brand "${brand.nameEn}"',
        afterData: brand.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Brand created successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to create brand.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateBrand(MBBrand brand) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final before = brands.firstWhereOrNull((e) => e.id == brand.id);

      await _repository.updateBrand(brand);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'update_brand',
        targetType: 'brand',
        targetId: brand.id,
        targetTitle: brand.nameEn,
        summary: 'Updated brand "${brand.nameEn}"',
        beforeData: before?.toMap(),
        afterData: brand.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Brand updated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update brand.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteBrand(String brandId) async {
    if (isDeleting.value) return;

    try {
      isDeleting.value = true;

      final before = brands.firstWhereOrNull((e) => e.id == brandId);

      await _repository.deleteBrand(brandId);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'delete_brand',
        targetType: 'brand',
        targetId: brandId,
        targetTitle: before?.nameEn ?? '',
        summary: 'Deleted brand "${before?.nameEn ?? brandId}"',
        beforeData: before?.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Brand deleted successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to delete brand.',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> toggleBrandActive(MBBrand brand) async {
    try {
      final updated = brand.copyWith(
        isActive: !brand.isActive,
        updatedAt: DateTime.now(),
      );

      await _repository.setBrandActiveState(
        brandId: brand.id,
        isActive: !brand.isActive,
      );

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'toggle_brand_active',
        targetType: 'brand',
        targetId: brand.id,
        targetTitle: brand.nameEn,
        summary: updated.isActive
            ? 'Activated brand "${brand.nameEn}"'
            : 'Deactivated brand "${brand.nameEn}"',
        beforeData: brand.toMap(),
        afterData: updated.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: brand.isActive ? 'Brand deactivated.' : 'Brand activated.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update brand state.',
      );
    }
  }

  @override
  void onClose() {
    _brandsSubscription?.cancel();
    super.onClose();
  }
}












