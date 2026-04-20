import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final RxBool isRefreshing = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeleting = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxString sectionTypeFilter = 'all'.obs;
  final RxString dataSourceFilter = 'all'.obs;
  final RxString layoutFilter = 'all'.obs;

  final RxnString operationError = RxnString();

  StreamSubscription<List<MBHomeSection>>? _sectionsSubscription;

  bool get isAnyBusy =>
      isLoading.value ||
          isRefreshing.value ||
          isSaving.value ||
          isDeleting.value;

  @override
  void onInit() {
    super.onInit();
    _listenSections();
  }

  void clearOperationError() {
    operationError.value = null;
  }

  void _setOperationError(Object error) {
    operationError.value = _humanizeError(error);
  }

  void _listenSections() {
    _sectionsSubscription?.cancel();
    isLoading.value = true;
    clearOperationError();

    _sectionsSubscription = _repository.watchSections().listen(
          (List<MBHomeSection> items) {
        sections.assignAll(items);
        applyFilters();
        isLoading.value = false;
      },
      onError: (Object error) {
        _setOperationError(error);
        isLoading.value = false;

        MBNotification.error(
          title: 'Error',
          message: operationError.value ?? 'Failed to load home sections.',
        );
      },
    );
  }

  Future<void> refreshSections() async {
    if (isRefreshing.value) return;

    try {
      isRefreshing.value = true;
      clearOperationError();

      final List<MBHomeSection> items = await _repository.fetchSectionsOnce();
      sections.assignAll(items);
      applyFilters();
    } catch (error) {
      _setOperationError(error);

      MBNotification.error(
        title: 'Error',
        message: operationError.value ?? 'Failed to refresh home sections.',
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
    statusFilter.value = value.trim().isEmpty ? 'all' : value.trim();
    applyFilters();
  }

  void setSectionTypeFilter(String value) {
    sectionTypeFilter.value = value.trim().isEmpty ? 'all' : value.trim();
    applyFilters();
  }

  void setDataSourceFilter(String value) {
    dataSourceFilter.value = value.trim().isEmpty ? 'all' : value.trim();
    applyFilters();
  }

  void setLayoutFilter(String value) {
    layoutFilter.value = value.trim().isEmpty ? 'all' : value.trim();
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
    final String query = searchQuery.value.trim().toLowerCase();
    final String status = statusFilter.value.trim().toLowerCase();
    final String sectionType = sectionTypeFilter.value.trim().toLowerCase();
    final String dataSource = dataSourceFilter.value.trim().toLowerCase();
    final String layout = layoutFilter.value.trim().toLowerCase();

    final List<MBHomeSection> result = sections.where((MBHomeSection section) {
      final String titleEn = section.titleEn.trim().toLowerCase();
      final String titleBn = section.titleBn.trim().toLowerCase();
      final String subtitleEn = section.subtitleEn.trim().toLowerCase();
      final String subtitleBn = section.subtitleBn.trim().toLowerCase();
      final String type = section.sectionType.trim().toLowerCase();
      final String style = section.layoutStyle.trim().toLowerCase();
      final String sourceType = section.dataSourceType.trim().toLowerCase();
      final String id = section.id.trim().toLowerCase();
      final String sourceCategoryId =
      (section.sourceCategoryId ?? '').trim().toLowerCase();
      final String sourceBrandId =
      (section.sourceBrandId ?? '').trim().toLowerCase();

      final bool matchesQuery = query.isEmpty ||
          titleEn.contains(query) ||
          titleBn.contains(query) ||
          subtitleEn.contains(query) ||
          subtitleBn.contains(query) ||
          type.contains(query) ||
          style.contains(query) ||
          sourceType.contains(query) ||
          id.contains(query) ||
          sourceCategoryId.contains(query) ||
          sourceBrandId.contains(query);

      final bool matchesStatus = switch (status) {
        'active' => section.isActive,
        'inactive' => !section.isActive,
        'viewallon' => section.showViewAll,
        'viewalloff' => !section.showViewAll,
        _ => true,
      };

      final bool matchesSectionType = switch (sectionType) {
        'all' => true,
        _ => type == sectionType,
      };

      final bool matchesDataSource = switch (dataSource) {
        'all' => true,
        _ => sourceType == dataSource,
      };

      final bool matchesLayout = switch (layout) {
        'all' => true,
        _ => style == layout,
      };

      return matchesQuery &&
          matchesStatus &&
          matchesSectionType &&
          matchesDataSource &&
          matchesLayout;
    }).toList(growable: false);

    result.sort(_sortSectionsForView);
    filteredSections.assignAll(result);
  }

  Future<int> suggestSortOrder({
    String? excludeSectionId,
  }) async {
    try {
      clearOperationError();
      return await _repository.suggestSortOrder(
        excludeSectionId: excludeSectionId,
      );
    } catch (error) {
      _setOperationError(error);
      rethrow;
    }
  }

  Future<bool> sortExists({
    required int sortOrder,
    String? excludeSectionId,
  }) async {
    try {
      clearOperationError();
      return await _repository.sortExists(
        sortOrder: sortOrder,
        excludeSectionId: excludeSectionId,
      );
    } catch (error) {
      _setOperationError(error);
      rethrow;
    }
  }

  Future<String?> createSection(MBHomeSection section) async {
    if (isSaving.value) return null;

    isSaving.value = true;
    clearOperationError();

    try {
      final String id = await _repository.createSection(section);

      MBNotification.success(
        title: 'Success',
        message: 'Home section created successfully.',
      );

      return id;
    } catch (error) {
      _setOperationError(error);

      MBNotification.error(
        title: 'Error',
        message: operationError.value ?? 'Failed to create home section.',
      );

      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateSection(MBHomeSection section) async {
    if (isSaving.value) return false;

    isSaving.value = true;
    clearOperationError();

    try {
      await _repository.updateSection(section);

      MBNotification.success(
        title: 'Success',
        message: 'Home section updated successfully.',
      );

      return true;
    } catch (error) {
      _setOperationError(error);

      MBNotification.error(
        title: 'Error',
        message: operationError.value ?? 'Failed to update home section.',
      );

      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteSection(
      String sectionId, {
        String? reason,
      }) async {
    if (isDeleting.value) return false;

    isDeleting.value = true;
    clearOperationError();

    try {
      await _repository.deleteSection(
        sectionId,
        reason: reason,
      );

      MBNotification.success(
        title: 'Success',
        message: 'Home section deleted successfully.',
      );

      return true;
    } catch (error) {
      _setOperationError(error);

      MBNotification.error(
        title: 'Error',
        message: operationError.value ?? 'Failed to delete home section.',
      );

      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  Future<bool> toggleSectionActive(
      MBHomeSection section, {
        String? reason,
      }) async {
    clearOperationError();

    try {
      final bool newState = !section.isActive;

      await _repository.setSectionActiveState(
        sectionId: section.id,
        isActive: newState,
        reason: reason,
      );

      MBNotification.success(
        title: 'Success',
        message: newState
            ? 'Home section activated.'
            : 'Home section deactivated.',
      );

      return true;
    } catch (error) {
      _setOperationError(error);

      MBNotification.error(
        title: 'Error',
        message:
        operationError.value ?? 'Failed to update home section state.',
      );

      return false;
    }
  }

  int _sortSectionsForView(MBHomeSection a, MBHomeSection b) {
    final int bySort = a.sortOrder.compareTo(b.sortOrder);
    if (bySort != 0) return bySort;

    final int byType = a.sectionType.trim().toLowerCase().compareTo(
      b.sectionType.trim().toLowerCase(),
    );
    if (byType != 0) return byType;

    return a.titleEn.trim().toLowerCase().compareTo(
      b.titleEn.trim().toLowerCase(),
    );
  }

  String _humanizeError(Object error) {
    if (error is FirebaseException) {
      final String message = (error.message ?? '').trim();
      if (message.isNotEmpty) {
        return message;
      }

      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied. Check Firestore rules and admin permissions.';
        case 'unavailable':
          return 'Firestore is temporarily unavailable. Please try again.';
        case 'not-found':
          return 'Requested home section was not found.';
        case 'failed-precondition':
          return 'Firestore precondition failed. Check indexes or document structure.';
        default:
          return 'Firestore error: ${error.code}';
      }
    }

    final String text = error.toString().trim();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '').trim();
    }

    return text.isEmpty ? 'Unexpected error occurred.' : text;
  }

  @override
  void onClose() {
    _sectionsSubscription?.cancel();
    super.onClose();
  }
}