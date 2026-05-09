// MuthoBazar Studio V4 JSON Panel
//
// Purpose:
// - Provides a safe V4 Lab export/debug surface before V4 is connected to
//   the real product save flow.
// - Shows document summary, validation hints, and copyable V4 JSON.
// - Keeps Studio V3 and customer runtime rendering untouched.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/mb_studio_v4_controller.dart';

class MBStudioV4JsonPanel extends StatelessWidget {
  const MBStudioV4JsonPanel({
    super.key,
    required this.controller,
  });

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final validationMessages = controller.exportValidationMessages;
        final preview = controller.exportPrettyJson;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                blurRadius: 16,
                offset: Offset(0, 8),
                color: Color(0x10000000),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _JsonHeader(controller: controller),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: <Widget>[
                    _SummaryGrid(controller: controller),
                    const SizedBox(height: 10),
                    _ValidationBox(messages: validationMessages),
                    const SizedBox(height: 10),
                    _JsonPreview(preview: preview),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _JsonHeader extends StatelessWidget {
  const _JsonHeader({required this.controller});

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.data_object,
              color: Color(0xFF2563EB),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'V4 JSON Lab',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Preview only · not saved to product yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy pretty V4 JSON',
            visualDensity: VisualDensity.compact,
            onPressed: () => _copyText(
              context,
              controller.exportPrettyJson,
              'Pretty V4 JSON copied.',
            ),
            icon: const Icon(Icons.copy_all, size: 18),
          ),
          IconButton(
            tooltip: 'Copy compact V4 JSON',
            visualDensity: VisualDensity.compact,
            onPressed: () => _copyText(
              context,
              controller.exportCompactJson,
              'Compact V4 JSON copied.',
            ),
            icon: const Icon(Icons.compress, size: 18),
          ),
          IconButton(
            tooltip: 'Paste / load V4 JSON',
            visualDensity: VisualDensity.compact,
            onPressed: () => _showLoadJsonDialog(context),
            icon: const Icon(Icons.upload_file, size: 18),
          ),
        ],
      ),
    );
  }

  void _copyText(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnack(context, message);
  }

  void _showSnack(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showLoadJsonDialog(BuildContext context) async {
    final textController = TextEditingController();
    var messages = <String>[];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final hasError = messages.any(
              (message) => message.trim().toLowerCase().startsWith('error:'),
            );

            return AlertDialog(
              title: const Text('Paste / load V4 JSON'),
              content: SizedBox(
                width: 620,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'Paste exported Studio V4 JSON here. Loading replaces the current V4 Lab draft only; it does not save to product.',
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: textController,
                      minLines: 8,
                      maxLines: 14,
                      decoration: const InputDecoration(
                        labelText: 'V4 JSON',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            height: 1.25,
                          ),
                    ),
                    if (messages.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      _ImportValidationBox(
                        messages: messages,
                        hasError: hasError,
                      ),
                    ],
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      messages = controller.validateImportedJsonText(
                        textController.text,
                      );
                    });
                  },
                  icon: const Icon(Icons.fact_check_outlined, size: 18),
                  label: const Text('Validate'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final result = controller.loadDocumentFromJsonText(
                      textController.text,
                    );
                    final hasBlockingError = result.any(
                      (message) =>
                          message.trim().toLowerCase().startsWith('error:'),
                    );

                    if (hasBlockingError) {
                      setDialogState(() {
                        messages = result;
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop();
                    _showSnack(context, result.first);
                  },
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: const Text('Load JSON'),
                ),
              ],
            );
          },
        );
      },
    );

    textController.dispose();
  }
}

class _ImportValidationBox extends StatelessWidget {
  const _ImportValidationBox({
    required this.messages,
    required this.hasError,
  });

  final List<String> messages;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = hasError ? const Color(0xFFDC2626) : const Color(0xFF16A34A);

    return Container(
      constraints: const BoxConstraints(maxHeight: 130),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  hasError ? Icons.error_outline : Icons.verified_outlined,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
                Text(
                  hasError ? 'Fix JSON before loading' : 'JSON can be loaded',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final message in messages)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '• $message',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.controller});

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        _SummaryChip(label: 'Schema', value: '${controller.exportSchemaVersion}'),
        _SummaryChip(label: 'Nodes', value: '${controller.exportNodeCount}'),
        _SummaryChip(label: 'Selected', value: '${controller.exportSelectedCount}'),
        _SummaryChip(
          label: 'Canvas',
          value:
              '${controller.exportCanvasWidth.toStringAsFixed(0)}×${controller.exportCanvasHeight.toStringAsFixed(0)}',
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelSmall?.copyWith(
          color: const Color(0xFF334155),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ValidationBox extends StatelessWidget {
  const _ValidationBox({required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasOnlySuccess = messages.length == 1 &&
        messages.first.toLowerCase().contains('export-ready');
    final color = hasOnlySuccess ? const Color(0xFF16A34A) : const Color(0xFFF97316);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                hasOnlySuccess ? Icons.verified_outlined : Icons.report_outlined,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                'Validation',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final message in messages.take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '• $message',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF475569),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (messages.length > 4)
            Text(
              '+${messages.length - 4} more validation messages',
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _JsonPreview extends StatelessWidget {
  const _JsonPreview({required this.preview});

  final String preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clipped = preview.length > 1200 ? '${preview.substring(0, 1200)}\n…' : preview;
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          clipped,
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFFE2E8F0),
            fontFamily: 'monospace',
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
