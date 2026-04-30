// File: mb_advanced_product_card_renderer.dart
//
// Advanced Product Card Runtime Renderer
// --------------------------------------
// Patch 11.5: Shared Studio V3 render core for Home/runtime cards.
//
// Purpose:
// - Render product.cardDesignJson directly in customer Home/product cards.
// - Align runtime rendering with Studio V3 canvas rendering.
// - Use MBAdvancedCardDesignDocument and MBAdvancedDesignNode instead of a
//   separate runtime-only parser/model.
// - Remove the runtime-only poster/wave painter that made Home look different
//   from Studio V3.
// - Render only saved V3 nodes; no legacy/default badges are injected.
//
// Notes:
// - Higher z is rendered on top.
// - Card width/height/radius are read from the same document model as Studio V3.
// - Node positioning, clamping, media rendering, text rendering, strike behavior,
//   and subtle grid are intentionally matched to mb_advanced_canvas_panel.dart.

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

import '../models/mb_advanced_card_design_document.dart';

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
    final document = MBAdvancedCardDesignDocument.fromJson(designJson);
    if (document.nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: SizedBox(
                width: document.cardWidth,
                height: document.cardHeight,
                child: _RuntimeCardCanvas(
                  product: product,
                  document: document,
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

class _RuntimeCardCanvas extends StatelessWidget {
  const _RuntimeCardCanvas({
    required this.product,
    required this.document,
    this.onAddToCartTap,
    this.trailingOverlay,
  });

  final dynamic product;
  final MBAdvancedCardDesignDocument document;
  final VoidCallback? onAddToCartTap;
  final Widget? trailingOverlay;

  @override
  Widget build(BuildContext context) {
    final background = _hexColor(
      document.palette['backgroundHex'],
      const Color(0xFFFF6500),
    );
    final background2 = _hexColor(
      document.palette['backgroundHex2'],
      const Color(0xFFFF9A3D),
    );
    final sortedNodes = <MBAdvancedDesignNode>[...document.nodes]
      ..sort((a, b) => a.position.z.compareTo(b.position.z));
    final cardRadius = document.borderRadius;

    return ClipRRect(
      key: ValueKey<String>('runtime_card_radius_${document.borderRadius.toStringAsFixed(2)}'),
      borderRadius: BorderRadius.circular(cardRadius),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[background, background2],
          ),
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: _SubtleGridPainter(),
              ),
            ),
            for (final node in sortedNodes)
              if (node.visible)
                _RuntimeNodeWidget(
                  product: product,
                  node: node,
                  cardWidth: document.cardWidth,
                  cardHeight: document.cardHeight,
                  onAddToCartTap: onAddToCartTap,
                ),
            if (trailingOverlay != null) Positioned.fill(child: trailingOverlay!),
          ],
        ),
      ),
    );
  }
}

class _RuntimeNodeWidget extends StatelessWidget {
  const _RuntimeNodeWidget({
    required this.product,
    required this.node,
    required this.cardWidth,
    required this.cardHeight,
    this.onAddToCartTap,
  });

  final dynamic product;
  final MBAdvancedDesignNode node;
  final double cardWidth;
  final double cardHeight;
  final VoidCallback? onAddToCartTap;

  @override
  Widget build(BuildContext context) {
    final width = node.size.width;
    final height = node.size.height;
    final left = _clampDouble(
      node.position.x * cardWidth - width / 2,
      0,
      math.max(0, cardWidth - width),
    );
    final top = _clampDouble(
      node.position.y * cardHeight - height / 2,
      0,
      math.max(0, cardHeight - height),
    );

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: ClipRect(
        child: _NodeVisual(
          product: product,
          node: node,
          scale: 1,
          onAddToCartTap: onAddToCartTap,
        ),
      ),
    );
  }
}

class _NodeVisual extends StatelessWidget {
  const _NodeVisual({
    required this.product,
    required this.node,
    required this.scale,
    this.onAddToCartTap,
  });

  final dynamic product;
  final MBAdvancedDesignNode node;
  final double scale;
  final VoidCallback? onAddToCartTap;

