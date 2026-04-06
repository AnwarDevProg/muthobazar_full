import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/profile/controllers/admin_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import 'admin_shell_state_controller.dart';
import 'admin_sidebar_config.dart';

class AdminWebShell extends StatefulWidget {
  const AdminWebShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AdminWebShell> createState() => _AdminWebShellState();
}

class _AdminWebShellState extends State<AdminWebShell> {
  late final AdminShellStateController controller;
  String _lastSyncedRoute = '';

  @override
  void initState() {
    super.initState();
    controller = Get.find<AdminShellStateController>();
    _scheduleRouteSync();
  }

  @override
  void didUpdateWidget(covariant AdminWebShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleRouteSync();
  }

  void _scheduleRouteSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final route = Get.currentRoute.trim();
      if (route.isEmpty) return;
      if (_lastSyncedRoute == route) return;

      _lastSyncedRoute = route;
      controller.setRouteFromNavigation(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                const _AdminSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      const _AdminTopBar(),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(
                            MBSpacing.lg,
                            0,
                            MBSpacing.lg,
                            MBSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(MBRadius.xl),
                            boxShadow: [
                              BoxShadow(
                                color: MBColors.shadow.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const _CommandPaletteOverlay(),
          ],
        ),
      ),
    );
  }
}

class _AdminSidebar extends GetView<AdminShellStateController> {
  const _AdminSidebar();

  @override
  Widget build(BuildContext context) {
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();

    return Obx(() {
      final bool collapsed = controller.isSidebarCollapsed.value;
      final double width = collapsed ? 96 : 292;
      final permission = accessController.permission.value;

      final visibleGroups = AdminSidebarConfig.visibleGroups(permission);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: width,
        margin: const EdgeInsets.all(MBSpacing.lg),
        decoration: BoxDecoration(
          gradient: MBGradients.primaryGradient,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          boxShadow: [
            BoxShadow(
              color: MBColors.primaryOrange.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(MBSpacing.lg),
              child: _SidebarBrand(collapsed: collapsed),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: MBSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: visibleGroups.map((group) {
                    final items = AdminSidebarConfig.itemsForGroup(group.title)
                        .where(
                          (item) => AdminSidebarConfig.canAccessItem(
                        item,
                        permission,
                      ),
                    )
                        .toList();

                    if (items.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: MBSpacing.md),
                      child: _SidebarGroupCard(
                        key: ValueKey<String>('sidebar-group-${group.title}'),
                        title: group.title,
                        collapsed: collapsed,
                        items: items,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(MBSpacing.md),
              child: _SidebarBottomBar(collapsed: collapsed),
            ),
          ],
        ),
      );
    });
  }
}

class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand({
    required this.collapsed,
  });

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: collapsed
          ? const Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: Colors.white,
          size: 28,
        ),
      )
          : Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(MBRadius.lg),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          MBSpacing.w(MBSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MuthoBazar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MBTextStyles.sectionTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxxs),
                Text(
                  'Admin Web',
                  style: MBTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarGroupCard extends GetView<AdminShellStateController> {
  const _SidebarGroupCard({
    super.key,
    required this.title,
    required this.collapsed,
    required this.items,
  });

  final String title;
  final bool collapsed;
  final List<AdminSidebarItemConfig> items;

  @override
  Widget build(BuildContext context) {

      final bool active = controller.isGroupActive(title);
      final bool expanded = controller.isGroupExpanded(title);

      if (collapsed) {
        final firstIcon = items.first;
        return Tooltip(
          message: title,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => controller.setRoute(items.first.route),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: MBSpacing.sm,
                vertical: MBSpacing.md,
              ),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.20)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: active
                    ? Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                )
                    : null,
              ),
              child: Center(
                child: Icon(
                  IconData(
                    firstIcon.iconCodePoint,
                    fontFamily: firstIcon.iconFontFamily,
                    fontPackage: firstIcon.iconFontPackage,
                  ),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => controller.toggleGroup(title),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: MBSpacing.md,
                  vertical: MBSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.toUpperCase(),
                        style: MBTextStyles.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              crossFadeState: expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(
                  MBSpacing.sm,
                  0,
                  MBSpacing.sm,
                  MBSpacing.sm,
                ),
                child: Column(
                  children: items
                      .map(
                        (item) => _SidebarItem(
                      key: ValueKey<String>('sidebar-item-${item.route}'),
                      item: item,
                      collapsed: false,
                    ),
                  )
                      .toList(),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      );

  }
}

class _SidebarItem extends GetView<AdminShellStateController> {
  const _SidebarItem({
    super.key,
    required this.item,
    required this.collapsed,
  });

  final AdminSidebarItemConfig item;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {

      final bool isActive = controller.isActive(item.route);
      final icon = IconData(
        item.iconCodePoint,
        fontFamily: item.iconFontFamily,
        fontPackage: item.iconFontPackage,
      );

      return Padding(
        padding: const EdgeInsets.only(bottom: MBSpacing.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => controller.setRoute(item.route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? MBSpacing.sm : MBSpacing.md,
              vertical: MBSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.20)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: isActive
                  ? Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              )
                  : null,
            ),
            child: collapsed
                ? Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            )
                : Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                MBSpacing.w(MBSpacing.sm),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MBTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  }
}

