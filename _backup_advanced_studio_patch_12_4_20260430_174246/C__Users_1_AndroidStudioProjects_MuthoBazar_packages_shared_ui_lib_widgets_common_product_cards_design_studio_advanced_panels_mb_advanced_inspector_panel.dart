// MuthoBazar Advanced Product Card Design Studio
// Patch 12.2 right inspector panel.
//
// Purpose:
// - Extends the inspector with richer controls for both the card and nodes.
// - Adds fully synced manual numeric input beside sliders.
// - Adds inline color swatch pickers + manual hex input.
// - Exposes more editable style props so the canvas feels more like a real
//   design tool instead of a demo-only inspector.
// - Rebinds all text inputs when the selected node changes.
// - Adds MRP/old-price strike and chip-cross controls.
// - Adds card width presets and anchored node resizing.
// - Adds responsive/fixed card resize mode for element locking.
// - Patch 12.2 adds element-type-specific inspector control sections.

import 'package:flutter/material.dart';

import '../models/mb_advanced_card_design_document.dart';

class MBAdvancedInspectorPanel extends StatelessWidget {
  const MBAdvancedInspectorPanel({
    super.key,
    required this.document,
    required this.onUpdateDocument,
    required this.onUpdateNode,
    required this.onDeleteNode,
    required this.onCopyJson,
    required this.onPasteJson,
    required this.onSave,
  });

  final MBAdvancedCardDesignDocument document;
  final ValueChanged<MBAdvancedCardDesignDocument> onUpdateDocument;
  final ValueChanged<MBAdvancedDesignNode> onUpdateNode;
  final ValueChanged<String> onDeleteNode;
  final VoidCallback onCopyJson;
  final VoidCallback onPasteJson;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final selectedNode = document.selectedNode;

    return Container(
      width: 336,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFE6E8EF)),
        ),
      ),
      child: Column(
        children: <Widget>[
          _InspectorHeader(
            isCardSelected: selectedNode == null,
            node: selectedNode,
          ),
          _JsonActionBar(
            onCopyJson: onCopyJson,
            onPasteJson: onPasteJson,
            onSave: onSave,
          ),
          Expanded(
            child: selectedNode == null
                ? _CardInspector(
                    document: document,
                    onUpdateDocument: onUpdateDocument,
                  )
                : _NodeInspector(
                    key: ValueKey<String>('node_inspector_${selectedNode.id}'),
                    document: document,
                    node: selectedNode,
                    onUpdateNode: onUpdateNode,
                    onDeleteNode: onDeleteNode,
                  ),
          ),
        ],
      ),
    );
  }
}

class _InspectorHeader extends StatelessWidget {
  const _InspectorHeader({
    required this.isCardSelected,
    required this.node,
  });

