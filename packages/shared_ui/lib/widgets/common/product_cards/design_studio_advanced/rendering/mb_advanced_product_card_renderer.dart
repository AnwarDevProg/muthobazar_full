// File: mb_advanced_product_card_renderer.dart
//
// Advanced Product Card Runtime Renderer
// --------------------------------------
// Patch 12.3: Runtime renderer support for new element styles.
//
// Purpose:
// - Render product.cardDesignJson directly in customer/admin runtime cards.
// - Keep Studio V3 and Home runtime visually aligned by rendering the saved
//   design-size stage and scaling it into the parent slot.
// - Support the richer Patch 12.2 inspector style keys for text, media, price,
//   CTA, badge, icon, progress, shape/effect, and MRP strike elements.
// - Render only nodes saved inside cardDesignJson. No old default template
//   elements are injected by this renderer.
//
// Clean JSON rule:
// - The runtime resolves product/brand/category-like bindings at display time.
// - It does not require resolved preview text to be stored in cardDesignJson.
// - Style overrides are read from each node.style map.

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
    if (design == null) return const SizedBox.shrink();

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
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              _parseColor(
                design.palette['backgroundHex'],
                fallback: const Color(0xFFFF6500),
              ),
              _parseColor(
                design.palette['backgroundHex2'],
                fallback: const Color(0xFFFF9A3D),
              ),
            ],
          ),
          borderRadius: radius,
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: _SubtleGridPainter(
                  opacity: _readDouble(
                    design.palette['gridOpacity'],
                    fallback: 0.08,
                  ).clamp(0.0, 0.30).toDouble(),
                  step: _readDouble(
                    design.palette['gridStep'],
                    fallback: 24,
                  ).clamp(8.0, 80.0).toDouble(),
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
            if (trailingOverlay != null) Positioned.fill(child: trailingOverlay!),
          ],
        ),
      ),
    );
  }
}

class _SubtleGridPainter extends CustomPainter {
  const _SubtleGridPainter({
    required this.opacity,
    required this.step,
  });

  final double opacity;
  final double step;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || step <= 0) return;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 1;

    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SubtleGridPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.step != step;
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

    final left = ((node.x * cardWidth) - (width / 2))
        .clamp(-width, cardWidth)
        .toDouble();
    final top = ((node.y * cardHeight) - (height / 2))
        .clamp(-height, cardHeight)
        .toDouble();

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
      case 'secondarycta':
        return _CtaNode(
          label: _resolveNodeText(product, node),
          node: node,
          onTap: onAddToCartTap,
        );

      case 'price':
      case 'final_price':
      case 'pricebadge':
      case 'price_badge':
        return _PriceNode(product: product, node: node);

      case 'mrp':
      case 'old_price':
      case 'original_price':
        return _MrpNode(product: product, node: node);

      case 'discount':
      case 'badge':
      case 'promo_badge':
      case 'promobadge':
      case 'flash_badge':
      case 'flashbadge':
      case 'timer':
      case 'rating':
      case 'stock':
      case 'delivery':
      case 'unit':
      case 'feature':
      case 'savingtext':
      case 'saving_text':
      case 'ribbon':
      case 'quantity':
        return _BadgeOrTextNode(product: product, node: node);

      case 'wishlist':
      case 'compare':
      case 'share':
      case 'icon':
        return _IconNode(node: node);

      case 'progress':
      case 'stock_progress':
        return _ProgressNode(product: product, node: node);

      case 'dots':
      case 'indicator_dots':
        return _DotsNode(node: node);

      case 'panel':
      case 'shape':
      case 'divider':
      case 'imageoverlay':
      case 'image_overlay':
      case 'border':
      case 'effect':
      case 'shadow':
      case 'spacing':
      case 'animation':
        return _ShapeEffectNode(node: node);

      case 'title':
      case 'subtitle':
      case 'description':
      case 'brand':
      case 'category':
      default:
        return _TextNode(
          text: _resolveNodeText(product, node),
          node: node,
          fallbackColor: _fallbackTextColor(node.elementType),
        );
    }
  }
}

class _TextNode extends StatelessWidget {
  const _TextNode({
    required this.text,
    required this.node,
    required this.fallbackColor,
    this.center = false,
    this.forceChip = false,
    this.strikeOriginalPrice = false,
  });

