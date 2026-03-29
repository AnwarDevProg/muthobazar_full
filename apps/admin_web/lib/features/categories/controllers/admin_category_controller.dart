import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_services/shared_services.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../admin_access/controllers/admin_access_controller.dart';

class AdminCategoryController extends GetxController {
  final AdminCategoryRepository _repository = AdminCategoryRepository.instance;
  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxList<MBCategory> categories = <MBCategory>[].obs;
  final RxList<MBCategory> filteredCategories = <MBCategory>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString featuredFilter = 'all'.obs;
  final RxString homeFilter = 'all'.obs;

  StreamSubscription<List<MBCategory>>? _categoriesSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenCategories();
  }

  void _listenCategories() {
    _categoriesSubscription?.cancel();
    isLoading.value = true;

    _categoriesSubscription = _repository.watchCategories().listen(
          (items) {
        categories.assignAll(items);
        applyFilters();
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load categories.',
        );
      },
    );
  }

  Future<void> refreshCategories() async {
    try {
      isLoading.value = true;
      final items = await _repository.fetchCategoriesOnce();
      categories.assignAll(items);
      applyFilters();
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh categories.',
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

    final result = categories.where((category) {
      final matchesQuery = query.isEmpty ||
          category.nameEn.toLowerCase().contains(query) ||
          category.nameBn.toLowerCase().contains(query) ||
          category.slug.toLowerCase().contains(query) ||
          category.descriptionEn.toLowerCase().contains(query) ||
          category.descriptionBn.toLowerCase().contains(query);

      final matchesStatus = switch (status) {
        'active' => category.isActive,
        'inactive' => !category.isActive,
        _ => true,
      };

      final matchesFeatured = switch (featured) {
        'featured' => category.isFeatured,
        'notFeatured' => !category.isFeatured,
        _ => true,
      };

      final matchesHome = switch (home) {
        'showOnHome' => category.showOnHome,
        'hideFromHome' => !category.showOnHome,
        _ => true,
      };

      return matchesQuery &&
          matchesStatus &&
          matchesFeatured &&
          matchesHome;
    }).toList();

    filteredCategories.assignAll(result);
  }

  Future<void> createCategory(MBCategory category) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      await _repository.createCategory(category);

      await AdminActivityLogger.log(
        adminUid: _accessController.currentAdminUid,
        adminName: _accessController.currentAdminName,
        adminEmail: _accessController.currentAdminEmail,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'create_category',
        targetType: 'category',
        targetId: category.id,
        targetTitle: category.nameEn,
        summary: 'Created category "${category.nameEn}"',
        afterData: category.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Category created successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to create category.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateCategory(MBCategory category) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      final before = categories.firstWhereOrNull((e) => e.id == category.id);

      await _repository.updateCategory(category);

      await AdminActivityLogger.log(
        adminUid: _accessController.currentAdminUid,
        adminName: _accessController.currentAdminName,
        adminEmail: _accessController.currentAdminEmail,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'update_category',
        targetType: 'category',
        targetId: category.id,
        targetTitle: category.nameEn,
        summary: 'Updated category "${category.nameEn}"',
        beforeData: before?.toMap(),
        afterData: category.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Category updated successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update category.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    if (isDeleting.value) return;

    try {
      isDeleting.value = true;

      final before = categories.firstWhereOrNull((e) => e.id == categoryId);

      await _repository.deleteCategory(categoryId);

      await AdminActivityLogger.log(
        adminUid: _accessController.currentAdminUid,
        adminName: _accessController.currentAdminName,
        adminEmail: _accessController.currentAdminEmail,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'delete_category',
        targetType: 'category',
        targetId: categoryId,
        targetTitle: before?.nameEn ?? '',
        summary: 'Deleted category "${before?.nameEn ?? categoryId}"',
        beforeData: before?.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: 'Category deleted successfully.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to delete category.',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> toggleCategoryActive(MBCategory category) async {
    try {
      final updated = category.copyWith(
        isActive: !category.isActive,
        updatedAt: DateTime.now(),
      );

      await _repository.setCategoryActiveState(
        categoryId: category.id,
        isActive: updated.isActive,
      );

      await AdminActivityLogger.log(
        adminUid: _accessController.currentAdminUid,
        adminName: _accessController.currentAdminName,
        adminEmail: _accessController.currentAdminEmail,
        adminRole: _accessController.permission.value?.role ?? '',
        action: 'toggle_category_active',
        targetType: 'category',
        targetId: category.id,
        targetTitle: category.nameEn,
        summary: updated.isActive
            ? 'Activated category "${category.nameEn}"'
            : 'Deactivated category "${category.nameEn}"',
        beforeData: category.toMap(),
        afterData: updated.toMap(),
      );

      MBNotification.success(
        title: 'Success',
        message: updated.isActive
            ? 'Category activated.'
            : 'Category deactivated.',
      );
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update category state.',
      );
    }
  }

  @override
  void onClose() {
    _categoriesSubscription?.cancel();
    super.onClose();
  }
}