import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class AdminProductCardStyleSelector extends StatelessWidget {
  const AdminProductCardStyleSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = MBProductCardLayoutHelper.parse(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer App Card Style',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose how this product should appear in the customer app. Unsupported sections can still fall back safely.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.25,
          children: MBProductCardLayoutHelper.values
              .map(
                (layout) => _CardLayoutTile(
              layout: layout,
              selected: layout == selected,
              enabled: enabled,
              onTap: () => onChanged(layout.value),
            ),
          )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _CardLayoutTile extends StatelessWidget {
  const _CardLayoutTile({
    required this.layout,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final MBProductCardLayout layout;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: 0.30);
    final fillColor = selected
        ? colorScheme.primary.withValues(alpha: 0.08)
        : colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 1.8 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      layout.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                    color: selected ? colorScheme.primary : colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _CardMiniPreview(layout: layout),
              ),
              const SizedBox(height: 10),
              Text(
                _descriptionFor(layout),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _descriptionFor(MBProductCardLayout layout) {
    switch (layout) {
      case MBProductCardLayout.standard:
        return 'Balanced default card for regular product grids.';
      case MBProductCardLayout.compact:
        return 'Tighter card for denser rows and faster scanning.';
      case MBProductCardLayout.deal:
        return 'Promotion-focused layout with strong discount emphasis.';
      case MBProductCardLayout.featured:
        return 'Richer premium layout for spotlighted products.';
    }
  }
}

class _CardMiniPreview extends StatelessWidget {
  const _CardMiniPreview({required this.layout});

  final MBProductCardLayout layout;

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case MBProductCardLayout.standard:
        return const _StandardPreview();
      case MBProductCardLayout.compact:
        return const _CompactPreview();
      case MBProductCardLayout.deal:
        return const _DealPreview();
      case MBProductCardLayout.featured:
        return const _FeaturedPreview();
    }
  }
}

class _PreviewShell extends StatelessWidget {
  const _PreviewShell({
    required this.child,
    this.padding = const EdgeInsets.all(10),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      child: child,
    );
  }
}

class _StandardPreview extends StatelessWidget {
  const _StandardPreview();

  @override
  Widget build(BuildContext context) {
    return _PreviewShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _Line(widthFactor: 0.82),
          const SizedBox(height: 6),
          const _Line(widthFactor: 0.48),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(child: _Pill(label: 'Price')),
              SizedBox(width: 6),
              Expanded(child: _Pill(label: 'Stock')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactPreview extends StatelessWidget {
  const _CompactPreview();

  @override
  Widget build(BuildContext context) {
    return _PreviewShell(
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Line(widthFactor: 0.78),
                SizedBox(height: 6),
                _Line(widthFactor: 0.52),
                SizedBox(height: 8),
                _Pill(label: 'Price'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DealPreview extends StatelessWidget {
  const _DealPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PreviewShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'DEAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const _Line(widthFactor: 0.76),
          const SizedBox(height: 6),
          Row(
            children: const [
              Expanded(child: _Pill(label: 'Sale')),
              SizedBox(width: 6),
              Expanded(child: _Pill(label: 'Save')),
            ],
          ),
          const SizedBox(height: 6),
          const _Line(widthFactor: 0.40),
        ],
      ),
    );
  }
}

class _FeaturedPreview extends StatelessWidget {
  const _FeaturedPreview();

  @override
  Widget build(BuildContext context) {
    return _PreviewShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const _Pill(label: 'Featured'),
          const SizedBox(height: 8),
          const _Line(widthFactor: 0.84),
          const SizedBox(height: 6),
          const _Line(widthFactor: 0.62),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
