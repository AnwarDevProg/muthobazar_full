import 'dart:async';

import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_sidebar_config.dart';

class AdminShellStateController extends GetxController {
  AdminShellStateController({
    SharedPreferences? preferences,
  }) : _preferences = preferences;

  final SharedPreferences? _preferences;

  final RxString currentRoute = AdminWebRoutes.dashboard.obs;
  final RxBool isSidebarCollapsed = false.obs;
  final RxSet<String> expandedGroupTitles = <String>{}.obs;

  final RxString commandQuery = ''.obs;
  final RxBool isCommandPaletteOpen = false.obs;
  final RxList<String> recentRoutes = <String>[].obs;

  final TrackingScrollController sidebarScrollController =
  TrackingScrollController();

  static const int _maxRecentRoutes = 8;
  static const String _expandedGroupsKey =
      'admin_web_shell_expanded_group_titles';
  static const String _collapsedSidebarKey =
      'admin_web_shell_is_sidebar_collapsed';

  SharedPreferences? _prefs;
  bool _storageReady = false;

  @override
  void onInit() {
    super.onInit();
    _initializeGroups();
    unawaited(_restoreSidebarState());
  }

  @override
  void onClose() {
    sidebarScrollController.dispose();
    super.onClose();
  }

  void _initializeGroups() {
    expandedGroupTitles.clear();

    for (final group in AdminSidebarConfig.groups) {
      if (group.alwaysVisible) {
        expandedGroupTitles.add(group.title);
      }
    }

    expandedGroupTitles.refresh();
    update(['admin_sidebar']);
  }

  Future<void> _restoreSidebarState() async {
    _prefs = _preferences ?? await SharedPreferences.getInstance();
    _storageReady = true;

    isSidebarCollapsed.value =
        _prefs?.getBool(_collapsedSidebarKey) ?? false;

    final List<String> savedExpanded =
        _prefs?.getStringList(_expandedGroupsKey) ?? const <String>[];

    expandedGroupTitles.clear();

    for (final title in savedExpanded) {
      expandedGroupTitles.add(title);
    }

    for (final group in AdminSidebarConfig.groups) {
      if (group.alwaysVisible) {
        expandedGroupTitles.add(group.title);
      }
    }

    expandedGroupTitles.refresh();
    update(['admin_sidebar']);
  }

  Future<void> _persistSidebarState() async {
    if (!_storageReady) return;

    await _prefs?.setBool(_collapsedSidebarKey, isSidebarCollapsed.value);
    await _prefs?.setStringList(
      _expandedGroupsKey,
      expandedGroupTitles.toList(),
    );
  }

  void setRoute(String route) {
    final String normalized = route.trim();
    if (normalized.isEmpty) return;

    currentRoute.value = normalized;
    _pushRecentRoute(normalized);

    update(['admin_sidebar', 'admin_topbar']);

    if (Get.currentRoute == normalized) {
      return;
    }

    Get.offNamed(normalized);
  }

  void setRouteFromNavigation(String? route) {
    if (route == null) return;

    final String normalized = route.trim();
    if (normalized.isEmpty) return;

    currentRoute.value = normalized;
    _pushRecentRoute(normalized);

    update(['admin_sidebar', 'admin_topbar']);
  }

  Future<void> toggleSidebar() async {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
    update(['admin_sidebar']);
    await _persistSidebarState();
  }

  Future<void> toggleGroup(String groupTitle) async {
    if (isSidebarCollapsed.value) return;

    final bool isAlwaysVisible = AdminSidebarConfig.groups.any(
          (group) => group.title == groupTitle && group.alwaysVisible,
    );

    if (isAlwaysVisible) return;

    if (expandedGroupTitles.contains(groupTitle)) {
      expandedGroupTitles.remove(groupTitle);
    } else {
      expandedGroupTitles.add(groupTitle);
    }

    expandedGroupTitles.refresh();
    update(['admin_sidebar']);
    await _persistSidebarState();
  }

  bool isGroupExpanded(String groupTitle) {
    if (isSidebarCollapsed.value) return false;
    return expandedGroupTitles.contains(groupTitle);
  }

  bool isActive(String route) {
    final String current = currentRoute.value;
    return current == route || current.startsWith('$route/');
  }

  bool isGroupActive(String groupTitle) {
    final items = AdminSidebarConfig.itemsForGroup(groupTitle);
    return items.any((item) => isActive(item.route));
  }

  void _pushRecentRoute(String route) {
    if (route.isEmpty) return;

    recentRoutes.remove(route);
    recentRoutes.insert(0, route);

    if (recentRoutes.length > _maxRecentRoutes) {
      recentRoutes.removeRange(_maxRecentRoutes, recentRoutes.length);
    }
  }