  @override
  Widget build(BuildContext context) {
    switch (node.elementType) {
      case 'title':
      case 'subtitle':
      case 'brand':
      case 'category':
      case 'delivery':
      case 'unit':
      case 'feature':
      case 'savingText':
      case 'ribbon':
        return _TextNode(
          text: _resolveNodeText(product, node),
          node: node,
          scale: scale,
          fallbackColor: _fallbackTextColor(node.elementType),
          maxLines: node.variantId.contains('chip') ? 1 : 3,
          strikeOriginalPrice: _shouldStrikeOriginalPrice(product, node),
        );
      case 'media':
        return _MediaNode(
          imageUrl: _resolveBinding(product, node.binding, ''),
          node: node,
          scale: scale,
        );
      case 'price':
      case 'mrp':
      case 'discount':
      case 'badge':
      case 'timer':
      case 'rating':
      case 'stock':
      case 'quantity':
      case 'wishlist':
      case 'compare':
      case 'share':
      case 'icon':
      case 'priceBadge':
      case 'promoBadge':
      case 'flashBadge':
      case 'secondaryCta':
      case 'animation':
      case 'cta':
        return GestureDetector(
          behavior: node.elementType == 'cta' ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
          onTap: node.elementType == 'cta' ? onAddToCartTap : null,
          child: _TextNode(
            text: _resolveNodeText(product, node),
            node: node,
            scale: scale,
            fallbackColor: _fallbackTextColor(node.elementType),
            maxLines: 1,
            center: true,
            strikeOriginalPrice: _shouldStrikeOriginalPrice(product, node),
          ),
        );
      case 'divider':
      case 'shape':
      case 'panel':
      case 'imageOverlay':
      case 'progress':
      case 'dots':
      case 'border':
      case 'effect':
      case 'shadow':
      case 'spacing':
        return _ShapeNode(
          node: node,
          scale: scale,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TextNode extends StatelessWidget {
  const _TextNode({
    required this.text,
    required this.node,
    required this.scale,
    required this.fallbackColor,
    required this.maxLines,
    this.center = false,
    this.strikeOriginalPrice = false,
  });

  final String text;
  final MBAdvancedDesignNode node;
  final double scale;
  final Color fallbackColor;
  final int maxLines;
  final bool center;
  final bool strikeOriginalPrice;

  @override
  Widget build(BuildContext context) {
    final style = node.style;
    final background = _hexColor(style['backgroundHex'], Colors.transparent);
    final border = _hexColor(style['borderHex'], Colors.transparent);
    final textColor = _hexColor(style['textColorHex'], fallbackColor);
    final radius = _asDouble(style['borderRadius'], 0) * scale;
    final fontSize = _asDouble(style['fontSize'], 13) * scale;
    final padding = background == Colors.transparent
        ? EdgeInsets.zero
        : EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale);
    final alignment = center ? Alignment.center : _textAlignment(style['textAlign']);
    final strikeMode = style['strikeMode']?.toString().trim().toLowerCase();
    final isChipLike = _isChipLikeMrpNode(node, background);
    final usePainterStrike = strikeOriginalPrice &&
        (isChipLike ||
            strikeMode == 'horizontal' ||
            strikeMode == 'diagonal' ||
            strikeMode == 'cross');
    final useTextStrike = strikeOriginalPrice && !usePainterStrike;
    final textWidget = Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: center ? TextAlign.center : _textAlign(style['textAlign']),
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: _fontWeight(style['fontWeight']),
        height: 1.05,
        decoration: useTextStrike ? TextDecoration.lineThrough : null,
        decorationColor: _hexColor(style['strikeColorHex'], textColor),
        decorationThickness: useTextStrike
            ? _asDouble(style['strikeThickness'], 1.6)
                .clamp(0.5, 12.0)
                .toDouble()
            : null,
      ),
    );

    return Container(
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: border == Colors.transparent
            ? null
            : Border.all(
                color: border,
                width: _asDouble(node.style['borderWidth'], 1.0),
              ),
      ),
      child: usePainterStrike
          ? Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Align(alignment: alignment, child: textWidget),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _MrpStrikePainter(
                        style: style,
                        fallbackColor: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : textWidget,
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
    final color = _hexColor(style['strikeColorHex'], fallbackColor).withValues(
      alpha: _asDouble(style['strikeOpacity'], 1.0).clamp(0.0, 1.0),
    );
    final thickness = _asDouble(style['strikeThickness'], 1.6)
        .clamp(0.5, 12.0)
        .toDouble();
    final widthFactor = _asDouble(style['strikeWidthFactor'], 0.92)
        .clamp(0.1, 1.4)
        .toDouble();
    final inset = _asDouble(style['strikeInset'], 0.0).clamp(0.0, 40.0).toDouble();
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
      case 'lineThrough':
        drawCenteredLine(0);
        break;
      case 'diagonal':
        drawCenteredLine(_asDouble(style['strikeAngleDeg'], -14));
        break;
      case 'cross':
      default:
        final angle = _asDouble(style['strikeAngleDeg'], -14).abs();
        drawCenteredLine(angle);
        drawCenteredLine(-angle);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _MrpStrikePainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.fallbackColor != fallbackColor;
  }
}

class _MediaNode extends StatelessWidget {
  const _MediaNode({
    required this.imageUrl,
    required this.node,
    required this.scale,
  });

  final String imageUrl;
  final MBAdvancedDesignNode node;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final radius = _asDouble(node.style['borderRadius'], 24) * scale;
    final ringWidth = _asDouble(node.style['ringWidth'], 0) * scale;
    final borderColor = _hexColor(node.style['borderHex'], Colors.white);
    final hasImage = imageUrl.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(math.max(0, radius - ringWidth)),
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImageFallback(),
              )
            : const _ImageFallback(),
      ),
    );
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

