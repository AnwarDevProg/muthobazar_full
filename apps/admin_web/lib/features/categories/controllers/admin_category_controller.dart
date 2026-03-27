import 'dart:async';

import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../models/catalog/mb_category.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:shared_services/shared_services.dart';
import 'admin_access_controller.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminCategoryController extends GetxController {
  final AdminCategoryRepository _repository = AdminCategoryRepository.instance;
  final ProfileController _profileController = Get.find<ProfileController>();
  final AdminAccessController _accessController =
  Get.find<AdminAccessController>();

  final RxList<MBCategory> categories = <MBCategory>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

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
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh categories.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createCategory(MBCategory category) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;

      await _repository.createCategory(category);

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
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
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
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
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
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
        isActive: !category.isActive,
      );

      await AdminActivityLogger.log(
        adminUid: _profileController.user.value.id,
        adminName: _profileController.fullName,
        adminEmail: _profileController.user.value.email,
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
        message: category.isActive
            ? 'Category deactivated.'
            : 'Category activated.',
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












