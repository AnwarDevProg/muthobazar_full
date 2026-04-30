// File: mb_advanced_product_card_renderer.dart
//
// Advanced Product Card Runtime Renderer
// --------------------------------------
// Patch 11.2: Studio/Home V3 render parity.
//
// Purpose:
// - Render product.cardDesignJson directly in customer Home/product cards.
// - Treat the saved V3 node JSON as the single visual source of truth.
// - Match Studio V3 preview more closely by using the same design-size stage,
//   scaled with a FittedBox instead of rebuilding a different template.
// - Render only the nodes saved in cardDesignJson; no legacy/default badges are
//   injected by this runtime renderer.
//
// Notes:
// - Higher z is rendered on top.
// - Card width/height are read from layout.cardWidth/cardHeight.
// - The card is clipped to the saved card radius.
// - The orange poster background is painted here so Home and Studio do not use
//   the old saved-design/template renderer.

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class MBAdvancedProductCardRenderer extends StatelessWidget {
  const MBAdvancedProductCardRenderer({
    super.key,
    required this.product,
    required this.designJson,
    this.onTap,
    this.onAddToCartTap,
    this.trailingOverlay,
  });

  final MBProduct product;
  final String designJson;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCartTap;
  final Widget? trailingOverlay;

  static bool canRender(String? rawJson) {
    final source = rawJson?.trim();
    if (source == null || source.isEmpty) return false;

    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map) return false;

      final type = decoded['type']?.toString().trim();
      final nodes = decoded['nodes'];

      return type == 'muthobazar_card_design_advanced_v2' &&
          nodes is List &&
          nodes.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final design = _V3CardDesign.tryParse(designJson);
    if (design == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (_, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: SizedBox(
                width: design.cardWidth,
                height: design.cardHeight,
                child: _RuntimeCardStage(
                  product: product,
                  design: design,
                  onAddToCartTap: onAddToCartTap,
                  trailingOverlay: trailingOverlay,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RuntimeCardStage extends StatelessWidget {
  const _RuntimeCardStage({
    required this.product,
    required this.design,
    this.onAddToCartTap,
    this.trailingOverlay,
  });

  final MBProduct product;
  final _V3CardDesign design;
  final VoidCallback? onAddToCartTap;
  final Widget? trailingOverlay;

  @override
  Widget build(BuildContext context) {
    final sortedNodes = <_V3DesignNode>[
      ...design.nodes.where((node) => node.visible),
    ]..sort((a, b) => a.z.compareTo(b.z));

    final radius = BorderRadius.circular(design.borderRadius);

    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _V3HeroPosterBackgroundPainter(
                  background1: _parseColor(
                    design.palette['backgroundHex'],
                    fallback: const Color(0xFFFF6500),
                  ),
                  background2: _parseColor(
                    design.palette['backgroundHex2'],
                    fallback: const Color(0xFFFF9A3D),
                  ),
                  surface: _parseColor(
                    design.palette['surfaceHex'],
                    fallback: Colors.white,
                  ),
                ),
              ),
            ),
            for (final node in sortedNodes)
              _PositionedRuntimeNode(
                product: product,
                node: node,
                cardWidth: design.cardWidth,
                cardHeight: design.cardHeight,
                onAddToCartTap: onAddToCartTap,
              ),
            if (trailingOverlay != null)
              Positioned.fill(child: trailingOverlay!),
          ],
        ),
      ),
    );
  }
}

class _V3HeroPosterBackgroundPainter extends CustomPainter {
  const _V3HeroPosterBackgroundPainter({
    required this.background1,
    required this.background2,
    required this.surface,
  });

  final Color background1;
  final Color background2;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [background1, background2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

    _drawSubtleGrid(canvas, size);
    _drawPosterHighlights(canvas, size);
  }

  void _drawSubtleGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..strokeWidth = 0.7;

    const gap = 14.0;