class _SidebarBottomBar extends GetView<AdminShellStateController> {
  const _SidebarBottomBar({
    required this.collapsed,
  });

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: controller.toggleSidebar,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: MBSpacing.md,
              vertical: MBSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: collapsed
                ? const Icon(
              Icons.keyboard_double_arrow_right_rounded,
              color: Colors.white,
              size: 20,
            )
                : Row(
              children: [
                const Icon(
                  Icons.keyboard_double_arrow_left_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                MBSpacing.w(MBSpacing.sm),
                Expanded(
                  child: Text(
                    'Collapse Sidebar',
                    style: MBTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminTopBar extends GetView<AdminShellStateController> {
  const _AdminTopBar();

  @override
  Widget build(BuildContext context) {
    final AdminProfileController profileController =
    Get.find<AdminProfileController>();
    final AdminWebSessionService sessionService =
    Get.find<AdminWebSessionService>();

    return Container(
      height: 92,
      margin: const EdgeInsets.fromLTRB(
        MBSpacing.lg,
        MBSpacing.lg,
        MBSpacing.lg,
        MBSpacing.lg,
      ),
      padding: const EdgeInsets.symmetric(horizontal: MBSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.xl),
        boxShadow: [
          BoxShadow(
            color: MBColors.shadow.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final breadcrumbs = controller.breadcrumbs;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (int i = 0; i < breadcrumbs.length; i++) ...[
                        Text(
                          breadcrumbs[i],
                          style: MBTextStyles.caption.copyWith(
                            color: i == breadcrumbs.length - 1
                                ? MBColors.primaryOrange
                                : MBColors.textSecondary,
                            fontWeight: i == breadcrumbs.length - 1
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        if (i != breadcrumbs.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: MBSpacing.xs,
                            ),
                            child: Text(
                              '/',
                              style: MBTextStyles.caption.copyWith(
                                color: MBColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    controller.pageTitle,
                    style: MBTextStyles.pageTitle.copyWith(
                      color: MBColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(
            width: 320,
            child: InkWell(
              borderRadius: BorderRadius.circular(MBRadius.pill),
              onTap: controller.openCommandPalette,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: MBSpacing.md),
                decoration: BoxDecoration(
                  color: MBColors.background,
                  borderRadius: BorderRadius.circular(MBRadius.pill),
                  border: Border.all(
                    color: MBColors.border.withValues(alpha: 0.9),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: MBColors.textMuted,
                    ),
                    MBSpacing.w(MBSpacing.sm),
                    Expanded(
                      child: Text(
                        'Search modules, pages, routes...',
                        style: MBTextStyles.body.copyWith(
                          color: MBColors.textMuted,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MBSpacing.sm,
                        vertical: MBSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(MBRadius.pill),
                        border: Border.all(
                          color: MBColors.border.withValues(alpha: 0.9),
                        ),
                      ),
                      child: Text(
                        'Ctrl K',
                        style: MBTextStyles.caption.copyWith(
                          color: MBColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          MBSpacing.w(MBSpacing.lg),
          Obx(() {
            final bool loading = profileController.isLoading.value;
            final String name = profileController.displayNameForShell;
            final String role = profileController.displayRoleForShell;
            final String email = profileController.displayEmailForShell;
            final String initials = profileController.initials;
            final String picture = profileController.profilePicture;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MBSpacing.md,
                vertical: MBSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: MBColors.background,
                borderRadius: BorderRadius.circular(MBRadius.pill),
                border: Border.all(
                  color: MBColors.border.withValues(alpha: 0.9),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor:
                    MBColors.primaryOrange.withValues(alpha: 0.10),
                    backgroundImage:
                    picture.isNotEmpty ? NetworkImage(picture) : null,
                    child: picture.isEmpty
                        ? Text(
                      initials,
                      style: MBTextStyles.caption.copyWith(
                        color: MBColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                        : null,
                  ),
                  MBSpacing.w(MBSpacing.sm),
                  SizedBox(
                    width: 180,
                    child: loading
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 12,
                          width: 90,
                          decoration: BoxDecoration(
                            color: MBColors.border,
                            borderRadius:
                            BorderRadius.circular(MBRadius.pill),
                          ),
                        ),
                        MBSpacing.h(MBSpacing.xxs),
                        Container(
                          height: 10,
                          width: 70,
                          decoration: BoxDecoration(
                            color: MBColors.border,
                            borderRadius:
                            BorderRadius.circular(MBRadius.pill),
                          ),
                        ),
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MBTextStyles.bodyMedium.copyWith(
                            color: MBColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          role,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MBTextStyles.caption.copyWith(
                            color: MBColors.textSecondary,
                          ),
                        ),
                        if (email != 'No email')
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MBTextStyles.caption.copyWith(
                              color: MBColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  InkWell(
                    borderRadius: BorderRadius.circular(MBRadius.pill),
                    onTap: () => Get.toNamed(AdminWebRoutes.profile),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MBSpacing.md,
                        vertical: MBSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(MBRadius.pill),
                        border: Border.all(
                          color: MBColors.primaryOrange.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Text(
                        'Profile',
                        style: MBTextStyles.bodyMedium.copyWith(
                          color: MBColors.primaryOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.sm),
                  InkWell(
                    borderRadius: BorderRadius.circular(MBRadius.pill),
                    onTap: () async {
                      await sessionService.signOut();
                      Get.offAllNamed(AdminWebRoutes.login);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MBSpacing.md,
                        vertical: MBSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        gradient: MBGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(MBRadius.pill),
                      ),
                      child: Text(
                        'Logout',
                        style: MBTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CommandPaletteOverlay extends StatefulWidget {
  const _CommandPaletteOverlay();

  @override
  State<_CommandPaletteOverlay> createState() => _CommandPaletteOverlayState();
}

class _CommandPaletteOverlayState extends State<_CommandPaletteOverlay> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdminShellStateController controller =
    Get.find<AdminShellStateController>();

    return Obx(() {
      if (!controller.isCommandPaletteOpen.value) {
        return const SizedBox.shrink();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_searchFocusNode.hasFocus) {
          _searchFocusNode.requestFocus();
        }
      });

      final bool isSearching = controller.commandQuery.value.trim().isNotEmpty;
      final results = controller.commandPaletteItems;
      final recents = controller.recentCommandPaletteItems;

      return Positioned.fill(
        child: Material(
          color: Colors.black.withValues(alpha: 0.28),
          child: GestureDetector(
            onTap: () {
              _searchController.clear();
              controller.closeCommandPalette();
            },
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 760,
                  constraints: const BoxConstraints(
                    maxHeight: 620,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(MBRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 32,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(MBSpacing.lg),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: MBColors.border.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: MBColors.primaryOrange
                                        .withValues(alpha: 0.10),
                                    borderRadius:
                                    BorderRadius.circular(MBRadius.md),
                                  ),
                                  child: const Icon(
                                    Icons.search_rounded,
                                    color: MBColors.primaryOrange,
                                  ),
                                ),
                                MBSpacing.w(MBSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Command Palette',
                                        style: MBTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: MBColors.textPrimary,
                                        ),
                                      ),
                                      MBSpacing.h(MBSpacing.xxxs),
                                      Text(
                                        'Search modules, pages, and routes instantly.',
                                        style: MBTextStyles.caption.copyWith(
                                          color: MBColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: MBSpacing.sm,
                                    vertical: MBSpacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MBColors.background,
                                    borderRadius:
                                    BorderRadius.circular(MBRadius.pill),
                                    border: Border.all(
                                      color: MBColors.border
                                          .withValues(alpha: 0.9),
                                    ),
                                  ),
                                  child: Text(
                                    'Esc',
                                    style: MBTextStyles.caption.copyWith(
                                      color: MBColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            MBSpacing.h(MBSpacing.md),
                            TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              autofocus: true,
                              onChanged: controller.updateCommandQuery,
                              decoration: InputDecoration(
                                hintText: 'Search pages, modules, routes...',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon:
                                controller.commandQuery.value.trim().isEmpty
                                    ? null
                                    : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.updateCommandQuery('');
                                    _searchFocusNode.requestFocus();
                                  },
                                  icon:
                                  const Icon(Icons.close_rounded),
                                ),
                                filled: true,
                                fillColor: MBColors.background,
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(MBRadius.lg),
                                  borderSide: BorderSide(
                                    color:
                                    MBColors.border.withValues(alpha: 0.8),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(MBRadius.lg),
                                  borderSide: BorderSide(
                                    color:
                                    MBColors.border.withValues(alpha: 0.8),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(MBRadius.lg),
                                  borderSide: const BorderSide(
                                    color: MBColors.primaryOrange,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: isSearching
                            ? _SearchResultsSection(
                          results: results,
                          onItemTap: (route) {
                            _searchController.clear();
                            controller.openRouteFromCommand(route);
                          },
                        )
                            : _RecentAndBrowseSection(
                          recents: recents,
                          browseItems: results,
                          onItemTap: (route) {
                            _searchController.clear();
                            controller.openRouteFromCommand(route);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _SearchResultsSection extends StatelessWidget {
  const _SearchResultsSection({
    required this.results,
    required this.onItemTap,
  });

  final List<AdminRouteMeta> results;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No matching pages found.',
          style: MBTextStyles.body.copyWith(
            color: MBColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(MBSpacing.md),
      itemCount: results.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: MBColors.border.withValues(alpha: 0.8),
      ),
      itemBuilder: (context, index) {
        final item = results[index];
        return _CommandPaletteItemTile(
          item: item,
          onTap: () => onItemTap(item.route),
        );
      },
    );
  }
}

class _RecentAndBrowseSection extends StatelessWidget {
  const _RecentAndBrowseSection({
    required this.recents,
    required this.browseItems,
    required this.onItemTap,
  });

  final List<AdminRouteMeta> recents;
  final List<AdminRouteMeta> browseItems;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(MBSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recents.isNotEmpty) ...[
            _PaletteSectionTitle(
              title: 'Recent',
              subtitle: 'Recently visited pages',
            ),
            MBSpacing.h(MBSpacing.sm),
            ...recents.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(bottom: MBSpacing.sm),
                child: _CommandPaletteItemTile(
                  item: item,
                  compact: true,
                  onTap: () => onItemTap(item.route),
                ),
              ),
            ),
            MBSpacing.h(MBSpacing.lg),
          ],
          _PaletteSectionTitle(
            title: 'Browse All',
            subtitle: 'Available admin pages',
          ),
          MBSpacing.h(MBSpacing.sm),
          ...browseItems.take(16).map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: MBSpacing.sm),
              child: _CommandPaletteItemTile(
                item: item,
                compact: true,
                onTap: () => onItemTap(item.route),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteSectionTitle extends StatelessWidget {
  const _PaletteSectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: MBTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: MBColors.textPrimary,
                ),
              ),
              MBSpacing.h(MBSpacing.xxxs),
              Text(
                subtitle,
                style: MBTextStyles.caption.copyWith(
                  color: MBColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommandPaletteItemTile extends StatelessWidget {
  const _CommandPaletteItemTile({
    required this.item,
    required this.onTap,
    this.compact = false,
  });

  final AdminRouteMeta item;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(MBRadius.lg),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? MBSpacing.md : MBSpacing.lg),
        decoration: BoxDecoration(
          color: MBColors.card,
          borderRadius: BorderRadius.circular(MBRadius.lg),
          border: Border.all(
            color: MBColors.border.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: MBColors.primaryOrange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(MBRadius.md),
              ),
              child: Icon(
                item.icon,
                color: MBColors.primaryOrange,
                size: 20,
              ),
            ),
            MBSpacing.w(MBSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: MBTextStyles.bodyMedium.copyWith(
                      color: MBColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  MBSpacing.h(MBSpacing.xxxs),
                  Text(
                    item.breadcrumbs.join(' / '),
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                  if (item.description.trim().isNotEmpty) ...[
                    MBSpacing.h(MBSpacing.xxxs),
                    Text(
                      item.description,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: MBTextStyles.caption.copyWith(
                        color: MBColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            MBSpacing.w(MBSpacing.md),
            Text(
              item.route,
              style: MBTextStyles.caption.copyWith(
                color: MBColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}