  final String text;
  final _V3DesignNode node;
  final Color fallbackColor;
  final bool center;
  final bool forceChip;
  final bool strikeOriginalPrice;

  @override
  Widget build(BuildContext context) {
    final style = node.style;
    final background = node.readColorOrNull('backgroundHex');
    final backgroundOpacity = node.readDouble(
      'backgroundOpacity',
      fallback: node.readDouble('opacity', fallback: 1.0),
    ).clamp(0.0, 1.0).toDouble();

    final hasBackground = background != null && backgroundOpacity > 0.0;
    final border = node.readColorOrNull('borderHex');
    final borderWidth = node.readDouble('borderWidth', fallback: 1.0);
    final radius = node.readDouble('borderRadius', fallback: 0.0);
    final paddingX = node.readDouble(
      'paddingX',
      fallback: hasBackground || forceChip ? 8.0 : 0.0,
    );
    final paddingY = node.readDouble(
      'paddingY',
      fallback: hasBackground || forceChip ? 4.0 : 0.0,
    );

    final fontSize = node.readDouble('fontSize', fallback: 12.0);
    final lineHeight = node.readDouble('lineHeight', fallback: 1.05);
    final maxLines = node.readInt(
      'maxLines',
      fallback: _defaultMaxLinesForTextNode(node, fontSize, lineHeight),
    ).clamp(1, 8);

    final textColor = node.readColor('textColorHex', fallback: fallbackColor);
    final alignString = center ? 'center' : node.textAlign;
    final alignment = _alignmentFromTextAlign(alignString);
    final strikeMode = node.readString('strikeMode');
    final usePainterStrike = strikeOriginalPrice &&
        (forceChip ||
            hasBackground ||
            strikeMode == 'horizontal' ||
            strikeMode == 'diagonal' ||
            strikeMode == 'cross');
    final useTextStrike = strikeOriginalPrice && !usePainterStrike;

    final textWidget = Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: _textAlignFromString(alignString),
      style: TextStyle(
        color: textColor.withValues(
          alpha: node.readDouble('textOpacity', fallback: 1.0).clamp(0.0, 1.0),
        ),
        fontSize: fontSize,
        fontWeight: _fontWeightFromString(node.readString('fontWeight')),
        height: lineHeight,
        letterSpacing: node.readDouble('letterSpacing', fallback: 0.0),
        decoration: useTextStrike ? TextDecoration.lineThrough : null,
        decorationColor: node.readColor('strikeColorHex', fallback: textColor),
        decorationThickness: useTextStrike
            ? node.readDouble('strikeThickness', fallback: 1.6)
            : null,
      ),
    );

    Widget child = Align(
      alignment: alignment,
      child: textWidget,
    );

    if (usePainterStrike) {
      child = Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(alignment: alignment, child: textWidget),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _MrpStrikePainter(
                  style: style,
                  fallbackColor: node.readColor('strikeColorHex', fallback: textColor),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final decorated = Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(
        horizontal: paddingX.clamp(0.0, 60.0),
        vertical: paddingY.clamp(0.0, 40.0),
      ),
      decoration: BoxDecoration(
        color: hasBackground ? background.withValues(alpha: backgroundOpacity) : null,
        borderRadius: BorderRadius.circular(radius),
        border: border == null || borderWidth <= 0
            ? null
            : Border.all(color: border, width: borderWidth),
        boxShadow: _nodeShadow(node),
      ),
      child: child,
    );

    final opacity = node.readDouble('opacity', fallback: 1.0).clamp(0.0, 1.0);
    if (!hasBackground && opacity < 1.0) {
      return Opacity(opacity: opacity, child: decorated);
    }

    return decorated;
  }
}

class _BadgeOrTextNode extends StatelessWidget {
  const _BadgeOrTextNode({
    required this.product,
    required this.node,
  });

  final MBProduct product;
  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final text = _resolveNodeText(product, node);
    final chipLike = _isChipLike(node);

    return _TextNode(
      text: text,
      node: node,
      fallbackColor: chipLike ? const Color(0xFFFF6500) : _fallbackTextColor(node.elementType),
      center: chipLike,
      forceChip: chipLike,
    );
  }
}

class _PriceNode extends StatelessWidget {
  const _PriceNode({
    required this.product,
    required this.node,
  });

