import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_services/shared_services.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../admin_access/controllers/admin_access_controller.dart';

class AdminBrandController extends GetxController {
  final AdminBrandRepository _repository = AdminBrandRepository.instance;
  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxList<MBBrand> brands = <MBBrand>[].obs;
  final RxList<MBBrand> filteredBrands = <MBBrand>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString featuredFilter = 'all'.obs;
  final RxString homeFilter = 'all'.obs;

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
        applyFilters();
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
      applyFilters();
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh brands.',
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

  Future<void> createBrand(MBBrand brand) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      await _repository.createBrand(brand);
      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

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

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

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

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

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
        isActive: updated.isActive,
      );

      /// Insert actual logger during development
      /// await AdminActivityLogger.log(      );

      MBNotification.success(
        title: 'Success',
        message: updated.isActive
            ? 'Brand activated.'
            : 'Brand deactivated.',
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