  final bool isCardSelected;
  final MBAdvancedDesignNode? node;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFFFE3D0)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6500),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCardSelected ? Icons.credit_card_rounded : Icons.tune_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isCardSelected ? 'Card Inspector' : 'Element Inspector',
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isCardSelected
                      ? 'Layout, colors, radius and surface tuning'
                      : '${node!.elementType} - ${node!.variantId}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF747B8A),
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _JsonActionBar extends StatelessWidget {
  const _JsonActionBar({
    required this.onCopyJson,
    required this.onPasteJson,
    required this.onSave,
  });

  final VoidCallback onCopyJson;
  final VoidCallback onPasteJson;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE6E8EF)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SmallButton(
              icon: Icons.copy_rounded,
              label: 'Copy',
              onTap: onCopyJson,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SmallButton(
              icon: Icons.content_paste_rounded,
              label: 'Paste',
              onTap: onPasteJson,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SmallButton(
              icon: Icons.save_rounded,
              label: 'Save',
              filled: true,
              onTap: onSave,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardInspector extends StatelessWidget {
  const _CardInspector({
    required this.document,
    required this.onUpdateDocument,
  });

  final MBAdvancedCardDesignDocument document;
  final ValueChanged<MBAdvancedCardDesignDocument> onUpdateDocument;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        _SectionCard(
          title: 'Card layout',
          subtitle: 'Resize mode controls how elements respond to card size changes.',
          children: <Widget>[
            _ToggleRow(
              label: 'Lock elements to card size',
              value: document.lockElementsToCard,
              onChanged: (value) => onUpdateDocument(
                document.updateResizeMode(lockElementsToCard: value),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'ON: elements follow card size. OFF: card resizes while existing elements keep their visual position.',
                style: TextStyle(
                  color: Color(0xFF747B8A),
                  fontSize: 10.5,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _WidthPresetRow(
              currentWidth: document.cardWidth,
              onHalf: () => onUpdateDocument(
                document.resizeCardLayout(cardWidth: 192.0),
              ),
              onFull: () => onUpdateDocument(
                document.resizeCardLayout(cardWidth: 392.0),
              ),
            ),
            const SizedBox(height: 8),
            _NumberFieldRow(
              label: 'Width',
              value: document.cardWidth,
              min: 160,
              max: 420,
              decimals: 0,
              onChanged: (value) => onUpdateDocument(
                document.resizeCardLayout(cardWidth: value),
              ),
            ),
            _NumberFieldRow(
              label: 'Height',
              value: document.cardHeight,
              min: 220,
              max: 760,
              decimals: 0,
              onChanged: (value) => onUpdateDocument(
                document.resizeCardLayout(cardHeight: value),
              ),
            ),
            _NumberFieldRow(
              label: 'Radius',
              value: document.borderRadius,
              min: 0,
              max: 80,
              decimals: 0,
              onChanged: (value) => onUpdateDocument(
                document.resizeCardLayout(borderRadius: value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Card colors',
          subtitle: 'Quick swatches + manual hex entry.',
          children: <Widget>[
            _ColorFieldRow(
              label: 'Background 1',
              value: document.palette['backgroundHex']?.toString() ?? '#FF6500',
              onChanged: (value) => onUpdateDocument(
                document.updatePalette(<String, dynamic>{'backgroundHex': value}),
              ),
            ),
            _ColorFieldRow(
              label: 'Background 2',
              value:
                  document.palette['backgroundHex2']?.toString() ?? '#FF9A3D',
              onChanged: (value) => onUpdateDocument(
                document.updatePalette(<String, dynamic>{'backgroundHex2': value}),
              ),
            ),
            _ColorFieldRow(
              label: 'Surface',
              value: document.palette['surfaceHex']?.toString() ?? '#FFFFFF',
              onChanged: (value) => onUpdateDocument(
                document.updatePalette(<String, dynamic>{'surfaceHex': value}),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NodeInspector extends StatelessWidget {
  const _NodeInspector({
    super.key,
    required this.document,
    required this.node,
    required this.onUpdateNode,
    required this.onDeleteNode,
  });

  final MBAdvancedCardDesignDocument document;
  final MBAdvancedDesignNode node;
  final ValueChanged<MBAdvancedDesignNode> onUpdateNode;
  final ValueChanged<String> onDeleteNode;

  @override
  Widget build(BuildContext context) {
    final style = node.style;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        _SectionCard(
          title: 'Element',
          subtitle: 'Identity, binding, and variant-level settings.',
          children: <Widget>[
            _ReadOnlyInfoRow(label: 'Node ID', value: node.id),
            _ReadOnlyInfoRow(label: 'Element type', value: node.elementType),
            _TextInputRow(
              label: 'Variant',
              value: node.variantId,
              hintText: 'variant id',
              onSubmitted: (value) => onUpdateNode(node.copyWith(variantId: value)),
            ),
            _TextInputRow(
              label: 'Binding',
              value: node.binding,
              hintText: 'product.titleEn / product.finalPrice / static.badge',
              onSubmitted: (value) => onUpdateNode(node.copyWith(binding: value)),
            ),
            _TextInputRow(
              label: 'Label / text',
              value: _styleString(style, 'label', _styleString(style, 'text', '')),
              hintText: 'optional manual label override',
              onSubmitted: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'label': value})),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Position',
          subtitle: 'Normalized position on the card. Layer Z controls overlap priority.',
          children: <Widget>[
            _NumberFieldRow(
              label: 'X',
              value: node.position.x,
              min: 0,
              max: 1,
              decimals: 3,
              onChanged: (value) => onUpdateNode(
                node.copyWith(position: node.position.copyWith(x: value)),
              ),
            ),
            _NumberFieldRow(
              label: 'Y',
              value: node.position.y,
              min: 0,
              max: 1,
              decimals: 3,
              onChanged: (value) => onUpdateNode(
                node.copyWith(position: node.position.copyWith(y: value)),
              ),
            ),
            _NumberFieldRow(
              label: 'Layer Z',
              value: node.position.z.toDouble(),
              min: 0,
              max: 100,
              decimals: 0,
              onChanged: (value) => onUpdateNode(
                node.copyWith(position: node.position.copyWith(z: value.round())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Size',
          subtitle: 'Direct element footprint control. Resize keeps top-left anchored.',
          children: <Widget>[
            _NumberFieldRow(
              label: 'Width',
              value: node.size.width,
              min: 8,
              max: 420,
              decimals: 0,
              onChanged: (value) => onUpdateNode(
                _resizeNodeFromTopLeft(
                  node,
                  cardWidth: document.cardWidth,
                  cardHeight: document.cardHeight,
                  width: value,
                  height: node.size.height,
                ),
              ),
            ),
            _NumberFieldRow(
              label: 'Height',
              value: node.size.height,
              min: 4,
              max: 420,
              decimals: 0,
              onChanged: (value) => onUpdateNode(
                _resizeNodeFromTopLeft(
                  node,
                  cardWidth: document.cardWidth,
                  cardHeight: document.cardHeight,
                  width: node.size.width,
                  height: value,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Common style',
          subtitle: 'Core controls shared by most design elements.',
          children: <Widget>[
            _NumberFieldRow(
              label: 'Font size',
              value: _styleDouble(style, 'fontSize', 12),
              min: 6,
              max: 42,
              decimals: 1,
              onChanged: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'fontSize': value})),
              ),
            ),
            _NumberFieldRow(
              label: 'Radius',
              value: _styleDouble(style, 'borderRadius', 0),
              min: 0,
              max: 999,
              decimals: 0,
              onChanged: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'borderRadius': value})),
              ),
            ),
            _NumberFieldRow(
              label: 'Opacity',
              value: _styleDouble(style, 'opacity', 1),
              min: 0,
              max: 1,
              decimals: 2,
              onChanged: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'opacity': value})),
              ),
            ),
            _NumberFieldRow(
              label: 'Border width',
              value: _styleDouble(style, 'borderWidth', 1),
              min: 0,
              max: 16,
              decimals: 1,
              onChanged: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'borderWidth': value})),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Colors',
          subtitle: 'Use swatches or paste exact hex values.',
          children: <Widget>[
            _ColorFieldRow(
              label: 'Text',
              value: _styleString(style, 'textColorHex', '#FF6500'),
              onChanged: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'textColorHex': value})),
              ),
            ),
            _ColorFieldRow(
              label: 'Background',
              value: _styleString(style, 'backgroundHex', '#FFFFFF'),
              onChanged: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'backgroundHex': value})),
              ),
            ),
            _ColorFieldRow(
              label: 'Border',
              value: _styleString(style, 'borderHex', '#00000000'),
              onChanged: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'borderHex': value})),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Text / variant-specific',
          subtitle: 'Useful for text, chips, badges, buttons, and labels.',
          children: <Widget>[
            _TextInputRow(
              label: 'Prefix text',
              value: _styleString(style, 'prefixText', ''),
              hintText: 'ex: MRP ',
              onSubmitted: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'prefixText': value})),
              ),
            ),
            _TextInputRow(
              label: 'Suffix text',
              value: _styleString(style, 'suffixText', ''),
              hintText: 'ex: /kg',
              onSubmitted: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'suffixText': value})),
              ),
            ),
            _TextInputRow(
              label: 'Text align',
              value: _styleString(style, 'textAlign', 'center'),
              hintText: 'left / center / right',
              onSubmitted: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'textAlign': value})),
              ),
            ),
            _TextInputRow(
              label: 'Font weight',
              value: _styleString(style, 'fontWeight', 'w800'),
              hintText: 'w400 - w900',
              onSubmitted: (value) => onUpdateNode(
                node.copyWith(style: _patchStyle(style, <String, dynamic>{'fontWeight': value})),
              ),
            ),
          ],
        ),
        ..._buildTypeSpecificSections(style),
        if (node.elementType == 'mrp') ..._buildMrpStrikeSection(style),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'State',
          subtitle: 'Visibility, lock and delete.',
          children: <Widget>[
            _ToggleRow(
              label: 'Visible',
              value: node.visible,
              onChanged: (value) => onUpdateNode(node.copyWith(visible: value)),
            ),
            _ToggleRow(
              label: 'Locked',
              value: node.locked,
              onChanged: (value) => onUpdateNode(node.copyWith(locked: value)),
            ),
            const SizedBox(height: 8),
            _DangerButton(
              label: 'Delete element',
              onTap: () => onDeleteNode(node.id),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildTypeSpecificSections(Map<String, dynamic> style) {
    switch (node.elementType) {
      case 'title':
      case 'subtitle':
      case 'description':
      case 'brand':
      case 'category':
      case 'delivery':
      case 'unit':
      case 'feature':
      case 'savingText':
      case 'ribbon':
        return _buildTextElementSections(style);
      case 'media':
      case 'imageOverlay':
        return _buildMediaElementSections(style);
      case 'price':
      case 'priceBadge':
      case 'discount':
      case 'badge':
      case 'promoBadge':
      case 'flashBadge':
      case 'timer':
      case 'rating':
      case 'stock':
      case 'quantity':
        return _buildPriceBadgePromoSections(style);
      case 'cta':
      case 'secondaryCta':
        return _buildCtaElementSections(style);
      case 'wishlist':
      case 'compare':
      case 'share':
      case 'icon':
        return _buildIconElementSections(style);
      case 'progress':
      case 'dots':
        return _buildProgressIndicatorSections(style);
      case 'divider':
      case 'shape':
      case 'panel':
      case 'border':
      case 'effect':
      case 'shadow':
      case 'spacing':
      case 'animation':
        return _buildShapeEffectSections(style);
      default:
        return const <Widget>[];
    }
  }

  List<Widget> _buildTextElementSections(Map<String, dynamic> style) {
    return <Widget>[
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Text controls',
        subtitle: 'Controls only useful for title, subtitle, brand, category and text-like elements.',
        children: <Widget>[
          _NumberFieldRow(
            label: 'Max lines',
            value: _styleDouble(style, 'maxLines', node.elementType == 'title' ? 2 : 3),
            min: 1,
            max: 6,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'maxLines': value.round()})),
            ),
          ),
          _NumberFieldRow(
            label: 'Line height',
            value: _styleDouble(style, 'lineHeight', 1.05),
            min: 0.8,
            max: 2,
            decimals: 2,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'lineHeight': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Letter spacing',
            value: _styleDouble(style, 'letterSpacing', 0),
            min: -2,
            max: 6,
            decimals: 1,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'letterSpacing': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Padding X',
            value: _styleDouble(style, 'paddingX', 0),
            min: 0,
            max: 32,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'paddingX': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Padding Y',
            value: _styleDouble(style, 'paddingY', 0),
            min: 0,
            max: 24,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'paddingY': value})),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMediaElementSections(Map<String, dynamic> style) {
    return <Widget>[
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Media controls',
        subtitle: 'Image binding, fit, alignment, ring, crop and shadow controls.',
        children: <Widget>[
          _TextInputRow(
            label: 'Image fit',
            value: _styleString(style, 'imageFit', 'cover'),
            hintText: 'cover / contain / fill / fitWidth / fitHeight',
            onSubmitted: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'imageFit': value})),
            ),
          ),
          _TextInputRow(
            label: 'Image alignment',
            value: _styleString(style, 'imageAlignment', 'center'),
            hintText: 'center / topCenter / bottomCenter / left / right',
            onSubmitted: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'imageAlignment': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Image scale',
            value: _styleDouble(style, 'imageScale', 1),
            min: 0.5,
            max: 3,
            decimals: 2,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'imageScale': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Ring width',
            value: _styleDouble(style, 'ringWidth', 0),
            min: 0,
            max: 28,
            decimals: 1,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'ringWidth': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Shadow blur',
            value: _styleDouble(style, 'shadowBlur', 18),
            min: 0,
            max: 48,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'shadowBlur': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Shadow Y',
            value: _styleDouble(style, 'shadowOffsetY', 10),
            min: -12,
            max: 32,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'shadowOffsetY': value})),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildPriceBadgePromoSections(Map<String, dynamic> style) {
    return <Widget>[
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Price / badge / promo controls',
        subtitle: 'Controls for price badges, discount chips, timers, ratings and stock labels.',
        children: <Widget>[
          _TextInputRow(
            label: 'Currency symbol',
            value: _styleString(style, 'currencySymbol', '৳'),
            hintText: '৳ / Tk / BDT',
            onSubmitted: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'currencySymbol': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Decimal digits',
            value: _styleDouble(style, 'decimalDigits', 0),
            min: 0,
            max: 2,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'decimalDigits': value.round()})),
            ),
          ),
          _ToggleRow(
            label: 'Auto discount label',
            value: _styleBool(style, 'autoDiscountLabel', node.elementType == 'discount'),
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'autoDiscountLabel': value})),
            ),
          ),
          _TextInputRow(
            label: 'Icon text',
            value: _styleString(style, 'iconText', ''),
            hintText: 'ex: ⚡ / ★ / %',
            onSubmitted: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'iconText': value})),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildCtaElementSections(Map<String, dynamic> style) {
    return <Widget>[
      const SizedBox(height: 12),
      _SectionCard(
        title: 'CTA controls',
        subtitle: 'Action button behavior and button-style tuning.',
        children: <Widget>[
          _TextInputRow(
            label: 'Action type',
            value: _styleString(style, 'actionType', node.binding == 'action.details' ? 'details' : 'buy'),
            hintText: 'buy / addToCart / details / wishlist',
            onSubmitted: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'actionType': value})),
            ),
          ),
          _TextInputRow(
            label: 'Icon name',
            value: _styleString(style, 'iconName', ''),
            hintText: 'cart / bolt / eye / plus',
            onSubmitted: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'iconName': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Padding X',
            value: _styleDouble(style, 'paddingX', 10),
            min: 0,
            max: 40,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'paddingX': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Padding Y',
            value: _styleDouble(style, 'paddingY', 5),
            min: 0,
            max: 24,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'paddingY': value})),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildIconElementSections(Map<String, dynamic> style) {
    return <Widget>[
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Icon controls',
        subtitle: 'Wishlist, compare, share and custom icon tuning.',
        children: <Widget>[
          _TextInputRow(
            label: 'Icon name',
            value: _styleString(style, 'iconName', node.elementType),
            hintText: 'heart / compare / share / star',
            onSubmitted: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'iconName': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Icon size',
            value: _styleDouble(style, 'iconSize', 18),
            min: 8,
            max: 64,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'iconSize': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Hit padding',
            value: _styleDouble(style, 'hitPadding', 0),
            min: 0,
            max: 28,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'hitPadding': value})),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildProgressIndicatorSections(Map<String, dynamic> style) {
    return <Widget>[
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Progress / indicator controls',
        subtitle: 'Progress bar, stock bar and indicator dots controls.',
        children: <Widget>[
          _NumberFieldRow(
            label: 'Progress',
            value: _styleDouble(style, 'progress', 0.72),
            min: 0,
            max: 1,
            decimals: 2,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'progress': value})),
            ),
          ),
          _ColorFieldRow(
            label: 'Fill',
            value: _styleString(style, 'fillHex', '#FF6500'),
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'fillHex': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Dot count',
            value: _styleDouble(style, 'dotCount', 3),
            min: 1,
            max: 8,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'dotCount': value.round()})),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildShapeEffectSections(Map<String, dynamic> style) {
    return <Widget>[
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Shape / effect controls',
        subtitle: 'Panel, divider, border, glow, shadow, spacing and animation placeholders.',
        children: <Widget>[
          _NumberFieldRow(
            label: 'Effect strength',
            value: _styleDouble(style, 'effectStrength', 0.5),
            min: 0,
            max: 1,
            decimals: 2,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'effectStrength': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Blur',
            value: _styleDouble(style, 'blur', 0),
            min: 0,
            max: 48,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'blur': value})),
            ),
          ),
          _TextInputRow(
            label: 'Effect mode',
            value: _styleString(style, 'effectMode', node.elementType),
            hintText: 'glow / wave / flame / electric / pulse',
            onSubmitted: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'effectMode': value})),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMrpStrikeSection(Map<String, dynamic> style) {
    return <Widget>[
      const SizedBox(height: 12),
      _SectionCard(
        title: 'MRP strike / chip cross',
        subtitle: 'Old price strike appears only when sale price is lower unless manually forced.',
        children: <Widget>[
          _ToggleRow(
            label: 'Auto strike when discounted',
            value: _styleBool(style, 'autoStrikeWhenDiscounted', true),
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'autoStrikeWhenDiscounted': value})),
            ),
          ),
          _TextInputRow(
            label: 'Strike mode',
            value: _styleString(
              style,
              'strikeMode',
              node.variantId.contains('chip') ? 'cross' : 'lineThrough',
            ),
            hintText: 'lineThrough / horizontal / diagonal / cross',
            onSubmitted: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'strikeMode': value})),
            ),
          ),
          _ColorFieldRow(
            label: 'Strike color',
            value: _styleString(style, 'strikeColorHex', '#FF4A4A'),
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'strikeColorHex': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Strike thickness',
            value: _styleDouble(style, 'strikeThickness', 1.6),
            min: 0.5,
            max: 12,
            decimals: 1,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'strikeThickness': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Strike width factor',
            value: _styleDouble(style, 'strikeWidthFactor', 0.92),
            min: 0.1,
            max: 1.4,
            decimals: 2,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'strikeWidthFactor': value})),
            ),
          ),
          _NumberFieldRow(
            label: 'Strike angle',
            value: _styleDouble(style, 'strikeAngleDeg', -14),
            min: -45,
            max: 45,
            decimals: 0,
            onChanged: (value) => onUpdateNode(
              node.copyWith(style: _patchStyle(style, <String, dynamic>{'strikeAngleDeg': value})),
            ),
          ),
        ],
      ),
    ];
  }
}


