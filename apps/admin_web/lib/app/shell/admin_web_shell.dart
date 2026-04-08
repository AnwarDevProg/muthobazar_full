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
                    child: Container(
                      margin: const EdgeInsets.all(MBSpacing.lg),
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
                      child: child,
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
    final AdminAccessController accessController =
    Get.find<AdminAccessController>();
    final AdminWebSessionService sessionService =
    Get.find<AdminWebSessionService>();

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
                _SidebarBrandHeader(
                  collapsed: collapsed,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    controller.setRoute(AdminWebRoutes.dashboard);
                  },
                ),
                MBSpacing.h(MBSpacing.md),
                _SidebarSearchShortcut(
                  collapsed: collapsed,
                  onTap: controller.openCommandPalette,
                ),
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
                  onLogout: () async {
                    await sessionService.signOut();
                    Get.offAllNamed(AdminWebRoutes.login);
                  },
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
    required this.onTap,
  });

  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
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

    final Widget tappable = Material(
      color: Colors.transparent,
      child: InkWell(
        canRequestFocus: false,
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: content,
      ),
    );

    if (collapsed) {
      return Tooltip(
        message: 'Go to dashboard',
        child: tappable,
      );
    }

    return tappable;
  }
}

class _SidebarSearchShortcut extends StatelessWidget {
  const _SidebarSearchShortcut({
    required this.collapsed,
    required this.onTap,
  });

  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget child = Material(
      color: Colors.transparent,
      child: InkWell(
        canRequestFocus: false,
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? MBSpacing.sm : MBSpacing.md,
            vertical: MBSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: collapsed
              ? const Center(
            child: Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 20,
            ),
          )
              : Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
              MBSpacing.w(MBSpacing.sm),
              Expanded(
                child: Text(
                  'Search pages, commands...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MBTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(MBRadius.pill),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  'Ctrl + K',
                  style: MBTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(
        message: 'Search pages, commands, routes (Ctrl + K)',
        child: child,
      );
    }

    return child;
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
    required this.onLogout,
  });

  final bool collapsed;
  final VoidCallback onToggleSidebar;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SidebarActionButton(
          collapsed: collapsed,
          icon: collapsed
              ? Icons.keyboard_double_arrow_right_rounded
              : Icons.keyboard_double_arrow_left_rounded,
          label: 'Collapse Sidebar',
          tooltip: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
          onTap: onToggleSidebar,
        ),
        MBSpacing.h(MBSpacing.sm),
        _SidebarActionButton(
          collapsed: collapsed,
          icon: Icons.logout_rounded,
          label: 'Logout',
          tooltip: 'Logout',
          onTap: onLogout,
        ),
      ],
    );
  }
}

class _SidebarActionButton extends StatelessWidget {
  const _SidebarActionButton({
    required this.collapsed,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final bool collapsed;
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget child = Material(
      color: Colors.transparent,
      child: InkWell(
        canRequestFocus: false,
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
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
              ? Icon(
            icon,
            color: Colors.white,
            size: 20,
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
                  label,
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
    );

    if (collapsed) {
      return Tooltip(
        message: tooltip,
        child: child,
      );
    }

    return child;
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
                                      child: Icon(
                                        item.icon,
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
