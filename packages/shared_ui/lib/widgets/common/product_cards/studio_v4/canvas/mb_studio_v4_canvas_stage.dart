// MuthoBazar Studio V4 Canvas Stage
//
// Purpose:
// - Provides the first real Studio V4 visual canvas foundation.
// - Renders V4 document nodes on a card-sized stage.
// - Syncs canvas node selection with the Layers panel.
// - Adds basic move/drag, nudge, zoom, grid, guide, snap, and alignment controls.
//
// Notes:
// - This is still a V4 foundation widget. It does not replace Studio V3.
// - It intentionally renders safe placeholders for data-bound product nodes until
//   the V4 runtime renderer bridge is introduced in a later patch.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/shared_models.dart';

import '../controllers/mb_studio_v4_controller.dart';

class MBStudioV4CanvasStage extends StatelessWidget {
  const MBStudioV4CanvasStage({
    super.key,
    required this.controller,
  });

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final document = controller.document;
        final editorState = controller.editorState;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 10),
                color: Color(0x10000000),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _CanvasToolbar(controller: controller),
              const Divider(height: 1),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final canvasWidth = document.canvas.width <= 0
                        ? 200.0
                        : document.canvas.width;
                    final canvasHeight = document.canvas.height <= 0
                        ? 342.0
                        : document.canvas.height;
                    final safeWidth = math.max(1.0, constraints.maxWidth - 48);
                    final safeHeight = math.max(1.0, constraints.maxHeight - 48);
                    final fitScale = math.min(
                      safeWidth / canvasWidth,
                      safeHeight / canvasHeight,
                    );
                    final scale = (fitScale * editorState.zoom).clamp(0.15, 8.0).toDouble();
                    final stageWidth = canvasWidth * scale;
                    final stageHeight = canvasHeight * scale;

                    return Container(
                      color: const Color(0xFFF8FAFC),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: SizedBox(
                                width: stageWidth,
                                height: stageHeight,
                                child: _CanvasSurface(
                                  controller: controller,
                                  document: document,
                                  stageScale: scale,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _CanvasStatusBar(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class _CanvasToolbar extends StatelessWidget {
  const _CanvasToolbar({required this.controller});

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = controller.editorState;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard_customize_outlined,
              color: Color(0xFFFF6500),
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Canvas',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Drag nodes directly on the V4 stage',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _ToolbarToggle(
            tooltip: 'Grid',
            active: state.showGrid,
            icon: Icons.grid_4x4,
            onTap: controller.toggleGrid,
          ),
          _ToolbarToggle(
            tooltip: 'Guides',
            active: state.showGuides,
            icon: Icons.straighten,
            onTap: controller.toggleGuides,
          ),
          _ToolbarToggle(
            tooltip: 'Snap',
            active: state.snapEnabled,
            icon: Icons.center_focus_strong,
            onTap: controller.toggleSnap,
          ),
          const SizedBox(width: 4),
          _AlignmentMenuButton(controller: controller),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Zoom out',
            visualDensity: VisualDensity.compact,
            onPressed: controller.zoomOut,
            icon: const Icon(Icons.remove, size: 18),
          ),
          Text(
            '${(state.zoom * 100).round()}%',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF334155),
            ),
          ),
          IconButton(
            tooltip: 'Zoom in',
            visualDensity: VisualDensity.compact,
            onPressed: controller.zoomIn,
            icon: const Icon(Icons.add, size: 18),
          ),
          IconButton(
            tooltip: 'Reset viewport',
            visualDensity: VisualDensity.compact,
            onPressed: controller.resetViewport,
            icon: const Icon(Icons.fit_screen, size: 18),
          ),
        ],
      ),
    );
  }
}

