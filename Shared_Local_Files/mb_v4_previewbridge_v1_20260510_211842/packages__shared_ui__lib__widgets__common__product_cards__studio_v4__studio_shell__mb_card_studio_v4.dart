// MuthoBazar Studio V4 Shell
//
// Purpose:
// - Hosts the future Photoshop-like product-card editor workspace.
// - Shows the first V4 professional layer-management surface, visual canvas,
//   inspector foundation, workflow history controls, clipboard actions, and
//   keyboard shortcuts.
// - Studio V3 remains the active production editor until the V4 renderer and
//   save-flow migration are complete.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../canvas/mb_studio_v4_canvas_stage.dart';
import '../controllers/mb_studio_v4_controller.dart';
import '../panels/mb_studio_v4_inspector_panel.dart';
import '../panels/mb_studio_v4_json_panel.dart';
import '../panels/mb_studio_v4_element_library_panel.dart';
import '../panels/mb_studio_v4_layers_panel.dart';
import '../rendering/mb_studio_v4_runtime_preview_renderer.dart';

class MBCardStudioV4 extends StatelessWidget {
  const MBCardStudioV4({
    super.key,
    required this.controller,
    this.title = 'Studio V4',
    this.onUseDraft,
  });

  final MBStudioV4Controller controller;
  final String title;
  final ValueChanged<String>? onUseDraft;

  KeyEventResult _handleStudioKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    final shortcutPressed = pressed.contains(LogicalKeyboardKey.controlLeft) ||
        pressed.contains(LogicalKeyboardKey.controlRight) ||
        pressed.contains(LogicalKeyboardKey.metaLeft) ||
        pressed.contains(LogicalKeyboardKey.metaRight);
    final shiftPressed = pressed.contains(LogicalKeyboardKey.shiftLeft) ||
        pressed.contains(LogicalKeyboardKey.shiftRight);
    final key = event.logicalKey;

    if (shortcutPressed && key == LogicalKeyboardKey.keyC) {
      controller.copySelectedNodes();
      return KeyEventResult.handled;
    }

    if (shortcutPressed && key == LogicalKeyboardKey.keyV) {
      controller.pasteClipboardNodes();
      return KeyEventResult.handled;
    }

    if (shortcutPressed && key == LogicalKeyboardKey.keyD) {
      controller.duplicateSelectedNodes();
      return KeyEventResult.handled;
    }

    if (shortcutPressed && shiftPressed && key == LogicalKeyboardKey.keyG) {
      controller.ungroupSelectedGroup();
      return KeyEventResult.handled;
    }

