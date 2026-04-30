// MuthoBazar Advanced Product Card Renderer
// Patch 11
//
// Purpose:
// - Render product.cardDesignJson directly in customer/home/store/admin previews.
// - Treat cardDesignJson as the visual source of truth for V3 cards.
// - Keep the old preset renderer available as fallback from mb_product_card_renderer.dart.
//
// Design behavior:
// - The JSON card width/height defines the card aspect ratio.
// - Nodes are drawn by their normalized x/y and z layer.
// - Higher z is rendered on top.
// - Supports the common V3 node types used by the Advanced Studio.

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

  static bool canRender(String? designJson) {
    final source = designJson?.trim();
    if (source == null || source.isEmpty) return false;
    return source.contains('muthobazar_card_design_advanced_v2') ||
        source.contains('"nodes"');
  }

  @override
  Widget build(BuildContext context) {
    final document = MBAdvancedCardDesignDocument.fromJson(designJson)
        .lockElementsResponsive()
        .selectCard();
    final width = document.cardWidth <= 0 ? 240.0 : document.cardWidth;
    final height = document.cardHeight <= 0 ? 380.0 : document.cardHeight;
    final aspectRatio = width / height;

    Widget card = AspectRatio(
      aspectRatio: aspectRatio,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: width,
          height: height,
          child: _AdvancedCardSurface(
            product: product,
            document: document,
            onAddToCartTap: onAddToCartTap,
            trailingOverlay: trailingOverlay,
          ),
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

class _AdvancedCardSurface extends StatelessWidget {
  const _AdvancedCardSurface({
    required this.product,
    required this.document,
    required this.onAddToCartTap,
    required this.trailingOverlay,
  });

  final MBProduct product;
  final MBAdvancedCardDesignDocument document;
  final VoidCallback? onAddToCartTap;
  final Widget? trailingOverlay;

  @override
  Widget build(BuildContext context) {
    final nodes = <MBAdvancedDesignNode>[
      for (final node in document.nodes)
        if (node.visible && node.isRenderable) node,
    ]..sort((a, b) {
        final byZ = a.position.z.compareTo(b.position.z);
        if (byZ != 0) return byZ;
        return a.id.compareTo(b.id);
      });

    return ClipRRect(
      borderRadius: BorderRadius.circular(document.borderRadius),
      child: DecoratedBox(
        decoration: _cardDecoration(document),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(child: _CardBackground(document: document)),
            for (final node in nodes)
              _PositionedNode(
                product: product,
                document: document,
                node: node,
                onAddToCartTap: onAddToCartTap,
              ),
            if (trailingOverlay != null) Positioned.fill(child: trailingOverlay!),
          ],
        ),
      ),
    );
  }
}

class _CardBackground extends StatelessWidget {
  const _CardBackground({required this.document});

  final MBAdvancedCardDesignDocument document;

  @override
  Widget build(BuildContext context) {
    final panelStart = _paletteColor(
      document,
      const <String>['panelStartHex', 'backgroundHex'],
      const Color(0xFFFF6500),
    );
    final panelEnd = _paletteColor(
      document,
      const <String>['panelEndHex', 'backgroundHex2'],
      const Color(0xFFFF9A3D),
    );
    final surfaceStart = _paletteColor(
      document,
      const <String>['surfaceStartHex', 'surfaceHex'],
      const Color(0xFFFFF7F0),
    );
    final surfaceEnd = _paletteColor(
      document,
      const <String>['surfaceEndHex', 'surfaceHex'],
      const Color(0xFFFFFFFF),
    );

    return CustomPaint(
      painter: _AdvancedCardBackgroundPainter(
        panelStart: panelStart,
        panelEnd: panelEnd,
        surfaceStart: surfaceStart,
        surfaceEnd: surfaceEnd,
      ),
    );
  }
}

class _AdvancedCardBackgroundPainter extends CustomPainter {
  const _AdvancedCardBackgroundPainter({
    required this.panelStart,
    required this.panelEnd,
    required this.surfaceStart,
    required this.surfaceEnd,
  });

  final Color panelStart;
  final Color panelEnd;
  final Color surfaceStart;
  final Color surfaceEnd;

  @override
  void paint(Canvas canvas, Size size) {
    final surfacePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[surfaceStart, surfaceEnd],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, surfacePaint);