class _ToolbarToggle extends StatelessWidget {
  const _ToolbarToggle({
    required this.tooltip,
    required this.active,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFFF6500) : const Color(0xFF64748B);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? const Color(0xFFFED7AA) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}

class _AlignmentMenuButton extends StatelessWidget {
  const _AlignmentMenuButton({required this.controller});

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedNode;
    final enabled = selected != null && !selected.locked;
    final color = enabled ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return Tooltip(
      message: enabled
          ? 'Align selected layer'
          : 'Select an unlocked layer to align',
      child: PopupMenuButton<String>(
        enabled: enabled,
        tooltip: 'Align selected layer',
        onSelected: (value) {
          switch (value) {
            case 'left':
              controller.alignSelectedLeft();
              break;
            case 'centerX':
              controller.alignSelectedCenterX();
              break;
            case 'right':
              controller.alignSelectedRight();
              break;
            case 'top':
              controller.alignSelectedTop();
              break;
            case 'middleY':
              controller.alignSelectedMiddleY();
              break;
            case 'bottom':
              controller.alignSelectedBottom();
              break;
            case 'snapCenterX':
              controller.snapSelectedToCardCenterX();
              break;
            case 'snapCenterY':
              controller.snapSelectedToCardCenterY();
              break;
          }
        },
        itemBuilder: (context) => const <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'left',
            child: _AlignmentMenuItem(icon: Icons.format_align_left, label: 'Align left'),
          ),
          PopupMenuItem<String>(
            value: 'centerX',
            child: _AlignmentMenuItem(icon: Icons.format_align_center, label: 'Align center'),
          ),
          PopupMenuItem<String>(
            value: 'right',
            child: _AlignmentMenuItem(icon: Icons.format_align_right, label: 'Align right'),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'top',
            child: _AlignmentMenuItem(icon: Icons.vertical_align_top, label: 'Align top'),
          ),
          PopupMenuItem<String>(
            value: 'middleY',
            child: _AlignmentMenuItem(icon: Icons.vertical_align_center, label: 'Align middle'),
          ),
          PopupMenuItem<String>(
            value: 'bottom',
            child: _AlignmentMenuItem(icon: Icons.vertical_align_bottom, label: 'Align bottom'),
          ),
          PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'snapCenterX',
            child: _AlignmentMenuItem(icon: Icons.vertical_align_center, label: 'Snap center X'),
          ),
          PopupMenuItem<String>(
            value: 'snapCenterY',
            child: _AlignmentMenuItem(icon: Icons.center_focus_strong, label: 'Snap center Y'),
          ),
        ],
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled ? const Color(0xFFE2E8F0) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Icon(Icons.format_align_center, size: 17, color: color),
        ),
      ),
    );
  }
}

class _AlignmentMenuItem extends StatelessWidget {
  const _AlignmentMenuItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: const Color(0xFF475569)),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }
}

class _CanvasSurface extends StatelessWidget {
  const _CanvasSurface({
    required this.controller,
    required this.document,
    required this.stageScale,
  });

  final MBStudioV4Controller controller;
  final MBCardDesignDocumentV4 document;
  final double stageScale;

  @override
  Widget build(BuildContext context) {
    final state = controller.editorState;
    final canvasWidth = document.canvas.width;
    final canvasHeight = document.canvas.height;
    final stageWidth = canvasWidth * stageScale;
    final stageHeight = canvasHeight * stageScale;

    return GestureDetector(
      onTap: controller.selectCard,
      child: DecoratedBox(
        decoration: _buildCanvasDecoration(document.canvas),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(document.canvas.borderRadius * stageScale),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              if (state.showGrid)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CanvasGridPainter(stageScale: stageScale),
                  ),
                ),
              if (state.showGuides)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CanvasGuidePainter(),
                  ),
                ),
              for (final node in document.sortedNodes)
                if (node.visible)
                  _CanvasNode(
                    controller: controller,
                    node: node,
                    canvasWidth: canvasWidth,
                    canvasHeight: canvasHeight,
                    stageScale: stageScale,
                  ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        document.canvas.borderRadius * stageScale,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.65),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: _CanvasSizeBadge(
                  width: stageWidth,
                  height: stageHeight,
                  canvasWidth: canvasWidth,
                  canvasHeight: canvasHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCanvasDecoration(MBDesignCanvasSpecV4 canvas) {
    if (canvas.backgroundMode == 'solid') {
      return BoxDecoration(
        color: _parseColor(canvas.backgroundColor, const Color(0xFFFF6500)),
        borderRadius: BorderRadius.circular(canvas.borderRadius * stageScale),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 30,
            offset: Offset(0, 18),
            color: Color(0x24000000),
          ),
        ],
      );
    }

    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFFF8A00),
          Color(0xFFFF6500),
          Color(0xFFFF3D00),
        ],
      ),
      borderRadius: BorderRadius.circular(canvas.borderRadius * stageScale),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          blurRadius: 30,
          offset: Offset(0, 18),
          color: Color(0x24000000),
        ),
      ],
    );
  }
}

class _CanvasNode extends StatelessWidget {
  const _CanvasNode({
    required this.controller,
    required this.node,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.stageScale,
  });

