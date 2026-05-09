// MuthoBazar Studio V4 Inspector Panel
//
// Purpose:
// - Provides the first real Inspector foundation for Studio V4.
// - Edits selected node identity and layout values.
// - Keeps Studio V4 separate from the active Studio V3 production editor.

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../controllers/mb_studio_v4_controller.dart';

class MBStudioV4InspectorPanel extends StatelessWidget {
  const MBStudioV4InspectorPanel({
    super.key,
    required this.controller,
  });

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selectedNode = controller.selectedNode;
        final selectedNodes = controller.selectedNodes;
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
              _InspectorHeader(
                selectedNode: selectedNode,
                selectionCount: selectedNodes.length,
                onSelectCard: controller.selectCard,
              ),
              const Divider(height: 1),
              Expanded(
                child: selectedNodes.length > 1
                    ? _MultiSelectionInspectorView(
                        controller: controller,
                        selectedNodes: selectedNodes,
                      )
                    : selectedNode == null
                        ? _CardInspectorView(controller: controller)
                        : _NodeInspectorView(
                            controller: controller,
                            node: selectedNode,
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InspectorHeader extends StatelessWidget {
  const _InspectorHeader({
    required this.selectedNode,
    required this.selectionCount,
    required this.onSelectCard,
  });

  final MBDesignNodeV4? selectedNode;
  final int selectionCount;
  final VoidCallback onSelectCard;

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
              Icons.tune,
              color: Color(0xFFFF6500),
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Inspector',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  selectionCount > 1
                      ? '$selectionCount layers selected'
                      : selectedNode?.name ?? 'Card surface selected',
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

class _CardInspectorView extends StatelessWidget {
  const _CardInspectorView({required this.controller});

  final MBStudioV4Controller controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final document = controller.document;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        _SectionTitle(
          icon: Icons.dashboard_customize_outlined,
          title: 'Card document',
          subtitle: 'Select a layer or canvas node to edit it.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _InfoChip(label: 'Name', value: document.name),
            _InfoChip(
              label: 'Canvas',
              value:
                  '${document.canvas.width.toStringAsFixed(0)}×${document.canvas.height.toStringAsFixed(0)}',
            ),
            _InfoChip(label: 'Layout', value: document.canvas.layoutType),
            _InfoChip(label: 'Nodes', value: '${document.nodes.length}'),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            'Inspector v1 edits selected node name, visibility, lock state, position, size, rotation, opacity, and z-order. Card-level editing will come in later patches.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}


class _MultiSelectionInspectorView extends StatelessWidget {
  const _MultiSelectionInspectorView({
    required this.controller,
    required this.selectedNodes,
  });

  final MBStudioV4Controller controller;
  final List<MBDesignNodeV4> selectedNodes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlockedCount = selectedNodes.where((node) => !node.locked).length;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        _SectionTitle(
          icon: Icons.select_all_outlined,
          title: '${selectedNodes.length} layers selected',
          subtitle: 'Group selected layers or clear selection to edit the card surface.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _ActionChipButton(
              icon: Icons.create_new_folder_outlined,
              label: 'Group selected',
              onPressed: controller.canGroupSelected ? controller.groupSelectedNodes : null,
            ),
            _ActionChipButton(
              icon: Icons.crop_square_outlined,
              label: 'Clear selection',
              onPressed: controller.selectCard,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            '$unlockedCount unlocked layer${unlockedCount == 1 ? '' : 's'} can be grouped. Locked layers stay protected.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitle(
          icon: Icons.layers_outlined,
          title: 'Selected layers',
          subtitle: 'Ctrl/Shift click canvas or layer rows to refine the selection.',
          dense: true,
        ),
        const SizedBox(height: 10),
        for (final node in selectedNodes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SelectedNodeSummary(node: node),
          ),
      ],
    );
  }
}

class _SelectedNodeSummary extends StatelessWidget {
  const _SelectedNodeSummary({required this.node});

  final MBDesignNodeV4 node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: <Widget>[
          Icon(_NodeInspectorView._iconForType(node.type), size: 18, color: const Color(0xFFFF6500)),
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
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${node.type.name} · z ${node.transform.zIndex}${node.locked ? ' · locked' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF64748B),
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

class _NodeInspectorView extends StatelessWidget {
  const _NodeInspectorView({
    required this.controller,
    required this.node,
  });

  final MBStudioV4Controller controller;
  final MBDesignNodeV4 node;

  @override
  Widget build(BuildContext context) {
    final transform = node.transform;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        _SectionTitle(
          icon: _iconForType(node.type),
          title: node.name,
          subtitle: '${node.type.name} · ${node.id}',
        ),
        const SizedBox(height: 12),
        _QuickActions(controller: controller, node: node),
        const SizedBox(height: 14),
        _InspectorTextField(
          label: 'Layer name',
          initialValue: node.name,
          enabled: !node.locked,
          onSubmitted: controller.updateSelectedNodeName,
        ),
        const SizedBox(height: 12),
        _SwitchTile(
          title: 'Visible',
          subtitle: 'Show this layer in the card design',
          value: node.visible,
          onChanged: controller.setSelectedNodeVisibility,
        ),
        const SizedBox(height: 8),
        _SwitchTile(
          title: 'Locked',
          subtitle: 'Prevent accidental movement or editing',
          value: node.locked,
          onChanged: controller.setSelectedNodeLocked,
        ),
        const SizedBox(height: 16),
        _SectionTitle(
          icon: Icons.open_with_outlined,
          title: 'Layout',
          subtitle: 'X/Y are normalized 0.000–1.000. Width/height are canvas pixels.',
          dense: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _NumberField(
                label: 'X',
                initialValue: transform.x,
                decimals: 3,
                enabled: !node.locked,
                onSubmitted: (value) => controller.updateSelectedNodeTransform(x: value),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberField(
                label: 'Y',
                initialValue: transform.y,
                decimals: 3,
                enabled: !node.locked,
                onSubmitted: (value) => controller.updateSelectedNodeTransform(y: value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _NumberField(
                label: 'Width',
                initialValue: transform.width,
                decimals: 0,
                enabled: !node.locked,
                onSubmitted: (value) => controller.updateSelectedNodeTransform(width: value),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberField(
                label: 'Height',
                initialValue: transform.height,
                decimals: 0,
                enabled: !node.locked,
                onSubmitted: (value) => controller.updateSelectedNodeTransform(height: value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _NumberField(
                label: 'Rotation',
                initialValue: transform.rotation,
                decimals: 1,
                enabled: !node.locked,
                onSubmitted: (value) => controller.updateSelectedNodeTransform(rotation: value),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberField(
                label: 'Opacity',
                initialValue: transform.opacity,
                decimals: 2,
                enabled: !node.locked,
                onSubmitted: (value) => controller.updateSelectedNodeTransform(opacity: value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _IntegerField(
          label: 'Z index',
          initialValue: transform.zIndex,
          enabled: !node.locked,
          onSubmitted: (value) => controller.updateSelectedNodeTransform(zIndex: value),
        ),
        const SizedBox(height: 16),
        _SectionTitle(
          icon: Icons.palette_outlined,
          title: 'Style',
          subtitle: 'Basic fill, text, border, radius, and shadow controls.',
          dense: true,
        ),
        const SizedBox(height: 12),
        _InspectorTextField(
          label: 'Fill color',
          initialValue: node.style.fill ?? '',
          enabled: !node.locked,
          onSubmitted: controller.updateSelectedNodeFill,
        ),
        const SizedBox(height: 10),
        _InspectorTextField(
          label: 'Text color',
          initialValue: _styleTextColor(node),
          enabled: !node.locked,
          onSubmitted: controller.updateSelectedNodeTextColor,
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: _InspectorTextField(
                label: 'Border color',
                initialValue: node.style.border?.color ?? '',
                enabled: !node.locked,
                onSubmitted: controller.updateSelectedNodeBorderColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberField(
                label: 'Border width',
                initialValue: node.style.border?.width ?? 0,
                decimals: 1,
                enabled: !node.locked,
                onSubmitted: controller.updateSelectedNodeBorderWidth,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _NumberField(
          label: 'Radius',
          initialValue: node.style.radius ?? 0,
          decimals: 1,
          enabled: !node.locked,
          onSubmitted: controller.updateSelectedNodeRadius,
        ),
        const SizedBox(height: 8),
        _SwitchTile(
          title: 'Soft shadow',
          subtitle: 'Apply a clean product-card shadow preset',
          value: node.style.shadows.isNotEmpty,
          onChanged: controller.setSelectedNodeSoftShadow,
        ),
        const SizedBox(height: 16),
        _SectionTitle(
          icon: Icons.auto_awesome_outlined,
          title: 'Effects',
          subtitle: 'Fast visual presets for realistic card depth and product emphasis.',
          dense: true,
        ),
        const SizedBox(height: 12),
        _EffectPresetGrid(
          selectedPreset: _effectPreset(node),
          enabled: !node.locked,
          onSelected: controller.setSelectedNodeEffectPreset,
        ),
        const SizedBox(height: 16),
        _SectionTitle(
          icon: Icons.info_outline,
          title: 'Node info',
          subtitle: 'Content/binding inspectors will come in later patches.',
          dense: true,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _InfoChip(label: 'Type', value: node.type.name),
            _InfoChip(label: 'Anchor', value: transform.anchor),
            _InfoChip(label: 'Visible', value: node.visible ? 'yes' : 'no'),
            _InfoChip(label: 'Locked', value: node.locked ? 'yes' : 'no'),
          ],
        ),
      ],
    );
  }

  static String _styleTextColor(MBDesignNodeV4 node) {
    final raw = node.style.extra['textColor'];
    if (raw is String) return raw;
    return '';
  }

  static String _effectPreset(MBDesignNodeV4 node) {
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
    if (node.style.shadows.isNotEmpty) return 'soft_shadow';
    return 'none';
  }

  static IconData _iconForType(MBDesignNodeTypeV4 type) {
    switch (type) {
      case MBDesignNodeTypeV4.media:
        return Icons.image_outlined;
      case MBDesignNodeTypeV4.text:
        return Icons.text_fields;
      case MBDesignNodeTypeV4.price:
        return Icons.sell_outlined;
      case MBDesignNodeTypeV4.badge:
        return Icons.local_offer_outlined;
      case MBDesignNodeTypeV4.button:
        return Icons.smart_button_outlined;
      case MBDesignNodeTypeV4.shape:
        return Icons.category_outlined;
      case MBDesignNodeTypeV4.group:
      case MBDesignNodeTypeV4.component:
        return Icons.folder_copy_outlined;
      default:
        return Icons.layers_outlined;
    }
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.controller,
    required this.node,
  });

  final MBStudioV4Controller controller;
  final MBDesignNodeV4 node;

  @override
  Widget build(BuildContext context) {
    final disabled = node.locked;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        if (node.type == MBDesignNodeTypeV4.group)
          _ActionChipButton(
            icon: Icons.folder_off_outlined,
            label: 'Ungroup',
            onPressed: disabled ? null : controller.ungroupSelectedGroup,
          ),
        _ActionChipButton(
          icon: Icons.content_copy,
          label: 'Duplicate',
          onPressed: disabled ? null : () => controller.duplicateNode(node.id),
        ),
        _ActionChipButton(
          icon: Icons.delete_outline,
          label: 'Delete',
          onPressed: disabled ? null : () => controller.deleteNode(node.id),
          danger: true,
        ),
        _ActionChipButton(
          icon: Icons.flip_to_front_outlined,
          label: 'Front',
          onPressed: disabled ? null : () => controller.bringNodeToFront(node.id),
        ),
        _ActionChipButton(
          icon: Icons.flip_to_back_outlined,
          label: 'Back',
          onPressed: disabled ? null : () => controller.sendNodeToBack(node.id),
        ),
      ],
    );
  }
}

class _EffectPresetGrid extends StatelessWidget {
  const _EffectPresetGrid({
    required this.selectedPreset,
    required this.enabled,
    required this.onSelected,
  });

  final String selectedPreset;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _EffectPresetButton(
          id: 'none',
          label: 'None',
          icon: Icons.block,
          selectedPreset: selectedPreset,
          enabled: enabled,
          onSelected: onSelected,
        ),
        _EffectPresetButton(
          id: 'soft_shadow',
          label: 'Soft shadow',
          icon: Icons.layers_outlined,
          selectedPreset: selectedPreset,
          enabled: enabled,
          onSelected: onSelected,
        ),
        _EffectPresetButton(
          id: 'product_glow',
          label: 'Glow',
          icon: Icons.wb_sunny_outlined,
          selectedPreset: selectedPreset,
          enabled: enabled,
          onSelected: onSelected,
        ),
        _EffectPresetButton(
          id: 'spotlight',
          label: 'Spotlight',
          icon: Icons.highlight_outlined,
          selectedPreset: selectedPreset,
          enabled: enabled,
          onSelected: onSelected,
        ),
        _EffectPresetButton(
          id: 'glass_surface',
          label: 'Glass',
          icon: Icons.blur_on_outlined,
          selectedPreset: selectedPreset,
          enabled: enabled,
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class _EffectPresetButton extends StatelessWidget {
  const _EffectPresetButton({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedPreset,
    required this.enabled,
    required this.onSelected,
  });

  final String id;
  final String label;
  final IconData icon;
  final String selectedPreset;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = selectedPreset == id;
    return OutlinedButton.icon(
      onPressed: enabled ? () => onSelected(id) : null,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? const Color(0xFFFF6500) : const Color(0xFF334155),
        backgroundColor: selected ? const Color(0xFFFFF7ED) : Colors.white,
        side: BorderSide(
          color: selected ? const Color(0xFFFFB86B) : const Color(0xFFE2E8F0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFDC2626) : const Color(0xFFFF6500);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: onPressed == null ? const Color(0xFF94A3B8) : color,
        side: BorderSide(
          color: onPressed == null
              ? const Color(0xFFE2E8F0)
              : color.withValues(alpha: 0.35),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.dense = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: dense ? 28 : 34,
          height: dense ? 28 : 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(dense ? 10 : 12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFF6500),
            size: dense ? 16 : 19,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: dense ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InspectorTextField extends StatelessWidget {
  const _InspectorTextField({
    required this.label,
    required this.initialValue,
    required this.onSubmitted,
    this.enabled = true,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey<String>('text_${label}_${initialValue}_$enabled'),
      initialValue: initialValue,
      enabled: enabled,
      decoration: _inputDecoration(label),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: onSubmitted,
      onEditingComplete: () => FocusScope.of(context).unfocus(),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.initialValue,
    required this.onSubmitted,
    this.decimals = 2,
    this.enabled = true,
  });

  final String label;
  final double initialValue;
  final int decimals;
  final ValueChanged<double> onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey<String>('num_${label}_${initialValue.toStringAsFixed(decimals)}_$enabled'),
      initialValue: initialValue.toStringAsFixed(decimals),
      enabled: enabled,
      decoration: _inputDecoration(label),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) {
        final parsed = double.tryParse(value.trim());
        if (parsed == null) return;
        onSubmitted(parsed);
      },
      onEditingComplete: () => FocusScope.of(context).unfocus(),
    );
  }
}

class _IntegerField extends StatelessWidget {
  const _IntegerField({
    required this.label,
    required this.initialValue,
    required this.onSubmitted,
    this.enabled = true,
  });

  final String label;
  final int initialValue;
  final ValueChanged<int> onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey<String>('int_${label}_${initialValue}_$enabled'),
      initialValue: '$initialValue',
      enabled: enabled,
      decoration: _inputDecoration(label),
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) {
        final parsed = int.tryParse(value.trim());
        if (parsed == null) return;
        onSubmitted(parsed);
      },
      onEditingComplete: () => FocusScope.of(context).unfocus(),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFF64748B),
          ),
          children: <TextSpan>[
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    isDense: true,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFF6500), width: 1.4),
    ),
  );
}