  String get pageTitle => AdminRouteRegistry.titleOf(currentRoute.value);

  List<String> get breadcrumbs =>
      AdminRouteRegistry.breadcrumbsOf(currentRoute.value);

  List<AdminRouteMeta> get commandPaletteItems {
    final String query = commandQuery.value.trim().toLowerCase();
    final List<AdminRouteMeta> items = AdminRouteRegistry.commandPaletteItems();

    if (query.isEmpty) {
      return _sortedCommandItems(items);
    }

    final List<_ScoredRouteMeta> scored = items
        .map(
          (item) => _ScoredRouteMeta(
        item: item,
        score: _scoreItem(item, query),
      ),
    )
        .where((item) => item.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return scored.map((e) => e.item).toList();
  }

  List<AdminRouteMeta> get recentCommandPaletteItems {
    return recentRoutes
        .map(AdminRouteRegistry.find)
        .whereType<AdminRouteMeta>()
        .toList();
  }

  List<AdminRouteMeta> _sortedCommandItems(List<AdminRouteMeta> items) {
    final Set<String> recents =
    recentCommandPaletteItems.map((e) => e.route).toSet();

    final List<AdminRouteMeta> sorted = List<AdminRouteMeta>.from(items)
      ..sort((a, b) {
        final bool aRecent = recents.contains(a.route);
        final bool bRecent = recents.contains(b.route);

        if (aRecent && !bRecent) return -1;
        if (!aRecent && bRecent) return 1;

        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

    return sorted;
  }

  int _scoreItem(AdminRouteMeta item, String query) {
    final String title = item.title.toLowerCase();
    final String group = item.sidebarGroup.toLowerCase();
    final String description = item.description.toLowerCase();
    final String route = item.route.toLowerCase();
    final List<String> keywords =
    item.commandKeywords.map((e) => e.toLowerCase()).toList();

    int score = 0;

    if (title == query) score += 200;
    if (route == query) score += 190;

    if (title.startsWith(query)) score += 120;
    if (group.startsWith(query)) score += 70;
    if (route.startsWith(query)) score += 90;

    if (title.contains(query)) score += 80;
    if (group.contains(query)) score += 40;
    if (description.contains(query)) score += 25;
    if (route.contains(query)) score += 35;

    for (final keyword in keywords) {
      if (keyword == query) {
        score += 110;
      } else if (keyword.startsWith(query)) {
        score += 60;
      } else if (keyword.contains(query)) {
        score += 30;
      }
    }

    if (_fuzzyContains(title, query)) score += 18;
    if (_fuzzyContains(route, query)) score += 12;

    return score;
  }

  bool _fuzzyContains(String text, String query) {
    if (query.isEmpty) return true;

    int textIndex = 0;
    int queryIndex = 0;

    while (textIndex < text.length && queryIndex < query.length) {
      if (text[textIndex] == query[queryIndex]) {
        queryIndex++;
      }
      textIndex++;
    }

    return queryIndex == query.length;
  }

  void openCommandPalette() {
    isCommandPaletteOpen.value = true;
  }

  void closeCommandPalette() {
    isCommandPaletteOpen.value = false;
    commandQuery.value = '';
  }

  void updateCommandQuery(String value) {
    commandQuery.value = value;
  }

  void openRouteFromCommand(String route) {
    closeCommandPalette();
    setRoute(route);
  }

  bool get isOverviewActive => isGroupActive(AdminSidebarGroups.overview);
  bool get isCatalogActive => isGroupActive(AdminSidebarGroups.catalog);
  bool get isMarketingActive => isGroupActive(AdminSidebarGroups.marketing);
  bool get isAdministrationActive =>
      isGroupActive(AdminSidebarGroups.administration);
  bool get isOrdersActive => isGroupActive(AdminSidebarGroups.orders);
  bool get isInventoryProcurementActive =>
      isGroupActive(AdminSidebarGroups.inventoryProcurement);
  bool get isFinanceActive => isGroupActive(AdminSidebarGroups.finance);
  bool get isDeliveryActive => isGroupActive(AdminSidebarGroups.delivery);
  bool get isServicesActive => isGroupActive(AdminSidebarGroups.services);
  bool get isCustomersActive => isGroupActive(AdminSidebarGroups.customers);
  bool get isReportingConfigActive =>
      isGroupActive(AdminSidebarGroups.reportingConfig);
}

class _ScoredRouteMeta {
  const _ScoredRouteMeta({
    required this.item,
    required this.score,
  });

  final AdminRouteMeta item;
  final int score;
}