class _ShapeNode extends StatelessWidget {
  const _ShapeNode({
    required this.node,
    required this.scale,
  });

  final MBAdvancedDesignNode node;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final color = _hexColor(node.style['backgroundHex'], Colors.white)
        .withValues(alpha: _asDouble(node.style['opacity'], 1.0).clamp(0.0, 1.0));
    final radius = _asDouble(node.style['borderRadius'], 0) * scale;
    final border = _hexColor(node.style['borderHex'], Colors.transparent);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border == Colors.transparent
            ? null
            : Border.all(
                color: border,
                width: _asDouble(node.style['borderWidth'], 1.0),
              ),
      ),
    );
  }
}

class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..strokeWidth = 1;

    const step = 24.0;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String _resolveBinding(dynamic product, String binding, String fallback) {
  switch (binding) {
    case 'product.titleEn':
      return _readDynamicString(product, 'titleEn', fallback);
    case 'product.titleBn':
      return _readDynamicString(product, 'titleBn', fallback);
    case 'product.nameEn':
      return _readDynamicString(product, 'nameEn', fallback);
    case 'product.shortDescriptionEn':
      return _readDynamicString(product, 'shortDescriptionEn', fallback);
    case 'product.shortDescriptionBn':
      return _readDynamicString(product, 'shortDescriptionBn', fallback);
    case 'product.descriptionEn':
      return _readDynamicString(product, 'descriptionEn', fallback);
    case 'product.thumbnailUrl':
      return _readDynamicString(product, 'thumbnailUrl', fallback);
    case 'product.imageUrl':
      return _readDynamicString(product, 'imageUrl', fallback);
    case 'product.finalPrice':
    case 'product.salePrice':
      return _readPrice(product, fallback);
    case 'product.price':
      return _readDynamicString(product, 'price', fallback);
    case 'product.brandName':
    case 'product.brandNameEn':
    case 'product.brand':
      return _readDynamicString(product, 'brandNameEn', fallback);
    case 'product.categoryName':
    case 'product.categoryNameEn':
    case 'product.category':
      return _readDynamicString(product, 'categoryNameEn', fallback);
    case 'static.discount':
      return _discountLabel(product);
    case 'action.buy':
      return 'Buy';
    case 'action.add':
      return 'Add';
    default:
      if (binding.startsWith('static.')) {
        return binding.substring('static.'.length).replaceAll('_', ' ');
      }
      return fallback;
  }
}

