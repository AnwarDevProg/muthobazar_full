import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';

class AdminActivityLogController extends GetxController {
  AdminActivityLogController({
    AdminActivityLogRepository? repository,
  }) : _repository = repository ?? AdminActivityLogRepository.instance;

  final AdminActivityLogRepository _repository;

  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = true.obs;

  final RxList<MBAdminActivityLog> allLogs = <MBAdminActivityLog>[].obs;
  final RxList<MBAdminActivityLog> filteredLogs = <MBAdminActivityLog>[].obs;

  final RxString selectedStatus = 'All'.obs;
  final RxString selectedAction = 'All'.obs;
  final RxString selectedModule = 'All'.obs;

  final Rxn<DateTimeRange> selectedDateRange = Rxn<DateTimeRange>();

  final RxString sortColumn = 'createdAt'.obs;
  final RxBool isAscending = false.obs;

  StreamSubscription<List<MBAdminActivityLog>>? _logsSubscription;

  List<String> get availableStatuses {
    final values = <String>{'All'};
    for (final log in allLogs) {
      final value = log.status.trim();
      if (value.isNotEmpty) values.add(value);
    }
    final list = values.toList();
    list.sort(_allFirstCompare);
    return list;
  }

  List<String> get availableActions {
    final values = <String>{'All'};
    for (final log in allLogs) {
      final value = log.action.trim();
      if (value.isNotEmpty) values.add(value);
    }
    final list = values.toList();
    list.sort(_allFirstCompare);
    return list;
  }

  List<String> get availableModules {
    final values = <String>{'All'};
    for (final log in allLogs) {
      final value = log.module.trim();
      if (value.isNotEmpty) values.add(value);
    }
    final list = values.toList();
    list.sort(_allFirstCompare);
    return list;
  }

  int get successCount => allLogs
      .where((e) => e.status.trim().toLowerCase() == 'success')
      .length;

  int get failedCount => allLogs
      .where((e) => e.status.trim().toLowerCase() == 'failed')
      .length;

  bool get hasDateFilter => selectedDateRange.value != null;

  String get dateRangeLabel {
    final range = selectedDateRange.value;
    if (range == null) return 'Select date range';
    return '${_formatDate(range.start)} → ${_formatDate(range.end)}';
  }

  @override
  void onInit() {
    super.onInit();
    _listenLogs();
  }

  @override
  void onClose() {
    _logsSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _listenLogs() {
    _logsSubscription?.cancel();
    isLoading.value = true;

    _logsSubscription = _repository.watchActivityLogs(limit: 200).listen(
          (items) {
        allLogs.assignAll(items);
        _applyFilters();
        isLoading.value = false;
      },
      onError: (error, stackTrace) {
        isLoading.value = false;
        allLogs.clear();
        filteredLogs.clear();

        Get.snackbar(
          'Activity Logs',
          'Failed to load activity logs.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void onSearchChanged(String value) {
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    _applyFilters();
  }

  void setStatusFilter(String value) {
    selectedStatus.value = value;
    _applyFilters();
  }

  void setActionFilter(String value) {
    selectedAction.value = value;
    _applyFilters();
  }

  void setModuleFilter(String value) {
    selectedModule.value = value;
    _applyFilters();
  }

  void setDateRange(DateTimeRange value) {
    selectedDateRange.value = DateTimeRange(
      start: DateTime(
        value.start.year,
        value.start.month,
        value.start.day,
      ),
      end: DateTime(
        value.end.year,
        value.end.month,
        value.end.day,
        23,
        59,
        59,
        999,
      ),
    );
    _applyFilters();
  }

  void clearDateRange() {
    selectedDateRange.value = null;
    _applyFilters();
  }

  void resetFilters() {
    searchController.clear();
    selectedStatus.value = 'All';
    selectedAction.value = 'All';
    selectedModule.value = 'All';
    selectedDateRange.value = null;
    sortColumn.value = 'createdAt';
    isAscending.value = false;
    _applyFilters();
  }

  void sortBy(String column) {
    if (sortColumn.value == column) {
      isAscending.value = !isAscending.value;
    } else {
      sortColumn.value = column;
      isAscending.value = _defaultAscending(column);
    }
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    final status = selectedStatus.value.trim().toLowerCase();
    final action = selectedAction.value.trim().toLowerCase();
    final module = selectedModule.value.trim().toLowerCase();
    final range = selectedDateRange.value;

    final results = allLogs.where((log) {
      final matchesSearch = query.isEmpty || _matchesSearch(log, query);
      final matchesStatus =
          status == 'all' || log.status.trim().toLowerCase() == status;
      final matchesAction =
          action == 'all' || log.action.trim().toLowerCase() == action;
      final matchesModule =
          module == 'all' || log.module.trim().toLowerCase() == module;
      final matchesDate = _matchesDateRange(log.createdAt, range);

      return matchesSearch &&
          matchesStatus &&
          matchesAction &&
          matchesModule &&
          matchesDate;
    }).toList();

    results.sort(_buildComparator());
    filteredLogs.assignAll(results);
  }

  bool _matchesSearch(MBAdminActivityLog log, String query) {
    if (log.searchableText.contains(query)) return true;

    final extra = <String>[
      log.actorUid,
      log.targetId,
      log.metadataPreview,
    ];

    for (final item in extra) {
      if (item.toLowerCase().contains(query)) return true;
    }

    return false;
  }

  bool _matchesDateRange(DateTime? value, DateTimeRange? range) {
    if (range == null) return true;
    if (value == null) return false;

    final local = value.toLocal();
    return !local.isBefore(range.start) && !local.isAfter(range.end);
  }

  Comparator<MBAdminActivityLog> _buildComparator() {
    final column = sortColumn.value;
    final ascending = isAscending.value;

    int compare(MBAdminActivityLog a, MBAdminActivityLog b) {
      final result = switch (column) {
        'actorName' => _compareString(a.actorName, b.actorName),
        'actorRole' => _compareString(a.actorRole, b.actorRole),
        'action' => _compareString(a.action, b.action),
        'module' => _compareString(a.module, b.module),
        'targetTitle' => _compareString(a.targetTitle, b.targetTitle),
        'status' => _compareString(a.status, b.status),
        'reason' => _compareString(a.reason, b.reason),
        'createdAt' => _compareDate(a.createdAt, b.createdAt),
        _ => _compareDate(a.createdAt, b.createdAt),
      };

      return ascending ? result : -result;
    }

    return compare;
  }

  int _compareString(String a, String b) {
    return a.trim().toLowerCase().compareTo(b.trim().toLowerCase());
  }

  int _compareDate(DateTime? a, DateTime? b) {
    final aa = a?.millisecondsSinceEpoch ?? 0;
    final bb = b?.millisecondsSinceEpoch ?? 0;
    return aa.compareTo(bb);
  }

  bool _defaultAscending(String column) {
    switch (column) {
      case 'createdAt':
        return false;
      default:
        return true;
    }
  }

  int _allFirstCompare(String a, String b) {
    if (a == 'All' && b == 'All') return 0;
    if (a == 'All') return -1;
    if (b == 'All') return 1;
    return a.toLowerCase().compareTo(b.toLowerCase());
  }

  String _formatDate(DateTime value) {
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final yyyy = value.year.toString();
    return '$dd/$mm/$yyyy';
  }
}