    final panelPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.50)
      ..lineTo(0, size.height * 0.68)
      ..close();
    final panelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[panelStart, panelEnd],
      ).createShader(Offset.zero & size);
    canvas.drawPath(panelPath, panelPaint);
  }

  @override
  bool shouldRepaint(covariant _AdvancedCardBackgroundPainter oldDelegate) {
    return oldDelegate.panelStart != panelStart ||
        oldDelegate.panelEnd != panelEnd ||
        oldDelegate.surfaceStart != surfaceStart ||
        oldDelegate.surfaceEnd != surfaceEnd;
  }
}

class _PositionedNode extends StatelessWidget {
  const _PositionedNode({
    required this.product,
    required this.document,
    required this.node,
    required this.onAddToCartTap,
  });

  final MBProduct product;
  final MBAdvancedCardDesignDocument document;
  final MBAdvancedDesignNode node;
  final VoidCallback? onAddToCartTap;

  @override
  Widget build(BuildContext context) {
    final left = (node.position.x * document.cardWidth) - (node.size.width / 2);
    final top = (node.position.y * document.cardHeight) - (node.size.height / 2);

    return Positioned(
      left: left,
      top: top,
      width: node.size.width,
      height: node.size.height,
      child: _NodeVisual(
        product: product,
        node: node,
        onAddToCartTap: onAddToCartTap,
      ),
    );
  }
}

class _NodeVisual extends StatelessWidget {
  const _NodeVisual({
    required this.product,
    required this.node,
    required this.onAddToCartTap,
  });

  final MBProduct product;
  final MBAdvancedDesignNode node;
  final VoidCallback? onAddToCartTap;

  @override
  Widget build(BuildContext context) {
    switch (node.elementType) {
      case 'media':
        return _MediaNode(product: product, node: node);
      case 'divider':
      case 'shape':
      case 'panel':
      case 'imageOverlay':
      case 'border':
      case 'effect':
      case 'shadow':
      case 'spacing':
      case 'animation':
        return _ShapeNode(node: node);
      case 'progress':
        return _ProgressNode(product: product, node: node);
      case 'dots':
        return _DotsNode(node: node);
      case 'cta':
      case 'secondaryCta':
        return _ClickableTextNode(
          product: product,
          node: node,
          onTap: onAddToCartTap,
          text: _resolveNodeText(product, node),
          centered: true,
        );
      default:
        return _TextNode(
          product: product,
          node: node,
          text: _resolveNodeText(product, node),
          centered: _isChipLike(node),
        );
    }
  }
}

class _ClickableTextNode extends StatelessWidget {
  const _ClickableTextNode({
    required this.product,
    required this.node,
    required this.text,
    required this.centered,
    required this.onTap,
  });

  final MBProduct product;
  final MBAdvancedDesignNode node;
  final String text;
  final bool centered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_styleDouble(node, 'borderRadius', 999)),
        onTap: onTap,
        child: _TextNode(
          product: product,
          node: node,
          text: text,
          centered: centered,
        ),
      ),
    );
  }
}

class _TextNode extends StatelessWidget {
  const _TextNode({
    required this.product,
    required this.node,
    required this.text,
    required this.centered,
  });

  final MBProduct product;
  final MBAdvancedDesignNode node;
  final String text;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final background = _styleColorOrNull(node, 'backgroundHex');
    final border = _styleColorOrNull(node, 'borderHex');
    final textColor = _styleColor(
      node,
      'textColorHex',
      _fallbackTextColor(node.elementType),
    );
    final radius = _styleDouble(node, 'borderRadius', _isChipLike(node) ? 999 : 0);
    final opacity = _styleDouble(node, 'opacity', 1).clamp(0.0, 1.0).toDouble();
    final paddingX = _styleDouble(node, 'paddingX', background == null ? 0 : 8);
    final paddingY = _styleDouble(node, 'paddingY', background == null ? 0 : 4);
    final shouldStrike = node.elementType == 'mrp' && _shouldStrikeOriginalPrice(product, node);

    Widget child = Container(
      alignment: centered ? Alignment.center : _alignmentFromStyle(node),
      padding: EdgeInsets.symmetric(horizontal: paddingX, vertical: paddingY),
      decoration: BoxDecoration(
        color: background?.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Text(
        text,
        maxLines: _maxLinesForNode(node),
        overflow: TextOverflow.ellipsis,
        textAlign: _textAlignFromStyle(node, centered),
        style: TextStyle(
          color: textColor.withValues(alpha: opacity),
          fontSize: _styleDouble(node, 'fontSize', 12),
          fontWeight: _fontWeight(_styleString(node, 'fontWeight', 'w700')),
          height: _styleDoubleOrNull(node, 'lineHeight'),
          decoration: shouldStrike && !_isChipLike(node)
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          decorationColor: _styleColor(node, 'strikeColorHex', const Color(0xFFFF4A4A)),
          decorationThickness: _styleDouble(node, 'strikeThickness', 1.4),
        ),
      ),
    );

    if (shouldStrike && _isChipLike(node)) {
      child = CustomPaint(
        foregroundPainter: _MrpStrikePainter(
          mode: _styleString(node, 'strikeMode', 'cross'),
          color: _styleColor(node, 'strikeColorHex', const Color(0xFFFF4A4A)),
          thickness: _styleDouble(node, 'strikeThickness', 1.8),
          widthFactor: _styleDouble(node, 'strikeWidthFactor', 0.78),
          angleDeg: _styleDouble(node, 'strikeAngleDeg', -45),
        ),
        child: child,
      );
    }

    return child;
  }
}