String _resolveNodeText(dynamic product, MBAdvancedDesignNode node) {
  final styleLabel = node.style['label']?.toString().trim();
  final styleText = node.style['text']?.toString().trim();
  final prefix = node.style['prefixText']?.toString() ?? '';

  String fallback;
  switch (node.elementType) {
    case 'title':
      fallback = 'Product title';
      break;
    case 'subtitle':
      fallback = 'Fresh product detail';
      break;
    case 'brand':
      fallback = 'Fresh Farms';
      break;
    case 'category':
      fallback = 'Vegetables';
      break;
    case 'price':
      fallback = '\u09F3120';
      break;
    case 'mrp':
      fallback = '\u09F3150';
      break;
    case 'discount':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : _discountLabel(product);
      break;
    case 'cta':
      fallback = styleLabel?.isNotEmpty == true
          ? styleLabel!
          : (node.binding == 'action.details' ? 'View' : 'Buy');
      break;
    case 'badge':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'HOT';
      break;
    case 'timer':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : '02:15:08';
      break;
    case 'rating':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : '★ 4.8';
      break;
    case 'stock':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'In stock';
      break;
    case 'delivery':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'Fast delivery';
      break;
    case 'unit':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : '500 g';
      break;
    case 'feature':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'Farm fresh';
      break;
    case 'savingText':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'Save 25%';
      break;
    case 'ribbon':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'NEW';
      break;
    case 'wishlist':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : '♡';
      break;
    case 'compare':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : '⇄';
      break;
    case 'share':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : '↗';
      break;
    case 'icon':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : '✪';
      break;
    case 'quantity':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'Qty 1';
      break;
    case 'priceBadge':
      fallback = '\u09F3120';
      break;
    case 'promoBadge':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'Promo';
      break;
    case 'flashBadge':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'Flash';
      break;
    case 'secondaryCta':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'Details';
      break;
    case 'animation':
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : '●';
      break;
    default:
      fallback = styleLabel?.isNotEmpty == true ? styleLabel! : 'Label';
      break;
  }

  final bindingText = _resolveBinding(product, node.binding, fallback).trim();
  final baseText = styleText?.isNotEmpty == true
      ? styleText!
      : (bindingText.isNotEmpty ? bindingText : fallback);
  final text = prefix.isEmpty ? baseText : '$prefix$baseText';
  if (node.elementType == 'price' ||
      node.elementType == 'mrp' ||
      node.elementType == 'priceBadge') {
    return _formatPrice(text);
  }
  return text;
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
      return const Color(0xFFFFF4E8);
    case 'cta':
    case 'flashBadge':
      return Colors.white;
    default:
      return const Color(0xFFFF6500);
  }
}

bool _shouldStrikeOriginalPrice(dynamic product, MBAdvancedDesignNode node) {
  if (node.elementType != 'mrp') return false;

  final manualVisible = node.style['strikeVisible'];
  if (manualVisible is bool) return manualVisible;

  final auto = _asBool(node.style['autoStrikeWhenDiscounted'], true);
  if (!auto) return false;

  final originalPrice = _readDynamicNumber(product, 'price');
  final salePrice = _readDynamicNumber(product, 'salePrice');
  if (originalPrice == null || salePrice == null) return false;
  if (originalPrice <= 0 || salePrice <= 0) return false;
  return salePrice < originalPrice;
}

bool _isChipLikeMrpNode(MBAdvancedDesignNode node, Color background) {
  if (node.elementType != 'mrp') return false;
  final variant = node.variantId.toLowerCase();
  if (variant.contains('chip') ||
      variant.contains('pill') ||
      variant.contains('badge')) {
    return true;
  }
  final rawBg = node.style['backgroundHex']?.toString().trim();
  return rawBg != null &&
      rawBg.isNotEmpty &&
      rawBg != '#00000000' &&
      background != Colors.transparent;
}

