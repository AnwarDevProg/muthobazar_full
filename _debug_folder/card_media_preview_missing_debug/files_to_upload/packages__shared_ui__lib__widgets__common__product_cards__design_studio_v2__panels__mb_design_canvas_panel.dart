import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/shared_models.dart';

import '../models/mb_design_node.dart';
import '../models/mb_design_node_variant.dart';

// MuthoBazar Design Studio V2 Canvas Panel
// ---------------------------------------
// Select + Move Fix Patch
//
// Fixes:
// - Click node selects node.
// - Parent card tap no longer immediately overrides node selection.
// - Mouse drag moves selected/pressed node.
// - Node is now a direct Positioned child of Stack.
// - Arrow keys move selected node.
// - Ctrl + Arrow keys resize selected node.

class MBDesignCanvasPanel extends StatefulWidget {
  const MBDesignCanvasPanel({
    super.key,
    required this.product,
    required this.document,
    required this.onSelectCard,
    required this.onSelectNode,
    required this.onAddVariantAt,
    required this.onUpdateNode,
  });

  final MBProduct product;
  final MBDesignDocument document;
  final VoidCallback onSelectCard;
  final ValueChanged<String> onSelectNode;
  final void Function(MBDesignNodeVariant variant, Offset normalizedPosition)
      onAddVariantAt;
  final ValueChanged<MBDesignNode> onUpdateNode;

  @override
  State<MBDesignCanvasPanel> createState() => _MBDesignCanvasPanelState();
}

