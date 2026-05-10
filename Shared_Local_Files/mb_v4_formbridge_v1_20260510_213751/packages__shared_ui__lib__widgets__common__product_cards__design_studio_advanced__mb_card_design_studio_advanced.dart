// MuthoBazar Advanced Product Card Design Studio
// Patch 10.3 shell.
//
// Target layout:
// - Left: expandable element drawer with draggable variant boxes.
// - Middle: responsive product-card preview canvas.
// - Right: selected card/element inspector.
//
// Patch 5 scope implemented here:
// - New separated advanced studio path: design_studio_advanced.
// - Existing V1/V2 studio files are not modified.
// - Current design JSON import/export via clipboard.
// - Click node selection works.
// - Empty canvas/card click selects the card itself.
// - Drag variant from left drawer into canvas creates a node.
// - Mouse drag moves selected nodes around the canvas.
// - Patch 8 fixes card/root anchored resize and live radius rendering.
// - Patch 9 adds responsive/fixed element lock and auto-lock on copy/save/close.
// - Patch 10.3 shows true card-only preview while keeping cardLayoutType visible.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/mb_advanced_card_design_document.dart';
import 'models/mb_advanced_element_variant.dart';
import 'panels/mb_advanced_canvas_panel.dart';
import 'panels/mb_advanced_element_drawer_panel.dart';
import 'panels/mb_advanced_inspector_panel.dart';
import '../studio_v4/mb_card_studio_v4_exports.dart';
import '../studio_v4/rendering/mb_studio_v4_runtime_preview_renderer.dart';
import 'package:shared_models/shared_models.dart';

class MBCardDesignStudioAdvanced extends StatefulWidget {
  const MBCardDesignStudioAdvanced({
    super.key,
    required this.products,
    this.initialProductIndex = 0,
    this.initialDesignJson,
    this.title = 'Product Card Design Studio Advanced',
    this.wrapWithScaffold = true,
    this.previewBrand,
    this.previewCategory,
    this.previewVariation,
    this.previewPurchaseOption,
    this.previewProductAttribute,
    this.previewAttributeValue,
    this.previewAttributePreset,
    this.onSave,
    this.onSaveResult,
    this.onCloseResult,
  });

  final List<dynamic> products;
  final int initialProductIndex;
  final String? initialDesignJson;
  final String title;
  final bool wrapWithScaffold;
  final dynamic previewBrand;
  final dynamic previewCategory;
  final dynamic previewVariation;
  final dynamic previewPurchaseOption;
  final dynamic previewProductAttribute;
  final dynamic previewAttributeValue;
  final dynamic previewAttributePreset;
  final ValueChanged<String>? onSave;
  final ValueChanged<MBCardDesignStudioAdvancedResult>? onSaveResult;
  final ValueChanged<MBCardDesignStudioAdvancedResult>? onCloseResult;

  @override
  State<MBCardDesignStudioAdvanced> createState() =>
      _MBCardDesignStudioAdvancedState();
}

