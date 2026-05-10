// MuthoBazar Studio V4 Runtime Preview Renderer
//
// Purpose:
// - Renders a Studio V4 document as a clean card preview.
// - Shows the future runtime output without editor handles, grids, guides,
//   selection boxes, layers, or inspector controls.
// - This is still a lab/preview renderer. It does not replace the current
//   customer/admin product-card renderer yet.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class MBStudioV4RuntimePreviewRenderer extends StatelessWidget {
  const MBStudioV4RuntimePreviewRenderer({
    super.key,
    required this.document,
    this.backgroundColor = const Color(0xFFF8FAFC),
  });

  final MBCardDesignDocumentV4 document;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final canvasWidth = document.canvas.width <= 0 ? 200.0 : document.canvas.width;
    final canvasHeight = document.canvas.height <= 0 ? 342.0 : document.canvas.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        final safeWidth = math.max(1.0, constraints.maxWidth - 32);
        final safeHeight = math.max(1.0, constraints.maxHeight - 32);
        final scale = math.min(
          safeWidth / canvasWidth,
          safeHeight / canvasHeight,
        ).clamp(0.25, 4.0).toDouble();

        return Container(
          alignment: Alignment.center,
          color: backgroundColor,
          child: SizedBox(
            width: canvasWidth * scale,
            height: canvasHeight * scale,
            child: MBStudioV4RuntimePreviewCard(
              document: document,
              scale: scale,
            ),
          ),
        );
      },
    );
  }
}

class MBStudioV4RuntimePreviewCard extends StatelessWidget {
  const MBStudioV4RuntimePreviewCard({
    super.key,
    required this.document,
    this.scale = 1,
  });

  final MBCardDesignDocumentV4 document;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final canvas = document.canvas;
    final width = canvas.width <= 0 ? 200.0 : canvas.width;
    final height = canvas.height <= 0 ? 342.0 : canvas.height;
    final visibleNodes = <MBDesignNodeV4>[
      for (final node in document.sortedNodes)
        if (node.visible && node.type != MBDesignNodeTypeV4.group) node,
    ];

    return DecoratedBox(
      decoration: _buildCardDecoration(canvas, scale),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(canvas.borderRadius * scale),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                  ),
                ),
              ),
            ),
            for (final node in visibleNodes)
              _RuntimeNode(
                node: node,
                canvasWidth: width,
                canvasHeight: height,
                scale: scale,
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(MBDesignCanvasSpecV4 canvas, double scale) {
    if (canvas.backgroundMode == 'solid') {
      return BoxDecoration(
        color: _parseColor(canvas.backgroundColor, const Color(0xFFFF6500)),
        borderRadius: BorderRadius.circular(canvas.borderRadius * scale),
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
      borderRadius: BorderRadius.circular(canvas.borderRadius * scale),
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

class _RuntimeNode extends StatelessWidget {
  const _RuntimeNode({
    required this.node,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.scale,
  });

  final MBDesignNodeV4 node;
  final double canvasWidth;
  final double canvasHeight;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final width = math.max(1.0, node.transform.width * scale);
    final height = math.max(1.0, node.transform.height * scale);
    final left = ((node.transform.x * canvasWidth) - (node.transform.width / 2)) * scale;
    final top = ((node.transform.y * canvasHeight) - (node.transform.height / 2)) * scale;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Opacity(
        opacity: node.transform.opacity.clamp(0.0, 1.0).toDouble(),
        child: Transform.rotate(
          angle: node.transform.rotation * math.pi / 180,
          child: Transform.scale(
            scaleX: node.transform.scaleX,
            scaleY: node.transform.scaleY,
            child: _RuntimeNodePreview(node: node),
          ),
        ),
      ),
    );
  }
}

class _RuntimeNodePreview extends StatelessWidget {
  const _RuntimeNodePreview({required this.node});

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
    final decoration = BoxDecoration(
      color: effectGradient == null ? _effectFill(effectPreset, fill) : null,
      gradient: effectGradient,
      borderRadius: BorderRadius.circular(radius),
      border: _effectBorder(effectPreset, borderColor, borderWidth),
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

    if (node.type == MBDesignNodeTypeV4.divider) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          height: math.max(1.0, node.transform.height),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      );
    }

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
        return _MediaPlaceholder(
          text: text,
          color: textColor,
          isTransparent: _isTransparentMediaNode(node),
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
      case MBDesignNodeTypeV4.icon:
        return Center(child: Icon(Icons.star_rounded, color: textColor, size: 22));
      case MBDesignNodeTypeV4.shape:
      case MBDesignNodeTypeV4.component:
      case MBDesignNodeTypeV4.cardSurface:
      case MBDesignNodeTypeV4.group:
      case MBDesignNodeTypeV4.divider:
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
      return _bindingFallback(node.binding!.path);
    }
    if (node.name.trim().isNotEmpty) return node.name.trim();
    return node.type.name;
  }
}

