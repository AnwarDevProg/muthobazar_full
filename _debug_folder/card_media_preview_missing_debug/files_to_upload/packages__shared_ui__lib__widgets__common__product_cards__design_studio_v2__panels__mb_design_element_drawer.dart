import 'package:flutter/material.dart';

import '../models/mb_design_node_variant.dart';

// MuthoBazar Design Studio V2 Element Drawer
// -----------------------------------------
// Interaction fix:
// - Uses Draggable, not LongPressDraggable, so desktop/web drag starts normally.
// - The + button still adds immediately.
// - Drag feedback carries MBDesignNodeVariant into the canvas DragTarget.

class MBDesignElementDrawer extends StatelessWidget {
  const MBDesignElementDrawer({
    super.key,
    required this.onAddVariant,
  });

  final ValueChanged<MBDesignNodeVariant> onAddVariant;

  @override
  Widget build(BuildContext context) {
    final groups = MBDesignNodeVariantRegistry.grouped();

    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          right: BorderSide(color: Color(0xFFE6E8EF)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: Icons.widgets_rounded,
            title: 'Element Drawer',
            subtitle: 'Drag item to canvas or click +',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
              children: [
                for (final entry in groups.entries) ...[
                  _GroupTitle(
                    title: MBDesignNodeVariantRegistry.labelForElementType(
                      entry.key,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final variant in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _VariantTile(
                        variant: variant,
                        onAdd: () => onAddVariant(variant),
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VariantTile extends StatelessWidget {
  const _VariantTile({
    required this.variant,
    required this.onAdd,
  });

  final MBDesignNodeVariant variant;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final tile = _VariantTileSurface(
      variant: variant,
      onAdd: onAdd,
    );

    return Draggable<MBDesignNodeVariant>(
      data: variant,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 230,
          child: _VariantTileSurface(
            variant: variant,
            onAdd: null,
            elevated: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.45,
        child: tile,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: tile,
      ),
    );
  }
}

class _VariantTileSurface extends StatelessWidget {
  const _VariantTileSurface({
    required this.variant,
    required this.onAdd,
    this.elevated = false,
  });

  final MBDesignNodeVariant variant;
  final VoidCallback? onAdd;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF7A00).withValues(alpha: 0.18),
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : const [],
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A00).withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  variant.icon,
                  color: const Color(0xFFFF6500),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant.label,
                    style: const TextStyle(
                      color: Color(0xFF172033),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    variant.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      height: 1.18,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Add to card',
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_rounded),
              color: const Color(0xFFFF6500),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6500)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF747B8A),
                    fontSize: 11,
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

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFF6500),
        fontSize: 12,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
