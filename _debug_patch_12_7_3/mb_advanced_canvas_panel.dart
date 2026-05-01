// MuthoBazar Advanced Product Card Design Studio
// Patch 8 middle responsive canvas.
//
// Purpose:
// - Renders the selected product in a phone/card preview.
// - Renders the new node-based design document.
// - Allows clicking a node to select it.
// - Allows clicking empty card/background area to select the card itself.
// - Accepts draggable element variants from the left drawer.
// - Allows selected nodes to be moved by mouse drag.
//
// Patch 8 adds card/root anchored preview sizing and real card radius clipping.
// Patch 10.3 hides the visible preview-slot shell and shows the true card-only preview.
// Patch 12.7 uses the shared advanced preview context for canvas rendering.
// Patch 12.7.1 renders new model-bound element aliases and prevents invisible drops.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/mb_advanced_binding_resolver.dart';
import '../models/mb_advanced_card_design_document.dart';
import '../models/mb_advanced_element_variant.dart';

typedef MBAdvancedVariantDropCallback = void Function(
  MBAdvancedElementVariant variant,
  Offset normalizedCanvasPosition,
);

typedef MBAdvancedNodeChangedCallback = void Function(
  MBAdvancedDesignNode node,
);

class MBAdvancedCanvasPanel extends StatefulWidget {
  const MBAdvancedCanvasPanel({
    super.key,
    required this.product,
    this.previewBrand,
    this.previewCategory,
    this.previewVariation,
    this.previewPurchaseOption,
    this.previewProductAttribute,
    this.previewAttributeValue,
    this.previewAttributePreset,
    required this.document,
    required this.onSelectCard,
    required this.onSelectNode,
    required this.onDropVariant,
    required this.onMoveNode,
    required this.onDeleteNode,
    required this.onCardLayoutTypeChanged,
  });

  final dynamic product;
  final dynamic previewBrand;
  final dynamic previewCategory;
  final dynamic previewVariation;
  final dynamic previewPurchaseOption;
  final dynamic previewProductAttribute;
  final dynamic previewAttributeValue;
  final dynamic previewAttributePreset;
  final MBAdvancedCardDesignDocument document;
  final VoidCallback onSelectCard;
  final ValueChanged<String> onSelectNode;
  final MBAdvancedVariantDropCallback onDropVariant;
  final MBAdvancedNodeChangedCallback onMoveNode;
  final ValueChanged<String> onDeleteNode;
  final ValueChanged<String> onCardLayoutTypeChanged;

  @override
  State<MBAdvancedCanvasPanel> createState() => _MBAdvancedCanvasPanelState();
}

class _MBAdvancedCanvasPanelState extends State<MBAdvancedCanvasPanel> {
  late final FocusNode _focusNode;
  Timer? _keyboardRepeatTimer;
  LogicalKeyboardKey? _heldKey;