    for (double x = gap; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = gap; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawPosterHighlights(Canvas canvas, Size size) {
    final softCirclePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.98, size.height * 0.18),
      size.width * 0.34,
      softCirclePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.10, size.height * 0.20),
      size.width * 0.28,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.fill,
    );

    // Cream wave used in the Studio V3 hero poster design. It intentionally
    // stays mostly in the middle area, leaving enough orange in the lower area
    // so saved white subtitle nodes remain readable in Home.
    final wavePath = Path()
      ..moveTo(0, size.height * 0.56)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.50,
        size.width * 0.30,
        size.height * 0.46,
        size.width * 0.48,
        size.height * 0.49,
      )
      ..cubicTo(
        size.width * 0.70,
        size.height * 0.53,
        size.width * 0.82,
        size.height * 0.47,
        size.width,
        size.height * 0.42,
      )
      ..lineTo(size.width, size.height * 0.66)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.72,
        size.width * 0.50,
        size.height * 0.72,
        0,
        size.height * 0.72,
      )
      ..close();

    canvas.drawPath(
      wavePath,
      Paint()
        ..color = surface.withValues(alpha: 0.90)
        ..style = PaintingStyle.fill,
    );

    final lowerGlow = Rect.fromLTWH(
      0,
      size.height * 0.66,
      size.width,
      size.height * 0.34,
    );

    canvas.drawRect(
      lowerGlow,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.03),
            background2.withValues(alpha: 0.10),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(lowerGlow),
    );
  }

  @override
  bool shouldRepaint(covariant _V3HeroPosterBackgroundPainter oldDelegate) {
    return oldDelegate.background1 != background1 ||
        oldDelegate.background2 != background2 ||
        oldDelegate.surface != surface;
  }
}

class _PositionedRuntimeNode extends StatelessWidget {
  const _PositionedRuntimeNode({
    required this.product,
    required this.node,
    required this.cardWidth,
    required this.cardHeight,
    this.onAddToCartTap,
  });

  final MBProduct product;
  final _V3DesignNode node;
  final double cardWidth;
  final double cardHeight;
  final VoidCallback? onAddToCartTap;

  @override
  Widget build(BuildContext context) {
    final width = node.width.clamp(1, cardWidth * 2).toDouble();
    final height = node.height.clamp(1, cardHeight * 2).toDouble();

    final left = (node.x * cardWidth) - (width / 2);
    final top = (node.y * cardHeight) - (height / 2);

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: ClipRect(
        child: _RuntimeNodeContent(
          product: product,
          node: node,
          onAddToCartTap: onAddToCartTap,
        ),
      ),
    );
  }
}

class _RuntimeNodeContent extends StatelessWidget {
  const _RuntimeNodeContent({
    required this.product,
    required this.node,
    this.onAddToCartTap,
  });

  final MBProduct product;
  final _V3DesignNode node;
  final VoidCallback? onAddToCartTap;

  @override
  Widget build(BuildContext context) {
    switch (node.elementType) {
      case 'media':
      case 'product_image':
        return _MediaNode(product: product, node: node);
      case 'cta':
      case 'main_cta':
      case 'secondary_cta':
        return _ButtonNode(
          label: _resolveNodeText(product, node),
          node: node,
          onTap: onAddToCartTap,
        );
      case 'price':
      case 'final_price':
        return _PillNode(
          label: _resolveNodeText(product, node),
          node: node,
          emphasize: true,
        );
      case 'mrp':
      case 'old_price':
      case 'original_price':
        return _MrpNode(product: product, node: node);
      case 'discount':
      case 'badge':
      case 'promo_badge':
      case 'flash_badge':
      case 'stock':
      case 'delivery':
      case 'unit':
      case 'timer':
      case 'rating':
      case 'brand':
      case 'category':
        return _PillOrTextNode(product: product, node: node);
      case 'progress':
      case 'stock_progress':
        return _ProgressNode(node: node);
      case 'wishlist':
      case 'compare':
      case 'share':
        return _IconCircleNode(node: node);
      case 'dots':
      case 'indicator_dots':
        return _DotsNode(node: node);
      case 'title':
      case 'subtitle':
      case 'description':
      default:
        return _TextNode(
          text: _resolveNodeText(product, node),
          node: node,
        );
    }
  }
}