  final MBStudioV4Controller controller;
  final MBDesignNodeV4 node;
  final double canvasWidth;
  final double canvasHeight;
  final double stageScale;

  @override
  Widget build(BuildContext context) {
    final selected = controller.editorState.selectedNodeIds.contains(node.id);
    final width = math.max(8.0, node.transform.width * stageScale);
    final height = math.max(8.0, node.transform.height * stageScale);
    final left = ((node.transform.x * canvasWidth) - (node.transform.width / 2)) * stageScale;
    final top = ((node.transform.y * canvasHeight) - (node.transform.height / 2)) * stageScale;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => controller.selectNode(node.id, additive: _isMultiSelectPressed()),
        onPanUpdate: node.locked
            ? null
            : (details) {
                controller.moveNodeByCanvasDelta(
                  node.id,
                  dx: details.delta.dx / stageScale,
                  dy: details.delta.dy / stageScale,
                );
              },
        child: Opacity(
          opacity: node.transform.opacity.clamp(0.0, 1.0).toDouble(),
          child: Transform.rotate(
            angle: node.transform.rotation * math.pi / 180,
            child: Transform.scale(
              scaleX: node.transform.scaleX,
              scaleY: node.transform.scaleY,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(child: _NodePreview(node: node)),
                  if (selected)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF2563EB),
                              width: 1.5,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                blurRadius: 0,
                                spreadRadius: 2,
                                color: const Color(0xFF2563EB).withValues(alpha: 0.16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (node.locked)
                    const Positioned(
                      right: -7,
                      top: -7,
                      child: _MiniNodeBadge(icon: Icons.lock_outline),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NodePreview extends StatelessWidget {
  const _NodePreview({required this.node});

  final MBDesignNodeV4 node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectPreset = _nodeEffectPreset(node);
    final fill = _parseColor(node.style.fill, _defaultFill(node.type));
    final radius = node.style.radius ?? _defaultRadius(node.type);
    final border = node.style.border;
    final borderColor = border == null
        ? Colors.transparent
        : _parseColor(border.color, const Color(0xFFE2E8F0));
    final borderWidth = border?.width ?? 0;
    final effectGradient = _effectGradient(effectPreset);
    final effectFill = _effectFill(effectPreset, fill);
    final effectBorder = _effectBorder(effectPreset, borderColor, borderWidth);

    final decoration = BoxDecoration(
      color: effectGradient == null ? effectFill : null,
      gradient: effectGradient,
      borderRadius: BorderRadius.circular(radius),
      border: effectBorder,
      boxShadow: <BoxShadow>[
        for (final shadow in node.style.shadows)
          if (!shadow.inset)
            BoxShadow(
              color: _parseColor(shadow.color, const Color(0x22000000)),
              blurRadius: shadow.blur,
              spreadRadius: shadow.spread,
              offset: Offset(shadow.offsetX, shadow.offsetY),
            ),
        ..._effectShadows(effectPreset),
      ],
    );

    final textColor = _parseColor(
      node.style.extra['textColor'] is String
          ? node.style.extra['textColor'] as String
          : null,
      Colors.white,
    );

    return DecoratedBox(
      decoration: decoration,
      child: Padding(
        padding: _defaultPadding(node.type),
        child: _buildNodeContent(theme, textColor),
      ),
    );
  }

  Widget _buildNodeContent(ThemeData theme, Color textColor) {
    final text = _readText();
    switch (node.type) {
      case MBDesignNodeTypeV4.text:
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        );
      case MBDesignNodeTypeV4.media:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.image_outlined, color: textColor, size: 24),
            const SizedBox(height: 4),
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
      case MBDesignNodeTypeV4.price:
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            text.isEmpty ? '৳120' : text,
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      case MBDesignNodeTypeV4.badge:
      case MBDesignNodeTypeV4.delivery:
      case MBDesignNodeTypeV4.timer:
      case MBDesignNodeTypeV4.stock:
      case MBDesignNodeTypeV4.rating:
        return Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      case MBDesignNodeTypeV4.button:
        return Center(
          child: Text(
            text.isEmpty ? 'Buy now' : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      case MBDesignNodeTypeV4.divider:
        return const SizedBox.shrink();
      case MBDesignNodeTypeV4.icon:
        return Center(
          child: Icon(Icons.star_rounded, color: textColor, size: 22),
        );
      case MBDesignNodeTypeV4.group:
        return Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.folder_copy_outlined, size: 13, color: textColor),
                  const SizedBox(width: 4),
                  Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case MBDesignNodeTypeV4.shape:
      case MBDesignNodeTypeV4.component:
      case MBDesignNodeTypeV4.cardSurface:
      case MBDesignNodeTypeV4.unknown:
        return Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor.withValues(alpha: 0.88),
              fontWeight: FontWeight.w800,
            ),
          ),
        );
    }
  }

  String _readText() {
    final manual = node.content['text'];
    if (manual is String && manual.trim().isNotEmpty) return manual.trim();
    final label = node.props['label'];
    if (label is String && label.trim().isNotEmpty) return label.trim();
    if (node.binding != null && node.binding!.path.trim().isNotEmpty) {
      return node.binding!.path.trim();
    }
    return node.name;
  }
}

class _MiniNodeBadge extends StatelessWidget {
  const _MiniNodeBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(icon, size: 11, color: Colors.white),
      ),
    );
  }
}