  final MBProduct product;
  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    return _TextNode(
      text: _resolveNodeText(product, node),
      node: node,
      fallbackColor: const Color(0xFFFF6500),
      center: true,
      forceChip: _isChipLike(node, defaultValue: true),
    );
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
    return _TextNode(
      text: _resolveNodeText(product, node),
      node: node,
      fallbackColor: const Color(0xFFFFF4E8),
      center: _isChipLike(node),
      forceChip: _isChipLike(node),
      strikeOriginalPrice: _shouldStrikeOriginalPrice(product, node),
    );
  }
}

class _CtaNode extends StatelessWidget {
  const _CtaNode({
    required this.label,
    required this.node,
    this.onTap,
  });

  final String label;
  final _V3DesignNode node;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconName = node.readString('iconName');
    final iconPosition = node.readString('iconPosition', fallback: 'left');
    final icon = _iconFromName(iconName);

    final text = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: node.readColor('textColorHex', fallback: Colors.white),
          fontSize: node.readDouble('fontSize', fallback: 12.0),
          fontWeight: _fontWeightFromString(
            node.readString('fontWeight', fallback: 'w900'),
          ),
          height: 1,
        ),
      ),
    );

    final iconWidget = icon == null
        ? const SizedBox.shrink()
        : Icon(
            icon,
            color: node.readColor('textColorHex', fallback: Colors.white),
            size: node.readDouble('iconSize', fallback: 14.0),
          );

    final children = <Widget>[
      if (icon != null && iconPosition != 'right') ...[
        iconWidget,
        SizedBox(width: node.readDouble('iconGap', fallback: 5.0)),
      ],
      text,
      if (icon != null && iconPosition == 'right') ...[
        SizedBox(width: node.readDouble('iconGap', fallback: 5.0)),
        iconWidget,
      ],
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: node.readDouble('paddingX', fallback: 8.0),
          vertical: node.readDouble('paddingY', fallback: 4.0),
        ),
        decoration: BoxDecoration(
          color: node.readColor(
            'backgroundHex',
            fallback: const Color(0xFF151922),
          ).withValues(
            alpha: node.readDouble('backgroundOpacity', fallback: 1.0).clamp(0.0, 1.0),
          ),
          borderRadius: BorderRadius.circular(
            node.readDouble('borderRadius', fallback: 999.0),
          ),
          border: _optionalBorder(node),
          boxShadow: _nodeShadow(node),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
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
    final imageUrl = _resolveImageUrl(product, binding: node.binding);
    final radius = node.readDouble('borderRadius', fallback: 24.0);
    final ringWidth = node.readDouble('ringWidth', fallback: 0.0).clamp(0.0, 32.0);
    final background = node.readColor('backgroundHex', fallback: Colors.white);
    final borderColor = node.readColor('borderHex', fallback: Colors.white);
    final imageFit = _imageFitFromString(
      node.readString('imageFit', fallback: 'cover'),
      fallback: BoxFit.cover,
    );
    final alignment = _imageAlignmentFromString(
      node.readString('imageAlignment', fallback: 'center'),
      fallback: Alignment.center,
    );
    final imageScale = node.readDouble('imageScale', fallback: 1.0).clamp(0.5, 3.0);
    final opacity = node.readDouble('opacity', fallback: 1.0).clamp(0.0, 1.0);

    Widget imageChild;
    if (imageUrl.isEmpty) {
      imageChild = const _ImageFallback();
    } else {
      imageChild = Image.network(
        imageUrl,
        fit: imageFit,
        alignment: alignment,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => const _ImageFallback(),
      );

      if ((imageScale - 1.0).abs() > 0.001) {
        imageChild = Transform.scale(
          scale: imageScale,
          alignment: alignment,
          child: imageChild,
        );
      }
    }

    final child = Container(
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.circular(radius),
        border: _optionalBorder(node),
        boxShadow: _nodeShadow(
          node,
          fallback: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(math.max(0, radius - ringWidth)),
        child: ColoredBox(
          color: background,
          child: imageChild,
        ),
      ),
    );

    return Opacity(opacity: opacity, child: child);
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF2E7),
      alignment: Alignment.center,
      child: const Icon(
        Icons.shopping_bag_rounded,
        color: Color(0xFFFF6500),
        size: 34,
      ),
    );
  }
}

class _IconNode extends StatelessWidget {
  const _IconNode({required this.node});

  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final icon = _iconFromName(node.readString('iconName')) ??
        switch (node.elementType) {
          'wishlist' => Icons.favorite_border_rounded,
          'compare' => Icons.compare_arrows_rounded,
          'share' => Icons.share_rounded,
          _ => Icons.star_rounded,
        };