class _TextNode extends StatelessWidget {
  const _TextNode({
    required this.text,
    required this.node,
  });

  final String text;
  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final fontSize = node.readDouble('fontSize', fallback: 12);
    final lineHeight = (fontSize * 1.15).clamp(8.0, 32.0);
    final maxLines = math.max(1, (node.height / lineHeight).floor());

    return Align(
      alignment: _alignmentFromTextAlign(node.textAlign),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: _textAlignFromString(node.textAlign),
        style: TextStyle(
          color: node.readColor('textColorHex', fallback: Colors.white),
          fontSize: fontSize,
          fontWeight: _fontWeightFromString(node.readString('fontWeight')),
          height: 1.05,
          letterSpacing: node.readDouble('letterSpacing', fallback: 0),
        ),
      ),
    );
  }
}

class _PillOrTextNode extends StatelessWidget {
  const _PillOrTextNode({
    required this.product,
    required this.node,
  });

  final MBProduct product;
  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final text = _resolveNodeText(product, node);
    final isChip = node.variantId.contains('chip') ||
        node.variantId.contains('badge') ||
        node.readString('backgroundHex').isNotEmpty;

    if (!isChip) {
      return _TextNode(text: text, node: node);
    }

    return _PillNode(label: text, node: node);
  }
}

class _PillNode extends StatelessWidget {
  const _PillNode({
    required this.label,
    required this.node,
    this.emphasize = false,
  });

  final String label;
  final _V3DesignNode node;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final background = node.readColor(
      'backgroundHex',
      fallback: emphasize ? Colors.white : Colors.white.withValues(alpha: 0.92),
    );

    final border = node.readColorOrNull('borderHex');
    final radius = node.readDouble('borderRadius', fallback: 999);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: border == null
            ? null
            : Border.all(
                color: border,
                width: node.readDouble('borderWidth', fallback: 1.2),
              ),
        boxShadow: [
          if (emphasize)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: node.readColor(
                'textColorHex',
                fallback: emphasize
                    ? const Color(0xFFFF6500)
                    : const Color(0xFF151922),
              ),
              fontSize: node.readDouble('fontSize', fallback: emphasize ? 13 : 10),
              fontWeight: _fontWeightFromString(
                node.readString('fontWeight', fallback: emphasize ? 'w900' : 'w700'),
              ),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonNode extends StatelessWidget {
  const _ButtonNode({
    required this.label,
    required this.node,
    this.onTap,
  });

  final String label;
  final _V3DesignNode node;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: _PillNode(label: label, node: node, emphasize: false),
    );
  }
}

class _MediaNode extends StatelessWidget {
  const _MediaNode({
    required this.product,
    required this.node,
  });

  final MBProduct product;
  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(product);
    final border = node.readColor('borderHex', fallback: Colors.white);
    final ringWidth = node.readDouble('ringWidth', fallback: 0);
    final radius = node.readDouble('borderRadius', fallback: 24);
    final isCircle = radius >= 500 || node.variantId.contains('circle');

    final image = imageUrl.isEmpty
        ? const ColoredBox(color: Color(0xFFFFEFE3))
        : Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0xFFFFEFE3),
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFFFF6500),
                  size: 18,
                ),
              ),
            ),
          );

    final decoratedImage = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        border: ringWidth > 0
            ? Border.all(
                color: border,
                width: ringWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ringWidth > 0 ? math.max(1, ringWidth * 0.36) : 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isCircle ? 999 : math.max(0, radius - ringWidth)),
          child: image,
        ),
      ),
    );

    if (isCircle) {
      return ClipOval(child: decoratedImage);
    }

    return decoratedImage;
  }
}