class _MBCardDesignStudioAdvancedState
    extends State<MBCardDesignStudioAdvanced> {
  late int _productIndex;
  late MBAdvancedCardDesignDocument _document;
  bool _isDrawerCollapsed = false;
  bool _isInspectorCollapsed = false;
  bool _isFocusMode = false;
  MBStudioV4DraftBridgeResult? _studioV4DraftResult;

  dynamic get _product {
    if (widget.products.isEmpty) {
      return const <String, dynamic>{
        'id': 'advanced_preview_product',
        'titleEn': 'Fresh Mango Pack',
        'shortDescriptionEn': 'Sweet seasonal mango for family basket',
        'price': 120,
        'salePrice': 99,
        'thumbnailUrl': '',
      };
    }

    return widget.products[
        _productIndex.clamp(0, widget.products.length - 1).toInt()];
  }

  @override
  void initState() {
    super.initState();
    _productIndex = widget.initialProductIndex.clamp(
      0,
      widget.products.isEmpty ? 0 : widget.products.length - 1,
    );
    _document = MBAdvancedCardDesignDocument.fromJson(widget.initialDesignJson);
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: <Widget>[
        _TopBar(
          title: widget.title,
          productCount: widget.products.length,
          selectedProductIndex: _productIndex,
          products: widget.products,
          isDrawerCollapsed: _isDrawerCollapsed,
          isInspectorCollapsed: _isInspectorCollapsed,
          isFocusMode: _isFocusMode,
          onProductChanged: widget.products.isEmpty
              ? null
              : (index) => setState(() => _productIndex = index),
          onToggleDrawer: _toggleDrawer,
          onToggleInspector: _toggleInspector,
          onToggleFocusMode: _toggleFocusMode,
          onResetWorkspace: _resetWorkspace,
          onOpenStudioV4Lab: _openStudioV4Lab,
          onClose: _closeStudio,
        ),
        if (_studioV4DraftResult != null)
          _StudioV4DraftStatus(
            result: _studioV4DraftResult!,
            onPreviewDraft: _previewStudioV4Draft,
            onOpenDraft: _openReturnedStudioV4Draft,
            onCopyJson: _copyStudioV4DraftJson,
            onClear: _clearStudioV4Draft,
          ),
        Expanded(
          child: Row(
            children: <Widget>[
              if (_isDrawerCollapsed)
                _CollapsedStudioRail(
                  icon: Icons.widgets_rounded,
                  label: 'Elements',
                  tooltip: 'Expand element drawer',
                  isLeft: true,
                  onTap: () => setState(() => _isDrawerCollapsed = false),
                )
              else
                Stack(
                  children: <Widget>[
                    MBAdvancedElementDrawerPanel(
                      productTitle: _productTitle(_product),
                      productSubtitle: _productSubtitle(_product),
                      previewProduct: _product,
                      previewBrand: widget.previewBrand,
                      previewCategory: widget.previewCategory,
                      previewVariation: widget.previewVariation,
                      previewPurchaseOption: widget.previewPurchaseOption,
                      previewProductAttribute: widget.previewProductAttribute,
                      previewAttributeValue: widget.previewAttributeValue,
                      previewAttributePreset: widget.previewAttributePreset,
                      onAddVariant: _addVariant,
                      onApplyCardVariant: _applyCardVariant,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _PanelCollapseButton(
                        icon: Icons.chevron_left_rounded,
                        tooltip: 'Collapse element drawer',
                        onTap: () => setState(() => _isDrawerCollapsed = true),
                      ),
                    ),
                  ],
                ),
              MBAdvancedCanvasPanel(
                product: _product,
                previewBrand: widget.previewBrand,
                previewCategory: widget.previewCategory,
                previewVariation: widget.previewVariation,
                previewPurchaseOption: widget.previewPurchaseOption,
                previewProductAttribute: widget.previewProductAttribute,
                previewAttributeValue: widget.previewAttributeValue,
                previewAttributePreset: widget.previewAttributePreset,
                document: _document,
                onSelectCard: () {
                  setState(() => _document = _document.selectCard());
                },
                onSelectNode: (nodeId) {
                  setState(() => _document = _document.selectNode(nodeId));
                },
                onDropVariant: _dropVariantOnCanvas,
                onMoveNode: _updateNode,
                onDeleteNode: _deleteNode,
                onCardLayoutTypeChanged: _updateCardLayoutType,
              ),
              if (_isInspectorCollapsed)
                _CollapsedStudioRail(
                  icon: Icons.tune_rounded,
                  label: 'Inspector',
                  tooltip: 'Expand element inspector',
                  isLeft: false,
                  onTap: () => setState(() => _isInspectorCollapsed = false),
                )
              else
                Stack(
                  children: <Widget>[
                    MBAdvancedInspectorPanel(
                      document: _document,
                      onUpdateDocument: (document) {
                        setState(() => _document = document);
                      },
                      onUpdateNode: _updateNode,
                      onDeleteNode: _deleteNode,
                      onCopyJson: _copyJson,
                      onPasteJson: _pasteJson,
                      onSave: _saveDesign,
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _PanelCollapseButton(
                        icon: Icons.chevron_right_rounded,
                        tooltip: 'Collapse inspector',
                        onTap: () => setState(() => _isInspectorCollapsed = true),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );

    if (widget.wrapWithScaffold) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SafeArea(child: content),
      );
    }

    return ColoredBox(
      color: const Color(0xFFF6F7FB),
      child: content,
    );
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerCollapsed = !_isDrawerCollapsed;
      _isFocusMode = _isDrawerCollapsed && _isInspectorCollapsed;
    });
  }

  void _toggleInspector() {
    setState(() {
      _isInspectorCollapsed = !_isInspectorCollapsed;
      _isFocusMode = _isDrawerCollapsed && _isInspectorCollapsed;
    });
  }

  void _toggleFocusMode() {
    setState(() {
      if (_isFocusMode) {
        _isFocusMode = false;
        _isDrawerCollapsed = false;
        _isInspectorCollapsed = false;
      } else {
        _isFocusMode = true;
        _isDrawerCollapsed = true;
        _isInspectorCollapsed = true;
      }
    });
  }

  void _resetWorkspace() {
    setState(() {
      _isFocusMode = false;
      _isDrawerCollapsed = false;
      _isInspectorCollapsed = false;
    });
  }

  void _applyCardVariant(MBAdvancedElementVariant variant) {
    setState(() {
      _document = _document
          .updateLayout(variant.cardLayoutPatch)
          .updatePalette(variant.cardPalettePatch)
          .selectCard();
    });
  }

  void _addVariant(
    MBAdvancedElementVariant variant, {
    Offset? normalizedCanvasPosition,
  }) {
    if (variant.isCardVariant) {
      _applyCardVariant(variant);
      return;
    }

    final existingOfType = _document.nodes
        .where((node) => node.elementType == variant.elementType)
        .length;
    final offset = normalizedCanvasPosition == null ? existingOfType * 0.035 : 0.0;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final x = normalizedCanvasPosition?.dx ?? (variant.defaultPosition.x + offset);
    final y = normalizedCanvasPosition?.dy ?? (variant.defaultPosition.y + offset);

    final node = MBAdvancedDesignNode(
      id: '${variant.elementType}_${existingOfType + 1}_$timestamp',
      elementType: variant.elementType,
      variantId: variant.id,
      binding: variant.binding,
      position: variant.defaultPosition.copyWith(
        x: x.clamp(0.04, 0.96).toDouble(),
        y: y.clamp(0.04, 0.96).toDouble(),
        z: _nextLayerZ(),
      ),
      size: variant.defaultSize,
      style: variant.defaultStyle,
    );

    setState(() {
      _document = _document.upsertNode(node);
    });
  }

  void _dropVariantOnCanvas(
    MBAdvancedElementVariant variant,
    Offset normalizedCanvasPosition,
  ) {
    _addVariant(
      variant,
      normalizedCanvasPosition: normalizedCanvasPosition,
    );
  }

  void _updateNode(MBAdvancedDesignNode node) {
    setState(() {
      _document = _document.upsertNode(node);
    });
  }

  void _deleteNode(String nodeId) {
    setState(() {
      _document = _document.removeNode(nodeId);
    });
  }

  void _updateCardLayoutType(String value) {
    setState(() {
      _document = _document.updateCardLayoutType(value);
    });
  }

  MBAdvancedCardDesignDocument _finalizedDocument() {
    return _document.lockElementsResponsive().ensureCardLayoutType();
  }

  int _nextLayerZ() {
    if (_document.nodes.isEmpty) return 20;
    final maxZ = _document.nodes
        .map((node) => node.position.z)
        .fold<int>(0, (previous, current) => current > previous ? current : previous);
    return maxZ + 1;
  }

  Future<void> _copyJson() async {
    final lockedDocument = _finalizedDocument();
    if (!identical(lockedDocument, _document)) {
      setState(() => _document = lockedDocument);
    }
    await Clipboard.setData(ClipboardData(text: lockedDocument.toPrettyJson()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced design JSON copied with cardLayoutType')),
    );
  }

  Future<void> _pasteJson() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clipboard is empty')),
      );
      return;
    }

        if (_isStudioV4JsonText(text)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'V4 JSON cannot be pasted into V3 Studio. Use Preview/Open V4 Draft instead.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _document = MBAdvancedCardDesignDocument.fromJson(text);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced design JSON imported')),
    );
  }  bool _isStudioV4JsonText(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return false;
    return normalized.contains('muthobazar_card_design_v4') ||
        normalized.contains('"schemaVersion": 4') ||
        normalized.contains('"schemaVersion":4');
  }

  Future<void> _openStudioV4Lab() async {
    final lockedDocument = _finalizedDocument();
    if (!identical(lockedDocument, _document)) {
      setState(() => _document = lockedDocument);
    }

    final document = MBStudioV4DocumentAdapter.fromAdvancedDocument(
      lockedDocument,
      name: 'Studio V4 Lab - ${_productTitle(_product)}',
    );

    await _openStudioV4LabWithDocument(document);
  }

  Future<void> _openReturnedStudioV4Draft() async {
    final json = _studioV4DraftResult?.json.trim();
    if (json == null || json.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Studio V4 draft is attached yet.')),
      );
      return;
    }

    await _openStudioV4LabWithDocument(
      MBCardDesignDocumentV4.fromJson(json),
    );
  }

  Future<void> _previewStudioV4Draft() async {
    final json = _studioV4DraftResult?.json.trim();
    if (json == null || json.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Studio V4 draft is attached yet.')),
      );
      return;
    }

    final document = MBCardDesignDocumentV4.fromJson(json);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        return Dialog(
          insetPadding: const EdgeInsets.all(22),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SizedBox(
            width: size.width * 0.72,
            height: size.height * 0.78,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE6E8EF)),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3EA),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.visibility_rounded,
                          color: Color(0xFFFF6500),
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Studio V4 Draft Preview',
                              style: TextStyle(
                                color: Color(0xFF172033),
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Render-only preview. This does not use the V3 canvas and does not save to product.',
                              style: TextStyle(
                                color: Color(0xFF747B8A),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Close'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6500),
                          textStyle: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: MBStudioV4RuntimePreviewRenderer(document: document),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openStudioV4LabWithDocument(
    MBCardDesignDocumentV4 initialDocument,
  ) async {
    final controller = MBStudioV4Controller(initialDocument: initialDocument);

    if (!mounted) {
      controller.dispose();
      return;
    }

    final result = await showDialog<MBStudioV4DraftBridgeResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SizedBox(
            width: size.width * 0.94,
            height: size.height * 0.90,
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE6E8EF)),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3EA),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.science_rounded,
                          color: Color(0xFFFF6500),
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Studio V4 Lab',
                              style: TextStyle(
                                color: Color(0xFF172033),
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Preview only - use draft returns V4 JSON to V3 bridge, not product save.',
                              style: TextStyle(
                                color: Color(0xFF747B8A),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () {
                          final json = controller.document.toPrettyJson();
                          final draft = MBStudioV4DraftBridgeResult.fromJsonString(
                            json,
                            previewOnly: true,
                            source: 'studio_v4_lab_result',
                          );
                          Navigator.of(dialogContext).pop(draft);
                        },
                        icon: const Icon(Icons.output_rounded, size: 18),
                        label: const Text('Use V4 Draft'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6500),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Close Lab'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6500),
                          textStyle: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: MBCardStudioV4(
                      controller: controller,
                      title: 'Studio V4 Lab Preview',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);

    final returnedJson = result?.json.trim();
    if (!mounted || returnedJson == null || returnedJson.isEmpty) return;

    _rememberStudioV4Draft(returnedJson);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Studio V4 draft returned to V3 bridge. Not saved yet.'),
      ),
    );
  }
  void _rememberStudioV4Draft(String json) {
    final result = MBStudioV4DraftBridgeResult.fromJsonString(
      json,
      source: 'studio_v4_lab',
      previewOnly: true,
    );

    setState(() {
      _studioV4DraftResult = result;
    });
  }

  Future<void> _copyStudioV4DraftJson() async {
    final json = _studioV4DraftResult?.json;
    if (json == null || json.trim().isEmpty) return;

    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Returned Studio V4 JSON copied.')),
    );
  }

  void _clearStudioV4Draft() {
    setState(() {
      _studioV4DraftResult = null;
    });
  }

  MBCardDesignStudioAdvancedResult _buildResult(String designJson) {
    return MBCardDesignStudioAdvancedResult(
      designJson: designJson,
      studioV4Draft: _studioV4DraftResult,
    );
  }

  void _saveDesign() {
    final lockedDocument = _finalizedDocument();
    if (!identical(lockedDocument, _document)) {
      setState(() => _document = lockedDocument);
    }
    final json = lockedDocument.toPrettyJson();
    final result = _buildResult(json);
    widget.onSave?.call(json);
    widget.onSaveResult?.call(result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.hasStudioV4Draft
              ? 'Advanced design ready. Studio V4 draft metadata is attached to the result.'
              : 'Advanced design JSON ready for saving with cardLayoutType',
        ),
      ),
    );
  }

  void _closeStudio() {
    final lockedDocument = _finalizedDocument();
    if (!identical(lockedDocument, _document)) {
      setState(() => _document = lockedDocument);
    }
    widget.onCloseResult?.call(_buildResult(lockedDocument.toPrettyJson()));
    Navigator.of(context).maybePop();
  }
}