class _CanvasSizeBadge extends StatelessWidget {
  const _CanvasSizeBadge({
    required this.width,
    required this.height,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  final double width;
  final double height;
  final double canvasWidth;
  final double canvasHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          '${canvasWidth.toStringAsFixed(0)}×${canvasHeight.toStringAsFixed(0)}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CanvasStatusBar extends StatelessWidget {
  const _CanvasStatusBar({required this.controller});

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = controller.selectedNode;
    final selectedNodes = controller.selectedNodes;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              selectedNodes.length > 1
                  ? 'Selected: ${selectedNodes.length} layers · hold Ctrl/Shift and click to multi-select · use Inspector to group'
                  : selected == null
                      ? 'Card surface selected · click any layer or node to edit'
                      : 'Selected: ${selected.name} · X ${selected.transform.x.toStringAsFixed(3)} · Y ${selected.transform.y.toStringAsFixed(3)} · Z ${selected.transform.zIndex}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Nudge left',
            visualDensity: VisualDensity.compact,
            onPressed: selected == null
                ? null
                : () => controller.nudgeSelectedNode(dx: -2),
            icon: const Icon(Icons.keyboard_arrow_left, size: 18),
          ),
          IconButton(
            tooltip: 'Nudge up',
            visualDensity: VisualDensity.compact,
            onPressed: selected == null
                ? null
                : () => controller.nudgeSelectedNode(dy: -2),
            icon: const Icon(Icons.keyboard_arrow_up, size: 18),
          ),
          IconButton(
            tooltip: 'Nudge down',
            visualDensity: VisualDensity.compact,
            onPressed: selected == null
                ? null
                : () => controller.nudgeSelectedNode(dy: 2),
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          ),
          IconButton(
            tooltip: 'Nudge right',
            visualDensity: VisualDensity.compact,
            onPressed: selected == null
                ? null
                : () => controller.nudgeSelectedNode(dx: 2),
            icon: const Icon(Icons.keyboard_arrow_right, size: 18),
          ),
        ],
      ),
    );
  }
}

class _CanvasGridPainter extends CustomPainter {
  const _CanvasGridPainter({required this.stageScale});

  final double stageScale;

  @override
  void paint(Canvas canvas, Size size) {
    final step = math.max(8.0, 20 * stageScale);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasGridPainter oldDelegate) {
    return oldDelegate.stageScale != stageScale;
  }
}

class _CanvasGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..strokeWidth = 1.1;
    final safePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );

    final safeRect = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.06,
      size.width * 0.84,
      size.height * 0.88,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(safeRect, const Radius.circular(12)),
      safePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


bool _isMultiSelectPressed() {
  final keys = HardwareKeyboard.instance.logicalKeysPressed;
  return keys.contains(LogicalKeyboardKey.controlLeft) ||
      keys.contains(LogicalKeyboardKey.controlRight) ||
      keys.contains(LogicalKeyboardKey.shiftLeft) ||
      keys.contains(LogicalKeyboardKey.shiftRight) ||
      keys.contains(LogicalKeyboardKey.metaLeft) ||
      keys.contains(LogicalKeyboardKey.metaRight);
}