class _MrpNode extends StatelessWidget {
  const _MrpNode({
    required this.product,
    required this.node,
  });

  final MBProduct product;
  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final label = _formatCurrency(_readOriginalPrice(product));
    final child = _PillOrTextNode(
      product: product,
      node: node.copyWithLabel(label),
    );

    return CustomPaint(
      foregroundPainter: _MrpStrikePainter(
        color: node.readColor('strikeHex', fallback: const Color(0xFFFF4A4A)),
        width: node.readDouble('strikeWidth', fallback: 1.4),
      ),
      child: child,
    );
  }
}

class _MrpStrikePainter extends CustomPainter {
  const _MrpStrikePainter({
    required this.color,
    required this.width,
  });

  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.55),
      Offset(size.width * 0.84, size.height * 0.45),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MrpStrikePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.width != width;
  }
}

class _ProgressNode extends StatelessWidget {
  const _ProgressNode({required this.node});

  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final background = node.readColor(
      'backgroundHex',
      fallback: Colors.white.withValues(alpha: 0.40),
    );
    final foreground = node.readColor(
      'fillHex',
      fallback: const Color(0xFFFF6500),
    );
    final progress = node.readDouble('progress', fallback: 0.72).clamp(0, 1).toDouble();

    return Align(
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: background)),
            FractionallySizedBox(
              widthFactor: progress,
              child: ColoredBox(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircleNode extends StatelessWidget {
  const _IconCircleNode({required this.node});

  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final icon = switch (node.elementType) {
      'wishlist' => Icons.favorite_border_rounded,
      'compare' => Icons.compare_arrows_rounded,
      'share' => Icons.share_rounded,
      _ => Icons.circle_outlined,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: node.readColor('backgroundHex', fallback: Colors.white),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: math.min(node.width, node.height) * 0.56,
        color: node.readColor('textColorHex', fallback: const Color(0xFFFF6500)),
      ),
    );
  }
}

class _DotsNode extends StatelessWidget {
  const _DotsNode({required this.node});

  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < 3; index++) ...[
          Container(
            width: index == 0 ? 14 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: index == 0
                  ? node.readColor('fillHex', fallback: const Color(0xFFFF6500))
                  : Colors.white.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          if (index != 2) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

class _V3CardDesign {
  const _V3CardDesign({
    required this.cardWidth,
    required this.cardHeight,
    required this.borderRadius,
    required this.palette,
    required this.nodes,
  });

  final double cardWidth;
  final double cardHeight;
  final double borderRadius;
  final Map<String, dynamic> palette;
  final List<_V3DesignNode> nodes;

  static _V3CardDesign? tryParse(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) return null;

      final root = _stringKeyedMap(decoded);
      final layout = _stringKeyedMap(root['layout']);
      final palette = _stringKeyedMap(root['palette']);
      final nodesRaw = root['nodes'];

      if (nodesRaw is! List) return null;

      final cardWidth = _readDouble(layout['cardWidth'], fallback: 185).clamp(80, 900).toDouble();
      final cardHeight = _readDouble(layout['cardHeight'], fallback: 255).clamp(80, 1200).toDouble();
      final radius = _readDouble(layout['borderRadius'], fallback: 0).clamp(0, 120).toDouble();

      final nodes = nodesRaw
          .whereType<Object?>()
          .map(_V3DesignNode.tryParse)
          .whereType<_V3DesignNode>()
          .toList(growable: false);

      if (nodes.isEmpty) return null;

      return _V3CardDesign(
        cardWidth: cardWidth,
        cardHeight: cardHeight,
        borderRadius: radius,
        palette: palette,
        nodes: nodes,
      );
    } catch (_) {
      return null;
    }
  }
}

class _V3DesignNode {
  const _V3DesignNode({
    required this.id,
    required this.elementType,
    required this.variantId,
    required this.binding,
    required this.visible,
    required this.x,
    required this.y,
    required this.z,
    required this.width,
    required this.height,
    required this.style,
  });