class _WidthPresetRow extends StatelessWidget {
  const _WidthPresetRow({
    required this.currentWidth,
    required this.onHalf,
    required this.onFull,
  });

  final double currentWidth;
  final VoidCallback onHalf;
  final VoidCallback onFull;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _PresetButton(
            label: 'Half width',
            active: (currentWidth - 192.0).abs() < 1.0,
            onTap: onHalf,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PresetButton(
            label: 'Full width',
            active: (currentWidth - 392.0).abs() < 1.0,
            onTap: onFull,
          ),
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color(0xFFFF6500) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? const Color(0xFFFF6500) : const Color(0xFFE0E5EF),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF172033),
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFF6500),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF747B8A),
              fontSize: 10.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _ReadOnlyInfoRow extends StatelessWidget {
  const _ReadOnlyInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF747B8A),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextInputRow extends StatelessWidget {
  const _TextInputRow({
    required this.label,
    required this.value,
    required this.onSubmitted,
    this.hintText,
  });

  final String label;
  final String value;
  final String? hintText;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF172033),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            key: ValueKey<String>('${label}_${value}_${hintText ?? ''}'),
            initialValue: value,
            onFieldSubmitted: onSubmitted,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E5EF)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberFieldRow extends StatefulWidget {
  const _NumberFieldRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.decimals,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int decimals;
  final ValueChanged<double> onChanged;

  @override
  State<_NumberFieldRow> createState() => _NumberFieldRowState();
}