class _MBDesignCanvasPanelState extends State<MBDesignCanvasPanel> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'MBDesignCanvasPanel');
  bool _canvasActive = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = [
      for (final node in widget.document.nodes)
        if (node.visible && _isRenderable(node.elementType)) node,
    ];

    return Expanded(
      child: ColoredBox(
        color: const Color(0xFFF6F7FB),
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          canRequestFocus: true,
          onKeyEvent: _handleFocusKeyEvent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final safeWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;

              final previewWidth = safeWidth.clamp(360.0, 560.0).toDouble();
              final cardWidth =
                  widget.document.cardWidth.clamp(170.0, 330.0).toDouble();
              final cardHeight = (cardWidth / widget.document.aspectRatio)
                  .clamp(widget.document.minHeight, widget.document.maxHeight)
                  .toDouble();

              return Center(
                child: SizedBox(
                  width: previewWidth,
                  child: _MobileFrame(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          const _PhoneTopBar(),
                          const SizedBox(height: 10),
                          Text(
                            'Design Studio V2 · Select/Move Fixed Canvas',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.document.selectedNodeId == null
                                ? 'Card selected · ${nodes.length} editable nodes'
                                : 'Selected: ${widget.document.selectedNodeId}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF7A7F8D),
                                    ),
                          ),
                          const SizedBox(height: 8),
                          const _KeyboardHint(),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: _CardCanvas(
                              product: widget.product,
                              document: widget.document.copyWith(nodes: nodes),
                              onSelectCard: () {
                                _requestFocus();
                                widget.onSelectCard();
                              },
                              onSelectNode: (nodeId) {
                                _requestFocus();
                                widget.onSelectNode(nodeId);
                              },
                              onMoveNode: _moveNode,
                              onAddVariantAt: (variant, position) {
                                _requestFocus();
                                widget.onAddVariantAt(variant, position);
                              },
                              onCanvasActiveChanged: (value) {
                                _canvasActive = value;
                                if (value) {
                                  _requestFocus();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _requestFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  KeyEventResult _handleFocusKeyEvent(FocusNode node, KeyEvent event) {
    return _handleKeyboardEvent(event)
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (!_focusNode.hasFocus && !_canvasActive) {
      return false;
    }

    return _handleKeyboardEvent(event);
  }

  bool _handleKeyboardEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return false;
    }

    final selected = widget.document.selectedNode;
    if (selected == null ||
        selected.locked ||
        !_isRenderable(selected.elementType)) {
      return false;
    }

    final key = event.logicalKey;
    final isArrow = key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown;

    if (!isArrow) {
      return false;
    }

    final keyboard = HardwareKeyboard.instance;
    final isCtrl = keyboard.isControlPressed || keyboard.isMetaPressed;
    final isShift = keyboard.isShiftPressed;

    if (isCtrl) {
      _resizeSelected(
        selected,
        key: key,
        step: isShift ? 14 : 5,
      );
    } else {
      _moveNode(
        selected,
        _keyboardDelta(
          key: key,
          step: isShift ? 0.040 : 0.012,
        ),
      );
    }

    return true;
  }

  Offset _keyboardDelta({
    required LogicalKeyboardKey key,
    required double step,
  }) {
    if (key == LogicalKeyboardKey.arrowLeft) {
      return Offset(-step, 0);
    }

    if (key == LogicalKeyboardKey.arrowRight) {
      return Offset(step, 0);
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      return Offset(0, -step);
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      return Offset(0, step);
    }

    return Offset.zero;
  }

  void _resizeSelected(
    MBDesignNode node, {
    required LogicalKeyboardKey key,
    required double step,
  }) {
    final limits = _sizeLimits(node.elementType);
    final currentWidth = node.size.width ?? limits.defaultWidth;
    final currentHeight = node.size.height ?? limits.defaultHeight;

    var nextWidth = currentWidth;
    var nextHeight = currentHeight;

    if (key == LogicalKeyboardKey.arrowLeft) {
      nextWidth -= step;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      nextWidth += step;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      nextHeight -= step;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      nextHeight += step;
    }

    widget.onUpdateNode(
      node.copyWith(
        size: node.size.copyWith(
          width: nextWidth.clamp(limits.minWidth, limits.maxWidth).toDouble(),
          height:
              nextHeight.clamp(limits.minHeight, limits.maxHeight).toDouble(),
        ),
      ),
    );
  }

  void _moveNode(MBDesignNode node, Offset normalizedDelta) {
    if (node.locked || !_isRenderable(node.elementType)) {
      return;
    }

    widget.onUpdateNode(
      node.copyWith(
        position: node.position.copyWith(
          x: (node.position.x + normalizedDelta.dx).clamp(0.02, 0.98).toDouble(),
          y: (node.position.y + normalizedDelta.dy).clamp(0.02, 0.98).toDouble(),
        ),
      ),
    );
  }
}

class _CardCanvas extends StatelessWidget {
  const _CardCanvas({
    required this.product,
    required this.document,
    required this.onSelectCard,
    required this.onSelectNode,
    required this.onMoveNode,
    required this.onAddVariantAt,
    required this.onCanvasActiveChanged,
  });

  final MBProduct product;
  final MBDesignDocument document;
  final VoidCallback onSelectCard;
  final ValueChanged<String> onSelectNode;
  final void Function(MBDesignNode node, Offset normalizedDelta) onMoveNode;
  final void Function(MBDesignNodeVariant variant, Offset normalizedPosition)
      onAddVariantAt;
  final ValueChanged<bool> onCanvasActiveChanged;

  @override
  Widget build(BuildContext context) {
    final palette = _Palette(document.palette);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return DragTarget<MBDesignNodeVariant>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) {
            final renderObject = context.findRenderObject();

            if (renderObject is! RenderBox) {
              onAddVariantAt(details.data, const Offset(0.5, 0.5));
              return;
            }

            final local = renderObject.globalToLocal(details.offset);

            onAddVariantAt(
              details.data,
              Offset(
                (local.dx / cardSize.width).clamp(0.02, 0.98).toDouble(),
                (local.dy / cardSize.height).clamp(0.02, 0.98).toDouble(),
              ),
            );
          },
          builder: (context, candidateData, rejectedData) {
            final isDropHover = candidateData.isNotEmpty;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => onCanvasActiveChanged(true),
              onTap: onSelectCard,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.surfaceStart,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDropHover
                        ? const Color(0xFF22C55E)
                        : document.selectedNodeId == null
                            ? const Color(0xFFFF6500)
                            : palette.border,
                    width:
                        isDropHover || document.selectedNodeId == null ? 2 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CardBasePainter(palette: palette),
                        ),
                      ),
                      if (isDropHover)
                        Positioned.fill(
                          child: ColoredBox(
                            color: const Color(0xFF22C55E)
                                .withValues(alpha: 0.10),
                            child: const Center(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(999)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    'Drop element here',
                                    style: TextStyle(
                                      color: Color(0xFF15803D),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      for (final node in [...document.nodes]..sort(
                          (a, b) => a.position.z.compareTo(b.position.z),
                        ))
                        if (node.visible && _isRenderable(node.elementType))
                          _PositionedNode(
                            cardSize: cardSize,
                            product: product,
                            node: node,
                            selected: document.selectedNodeId == node.id,
                            onSelect: () => onSelectNode(node.id),
                            onMoveNode: onMoveNode,
                            onCanvasActiveChanged: onCanvasActiveChanged,
                            palette: palette,
                          ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CardBasePainter extends CustomPainter {
  const _CardBasePainter({required this.palette});

  final _Palette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [palette.surfaceStart, palette.surfaceEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
    );

    final panel = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.42)
      ..lineTo(0, size.height * 0.56)
      ..close();

    canvas.drawPath(
      panel,
      Paint()
        ..shader = LinearGradient(
          colors: [palette.panelStart, palette.panelEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.width * 0.80, size.height * 0.12),
      size.width * 0.23,
      Paint()..color = Colors.white.withValues(alpha: 0.11),
    );

    canvas.drawCircle(
      Offset(size.width * 0.10, size.height * 0.50),
      size.width * 0.18,
      Paint()..color = palette.panelEnd.withValues(alpha: 0.10),
    );
  }

  @override
  bool shouldRepaint(_CardBasePainter oldDelegate) {
    return oldDelegate.palette != palette;
  }
}

class _PositionedNode extends StatelessWidget {
  const _PositionedNode({
    required this.cardSize,
    required this.product,
    required this.node,
    required this.selected,
    required this.onSelect,
    required this.onMoveNode,
    required this.onCanvasActiveChanged,
    required this.palette,
  });

  final Size cardSize;
  final MBProduct product;
  final MBDesignNode node;
  final bool selected;
  final VoidCallback onSelect;
  final void Function(MBDesignNode node, Offset normalizedDelta) onMoveNode;
  final ValueChanged<bool> onCanvasActiveChanged;
  final _Palette palette;

  @override
  Widget build(BuildContext context) {
    final limits = _sizeLimits(node.elementType);
    final nodeWidth = (node.size.width ?? limits.defaultWidth)
        .clamp(limits.minWidth, limits.maxWidth)
        .clamp(20.0, cardSize.width)
        .toDouble();
    final nodeHeight = (node.size.height ?? limits.defaultHeight)
        .clamp(limits.minHeight, limits.maxHeight)
        .clamp(18.0, cardSize.height)
        .toDouble();

    final left = (node.position.x * cardSize.width) - nodeWidth / 2;
    final top = (node.position.y * cardSize.height) - nodeHeight / 2;

    return Positioned(
      left: left,
      top: top,
      width: nodeWidth,
      height: nodeHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          onCanvasActiveChanged(true);
          onSelect();
        },
        onTap: () {
          onCanvasActiveChanged(true);
          onSelect();
        },
        onPanStart: (_) {
          onCanvasActiveChanged(true);
          onSelect();
        },
        onPanUpdate: (details) {
          onMoveNode(
            node,
            Offset(
              details.delta.dx / cardSize.width,
              details.delta.dy / cardSize.height,
            ),
          );
        },
        onPanEnd: (_) => onCanvasActiveChanged(false),
        onPanCancel: () => onCanvasActiveChanged(false),
        child: MouseRegion(
          cursor:
              node.locked ? SystemMouseCursors.forbidden : SystemMouseCursors.move,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: selected
                  ? Border.all(color: const Color(0xFFFF6500), width: 2)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: _NodeView(
                    product: product,
                    node: node,
                    palette: palette,
                  ),
                ),
                if (selected)
                  const Positioned(
                    right: -8,
                    top: -8,
                    child: _SelectionHandle(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NodeView extends StatelessWidget {
  const _NodeView({
    required this.product,
    required this.node,
    required this.palette,
  });

  final MBProduct product;
  final MBDesignNode node;
  final _Palette palette;

  @override
  Widget build(BuildContext context) {
    switch (node.elementType) {
      case 'media':
        return _MediaNode(product: product, node: node);
      case 'priceBadge':
      case 'finalPrice':
        return _BadgeNode(
          text: _priceText(product),
          node: node,
          palette: palette,
          circular: node.variantId.contains('circle'),
        );
      case 'secondaryCta':
      case 'primaryCta':
        return _BadgeNode(text: 'Buy', node: node, palette: palette);
      case 'deliveryHint':
        return _BadgeNode(text: 'Fast delivery', node: node, palette: palette);
      case 'timer':
        return _BadgeNode(text: '02:15:08', node: node, palette: palette);
      case 'stockHint':
        return _BadgeNode(text: 'In stock', node: node, palette: palette);
      case 'promoBadge':
      case 'savingBadge':
        return _BadgeNode(text: 'Save 20%', node: node, palette: palette);
      case 'brand':
        return _TextNode(
          text: product.brandNameEn ?? '',
          node: node,
          palette: palette,
          fallbackSize: 10,
        );
      case 'categoryChip':
        return _BadgeNode(
          text: product.categoryNameEn ?? 'Category',
          node: node,
          palette: palette,
        );
      case 'unitLabel':
        return _TextNode(
          text: product.unitLabelEn ?? '',
          node: node,
          palette: palette,
          fallbackSize: 10,
        );
      case 'subtitle':
        return _TextNode(
          text: product.shortDescriptionEn,
          node: node,
          palette: palette,
          fallbackSize: 11,
        );
      case 'title':
      default:
        return node.variantId == 'chip_title'
            ? _BadgeNode(text: product.titleEn, node: node, palette: palette)
            : _TextNode(
                text: product.titleEn,
                node: node,
                palette: palette,
                fallbackSize: 17,
              );
    }
  }

  String _priceText(MBProduct product) {
    final price = product.salePrice ?? product.price;
    return '৳${price.toStringAsFixed(0)}';
  }
}

class _TextNode extends StatelessWidget {
  const _TextNode({
    required this.text,
    required this.node,
    required this.palette,
    required this.fallbackSize,
  });

  final String text;
  final MBDesignNode node;
  final _Palette palette;
  final double fallbackSize;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: node.elementType == 'title' ? 2 : 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _colorFromStyle(node.style, 'textColorHex', palette.titleText),
          fontSize: _doubleFromStyle(node.style, 'fontSize', fallbackSize),
          fontWeight: _fontWeight(node.style['fontWeight']),
          fontStyle: node.style['fontStyle'] == 'italic'
              ? FontStyle.italic
              : FontStyle.normal,
          height: 1.02,
        ),
      ),
    );
  }
}

class _BadgeNode extends StatelessWidget {
  const _BadgeNode({
    required this.text,
    required this.node,
    required this.palette,
    this.circular = false,
  });

  final String text;
  final MBDesignNode node;
  final _Palette palette;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final isButton =
        node.elementType == 'secondaryCta' || node.elementType == 'primaryCta';

    final background = _colorFromStyle(
      node.style,
      'backgroundHex',
      isButton ? palette.buttonEnd : Colors.white,
    );

    final foreground = _colorFromStyle(
      node.style,
      'textColorHex',
      isButton ? palette.buttonText : palette.priceText,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(999),
        border: Border.all(
          color: _colorFromStyle(
            node.style,
            'borderHex',
            circular ? Colors.white : Colors.transparent,
          ),
          width: circular ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foreground,
            fontSize: _doubleFromStyle(node.style, 'fontSize', 12),
            fontWeight: FontWeight.w900,
          ),
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
  final MBDesignNode node;

  @override
  Widget build(BuildContext context) {
    final ringWidth = _doubleFromStyle(node.style, 'ringWidth', 6);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _colorFromStyle(node.style, 'borderHex', Colors.white),
        shape: node.variantId == 'circle_ring'
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius:
            node.variantId == 'circle_ring' ? null : BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(ringWidth),
        child: ClipRRect(
          borderRadius: node.variantId == 'circle_ring'
              ? BorderRadius.circular(999)
              : BorderRadius.circular(18),
          child: ColoredBox(
            color: Colors.white,
            child: product.thumbnailUrl.trim().isEmpty
                ? const Icon(Icons.image_outlined)
                : Image.network(
                    product.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SelectionHandle extends StatelessWidget {
  const _SelectionHandle();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFF6500),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const SizedBox(
        width: 18,
        height: 18,
        child: Icon(Icons.open_with_rounded, size: 12, color: Colors.white),
      ),
    );
  }
}

class _MobileFrame extends StatelessWidget {
  const _MobileFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: ColoredBox(color: const Color(0xFFF7F8FC), child: child),
        ),
      ),
    );
  }
}

class _PhoneTopBar extends StatelessWidget {
  const _PhoneTopBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            '9:41',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
          Spacer(),
          SizedBox(
            width: 72,
            height: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF111827),
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
            ),
          ),
          Spacer(),
          Icon(Icons.battery_full_rounded, size: 15),
        ],
      ),
    );
  }
}

class _KeyboardHint extends StatelessWidget {
  const _KeyboardHint();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Click node first · drag node · Arrow move · Ctrl+Arrow resize',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF7A7F8D),
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Palette {
  const _Palette._({
    required this.panelStart,
    required this.panelEnd,
    required this.surfaceStart,
    required this.surfaceEnd,
    required this.border,
    required this.titleText,
    required this.priceText,
    required this.buttonEnd,
    required this.buttonText,
  });

  factory _Palette(Map<String, Object?> raw) {
    return _Palette._(
      panelStart: _colorFromHex(raw['panelStartHex'], const Color(0xFFFFA53A)),
      panelEnd: _colorFromHex(raw['panelEndHex'], const Color(0xFFFF7400)),
      surfaceStart:
          _colorFromHex(raw['surfaceStartHex'], const Color(0xFFFFFBF6)),
      surfaceEnd:
          _colorFromHex(raw['surfaceEndHex'], const Color(0xFFFFF4E8)),
      border: _colorFromHex(raw['cardBorderHex'], const Color(0xFFFF8E24)),
      titleText: _colorFromHex(raw['titleTextHex'], Colors.white),
      priceText: _colorFromHex(raw['priceTextHex'], const Color(0xFF0D4C7A)),
      buttonEnd: _colorFromHex(raw['buttonEndHex'], const Color(0xFFFF6500)),
      buttonText: _colorFromHex(raw['buttonTextHex'], Colors.white),
    );
  }

  final Color panelStart;
  final Color panelEnd;
  final Color surfaceStart;
  final Color surfaceEnd;
  final Color border;
  final Color titleText;
  final Color priceText;
  final Color buttonEnd;
  final Color buttonText;
}

class _SizeLimits {
  const _SizeLimits({
    required this.defaultWidth,
    required this.defaultHeight,
    required this.minWidth,
    required this.maxWidth,
    required this.minHeight,
    required this.maxHeight,
  });

  final double defaultWidth;
  final double defaultHeight;
  final double minWidth;
  final double maxWidth;
  final double minHeight;
  final double maxHeight;
}

_SizeLimits _sizeLimits(String elementType) {
  return switch (elementType) {
    'media' => const _SizeLimits(
        defaultWidth: 150,
        defaultHeight: 150,
        minWidth: 48,
        maxWidth: 190,
        minHeight: 48,
        maxHeight: 190,
      ),
    'priceBadge' || 'finalPrice' => const _SizeLimits(
        defaultWidth: 58,
        defaultHeight: 58,
        minWidth: 34,
        maxWidth: 96,
        minHeight: 34,
        maxHeight: 96,
      ),
    'secondaryCta' || 'primaryCta' => const _SizeLimits(
        defaultWidth: 68,
        defaultHeight: 32,
        minWidth: 44,
        maxWidth: 128,
        minHeight: 22,
        maxHeight: 52,
      ),
    'deliveryHint' || 'timer' || 'stockHint' || 'promoBadge' || 'savingBadge' =>
      const _SizeLimits(
        defaultWidth: 108,
        defaultHeight: 28,
        minWidth: 54,
        maxWidth: 150,
        minHeight: 20,
        maxHeight: 44,
      ),
    'subtitle' => const _SizeLimits(
        defaultWidth: 170,
        defaultHeight: 44,
        minWidth: 70,
        maxWidth: 220,
        minHeight: 22,
        maxHeight: 78,
      ),
    _ => const _SizeLimits(
        defaultWidth: 150,
        defaultHeight: 34,
        minWidth: 50,
        maxWidth: 220,
        minHeight: 22,
        maxHeight: 80,
      ),
  };
}

bool _isRenderable(String elementType) {
  const allowed = <String>{
    'title',
    'subtitle',
    'media',
    'priceBadge',
    'finalPrice',
    'secondaryCta',
    'primaryCta',
    'deliveryHint',
    'timer',
    'promoBadge',
    'savingBadge',
    'stockHint',
    'brand',
    'categoryChip',
    'unitLabel',
  };

  return allowed.contains(elementType);
}

Color _colorFromStyle(Map<String, Object?> style, String key, Color fallback) {
  return _colorFromHex(style[key], fallback);
}

Color _colorFromHex(Object? value, Color fallback) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty) return fallback;

  final hex = raw.startsWith('#') ? raw.substring(1) : raw;
  if (hex.length != 6 && hex.length != 8) return fallback;

  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return fallback;

  return hex.length == 6 ? Color(0xFF000000 | parsed) : Color(parsed);
}

double _doubleFromStyle(Map<String, Object?> style, String key, double fallback) {
  final value = style[key];
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}

FontWeight _fontWeight(Object? value) {
  return switch (value?.toString()) {
    'w400' => FontWeight.w400,
    'w500' => FontWeight.w500,
    'w600' => FontWeight.w600,
    'w700' => FontWeight.w700,
    'w800' => FontWeight.w800,
    'w900' => FontWeight.w900,
    _ => FontWeight.w900,
  };
}
