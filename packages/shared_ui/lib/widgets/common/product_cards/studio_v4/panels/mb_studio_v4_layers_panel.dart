// MuthoBazar Studio V4 Layers Panel
//
// Purpose:
// - Provides the first professional layer-management surface for Studio V4.
// - Displays document nodes in visual layer order.
// - Supports select, show/hide, lock/unlock, duplicate, delete, and z-order actions.
// - This is a foundation panel; grouping and drag-reorder will come later.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/shared_models.dart';

import '../controllers/mb_studio_v4_controller.dart';

class MBStudioV4LayersPanel extends StatelessWidget {
  const MBStudioV4LayersPanel({
    super.key,
    required this.controller,
  });

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final nodes = controller.layerNodes;
        final childCountByParent = <String, int>{};
        for (final node in controller.document.nodes) {
          final parentId = node.parentId;
          if (parentId == null) continue;
          childCountByParent[parentId] = (childCountByParent[parentId] ?? 0) + 1;
        }
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 10),
                color: Color(0x14000000),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _LayersHeader(
                nodeCount: nodes.length,
                selectionCount: controller.editorState.selectedNodeIds.length,
                canGroup: controller.canGroupSelected,
                canUngroup: controller.canUngroupSelected,
                onSelectCard: controller.selectCard,
                onGroup: controller.groupSelectedNodes,
                onUngroup: controller.ungroupSelectedGroup,
              ),
              const Divider(height: 1),
              Expanded(
                child: nodes.isEmpty
                    ? const _EmptyLayersState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(10),
                        itemCount: nodes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final node = nodes[index];
                          final selected = controller
                              .editorState.selectedNodeIds
                              .contains(node.id);
                          return _LayerTile(
                            node: node,
                            selected: selected,
                            depth: node.parentId == null ? 0 : 1,
                            childCount: childCountByParent[node.id] ?? 0,
                            onSelect: () => controller.selectNode(
                              node.id,
                              additive: _isMultiSelectPressed(),
                            ),
                            onToggleVisible: () =>
                                controller.toggleNodeVisibility(node.id),
                            onToggleLocked: () => controller.toggleNodeLock(node.id),
                            onDuplicate: node.locked
                                ? null
                                : () => controller.duplicateNode(node.id),
                            onDelete: node.locked
                                ? null
                                : () => controller.deleteNode(node.id),
                            onForward: node.locked
                                ? null
                                : () => controller.bringNodeForward(node.id),
                            onBackward: node.locked
                                ? null
                                : () => controller.sendNodeBackward(node.id),
                            onFront: node.locked
                                ? null
                                : () => controller.bringNodeToFront(node.id),
                            onBack: node.locked
                                ? null
                                : () => controller.sendNodeToBack(node.id),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LayersHeader extends StatelessWidget {
  const _LayersHeader({
    required this.nodeCount,
    required this.selectionCount,
    required this.canGroup,
    required this.canUngroup,
    required this.onSelectCard,
    required this.onGroup,
    required this.onUngroup,
  });

  final int nodeCount;
  final int selectionCount;
  final bool canGroup;
  final bool canUngroup;
  final VoidCallback onSelectCard;
  final VoidCallback onGroup;
  final VoidCallback onUngroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
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
              Icons.layers_outlined,
              color: Color(0xFFFF6500),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Layers',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  selectionCount > 1
                      ? '$selectionCount selected · Ctrl/Shift click to refine'
                      : '$nodeCount node${nodeCount == 1 ? '' : 's'} · top first',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: canGroup ? 'Group selected layers' : 'Select 2+ unlocked layers to group',
            visualDensity: VisualDensity.compact,
            onPressed: canGroup ? onGroup : null,
            icon: const Icon(Icons.create_new_folder_outlined, size: 18),
          ),
          IconButton(
            tooltip: canUngroup ? 'Ungroup selected group' : 'Select a group to ungroup',
            visualDensity: VisualDensity.compact,
            onPressed: canUngroup ? onUngroup : null,
            icon: const Icon(Icons.folder_off_outlined, size: 18),
          ),
          IconButton(
            tooltip: 'Select card surface',
            visualDensity: VisualDensity.compact,
            onPressed: onSelectCard,
            icon: const Icon(Icons.crop_square_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _EmptyLayersState extends StatelessWidget {
  const _EmptyLayersState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.layers_clear_outlined,
              color: Color(0xFF94A3B8),
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              'No layers yet',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'V4 blocks and element creation will add nodes here in later patches.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayerTile extends StatelessWidget {
  const _LayerTile({
    required this.node,
    required this.selected,
    required this.depth,
    required this.childCount,
    required this.onSelect,
    required this.onToggleVisible,
    required this.onToggleLocked,
    required this.onDuplicate,
    required this.onDelete,
    required this.onForward,
    required this.onBackward,
    required this.onFront,
    required this.onBack,
  });

  final MBDesignNodeV4 node;
  final bool selected;
  final int depth;
  final int childCount;
  final VoidCallback onSelect;
  final VoidCallback onToggleVisible;
  final VoidCallback onToggleLocked;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final VoidCallback? onForward;
  final VoidCallback? onBackward;
  final VoidCallback? onFront;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = !node.visible;
    return Padding(
      padding: EdgeInsets.only(left: depth * 14.0),
      child: Material(
      color: selected ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFFFF6500) : const Color(0xFFE5E7EB),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _LayerTypeIcon(type: node.type, muted: muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          node.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: muted
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${node.type.name} · z ${node.transform.zIndex}'
                          '${node.parentId == null ? '' : ' · grouped'}'
                          '${childCount <= 0 ? '' : ' · $childCount child${childCount == 1 ? '' : 'ren'}'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: node.visible ? 'Hide layer' : 'Show layer',
                    visualDensity: VisualDensity.compact,
                    onPressed: onToggleVisible,
                    icon: Icon(
                      node.visible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                  ),
                  IconButton(
                    tooltip: node.locked ? 'Unlock layer' : 'Lock layer',
                    visualDensity: VisualDensity.compact,
                    onPressed: onToggleLocked,
                    icon: Icon(
                      node.locked ? Icons.lock_outline : Icons.lock_open_outlined,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  _LayerActionButton(
                    tooltip: 'To front',
                    icon: Icons.vertical_align_top,
                    onPressed: onFront,
                  ),
                  _LayerActionButton(
                    tooltip: 'Forward',
                    icon: Icons.keyboard_arrow_up,
                    onPressed: onForward,
                  ),
                  _LayerActionButton(
                    tooltip: 'Backward',
                    icon: Icons.keyboard_arrow_down,
                    onPressed: onBackward,
                  ),
                  _LayerActionButton(
                    tooltip: 'To back',
                    icon: Icons.vertical_align_bottom,
                    onPressed: onBack,
                  ),
                  _LayerActionButton(
                    tooltip: 'Duplicate',
                    icon: Icons.content_copy_outlined,
                    onPressed: onDuplicate,
                  ),
                  _LayerActionButton(
                    tooltip: 'Delete',
                    icon: Icons.delete_outline,
                    danger: true,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _LayerTypeIcon extends StatelessWidget {
  const _LayerTypeIcon({required this.type, required this.muted});

  final MBDesignNodeTypeV4 type;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      MBDesignNodeTypeV4.text => Icons.text_fields,
      MBDesignNodeTypeV4.media => Icons.image_outlined,
      MBDesignNodeTypeV4.price => Icons.sell_outlined,
      MBDesignNodeTypeV4.badge => Icons.local_offer_outlined,
      MBDesignNodeTypeV4.button => Icons.smart_button_outlined,
      MBDesignNodeTypeV4.group => Icons.folder_copy_outlined,
      MBDesignNodeTypeV4.cardSurface => Icons.crop_square_outlined,
      MBDesignNodeTypeV4.shape => Icons.category_outlined,
      MBDesignNodeTypeV4.icon => Icons.star_border,
      _ => Icons.layers_outlined,
    };

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: muted ? const Color(0xFFF1F5F9) : const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 18,
        color: muted ? const Color(0xFF94A3B8) : const Color(0xFFFF6500),
      ),
    );
  }
}

class _LayerActionButton extends StatelessWidget {
  const _LayerActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.danger = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final activeColor = danger ? const Color(0xFFDC2626) : const Color(0xFF334155);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onPressed,
        child: Container(
          width: 30,
          height: 28,
          decoration: BoxDecoration(
            color: onPressed == null ? const Color(0xFFE5E7EB) : Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(
            icon,
            size: 16,
            color: onPressed == null ? const Color(0xFFCBD5E1) : activeColor,
          ),
        ),
      ),
    );
  }
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