class _NumberFieldRowState extends State<_NumberFieldRow> {
  late final TextEditingController _controller;
  var _isEditingText = false;

  double get _clampedValue {
    return widget.value.clamp(widget.min, widget.max).toDouble();
  }

  String _format(double value) => value.toStringAsFixed(widget.decimals);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(_clampedValue));
  }

  @override
  void didUpdateWidget(covariant _NumberFieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = _format(_clampedValue);
    if (!_isEditingText && _controller.text != nextText) {
      _controller.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commitTextValue(String raw) {
    final parsed = double.tryParse(raw.trim());
    final nextValue = (parsed ?? _clampedValue)
        .clamp(widget.min, widget.max)
        .toDouble();
    final nextText = _format(nextValue);
    _isEditingText = false;
    _controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    widget.onChanged(nextValue);
  }

  void _applySliderValue(double value) {
    final nextValue = value.clamp(widget.min, widget.max).toDouble();
    final nextText = _format(nextValue);
    _isEditingText = false;
    if (_controller.text != nextText) {
      _controller.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }
    widget.onChanged(nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final clamped = _clampedValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(
                width: 76,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus && _isEditingText) {
                      _commitTextValue(_controller.text);
                    }
                  },
                  child: TextFormField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onTap: () => _isEditingText = true,
                    onChanged: (_) => _isEditingText = true,
                    onFieldSubmitted: _commitTextValue,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0E5EF)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: clamped,
            min: widget.min,
            max: widget.max,
            onChanged: _applySliderValue,
          ),
        ],
      ),
    );
  }
}

