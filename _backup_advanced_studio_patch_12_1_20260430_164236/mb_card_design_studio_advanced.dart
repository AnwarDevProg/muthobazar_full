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

class MBCardDesignStudioAdvanced extends StatefulWidget {
  const MBCardDesignStudioAdvanced({
    super.key,
    required this.products,
    this.initialProductIndex = 0,
    this.initialDesignJson,
    this.title = 'Product Card Design Studio Advanced',
    this.wrapWithScaffold = true,
    this.onSave,
  });

  final List<dynamic> products;
  final int initialProductIndex;
  final String? initialDesignJson;
  final String title;
  final bool wrapWithScaffold;
  final ValueChanged<String>? onSave;

  @override
  State<MBCardDesignStudioAdvanced> createState() =>
      _MBCardDesignStudioAdvancedState();
}

class _MBCardDesignStudioAdvancedState
    extends State<MBCardDesignStudioAdvanced> {
  late int _productIndex;
  late MBAdvancedCardDesignDocument _document;

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
          onProductChanged: widget.products.isEmpty
              ? null
              : (index) => setState(() => _productIndex = index),
          onClose: _closeStudio,
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              MBAdvancedElementDrawerPanel(
                productTitle: _productTitle(_product),
                productSubtitle: _productSubtitle(_product),
                onAddVariant: _addVariant,
                onApplyCardVariant: _applyCardVariant,
              ),
              MBAdvancedCanvasPanel(
                product: _product,
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

    setState(() {
      _document = MBAdvancedCardDesignDocument.fromJson(text);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced design JSON imported')),
    );
  }

  void _saveDesign() {
    final lockedDocument = _finalizedDocument();
    if (!identical(lockedDocument, _document)) {
      setState(() => _document = lockedDocument);
    }
    final json = lockedDocument.toPrettyJson();
    widget.onSave?.call(json);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Advanced design JSON ready for saving with cardLayoutType')),
    );
  }

  void _closeStudio() {
    final lockedDocument = _finalizedDocument();
    if (!identical(lockedDocument, _document)) {
      setState(() => _document = lockedDocument);
    }
    Navigator.of(context).maybePop();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.productCount,
    required this.selectedProductIndex,
    required this.products,
    required this.onProductChanged,
    required this.onClose,
  });

  final String title;
  final int productCount;
  final int selectedProductIndex;
  final List<dynamic> products;
  final ValueChanged<int>? onProductChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE6E8EF)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Patch 10.3 active - true card-only preview',
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
              width: 220,
              child: DropdownButtonFormField<int>(
                value: selectedProductIndex,
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
          const SizedBox(width: 12),
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
