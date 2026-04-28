// MuthoBazar Advanced Product Card Design Studio
// Patch 2 middle responsive canvas.
//
// Purpose:
// - Renders the selected product in a phone/card preview.
// - Renders the new node-based design document.
// - Allows clicking a node to select it.
// - Allows clicking empty card/background area to select the card itself.
// - Accepts draggable element variants from the left drawer.
// - Allows selected nodes to be moved by mouse drag.
//
// Patch 3 will add keyboard move/resize/delete.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/mb_advanced_card_design_document.dart';
import '../models/mb_advanced_element_variant.dart';

typedef MBAdvancedVariantDropCallback = void Function(
  MBAdvancedElementVariant variant,
  Offset normalizedCanvasPosition,
);

typedef MBAdvancedNodeChangedCallback = void Function(
  MBAdvancedDesignNode node,
);

class MBAdvancedCanvasPanel extends StatelessWidget {
  const MBAdvancedCanvasPanel({
    super.key,
    required this.product,
    required this.document,
    required this.onSelectCard,
    required this.onSelectNode,
    required this.onDropVariant,
    required this.onMoveNode,
  });

  final dynamic product;
  final MBAdvancedCardDesignDocument document;
  final VoidCallback onSelectCard;
  final ValueChanged<String> onSelectNode;
  final MBAdvancedVariantDropCallback onDropVariant;
  final MBAdvancedNodeChangedCallback onMoveNode;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color(0xFFF6F7FB),
        child: Column(
          children: <Widget>[
            const _CanvasHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = math.min(
                    document.cardWidth,
                    math.max(180.0, constraints.maxWidth - 72),
                  );
                  final scale = cardWidth / document.cardWidth;
                  final cardHeight = document.cardHeight * scale;

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _DevicePreviewFrame(
                            child: _CanvasDropTarget(
                              cardWidth: cardWidth,
                              cardHeight: cardHeight,
                              onDropVariant: onDropVariant,
                              child: SizedBox(
                                width: cardWidth,
                                height: cardHeight,
                                child: _EditableCardCanvas(
                                  product: product,
                                  document: document,
                                  scale: scale,
                                  onSelectCard: onSelectCard,
                                  onSelectNode: onSelectNode,
                                  onMoveNode: onMoveNode,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Canvas: ${document.cardWidth.toStringAsFixed(0)} × ${document.cardHeight.toStringAsFixed(0)} px · ${document.nodes.length} node(s)',
                            style: const TextStyle(
                              color: Color(0xFF747B8A),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CanvasHeader extends StatelessWidget {
  const _CanvasHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE6E8EF)),
        ),
      ),
      child: const Row(
        children: <Widget>[
          Icon(
            Icons.phone_android_rounded,
            color: Color(0xFFFF6500),
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Responsive Preview Canvas',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            'Drop from drawer · Mouse drag moves node',
            style: TextStyle(
              color: Color(0xFF747B8A),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DevicePreviewFrame extends StatelessWidget {
  const _DevicePreviewFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: const Color(0xFFE2E6EF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: child,
      ),
    );
  }
}

class _CanvasDropTarget extends StatefulWidget {
  const _CanvasDropTarget({
    required this.cardWidth,
    required this.cardHeight,
    required this.child,
    required this.onDropVariant,
  });

  final double cardWidth;
  final double cardHeight;
  final Widget child;
  final MBAdvancedVariantDropCallback onDropVariant;

  @override
  State<_CanvasDropTarget> createState() => _CanvasDropTargetState();
}

class _CanvasDropTargetState extends State<_CanvasDropTarget> {
  final GlobalKey _targetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DragTarget<MBAdvancedElementVariant>(
      key: _targetKey,
      onWillAcceptWithDetails: (details) => !details.data.isCardVariant,
      onAcceptWithDetails: (details) {
        final renderObject = _targetKey.currentContext?.findRenderObject();
        if (renderObject is! RenderBox) return;

        final local = renderObject.globalToLocal(details.offset);
        final normalized = Offset(
          (local.dx / widget.cardWidth).clamp(0.0, 1.0).toDouble(),
          (local.dy / widget.cardHeight).clamp(0.0, 1.0).toDouble(),
        );

        widget.onDropVariant(details.data, normalized);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return SizedBox(
          width: widget.cardWidth,
          height: widget.cardHeight,
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: widget.child),
              if (isHovering)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0x22FFFFFF),
                        border: Border.all(
                          color: const Color(0xFFFFE0C4),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: _DropHint(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DropHint extends StatelessWidget {
  const _DropHint();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Text(
          'Drop here',
          style: TextStyle(
            color: Color(0xFFFF6500),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _EditableCardCanvas extends StatelessWidget {
  const _EditableCardCanvas({
    required this.product,
    required this.document,
    required this.scale,
    required this.onSelectCard,
    required this.onSelectNode,
    required this.onMoveNode,
  });

  final dynamic product;
  final MBAdvancedCardDesignDocument document;
  final double scale;
  final VoidCallback onSelectCard;
  final ValueChanged<String> onSelectNode;
  final MBAdvancedNodeChangedCallback onMoveNode;

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
    final selectedCard = document.isCardSelected;
    final sortedNodes = <MBAdvancedDesignNode>[...document.nodes]
      ..sort((a, b) => a.position.z.compareTo(b.position.z));
    final scaledCardWidth = document.cardWidth * scale;
    final scaledCardHeight = document.cardHeight * scale;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelectCard,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[background, background2],
          ),
          borderRadius: BorderRadius.circular(document.borderRadius * scale),
          border: Border.all(
            color: selectedCard ? const Color(0xFF172033) : Colors.transparent,
            width: selectedCard ? 2 : 0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(document.borderRadius * scale),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: _SubtleGridPainter(),
                ),
              ),
              for (final node in sortedNodes)
                if (node.visible)
                  _CanvasNodeWidget(
                    product: product,
                    node: node,
                    selected: document.selectedNodeId == node.id,
                    scale: scale,
                    cardWidth: scaledCardWidth,
                    cardHeight: scaledCardHeight,
                    onSelect: () => onSelectNode(node.id),
                    onMoveNode: onMoveNode,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CanvasNodeWidget extends StatelessWidget {
  const _CanvasNodeWidget({
    required this.product,
    required this.node,
    required this.selected,
    required this.scale,
    required this.cardWidth,
    required this.cardHeight,
    required this.onSelect,
    required this.onMoveNode,
  });

  final dynamic product;
  final MBAdvancedDesignNode node;
  final bool selected;
  final double scale;
  final double cardWidth;
  final double cardHeight;
  final VoidCallback onSelect;
  final MBAdvancedNodeChangedCallback onMoveNode;

  @override
  Widget build(BuildContext context) {
    final width = node.size.width * scale;
    final height = node.size.height * scale;
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
      child: MouseRegion(
        cursor: node.locked ? SystemMouseCursors.basic : SystemMouseCursors.move,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onSelect,
          onPanStart: (_) => onSelect(),
          onPanUpdate: node.locked
              ? null
              : (details) {
                  final halfWidth = cardWidth <= 0 ? 0.0 : (width / cardWidth) / 2;
                  final halfHeight = cardHeight <= 0 ? 0.0 : (height / cardHeight) / 2;
                  final nextX = _clampDouble(
                    node.position.x + details.delta.dx / cardWidth,
                    halfWidth,
                    1.0 - halfWidth,
                  );
                  final nextY = _clampDouble(
                    node.position.y + details.delta.dy / cardHeight,
                    halfHeight,
                    1.0 - halfHeight,
                  );

                  onMoveNode(
                    node.copyWith(
                      position: node.position.copyWith(
                        x: nextX,
                        y: nextY,
                      ),
                    ),
                  );
                },
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: selected
                  ? Border.all(color: const Color(0xFF172033), width: 1.6)
                  : Border.all(color: Colors.transparent),
              boxShadow: selected
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: _NodeVisual(
              product: product,
              node: node,
              scale: scale,
            ),
          ),
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
  });

  final dynamic product;
  final MBAdvancedDesignNode node;
  final double scale;

  @override
  Widget build(BuildContext context) {
    switch (node.elementType) {
      case 'title':
        return _TextNode(
          text: _resolveBinding(product, node.binding, 'Product title'),
          node: node,
          scale: scale,
          fallbackColor: Colors.white,
          maxLines: node.variantId.contains('chip') ? 1 : 2,
        );
      case 'subtitle':
        return _TextNode(
          text: _resolveBinding(product, node.binding, 'Fresh product detail'),
          node: node,
          scale: scale,
          fallbackColor: const Color(0xFFFFF4E8),
          maxLines: node.variantId.contains('chip') ? 1 : 3,
        );
      case 'media':
        return _MediaNode(
          imageUrl: _resolveBinding(product, node.binding, ''),
          node: node,
          scale: scale,
        );
      case 'price':
        return _TextNode(
          text: _formatPrice(_resolveBinding(product, node.binding, '৳120')),
          node: node,
          scale: scale,
          fallbackColor: const Color(0xFFFF6500),
          maxLines: 1,
          center: true,
        );
      case 'cta':
        return _TextNode(
          text: node.binding == 'action.details' ? 'View' : 'Buy',
          node: node,
          scale: scale,
          fallbackColor: Colors.white,
          maxLines: 1,
          center: true,
        );
      case 'badge':
        return _TextNode(
          text: node.style['label']?.toString().trim().isNotEmpty == true
              ? node.style['label'].toString().trim()
              : 'HOT',
          node: node,
          scale: scale,
          fallbackColor: const Color(0xFFFF6500),
          maxLines: 1,
          center: true,
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
  });

  final String text;
  final MBAdvancedDesignNode node;
  final double scale;
  final Color fallbackColor;
  final int maxLines;
  final bool center;

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

    return Container(
      alignment: center ? Alignment.center : _textAlignment(style['textAlign']),
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: border == Colors.transparent ? null : Border.all(color: border),
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: center ? TextAlign.center : _textAlign(style['textAlign']),
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: _fontWeight(style['fontWeight']),
          height: 1.05,
        ),
      ),
    );
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
    case 'product.nameEn':
      return _readDynamicString(product, 'nameEn', fallback);
    case 'product.shortDescriptionEn':
      return _readDynamicString(product, 'shortDescriptionEn', fallback);
    case 'product.descriptionEn':
      return _readDynamicString(product, 'descriptionEn', fallback);
    case 'product.thumbnailUrl':
      return _readDynamicString(product, 'thumbnailUrl', fallback);
    case 'product.imageUrl':
      return _readDynamicString(product, 'imageUrl', fallback);
    case 'product.finalPrice':
      return _readPrice(product, fallback);
    case 'product.price':
      return _readDynamicString(product, 'price', fallback);
    default:
      return fallback;
  }
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
      case 'nameEn':
        value = product.nameEn;
        break;
      case 'shortDescriptionEn':
        value = product.shortDescriptionEn;
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
  if (salePrice.isNotEmpty) return salePrice;
  final price = _readDynamicString(product, 'price', '');
  if (price.isNotEmpty) return price;
  return fallback;
}

String _formatPrice(String value) {
  final text = value.trim();
  if (text.isEmpty) return '৳120';
  if (text.startsWith('৳')) return text;
  final number = num.tryParse(text);
  if (number == null) return text;
  final formatted = number == number.roundToDouble()
      ? number.toInt().toString()
      : number.toStringAsFixed(2);
  return '৳$formatted';
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
