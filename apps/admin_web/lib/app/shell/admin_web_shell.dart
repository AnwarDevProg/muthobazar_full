import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/app/services/admin_web_session_service.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_ui/shared_ui.dart';

import 'admin_shell_state_controller.dart';
import 'admin_sidebar_config.dart';

class AdminWebShell extends StatelessWidget {
  const AdminWebShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (_AdminWebShellScope.isActive(context)) {
      return child;
    }

    return _AdminWebShellScope(
      child: Scaffold(
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
                              borderRadius:
                              BorderRadius.circular(MBRadius.xl),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  MBColors.shadow.withValues(alpha: 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: child,
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
      ),
    );
  }
}

class _AdminWebShellScope extends InheritedWidget {
  const _AdminWebShellScope({
    required super.child,
  });

  static bool isActive(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AdminWebShellScope>() !=
        null;
  }

  @override
  bool updateShouldNotify(_AdminWebShellScope oldWidget) => false;
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar();

  @override
  Widget build(BuildContext context) {
    final AdminShellStateController controller =
    Get.find<AdminShellStateController>();
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();

    return Obx(() {
      final permission = accessController.permission.value;

      return GetBuilder<AdminShellStateController>(
        id: 'admin_sidebar',
        builder: (controller) {
          final bool collapsed = controller.isSidebarCollapsed.value;
          final String currentRoute = controller.currentRoute.value;
          final Set<String> expandedTitles =
          Set<String>.from(controller.expandedGroupTitles);
          final visibleGroups = AdminSidebarConfig.visibleGroups(permission);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: collapsed ? 92 : 300,
            margin: const EdgeInsets.fromLTRB(
              MBSpacing.lg,
              MBSpacing.lg,
              0,
              MBSpacing.lg,
            ),
            padding: const EdgeInsets.all(MBSpacing.md),
            decoration: BoxDecoration(
              gradient: MBGradients.primaryGradient,
              borderRadius: BorderRadius.circular(MBRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: MBColors.primaryOrange.withValues(alpha: 0.22),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SidebarBrandHeader(collapsed: collapsed),
                MBSpacing.h(MBSpacing.lg),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller.sidebarScrollController,
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

                        final bool isExpanded =
                            !collapsed && expandedTitles.contains(group.title);

                        final bool isActive = items.any(
                              (item) =>
                          currentRoute == item.route ||
                              currentRoute.startsWith('${item.route}/'),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: MBSpacing.md),
                          child: _SidebarGroupCard(
                            key: ValueKey<String>(
                              'sidebar-group-${group.title}',
                            ),
                            title: group.title,
                            collapsed: collapsed,
                            items: items,
                            active: isActive,
                            expanded: isExpanded,
                            currentRoute: currentRoute,
                            onGroupTap: () => controller.toggleGroup(group.title),
                            onItemTap: (route) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              controller.setRoute(route);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                MBSpacing.h(MBSpacing.md),
                _SidebarBottomBar(
                  collapsed: collapsed,
                  onToggleSidebar: controller.toggleSidebar,
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _SidebarBrandHeader extends StatelessWidget {
  const _SidebarBrandHeader({
    required this.collapsed,
  });

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: collapsed
          ? const Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: Colors.white,
          size: 26,
        ),
      )
          : Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 26,
              ),
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

class _SidebarGroupCard extends StatelessWidget {
  const _SidebarGroupCard({
    super.key,
    required this.title,
    required this.collapsed,
    required this.items,
    required this.active,
    required this.expanded,
    required this.currentRoute,
    required this.onGroupTap,
    required this.onItemTap,
  });

  final String title;
  final bool collapsed;
  final List<AdminSidebarItemConfig> items;
  final bool active;
  final bool expanded;
  final String currentRoute;
  final VoidCallback onGroupTap;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      final firstIcon = items.first;

      return Tooltip(
        message: title,
        child: InkWell(
          canRequestFocus: false,
          borderRadius: BorderRadius.circular(14),
          onTap: () => onItemTap(items.first.route),
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
            canRequestFocus: false,
            borderRadius: BorderRadius.circular(14),
            onTap: onGroupTap,
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
            crossFadeState:
            expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
                    isActive: currentRoute == item.route ||
                        currentRoute.startsWith('${item.route}/'),
                    onTap: () => onItemTap(item.route),
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

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    super.key,
    required this.item,
    required this.collapsed,
    required this.isActive,
    required this.onTap,
  });

  final AdminSidebarItemConfig item;
  final bool collapsed;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = IconData(
      item.iconCodePoint,
      fontFamily: item.iconFontFamily,
      fontPackage: item.iconFontPackage,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: MBSpacing.sm),
      child: InkWell(
        canRequestFocus: false,
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
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

class _SidebarBottomBar extends StatelessWidget {
  const _SidebarBottomBar({
    required this.collapsed,
    required this.onToggleSidebar,
  });

  final bool collapsed;
  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          canRequestFocus: false,
          borderRadius: BorderRadius.circular(14),
          onTap: onToggleSidebar,
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

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar();

  @override
  Widget build(BuildContext context) {
    final AdminWebSessionService sessionService =
    Get.find<AdminWebSessionService>();

    return GetBuilder<AdminShellStateController>(
      id: 'admin_topbar',
      builder: (controller) {
        final breadcrumbs = controller.breadcrumbs;

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
                child: Column(
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
                ),
              ),
              SizedBox(
                width: 320,
                child: InkWell(
                  canRequestFocus: false,
                  borderRadius: BorderRadius.circular(MBRadius.pill),
                  onTap: controller.openCommandPalette,
                  child: Container(
                    height: 48,
                    padding:
                    const EdgeInsets.symmetric(horizontal: MBSpacing.md),
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
                          color: MBColors.textSecondary,
                          size: 20,
                        ),
                        MBSpacing.w(MBSpacing.sm),
                        Expanded(
                          child: Text(
                            'Search pages, commands, routes...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MBTextStyles.bodyMedium.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                        MBSpacing.w(MBSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: MBSpacing.sm,
                            vertical: MBSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: MBColors.border.withValues(alpha: 0.9),
                            ),
                          ),
                          child: Text(
                            'Ctrl + K',
                            style: MBTextStyles.caption.copyWith(
                              color: MBColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              InkWell(
                canRequestFocus: false,
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
      },
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
      final items = isSearching ? results : recents;

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
                              color: MBColors.border.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: MBColors.textSecondary,
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onChanged: controller.updateCommandQuery,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'Search command or page...',
                                ),
                                style: MBTextStyles.bodyMedium.copyWith(
                                  color: MBColors.textPrimary,
                                ),
                              ),
                            ),
                            MBSpacing.w(MBSpacing.sm),
                            InkWell(
                              canRequestFocus: false,
                              borderRadius: BorderRadius.circular(999),
                              onTap: () {
                                _searchController.clear();
                                controller.closeCommandPalette();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: MBSpacing.sm,
                                  vertical: MBSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: MBColors.background,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'ESC',
                                  style: MBTextStyles.caption.copyWith(
                                    color: MBColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: items.isEmpty
                            ? Center(
                          child: Text(
                            isSearching
                                ? 'No matching command found'
                                : 'No recent pages yet',
                            style: MBTextStyles.bodyMedium.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        )
                            : ListView.separated(
                          padding: const EdgeInsets.all(MBSpacing.md),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              MBSpacing.h(MBSpacing.sm),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return InkWell(
                              canRequestFocus: false,
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                _searchController.clear();
                                controller.openRouteFromCommand(item.route);
                              },
                              child: Container(
                                padding:
                                const EdgeInsets.all(MBSpacing.md),
                                decoration: BoxDecoration(
                                  color: MBColors.background,
                                  borderRadius:
                                  BorderRadius.circular(16),
                                  border: Border.all(
                                    color: MBColors.border.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        gradient:
                                        MBGradients.primaryGradient,
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_outward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    MBSpacing.w(MBSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: MBTextStyles.bodyMedium
                                                .copyWith(
                                              color: MBColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          MBSpacing.h(MBSpacing.xxxs),
                                          Text(
                                            item.description,
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: MBTextStyles.caption
                                                .copyWith(
                                              color:
                                              MBColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    MBSpacing.w(MBSpacing.md),
                                    Text(
                                      item.route,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: MBTextStyles.caption.copyWith(
                                        color: MBColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
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
