import 'package:flutter/material.dart';

import '../../responsive/mb_spacing.dart';
import 'mb_admin_form_shell_widgets.dart';
import 'mb_admin_image_resize_presets.dart';

// Reusable image-form panel widgets for admin create/edit dialogs.
// These are designed for category, brand, banner, and future admin entities.

class MBAdminImagePresetSelector extends StatelessWidget {
  const MBAdminImagePresetSelector({
    super.key,
    required this.presets,
    required this.selectedPreset,
    required this.onSelected,
    this.enabled = true,
  });

  final List<MBAdminImageResizePreset> presets;
  final MBAdminImageResizePreset selectedPreset;
  final ValueChanged<MBAdminImageResizePreset> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((preset) {
            return ChoiceChip(
              label: Text(preset.label),
              selected: identical(preset, selectedPreset) || preset.id == selectedPreset.id,
              onSelected: enabled ? (_) => onSelected(preset) : null,
            );
          }).toList(),
        ),
        MBSpacing.h(MBSpacing.sm),
        Text(
          selectedPreset.note,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class MBAdminImagePanel extends StatelessWidget {
  const MBAdminImagePanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.preview,
    this.infoRows = const <Widget>[],
    this.actions = const <Widget>[],
    this.bottom = const <Widget>[],
    this.padding,
  });

  final String title;
  final String subtitle;
  final Widget preview;
  final List<Widget> infoRows;
  final List<Widget> actions;
  final List<Widget> bottom;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return MBAdminFormSectionCard(
      title: title,
      subtitle: subtitle,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          preview,
          if (infoRows.isNotEmpty) ...[
            MBSpacing.h(MBSpacing.md),
            ..._withVerticalSpacing(infoRows, MBSpacing.xs),
          ],
          if (actions.isNotEmpty) ...[
            MBSpacing.h(MBSpacing.md),
            ..._withVerticalSpacing(actions, MBSpacing.sm),
          ],
          if (bottom.isNotEmpty) ...[
            MBSpacing.h(MBSpacing.md),
            ..._withVerticalSpacing(bottom, MBSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class MBAdminDualImagePanels extends StatelessWidget {
  const MBAdminDualImagePanels({
    super.key,
    required this.left,
    required this.right,
    this.breakpoint = 900,
    this.gap = MBSpacing.md,
  });

  final Widget left;
  final Widget right;
  final double breakpoint;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            children: [
              left,
              SizedBox(height: gap),
              right,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: gap),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

List<Widget> _withVerticalSpacing(List<Widget> children, double gap) {
  if (children.isEmpty) return const <Widget>[];

  final List<Widget> result = <Widget>[];
  for (int i = 0; i < children.length; i++) {
    if (i > 0) {
      result.add(SizedBox(height: gap));
    }
    result.add(children[i]);
  }
  return result;
}