    if (shortcutPressed && key == LogicalKeyboardKey.keyG) {
      controller.groupSelectedNodes();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      controller.deleteSelectedNodes();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final editorState = controller.editorState;
        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) => _handleStudioKey(event),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.auto_awesome, color: Color(0xFFFF6500)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Library + layers + canvas + inspector + history + clipboard · Studio V3 remains untouched',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatusPill(
                        label: editorState.dirty ? 'Unsaved' : 'Saved / clean',
                        color: editorState.dirty
                            ? const Color(0xFFF97316)
                            : const Color(0xFF16A34A),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _StudioHistoryToolbar(
                    controller: controller,
                    onUseDraft: onUseDraft,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 620,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          width: 330,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 260,
                                child: MBStudioV4ElementLibraryPanel(
                                  controller: controller,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: MBStudioV4LayersPanel(
                                  controller: controller,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: MBStudioV4CanvasStage(controller: controller),
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 330,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: MBStudioV4InspectorPanel(controller: controller),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 230,
                                child: MBStudioV4JsonPanel(controller: controller),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StudioHistoryToolbar extends StatelessWidget {
  const _StudioHistoryToolbar({
    required this.controller,
    this.onUseDraft,
  });

  final MBStudioV4Controller controller;
  final ValueChanged<String>? onUseDraft;

  Future<void> _showRuntimePreviewDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 920,
              maxHeight: 760,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.visibility_outlined,
                          color: Color(0xFFFF6500),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Studio V4 Runtime Preview',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Render-only card output · no editor handles, grid, guides, or selection overlays',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close preview',
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: MBStudioV4RuntimePreviewRenderer(
                      document: controller.document,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _ToolbarButton(
              icon: Icons.undo,
              label: 'Undo',
              tooltip: controller.lastUndoDescription,
              enabled: controller.canUndo,
              onPressed: controller.undo,
            ),
            const SizedBox(width: 8),
            _ToolbarButton(
              icon: Icons.redo,
              label: 'Redo',
              tooltip: controller.lastRedoDescription,
              enabled: controller.canRedo,
              onPressed: controller.redo,
            ),
            const SizedBox(width: 10),
            _MiniDivider(),
            const SizedBox(width: 10),
            _ToolbarButton(
              icon: Icons.content_copy,
              label: 'Copy',
              tooltip: 'Copy selected layer(s) · Ctrl+C',
              enabled: controller.editorState.hasSelection,
              onPressed: controller.copySelectedNodes,
            ),
            const SizedBox(width: 8),
            _ToolbarButton(
              icon: Icons.content_paste,
              label: 'Paste',
              tooltip: '${controller.clipboardStatusLabel} · Ctrl+V',
              enabled: controller.hasClipboard,
              onPressed: controller.pasteClipboardNodes,
            ),
            const SizedBox(width: 8),
            _ToolbarButton(
              icon: Icons.control_point_duplicate,
              label: 'Dup',
              tooltip: 'Duplicate selected layer(s) · Ctrl+D',
              enabled: controller.editorState.hasSelection,
              onPressed: controller.duplicateSelectedNodes,
            ),
            const SizedBox(width: 8),
            _ToolbarButton(
              icon: Icons.delete_outline,
              label: 'Del',
              tooltip: 'Delete selected layer(s) · Delete',
              enabled: controller.editorState.hasSelection,
              onPressed: controller.deleteSelectedNodes,
            ),
            const SizedBox(width: 8),
            _ToolbarButton(
              icon: controller.canUngroupSelected
                  ? Icons.folder_open_outlined
                  : Icons.create_new_folder_outlined,
              label: controller.canUngroupSelected ? 'Ungroup' : 'Group',
              tooltip: controller.canUngroupSelected
                  ? 'Ungroup selected group · Ctrl+Shift+G'
                  : 'Group selected layers · Ctrl+G',
              enabled: controller.canGroupSelected || controller.canUngroupSelected,
              onPressed: controller.toggleGroupSelected,
            ),
            const SizedBox(width: 10),
            _MiniDivider(),
            const SizedBox(width: 10),
            _ToolbarButton(
              icon: Icons.save_outlined,
              label: 'Mark saved',
              tooltip:
                  'Marks the current V4 draft as clean. Real save wiring comes later.',
              enabled: controller.editorState.dirty,
              onPressed: controller.markSaved,
            ),
            const SizedBox(width: 8),
            _ToolbarButton(
              icon: Icons.restart_alt,
              label: 'Reset draft',
              tooltip: 'Reset the V4 draft document. Undo is available after reset.',
              enabled: true,
              onPressed: controller.resetDocumentToBlank,
            ),
            const SizedBox(width: 8),
            if (onUseDraft != null)
              _ToolbarButton(
                icon: Icons.output_rounded,
                label: 'Use V4 Draft',
                tooltip: 'Return the current V4 JSON to the Studio V3 bridge',
                enabled: true,
                onPressed: () => onUseDraft!(controller.exportPrettyJson),
              ),
            if (onUseDraft != null) const SizedBox(width: 8),
            _ToolbarButton(
              icon: Icons.visibility_outlined,
              label: 'Preview',
              tooltip: 'Open clean Studio V4 runtime preview. No editor handles, grid, or guides.',
              enabled: true,
              onPressed: () => _showRuntimePreviewDialog(context),
            ),
            const SizedBox(width: 14),
            Text(
              'Undo ${controller.undoCount} · Redo ${controller.redoCount} · ${controller.clipboardStatusLabel}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Shortcuts: Ctrl+C/V/D · Del · Ctrl+G',
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: const Color(0xFFE5E7EB),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