class _MediaNode extends StatelessWidget {
  const _MediaNode({required this.product, required this.node});

  final MBProduct product;
  final MBAdvancedDesignNode node;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveBinding(product, node.binding, _readImageUrl(product));
    final radius = _styleDouble(node, 'borderRadius', 24);
    final borderColor = _styleColorOrNull(node, 'borderHex') ?? Colors.white;
    final ringWidth = _styleDouble(node, 'ringWidth', 0);

    return Container(
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: <BoxShadow>[
          if (_styleDouble(node, 'shadowBlur', 0) > 0)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: _styleDouble(node, 'shadowBlur', 18),
              offset: Offset(0, _styleDouble(node, 'shadowDy', 5)),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((radius - ringWidth).clamp(0, 999).toDouble()),
        child: imageUrl.trim().isEmpty
            ? const _ImageFallback()
            : Image.network(
                imageUrl,
                fit: _boxFitFromStyle(node),
                errorBuilder: (_, __, ___) => const _ImageFallback(),
              ),
      ),
    );
  }
}

class _ShapeNode extends StatelessWidget {
  const _ShapeNode({required this.node});

  final MBAdvancedDesignNode node;

  @override
  Widget build(BuildContext context) {
    final opacity = _styleDouble(node, 'opacity', 1).clamp(0.0, 1.0).toDouble();
    final color = _styleColor(node, 'backgroundHex', const Color(0xFFFFFFFF));
    final border = _styleColorOrNull(node, 'borderHex');
    final radius = _styleDouble(node, 'borderRadius', 0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border),
      ),
    );
  }
}

class _ProgressNode extends StatelessWidget {
  const _ProgressNode({required this.product, required this.node});

  final MBProduct product;
  final MBAdvancedDesignNode node;

  @override
  Widget build(BuildContext context) {
    final bg = _styleColor(node, 'backgroundHex', const Color(0xFFE8E8E8));
    final valueColor = _styleColor(node, 'valueHex', const Color(0xFFFF6500));
    final radius = _styleDouble(node, 'borderRadius', 999);
    final value = _progressValue(product).clamp(0.0, 1.0).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: <Widget>[
          Positioned.fill(child: ColoredBox(color: bg)),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: ColoredBox(color: valueColor),
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

  final MBAdvancedDesignNode node;

  @override
  Widget build(BuildContext context) {
    final active = _styleColor(node, 'textColorHex', const Color(0xFFFF6500));
    final inactive = _styleColor(node, 'backgroundHex', const Color(0xFFFFD4B8));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (var i = 0; i < 3; i++)
          Container(
            width: i == 0 ? 14 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: i == 0 ? active : inactive,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
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
        size: 30,
      ),
    );
  }
}

class _MrpStrikePainter extends CustomPainter {
  const _MrpStrikePainter({
    required this.mode,
    required this.color,
    required this.thickness,
    required this.widthFactor,
    required this.angleDeg,
  });

  final String mode;
  final Color color;
  final double thickness;
  final double widthFactor;
  final double angleDeg;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final safeWidth = size.width * widthFactor.clamp(0.1, 1.2);
    final left = (size.width - safeWidth) / 2;
    final right = left + safeWidth;
    final centerY = size.height / 2;

    if (mode == 'horizontal') {
      canvas.drawLine(Offset(left, centerY), Offset(right, centerY), paint);
      return;
    }

    final diagonalInset = size.height * 0.24;
    canvas.drawLine(
      Offset(left, size.height - diagonalInset),
      Offset(right, diagonalInset),
      paint,
    );

