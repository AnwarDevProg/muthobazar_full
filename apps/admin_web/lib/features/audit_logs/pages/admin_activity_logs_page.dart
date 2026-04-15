import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/admin/mb_admin_activity_log.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_activity_log_controller.dart';
import '../widgets/activity_log_details_dialog.dart';

class AdminActivityLogsPage extends GetView<AdminActivityLogController> {
  const AdminActivityLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MBColors.background,
      body: SafeArea(
        child: Obx(
              () => Column(
            children: [
              _buildTopHeader(context),
              _buildStickyFilterArea(context),
              Expanded(
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.filteredLogs.isEmpty
                    ? _buildEmptyState(context)
                    : _buildPremiumTable(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        MBSpacing.adminPageHorizontal(context),
        MBSpacing.lg,
        MBSpacing.adminPageHorizontal(context),
        MBSpacing.md,
      ),
      decoration: const BoxDecoration(
        gradient: MBGradients.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Logs',
            style: MBTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor admin actions, filter events, export reports, and inspect change history.',
            style: MBTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildTopStatCard(
                title: 'Total',
                value: controller.allLogs.length.toString(),
                icon: Icons.receipt_long_rounded,
              ),
              _buildTopStatCard(
                title: 'Filtered',
                value: controller.filteredLogs.length.toString(),
                icon: Icons.filter_alt_rounded,
              ),
              _buildTopStatCard(
                title: 'Success',
                value: controller.successCount.toString(),
                icon: Icons.verified_rounded,
              ),
              _buildTopStatCard(
                title: 'Failed',
                value: controller.failedCount.toString(),
                icon: Icons.error_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(MBRadius.xl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MBTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: MBTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFilterArea(BuildContext context) {
    return Container(
      width: double.infinity,
      color: MBColors.background,
      padding: EdgeInsets.fromLTRB(
        MBSpacing.adminPageHorizontal(context),
        MBSpacing.md,
        MBSpacing.adminPageHorizontal(context),
        MBSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MBColors.card,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: MBColors.border.withValues(alpha: 0.7),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search actor, action, module, target, status...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: controller.searchController.text.trim().isEmpty
                          ? null
                          : IconButton(
                        onPressed: controller.clearSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
                      filled: true,
                      fillColor: MBColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MBRadius.lg),
                        borderSide: BorderSide(
                          color: MBColors.border.withValues(alpha: 0.8),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MBRadius.lg),
                        borderSide: BorderSide(
                          color: MBColors.border.withValues(alpha: 0.8),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(MBRadius.lg),
                        borderSide: const BorderSide(
                          color: MBColors.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildDateRangeButton(context),
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.restart_alt_rounded,
                  label: 'Reset',
                  onTap: controller.resetFilters,
                  isPrimary: false,
                ),
                const SizedBox(width: 10),
                _buildActionButton(
                  icon: Icons.download_rounded,
                  label: 'Export CSV',
                  onTap: _exportCsv,
                  isPrimary: true,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildFilterChipGroup(
                    title: 'Status',
                    values: controller.availableStatuses,
                    selectedValue: controller.selectedStatus.value,
                    onSelected: controller.setStatusFilter,
                    colorBuilder: _statusColor,
                  ),
                  _buildFilterChipGroup(
                    title: 'Action',
                    values: controller.availableActions,
                    selectedValue: controller.selectedAction.value,
                    onSelected: controller.setActionFilter,
                    colorBuilder: _actionColor,
                  ),
                  _buildFilterChipGroup(
                    title: 'Module',
                    values: controller.availableModules,
                    selectedValue: controller.selectedModule.value,
                    onSelected: controller.setModuleFilter,
                    colorBuilder: (_) => MBColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeButton(BuildContext context) {
    final label = controller.dateRangeLabel;

    return InkWell(
      onTap: () => _pickDateRange(context),
      borderRadius: BorderRadius.circular(MBRadius.lg),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: MBColors.background,
          borderRadius: BorderRadius.circular(MBRadius.lg),
          border: Border.all(
            color: MBColors.border.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: MBTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (controller.hasDateFilter)
              IconButton(
                tooltip: 'Clear date filter',
                onPressed: controller.clearDateRange,
                icon: const Icon(Icons.close_rounded),
              )
            else
              const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MBRadius.lg),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: isPrimary ? MBGradients.primaryGradient : null,
          color: isPrimary ? null : MBColors.background,
          borderRadius: BorderRadius.circular(MBRadius.lg),
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : MBColors.border.withValues(alpha: 0.8),
          ),
          boxShadow: isPrimary
              ? [
            BoxShadow(
              color: MBColors.primary.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : MBColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: MBTextStyles.body.copyWith(
                color: isPrimary ? Colors.white : MBColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChipGroup({
    required String title,
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String> onSelected,
    required Color Function(String value) colorBuilder,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$title:',
          style: MBTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: MBColors.textSecondary,
          ),
        ),
        ...values.map((value) {
          final isSelected = value == selectedValue;
          final color = colorBuilder(value);

          return InkWell(
            onTap: () => onSelected(value),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.14)
                    : MBColors.background,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.9)
                      : MBColors.border.withValues(alpha: 0.9),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value.toLowerCase() != 'all') ...[
                    Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    value,
                    style: MBTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : MBColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPremiumTable(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        MBSpacing.adminPageHorizontal(context),
        0,
        MBSpacing.adminPageHorizontal(context),
        MBSpacing.adminPageHorizontal(context),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: MBColors.card,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          border: Border.all(
            color: MBColors.border.withValues(alpha: 0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildStickyHeaderRow(),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1600,
                    child: ListView.separated(
                      itemCount: controller.filteredLogs.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: MBColors.border.withValues(alpha: 0.6),
                      ),
                      itemBuilder: (context, index) {
                        final log = controller.filteredLogs[index];
                        return _buildDataRow(context, log, index);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeaderRow() {
    Widget headerCell({
      required String title,
      required String sortKey,
      required double width,
      Alignment alignment = Alignment.centerLeft,
    }) {
      final bool active = controller.sortColumn.value == sortKey;
      final bool ascending = controller.isAscending.value;

      return InkWell(
        onTap: () => controller.sortBy(sortKey),
        child: Container(
          alignment: alignment,
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: MBTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: active ? MBColors.primary : MBColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                active
                    ? (ascending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 16,
                color: active ? MBColors.primary : MBColors.textHint,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: MBColors.background,
      child: Row(
        children: [
          headerCell(title: 'Time', sortKey: 'createdAt', width: 190),
          headerCell(title: 'Actor', sortKey: 'actorName', width: 220),
          headerCell(title: 'Role', sortKey: 'actorRole', width: 140),
          headerCell(title: 'Action', sortKey: 'action', width: 180),
          headerCell(title: 'Module', sortKey: 'module', width: 170),
          headerCell(title: 'Target', sortKey: 'targetTitle', width: 250),
          headerCell(title: 'Status', sortKey: 'status', width: 140),
          headerCell(title: 'Reason', sortKey: 'reason', width: 210),
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            alignment: Alignment.center,
            child: Text(
              'Details',
              style: MBTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: MBColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(
      BuildContext context,
      MBAdminActivityLog log,
      int index,
      ) {
    final rowColor = index.isEven
        ? Colors.transparent
        : MBColors.background.withValues(alpha: 0.55);

    return InkWell(
      onTap: () => ActivityLogDetailsDialog.show(context, log: log),
      child: Container(
        color: rowColor,
        child: Row(
          children: [
            _cell(
              width: 190,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDateTime(log.createdAt),
                    style: MBTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRelative(log.createdAt),
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _cell(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _safe(log.actorName, fallback: 'Unknown'),
                    style: MBTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _safe(log.actorPhone, fallback: '-'),
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _cell(
              width: 140,
              child: _roleBadge(log.actorRole),
            ),
            _cell(
              width: 180,
              child: _actionBadge(log.action),
            ),
            _cell(
              width: 170,
              child: Text(
                _safe(log.module, fallback: '-'),
                style: MBTextStyles.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _cell(
              width: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _safe(log.targetTitle, fallback: '-'),
                    style: MBTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_safe(log.targetType, fallback: '-')} • ${_safe(log.targetId, fallback: '-')}',
                    style: MBTextStyles.caption.copyWith(
                      color: MBColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _cell(
              width: 140,
              child: _statusBadge(log.status),
            ),
            _cell(
              width: 210,
              child: Text(
                _safe(log.reason, fallback: '-'),
                style: MBTextStyles.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              alignment: Alignment.center,
              child: Tooltip(
                message: 'Open details',
                child: InkWell(
                  onTap: () => ActivityLogDetailsDialog.show(context, log: log),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: MBColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: MBColors.primary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.remove_red_eye_rounded,
                      color: MBColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell({
    required double width,
    required Widget child,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  Widget _statusBadge(String status) {
    final raw = _safe(status, fallback: 'unknown');
    final color = _statusColor(raw);

    return _badge(
      label: raw,
      color: color,
      icon: raw.toLowerCase() == 'success'
          ? Icons.check_circle_rounded
          : raw.toLowerCase() == 'failed'
          ? Icons.error_rounded
          : Icons.info_rounded,
    );
  }

  Widget _actionBadge(String action) {
    final raw = _safe(action, fallback: 'unknown');
    final color = _actionColor(raw);

    return _badge(
      label: raw,
      color: color,
      icon: _actionIcon(raw),
    );
  }

  Widget _roleBadge(String role) {
    final raw = _safe(role, fallback: 'staff');
    final color = raw.toLowerCase() == 'super_admin'
        ? Colors.deepPurple
        : raw.toLowerCase() == 'admin'
        ? MBColors.primary
        : Colors.blueGrey;

    return _badge(
      label: raw,
      color: color,
      icon: Icons.shield_rounded,
    );
  }

  Widget _badge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: MBTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        width: 520,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: MBColors.card,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          border: Border.all(color: MBColors.border.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: MBColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: MBColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No activity logs found',
              style: MBTextStyles.h3.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing the filters, date range, or search keywords.',
              textAlign: TextAlign.center,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: controller.resetFilters,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: controller.selectedDateRange.value,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      helpText: 'Select log date range',
      saveText: 'Apply',
    );

    if (picked == null) return;
    controller.setDateRange(picked);
  }

  void _exportCsv() {
    final logs = controller.filteredLogs;
    if (logs.isEmpty) {
      Get.snackbar(
        'No Data',
        'There is no filtered log data to export.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln(
      'Time,Actor Name,Actor Phone,Actor Role,Action,Module,Target Type,Target ID,Target Title,Status,Reason',
    );

    for (final log in logs) {
      buffer.writeln([
        _csv(_formatDateTime(log.createdAt)),
        _csv(log.actorName),
        _csv(log.actorPhone),
        _csv(log.actorRole),
        _csv(log.action),
        _csv(log.module),
        _csv(log.targetType),
        _csv(log.targetId),
        _csv(log.targetTitle),
        _csv(log.status),
        _csv(log.reason),
      ].join(','));
    }

    final bytes = buffer.toString().codeUnits;
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8;');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final downloadAnchor = html.AnchorElement(href: url)
      ..setAttribute(
        'download',
        'activity_logs_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv',
      )
      ..click();

    html.Url.revokeObjectUrl(url);
    downloadAnchor.remove();

    Get.snackbar(
      'Export Complete',
      'CSV file downloaded successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _csv(String? value) {
    final safe = _safe(value, fallback: '');
    final escaped = safe.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _safe(String? value, {required String fallback}) {
    final v = (value ?? '').trim();
    return v.isEmpty ? fallback : v;
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('dd MMM yyyy • hh:mm a').format(value.toLocal());
  }

  String _formatRelative(DateTime? value) {
    if (value == null) return '-';

    final now = DateTime.now();
    final diff = now.difference(value);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo ago';
    final years = (months / 12).floor();
    return '${years}y ago';
  }

  Color _statusColor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'pending':
        return Colors.amber.shade800;
      default:
        return Colors.blueGrey;
    }
  }

  Color _actionColor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'create':
        return Colors.green;
      case 'update':
      case 'edit':
        return MBColors.primary;
      case 'delete':
        return Colors.red;
      case 'login':
      case 'signin':
        return Colors.blue;
      case 'logout':
      case 'signout':
        return Colors.deepOrange;
      case 'approve':
        return Colors.teal;
      case 'reject':
        return Colors.pink;
      default:
        return Colors.deepPurple;
    }
  }

  IconData _actionIcon(String value) {
    switch (value.trim().toLowerCase()) {
      case 'create':
        return Icons.add_circle_rounded;
      case 'update':
      case 'edit':
        return Icons.edit_rounded;
      case 'delete':
        return Icons.delete_rounded;
      case 'login':
      case 'signin':
        return Icons.login_rounded;
      case 'logout':
      case 'signout':
        return Icons.logout_rounded;
      case 'approve':
        return Icons.verified_rounded;
      case 'reject':
        return Icons.cancel_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }
}