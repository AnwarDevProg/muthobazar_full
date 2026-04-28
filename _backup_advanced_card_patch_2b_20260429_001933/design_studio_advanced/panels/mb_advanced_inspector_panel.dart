// MuthoBazar Advanced Product Card Design Studio
// Patch 1 right inspector panel.
//
// Purpose:
// - Shows card config when the card/background is selected.
// - Shows only applicable node config when a node is selected.
// - Supports position, size, layer, visibility, lock, and basic style edits.
// - Exposes JSON copy/paste/import/export/save actions.

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
      width: 318,
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
              isCardSelected
                  ? Icons.credit_card_rounded
                  : Icons.tune_rounded,
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
                  isCardSelected ? 'Card Inspector' : 'Selected Element',
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isCardSelected
                      ? 'Card size, radius and background'
                      : '${node!.elementType} · ${node!.variantId}',
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
        _SectionTitle(
          title: 'Card layout',
          subtitle: 'Empty canvas click selects this card config.',
        ),
        _NumberRow(
          label: 'Width',
          value: document.cardWidth,
          min: 160,
          max: 420,
          step: 10,
          onChanged: (value) => onUpdateDocument(
            document.updateLayout(<String, dynamic>{'cardWidth': value}),
          ),
        ),
        _NumberRow(
          label: 'Height',
          value: document.cardHeight,
          min: 220,
          max: 760,
          step: 10,
          onChanged: (value) => onUpdateDocument(
            document.updateLayout(<String, dynamic>{'cardHeight': value}),
          ),
        ),
        _NumberRow(
          label: 'Radius',
          value: document.borderRadius,
          min: 0,
          max: 80,
          step: 2,
          onChanged: (value) => onUpdateDocument(
            document.updateLayout(<String, dynamic>{'borderRadius': value}),
          ),
        ),
        const SizedBox(height: 18),
        _SectionTitle(
          title: 'Background',
          subtitle: 'Hex colors are saved into design JSON.',
        ),
        _TextFieldRow(
          label: 'Color 1',
          value: document.palette['backgroundHex']?.toString() ?? '#FF6500',
          onSubmitted: (value) => onUpdateDocument(
            document.updatePalette(<String, dynamic>{'backgroundHex': value}),
          ),
        ),
        _TextFieldRow(
          label: 'Color 2',
          value: document.palette['backgroundHex2']?.toString() ?? '#FF9A3D',
          onSubmitted: (value) => onUpdateDocument(
            document.updatePalette(<String, dynamic>{'backgroundHex2': value}),
          ),
        ),
        _TextFieldRow(
          label: 'Preset',
          value: document.palette['presetId']?.toString() ?? 'custom',
          onSubmitted: (value) => onUpdateDocument(
            document.updatePalette(<String, dynamic>{'presetId': value}),
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle(
          title: 'Document info',
          subtitle: 'Read-only identity for this design document.',
        ),
        _ReadOnlyInfo(label: 'Type', value: document.type),
        _ReadOnlyInfo(label: 'Version', value: document.version.toString()),
        _ReadOnlyInfo(label: 'Nodes', value: document.nodes.length.toString()),
      ],
    );
  }
}

class _NodeInspector extends StatelessWidget {
  const _NodeInspector({
    required this.node,
    required this.onUpdateNode,
    required this.onDeleteNode,
  });