  final String id;
  final String elementType;
  final String variantId;
  final String binding;
  final bool visible;
  final double x;
  final double y;
  final int z;
  final double width;
  final double height;
  final Map<String, dynamic> style;

  static _V3DesignNode? tryParse(Object? raw) {
    final map = _stringKeyedMap(raw);
    if (map.isEmpty) return null;

    final position = _stringKeyedMap(map['position']);
    final size = _stringKeyedMap(map['size']);
    final style = _stringKeyedMap(map['style']);

    return _V3DesignNode(
      id: map['id']?.toString() ?? '',
      elementType: (map['elementType']?.toString() ?? '').trim().toLowerCase(),
      variantId: (map['variantId']?.toString() ?? '').trim().toLowerCase(),
      binding: (map['binding']?.toString() ?? '').trim(),
      visible: map['visible'] != false,
      x: _readDouble(position['x'], fallback: 0.5),
      y: _readDouble(position['y'], fallback: 0.5),
      z: _readDouble(position['z'], fallback: 0).round(),
      width: _readDouble(size['width'], fallback: 80),
      height: _readDouble(size['height'], fallback: 28),
      style: style,
    );
  }

  _V3DesignNode copyWithLabel(String label) {
    return _V3DesignNode(
      id: id,
      elementType: elementType,
      variantId: variantId,
      binding: binding,
      visible: visible,
      x: x,
      y: y,
      z: z,
      width: width,
      height: height,
      style: {
        ...style,
        'label': label,
      },
    );
  }

  String readString(String key, {String fallback = ''}) {
    return style[key]?.toString().trim() ?? fallback;
  }

  double readDouble(String key, {required double fallback}) {
    return _readDouble(style[key], fallback: fallback);
  }

  Color readColor(String key, {required Color fallback}) {
    return _parseColor(style[key], fallback: fallback);
  }

  Color? readColorOrNull(String key) {
    final value = style[key];
    if (value == null) return null;
    return _parseColor(value, fallback: Colors.transparent);
  }

  String get textAlign => readString('textAlign', fallback: 'left');
}

String _resolveNodeText(MBProduct product, _V3DesignNode node) {
  final styleLabel = node.readString('label');
  if (styleLabel.isNotEmpty) return styleLabel;

  final binding = node.binding.trim();

  switch (binding) {
    case 'product.titleEn':
      return _tryReadString(() => (product as dynamic).titleEn, fallback: 'Product');
    case 'product.titleBn':
      return _tryReadString(() => (product as dynamic).titleBn, fallback: 'পণ্য');
    case 'product.shortDescriptionEn':
      return _tryReadString(() => (product as dynamic).shortDescriptionEn, fallback: '');
    case 'product.shortDescriptionBn':
      return _tryReadString(() => (product as dynamic).shortDescriptionBn, fallback: '');
    case 'product.brandNameEn':
    case 'product.brand':
      return _tryReadString(() => (product as dynamic).brandNameEn, fallback: 'Brand');
    case 'product.categoryNameEn':
    case 'product.category':
      return _tryReadString(() => (product as dynamic).categoryNameEn, fallback: 'Category');
    case 'product.finalPrice':
    case 'product.salePrice':
    case 'product.price':
      return _formatCurrency(_readFinalPrice(product));
    case 'product.originalPrice':
    case 'product.mrp':
      return _formatCurrency(_readOriginalPrice(product));
    case 'product.unitLabelEn':
      return _tryReadString(() => (product as dynamic).unitLabelEn, fallback: '/pcs');
    case 'product.stockText':
      return 'In stock';
    case 'product.deliveryHint':
      return 'Fast delivery';
    case 'product.rating':
      return '★ ★ ★ ★ ☆(128)';
    case 'static.discount':
      return _discountLabel(product);
    case 'action.buy':
      return 'Buy';
    case 'action.add':
      return 'Add';
    case 'static.flash':
      return 'Flash';
    case 'static.new':
      return 'New';
    case 'static.premium':
      return 'Premium';
    case 'timer.countdown':
      return '02:15:08';
    default:
      if (binding.startsWith('static.')) {
        return binding.substring('static.'.length).replaceAll('_', ' ');
      }
      return node.elementType == 'cta' ? 'Buy' : '';
  }
}

