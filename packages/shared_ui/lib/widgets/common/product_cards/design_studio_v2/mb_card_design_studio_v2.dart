import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/shared_models.dart';

import 'models/mb_design_node.dart';
import 'models/mb_design_node_variant.dart';
import 'panels/mb_design_canvas_panel.dart';
import 'panels/mb_design_element_drawer.dart';
import 'panels/mb_design_inspector_panel.dart';

// MuthoBazar Card Design Studio V2
// --------------------------------
// Interaction fix patch:
// - Confirms Patch 2 is active in the top subtitle.
// - Wires drawer drag insertion to canvas.
// - Wires selected node mouse/keyboard update to inspector/canvas.

class MBCardDesignStudioV2 extends StatefulWidget {
  const MBCardDesignStudioV2({
    super.key,
    required this.products,
    this.initialProductIndex = 0,
    this.initialDesignJson,
    this.title = 'Product Card Design Studio V2',
    this.wrapWithScaffold = true,
    this.onSave,
  });

  final List<MBProduct> products;
  final int initialProductIndex;
  final String? initialDesignJson;
  final String title;
  final bool wrapWithScaffold;
  final ValueChanged<String>? onSave;

  @override
  State<MBCardDesignStudioV2> createState() => _MBCardDesignStudioV2State();
}

class _MBCardDesignStudioV2State extends State<MBCardDesignStudioV2> {
  late int _productIndex;
  late MBDesignDocument _document;