  final MBAdvancedDesignNode node;
  final ValueChanged<MBAdvancedDesignNode> onUpdateNode;
  final ValueChanged<String> onDeleteNode;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        _SectionTitle(
          title: 'Element identity',
          subtitle: 'Element type and product data binding.',
        ),
        _ReadOnlyInfo(label: 'Element', value: node.elementType),
        _ReadOnlyInfo(label: 'Variant', value: node.variantId),
        _TextFieldRow(
          label: 'Binding',
          value: node.binding,
          onSubmitted: (value) => onUpdateNode(node.copyWith(binding: value)),
        ),
        const SizedBox(height: 18),
        const _SectionTitle(
          title: 'Position',
          subtitle: 'Normalized position. Keyboard control comes in Patch 3.',
        ),
        _NumberRow(
          label: 'X %',
          value: node.position.x * 100,
          min: 0,
          max: 100,
          step: 1,
          onChanged: (value) => onUpdateNode(
            node.copyWith(
              position: node.position.copyWith(x: (value / 100).clamp(0.0, 1.0)),
            ),
          ),
        ),
        _NumberRow(
          label: 'Y %',
          value: node.position.y * 100,
          min: 0,
          max: 100,
          step: 1,
          onChanged: (value) => onUpdateNode(
            node.copyWith(
              position: node.position.copyWith(y: (value / 100).clamp(0.0, 1.0)),
            ),
          ),
        ),
        _NumberRow(
          label: 'Layer',
          value: node.position.z.toDouble(),
          min: 0,
          max: 999,
          step: 1,
          onChanged: (value) => onUpdateNode(
            node.copyWith(
              position: node.position.copyWith(z: value.round()),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _SectionTitle(
          title: 'Size',
          subtitle: 'Width and height are stored in design pixels.',
        ),
        _NumberRow(
          label: 'Width',
          value: node.size.width,
          min: 12,
          max: 800,
          step: 4,
          onChanged: (value) => onUpdateNode(
            node.copyWith(size: node.size.copyWith(width: value)),
          ),
        ),
        _NumberRow(
          label: 'Height',
          value: node.size.height,
          min: 12,
          max: 800,
          step: 4,
          onChanged: (value) => onUpdateNode(
            node.copyWith(size: node.size.copyWith(height: value)),
          ),
        ),
        const SizedBox(height: 18),
        _SectionTitle(
          title: 'Style',
          subtitle: _styleSubtitleForNode(node.elementType),
        ),
        if (_hasTextStyle(node.elementType)) ...<Widget>[
          _NumberRow(
            label: 'Font size',
            value: _asDouble(node.style['fontSize'], 13),
            min: 6,
            max: 80,
            step: 1,
            onChanged: (value) => _updateStyle('fontSize', value),
          ),
          _DropdownRow(
            label: 'Weight',
            value: node.style['fontWeight']?.toString() ?? 'w900',
            values: const <String>['w400', 'w500', 'w600', 'w700', 'w800', 'w900'],
            onChanged: (value) => _updateStyle('fontWeight', value),
          ),
          _TextFieldRow(
            label: 'Text color',
            value: node.style['textColorHex']?.toString() ?? '#FFFFFF',
            onSubmitted: (value) => _updateStyle('textColorHex', value),
          ),
        ],
        if (_hasBoxStyle(node.elementType)) ...<Widget>[
          _TextFieldRow(
            label: 'Background',
            value: node.style['backgroundHex']?.toString() ?? '',
            onSubmitted: (value) => _updateStyle('backgroundHex', value),
          ),
          _TextFieldRow(
            label: 'Border',
            value: node.style['borderHex']?.toString() ?? '',
            onSubmitted: (value) => _updateStyle('borderHex', value),
          ),
          _NumberRow(
            label: 'Radius',
            value: _asDouble(node.style['borderRadius'], 0),
            min: 0,
            max: 999,
            step: 2,
            onChanged: (value) => _updateStyle('borderRadius', value),
          ),
        ],
        if (node.elementType == 'media')
          _NumberRow(
            label: 'Ring',
            value: _asDouble(node.style['ringWidth'], 0),
            min: 0,
            max: 40,
            step: 1,
            onChanged: (value) => _updateStyle('ringWidth', value),
          ),
        if (node.elementType == 'badge')
          _TextFieldRow(
            label: 'Label',
            value: node.style['label']?.toString() ?? 'HOT',
            onSubmitted: (value) => _updateStyle('label', value),
          ),
        const SizedBox(height: 18),
        const _SectionTitle(
          title: 'State',
          subtitle: 'Basic visibility and lock flags.',
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: node.visible,
          title: const Text(
            'Visible',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          onChanged: (value) => onUpdateNode(node.copyWith(visible: value)),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: node.locked,
          title: const Text(
            'Locked',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          onChanged: (value) => onUpdateNode(node.copyWith(locked: value)),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE93B3B),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(42),
          ),
          onPressed: () => onDeleteNode(node.id),
          icon: const Icon(Icons.delete_rounded, size: 18),
          label: const Text('Delete selected element'),
        ),
      ],
    );
  }