String _resolveImageUrl(MBProduct product) {
  final thumb = _tryReadString(() => (product as dynamic).thumbnailUrl);
  if (thumb.isNotEmpty) return thumb;

  try {
    final dynamic imageUrls = (product as dynamic).imageUrls;
    if (imageUrls is List && imageUrls.isNotEmpty) {
      final first = imageUrls.first?.toString().trim() ?? '';
      if (first.isNotEmpty) return first;
    }
  } catch (_) {
    // Ignore; fall through.
  }

  return '';
}

num _readFinalPrice(MBProduct product) {
  final sale = _tryReadNum(() => (product as dynamic).salePrice);
  if (sale != null && sale > 0) return sale;
  return _tryReadNum(() => (product as dynamic).price) ?? 0;
}

num _readOriginalPrice(MBProduct product) {
  final price = _tryReadNum(() => (product as dynamic).price);
  if (price != null && price > 0) return price;
  return _readFinalPrice(product);
}

String _discountLabel(MBProduct product) {
  final original = _readOriginalPrice(product).toDouble();
  final finalPrice = _readFinalPrice(product).toDouble();

  if (original <= 0 || finalPrice <= 0 || finalPrice >= original) {
    return 'Save';
  }

  final percent = (((original - finalPrice) / original) * 100).round();
  return '$percent% OFF';
}

String _formatCurrency(num value) {
  final number = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
  return '৳$number';
}

Map<String, dynamic> _stringKeyedMap(Object? source) {
  if (source is Map<String, dynamic>) return Map<String, dynamic>.from(source);
  if (source is Map) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

double _readDouble(Object? value, {required double fallback}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

Color _parseColor(Object? value, {required Color fallback}) {
  final source = value?.toString().trim();
  if (source == null || source.isEmpty) return fallback;

  var hex = source.toUpperCase().replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return fallback;

  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return fallback;

  return Color(parsed);
}

String _tryReadString(Object? Function() reader, {String fallback = ''}) {
  try {
    final value = reader();
    return value?.toString().trim() ?? fallback;
  } catch (_) {
    return fallback;
  }
}

num? _tryReadNum(Object? Function() reader) {
  try {
    final value = reader();
    if (value is num) return value;
    return num.tryParse(value?.toString().trim() ?? '');
  } catch (_) {
    return null;
  }
}

FontWeight _fontWeightFromString(String source) {
  switch (source.trim().toLowerCase()) {
    case 'w100':
      return FontWeight.w100;
    case 'w200':
      return FontWeight.w200;
    case 'w300':
      return FontWeight.w300;
    case 'w400':
    case 'normal':
      return FontWeight.w400;
    case 'w500':
      return FontWeight.w500;
    case 'w600':
      return FontWeight.w600;
    case 'w700':
    case 'bold':
      return FontWeight.w700;
    case 'w800':
      return FontWeight.w800;
    case 'w900':
    case 'black':
      return FontWeight.w900;
    default:
      return FontWeight.w700;
  }
}

TextAlign _textAlignFromString(String source) {
  switch (source.trim().toLowerCase()) {
    case 'center':
      return TextAlign.center;
    case 'right':
    case 'end':
      return TextAlign.right;
    case 'justify':
      return TextAlign.justify;
    case 'left':
    case 'start':
    default:
      return TextAlign.left;
  }
}

Alignment _alignmentFromTextAlign(String source) {
  switch (source.trim().toLowerCase()) {
    case 'center':
      return Alignment.center;
    case 'right':
    case 'end':
      return Alignment.centerRight;
    case 'left':
    case 'start':
    default:
      return Alignment.centerLeft;
  }
}
