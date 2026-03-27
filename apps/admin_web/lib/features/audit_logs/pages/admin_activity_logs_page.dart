import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import 'package:admin_web/app/routes/admin_web_routes.dart';
import 'package:admin_web/features/admin_access/controllers/admin_access_controller.dart';
import 'package:admin_web/features/audit_logs/controllers/admin_activity_log_controller.dart';

class AdminActivityLogsPage extends StatelessWidget {
  const AdminActivityLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accessController = Get.find<AdminAccessController>();
    final logController = Get.find<AdminActivityLogController>();

    return Scaffold(
      backgroundColor: MBColors.background,
      body: Row(
        children: [
          _SidebarProxy(
            currentRoute: AppRoutes.adminActivityLogs,
            isSuperAdmin: accessController.isSuperAdmin,
          ),
          Expanded(
            child: Column(
              children: [
                const _TopBarProxy(title: 'Admin Activity Logs'),
                Expanded(
                  child: Obx(() {
                    if (!accessController.canViewActivityLogs) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        child: MBCard(
                          child: Text(
                            'You do not have permission to view activity logs.',
                            style: MBTextStyles.body.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    if (logController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (logController.logs.isEmpty) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        child: MBCard(
                          child: Text(
                            'No activity logs found.',
                            style: MBTextStyles.body.copyWith(
                              color: MBColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: logController.refreshLogs,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(MBSpacing.xl),
                        itemCount: logController.logs.length,
                        itemBuilder: (context, index) {
                          final log = logController.logs[index];
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: MBSpacing.md),
                            child: _LogCard(log: log),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogCard extends StatefulWidget {
  final dynamic log;

  const _LogCard({
    required this.log,
  });

  @override
  State<_LogCard> createState() => _LogCardState();
}

class _LogCardState extends State<_LogCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.log;

    return MBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ActionBadge(action: log.action.toString()),
              const Spacer(),
              Text(
                log.createdAt?.toIso8601String() ?? '',
                style: MBTextStyles.caption,
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.sm),
          Text(
            log.summary.toString(),
            style: MBTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xxxs),
          Text(
            'Admin: ${log.adminName} (${log.adminRole})',
            style: MBTextStyles.caption,
          ),
          MBSpacing.h(MBSpacing.xxxs),
          Text(
            'Target: ${log.targetType} • ${log.targetTitle} • ${log.targetId}',
            style: MBTextStyles.caption,
          ),
          if (log.beforeData != null || log.afterData != null) ...[
            MBSpacing.h(MBSpacing.sm),
            TextButton(
              onPressed: () {
                setState(() {
                  _showDetails = !_showDetails;
                });
              },
              child: Text(_showDetails ? 'Hide Details' : 'Show Details'),
            ),
          ],
          if (_showDetails) ...[
            if (log.beforeData != null) ...[
              MBSpacing.h(MBSpacing.sm),
              Text(
                'Before',
                style: MBTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.xxxs),
              _JsonBox(data: log.beforeData as Map<String, dynamic>),
            ],
            if (log.afterData != null) ...[
              MBSpacing.h(MBSpacing.sm),
              Text(
                'After',
                style: MBTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              MBSpacing.h(MBSpacing.xxxs),
              _JsonBox(data: log.afterData as Map<String, dynamic>),
            ],
          ],
        ],
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final String action;

  const _ActionBadge({
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MBSpacing.sm,
        vertical: MBSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: MBColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        action,
        style: MBTextStyles.caption.copyWith(
          color: MBColors.primaryOrange,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _JsonBox extends StatelessWidget {
  final Map<String, dynamic> data;

  const _JsonBox({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.md),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MBColors.border),
      ),
      child: SelectableText(
        data.toString(),
        style: MBTextStyles.caption.copyWith(
          color: MBColors.textPrimary,
        ),
      ),
    );
  }
}

class _SidebarProxy extends StatelessWidget {
  final String currentRoute;
  final bool isSuperAdmin;

  const _SidebarProxy({
    required this.currentRoute,
    required this.isSuperAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: MBColors.primaryOrange,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MBSpacing.md),
          child: Column(
            children: [
              _ProxyTile(
                label: 'Dashboard',
                selected: currentRoute == AppRoutes.adminDashboard ||
                    currentRoute == AppRoutes.adminShell,
                onTap: () => Get.offNamed(AppRoutes.adminShell),
              ),
              _ProxyTile(
                label: 'Activity Logs',
                selected: currentRoute == AppRoutes.adminActivityLogs,
                onTap: () => Get.offNamed(AppRoutes.adminActivityLogs),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProxyTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ProxyTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: Colors.white.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        label,
        style: MBTextStyles.body.copyWith(
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _TopBarProxy extends StatelessWidget {
  final String title;

  const _TopBarProxy({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: MBSpacing.xl),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: MBColors.border),
        ),
      ),
      child: Text(
        title,
        style: MBTextStyles.pageTitle,
      ),
    );
  }
}












