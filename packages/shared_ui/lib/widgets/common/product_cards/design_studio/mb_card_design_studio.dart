import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/product_cards/design/mb_card_design_models.dart';
import 'package:shared_models/product_cards/design/mb_card_element_position.dart';
import 'package:shared_models/product_cards/design/mb_card_element_size.dart';
import 'package:shared_models/shared_models.dart';
import '../design_engine/mb_design_card_engine.dart';

// MuthoBazar Reusable Card Design Studio Shell
// -------------------------------------------
// Shared UI shell for the new design-family product-card editor.
//
// This widget contains the working design-lab capabilities:
// - product sample/target selection
// - element visibility controls
// - element position controls
// - element size/transform controls
// - drag handles on preview
// - JSON export/import for design state
//
// Important:
// - new design renderer only
// - no old cardConfig fallback
// - no Firestore writes from this reusable shell

typedef MBCardDesignStudioSaveCallback = void Function(
  Map<String, Object?> designState,
  String designJson,
);

class MBCardDesignStudio extends StatefulWidget {
  const MBCardDesignStudio({
    super.key,
    required this.products,
    this.initialProductIndex = 0,
    this.wrapWithScaffold = true,
    this.backgroundColor = const Color(0xFFF6F7FB),
    this.title = 'MuthoBazar Card Lab',
    this.initialDesignJson,
    this.onSave,
    this.showSaveButton = false,
    this.saveButtonLabel = 'Save design',
  });

  final List<MBProduct> products;
  final int initialProductIndex;
  final bool wrapWithScaffold;
  final Color backgroundColor;
  final String title;

  // Optional import/export bridge used by admin product card editor.
  final String? initialDesignJson;
  final MBCardDesignStudioSaveCallback? onSave;
  final bool showSaveButton;
  final String saveButtonLabel;

  @override
  State<MBCardDesignStudio> createState() => _MBCardDesignStudioState();
}

class _MBCardDesignStudioState extends State<MBCardDesignStudio> {
  int _selectedProductIndex = 0;

  bool _showMobileFrame = true;
  double _cardWidth = 220;
  double _aspectRatio = 0.56;
  double _minHeight = 430;
  double _maxHeight = 520;

  String _activePresetId = 'rich';
  String _activeElementId = 'title';

  late Set<String> _visibleElementIds =
      Set<String>.from(_presets[_activePresetId] ?? _richPreset);

  final Map<String, MBCardElementPosition> _positionOverrides =
      <String, MBCardElementPosition>{};

  final Map<String, MBCardElementSize> _sizeOverrides =
      <String, MBCardElementSize>{};

  static const List<String> _allElementIds = <String>[
    'backgroundPanel',
    'borderEffect',
    'brand',
    'categoryChip',
    'compareButton',
    'decorativeShape',
    'deliveryHint',
    'finalPrice',
    'flashBadge',
    'imageFrame',
    'imageOverlay',
    'indicatorDots',
    'media',
    'originalPrice',
    'priceBadge',
    'primaryCta',
    'progressBar',
    'promoBadge',
    'rating',
    'reviewCount',
    'ribbon',
    'savingBadge',
    'secondaryCta',
    'shareButton',
    'stockHint',
    'subtitle',
    'timer',
    'title',
    'unitLabel',
    'wishlistButton',
  ];

  static const List<String> _slotOptions = <String>[
    'topLeft',
    'topCenter',
    'topRight',
    'heroTopLeft',
    'heroTopCenter',
    'heroTopRight',
    'heroCenterLeft',
    'heroCenter',
    'heroCenterRight',
    'bodyTopLeft',
    'bodyTopCenter',
    'bodyTopRight',
    'bodyCenterLeft',
    'bodyCenter',
    'bodyCenterRight',
    'bodyBottomLeft',
    'bodyBottomCenter',
    'bodyBottomRight',
    'bottomLeft',
    'bottomCenter',
    'bottomRight',
    'footerLeft',
    'footerCenter',
    'footerRight',
    'overlayTopLeft',
    'overlayTopCenter',
    'overlayTopRight',
    'overlayCenter',
    'overlayBottomLeft',
    'overlayBottomCenter',
    'overlayBottomRight',
  ];

  static const List<String> _anchorOptions = <String>[
    'topLeft',
    'topCenter',
    'topRight',
    'centerLeft',
    'center',
    'centerRight',
    'bottomLeft',
    'bottomCenter',
    'bottomRight',
  ];

  static const List<String> _alignmentOptions = <String>[
    'start',
    'center',
    'end',
    'topLeft',
    'topCenter',
    'topRight',
    'centerLeft',
    'centerRight',
    'bottomLeft',
    'bottomCenter',
    'bottomRight',
  ];

  static const Set<String> _cleanPreset = <String>{
    'backgroundPanel',
    'decorativeShape',
    'ribbon',
    'media',
    'imageFrame',
    'title',
    'subtitle',
    'finalPrice',
    'originalPrice',
    'savingBadge',
    'primaryCta',
    'indicatorDots',
  };

  static const Set<String> _richPreset = <String>{
    'backgroundPanel',
    'decorativeShape',
    'ribbon',
    'priceBadge',
    'brand',
    'categoryChip',
    'wishlistButton',
    'media',
    'imageFrame',
    'imageOverlay',
    'title',
    'subtitle',
    'rating',
    'reviewCount',
    'stockHint',
    'deliveryHint',
    'finalPrice',
    'originalPrice',
    'unitLabel',
    'savingBadge',
    'primaryCta',
    'secondaryCta',
  };

  static const Set<String> _promoPreset = <String>{
    'backgroundPanel',
    'decorativeShape',
    'ribbon',
    'priceBadge',
    'brand',
    'media',
    'imageFrame',
    'promoBadge',
    'flashBadge',
    'imageOverlay',
    'title',
    'subtitle',
    'timer',
    'progressBar',
    'finalPrice',
    'originalPrice',
    'savingBadge',
    'primaryCta',
  };