    final hasBackground = node.readString('backgroundHex').isNotEmpty ||
        node.variantId.contains('circle') ||
        node.variantId.contains('chip');

    final iconWidget = Icon(
      icon,
      size: node.readDouble(
        'iconSize',
        fallback: math.min(node.width, node.height) * 0.56,
      ),
      color: node.readColor('textColorHex', fallback: const Color(0xFFFF6500)),
    );

    if (!hasBackground) return Center(child: iconWidget);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: node.readColor('backgroundHex', fallback: Colors.white),
        borderRadius: BorderRadius.circular(
          node.readDouble('borderRadius', fallback: 999.0),
        ),
        border: _optionalBorder(node),
        boxShadow: _nodeShadow(node),
      ),
      child: Center(child: iconWidget),
    );
  }
}

class _ProgressNode extends StatelessWidget {
  const _ProgressNode({
    required this.product,
    required this.node,
  });

  final MBProduct product;
  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final progress = _resolveProgress(product, node).clamp(0.0, 1.0);
    final radius = node.readDouble('borderRadius', fallback: 999.0);
    final background = node.readColor(
      'backgroundHex',
      fallback: Colors.white.withValues(alpha: 0.35),
    );
    final fill = node.readColor('fillHex', fallback: const Color(0xFFFF6500));

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: ColoredBox(color: background)),
          FractionallySizedBox(
            widthFactor: progress,
            child: ColoredBox(color: fill),
          ),
          if (node.readBool('showLabel', fallback: false))
            Center(
              child: Text(
                '${(progress * 100).round()}%',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: node.readColor('textColorHex', fallback: Colors.white),
                  fontSize: node.readDouble('fontSize', fallback: 9.0),
                  fontWeight: _fontWeightFromString(
                    node.readString('fontWeight', fallback: 'w800'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DotsNode extends StatelessWidget {
  const _DotsNode({required this.node});

  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final count = node.readInt('dotCount', fallback: 3).clamp(1, 8);
    final activeIndex = node.readInt('activeIndex', fallback: 0).clamp(0, count - 1);
    final activeWidth = node.readDouble('activeDotWidth', fallback: 14.0);
    final dotSize = node.readDouble('dotSize', fallback: 6.0);
    final gap = node.readDouble('dotGap', fallback: 4.0);
    final activeColor = node.readColor('fillHex', fallback: Colors.white);
    final inactiveColor = node.readColor(
      'backgroundHex',
      fallback: Colors.white.withValues(alpha: 0.55),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (var index = 0; index < count; index++) ...[
          Container(
            width: index == activeIndex ? activeWidth : dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: index == activeIndex ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          if (index != count - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class _ShapeEffectNode extends StatelessWidget {
  const _ShapeEffectNode({required this.node});

  final _V3DesignNode node;

  @override
  Widget build(BuildContext context) {
    final opacity = node.readDouble('opacity', fallback: 1.0).clamp(0.0, 1.0);
    final color = node.readColor('backgroundHex', fallback: Colors.white);
    final radius = node.readDouble('borderRadius', fallback: 0.0);
    final shapeKind = node.readString('shapeKind', fallback: node.variantId);
    final isCircle = shapeKind.contains('circle');
    final isLine = node.elementType == 'divider' || shapeKind.contains('line');
    final border = _optionalBorder(node);

    if (isLine) {
      final thickness = node.readDouble('lineThickness', fallback: node.height);
      return Center(
        child: Container(
          height: thickness.clamp(1.0, node.height),
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        border: border,
        boxShadow: _nodeShadow(node),
      ),
    );
  }
}

class _MrpStrikePainter extends CustomPainter {
  const _MrpStrikePainter({
    required this.style,
    required this.fallbackColor,
  });

  final Map<String, dynamic> style;
  final Color fallbackColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final mode = style['strikeMode']?.toString().trim().toLowerCase();
    final effectiveMode = mode == null || mode.isEmpty ? 'cross' : mode;
    final color = _parseColor(style['strikeColorHex'], fallback: fallbackColor)
        .withValues(
          alpha: _readDouble(style['strikeOpacity'], fallback: 1.0)
              .clamp(0.0, 1.0),
        );
    final thickness = _readDouble(style['strikeThickness'], fallback: 1.6)
        .clamp(0.5, 12.0)
        .toDouble();
    final widthFactor = _readDouble(style['strikeWidthFactor'], fallback: 0.92)
        .clamp(0.1, 1.4)
        .toDouble();
    final inset = _readDouble(style['strikeInset'], fallback: 0.0)
        .clamp(0.0, 40.0)
        .toDouble();

    final rawLength = math.max(0.0, size.width * widthFactor - inset * 2);
    final lineLength = math.min(size.width + size.height, rawLength);
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void drawCenteredLine(double angleDeg) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(angleDeg * math.pi / 180.0);
      canvas.drawLine(
        Offset(-lineLength / 2, 0),
        Offset(lineLength / 2, 0),
        paint,
      );
      canvas.restore();
    }

    switch (effectiveMode) {
      case 'horizontal':
      case 'linethrough':
      case 'line_through':
      case 'lineThrough':
        drawCenteredLine(0);
        break;
      case 'diagonal':
        drawCenteredLine(_readDouble(style['strikeAngleDeg'], fallback: -14));
        break;
      case 'cross':
      default:
        final angle = _readDouble(style['strikeAngleDeg'], fallback: -14).abs();
        drawCenteredLine(angle);
        drawCenteredLine(-angle);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _MrpStrikePainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.fallbackColor != fallbackColor;
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

      final cardWidth = _readDouble(layout['cardWidth'], fallback: 185)
          .clamp(80, 1200)
          .toDouble();
      final cardHeight = _readDouble(layout['cardHeight'], fallback: 255)
          .clamp(80, 1600)
          .toDouble();
      final radius = _readDouble(layout['borderRadius'], fallback: 0)
          .clamp(0, 160)
          .toDouble();

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
    required this.metadata,
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
  final Map<String, dynamic> metadata;

  static _V3DesignNode? tryParse(Object? raw) {
    final map = _stringKeyedMap(raw);
    if (map.isEmpty) return null;

    final position = _stringKeyedMap(map['position']);
    final size = _stringKeyedMap(map['size']);
    final style = _stringKeyedMap(map['style']);
    final metadata = _stringKeyedMap(map['metadata']);

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
      metadata: metadata,
    );
  }

  String readString(String key, {String fallback = ''}) {
    final value = style[key] ?? metadata[key];
    return value?.toString().trim() ?? fallback;
  }

  int readInt(String key, {required int fallback}) {
    final value = style[key] ?? metadata[key];
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString().trim() ?? '') ?? fallback;
  }

  double readDouble(String key, {required double fallback}) {
    final value = style[key] ?? metadata[key];
    return _readDouble(value, fallback: fallback);
  }

  bool readBool(String key, {required bool fallback}) {
    final value = style[key] ?? metadata[key];
    if (value is bool) return value;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    return fallback;
  }

  Color readColor(String key, {required Color fallback}) {
    final value = style[key] ?? metadata[key];
    return _parseColor(value, fallback: fallback);
  }

  Color? readColorOrNull(String key) {
    final value = style[key] ?? metadata[key];
    if (value == null) return null;

    final raw = value.toString().trim();
    if (raw.isEmpty || raw == '#00000000' || raw.toLowerCase() == 'transparent') {
      return null;
    }

    return _parseColor(value, fallback: Colors.transparent);
  }

  String get textAlign => readString('textAlign', fallback: 'left');
}

String _resolveNodeText(MBProduct product, _V3DesignNode node) {
  final styleLabel = node.readString('label');
  if (styleLabel.isNotEmpty) return _applyPrefixSuffix(styleLabel, node);

  final styleText = node.readString('text');
  if (styleText.isNotEmpty) return _applyPrefixSuffix(styleText, node);

  final binding = node.binding.trim();

  String value;
  switch (binding) {
    case 'product.titleEn':
      value = _tryReadString(() => (product as dynamic).titleEn, fallback: 'Product');
      break;
    case 'product.titleBn':
      value = _tryReadString(() => (product as dynamic).titleBn, fallback: 'পণ্য');
      break;
    case 'product.shortDescriptionEn':
      value = _tryReadString(() => (product as dynamic).shortDescriptionEn, fallback: '');
      break;
    case 'product.shortDescriptionBn':
      value = _tryReadString(() => (product as dynamic).shortDescriptionBn, fallback: '');
      break;
    case 'product.descriptionEn':
      value = _tryReadString(() => (product as dynamic).descriptionEn, fallback: '');
      break;
    case 'product.descriptionBn':
      value = _tryReadString(() => (product as dynamic).descriptionBn, fallback: '');
      break;
    case 'product.brandName':
    case 'product.brandNameEn':
    case 'brand.nameEn':
      value = _tryReadString(() => (product as dynamic).brandNameEn, fallback: 'Brand');
      break;
    case 'product.brandNameBn':
    case 'brand.nameBn':
      value = _tryReadString(() => (product as dynamic).brandNameBn, fallback: 'ব্র্যান্ড');
      break;
    case 'product.categoryName':
    case 'product.categoryNameEn':
    case 'category.nameEn':
      value = _tryReadString(() => (product as dynamic).categoryNameEn, fallback: 'Category');
      break;
    case 'product.categoryNameBn':
    case 'category.nameBn':
      value = _tryReadString(() => (product as dynamic).categoryNameBn, fallback: 'ক্যাটাগরি');
      break;
    case 'product.finalPrice':
    case 'product.salePrice':
      value = _formatCurrency(_readFinalPrice(product), node);
      break;
    case 'product.price':
    case 'product.originalPrice':
    case 'product.mrp':
      value = _formatCurrency(_readOriginalPrice(product), node);
      break;
    case 'product.costPrice':
      value = _formatCurrency(_tryReadNum(() => (product as dynamic).costPrice) ?? 0, node);
      break;
    case 'product.quantityType':
      value = _tryReadString(() => (product as dynamic).quantityType, fallback: 'pcs');
      break;
    case 'product.quantityValue':
      value = _tryReadString(() => (product as dynamic).quantityValue, fallback: '');
      break;
    case 'product.unitLabelEn':
      value = _tryReadString(() => (product as dynamic).unitLabelEn, fallback: '');
      break;
    case 'product.unitLabelBn':
      value = _tryReadString(() => (product as dynamic).unitLabelBn, fallback: '');
      break;
    case 'product.stockQty':
      value = _tryReadString(() => (product as dynamic).stockQty, fallback: '0');
      break;
    case 'product.stockText':
      value = _stockLabel(product);
      break;
    case 'product.deliveryHint':
      value = 'Fast delivery';
      break;
    case 'product.rating':
      value = node.readString('fallbackText', fallback: '★ 4.8');
      break;
    case 'static.discount':
      value = _discountLabel(product);
      break;
    case 'action.buy':
      value = node.readString('fallbackText', fallback: 'Buy');
      break;
    case 'action.add':
      value = node.readString('fallbackText', fallback: 'Add');
      break;
    case 'action.details':
      value = node.readString('fallbackText', fallback: 'View');
      break;
    case 'static.flash':
      value = node.readString('fallbackText', fallback: 'Flash');
      break;
    case 'static.new':
      value = node.readString('fallbackText', fallback: 'New');
      break;
    case 'static.premium':
      value = node.readString('fallbackText', fallback: 'Premium');
      break;
    case 'timer.countdown':
    case 'static.timer':
      value = node.readString('fallbackText', fallback: '02:15:08');
      break;
    default:
      if (binding.startsWith('static.')) {
        value = node.readString(
          'fallbackText',
          fallback: binding.substring('static.'.length).replaceAll('_', ' '),
        );
      } else if (node.elementType == 'cta' || node.elementType == 'secondarycta') {
        value = 'Buy';
      } else {
        value = node.readString('fallbackText');
      }
      break;
  }

  return _applyPrefixSuffix(value, node);
}

String _applyPrefixSuffix(String value, _V3DesignNode node) {
  final prefix = node.readString('prefixText');
  final suffix = node.readString('suffixText');
  return '$prefix$value$suffix';
}

String _resolveImageUrl(MBProduct product, {required String binding}) {
  final normalized = binding.trim();

  if (normalized == 'product.imageUrls.first' ||
      normalized == 'product.fullImageUrl' ||
      normalized == 'product.imageUrl') {
    final full = _firstImageUrl(product);
    if (full.isNotEmpty) return full;
  }

  final thumb = _tryReadString(() => (product as dynamic).thumbnailUrl);
  if (thumb.isNotEmpty) return thumb;

  return _firstImageUrl(product);
}

String _firstImageUrl(MBProduct product) {
  try {
    final dynamic imageUrls = (product as dynamic).imageUrls;
    if (imageUrls is List && imageUrls.isNotEmpty) {
      final first = imageUrls.first?.toString().trim() ?? '';
      if (first.isNotEmpty) return first;
    }
  } catch (_) {
    // Ignore; fall through.
  }

  try {
    final dynamic mediaItems = (product as dynamic).mediaItems;
    if (mediaItems is List && mediaItems.isNotEmpty) {
      for (final item in mediaItems) {
        try {
          final dynamic dynamicItem = item;
          final thumb = dynamicItem.thumbUrl?.toString().trim() ?? '';
          if (thumb.isNotEmpty) return thumb;
          final full = dynamicItem.fullUrl?.toString().trim() ?? '';
          if (full.isNotEmpty) return full;
          final url = dynamicItem.url?.toString().trim() ?? '';
          if (url.isNotEmpty) return url;
        } catch (_) {
          if (item is Map) {
            final thumb = item['thumbUrl']?.toString().trim() ?? '';
            if (thumb.isNotEmpty) return thumb;
            final full = item['fullUrl']?.toString().trim() ?? '';
            if (full.isNotEmpty) return full;
            final url = item['url']?.toString().trim() ?? '';
            if (url.isNotEmpty) return url;
          }
        }
      }
    }
  } catch (_) {
    // Ignore.
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

String _stockLabel(MBProduct product) {
  final qty = _tryReadNum(() => (product as dynamic).stockQty) ?? 0;
  if (qty <= 0) return 'Stock';
  return 'Stock $qty';
}

bool _shouldStrikeOriginalPrice(MBProduct product, _V3DesignNode node) {
  final manual = node.readString('strikeVisible');
  if (manual == 'true') return true;
  if (manual == 'false') return false;

  final auto = node.readBool('autoStrikeWhenDiscounted', fallback: true);
  if (!auto) return false;

  final original = _readOriginalPrice(product).toDouble();
  final finalPrice = _readFinalPrice(product).toDouble();

  return original > 0 && finalPrice > 0 && finalPrice < original;
}

double _resolveProgress(MBProduct product, _V3DesignNode node) {
  final explicit = node.readDouble('progress', fallback: -1);
  if (explicit >= 0) return explicit;

  final stock = _tryReadNum(() => (product as dynamic).stockQty)?.toDouble() ?? 0;
  final cap = node.readDouble('stockCap', fallback: 100.0);
  if (cap <= 0) return 0.0;

  return stock / cap;
}

String _formatCurrency(num value, _V3DesignNode node) {
  final showCurrency = node.readBool('showCurrency', fallback: true);
  final currency = node.readString('currencySymbol', fallback: '৳');
  final decimals = node.readInt('decimalPlaces', fallback: value % 1 == 0 ? 0 : 1)
      .clamp(0, 3);

  final number = decimals == 0 ? value.toInt().toString() : value.toStringAsFixed(decimals);
  return showCurrency ? '$currency$number' : number;
}

bool _isChipLike(_V3DesignNode node, {bool defaultValue = false}) {
  final variant = node.variantId.toLowerCase();
  final rawBg = node.readString('backgroundHex');
  return variant.contains('chip') ||
      variant.contains('pill') ||
      variant.contains('badge') ||
      rawBg.isNotEmpty ||
      defaultValue;
}

int _defaultMaxLinesForTextNode(
  _V3DesignNode node,
  double fontSize,
  double lineHeight,
) {
  final effectiveLineHeight = (fontSize * lineHeight).clamp(6.0, 80.0);
  final computed = (node.height / effectiveLineHeight).floor();
  if (node.elementType == 'title') return math.max(1, computed).clamp(1, 3);
  if (node.elementType == 'subtitle' || node.elementType == 'description') {
    return math.max(1, computed).clamp(1, 5);
  }
  return math.max(1, computed).clamp(1, 2);
}

Color _fallbackTextColor(String elementType) {
  switch (elementType) {
    case 'title':
    case 'category':
    case 'delivery':
    case 'unit':
    case 'feature':
      return Colors.white;
    case 'subtitle':
    case 'mrp':
    case 'description':
      return const Color(0xFFFFF4E8);
    case 'cta':
    case 'flashbadge':
    case 'flash_badge':
      return Colors.white;
    default:
      return const Color(0xFFFF6500);
  }
}

Border? _optionalBorder(_V3DesignNode node) {
  final border = node.readColorOrNull('borderHex');
  final borderWidth = node.readDouble('borderWidth', fallback: 1.0);
  if (border == null || borderWidth <= 0) return null;
  return Border.all(color: border, width: borderWidth);
}

List<BoxShadow> _nodeShadow(
  _V3DesignNode node, {
  List<BoxShadow> fallback = const <BoxShadow>[],
}) {
  final enabled = node.readBool(
    'shadowEnabled',
    fallback: node.readDouble('shadowOpacity', fallback: -1) >= 0,
  );

  if (!enabled) return fallback;

  final opacity = node.readDouble('shadowOpacity', fallback: 0.12).clamp(0.0, 1.0);
  if (opacity <= 0) return const <BoxShadow>[];

  return <BoxShadow>[
    BoxShadow(
      color: node.readColor('shadowColorHex', fallback: Colors.black)
          .withValues(alpha: opacity),
      blurRadius: node.readDouble('shadowBlur', fallback: 12.0),
      spreadRadius: node.readDouble('shadowSpread', fallback: 0.0),
      offset: Offset(
        node.readDouble('shadowOffsetX', fallback: 0.0),
        node.readDouble('shadowOffsetY', fallback: 6.0),
      ),
    ),
  ];
}

BoxFit _imageFitFromString(String source, {required BoxFit fallback}) {
  switch (source.trim().toLowerCase()) {
    case 'contain':
      return BoxFit.contain;
    case 'fill':
      return BoxFit.fill;
    case 'fitwidth':
    case 'fit_width':
      return BoxFit.fitWidth;
    case 'fitheight':
    case 'fit_height':
      return BoxFit.fitHeight;
    case 'none':
      return BoxFit.none;
    case 'scaledown':
    case 'scale_down':
      return BoxFit.scaleDown;
    case 'cover':
      return BoxFit.cover;
    default:
      return fallback;
  }
}

Alignment _imageAlignmentFromString(
  String source, {
  required Alignment fallback,
}) {
  switch (source.trim().toLowerCase()) {
    case 'top':
    case 'topcenter':
    case 'top_center':
      return Alignment.topCenter;
    case 'bottom':
    case 'bottomcenter':
    case 'bottom_center':
      return Alignment.bottomCenter;
    case 'left':
    case 'centerleft':
    case 'center_left':
      return Alignment.centerLeft;
    case 'right':
    case 'centerright':
    case 'center_right':
      return Alignment.centerRight;
    case 'topleft':
    case 'top_left':
      return Alignment.topLeft;
    case 'topright':
    case 'top_right':
      return Alignment.topRight;
    case 'bottomleft':
    case 'bottom_left':
      return Alignment.bottomLeft;
    case 'bottomright':
    case 'bottom_right':
      return Alignment.bottomRight;
    case 'center':
    case '':
      return Alignment.center;
    default:
      return fallback;
  }
}

IconData? _iconFromName(String source) {
  switch (source.trim().toLowerCase()) {
    case 'cart':
    case 'shopping_cart':
    case 'add_cart':
      return Icons.shopping_cart_rounded;
    case 'bag':
    case 'shopping_bag':
      return Icons.shopping_bag_rounded;
    case 'bolt':
    case 'flash':
      return Icons.bolt_rounded;
    case 'favorite':
    case 'heart':
    case 'wishlist':
      return Icons.favorite_border_rounded;
    case 'share':
      return Icons.share_rounded;
    case 'compare':
      return Icons.compare_arrows_rounded;
    case 'star':
    case 'rating':
      return Icons.star_rounded;
    case 'delivery':
    case 'truck':
      return Icons.local_shipping_rounded;
    case 'timer':
    case 'clock':
      return Icons.timer_rounded;
    case 'tag':
    case 'offer':
      return Icons.local_offer_rounded;
    case 'info':
      return Icons.info_outline_rounded;
    case 'view':
    case 'details':
      return Icons.visibility_rounded;
    case '':
      return null;
    default:
      return null;
  }
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
  if (source.toLowerCase() == 'transparent') return Colors.transparent;

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

FontWeight _fontWeightFromString(String source, {String fallback = 'w700'}) {
  final value = source.trim().isEmpty ? fallback : source.trim().toLowerCase();

  switch (value) {
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