  void _updateStyle(String key, Object? value) {
    onUpdateNode(
      node.copyWith(
        style: <String, dynamic>{
          ...node.style,
          key: value,
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF172033),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF747B8A),
              fontSize: 10.5,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyInfo extends StatelessWidget {
  const _ReadOnlyInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E8EF)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF747B8A),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberRow extends StatelessWidget {
  const _NumberRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(min, max).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _IconStepButton(
            icon: Icons.remove_rounded,
            onTap: () => onChanged((normalized - step).clamp(min, max).toDouble()),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              key: ValueKey<String>('${label}_${normalized.toStringAsFixed(2)}'),
              initialValue: normalized.toStringAsFixed(
                normalized == normalized.roundToDouble() ? 0 : 1,
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
              decoration: _inputDecoration(),
              onFieldSubmitted: (text) {
                final parsed = double.tryParse(text.trim());
                if (parsed == null) return;
                onChanged(parsed.clamp(min, max).toDouble());
              },
            ),
          ),
          const SizedBox(width: 6),
          _IconStepButton(
            icon: Icons.add_rounded,
            onTap: () => onChanged((normalized + step).clamp(min, max).toDouble()),
          ),
        ],
      ),
    );
  }
}

class _TextFieldRow extends StatelessWidget {
  const _TextFieldRow({
    required this.label,
    required this.value,
    required this.onSubmitted,
  });

  final String label;
  final String value;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              key: ValueKey<String>('${label}_$value'),
              initialValue: value,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              decoration: _inputDecoration(),
              onFieldSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = values.contains(value) ? value : values.last;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: safeValue,
              decoration: _inputDecoration(),
              items: <DropdownMenuItem<String>>[
                for (final item in values)
                  DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                onChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _IconStepButton extends StatelessWidget {
  const _IconStepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF3EA),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 34,
          child: Icon(icon, color: const Color(0xFFFF6500), size: 17),
        ),
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
    return Material(
      color: filled ? const Color(0xFFFF6500) : const Color(0xFFFFF3EA),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 15,
                color: filled ? Colors.white : const Color(0xFFFF6500),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: filled ? Colors.white : const Color(0xFFFF6500),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    filled: true,
    fillColor: const Color(0xFFF7F8FB),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xFFE6E8EF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xFFE6E8EF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(color: Color(0xFFFF6500)),
    ),
  );
}

String _styleSubtitleForNode(String elementType) {
  switch (elementType) {
    case 'title':
    case 'subtitle':
      return 'Text style and optional chip background.';
    case 'media':
      return 'Image radius, border and ring.';
    case 'price':
    case 'cta':
    case 'badge':
      return 'Badge/button text and container style.';
    default:
      return 'Applicable style fields.';
  }
}

bool _hasTextStyle(String elementType) {
  return elementType == 'title' ||
      elementType == 'subtitle' ||
      elementType == 'price' ||
      elementType == 'cta' ||
      elementType == 'badge';
}

bool _hasBoxStyle(String elementType) {
  return elementType == 'title' ||
      elementType == 'subtitle' ||
      elementType == 'media' ||
      elementType == 'price' ||
      elementType == 'cta' ||
      elementType == 'badge';
}

double _asDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}
