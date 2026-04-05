import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/admin/mb_admin_activity_log.dart';
import 'package:shared_ui/shared_ui.dart';

class ActivityLogDetailsDialog extends StatelessWidget {
  final MBAdminActivityLog log;

  const ActivityLogDetailsDialog({
    super.key,
    required this.log,
  });

  static Future<void> show(
      BuildContext context, {
        required MBAdminActivityLog log,
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ActivityLogDetailsDialog(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(log.status);
    final actionColor = _actionColor(log.action);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 1200,
        constraints: const BoxConstraints(
          maxWidth: 1200,
          maxHeight: 860,
        ),
        decoration: BoxDecoration(
          color: MBColors.card,
          borderRadius: BorderRadius.circular(MBRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 20),
              decoration: const BoxDecoration(
                gradient: MBGradients.primaryGradient,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Log Details',
                          style: MBTextStyles.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Inspect action details, actor info, target info, and before/after payload.',
                          style: MBTextStyles.body.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _headerBadge(
                              label: _safe(log.action, fallback: 'unknown'),
                              color: actionColor,
                            ),
                            _headerBadge(
                              label: _safe(log.status, fallback: 'unknown'),
                              color: statusColor,
                            ),
                            _headerBadge(
                              label: _safe(log.module, fallback: 'module'),
                              color: Colors.white,
                              textColor: MBColors.primary,
                              fillAlpha: 0.96,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Overview'),
                          const SizedBox(height: 12),
                          _infoGrid(
                            children: [
                              _infoCard(
                                title: 'Log ID',
                                value: _safe(log.id, fallback: '-'),
                                icon: Icons.fingerprint_rounded,
                              ),
                              _infoCard(
                                title: 'Created At',
                                value: _formatDateTime(log.createdAt),
                                icon: Icons.schedule_rounded,
                              ),
                              _infoCard(
                                title: 'Module',
                                value: _safe(log.module, fallback: '-'),
                                icon: Icons.widgets_rounded,
                              ),
                              _infoCard(
                                title: 'Action',
                                value: _safe(log.action, fallback: '-'),
                                icon: Icons.bolt_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('Actor Information'),
                          const SizedBox(height: 12),
                          _infoGrid(
                            children: [
                              _infoCard(
                                title: 'Actor Name',
                                value: _safe(log.actorName, fallback: '-'),
                                icon: Icons.person_rounded,
                              ),
                              _infoCard(
                                title: 'Phone',
                                value: _safe(log.actorPhone, fallback: '-'),
                                icon: Icons.phone_rounded,
                              ),
                              _infoCard(
                                title: 'Role',
                                value: _safe(log.actorRole, fallback: '-'),
                                icon: Icons.shield_rounded,
                              ),
                              _infoCard(
                                title: 'Actor UID',
                                value: _safe(log.actorUid, fallback: '-'),
                                icon: Icons.badge_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('Target Information'),
                          const SizedBox(height: 12),
                          _infoGrid(
                            children: [
                              _infoCard(
                                title: 'Target Title',
                                value: _safe(log.targetTitle, fallback: '-'),
                                icon: Icons.title_rounded,
                              ),
                              _infoCard(
                                title: 'Target Type',
                                value: _safe(log.targetType, fallback: '-'),
                                icon: Icons.category_rounded,
                              ),
                              _infoCard(
                                title: 'Target ID',
                                value: _safe(log.targetId, fallback: '-'),
                                icon: Icons.tag_rounded,
                              ),
                              _infoCard(
                                title: 'Status',
                                value: _safe(log.status, fallback: '-'),
                                icon: Icons.verified_rounded,
                                trailing: _statusPill(log.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('Reason'),
                          const SizedBox(height: 12),
                          _textPanel(
                            text: _safe(log.reason, fallback: 'No reason provided.'),
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('Metadata'),
                          const SizedBox(height: 12),
                          _jsonPanel(
                            title: 'Metadata',
                            data: log.metadata,
                            emptyText: 'No metadata available.',
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('Change Inspector'),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _jsonPanel(
                                  title: 'Before',
                                  data: log.beforeData,
                                  emptyText: 'No beforeData captured.',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _jsonPanel(
                                  title: 'After',
                                  data: log.afterData,
                                  emptyText: 'No afterData captured.',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: MBColors.background,
                      border: Border(
                        left: BorderSide(
                          color: MBColors.border.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: MBTextStyles.h3.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _sideButton(
                            icon: Icons.copy_all_rounded,
                            label: 'Copy Full JSON',
                            onTap: () => _copyJson(
                              context,
                              {
                                ...log.toMap(),
                                'id': log.id,
                              },
                              successMessage: 'Full log JSON copied.',
                            ),
                          ),
                          const SizedBox(height: 10),
                          _sideButton(
                            icon: Icons.copy_rounded,
                            label: 'Copy Before JSON',
                            onTap: () => _copyJson(
                              context,
                              log.beforeData,
                              successMessage: 'beforeData copied.',
                            ),
                          ),
                          const SizedBox(height: 10),
                          _sideButton(
                            icon: Icons.copy_rounded,
                            label: 'Copy After JSON',
                            onTap: () => _copyJson(
                              context,
                              log.afterData,
                              successMessage: 'afterData copied.',
                            ),
                          ),
                          const SizedBox(height: 10),
                          _sideButton(
                            icon: Icons.copy_rounded,
                            label: 'Copy Metadata JSON',
                            onTap: () => _copyJson(
                              context,
                              log.metadata,
                              successMessage: 'metadata copied.',
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'Summary',
                            style: MBTextStyles.body.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _summaryTile(
                            title: 'Action',
                            value: _safe(log.action, fallback: '-'),
                            color: actionColor,
                          ),
                          const SizedBox(height: 10),
                          _summaryTile(
                            title: 'Status',
                            value: _safe(log.status, fallback: '-'),
                            color: statusColor,
                          ),
                          const SizedBox(height: 10),
                          _summaryTile(
                            title: 'Module',
                            value: _safe(log.module, fallback: '-'),
                            color: MBColors.primary,
                          ),
                          const SizedBox(height: 10),
                          _summaryTile(
                            title: 'Actor',
                            value: _safe(log.actorName, fallback: '-'),
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(height: 10),
                          _summaryTile(
                            title: 'Target',
                            value: _safe(log.targetTitle, fallback: '-'),
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Payload Stats',
                            style: MBTextStyles.body.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _metricCard(
                            title: 'Metadata fields',
                            value: (log.metadata?.length ?? 0).toString(),
                            icon: Icons.dataset_linked_rounded,
                          ),
                          const SizedBox(height: 10),
                          _metricCard(
                            title: 'Before fields',
                            value: (log.beforeData?.length ?? 0).toString(),
                            icon: Icons.history_toggle_off_rounded,
                          ),
                          const SizedBox(height: 10),
                          _metricCard(
                            title: 'After fields',
                            value: (log.afterData?.length ?? 0).toString(),
                            icon: Icons.update_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: MBTextStyles.h3.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _infoGrid({
    required List<Widget> children,
  }) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: children
          .map(
            (child) => SizedBox(
          width: 360,
          child: child,
        ),
      )
          .toList(),
    );
  }

  Widget _infoCard({
    required String title,
    required String value,
    required IconData icon,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: MBColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: MBColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MBTextStyles.caption.copyWith(
                    color: MBColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: MBTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: MBColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _textPanel({
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.8),
        ),
      ),
      child: SelectableText(
        text,
        style: MBTextStyles.body.copyWith(
          height: 1.45,
        ),
      ),
    );
  }

  Widget _jsonPanel({
    required String title,
    required Map<String, dynamic>? data,
    required String emptyText,
  }) {
    final jsonText = _prettyJson(data);

    return Container(
      decoration: BoxDecoration(
        color: MBColors.background,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: MBColors.card,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(MBRadius.lg),
              ),
              border: Border(
                bottom: BorderSide(
                  color: MBColors.border.withValues(alpha: 0.8),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: MBTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Copy JSON',
                  onPressed: data == null || data.isEmpty
                      ? null
                      : () => _copyRawJsonText(
                    title: title,
                    jsonText: jsonText,
                  ),
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 180),
            padding: const EdgeInsets.all(14),
            child: data == null || data.isEmpty
                ? Text(
              emptyText,
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            )
                : SelectableText(
              jsonText,
              style: MBTextStyles.body.copyWith(
                fontFamily: 'monospace',
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MBRadius.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: MBColors.card,
          borderRadius: BorderRadius.circular(MBRadius.lg),
          border: Border.all(
            color: MBColors.border.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: MBColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: MBTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MBTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: MBTextStyles.body.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: MBColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: MBColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: MBTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: MBTextStyles.h3.copyWith(
              fontWeight: FontWeight.w800,
              color: MBColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBadge({
    required String label,
    required Color color,
    Color? textColor,
    double fillAlpha = 0.14,
  }) {
    final effectiveTextColor = textColor ?? color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: fillAlpha),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label,
        style: MBTextStyles.caption.copyWith(
          color: effectiveTextColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _statusPill(String? status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        _safe(status, fallback: 'unknown'),
        style: MBTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _prettyJson(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return '';
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  Future<void> _copyJson(
      BuildContext context,
      Map<String, dynamic>? data, {
        required String successMessage,
      }) async {
    if (data == null || data.isEmpty) {
      _showSnack(context, 'No JSON available to copy.');
      return;
    }

    const encoder = JsonEncoder.withIndent('  ');
    final text = encoder.convert(data);
    await Clipboard.setData(ClipboardData(text: text));
    _showSnack(context, successMessage);
  }

  Future<void> _copyRawJsonText({
    required String title,
    required String jsonText,
  }) async {
    if (jsonText.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: jsonText));
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('dd MMM yyyy • hh:mm:ss a').format(value.toLocal());
  }

  String _safe(String? value, {required String fallback}) {
    final v = (value ?? '').trim();
    return v.isEmpty ? fallback : v;
  }

  Color _statusColor(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
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

  Color _actionColor(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
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
}