Color _defaultFill(MBDesignNodeTypeV4 type) {
  return switch (type) {
    MBDesignNodeTypeV4.text => const Color(0x00000000),
    MBDesignNodeTypeV4.media => Colors.white.withValues(alpha: 0.22),
    MBDesignNodeTypeV4.price => const Color(0xFF111827),
    MBDesignNodeTypeV4.badge => const Color(0xFFEF4444),
    MBDesignNodeTypeV4.button => const Color(0xFF16A34A),
    MBDesignNodeTypeV4.delivery => const Color(0xFF0F766E),
    MBDesignNodeTypeV4.timer => const Color(0xFF7C3AED),
    MBDesignNodeTypeV4.stock => const Color(0xFF0369A1),
    MBDesignNodeTypeV4.rating => const Color(0xFFF59E0B),
    MBDesignNodeTypeV4.divider => Colors.white.withValues(alpha: 0.72),
    MBDesignNodeTypeV4.icon => const Color(0xFF111827),
    MBDesignNodeTypeV4.shape => Colors.white.withValues(alpha: 0.22),
    MBDesignNodeTypeV4.cardSurface => Colors.transparent,
    MBDesignNodeTypeV4.group => Colors.white.withValues(alpha: 0.12),
    MBDesignNodeTypeV4.component => Colors.white.withValues(alpha: 0.12),
    MBDesignNodeTypeV4.unknown => Colors.white.withValues(alpha: 0.18),
  };
}

double _defaultRadius(MBDesignNodeTypeV4 type) {
  return switch (type) {
    MBDesignNodeTypeV4.media => 18,
    MBDesignNodeTypeV4.price => 16,
    MBDesignNodeTypeV4.badge => 999,
    MBDesignNodeTypeV4.button => 999,
    MBDesignNodeTypeV4.delivery => 999,
    MBDesignNodeTypeV4.timer => 999,
    MBDesignNodeTypeV4.stock => 999,
    MBDesignNodeTypeV4.rating => 999,
    MBDesignNodeTypeV4.shape => 20,
    _ => 10,
  };
}


String _nodeEffectPreset(MBDesignNodeV4 node) {
  for (final effect in node.effects) {
    if (!effect.enabled) continue;
    switch (effect.type) {
      case 'softShadow':
        return 'soft_shadow';
      case 'productGlow':
        return 'product_glow';
      case 'spotlight':
        return 'spotlight';
      case 'glassSurface':
        return 'glass_surface';
    }
  }
  return 'none';
}

Color _effectFill(String preset, Color fallback) {
  return switch (preset) {
    'glass_surface' => Colors.white.withValues(alpha: 0.20),
    'spotlight' => Colors.white.withValues(alpha: 0.10),
    _ => fallback,
  };
}

Gradient? _effectGradient(String preset) {
  return switch (preset) {
    'spotlight' => RadialGradient(
        center: Alignment.center,
        radius: 0.82,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.82),
          const Color(0xFFFFB020).withValues(alpha: 0.24),
          Colors.white.withValues(alpha: 0.02),
        ],
      ),
    'glass_surface' => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.42),
          Colors.white.withValues(alpha: 0.14),
        ],
      ),
    _ => null,
  };
}

BoxBorder? _effectBorder(String preset, Color borderColor, double borderWidth) {
  if (borderWidth > 0) return Border.all(color: borderColor, width: borderWidth);
  if (preset == 'glass_surface') {
    return Border.all(
      color: Colors.white.withValues(alpha: 0.48),
      width: 1,
    );
  }
  return null;
}

List<BoxShadow> _effectShadows(String preset) {
  return switch (preset) {
    'soft_shadow' => const <BoxShadow>[
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ],
    'product_glow' => <BoxShadow>[
        BoxShadow(
          color: const Color(0xFFFFB020).withValues(alpha: 0.42),
          blurRadius: 28,
          spreadRadius: 2,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.16),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, -2),
        ),
      ],
    'spotlight' => const <BoxShadow>[
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 22,
          offset: Offset(0, 10),
        ),
      ],
    'glass_surface' => <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.14),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.18),
          blurRadius: 8,
          offset: const Offset(-2, -2),
        ),
      ],
    _ => const <BoxShadow>[],
  };
}

EdgeInsets _defaultPadding(MBDesignNodeTypeV4 type) {
  return switch (type) {
    MBDesignNodeTypeV4.text => const EdgeInsets.all(2),
    MBDesignNodeTypeV4.media => const EdgeInsets.all(8),
    MBDesignNodeTypeV4.divider => EdgeInsets.zero,
    _ => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  };
}

Color _parseColor(String? raw, Color fallback) {
  if (raw == null || raw.trim().isEmpty) return fallback;
  var value = raw.trim();
  if (value.startsWith('#')) value = value.substring(1);
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return fallback;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return fallback;
  return Color(parsed);
}