  MBAdvancedPreviewContext get _previewContext {
    return MBAdvancedPreviewContext.fromProduct(
      product: widget.product,
      brand: widget.previewBrand,
      category: widget.previewCategory,
      selectedVariation: widget.previewVariation,
      selectedPurchaseOption: widget.previewPurchaseOption,
      selectedProductAttribute: widget.previewProductAttribute,
      selectedAttributeValue: widget.previewAttributeValue,
      selectedAttributePreset: widget.previewAttributePreset,
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'MBAdvancedCardStudioCanvas');
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _stopKeyboardRepeat();
    });
  }

  @override
  void dispose() {
    _stopKeyboardRepeat();
    _focusNode.dispose();
    super.dispose();
  }

  void _requestCanvasFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;

    if (event is KeyUpEvent) {
      if (_heldKey == key) {
        _stopKeyboardRepeat();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final selectedNode = widget.document.selectedNode;
    if (selectedNode == null || selectedNode.locked) {
      return KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      if (event is KeyDownEvent) {
        widget.onDeleteNode(selectedNode.id);
      }
      return KeyEventResult.handled;
    }

    final isArrow = key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown;

    if (!isArrow) {
      return KeyEventResult.ignored;
    }

    final keyboard = HardwareKeyboard.instance;
    final isResize = keyboard.isControlPressed || keyboard.isMetaPressed;
    final isFast = keyboard.isShiftPressed;

    if (event is KeyDownEvent) {
      _applyKeyboardEdit(key, resize: isResize, fast: isFast);
      _startKeyboardRepeat(key, resize: isResize, fast: isFast);
    }

    return KeyEventResult.handled;
  }

  void _startKeyboardRepeat(
    LogicalKeyboardKey key, {
    required bool resize,
    required bool fast,
  }) {
    if (_heldKey == key && _keyboardRepeatTimer?.isActive == true) {
      return;
    }

    _stopKeyboardRepeat();
    _heldKey = key;
    _keyboardRepeatTimer = Timer.periodic(
      const Duration(milliseconds: 55),
      (_) => _applyKeyboardEdit(key, resize: resize, fast: fast),
    );
  }

  void _stopKeyboardRepeat() {
    _keyboardRepeatTimer?.cancel();
    _keyboardRepeatTimer = null;
    _heldKey = null;
  }

  void _applyKeyboardEdit(
    LogicalKeyboardKey key, {
    required bool resize,
    required bool fast,
  }) {
    final selectedNode = widget.document.selectedNode;
    if (selectedNode == null || selectedNode.locked) return;

    final stepPx = fast ? 10.0 : 1.0;

    if (resize) {
      final widthDelta = key == LogicalKeyboardKey.arrowRight
          ? stepPx
          : key == LogicalKeyboardKey.arrowLeft
              ? -stepPx
              : 0.0;
      final heightDelta = key == LogicalKeyboardKey.arrowDown
          ? stepPx
          : key == LogicalKeyboardKey.arrowUp
              ? -stepPx
              : 0.0;

      final nextWidth = (selectedNode.size.width + widthDelta)
          .clamp(selectedNode.size.minWidth, selectedNode.size.maxWidth)
          .toDouble();
      final nextHeight = (selectedNode.size.height + heightDelta)
          .clamp(selectedNode.size.minHeight, selectedNode.size.maxHeight)
          .toDouble();

      widget.onMoveNode(
        _resizeNodeFromTopLeft(
          selectedNode,
          cardWidth: widget.document.cardWidth,
          cardHeight: widget.document.cardHeight,
          width: nextWidth,
          height: nextHeight,
        ),
      );
      return;
    }

    final dx = key == LogicalKeyboardKey.arrowRight
        ? stepPx / widget.document.cardWidth
        : key == LogicalKeyboardKey.arrowLeft
            ? -stepPx / widget.document.cardWidth
            : 0.0;
    final dy = key == LogicalKeyboardKey.arrowDown
        ? stepPx / widget.document.cardHeight
        : key == LogicalKeyboardKey.arrowUp
            ? -stepPx / widget.document.cardHeight
            : 0.0;

    final halfWidth = selectedNode.size.width / widget.document.cardWidth / 2;
    final halfHeight = selectedNode.size.height / widget.document.cardHeight / 2;

    final nextX = _clampDouble(
      selectedNode.position.x + dx,
      halfWidth,
      1.0 - halfWidth,
    );
    final nextY = _clampDouble(
      selectedNode.position.y + dy,
      halfHeight,
      1.0 - halfHeight,
    );

    widget.onMoveNode(
      selectedNode.copyWith(
        position: selectedNode.position.copyWith(x: nextX, y: nextY),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Container(
          color: const Color(0xFFF6F7FB),
          child: Column(
            children: <Widget>[
              const _CanvasHeader(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, outerConstraints) {
                    const halfWidthPreset = 192.0;
                    const fullWidthPreset = 392.0;
                    const defaultHeight = 380.0;

                    // Patch 10.3: the preview stage must match the actual card.
                    // The larger white slot was useful for debugging card anchoring,
                    // but it made the studio look like the white slot was part of
                    // the product card. Keep the math simple here: render the true
                    // card only, then place the cardLayoutType editor below it.
                    final stageDesignWidth = widget.document.cardWidth;
                    final stageDesignHeight = widget.document.cardHeight;

                    return Column(
                      children: <Widget>[
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, previewConstraints) {
                              final availableStageWidth = math.max(
                                180.0,
                                previewConstraints.maxWidth - 72,
                              );
                              final availableStageHeight = math.max(
                                220.0,
                                previewConstraints.maxHeight - 24,
                              );
                              final scale = math.min(
                                1.0,
                                math.min(
                                  availableStageWidth / stageDesignWidth,
                                  availableStageHeight / stageDesignHeight,
                                ),
                              );

                              final stageWidth = stageDesignWidth * scale;
                              final stageHeight = stageDesignHeight * scale;
                              final cardWidth = widget.document.cardWidth * scale;
                              final cardHeight = widget.document.cardHeight * scale;

                              return Center(
                                child: _DevicePreviewFrame(
                                  child: SizedBox(
                                    width: stageWidth,
                                    height: stageHeight,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: <Widget>[
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          width: cardWidth,
                                          height: cardHeight,
                                          child: _CanvasDropTarget(
                                            cardWidth: cardWidth,
                                            cardHeight: cardHeight,
                                            onDropVariant: (variant, normalizedPosition) {
                                              widget.onDropVariant(
                                                variant,
                                                normalizedPosition,
                                              );
                                              _requestCanvasFocus();
                                            },
                                            child: SizedBox(
                                              width: cardWidth,
                                              height: cardHeight,
                                              child: _EditableCardCanvas(
                                                previewContext: _previewContext,
                                                document: widget.document,
                                                scale: scale,
                                                onSelectCard: () {
                                                  widget.onSelectCard();
                                                  _requestCanvasFocus();
                                                },
                                                onSelectNode: (nodeId) {
                                                  widget.onSelectNode(nodeId);
                                                  _requestCanvasFocus();
                                                },
                                                onMoveNode: widget.onMoveNode,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: _StageAnchorHint(
                                            visible: widget.document.isCardSelected,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Card: ${widget.document.cardWidth.toStringAsFixed(0)} x ${widget.document.cardHeight.toStringAsFixed(0)} px | ${widget.document.nodes.length} nodes | true card-only preview',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF747B8A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: math.min(560, math.max(320, outerConstraints.maxWidth - 96)),
                                child: _CardLayoutTypeEditor(
                                  value: widget.document.cardLayoutType,
                                  onChanged: widget.onCardLayoutTypeChanged,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardLayoutTypeEditor extends StatefulWidget {
  const _CardLayoutTypeEditor({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_CardLayoutTypeEditor> createState() => _CardLayoutTypeEditorState();
}

class _CardLayoutTypeEditorState extends State<_CardLayoutTypeEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _CardLayoutTypeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8EF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'cardLayoutType',
              style: TextStyle(
                color: Color(0xFFFF6500),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'This value is written to product.cardLayoutType when copying/saving this V3 design.',
              style: TextStyle(
                color: Color(0xFF747B8A),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _commit(),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'hero_poster_circle_diagonal_v1',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0E5EF)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 96,
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      _controller.text = 'hero_poster_circle_diagonal_v1';
                      _commit();
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(96, 40),
                      maximumSize: const Size(96, 40),
                    ),
                    child: const Text('Suggested'),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 82,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _commit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6500),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(82, 40),
                      maximumSize: const Size(82, 40),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
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
      child: Row(
        children: const <Widget>[
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
          SizedBox(
            width: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFF7F8FB),
                borderRadius: BorderRadius.all(Radius.circular(12)),
                border: Border.fromBorderSide(BorderSide(color: Color(0xFFE6E8EF))),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.history_rounded, size: 16, color: Color(0xFFFF6500)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Previous config: Current product design',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF747B8A),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF747B8A)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 14),
          Text(
            'Drop | Mouse move | Arrow move | Ctrl+Arrow resize',
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
    // Patch 10.3: do not draw a large white preview slot around the card.
    // The design surface itself is the card; the surrounding panel is only
    // workspace. A soft shadow keeps the preview visible without implying
    // an extra card container.
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StageAnchorHint extends StatelessWidget {
  const _StageAnchorHint({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFE0C4)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          'Card anchors: left/top fixed',
          style: TextStyle(
            color: Color(0xFFFF6500),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
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
      onWillAcceptWithDetails: (details) => true,
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
    required this.previewContext,
    required this.document,
    required this.scale,
    required this.onSelectCard,
    required this.onSelectNode,
    required this.onMoveNode,
  });

  final MBAdvancedPreviewContext previewContext;
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

    final cardRadius = document.borderRadius * scale;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelectCard,
      child: ClipRRect(
        key: ValueKey<String>('card_radius_${document.borderRadius.toStringAsFixed(2)}'),
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
          ),
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(
                color: selectedCard ? const Color(0xFF172033) : Colors.transparent,
                width: selectedCard ? 2 : 0,
              ),
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
                    _CanvasNodeWidget(
                      previewContext: previewContext,
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
      ),
    );
  }
}

class _CanvasNodeWidget extends StatelessWidget {
  const _CanvasNodeWidget({
    required this.previewContext,
    required this.node,
    required this.selected,
    required this.scale,
    required this.cardWidth,
    required this.cardHeight,
    required this.onSelect,
    required this.onMoveNode,
  });

  final MBAdvancedPreviewContext previewContext;
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
              previewContext: previewContext,
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
    required this.previewContext,
    required this.node,
    required this.scale,
  });

  final MBAdvancedPreviewContext previewContext;
  final MBAdvancedDesignNode node;
  final double scale;

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
      case 'savingtext':
      case 'ribbon':
      case 'variation':
      case 'purchaseOption':
      case 'purchaseoption':
      case 'purchase_option':
      case 'attribute':
      case 'productAttribute':
      case 'productattribute':
      case 'product_attribute':
      case 'attributeValue':
      case 'attributevalue':
      case 'attribute_value':
      case 'attributePreset':
      case 'attributepreset':
      case 'attribute_preset':
        return _TextNode(
          text: _resolveNodeText(previewContext, node),
          node: node,
          scale: scale,
          fallbackColor: _fallbackTextColor(node.elementType),
          maxLines: node.variantId.contains('chip') ? 1 : 3,
          strikeOriginalPrice: _shouldStrikeOriginalPrice(previewContext, node),
        );
      case 'media':
        return _MediaNode(
          imageUrl: _resolveImageUrl(previewContext, node.binding),
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
      case 'pricebadge':
      case 'price_badge':
      case 'promoBadge':
      case 'promobadge':
      case 'promo_badge':
      case 'flashBadge':
      case 'flashbadge':
      case 'flash_badge':
      case 'secondaryCta':
      case 'secondarycta':
      case 'secondary_cta':
      case 'animation':
      case 'cta':
        return _TextNode(
          text: _resolveNodeText(previewContext, node),
          node: node,
          scale: scale,
          fallbackColor: _fallbackTextColor(node.elementType),
          maxLines: 1,
          center: true,
          strikeOriginalPrice: _shouldStrikeOriginalPrice(previewContext, node),
        );
      case 'divider':
      case 'shape':
      case 'panel':
      case 'imageOverlay':
      case 'imageoverlay':
      case 'image_overlay':
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
        return _TextNode(
          text: _resolveNodeText(previewContext, node),
          node: node,
          scale: scale,
          fallbackColor: const Color(0xFFFFFFFF),
          maxLines: 2,
          center: node.style['textAlign']?.toString() == 'center',
          strikeOriginalPrice: _shouldStrikeOriginalPrice(previewContext, node),
        );
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
        (isChipLike || strikeMode == 'horizontal' || strikeMode == 'diagonal' || strikeMode == 'cross');
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
            ? _asDouble(style['strikeThickness'], 1.6).clamp(0.5, 12.0).toDouble()
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
            : Border.all(color: border, width: _asDouble(node.style['borderWidth'], 1.0)),
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
            : Border.all(color: border, width: _asDouble(node.style['borderWidth'], 1.0)),
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

String _resolveBinding(
  MBAdvancedPreviewContext previewContext,
  String binding,
  String fallback,
) {
  return MBAdvancedBindingResolver.resolveText(
    previewContext,
    binding,
    fallback: fallback,
  );
}

String _resolveImageUrl(
  MBAdvancedPreviewContext previewContext,
  String binding,
) {
  final imageUrl = MBAdvancedBindingResolver.resolveImageUrl(
    previewContext,
    binding,
  );

  if (imageUrl.trim().isNotEmpty) {
    return imageUrl;
  }

  return MBAdvancedBindingResolver.resolveImageUrl(
    previewContext,
    'product.thumbnailUrl',
  );
}

String _resolveNodeText(
  MBAdvancedPreviewContext previewContext,
  MBAdvancedDesignNode node,
) {
  final styleLabel = node.style['label']?.toString().trim();
  final styleText = node.style['text']?.toString().trim();
  final prefix = node.style['prefixText']?.toString() ?? '';
  final suffix = node.style['suffixText']?.toString() ?? '';

  final fallback = styleLabel?.isNotEmpty == true
      ? styleLabel!
      : _fallbackTextForNode(node);

  final resolved = MBAdvancedBindingResolver.resolveText(
    previewContext,
    node.binding,
    fallback: fallback,
  ).trim();

  final baseText = styleText?.isNotEmpty == true
      ? styleText!
      : (resolved.isNotEmpty ? resolved : fallback);

  final text = '$prefix$baseText$suffix';

  if (node.elementType == 'price' ||
      node.elementType == 'mrp' ||
      node.elementType == 'priceBadge') {
    return _formatPrice(text);
  }

  return text;
}

String _fallbackTextForNode(MBAdvancedDesignNode node) {
  switch (node.elementType) {
    case 'title':
      return 'Product title';
    case 'subtitle':
      return 'Fresh product detail';
    case 'brand':
      return 'Fresh Farms';
    case 'category':
      return 'Vegetables';
    case 'price':
    case 'priceBadge':
      return '\u09F3120';
    case 'mrp':
      return '\u09F3150';
    case 'discount':
      return '25% OFF';
    case 'cta':
      return node.binding == 'action.details' ? 'View' : 'Buy';
    case 'badge':
      return 'HOT';
    case 'timer':
      return '02:15:08';
    case 'rating':
      return '★ 4.8';
    case 'stock':
      return 'In stock';
    case 'delivery':
      return 'Fast delivery';
    case 'unit':
      return '500 g';
    case 'feature':
      return 'Farm fresh';
    case 'savingText':
      return 'Save 25%';
    case 'ribbon':
      return 'NEW';
    case 'wishlist':
      return '♡';
    case 'compare':
      return '⇄';
    case 'share':
      return '↗';
    case 'icon':
      return '✪';
    case 'quantity':
      return 'Qty 1';
    case 'promoBadge':
      return 'Promo';
    case 'flashBadge':
      return 'Flash';
    case 'secondaryCta':
      return 'Details';
    case 'animation':
      return '●';
    case 'variation':
      return 'Variation';
    case 'purchaseOption':
    case 'purchaseoption':
      return '1 pcs';
    case 'attribute':
      return 'Attribute';
    case 'attributeValue':
    case 'attributevalue':
      return 'Value';
    case 'attributePreset':
    case 'attributepreset':
      return 'Preset';
    default:
      return 'Label';
  }
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


bool _shouldStrikeOriginalPrice(MBAdvancedPreviewContext previewContext, MBAdvancedDesignNode node) {
  if (node.elementType != 'mrp') return false;

  final manualVisible = node.style['strikeVisible'];
  if (manualVisible is bool) return manualVisible;

  final auto = _asBool(node.style['autoStrikeWhenDiscounted'], true);
  if (!auto) return false;

  final originalPrice = MBAdvancedBindingResolver.resolveNumber(
    previewContext,
    'product.price',
  )?.toDouble();
  final salePrice = MBAdvancedBindingResolver.resolveNumber(
    previewContext,
    'product.salePrice',
  )?.toDouble();
  if (originalPrice == null || salePrice == null) return false;
  if (originalPrice <= 0 || salePrice <= 0) return false;
  return salePrice < originalPrice;
}

bool _isChipLikeMrpNode(MBAdvancedDesignNode node, Color background) {
  if (node.elementType != 'mrp') return false;
  final variant = node.variantId.toLowerCase();
  if (variant.contains('chip') || variant.contains('pill') || variant.contains('badge')) {
    return true;
  }
  final rawBg = node.style['backgroundHex']?.toString().trim();
  return rawBg != null && rawBg.isNotEmpty && rawBg != '#00000000' && background != Colors.transparent;
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


MBAdvancedDesignNode _resizeNodeFromTopLeft(
  MBAdvancedDesignNode node, {
  required double cardWidth,
  required double cardHeight,
  required double width,
  required double height,
}) {
  final safeCardWidth = math.max(1.0, cardWidth);
  final safeCardHeight = math.max(1.0, cardHeight);
  final oldLeft = node.position.x - node.size.width / safeCardWidth / 2;
  final oldTop = node.position.y - node.size.height / safeCardHeight / 2;
  final nextHalfWidth = width / safeCardWidth / 2;
  final nextHalfHeight = height / safeCardHeight / 2;
  final nextX = _clampDouble(oldLeft + nextHalfWidth, nextHalfWidth, 1.0 - nextHalfWidth);
  final nextY = _clampDouble(oldTop + nextHalfHeight, nextHalfHeight, 1.0 - nextHalfHeight);

  return node.copyWith(
    position: node.position.copyWith(x: nextX, y: nextY),
    size: node.size.copyWith(width: width, height: height),
  );
}

double _clampDouble(double value, double min, double max) {
  if (max < min) return min;
  return math.min(math.max(value, min), max);
}