class MBCardDesignStudioAdvancedResult {
  const MBCardDesignStudioAdvancedResult({
    required this.designJson,
    this.studioV4Draft,
  });

  final String designJson;
  final MBStudioV4DraftBridgeResult? studioV4Draft;

  bool get hasStudioV4Draft => studioV4Draft?.hasJson ?? false;
  String? get studioV4DraftJson => studioV4Draft?.json;
  int? get studioV4SchemaVersion => studioV4Draft?.schemaVersion;
  int get studioV4NodeCount => studioV4Draft?.nodeCount ?? 0;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'designJson': designJson,
      'hasStudioV4Draft': hasStudioV4Draft,
      if (studioV4Draft != null) 'studioV4Draft': studioV4Draft!.toMap(),
      if (studioV4DraftJson != null) 'studioV4DraftJson': studioV4DraftJson,
    };
  }
}

class _StudioV4DraftStatus extends StatelessWidget {
  const _StudioV4DraftStatus({
    required this.result,
    required this.onPreviewDraft,
    required this.onOpenDraft,
    required this.onCopyJson,
    required this.onClear,
  });

  final MBStudioV4DraftBridgeResult result;
  final VoidCallback onPreviewDraft;
  final VoidCallback onOpenDraft;
  final VoidCallback onCopyJson;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final schemaText = result.schemaVersion == null
        ? 'unknown'
        : '${result.schemaVersion}';
    final canvasText = result.hasValidCanvas
        ? '${result.canvasWidth!.toStringAsFixed(0)}Ã—${result.canvasHeight!.toStringAsFixed(0)}'
        : 'unknown canvas';
    final statusText = result.previewOnly
        ? 'Preview only, not saved to product'
        : 'Ready for product save bridge';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.science_rounded,
            color: Color(0xFFFF6500),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'V4 draft attached Â· Schema: $schemaText Â· Nodes: ${result.nodeCount} Â· Canvas: $canvasText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9A3412),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$statusText Â· V4 JSON cannot be pasted into V3 Studio. Use Preview or Open/Edit V4 Draft.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFC2410C),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              TextButton.icon(
                onPressed: onPreviewDraft,
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: const Text('Preview V4'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6500),
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              TextButton.icon(
                onPressed: onOpenDraft,
                icon: const Icon(Icons.edit_note_rounded, size: 16),
                label: const Text('Open/Edit V4'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6500),
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              TextButton.icon(
                onPressed: onCopyJson,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy V4 JSON'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6500),
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                tooltip: 'Clear returned V4 draft status',
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _PanelCollapseButton extends StatelessWidget {
  const _PanelCollapseButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        elevation: 3,
        shadowColor: const Color(0x22000000),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFFD8BD)),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFFFF6500),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedStudioRail extends StatelessWidget {
  const _CollapsedStudioRail({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.isLeft,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF8),
              border: Border(
                left: isLeft
                    ? BorderSide.none
                    : const BorderSide(color: Color(0xFFE6E8EF)),
                right: isLeft
                    ? const BorderSide(color: Color(0xFFE6E8EF))
                    : BorderSide.none,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6500),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 10),
                RotatedBox(
                  quarterTurns: isLeft ? 3 : 1,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF172033),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.productCount,
    required this.selectedProductIndex,
    required this.products,
    required this.isDrawerCollapsed,
    required this.isInspectorCollapsed,
    required this.isFocusMode,
    required this.onProductChanged,
    required this.onToggleDrawer,
    required this.onToggleInspector,
    required this.onToggleFocusMode,
    required this.onResetWorkspace,
    required this.onOpenStudioV4Lab,
    required this.onClose,
  });

  final String title;
  final int productCount;
  final int selectedProductIndex;
  final List<dynamic> products;
  final bool isDrawerCollapsed;
  final bool isInspectorCollapsed;
  final bool isFocusMode;
  final ValueChanged<int>? onProductChanged;
  final VoidCallback onToggleDrawer;
  final VoidCallback onToggleInspector;
  final VoidCallback onToggleFocusMode;
  final VoidCallback onResetWorkspace;
  final VoidCallback onOpenStudioV4Lab;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE6E8EF)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFFF6500), Color(0xFFFF9A3D)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.dashboard_customize_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Studio UI v3 - compact workspace controls',
                  style: TextStyle(
                    color: Color(0xFF747B8A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (productCount > 1)
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<int>(
                initialValue: selectedProductIndex,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE6E8EF)),
                  ),
                ),
                items: <DropdownMenuItem<int>>[
                  for (var index = 0; index < products.length; index++)
                    DropdownMenuItem<int>(
                      value: index,
                      child: Text(
                        _productTitle(products[index]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  onProductChanged?.call(value);
                },
              ),
            ),
          const SizedBox(width: 8),
          _TopBarButton(
            icon: isDrawerCollapsed
                ? Icons.keyboard_double_arrow_right_rounded
                : Icons.keyboard_double_arrow_left_rounded,
            label: isDrawerCollapsed ? 'Elements' : 'Hide left',
            tooltip: isDrawerCollapsed
                ? 'Expand element drawer'
                : 'Collapse element drawer',
            selected: isDrawerCollapsed,
            onTap: onToggleDrawer,
          ),
          const SizedBox(width: 6),
          _TopBarButton(
            icon: isInspectorCollapsed
                ? Icons.keyboard_double_arrow_left_rounded
                : Icons.keyboard_double_arrow_right_rounded,
            label: isInspectorCollapsed ? 'Inspector' : 'Hide right',
            tooltip: isInspectorCollapsed
                ? 'Expand element inspector'
                : 'Collapse element inspector',
            selected: isInspectorCollapsed,
            onTap: onToggleInspector,
          ),
          const SizedBox(width: 6),
          _TopBarButton(
            icon: isFocusMode
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            label: isFocusMode ? 'Exit focus' : 'Focus',
            tooltip: isFocusMode
                ? 'Exit focus mode'
                : 'Collapse both panels and maximize canvas',
            selected: isFocusMode,
            onTap: onToggleFocusMode,
          ),
          const SizedBox(width: 6),
          _TopBarButton(
            icon: Icons.restart_alt_rounded,
            label: 'Reset',
            tooltip: 'Reset workspace panels',
            onTap: onResetWorkspace,
          ),
          const SizedBox(width: 6),
          _TopBarButton(
            icon: Icons.science_rounded,
            label: 'V4 Lab',
            tooltip: 'Open Studio V4 Lab preview and return V4 JSON safely',
            onTap: onOpenStudioV4Lab,
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Close'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6500),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}


class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : const Color(0xFFFF6500);
    final background = selected ? const Color(0xFFFF6500) : const Color(0xFFFFF3EA);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? const Color(0xFFFF6500)
                    : const Color(0xFFFFD8BD),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 17, color: foreground),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _productTitle(dynamic product) {
  return _readDynamicString(product, 'titleEn', 'Preview Product');
}

String _productSubtitle(dynamic product) {
  return _readDynamicString(
    product,
    'shortDescriptionEn',
    'Fresh product detail',
  );
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
      default:
        value = null;
    }
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  } catch (_) {}

  return fallback;
}