  MBProduct get _product {
    if (widget.products.isEmpty) {
      return MBProduct.fromMap(const <String, Object?>{
        'id': 'preview_product',
        'titleEn': 'Preview Product',
        'shortDescriptionEn': 'Preview product description',
        'price': 80,
        'salePrice': 65,
        'thumbnailUrl': '',
      });
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
    _document = MBDesignDocument.fromJson(widget.initialDesignJson);
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        _TopBar(
          title: widget.title,
          productCount: widget.products.length,
          selectedProductIndex: _productIndex,
          onProductChanged: widget.products.isEmpty
              ? null
              : (index) => setState(() => _productIndex = index),
          products: widget.products,
        ),
        Expanded(
          child: Row(
            children: [
              MBDesignElementDrawer(
                onAddVariant: _addVariant,
              ),
              MBDesignCanvasPanel(
                product: _product,
                document: _document,
                onSelectCard: () {
                  setState(() {
                    _document = _document.copyWith(clearSelectedNodeId: true);
                  });
                },
                onSelectNode: (nodeId) {
                  setState(() {
                    _document = _document.copyWith(selectedNodeId: nodeId);
                  });
                },
                onAddVariantAt: _addVariantAt,
                onUpdateNode: _updateNode,
              ),
              MBDesignInspectorPanel(
                document: _document,
                onUpdateDocument: (document) {
                  setState(() => _document = document);
                },
                onUpdateNode: _updateNode,
                onDeleteNode: (nodeId) {
                  setState(() => _document = _document.removeNode(nodeId));
                },
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
        body: content,
      );
    }

    return ColoredBox(
      color: const Color(0xFFF6F7FB),
      child: content,
    );
  }

  void _addVariant(MBDesignNodeVariant variant) {
    final existingOfType = _document.nodes
        .where((node) => node.elementType == variant.elementType)
        .length;

    _addVariantAt(
      variant,
      Offset(
        (0.50 + existingOfType * 0.035).clamp(0.08, 0.92).toDouble(),
        (0.22 + existingOfType * 0.055).clamp(0.08, 0.92).toDouble(),
      ),
    );
  }

  void _addVariantAt(
    MBDesignNodeVariant variant,
    Offset normalizedPosition,
  ) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final existingOfType = _document.nodes
        .where((node) => node.elementType == variant.elementType)
        .length;

    final node = MBDesignNode(
      id: '${variant.elementType}_${existingOfType + 1}_$timestamp',
      elementType: variant.elementType,
      variantId: variant.id,
      binding: _defaultBindingForElement(variant.elementType),
      position: MBDesignNodePosition(
        x: normalizedPosition.dx.clamp(0.04, 0.96).toDouble(),
        y: normalizedPosition.dy.clamp(0.04, 0.96).toDouble(),
        z: _nextLayerZ(),
      ),
      size: _defaultSizeForElement(variant.elementType),
      style: _defaultStyleForVariant(variant),
    );

    setState(() {
      _document = _document.upsertNode(node);
    });
  }

  void _updateNode(MBDesignNode node) {
    setState(() {
      _document = _document.upsertNode(node);
    });
  }

  int _nextLayerZ() {
    if (_document.nodes.isEmpty) {
      return 20;
    }

    final maxZ = _document.nodes
        .map((node) => node.position.z)
        .fold<int>(
          0,
          (previous, current) => current > previous ? current : previous,
        );

    return maxZ + 1;
  }

  Future<void> _copyJson() async {
    await Clipboard.setData(
      ClipboardData(text: _document.toPrettyJson()),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Design V2 JSON copied')),
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
      _document = MBDesignDocument.fromJson(text);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Design V2 JSON pasted')),
    );
  }

  void _saveDesign() {
    final json = _document.toPrettyJson();

    widget.onSave?.call(json);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Design V2 JSON ready')),
    );
  }

  static String _defaultBindingForElement(String elementType) {
    switch (elementType) {
      case 'title':
        return 'product.titleEn';
      case 'subtitle':
        return 'product.shortDescriptionEn';
      case 'media':
        return 'product.thumbnailUrl';
      case 'priceBadge':
      case 'finalPrice':
        return 'product.finalPrice';
      case 'secondaryCta':
      case 'primaryCta':
        return 'action.buy';
      case 'deliveryHint':
        return 'product.deliveryHint';
      case 'timer':
        return 'product.timer';
      default:
        return 'static';
    }
  }

  static MBDesignNodeSize _defaultSizeForElement(String elementType) {
    return switch (elementType) {
      'media' => const MBDesignNodeSize(width: 160, height: 160),
      'priceBadge' => const MBDesignNodeSize(width: 58, height: 58),
      'secondaryCta' || 'primaryCta' =>
        const MBDesignNodeSize(width: 68, height: 32),
      'deliveryHint' || 'timer' => const MBDesignNodeSize(width: 112, height: 28),
      'subtitle' => const MBDesignNodeSize(width: 170, height: 44),
      _ => const MBDesignNodeSize(width: 150, height: 34),
    };
  }

  static Map<String, Object?> _defaultStyleForVariant(
    MBDesignNodeVariant variant,
  ) {
    switch (variant.elementType) {
      case 'title':
        return <String, Object?>{
          'textColorHex': '#FFFFFF',
          'fontSize': variant.id == 'chip_title' ? 13.0 : 18.0,
          'fontWeight': 'w900',
          if (variant.id == 'text_italic') 'fontStyle': 'italic',
          if (variant.id == 'chip_title') 'backgroundHex': '#FFFFFF',
        };
      case 'subtitle':
        return <String, Object?>{
          'textColorHex': '#FFF2E7',
          'fontSize': 11.0,
          if (variant.id == 'soft_chip') 'backgroundHex': '#FFFFFF',
        };
      case 'media':
        return <String, Object?>{
          'borderHex': '#FFFFFF',
          'ringWidth': variant.id == 'circle_ring' ? 7.0 : 0.0,
        };
      case 'priceBadge':
        return <String, Object?>{
          'backgroundHex': '#FFE1CF',
          'textColorHex': '#0D4C7A',
          'borderHex': '#FFFFFF',
          'fontWeight': 'w900',
        };
      case 'secondaryCta':
      case 'primaryCta':
        return <String, Object?>{
          'backgroundHex': '#FF6500',
          'textColorHex': '#FFFFFF',
          'borderRadius': 999.0,
          'fontWeight': 'w900',
        };
      default:
        return <String, Object?>{
          'backgroundHex': '#FFFFFF',
          'textColorHex': '#FF6500',
        };
    }
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.productCount,
    required this.selectedProductIndex,
    required this.onProductChanged,
    required this.products,
  });

  final String title;
  final int productCount;
  final int selectedProductIndex;
  final ValueChanged<int>? onProductChanged;
  final List<MBProduct> products;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE6E8EF)),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.dashboard_customize_rounded,
            color: Color(0xFFFF6500),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Patch 2 active · drag insert + mouse move + keyboard move/resize',
                  style: TextStyle(
                    color: Color(0xFF747B8A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (productCount > 1)
            DropdownButton<int>(
              value: selectedProductIndex,
              items: [
                for (var index = 0; index < products.length; index++)
                  DropdownMenuItem(
                    value: index,
                    child: Text(products[index].titleEn),
                  ),
              ],
              onChanged: onProductChanged == null
                  ? null
                  : (value) {
                      if (value == null) return;
                      onProductChanged?.call(value);
                    },
            ),
        ],
      ),
    );
  }
}