class _MediaPlaceholder extends StatelessWidget {
  const _MediaPlaceholder({
    required this.text,
    required this.color,
    required this.isTransparent,
  });

  final String text;
  final Color color;
  final bool isTransparent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          isTransparent ? Icons.auto_fix_high : Icons.image_outlined,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          isTransparent ? 'Cutout image' : text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

String _bindingFallback(String path) {
  final normalized = path.toLowerCase();
  if (normalized.contains('transparent')) return 'Cutout image';
  if (normalized.contains('image')) return 'Product image';
  if (normalized.contains('price')) return '৳120';
  if (normalized.contains('discount')) return '15% OFF';
  if (normalized.contains('delivery')) return 'Fast delivery';
  if (normalized.contains('stock')) return 'In stock';
  if (normalized.contains('title') || normalized.contains('name')) return 'Product title';
  return path;
}

bool _isTransparentMediaNode(MBDesignNodeV4 node) {
  final binding = node.binding?.path.toLowerCase() ?? '';
  final role = node.props['templateRole']?.toString().toLowerCase() ?? '';
  final kind = node.props['mediaKind']?.toString().toLowerCase() ?? '';
  return binding.contains('transparent') ||
      role.contains('transparent') ||
      role.contains('cutout') ||
      kind.contains('transparent') ||
      kind.contains('cutout');
}

Color _defaultFill(MBDesignNodeTypeV4 type) {
  return switch (type) {
    MBDesignNodeTypeV4.text => Colors.transparent,
    MBDesignNodeTypeV4.media => Colors.white.withValues(alpha: 0.18),
    MBDesignNodeTypeV4.price => Colors.black.withValues(alpha: 0.30),
    MBDesignNodeTypeV4.badge => const Color(0xFF111827),
    MBDesignNodeTypeV4.button => const Color(0xFF111827),
    MBDesignNodeTypeV4.delivery => Colors.white.withValues(alpha: 0.18),
    MBDesignNodeTypeV4.timer => const Color(0xFFDC2626),
    MBDesignNodeTypeV4.stock => const Color(0xFF16A34A),
    MBDesignNodeTypeV4.rating => const Color(0xFFFFB020),
    MBDesignNodeTypeV4.divider => Colors.white.withValues(alpha: 0.72),
    MBDesignNodeTypeV4.icon => const Color(0xFF111827),
    MBDesignNodeTypeV4.shape => Colors.white.withValues(alpha: 0.22),
    MBDesignNodeTypeV4.cardSurface => Colors.transparent,
    MBDesignNodeTypeV4.group => Colors.transparent,
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

EdgeInsets _defaultPadding(MBDesignNodeTypeV4 type) {
  return switch (type) {
    MBDesignNodeTypeV4.text => const EdgeInsets.all(2),
    MBDesignNodeTypeV4.media => const EdgeInsets.all(8),
    MBDesignNodeTypeV4.divider => EdgeInsets.zero,
    _ => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