    if (mode == 'cross') {
      canvas.drawLine(
        Offset(left, diagonalInset),
        Offset(right, size.height - diagonalInset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MrpStrikePainter oldDelegate) {
    return oldDelegate.mode != mode ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.widthFactor != widthFactor ||
        oldDelegate.angleDeg != angleDeg;
  }
}

BoxDecoration _cardDecoration(MBAdvancedCardDesignDocument document) {
  final border = _paletteColor(
    document,
    const <String>['cardBorderHex'],
    Colors.transparent,
  );
  return BoxDecoration(
    borderRadius: BorderRadius.circular(document.borderRadius),
    border: border == Colors.transparent ? null : Border.all(color: border),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

String _resolveNodeText(MBProduct product, MBAdvancedDesignNode node) {
  final label = _styleString(node, 'label', node.label ?? '').trim();
  final prefix = _styleString(node, 'prefixText', '');
  final bindingValue = _resolveBinding(product, node.binding, '').trim();
  final base = label.isNotEmpty ? label : bindingValue;

  switch (node.elementType) {
    case 'price':
    case 'priceBadge':
      return _formatPrice(_readEffectivePrice(product));
    case 'mrp':
      return '$prefix${_formatPrice(product.price)}';
    case 'discount':
    case 'savingText':
      return label.isNotEmpty ? label : '${product.discountPercent}% OFF';
    case 'cta':
      return label.isNotEmpty ? label : 'Buy';
    case 'secondaryCta':
      return label.isNotEmpty ? label : 'View';
    case 'badge':
    case 'promoBadge':
      return label.isNotEmpty ? label : 'HOT';
    case 'flashBadge':
      return label.isNotEmpty ? label : 'FLASH';
    case 'timer':
      return label.isNotEmpty ? label : '02:15:08';
    case 'rating':
      return label.isNotEmpty ? label : '★ 4.8';
    case 'stock':
      return label.isNotEmpty ? label : (product.inStock ? 'In stock' : 'Out of stock');
    case 'delivery':
      return label.isNotEmpty ? label : 'Fast delivery';
    case 'unit':
      return base.isNotEmpty ? base : _unitText(product);
    case 'wishlist':
      return label.isNotEmpty ? label : '♡';
    case 'compare':
      return label.isNotEmpty ? label : '⇄';
    case 'share':
      return label.isNotEmpty ? label : '↗';
    case 'quantity':
      return label.isNotEmpty ? label : 'Qty 1';
    case 'icon':
      return label.isNotEmpty ? label : '✪';
    default:
      return base.isNotEmpty ? base : _fallbackTextForElement(node.elementType);
  }
}

String _resolveBinding(MBProduct product, String binding, String fallback) {
  switch (binding) {
    case 'product.titleEn':
      return product.titleEn;
    case 'product.titleBn':
      return product.titleBn;
    case 'product.shortDescriptionEn':
      return product.shortDescriptionEn;
    case 'product.shortDescriptionBn':
      return product.shortDescriptionBn;
    case 'product.thumbnailUrl':
      return _readImageUrl(product);
    case 'product.finalPrice':
      return _formatPrice(_readEffectivePrice(product));
    case 'product.price':
      return _formatPrice(product.price);
    case 'product.brandName':
    case 'product.brandNameEn':
      return product.brandNameEn ?? fallback;
    case 'product.categoryName':
    case 'product.categoryNameEn':
      return product.categoryNameEn ?? fallback;
    case 'product.unitLabelEn':
      return _unitText(product);
    default:
      return fallback;
  }
}

String _readImageUrl(MBProduct product) {
  final resolved = product.resolvedThumbnailUrl.trim();
  if (resolved.isNotEmpty) return resolved;
  final thumb = product.thumbnailUrl.trim();
  if (thumb.isNotEmpty) return thumb;
  if (product.imageUrls.isNotEmpty) return product.imageUrls.first.toString();
  return '';
}

double _readEffectivePrice(MBProduct product) {
  return product.hasDiscount ? product.salePrice! : product.price;
}

String _formatPrice(Object? value) {
  final amount = value is num ? value.toDouble() : double.tryParse('$value') ?? 0.0;
  final isWhole = amount == amount.roundToDouble();
  final text = isWhole ? amount.round().toString() : amount.toStringAsFixed(2);
  return '\u09F3$text';
}

String _unitText(MBProduct product) {
  final label = product.unitLabelEn?.trim();
  if (label != null && label.isNotEmpty) return label;
  final value = product.quantityValue;
  final type = product.quantityType.trim().isEmpty ? 'pcs' : product.quantityType;
  if (value <= 0) return type;
  final valueText = value == value.roundToDouble() ? value.round().toString() : value.toStringAsFixed(2);
  return '$valueText $type';
}

double _progressValue(MBProduct product) {
  if (product.stockQty <= 0) return 0.0;
  final sold = product.totalSold.clamp(0, product.stockQty);
  return sold / product.stockQty;
}

bool _shouldStrikeOriginalPrice(MBProduct product, MBAdvancedDesignNode node) {
  if (_styleString(node, 'autoStrikeWhenDiscounted', 'true') == 'false') {
    return false;
  }
  return product.hasDiscount;
}

bool _isChipLike(MBAdvancedDesignNode node) {
  if (node.elementType == 'price' || node.elementType == 'mrp') return true;
  if (node.elementType == 'cta' || node.elementType == 'secondaryCta') return true;
  if (node.elementType == 'badge' || node.elementType.endsWith('Badge')) return true;
  return node.variantId.contains('chip') ||
      node.variantId.contains('badge') ||
      node.variantId.contains('pill') ||
      node.variantId.contains('circle');
}

int _maxLinesForNode(MBAdvancedDesignNode node) {
  final raw = node.style['maxLines'];
  if (raw is int) return raw;
  final parsed = int.tryParse(raw?.toString() ?? '');
  if (parsed != null) return parsed.clamp(1, 5);
  switch (node.elementType) {
    case 'title':
      return 2;
    case 'subtitle':
      return 3;
    default:
      return _isChipLike(node) ? 1 : 2;
  }
}

String _fallbackTextForElement(String elementType) {
  switch (elementType) {
    case 'title':
      return 'Product title';
    case 'subtitle':
      return 'Fresh product detail';
    case 'brand':
      return 'Brand';
    case 'category':
      return 'Category';
    default:
      return 'Label';
  }
}

Color _fallbackTextColor(String elementType) {
  switch (elementType) {
    case 'title':
    case 'subtitle':
    case 'delivery':
      return Colors.white;
    case 'cta':
    case 'secondaryCta':
      return Colors.white;
    default:
      return const Color(0xFFFF6500);
  }
}

TextAlign _textAlignFromStyle(MBAdvancedDesignNode node, bool centered) {
  final value = _styleString(node, 'textAlign', centered ? 'center' : 'left').toLowerCase();
  switch (value) {
    case 'right':
    case 'end':
      return TextAlign.right;
    case 'center':
      return TextAlign.center;
    default:
      return TextAlign.left;
  }
}

Alignment _alignmentFromStyle(MBAdvancedDesignNode node) {
  final value = _styleString(node, 'textAlign', 'left').toLowerCase();
  switch (value) {
    case 'right':
    case 'end':
      return Alignment.centerRight;
    case 'center':
      return Alignment.center;
    default:
      return Alignment.centerLeft;
  }
}

FontWeight _fontWeight(String value) {
  switch (value.toLowerCase()) {
    case 'w100':
      return FontWeight.w100;
    case 'w200':
      return FontWeight.w200;
    case 'w300':
      return FontWeight.w300;
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
      return FontWeight.w900;
    default:
      return FontWeight.w700;
  }
}

BoxFit _boxFitFromStyle(MBAdvancedDesignNode node) {
  final value = _styleString(node, 'fit', 'cover').toLowerCase();
  switch (value) {
    case 'contain':
      return BoxFit.contain;
    case 'fill':
      return BoxFit.fill;
    case 'fitwidth':
      return BoxFit.fitWidth;
    case 'fitheight':
      return BoxFit.fitHeight;
    default:
      return BoxFit.cover;
  }
}

Color _paletteColor(
  MBAdvancedCardDesignDocument document,
  List<String> keys,
  Color fallback,
) {
  for (final key in keys) {
    final color = _hexColor(document.palette[key], null);
    if (color != null) return color;
  }
  return fallback;
}

Color _styleColor(
  MBAdvancedDesignNode node,
  String key,
  Color fallback,
) {
  return _styleColorOrNull(node, key) ?? fallback;
}

Color? _styleColorOrNull(MBAdvancedDesignNode node, String key) {
  return _hexColor(node.style[key], null);
}

Color? _hexColor(Object? value, Color? fallback) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return fallback;
  final normalized = raw.replaceAll('#', '');
  if (normalized.length != 6 && normalized.length != 8) return fallback;
  final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return fallback;
  return Color(parsed);
}

double _styleDouble(MBAdvancedDesignNode node, String key, double fallback) {
  final value = node.style[key];
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _styleDoubleOrNull(MBAdvancedDesignNode node, String key) {
  final value = node.style[key];
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String _styleString(MBAdvancedDesignNode node, String key, String fallback) {
  final value = node.style[key]?.toString().trim();
  if (value == null || value.isEmpty) return fallback;
  return value;
}