  static const Set<String> _minimalPreset = <String>{
    'backgroundPanel',
    'media',
    'imageFrame',
    'title',
    'finalPrice',
    'primaryCta',
  };

  static const Map<String, Set<String>> _presets = <String, Set<String>>{
    'clean': _cleanPreset,
    'rich': _richPreset,
    'promo': _promoPreset,
    'minimal': _minimalPreset,
    'all': <String>{..._allElementIds},
  };

  List<MBProduct> get _products => widget.products;

  MBProduct get _selectedProduct {
    if (widget.products.isEmpty) {
      return _fallbackProduct;
    }

    final index = _selectedProductIndex.clamp(
      0,
      widget.products.length - 1,
    );

    return widget.products[index];
  }

  @override
  void initState() {
    super.initState();
    _selectedProductIndex = _clampedProductIndex(widget.initialProductIndex);

    final initialJson = widget.initialDesignJson?.trim();
    if (initialJson != null && initialJson.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final error = _tryImportDesignJson(initialJson);
        if (error != null) {
          _showSnack(error)();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant MBCardDesignStudio oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.products.length != widget.products.length ||
        _selectedProductIndex >= widget.products.length) {
      _selectedProductIndex = _clampedProductIndex(_selectedProductIndex);
    }
  }

  int _clampedProductIndex(int value) {
    if (widget.products.isEmpty) {
      return 0;
    }

    return value.clamp(0, widget.products.length - 1);
  }


  MBCardDesignConfig get _config {
    const templateId = MBCardDesignRegistry.heroPosterCircleDiagonalV1;

    final base = MBDesignCardDefaultConfigs.heroPosterCircleDiagonalV1();

    final layout = MBCardDesignRegistry.defaultLayoutForTemplate(templateId)
        .copyWith(
      aspectRatio: _aspectRatio,
      minHeight: _minHeight,
      maxHeight: _maxHeight,
      canShrink: true,
      canExpand: true,
      maxShrinkPercent: 7,
      maxExpandPercent: 12,
    );

    final elements = <String, MBCardElementConfig>{};

    for (final entry in base.elements.entries) {
      final resolvedPosition = _resolveElementPosition(
        elementId: entry.key,
        baseElement: entry.value,
      );

      final resolvedSize = _resolveElementSize(
        elementId: entry.key,
        baseElement: entry.value,
      );

      elements[entry.key] = entry.value.copyWith(
        visible: _visibleElementIds.contains(entry.key),
        slot: resolvedPosition.slot,
        position: resolvedPosition,
        size: resolvedSize,
      );
    }

    return base.copyWith(
      layout: layout,
      elements: elements,
      metadata: <String, Object?>{
        ...base.metadata,
        'lab': 'customer_chat_page',
        'activePresetId': _activePresetId,
        'cardWidth': _cardWidth,
        'visibleElementCount': _visibleElementIds.length,
        'activeElementId': _activeElementId,
        'positionOverrides': _positionOverrides.map(
          (key, value) => MapEntry(key, value.toMap()),
        ),
        'sizeOverrides': _sizeOverrides.map(
          (key, value) => MapEntry(key, value.toMap()),
        ),
      },
    );
  }

  MBCardElementPosition _resolveElementPosition({
    required String elementId,
    required MBCardElementConfig baseElement,
  }) {
    final override = _positionOverrides[elementId];
    if (override != null) {
      return override;
    }

    return baseElement.position ?? MBCardElementPosition(slot: baseElement.slot);
  }

  MBCardElementSize? _resolveElementSize({
    required String elementId,
    required MBCardElementConfig baseElement,
  }) {
    final override = _sizeOverrides[elementId];
    if (override != null) {
      return override;
    }

    return baseElement.size;
  }

  MBCardElementPosition get _activeElementPosition {
    final base =
        MBDesignCardDefaultConfigs.heroPosterCircleDiagonalV1().elements[
            _activeElementId];

    if (base == null) {
      return const MBCardElementPosition(slot: 'bodyCenter');
    }

    return _resolveElementPosition(
      elementId: _activeElementId,
      baseElement: base,
    );
  }

  MBCardElementSize get _activeElementSize {
    final base =
        MBDesignCardDefaultConfigs.heroPosterCircleDiagonalV1().elements[
            _activeElementId];

    final resolved = base == null
        ? null
        : _resolveElementSize(
            elementId: _activeElementId,
            baseElement: base,
          );

    return resolved ?? const MBCardElementSize();
  }

  Map<String, Object?> get _exportableDesignState {
    final visible = _visibleElementIds.toList()..sort();
    final positionKeys = _positionOverrides.keys.toList()..sort();
    final sizeKeys = _sizeOverrides.keys.toList()..sort();

    return <String, Object?>{
      'version': 1,
      'type': 'muthobazar_card_design_lab_state',
      'templateId': MBCardDesignRegistry.heroPosterCircleDiagonalV1,
      'designFamilyId': _config.designFamilyId,
      'activePresetId': _activePresetId,
      'activeElementId': _activeElementId,
      'layout': <String, Object?>{
        'cardWidth': _cardWidth,
        'aspectRatio': _aspectRatio,
        'minHeight': _minHeight,
        'maxHeight': _maxHeight,
      },
      'visibleElementIds': visible,
      'positionOverrides': <String, Object?>{
        for (final key in positionKeys) key: _positionOverrides[key]!.toMap(),
      },
      'sizeOverrides': <String, Object?>{
        for (final key in sizeKeys) key: _sizeOverrides[key]!.toMap(),
      },
    };
  }

  String get _exportableDesignJson {
    return const JsonEncoder.withIndent('  ').convert(_exportableDesignState);
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 860;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildPreviewArea(constraints),
                ),
                SizedBox(
                  width: 430,
                  child: _buildControlPanel(),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              children: [
                _buildPreviewArea(constraints),
                _buildControlPanel(),
              ],
            ),
          );
        },
      ),
    );

    if (widget.wrapWithScaffold) {
      return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: content,
      );
    }

    return ColoredBox(
      color: widget.backgroundColor,
      child: content,
    );
  }

  Widget _buildPreviewArea(BoxConstraints constraints) {
    final width = constraints.maxWidth <= 0
        ? MediaQuery.sizeOf(context).width
        : constraints.maxWidth;

    final frameWidth = math.min(390.0, width - 24).clamp(300.0, 390.0);
    final frameHeight = math.min(760.0, MediaQuery.sizeOf(context).height - 24)
        .clamp(620.0, 820.0);

    final previewContent = _buildInteractiveCardPreview();

    return Container(
      width: double.infinity,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      child: _showMobileFrame
          ? MBDesignCardMobilePreviewFrame(
              width: frameWidth.toDouble(),
              height: frameHeight.toDouble(),
              title: widget.title,
              subtitle:
                  '${MBCardDesignRegistry.heroPosterCircleDiagonalV1} • $_activePresetId • drag-lab',
              child: previewContent,
            )
          : previewContent,
    );
  }

  Widget _buildInteractiveCardPreview() {
    final layout = _config.layout;
    final aspectRatio = layout?.aspectRatio ?? _aspectRatio;
    final estimatedHeight = _cardWidth / aspectRatio;
    final cardHeight = estimatedHeight
        .clamp(layout?.minHeight ?? _minHeight, layout?.maxHeight ?? _maxHeight)
        .toDouble();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DragHintPill(
            activeElementId: _activeElementId,
            isVisible: _visibleElementIds.contains(_activeElementId),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: _cardWidth,
            height: cardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: MBDesignCardRenderer(
                    product: _selectedProduct,
                    config: _config,
                    onTap: _showSnack('Product tapped'),
                    onPrimaryCtaTap: _showSnack('Primary CTA tapped'),
                    onSecondaryCtaTap: _showSnack('Secondary CTA tapped'),
                  ),
                ),
                _buildActiveElementDragHandle(cardHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveElementDragHandle(double cardHeight) {
    if (!_visibleElementIds.contains(_activeElementId)) {
      return const SizedBox.shrink();
    }

    final activePosition = _activeElementPosition;
    final point = _previewPointForPosition(activePosition);

    const safePadding = 12.0;
    final usableWidth = (_cardWidth - (safePadding * 2)).clamp(0.0, _cardWidth);
    final usableHeight = (cardHeight - (safePadding * 2)).clamp(0.0, cardHeight);

    final left = safePadding + (usableWidth * point.x) - 17;
    final top = safePadding + (usableHeight * point.y) - 17;

    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanStart: (_) {
            final current = _activeElementPosition;
            final currentPoint = _previewPointForPosition(current);

            _updateActivePosition(
              current.copyWith(
                mode: MBCardElementPositionMode.free,
                x: currentPoint.x,
                y: currentPoint.y,
                z: current.z ?? 10,
                anchor: current.anchor ?? 'center',
                alignment: current.alignment ?? 'center',
              ),
            );
          },
          onPanUpdate: (details) {
            _dragActiveElementBy(
              details.delta,
              usableWidth: usableWidth,
              usableHeight: usableHeight,
            );
          },
          child: _DragHandleBadge(
            elementId: _activeElementId,
          ),
        ),
      ),
    );
  }

  void _dragActiveElementBy(
    Offset delta, {
    required double usableWidth,
    required double usableHeight,
  }) {
    if (usableWidth <= 0 || usableHeight <= 0) {
      return;
    }

    final current = _activeElementPosition;
    final currentPoint = _previewPointForPosition(current);

    final nextX = (currentPoint.x + (delta.dx / usableWidth)).clamp(0.0, 1.0);
    final nextY = (currentPoint.y + (delta.dy / usableHeight)).clamp(0.0, 1.0);

    _updateActivePosition(
      current.copyWith(
        mode: MBCardElementPositionMode.free,
        x: nextX,
        y: nextY,
        z: current.z ?? 10,
        anchor: current.anchor ?? 'center',
        alignment: current.alignment ?? 'center',
      ),
    );
  }

  _PreviewPoint _previewPointForPosition(MBCardElementPosition position) {
    if (position.mode == MBCardElementPositionMode.free) {
      return _PreviewPoint(
        x: (position.x ?? 0.5).clamp(0.0, 1.0),
        y: (position.y ?? 0.5).clamp(0.0, 1.0),
      );
    }

    return _previewPointForSlot(position.slot);
  }

  _PreviewPoint _previewPointForSlot(String slot) {
    switch (slot.trim()) {
      case 'topLeft':
        return const _PreviewPoint(x: 0, y: 0);
      case 'topCenter':
        return const _PreviewPoint(x: 0.5, y: 0);
      case 'topRight':
        return const _PreviewPoint(x: 1, y: 0);
      case 'bottomLeft':
        return const _PreviewPoint(x: 0, y: 1);
      case 'bottomCenter':
        return const _PreviewPoint(x: 0.5, y: 1);
      case 'bottomRight':
        return const _PreviewPoint(x: 1, y: 1);
      case 'center':
      case 'bodyCenter':
      case 'overlayCenter':
        return const _PreviewPoint(x: 0.5, y: 0.5);

      case 'heroTopLeft':
        return const _PreviewPoint(x: 0.06, y: 0.08);
      case 'heroTopCenter':
        return const _PreviewPoint(x: 0.5, y: 0.08);
      case 'heroTopRight':
        return const _PreviewPoint(x: 0.94, y: 0.08);
      case 'heroCenterLeft':
        return const _PreviewPoint(x: 0.06, y: 0.34);
      case 'heroCenter':
        return const _PreviewPoint(x: 0.5, y: 0.42);
      case 'heroCenterRight':
        return const _PreviewPoint(x: 0.94, y: 0.34);
      case 'heroLowerLeft':
        return const _PreviewPoint(x: 0.22, y: 0.58);
      case 'heroLowerRight':
        return const _PreviewPoint(x: 0.78, y: 0.58);

      case 'bodyTopLeft':
      case 'bodyTop':
        return const _PreviewPoint(x: 0.06, y: 0.56);
      case 'bodyTopCenter':
        return const _PreviewPoint(x: 0.5, y: 0.56);
      case 'bodyTopRight':
        return const _PreviewPoint(x: 0.94, y: 0.56);
      case 'bodyCenterLeft':
        return const _PreviewPoint(x: 0.06, y: 0.72);
      case 'bodyCenterRight':
        return const _PreviewPoint(x: 0.94, y: 0.72);
      case 'bodyBottomLeft':
        return const _PreviewPoint(x: 0.06, y: 0.88);
      case 'bodyBottomCenter':
        return const _PreviewPoint(x: 0.5, y: 0.88);
      case 'bodyBottomRight':
        return const _PreviewPoint(x: 0.94, y: 0.88);

      case 'overlayTopLeft':
      case 'topLeftOverlay':
        return const _PreviewPoint(x: 0.06, y: 0.03);
      case 'overlayTopCenter':
        return const _PreviewPoint(x: 0.5, y: 0.03);
      case 'overlayTopRight':
      case 'topRightOverlay':
        return const _PreviewPoint(x: 0.94, y: 0.03);
      case 'overlayBottomLeft':
        return const _PreviewPoint(x: 0.06, y: 0.97);
      case 'overlayBottomCenter':
        return const _PreviewPoint(x: 0.5, y: 0.97);
      case 'overlayBottomRight':
        return const _PreviewPoint(x: 0.94, y: 0.97);

      case 'topTextStart':
        return const _PreviewPoint(x: 0.06, y: 0.09);
      case 'belowBrand':
        return const _PreviewPoint(x: 0.06, y: 0.16);
      case 'actionTop1':
        return const _PreviewPoint(x: 0.94, y: 0.15);
      case 'actionTop2':
        return const _PreviewPoint(x: 0.94, y: 0.22);
      case 'actionTop3':
        return const _PreviewPoint(x: 0.94, y: 0.29);
      case 'centerHero':
      case 'aroundMedia':
        return const _PreviewPoint(x: 0.5, y: 0.47);
      case 'mediaBottomRight':
        return const _PreviewPoint(x: 0.73, y: 0.58);
      case 'bodyTitle':
        return const _PreviewPoint(x: 0.06, y: 0.26);
      case 'bodySubtitle':
        return const _PreviewPoint(x: 0.06, y: 0.36);
      case 'metaLine1':
        return const _PreviewPoint(x: 0.06, y: 0.64);
      case 'metaLine1Right':
        return const _PreviewPoint(x: 0.48, y: 0.64);
      case 'metaLine2Left':
        return const _PreviewPoint(x: 0.06, y: 0.70);
      case 'metaLine2Right':
        return const _PreviewPoint(x: 0.55, y: 0.70);
      case 'metaLine3Left':
        return const _PreviewPoint(x: 0.06, y: 0.77);
      case 'metaLine3Right':
        return const _PreviewPoint(x: 0.46, y: 0.77);
      case 'priceRowStart':
        return const _PreviewPoint(x: 0.06, y: 0.86);
      case 'priceRowMiddle':
        return const _PreviewPoint(x: 0.48, y: 0.86);
      case 'priceRowEnd':
        return const _PreviewPoint(x: 0.92, y: 0.86);
      case 'priceRowBadge':
        return const _PreviewPoint(x: 0.5, y: 0.86);
      case 'bottomLeftSecondary':
        return const _PreviewPoint(x: 0.06, y: 0.92);
      case 'bottomRightSecondary':
        return const _PreviewPoint(x: 0.06, y: 0.97);
      case 'bottomRightMain':
        return const _PreviewPoint(x: 0.94, y: 0.97);
      case 'footerLeft':
        return const _PreviewPoint(x: 0.06, y: 0.97);
      case 'footerCenter':
        return const _PreviewPoint(x: 0.5, y: 0.97);
      case 'footerRight':
        return const _PreviewPoint(x: 0.94, y: 0.97);
      default:
        return const _PreviewPoint(x: 0.5, y: 0.5);
    }
  }

  Widget _buildControlPanel() {
    final visibleKeys = _visibleElementIds.toList()..sort();
    final activePosition = _activeElementPosition;
    final activeSize = _activeElementSize;
    final activeIsVisible = _visibleElementIds.contains(_activeElementId);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF242424),
          fontSize: 13,
          height: 1.35,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Design Renderer V1 Lab',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tune, copy, paste, and preserve design config JSON.',
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Design config JSON'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _copyDesignJsonToClipboard,
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy JSON'),
                  ),
                  if (widget.showSaveButton || widget.onSave != null)
                    FilledButton.icon(
                      onPressed: _saveDesignToHost,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(widget.saveButtonLabel),
                    ),
                  OutlinedButton.icon(
                    onPressed: _showPasteDesignJsonDialog,
                    icon: const Icon(Icons.paste_rounded),
                    label: const Text('Paste JSON'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _printDesignJsonToConsole,
                    icon: const Icon(Icons.terminal_rounded),
                    label: const Text('Print JSON'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showDesignJsonPreviewDialog,
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('View JSON'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _resetLabDesignState,
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Reset config'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _sectionLabel('Product data'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var index = 0; index < _products.length; index++)
                    ChoiceChip(
                      label: Text(_products[index].titleEn),
                      selected: _selectedProductIndex == index,
                      onSelected: (_) {
                        setState(() => _selectedProductIndex = index);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _sectionLabel('Quick presets'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip('clean', 'Clean'),
                  _presetChip('rich', 'Rich'),
                  _presetChip('promo', 'Promo'),
                  _presetChip('minimal', 'Minimal'),
                  _presetChip('all', 'All'),
                ],
              ),
              const SizedBox(height: 18),
              _sectionLabel('Preview'),
              SwitchListTile.adaptive(
                value: _showMobileFrame,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Show mobile frame',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onChanged: (value) => setState(() => _showMobileFrame = value),
              ),
              _slider(
                label: 'Card width',
                value: _cardWidth,
                min: 180,
                max: 260,
                divisions: 16,
                suffix: 'px',
                onChanged: (value) => setState(() => _cardWidth = value),
              ),
              _slider(
                label: 'Aspect ratio',
                value: _aspectRatio,
                min: 0.48,
                max: 0.68,
                divisions: 20,
                decimals: 2,
                onChanged: (value) => setState(() => _aspectRatio = value),
              ),
              _slider(
                label: 'Min height',
                value: _minHeight,
                min: 360,
                max: 520,
                divisions: 32,
                suffix: 'px',
                onChanged: (value) {
                  setState(() {
                    _minHeight = value;
                    if (_maxHeight < _minHeight) {
                      _maxHeight = _minHeight;
                    }
                  });
                },
              ),
              _slider(
                label: 'Max height',
                value: _maxHeight,
                min: 420,
                max: 660,
                divisions: 24,
                suffix: 'px',
                onChanged: (value) {
                  setState(() {
                    _maxHeight = value;
                    if (_minHeight > _maxHeight) {
                      _minHeight = _maxHeight;
                    }
                  });
                },
              ),
              const SizedBox(height: 14),
              _sectionLabel('Element visibility'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in _allElementIds) _elementChip(id),
                ],
              ),
              const SizedBox(height: 18),
              _sectionLabel('Active element editor'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _activeElementId,
                decoration: _inputDecoration('Element id'),
                items: [
                  for (final id in _allElementIds)
                    DropdownMenuItem<String>(
                      value: id,
                      child: Text(id),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _activeElementId = value);
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                value: activeIsVisible,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Visible',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  activeIsVisible
                      ? 'The active element is currently rendered.'
                      : 'The active element is hidden now.',
                  style: const TextStyle(fontSize: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _activePresetId = 'custom';
                    if (value) {
                      _visibleElementIds.add(_activeElementId);
                    } else {
                      _visibleElementIds.remove(_activeElementId);
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              _sectionLabel('Position'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Slot mode'),
                    selected: activePosition.mode == MBCardElementPositionMode.slot,
                    onSelected: (_) => _updateActivePosition(
                      activePosition.copyWith(
                        mode: MBCardElementPositionMode.slot,
                      ),
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Free mode'),
                    selected: activePosition.mode == MBCardElementPositionMode.free,
                    onSelected: (_) => _updateActivePosition(
                      activePosition.copyWith(
                        mode: MBCardElementPositionMode.free,
                        x: activePosition.x ?? 0.5,
                        y: activePosition.y ?? 0.5,
                        z: activePosition.z ?? 0,
                        anchor: activePosition.anchor ?? 'center',
                        alignment: activePosition.alignment ?? 'center',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _slotOptions.contains(activePosition.slot)
                    ? activePosition.slot
                    : _slotOptions.first,
                decoration: _inputDecoration('Slot'),
                items: [
                  for (final slot in _slotOptions)
                    DropdownMenuItem<String>(
                      value: slot,
                      child: Text(slot),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  _updateActivePosition(activePosition.copyWith(slot: value));
                },
              ),
              const SizedBox(height: 10),
              if (activePosition.mode == MBCardElementPositionMode.free) ...[
                _slider(
                  label: 'X position',
                  value: activePosition.x ?? 0.5,
                  min: 0,
                  max: 1,
                  divisions: 100,
                  decimals: 2,
                  onChanged: (value) => _updateActivePosition(
                    activePosition.copyWith(x: value),
                  ),
                ),
                _slider(
                  label: 'Y position',
                  value: activePosition.y ?? 0.5,
                  min: 0,
                  max: 1,
                  divisions: 100,
                  decimals: 2,
                  onChanged: (value) => _updateActivePosition(
                    activePosition.copyWith(y: value),
                  ),
                ),
                _slider(
                  label: 'Z order',
                  value: activePosition.z ?? 0,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  decimals: 0,
                  onChanged: (value) => _updateActivePosition(
                    activePosition.copyWith(z: value),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _anchorOptions.contains(activePosition.anchor)
                      ? activePosition.anchor
                      : 'center',
                  decoration: _inputDecoration('Anchor'),
                  items: [
                    for (final anchor in _anchorOptions)
                      DropdownMenuItem<String>(
                        value: anchor,
                        child: Text(anchor),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    _updateActivePosition(
                      activePosition.copyWith(anchor: value),
                    );
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _alignmentOptions.contains(activePosition.alignment)
                      ? activePosition.alignment
                      : 'center',
                  decoration: _inputDecoration('Alignment'),
                  items: [
                    for (final alignment in _alignmentOptions)
                      DropdownMenuItem<String>(
                        value: alignment,
                        child: Text(alignment),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    _updateActivePosition(
                      activePosition.copyWith(alignment: value),
                    );
                  },
                ),
              ],
              const SizedBox(height: 18),
              _sectionLabel('Size and transform'),
              const SizedBox(height: 8),
              _nullableDimensionSlider(
                label: 'Width',
                value: activeSize.width,
                defaultValue: _defaultElementWidth(_activeElementId),
                min: 20,
                max: 320,
                suffix: 'px',
                onChanged: (value) => _updateActiveSize(
                  activeSize.copyWith(width: value),
                ),
                onClear: () => _updateActiveSize(
                  activeSize.copyWith(width: null),
                ),
              ),
              _nullableDimensionSlider(
                label: 'Height',
                value: activeSize.height,
                defaultValue: _defaultElementHeight(_activeElementId),
                min: 12,
                max: 320,
                suffix: 'px',
                onChanged: (value) => _updateActiveSize(
                  activeSize.copyWith(height: value),
                ),
                onClear: () => _updateActiveSize(
                  activeSize.copyWith(height: null),
                ),
              ),
              _nullableDimensionSlider(
                label: 'Min width',
                value: activeSize.minWidth,
                defaultValue: 0,
                min: 0,
                max: 320,
                suffix: 'px',
                onChanged: (value) => _updateActiveSize(
                  activeSize.copyWith(minWidth: value),
                ),
                onClear: () => _updateActiveSize(
                  activeSize.copyWith(minWidth: null),
                ),
              ),
              _nullableDimensionSlider(
                label: 'Max width',
                value: activeSize.maxWidth,
                defaultValue: 320,
                min: 20,
                max: 420,
                suffix: 'px',
                onChanged: (value) => _updateActiveSize(
                  activeSize.copyWith(maxWidth: value),
                ),
                onClear: () => _updateActiveSize(
                  activeSize.copyWith(maxWidth: null),
                ),
              ),
              _nullableDimensionSlider(
                label: 'Scale',
                value: activeSize.scale,
                defaultValue: 1,
                min: 0.25,
                max: 2,
                divisions: 35,
                decimals: 2,
                onChanged: (value) => _updateActiveSize(
                  activeSize.copyWith(scale: value),
                ),
                onClear: () => _updateActiveSize(
                  activeSize.copyWith(scale: null),
                ),
              ),
              _nullableDimensionSlider(
                label: 'Rotation',
                value: activeSize.rotation,
                defaultValue: 0,
                min: -180,
                max: 180,
                divisions: 72,
                suffix: '°',
                onChanged: (value) => _updateActiveSize(
                  activeSize.copyWith(rotation: value),
                ),
                onClear: () => _updateActiveSize(
                  activeSize.copyWith(rotation: null),
                ),
              ),
              _nullableDimensionSlider(
                label: 'Opacity',
                value: activeSize.opacity,
                defaultValue: 1,
                min: 0,
                max: 1,
                divisions: 20,
                decimals: 2,
                onChanged: (value) => _updateActiveSize(
                  activeSize.copyWith(opacity: value),
                ),
                onClear: () => _updateActiveSize(
                  activeSize.copyWith(opacity: null),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _resetActiveElementPosition,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Reset active position'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _resetAllPositionOverrides,
                    icon: const Icon(Icons.layers_clear_rounded),
                    label: const Text('Reset all positions'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _resetActiveElementSize,
                    icon: const Icon(Icons.aspect_ratio_rounded),
                    label: const Text('Reset active size'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _resetAllSizeOverrides,
                    icon: const Icon(Icons.format_shapes_rounded),
                    label: const Text('Reset all sizes'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _sectionLabel('Active element position'),
              const SizedBox(height: 8),
              _codeBox(_prettyPosition(_activeElementId, activePosition)),
              const SizedBox(height: 14),
              _sectionLabel('Active element size'),
              const SizedBox(height: 8),
              _codeBox(_prettySize(_activeElementId, activeSize)),
              const SizedBox(height: 14),
              _sectionLabel('Resolved config'),
              const SizedBox(height: 8),
              _codeBox(
                'family: ${_config.designFamilyId}\n'
                'template: ${_config.templateId}\n'
                'preset: $_activePresetId\n'
                'layout.aspectRatio: ${_aspectRatio.toStringAsFixed(2)}\n'
                'layout.minHeight: ${_minHeight.toStringAsFixed(0)}\n'
                'layout.maxHeight: ${_maxHeight.toStringAsFixed(0)}\n'
                'visible elements: ${_visibleElementIds.length}\n'
                'supported elements: ${_config.elements.length}\n'
                'position overrides: ${_positionOverrides.length}\n'
                'size overrides: ${_sizeOverrides.length}',
              ),
              const SizedBox(height: 12),
              _sectionLabel('Visible element ids'),
              const SizedBox(height: 8),
              _codeBox(visibleKeys.join('\n')),
              const SizedBox(height: 12),
              _sectionLabel('All position overrides'),
              const SizedBox(height: 8),
              _codeBox(_allPositionOverridesText()),
              const SizedBox(height: 12),
              _sectionLabel('All size overrides'),
              const SizedBox(height: 8),
              _codeBox(_allSizeOverridesText()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _presetChip(String presetId, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _activePresetId == presetId,
      onSelected: (_) {
        setState(() {
          _activePresetId = presetId;
          _visibleElementIds = Set<String>.from(
            _presets[presetId] ?? _cleanPreset,
          );
        });
      },
    );
  }

  Widget _elementChip(String id) {
    final selected = _visibleElementIds.contains(id);
    final isActive = _activeElementId == id;

    return FilterChip(
      label: Text(isActive ? '$id • active' : id),
      selected: selected,
      onSelected: (value) {
        setState(() {
          _activePresetId = 'custom';
          _activeElementId = id;

          if (value) {
            _visibleElementIds.add(id);
          } else {
            _visibleElementIds.remove(id);
          }
        });
      },
      avatar: isActive
          ? const Icon(
              Icons.tune_rounded,
              size: 18,
            )
          : null,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFF6A00),
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
    String suffix = '',
    int decimals = 0,
  }) {
    final displayValue = decimals == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(decimals);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$displayValue$suffix',
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _nullableDimensionSlider({
    required String label,
    required double? value,
    required double defaultValue,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required VoidCallback onClear,
    int? divisions,
    String suffix = '',
    int decimals = 0,
  }) {
    final enabled = value != null;
    final effectiveValue = (value ?? defaultValue).clamp(min, max).toDouble();
    final displayValue = decimals == 0
        ? effectiveValue.toStringAsFixed(0)
        : effectiveValue.toStringAsFixed(decimals);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFFFF7EF)
              : const Color(0xFFF8F8F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? const Color(0xFFFF7A00).withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 6, 6),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    enabled ? '$displayValue$suffix' : 'auto',
                    style: TextStyle(
                      color: enabled
                          ? const Color(0xFFFF6A00)
                          : const Color(0xFF777777),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch.adaptive(
                    value: enabled,
                    onChanged: (state) {
                      if (state) {
                        onChanged(defaultValue.clamp(min, max).toDouble());
                      } else {
                        onClear();
                      }
                    },
                  ),
                ],
              ),
              if (enabled)
                Slider(
                  value: effectiveValue,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _codeBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          height: 1.38,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF9F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFFF7A00),
          width: 1.2,
        ),
      ),
    );
  }

  double _defaultElementWidth(String elementId) {
    switch (elementId) {
      case 'media':
      case 'imageFrame':
        return 150;
      case 'title':
      case 'subtitle':
        return _cardWidth * 0.68;
      case 'stockHint':
      case 'deliveryHint':
      case 'progressBar':
        return _cardWidth * 0.42;
      case 'primaryCta':
        return _cardWidth * 0.46;
      case 'secondaryCta':
        return _cardWidth * 0.30;
      case 'finalPrice':
        return _cardWidth * 0.44;
      default:
        return 90;
    }
  }

  double _defaultElementHeight(String elementId) {
    switch (elementId) {
      case 'media':
      case 'imageFrame':
        return 150;
      case 'title':
        return 42;
      case 'subtitle':
        return 52;
      case 'primaryCta':
      case 'secondaryCta':
        return 38;
      case 'progressBar':
        return 30;
      default:
        return 32;
    }
  }

  void _updateActivePosition(MBCardElementPosition newPosition) {
    setState(() {
      _activePresetId = 'custom';
      _positionOverrides[_activeElementId] = newPosition;
    });
  }

  void _updateActiveSize(MBCardElementSize newSize) {
    setState(() {
      _activePresetId = 'custom';
      if (newSize.isEmpty) {
        _sizeOverrides.remove(_activeElementId);
      } else {
        _sizeOverrides[_activeElementId] = newSize;
      }
    });
  }

  void _resetActiveElementPosition() {
    setState(() {
      _positionOverrides.remove(_activeElementId);
    });
  }

  void _resetAllPositionOverrides() {
    setState(() {
      _positionOverrides.clear();
    });
  }

  void _resetActiveElementSize() {
    setState(() {
      _sizeOverrides.remove(_activeElementId);
    });
  }

  void _resetAllSizeOverrides() {
    setState(() {
      _sizeOverrides.clear();
    });
  }

  void _resetLabDesignState() {
    setState(() {
      _activePresetId = 'rich';
      _activeElementId = 'title';
      _visibleElementIds = Set<String>.from(_richPreset);
      _positionOverrides.clear();
      _sizeOverrides.clear();
      _cardWidth = 220;
      _aspectRatio = 0.56;
      _minHeight = 430;
      _maxHeight = 520;
    });

    _showSnack('Design config reset')();
  }

  void _saveDesignToHost() {
    final callback = widget.onSave;

    if (callback == null) {
      _copyDesignJsonToClipboard();
      return;
    }

    callback(
      Map<String, Object?>.from(_exportableDesignState),
      _exportableDesignJson,
    );
  }

  Future<void> _copyDesignJsonToClipboard() async {
    await Clipboard.setData(
      ClipboardData(text: _exportableDesignJson),
    );

    if (!mounted) return;
    _showSnack('Design JSON copied')();
  }

  void _printDesignJsonToConsole() {
    debugPrint('[MUTHOBAZAR_CARD_DESIGN_JSON]');
    debugPrint(_exportableDesignJson, wrapWidth: 1024);
    _showSnack('Design JSON printed to console')();
  }

  Future<void> _showDesignJsonPreviewDialog() async {
    final controller = TextEditingController(text: _exportableDesignJson);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Design config JSON'),
          content: SizedBox(
            width: 620,
            height: 440,
            child: TextField(
              controller: controller,
              readOnly: true,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: controller.text),
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
                _showSnack('Design JSON copied')();
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> _showPasteDesignJsonDialog() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final controller = TextEditingController(text: clipboard?.text ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Paste design config JSON'),
          content: SizedBox(
            width: 620,
            height: 440,
            child: TextField(
              controller: controller,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste copied design JSON here...',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                final result = _tryImportDesignJson(controller.text);
                if (!context.mounted) return;

                if (result == null) {
                  Navigator.of(context).pop();
                  _showSnack('Design JSON imported')();
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              },
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Import'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  String? _tryImportDesignJson(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);

      if (decoded is! Map) {
        return 'Invalid JSON: root must be an object.';
      }

      final map = Map<String, dynamic>.from(decoded);

      final templateId = _readString(map['templateId']);
      if (templateId.isNotEmpty &&
          templateId != MBCardDesignRegistry.heroPosterCircleDiagonalV1) {
        return 'Unsupported templateId: $templateId';
      }

      final activePresetId = _readString(
        map['activePresetId'],
        fallback: 'custom',
      );

      final activeElementId = _readString(
        map['activeElementId'],
        fallback: _activeElementId,
      );

      final layout = _readMap(map['layout']);

      final importedVisible = _readStringList(
        map['visibleElementIds'],
      ).where(_allElementIds.contains).toSet();

      final importedPositions = _readPositionOverrides(
        map['positionOverrides'],
      );

      final importedSizes = _readSizeOverrides(
        map['sizeOverrides'],
      );

      setState(() {
        _activePresetId = activePresetId.isEmpty ? 'custom' : activePresetId;
        _activeElementId = _allElementIds.contains(activeElementId)
            ? activeElementId
            : 'title';

        if (importedVisible.isNotEmpty) {
          _visibleElementIds = importedVisible;
        }

        _positionOverrides
          ..clear()
          ..addAll(importedPositions);

        _sizeOverrides
          ..clear()
          ..addAll(importedSizes);

        _cardWidth = _readDouble(
          layout['cardWidth'],
          fallback: _cardWidth,
        ).clamp(180, 260).toDouble();

        _aspectRatio = _readDouble(
          layout['aspectRatio'],
          fallback: _aspectRatio,
        ).clamp(0.48, 0.68).toDouble();

        _minHeight = _readDouble(
          layout['minHeight'],
          fallback: _minHeight,
        ).clamp(360, 520).toDouble();

        _maxHeight = _readDouble(
          layout['maxHeight'],
          fallback: _maxHeight,
        ).clamp(420, 660).toDouble();

        if (_maxHeight < _minHeight) {
          _maxHeight = _minHeight;
        }
      });

      return null;
    } catch (error) {
      return 'Import failed: $error';
    }
  }

  String _prettyPosition(String elementId, MBCardElementPosition position) {
    return 'elementId: $elementId\n'
        'mode: ${position.mode.id}\n'
        'slot: ${position.slot}\n'
        'x: ${position.x?.toStringAsFixed(2) ?? 'null'}\n'
        'y: ${position.y?.toStringAsFixed(2) ?? 'null'}\n'
        'z: ${position.z?.toStringAsFixed(0) ?? 'null'}\n'
        'anchor: ${position.anchor ?? 'null'}\n'
        'alignment: ${position.alignment ?? 'null'}';
  }

  String _prettySize(String elementId, MBCardElementSize size) {
    return 'elementId: $elementId\n'
        'width: ${size.width?.toStringAsFixed(1) ?? 'auto'}\n'
        'height: ${size.height?.toStringAsFixed(1) ?? 'auto'}\n'
        'minWidth: ${size.minWidth?.toStringAsFixed(1) ?? 'auto'}\n'
        'maxWidth: ${size.maxWidth?.toStringAsFixed(1) ?? 'auto'}\n'
        'minHeight: ${size.minHeight?.toStringAsFixed(1) ?? 'auto'}\n'
        'maxHeight: ${size.maxHeight?.toStringAsFixed(1) ?? 'auto'}\n'
        'scale: ${size.scale?.toStringAsFixed(2) ?? 'auto'}\n'
        'rotation: ${size.rotation?.toStringAsFixed(1) ?? 'auto'}\n'
        'opacity: ${size.opacity?.toStringAsFixed(2) ?? 'auto'}';
  }

  String _allPositionOverridesText() {
    if (_positionOverrides.isEmpty) {
      return 'No position overrides yet.';
    }

    final keys = _positionOverrides.keys.toList()..sort();
    return keys
        .map(
          (key) => _prettyPosition(key, _positionOverrides[key]!),
        )
        .join('\n\n');
  }

  String _allSizeOverridesText() {
    if (_sizeOverrides.isEmpty) {
      return 'No size overrides yet.';
    }

    final keys = _sizeOverrides.keys.toList()..sort();
    return keys
        .map(
          (key) => _prettySize(key, _sizeOverrides[key]!),
        )
        .join('\n\n');
  }

  VoidCallback _showSnack(String message) {
    return () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 900),
        ),
      );
    };
  }

  static Map<String, dynamic> _readMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }

    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }

    return <String, dynamic>{};
  }

  static String _readString(
    Object? value, {
    String fallback = '',
  }) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) return fallback;
    return normalized;
  }

  static double _readDouble(
    Object? value, {
    required double fallback,
  }) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
  }

  static List<String> _readStringList(Object? value) {
    if (value is! Iterable) {
      return const <String>[];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static Map<String, MBCardElementPosition> _readPositionOverrides(
    Object? value,
  ) {
    final map = _readMap(value);
    final result = <String, MBCardElementPosition>{};

    for (final entry in map.entries) {
      final raw = entry.value;
      if (raw is Map) {
        result[entry.key] = MBCardElementPosition.fromMap(raw);
      }
    }

    return result;
  }

  static Map<String, MBCardElementSize> _readSizeOverrides(Object? value) {
    final map = _readMap(value);
    final result = <String, MBCardElementSize>{};

    for (final entry in map.entries) {
      final raw = entry.value;
      if (raw is Map) {
        result[entry.key] = MBCardElementSize.fromMap(raw);
      }
    }

    return result;
  }

  static final MBProduct _fallbackProduct = MBProduct.fromMap(
    <String, dynamic>{
      'id': 'design_studio_fallback_product',
      'titleEn': 'Preview Product',
      'titleBn': 'Preview Product',
      'shortDescriptionEn': 'Add a product to preview the design.',
      'descriptionEn': 'Add a product to preview the design.',
      'thumbnailUrl': '',
      'imageUrl': '',
      'images': <String>[],
      'price': 0,
      'salePrice': 0,
      'effectivePrice': 0,
      'hasDiscount': false,
      'categoryNameEn': 'General',
      'categoryNameBn': 'General',
      'brandNameEn': 'MuthoBazar',
      'brandNameBn': 'MuthoBazar',
      'isActive': true,
      'isPublished': true,
    },
  );
}

class _PreviewPoint {
  const _PreviewPoint({
    required this.x,
    required this.y,
  });

  final double x;
  final double y;
}

class _DragHintPill extends StatelessWidget {
  const _DragHintPill({
    required this.activeElementId,
    required this.isVisible,
  });

  final String activeElementId;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFF7A00).withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVisible ? Icons.open_with_rounded : Icons.visibility_off,
              size: 15,
              color: const Color(0xFFFF7A00),
            ),
            const SizedBox(width: 6),
            Text(
              isVisible
                  ? 'Drag active: $activeElementId'
                  : 'Active hidden: $activeElementId',
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandleBadge extends StatelessWidget {
  const _DragHandleBadge({
    required this.elementId,
  });

  final String elementId;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFF7A00),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Tooltip(
        message: 'Drag $elementId',
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            Icons.open_with_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

