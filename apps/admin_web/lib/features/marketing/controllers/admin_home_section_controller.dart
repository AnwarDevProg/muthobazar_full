import 'dart:async';

import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminHomeSectionController extends GetxController {
  final AdminHomeSectionRepository _repository =
      AdminHomeSectionRepository.instance;

  final RxList<MBHomeSection> sections = <MBHomeSection>[].obs;
  final RxList<MBHomeSection> filteredSections = <MBHomeSection>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isRefreshing = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString sectionTypeFilter = 'all'.obs;
  final RxString dataSourceFilter = 'all'.obs;
  final RxString layoutFilter = 'all'.obs;

  StreamSubscription<List<MBHomeSection>>? _sectionsSubscription;

  bool get isBusy =>
      isLoading.value ||
          isSaving.value ||
          isDeleting.value ||
          isRefreshing.value;

  @override
  void onInit() {
    super.onInit();
    _listenSections();
  }

  void _listenSections() {
    _sectionsSubscription?.cancel();
    isLoading.value = true;

    _sectionsSubscription = _repository.watchSections().listen(
          (items) {
        sections.assignAll(items);
        applyFilters();
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        MBNotification.error(
          title: 'Error',
          message: 'Failed to load home sections.',
        );
      },
    );
  }

  Future<void> refreshSections() async {
    try {
      isRefreshing.value = true;
      final items = await _repository.fetchSectionsOnce();
      sections.assignAll(items);
      applyFilters();
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to refresh home sections.',
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  void setSearchQuery(String value) {
    searchQuery.value = value.trim().toLowerCase();
    applyFilters();
  }

  void setStatusFilter(String value) {
    statusFilter.value = value.trim();
    applyFilters();
  }

  void setSectionTypeFilter(String value) {
    sectionTypeFilter.value = value.trim();
    applyFilters();
  }

  void setDataSourceFilter(String value) {
    dataSourceFilter.value = value.trim();
    applyFilters();
  }

  void setLayoutFilter(String value) {
    layoutFilter.value = value.trim();
    applyFilters();
  }

  void resetFilters() {
    searchQuery.value = '';
    statusFilter.value = 'all';
    sectionTypeFilter.value = 'all';
    dataSourceFilter.value = 'all';
    layoutFilter.value = 'all';
    applyFilters();
  }

  void applyFilters() {
    final query = searchQuery.value;
    final status = statusFilter.value;
    final sectionType = sectionTypeFilter.value;
    final dataSource = dataSourceFilter.value;
    final layout = layoutFilter.value;

    final result = sections.where((section) {
      final titleEn = section.titleEn.trim().toLowerCase();
      final titleBn = section.titleBn.trim().toLowerCase();
      final subtitleEn = section.subtitleEn.trim().toLowerCase();
      final subtitleBn = section.subtitleBn.trim().toLowerCase();
      final type = section.sectionType.trim().toLowerCase();
      final sourceType = section.dataSourceType.trim().toLowerCase();
      final style = section.layoutStyle.trim().toLowerCase();
      final sourceCategoryId =
      (section.sourceCategoryId ?? '').trim().toLowerCase();
      final sourceBrandId = (section.sourceBrandId ?? '').trim().toLowerCase();

      final matchesQuery = query.isEmpty ||
          titleEn.contains(query) ||
          titleBn.contains(query) ||
          subtitleEn.contains(query) ||
          subtitleBn.contains(query) ||
          type.contains(query) ||
          sourceType.contains(query) ||
          sourceCategoryId.contains(query) ||
          sourceBrandId.contains(query) ||
          section.id.trim().toLowerCase().contains(query);

      final matchesStatus = switch (status) {
        'active' => section.isActive,
        'inactive' => !section.isActive,
        'viewAllOn' => section.showViewAll,
        'viewAllOff' => !section.showViewAll,
        _ => true,
      };

      final matchesSectionType =
          sectionType == 'all' || type == sectionType.toLowerCase();

      final matchesDataSource =
          dataSource == 'all' || sourceType == dataSource.toLowerCase();

      final matchesLayout =
          layout == 'all' || style == layout.toLowerCase();

      return matchesQuery &&
          matchesStatus &&
          matchesSectionType &&
          matchesDataSource &&
          matchesLayout;
    }).toList(growable: false);

    result.sort((a, b) {
      final bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;

      return a.titleEn.trim().toLowerCase().compareTo(
        b.titleEn.trim().toLowerCase(),
      );
    });

    filteredSections.assignAll(result);
  }

  Future<int> suggestSortOrder({
    String? excludeSectionId,
  }) {
    return _repository.suggestSortOrder(
      excludeSectionId: excludeSectionId,
    );
  }

  Future<bool> sortExists({
    required int sortOrder,
    String? excludeSectionId,
  }) {
    return _repository.sortExists(
      sortOrder: sortOrder,
      excludeSectionId: excludeSectionId,
    );
  }

  Future<String?> createSection(MBHomeSection section) async {
    if (isSaving.value) return null;

    try {
      isSaving.value = true;
      final id = await _repository.createSection(section);

      MBNotification.success(
        title: 'Success',
        message: 'Home section created successfully.',
      );

      return id;
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to create home section.',
      );
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateSection(MBHomeSection section) async {
    if (isSaving.value) return false;

    try {
      isSaving.value = true;
      await _repository.updateSection(section);

      MBNotification.success(
        title: 'Success',
        message: 'Home section updated successfully.',
      );

      return true;
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update home section.',
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteSection(String sectionId) async {
    if (isDeleting.value) return false;

    try {
      isDeleting.value = true;
      await _repository.deleteSection(sectionId);

      MBNotification.success(
        title: 'Success',
        message: 'Home section deleted successfully.',
      );

      return true;
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to delete home section.',
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool> toggleSectionActive(MBHomeSection section) async {
    try {
      await _repository.setSectionActiveState(
        sectionId: section.id,
        isActive: !section.isActive,
      );

      MBNotification.success(
        title: 'Success',
        message: !section.isActive
            ? 'Home section activated.'
            : 'Home section deactivated.',
      );

      return true;
    } catch (_) {
      MBNotification.error(
        title: 'Error',
        message: 'Failed to update home section state.',
      );
      return false;
    }
  }

  @override
  void onClose() {
    _sectionsSubscription?.cancel();
    super.onClose();
  }
}