class _ColorFieldRow extends StatelessWidget {
  const _ColorFieldRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  static const List<String> _swatches = <String>[
    '#FFFFFF',
    '#FFF6EF',
    '#FFE8D4',
    '#FF6500',
    '#FF9A3D',
    '#FFD9B5',
    '#151922',
    '#172033',
    '#2D3648',
    '#EAFBF0',
    '#12803B',
    '#FF4A4A',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF172033),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _hexToColor(value),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD6DCE8)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  key: ValueKey(value),
                  initialValue: value,
                  onFieldSubmitted: onChanged,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _swatches
                .map(
                  (hex) => InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () => onChanged(hex),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _hexToColor(hex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: value.toUpperCase() == hex
                              ? const Color(0xFF172033)
                              : const Color(0xFFD6DCE8),
                          width: value.toUpperCase() == hex ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E5EF)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? const Color(0xFFFF6500) : const Color(0xFFFFF4EC);
    final fg = filled ? Colors.white : const Color(0xFFFF6500);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: const Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD93025),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


MBAdvancedDesignNode _resizeNodeFromTopLeft(
  MBAdvancedDesignNode node, {
  required double cardWidth,
  required double cardHeight,
  required double width,
  required double height,
}) {
  final safeCardWidth = cardWidth <= 0 ? 1.0 : cardWidth;
  final safeCardHeight = cardHeight <= 0 ? 1.0 : cardHeight;
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
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

Map<String, dynamic> _patchStyle(
  Map<String, dynamic> current,
  Map<String, dynamic> patch,
) {
  return <String, dynamic>{...current, ...patch};
}

double _styleDouble(Map<String, dynamic> style, String key, double fallback) {
  final value = style[key];
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

String _styleString(Map<String, dynamic> style, String key, String fallback) {
  final value = style[key]?.toString().trim();
  if (value == null || value.isEmpty) return fallback;
  return value;
}

bool _styleBool(Map<String, dynamic> style, String key, bool fallback) {
  final value = style[key];
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return fallback;
}

Color _hexToColor(String hex) {
  final normalized = hex.trim().replaceAll('#', '');
  final buffer = StringBuffer();
  if (normalized.length == 6) buffer.write('FF');
  buffer.write(normalized);
  if (buffer.length != 8) return const Color(0xFFFF6500);
  return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFFFF6500);
}