double? _readDynamicNumber(dynamic product, String fieldName) {
  final text = _readDynamicString(product, fieldName, '').trim();
  if (text.isEmpty) return null;
  final normalized = text
      .replaceAll('\u09F3', '')
      .replaceAll(',', '')
      .replaceAll(RegExp(r'[^0-9\.-]'), '')
      .trim();
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

bool _asBool(Object? value, bool fallback) {
  if (value is bool) return value;
  final text = value?.toString().trim().toLowerCase();
  if (text == 'true') return true;
  if (text == 'false') return false;
  return fallback;
}

String _readDynamicString(dynamic product, String fieldName, String fallback) {
  try {
    final map = product is Map ? product : null;
    if (map != null && map.containsKey(fieldName)) {
      final value = map[fieldName];
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
  } catch (_) {}

  try {
    late final Object? value;
    switch (fieldName) {
      case 'titleEn':
        value = product.titleEn;
        break;
      case 'titleBn':
        value = product.titleBn;
        break;
      case 'nameEn':
        value = product.nameEn;
        break;
      case 'shortDescriptionEn':
        value = product.shortDescriptionEn;
        break;
      case 'shortDescriptionBn':
        value = product.shortDescriptionBn;
        break;
      case 'descriptionEn':
        value = product.descriptionEn;
        break;
      case 'thumbnailUrl':
        value = product.thumbnailUrl;
        break;
      case 'imageUrl':
        value = product.imageUrl;
        break;
      case 'price':
        value = product.price;
        break;
      case 'salePrice':
        value = product.salePrice;
        break;
      case 'brandNameEn':
        value = product.brandNameEn;
        break;
      case 'categoryNameEn':
        value = product.categoryNameEn;
        break;
      default:
        value = null;
    }
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  } catch (_) {}

  return fallback;
}

String _readPrice(dynamic product, String fallback) {
  final salePrice = _readDynamicString(product, 'salePrice', '');
  if (salePrice.isNotEmpty && salePrice != '0') return salePrice;
  final price = _readDynamicString(product, 'price', '');
  if (price.isNotEmpty) return price;
  return fallback;
}

String _discountLabel(dynamic product) {
  final originalPrice = _readDynamicNumber(product, 'price');
  final salePrice = _readDynamicNumber(product, 'salePrice');
  if (originalPrice == null || salePrice == null) return '25% OFF';
  if (originalPrice <= 0 || salePrice <= 0 || salePrice >= originalPrice) {
    return 'Save';
  }
  final percent = (((originalPrice - salePrice) / originalPrice) * 100).round();
  return '$percent% OFF';
}

String _formatPrice(String value) {
  final text = value.trim();
  if (text.isEmpty) return '\u09F3120';
  if (text.startsWith('\u09F3')) return text;
  final number = num.tryParse(text);
  if (number == null) return text;
  final formatted = number == number.roundToDouble()
      ? number.toInt().toString()
      : number.toStringAsFixed(2);
  return '\u09F3$formatted';
}

Alignment _textAlignment(Object? value) {
  switch (value?.toString()) {
    case 'center':
      return Alignment.center;
    case 'right':
      return Alignment.centerRight;
    case 'left':
    default:
      return Alignment.centerLeft;
  }
}

TextAlign _textAlign(Object? value) {
  switch (value?.toString()) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    case 'left':
    default:
      return TextAlign.left;
  }
}

FontWeight _fontWeight(Object? value) {
  switch (value?.toString()) {
    case 'w400':
      return FontWeight.w400;
    case 'w500':
      return FontWeight.w500;
    case 'w600':
      return FontWeight.w600;
    case 'w700':
      return FontWeight.w700;
    case 'w800':
      return FontWeight.w800;
    case 'w900':
    default:
      return FontWeight.w900;
  }
}

Color _hexColor(Object? value, Color fallback) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return fallback;
  var hex = raw.replaceAll('#', '').toUpperCase();
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return fallback;
  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return fallback;
  return Color(parsed);
}

double _asDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

double _clampDouble(double value, double min, double max) {
  if (max < min) return min;
  return math.min(math.max(value, min), max);
}
