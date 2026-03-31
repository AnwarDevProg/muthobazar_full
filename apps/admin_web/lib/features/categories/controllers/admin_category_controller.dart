import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminCategoryController extends GetxController {
  final AdminCategoryRepository _repository =
      AdminCategoryRepository.instance;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final RxList<MBCategory> categories = <MBCategory>[].obs;
  final RxList<MBCategory> filteredCategories = <MBCategory>[].obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString featuredFilter = 'all'.obs;
  final RxString homeFilter = 'all'.obs;

  final RxString loadError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      loadError.value = '';

      final items = await _repository.fetchCategoriesOnce();

      categories.assignAll(items);
      _applyFilters();
    } catch (e) {
      loadError.value = _readableError(e);

      Get.snackbar(
        'Categories Load Failed',
        loadError.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    List<MBCategory> result = categories.toList();

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((c) {
        return c.nameEn.toLowerCase().contains(query) ||
            c.nameBn.toLowerCase().contains(query) ||
            c.slug.toLowerCase().contains(query) ||
            c.descriptionEn.toLowerCase().contains(query) ||
            c.descriptionBn.toLowerCase().contains(query);
      }).toList();
    }

    if (statusFilter.value == 'active') {
      result = result.where((c) => c.isActive).toList();
    } else if (statusFilter.value == 'inactive') {
      result = result.where((c) => !c.isActive).toList();
    }

    if (featuredFilter.value == 'featured') {
      result = result.where((c) => c.isFeatured).toList();
    } else if (featuredFilter.value == 'notFeatured') {
      result = result.where((c) => !c.isFeatured).toList();
    }

    if (homeFilter.value == 'showOnHome') {
      result = result.where((c) => c.showOnHome).toList();
    } else if (homeFilter.value == 'hideFromHome') {
      result = result.where((c) => !c.showOnHome).toList();
    }

    result.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    filteredCategories.assignAll(result);
  }

  Future<bool> isSlugAvailable({
    required String slug,
    String? excludeCategoryId,
  }) async {
    if (slug.trim().isEmpty) return false;
    final exists = await _repository.slugExists(
      slug: slug.trim(),
      excludeCategoryId: excludeCategoryId,
    );
    return !exists;
  }

  Future<void> refreshCategories() async {
    await loadCategories();
  }

  Future<void> createCategory(MBCategory category) async {
    try {
      isSaving.value = true;

      await _repository.createCategory(category);
      await loadCategories();

      Get.snackbar(
        'Category Created',
        '${category.nameEn.trim().isEmpty ? 'Category' : category.nameEn} was created successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Create Failed',
        _readableError(e),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateCategory(MBCategory category) async {
    try {
      isSaving.value = true;

      await _repository.updateCategory(category);
      await loadCategories();

      Get.snackbar(
        'Category Updated',
        '${category.nameEn.trim().isEmpty ? 'Category' : category.nameEn} was updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        _readableError(e),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      await loadCategories();

      Get.snackbar(
        'Category Deleted',
        'The category was deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Delete Failed',
        _readableError(e),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
    }
  }

  Future<void> toggleCategoryActive(MBCategory category) async {
    try {
      await _repository.setCategoryActiveState(
        categoryId: category.id,
        isActive: !category.isActive,
      );
      await loadCategories();
    } catch (e) {
      Get.snackbar(
        'Status Update Failed',
        _readableError(e),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
      );
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
    _applyFilters();
  }

  void setFeaturedFilter(String value) {
    featuredFilter.value = value;
    _applyFilters();
  }

  void setHomeFilter(String value) {
    homeFilter.value = value;
    _applyFilters();
  }

  void resetFilters() {
    searchQuery.value = '';
    statusFilter.value = 'all';
    featuredFilter.value = 'all';
    homeFilter.value = 'all';
    _applyFilters();
  }

  String _readableError(Object error) {
    final text = error.toString();

    if (text.contains('permission-denied')) {
      return 'Firestore permission denied. Check your Firestore rules.';
    }
    if (text.contains('failed-precondition') || text.contains('index')) {
      return 'Firestore index/query problem. Check Firestore indexes and queried fields.';
    }
    if (text.contains('Timed out')) {
      return text;
    }
    if (text.contains('unavailable')) {
      return 'Firebase is temporarily unavailable. Check internet connection.';
    }
    if (text.contains('network')) {
      return 'Network problem detected. Please check your internet connection.';
    }
    if (text.contains('Failed to parse category document')) {
      return text;
    }

    return text;
  }
}