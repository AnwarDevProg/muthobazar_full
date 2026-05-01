import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/product_cards/design/mb_card_design_models.dart';
import 'package:shared_models/product_cards/design/mb_card_element_position.dart';
import 'package:shared_models/product_cards/design/mb_card_element_size.dart';
import 'package:shared_models/shared_models.dart';
import '../design_engine/mb_design_card_engine.dart';
import '../design_engine/mb_design_runtime_palette.dart';
import '../design_engine/mb_design_element_runtime_style.dart';

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

  String _activePaletteId = 'orange_fresh';
  late Map<String, String> _paletteValues =
      MBDesignRuntimePalette.presetHexMap(_activePaletteId);

  late Set<String> _visibleElementIds =
      Set<String>.from(_presets[_activePresetId] ?? _richPreset);

  final Map<String, MBCardElementPosition> _positionOverrides =
      <String, MBCardElementPosition>{};

  final Map<String, MBCardElementSize> _sizeOverrides =
      <String, MBCardElementSize>{};

  final Map<String, Map<String, Object?>> _elementStyleOverrides =
      <String, Map<String, Object?>>{};

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
        'palette': _paletteMap,
        'elementStyles': _cleanElementStyleOverrides(),
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

  Map<String, Object?> get _paletteMap {
    return <String, Object?>{
      'presetId': _activePaletteId,
      for (final key in MBDesignRuntimePalette.editableHexKeys)
        key: _paletteValues[key],
    };
  }

  Map<String, Object?> get _exportableDesignState {
    final visible = _visibleElementIds.toList()..sort();
    final positionKeys = _positionOverrides.keys.toList()..sort();
    final sizeKeys = _sizeOverrides.keys.toList()..sort();
    final styleKeys = _elementStyleOverrides.keys.toList()..sort();

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
      'palette': _paletteMap,
      'visibleElementIds': visible,
      'positionOverrides': <String, Object?>{
        for (final key in positionKeys) key: _positionOverrides[key]!.toMap(),
      },
      'sizeOverrides': <String, Object?>{
        for (final key in sizeKeys) key: _sizeOverrides[key]!.toMap(),
      },
      'elementStyles': <String, Object?>{
        for (final key in styleKeys)
          if ((_elementStyleOverrides[key] ?? <String, Object?>{}).isNotEmpty)
            key: _elementStyleOverrides[key],
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
                  child: MBDesignRuntimePaletteScope(
                    palette: MBDesignRuntimePalette.fromMap(_paletteMap),
                    child: MBDesignElementRuntimeStyleScope(
                      styles: MBDesignElementRuntimeStyles.fromMap(
                        _cleanElementStyleOverrides(),
                      ),
                      child: MBDesignCardRenderer(
                        product: _selectedProduct,
                        config: _config,
                        onTap: _showSnack('Product tapped'),
                        onPrimaryCtaTap: _showSnack('Primary CTA tapped'),
                        onSecondaryCtaTap: _showSnack('Secondary CTA tapped'),
                      ),
                    ),
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
              _buildPalettePanel(),
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
              const SizedBox(height: 18),
              _buildElementStylePanel(),
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
                'size overrides: ${_sizeOverrides.length}\n'
                'style overrides: ${_elementStyleOverrides.length}',
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
              const SizedBox(height: 12),
              _sectionLabel('All element style overrides'),
              const SizedBox(height: 8),
              _codeBox(_allElementStyleOverridesText()),
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



  Widget _buildElementStylePanel() {
    final style = _activeStyleMap;
    final activeElement = _activeElementId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Element style tuning'),
        const SizedBox(height: 8),
        Text(
          'Active element: $activeElement',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF777777),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _styleHexField(
              keyName: 'textColorHex',
              label: 'Text color',
              fallbackHex: _styleFallbackTextHex(activeElement),
            ),
            _styleHexField(
              keyName: 'backgroundHex',
              label: 'Background',
              fallbackHex: _styleFallbackBackgroundHex(activeElement),
            ),
            _styleHexField(
              keyName: 'borderHex',
              label: 'Border / ring color',
              fallbackHex: _styleFallbackBorderHex(activeElement),
            ),
            _styleHexField(
              keyName: 'shadowHex',
              label: 'Shadow color',
              fallbackHex: '#000000',
            ),
          ],
        ),
        const SizedBox(height: 10),
        _styleNullableSlider(
          label: 'Font size',
          keyName: 'fontSize',
          defaultValue: _defaultStyleFontSize(activeElement),
          min: 7,
          max: 32,
          divisions: 50,
          decimals: 1,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _styleDropdownValue(
            keyName: 'fontWeight',
            allowedValues: const [
              'auto',
              'w400',
              'w500',
              'w600',
              'w700',
              'w800',
              'w900',
            ],
          ),
          decoration: _inputDecoration('Font weight'),
          items: const [
            DropdownMenuItem(value: 'auto', child: Text('Auto')),
            DropdownMenuItem(value: 'w400', child: Text('Normal / w400')),
            DropdownMenuItem(value: 'w500', child: Text('Medium / w500')),
            DropdownMenuItem(value: 'w600', child: Text('SemiBold / w600')),
            DropdownMenuItem(value: 'w700', child: Text('Bold / w700')),
            DropdownMenuItem(value: 'w800', child: Text('ExtraBold / w800')),
            DropdownMenuItem(value: 'w900', child: Text('Black / w900')),
          ],
          onChanged: (value) {
            if (value == null || value == 'auto') {
              _setActiveStyleValue('fontWeight', null);
              return;
            }

            _setActiveStyleValue('fontWeight', value);
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _styleDropdownValue(
            keyName: 'fontStyle',
            allowedValues: const [
              'auto',
              'normal',
              'italic',
            ],
          ),
          decoration: _inputDecoration('Font style'),
          items: const [
            DropdownMenuItem(value: 'auto', child: Text('Auto')),
            DropdownMenuItem(value: 'normal', child: Text('Normal')),
            DropdownMenuItem(value: 'italic', child: Text('Italic')),
          ],
          onChanged: (value) {
            if (value == null || value == 'auto') {
              _setActiveStyleValue('fontStyle', null);
              return;
            }

            _setActiveStyleValue('fontStyle', value);
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _styleDropdownValue(
            keyName: 'textAlign',
            allowedValues: const [
              'auto',
              'start',
              'center',
              'end',
            ],
          ),
          decoration: _inputDecoration('Text alignment'),
          items: const [
            DropdownMenuItem(value: 'auto', child: Text('Auto')),
            DropdownMenuItem(value: 'start', child: Text('Start')),
            DropdownMenuItem(value: 'center', child: Text('Center')),
            DropdownMenuItem(value: 'end', child: Text('End')),
          ],
          onChanged: (value) {
            if (value == null || value == 'auto') {
              _setActiveStyleValue('textAlign', null);
              return;
            }

            _setActiveStyleValue('textAlign', value);
          },
        ),
        const SizedBox(height: 10),
        _styleNullableSlider(
          label: 'Border radius',
          keyName: 'borderRadius',
          defaultValue: _defaultStyleRadius(activeElement),
          min: 0,
          max: 999,
          divisions: 60,
        ),
        _styleNullableSlider(
          label: 'Border width',
          keyName: 'borderWidth',
          defaultValue: _defaultStyleBorderWidth(activeElement),
          min: 0,
          max: 12,
          divisions: 24,
          decimals: 1,
        ),
        _styleNullableSlider(
          label: 'Padding X',
          keyName: 'paddingX',
          defaultValue: _defaultStylePaddingX(activeElement),
          min: 0,
          max: 32,
          divisions: 32,
          decimals: 1,
        ),
        _styleNullableSlider(
          label: 'Padding Y',
          keyName: 'paddingY',
          defaultValue: _defaultStylePaddingY(activeElement),
          min: 0,
          max: 24,
          divisions: 24,
          decimals: 1,
        ),
        _styleNullableSlider(
          label: 'Shadow opacity',
          keyName: 'shadowOpacity',
          defaultValue: 0.14,
          min: 0,
          max: 0.50,
          divisions: 25,
          decimals: 2,
        ),
        _styleNullableSlider(
          label: 'Shadow blur',
          keyName: 'shadowBlur',
          defaultValue: 12,
          min: 0,
          max: 40,
          divisions: 40,
          decimals: 1,
        ),
        _styleNullableSlider(
          label: 'Shadow Y',
          keyName: 'shadowDy',
          defaultValue: 4,
          min: -12,
          max: 24,
          divisions: 36,
          decimals: 1,
        ),
        _styleNullableSlider(
          label: 'Image ring width',
          keyName: 'ringWidth',
          defaultValue: 5,
          min: 0,
          max: 16,
          divisions: 32,
          decimals: 1,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _resetActiveElementStyle,
              icon: const Icon(Icons.format_clear_rounded),
              label: const Text('Reset active style'),
            ),
            OutlinedButton.icon(
              onPressed: _resetAllElementStyles,
              icon: const Icon(Icons.layers_clear_rounded),
              label: const Text('Reset all styles'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _codeBox(_prettyElementStyle(activeElement, style)),
      ],
    );
  }

  Map<String, Object?> get _activeStyleMap {
    return Map<String, Object?>.from(
      _elementStyleOverrides[_activeElementId] ?? <String, Object?>{},
    );
  }

  Map<String, Object?> _cleanElementStyleOverrides() {
    final result = <String, Object?>{};
    final keys = _elementStyleOverrides.keys.toList()..sort();

    for (final key in keys) {
      final value = Map<String, Object?>.from(
        _elementStyleOverrides[key] ?? <String, Object?>{},
      );

      value.removeWhere((_, item) {
        if (item == null) return true;
        if (item is String && item.trim().isEmpty) return true;
        return false;
      });

      if (value.isNotEmpty) {
        result[key] = value;
      }
    }

    return result;
  }

  void _setActiveStyleValue(String key, Object? value) {
    setState(() {
      _activePresetId = 'custom';

      final current = Map<String, Object?>.from(
        _elementStyleOverrides[_activeElementId] ?? <String, Object?>{},
      );

      if (value == null || (value is String && value.trim().isEmpty)) {
        current.remove(key);
      } else {
        current[key] = value;
      }

      if (current.isEmpty) {
        _elementStyleOverrides.remove(_activeElementId);
      } else {
        _elementStyleOverrides[_activeElementId] = current;
      }
    });
  }

  void _resetActiveElementStyle() {
    setState(() {
      _elementStyleOverrides.remove(_activeElementId);
    });
  }

  void _resetAllElementStyles() {
    setState(() {
      _elementStyleOverrides.clear();
    });
  }

  String _styleDropdownValue({
    required String keyName,
    required List<String> allowedValues,
  }) {
    final value = _activeStyleMap[keyName]?.toString().trim();
    if (value == null || value.isEmpty) {
      return 'auto';
    }

    if (allowedValues.contains(value)) {
      return value;
    }

    return 'auto';
  }

  Widget _styleHexField({
    required String keyName,
    required String label,
    required String fallbackHex,
  }) {
    final rawCurrent = _activeStyleMap[keyName]?.toString() ?? fallbackHex;
    final current = MBDesignRuntimePalette.normalizeHex(rawCurrent);
    final isValid = MBDesignRuntimePalette.isValidHex(current);
    final swatchColor = MBDesignRuntimePalette.colorFromHex(
      current,
      fallback: Colors.transparent,
    );

    void openPicker() {
      _openHexColorPicker(
        title: '$label Â· $_activeElementId',
        initialHex: current,
        fallbackHex: fallbackHex,
        onSelected: (hex) => _setActiveStyleValue(keyName, hex),
      );
    }

    return SizedBox(
      width: 190,
      child: TextFormField(
        key: ValueKey(
          'style_picker_${_activeElementId}_${keyName}_$current',
        ),
        initialValue: current,
        readOnly: true,
        onTap: openPicker,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          prefixIcon: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: openPicker,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: swatchColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: swatchColor.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 22,
                  height: 22,
                ),
              ),
            ),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Pick color',
                icon: const Icon(Icons.palette_outlined, size: 18),
                onPressed: openPicker,
              ),
              IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close_rounded, size: 17),
                onPressed: () => _setActiveStyleValue(keyName, null),
              ),
            ],
          ),
          errorText: isValid ? null : 'Use #RRGGBB',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _openHexColorPicker({
    required String title,
    required String initialHex,
    required String fallbackHex,
    required ValueChanged<String> onSelected,
  }) async {
    final startHex = MBDesignRuntimePalette.isValidHex(initialHex)
        ? MBDesignRuntimePalette.normalizeHex(initialHex)
        : MBDesignRuntimePalette.normalizeHex(fallbackHex);

    final picked = await showDialog<String>(
      context: context,
      builder: (context) {
        return _MBHexColorPickerDialog(
          title: title,
          initialHex: startHex,
        );
      },
    );

    if (picked == null) {
      return;
    }

    final normalized = MBDesignRuntimePalette.normalizeHex(picked);

    if (!MBDesignRuntimePalette.isValidHex(normalized)) {
      return;
    }

    onSelected(normalized);
  }
  Widget _styleNullableSlider({
    required String label,
    required String keyName,
    required double defaultValue,
    required double min,
    required double max,
    int? divisions,
    int decimals = 0,
  }) {
    final rawValue = _activeStyleMap[keyName];
    final enabled = rawValue != null;
    final numericValue = _readStyleDouble(rawValue) ?? defaultValue;
    final effectiveValue = numericValue.clamp(min, max).toDouble();
    final display = decimals == 0
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
                    enabled ? display : 'auto',
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
                        _setActiveStyleValue(keyName, defaultValue);
                      } else {
                        _setActiveStyleValue(keyName, null);
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
                  onChanged: (value) => _setActiveStyleValue(keyName, value),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double? _readStyleDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().trim() ?? '');
  }

  String _styleFallbackTextHex(String elementId) {
    final palette = MBDesignRuntimePalette.normalizePaletteMap(_paletteMap);

    switch (elementId) {
      case 'title':
        return palette['titleTextHex'] ?? '#FFFFFF';
      case 'subtitle':
        return palette['subtitleTextHex'] ?? '#FFFFFF';
      case 'finalPrice':
      case 'priceBadge':
        return palette['priceTextHex'] ?? '#0D4C7A';
      case 'secondaryCta':
      case 'primaryCta':
        return palette['buttonTextHex'] ?? '#FFFFFF';
      case 'deliveryHint':
        return palette['deliveryChipTextHex'] ?? '#1565C0';
      case 'timer':
        return palette['timerChipTextHex'] ?? '#B55A00';
      default:
        return palette['badgeTextHex'] ?? '#FF6A00';
    }
  }

  String _styleFallbackBackgroundHex(String elementId) {
    final palette = MBDesignRuntimePalette.normalizePaletteMap(_paletteMap);

    switch (elementId) {
      case 'secondaryCta':
      case 'primaryCta':
        return palette['buttonEndHex'] ?? '#FF6500';
      case 'priceBadge':
        return palette['priceBubbleBackgroundHex'] ?? '#FFE1CF';
      case 'deliveryHint':
        return palette['deliveryChipBackgroundHex'] ?? '#E7F0FF';
      case 'timer':
        return palette['timerChipBackgroundHex'] ?? '#FFF2DE';
      case 'media':
      case 'imageFrame':
        return palette['badgeBackgroundHex'] ?? '#FFFFFF';
      default:
        return palette['badgeBackgroundHex'] ?? '#FFFFFF';
    }
  }

  String _styleFallbackBorderHex(String elementId) {
    final palette = MBDesignRuntimePalette.normalizePaletteMap(_paletteMap);

    switch (elementId) {
      case 'media':
      case 'imageFrame':
        return palette['badgeBackgroundHex'] ?? '#FFFFFF';
      default:
        return palette['cardBorderHex'] ?? '#FF8E24';
    }
  }

  double _defaultStyleFontSize(String elementId) {
    switch (elementId) {
      case 'title':
        return 18;
      case 'subtitle':
        return 11.5;
      case 'finalPrice':
        return 17;
      case 'priceBadge':
        return 14;
      case 'secondaryCta':
      case 'primaryCta':
        return 11;
      default:
        return 10.5;
    }
  }

  double _defaultStyleRadius(String elementId) {
    switch (elementId) {
      case 'title':
      case 'subtitle':
        return 0;
      case 'media':
      case 'imageFrame':
      case 'priceBadge':
      case 'secondaryCta':
      case 'primaryCta':
      default:
        return 999;
    }
  }

  double _defaultStyleBorderWidth(String elementId) {
    switch (elementId) {
      case 'media':
        return 4;
      case 'imageFrame':
        return 5;
      case 'priceBadge':
        return 3;
      default:
        return 1;
    }
  }

  double _defaultStylePaddingX(String elementId) {
    switch (elementId) {
      case 'secondaryCta':
      case 'primaryCta':
        return 14;
      case 'deliveryHint':
      case 'timer':
      case 'savingBadge':
      case 'imageOverlay':
        return 9;
      default:
        return 8;
    }
  }

  double _defaultStylePaddingY(String elementId) {
    switch (elementId) {
      case 'secondaryCta':
      case 'primaryCta':
        return 8;
      case 'deliveryHint':
      case 'timer':
        return 6;
      default:
        return 5;
    }
  }

  String _prettyElementStyle(
    String elementId,
    Map<String, Object?> style,
  ) {
    if (style.isEmpty) {
      return 'elementId: $elementId\nNo style overrides.';
    }

    final keys = style.keys.toList()..sort();

    return [
      'elementId: $elementId',
      for (final key in keys) '$key: ${style[key]}',
    ].join('\n');
  }


  Widget _buildPalettePanel() {
    final palettePreview = MBDesignRuntimePalette.fromMap(_paletteMap);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Palette / Color tuning'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final presetId in MBDesignRuntimePalette.presetIds)
              ChoiceChip(
                label: Text(MBDesignRuntimePalette.presetLabel(presetId)),
                selected: _activePaletteId == presetId,
                onSelected: (_) => _applyPalettePreset(presetId),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                palettePreview.panelStart,
                palettePreview.panelEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: palettePreview.cardBorder.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  MBDesignRuntimePalette.presetLabel(_activePaletteId),
                  style: TextStyle(
                    color: palettePreview.titleText,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: palettePreview.buttonGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Button',
                  style: TextStyle(
                    color: palettePreview.buttonText,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final key in MBDesignRuntimePalette.editableHexKeys)
              SizedBox(
                width: 190,
                child: _paletteHexField(key),
              ),
          ],
        ),
      ],
    );
  }

  Widget _paletteHexField(String key) {
    final rawValue = _paletteValues[key] ??
        MBDesignRuntimePalette.presetHexMap(_activePaletteId)[key] ??
        '#FFFFFF';

    final value = MBDesignRuntimePalette.normalizeHex(rawValue);
    final isValid = MBDesignRuntimePalette.isValidHex(value);
    final swatchColor = MBDesignRuntimePalette.colorFromHex(
      value,
      fallback: Colors.transparent,
    );

    void openPicker() {
      _openHexColorPicker(
        title: MBDesignRuntimePalette.fieldLabel(key),
        initialHex: value,
        fallbackHex: '#FFFFFF',
        onSelected: (hex) => _applyPaletteHex(key, hex),
      );
    }

    return TextFormField(
      key: ValueKey('palette_picker_${_activePaletteId}_${key}_$value'),
      initialValue: value,
      readOnly: true,
      onTap: openPicker,
      decoration: InputDecoration(
        labelText: MBDesignRuntimePalette.fieldLabel(key),
        isDense: true,
        prefixIcon: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: openPicker,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: swatchColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: swatchColor.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const SizedBox(
                width: 22,
                height: 22,
              ),
            ),
          ),
        ),
        suffixIcon: IconButton(
          tooltip: 'Pick color',
          icon: const Icon(Icons.palette_outlined, size: 18),
          onPressed: openPicker,
        ),
        errorText: isValid ? null : 'Use #RRGGBB',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _applyPaletteHex(String key, String rawHex) {
    final normalized = MBDesignRuntimePalette.normalizeHex(rawHex);

    if (!MBDesignRuntimePalette.isValidHex(normalized)) {
      return;
    }

    setState(() {
      _activePresetId = 'custom';
      _paletteValues = <String, String>{
        ..._paletteValues,
        key: normalized,
      };
    });
  }
  void _applyPalettePreset(String presetId) {
    setState(() {
      _activePresetId = 'custom';
      _activePaletteId = presetId;
      _paletteValues = MBDesignRuntimePalette.presetHexMap(presetId);
    });
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
      _elementStyleOverrides.clear();
      _cardWidth = 220;
      _aspectRatio = 0.56;
      _minHeight = 430;
      _maxHeight = 520;
      _activePaletteId = 'orange_fresh';
      _paletteValues = MBDesignRuntimePalette.presetHexMap(_activePaletteId);
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
      final importedPalette = MBDesignRuntimePalette.normalizePaletteMap(
        _readMap(map['palette']),
      );

      final importedVisible = _readStringList(
        map['visibleElementIds'],
      ).where(_allElementIds.contains).toSet();

      final importedPositions = _readPositionOverrides(
        map['positionOverrides'],
      );

      final importedSizes = _readSizeOverrides(
        map['sizeOverrides'],
      );

      final importedStyles = _readElementStyles(
        map['elementStyles'],
      );

      setState(() {
        _activePresetId = activePresetId.isEmpty ? 'custom' : activePresetId;
        _activeElementId = _allElementIds.contains(activeElementId)
            ? activeElementId
            : 'title';

        _activePaletteId = importedPalette['presetId'] ?? 'orange_fresh';
        _paletteValues = Map<String, String>.from(importedPalette);

        if (importedVisible.isNotEmpty) {
          _visibleElementIds = importedVisible;
        }

        _positionOverrides
          ..clear()
          ..addAll(importedPositions);

        _sizeOverrides
          ..clear()
          ..addAll(importedSizes);

        _elementStyleOverrides
          ..clear()
          ..addAll(importedStyles);

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

  String _allElementStyleOverridesText() {
    final cleaned = _cleanElementStyleOverrides();
    if (cleaned.isEmpty) {
      return 'No element style overrides yet.';
    }

    final keys = cleaned.keys.toList()..sort();
    return keys
        .map(
          (key) => _prettyElementStyle(
            key,
            Map<String, Object?>.from(cleaned[key] as Map),
          ),
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

  static Map<String, Map<String, Object?>> _readElementStyles(Object? value) {
    final map = _readMap(value);
    final result = <String, Map<String, Object?>>{};

    for (final entry in map.entries) {
      final elementId = entry.key.toString().trim();
      final rawStyle = entry.value;

      if (elementId.isEmpty || rawStyle is! Map) {
        continue;
      }

      final style = <String, Object?>{};
      final rawMap = _readMap(rawStyle);

      for (final styleEntry in rawMap.entries) {
        final key = styleEntry.key.toString().trim();
        final item = styleEntry.value;

        if (key.isEmpty) {
          continue;
        }

        if (item == null) {
          continue;
        }

        if (item is String && item.trim().isEmpty) {
          continue;
        }

        style[key] = item;
      }

      if (style.isNotEmpty) {
        result[elementId] = style;
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

class _MBHexColorPickerDialog extends StatefulWidget {
  const _MBHexColorPickerDialog({
    required this.title,
    required this.initialHex,
  });

  final String title;
  final String initialHex;

  @override
  State<_MBHexColorPickerDialog> createState() =>
      _MBHexColorPickerDialogState();
}

class _MBHexColorPickerDialogState extends State<_MBHexColorPickerDialog> {
  late int _red;
  late int _green;
  late int _blue;
  late final TextEditingController _hexController;

  static const List<String> _quickColors = <String>[
    '#FFFFFF',
    '#F8FAFC',
    '#F1F5F9',
    '#E5E7EB',
    '#111827',
    '#000000',
    '#FF7A00',
    '#FF6500',
    '#FFA53A',
    '#FFE1CF',
    '#42C66B',
    '#129A44',
    '#22A652',
    '#EFFFF0',
    '#2196F3',
    '#1565C0',
    '#E7F0FF',
    '#7C3AED',
    '#EC4899',
    '#F43F5E',
    '#FFB300',
    '#075E2D',
    '#0D4C7A',
    '#6C6C6C',
  ];

  @override
  void initState() {
    super.initState();

    final initialColor = MBDesignRuntimePalette.colorFromHex(
      widget.initialHex,
      fallback: const Color(0xFFFF7A00),
    );

    _red = (initialColor.r * 255).round().clamp(0, 255).toInt();
    _green = (initialColor.g * 255).round().clamp(0, 255).toInt();
    _blue = (initialColor.b * 255).round().clamp(0, 255).toInt();
    _hexController = TextEditingController(text: _currentHex);
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor {
    return Color.fromARGB(255, _red, _green, _blue);
  }

  String get _currentHex {
    String part(int value) {
      return value.clamp(0, 255).toRadixString(16).padLeft(2, '0');
    }

    return '#${part(_red)}${part(_green)}${part(_blue)}'.toUpperCase();
  }

  void _setColorFromHex(String rawHex) {
    final normalized = MBDesignRuntimePalette.normalizeHex(rawHex);

    if (!MBDesignRuntimePalette.isValidHex(normalized)) {
      return;
    }

    final color = MBDesignRuntimePalette.colorFromHex(
      normalized,
      fallback: _currentColor,
    );

    setState(() {
      _red = (color.r * 255).round().clamp(0, 255).toInt();
      _green = (color.g * 255).round().clamp(0, 255).toInt();
      _blue = (color.b * 255).round().clamp(0, 255).toInt();
      _hexController.text = normalized;
      _hexController.selection = TextSelection.collapsed(
        offset: _hexController.text.length,
      );
    });
  }

  void _setChannel({
    required String channel,
    required double value,
  }) {
    setState(() {
      final channelValue = value.round().clamp(0, 255).toInt();

      switch (channel) {
        case 'r':
          _red = channelValue;
          break;
        case 'g':
          _green = channelValue;
          break;
        case 'b':
          _blue = channelValue;
          break;
      }

      _hexController.text = _currentHex;
      _hexController.selection = TextSelection.collapsed(
        offset: _hexController.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _currentColor;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 82,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        child: Text(
                          _currentHex,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _hexController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'HEX color',
                  hintText: '#FF7A00',
                  prefixIcon: const Icon(Icons.tag_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: _setColorFromHex,
              ),
              const SizedBox(height: 12),
              _buildChannelSlider(
                label: 'Red',
                value: _red,
                onChanged: (value) => _setChannel(
                  channel: 'r',
                  value: value,
                ),
              ),
              _buildChannelSlider(
                label: 'Green',
                value: _green,
                onChanged: (value) => _setChannel(
                  channel: 'g',
                  value: value,
                ),
              ),
              _buildChannelSlider(
                label: 'Blue',
                value: _blue,
                onChanged: (value) => _setChannel(
                  channel: 'b',
                  value: value,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick colors',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final hex in _quickColors)
                    _ColorPickerSwatch(
                      hex: hex,
                      selected: MBDesignRuntimePalette.normalizeHex(hex) ==
                          _currentHex,
                      onTap: () => _setColorFromHex(hex),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(_currentHex),
          icon: const Icon(Icons.check_rounded),
          label: const Text('Apply color'),
        ),
      ],
    );
  }

  Widget _buildChannelSlider({
    required String label,
    required int value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            divisions: 255,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorPickerSwatch extends StatelessWidget {
  const _ColorPickerSwatch({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = MBDesignRuntimePalette.colorFromHex(
      hex,
      fallback: Colors.transparent,
    );

    return Tooltip(
      message: hex,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black.withValues(alpha: 0.10),
              width: selected ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: selected ? 0.34 : 0.16),
                blurRadius: selected ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: selected
              ? const Icon(
                  Icons.check_rounded,
                  size: 17,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
