import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/mb_design_node.dart';
import '../models/mb_design_node_variant.dart';

// MuthoBazar Design Studio V2 Inspector Panel
// ------------------------------------------
// Right panel.
// Patch 1 supports card config, selected node config, and JSON copy/paste.
// Later patches will replace generic fields with element-specific inspectors.

class MBDesignInspectorPanel extends StatelessWidget {
  const MBDesignInspectorPanel({
    super.key,
    required this.document,
    required this.onUpdateDocument,
    required this.onUpdateNode,
    required this.onDeleteNode,
    required this.onCopyJson,
    required this.onPasteJson,
    required this.onSave,
  });

  final MBDesignDocument document;
  final ValueChanged<MBDesignDocument> onUpdateDocument;
  final ValueChanged<MBDesignNode> onUpdateNode;
  final ValueChanged<String> onDeleteNode;
  final VoidCallback onCopyJson;
  final VoidCallback onPasteJson;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final node = document.selectedNode;

    return Container(
      width: 340,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          left: BorderSide(color: Color(0xFFE6E8EF)),
        ),
      ),
      child: Column(
        children: [
          _PanelHeader(
            icon: Icons.tune_rounded,
            title: node == null ? 'Card Inspector' : 'Element Inspector',
            subtitle: node == null
                ? 'Selected: card'
                : 'Selected: ${node.elementType} · ${node.variantId}',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              children: [
                if (node == null)
                  _CardInspector(
                    document: document,
                    onUpdateDocument: onUpdateDocument,
                  )
                else
                  _NodeInspector(
                    node: node,
                    onUpdateNode: onUpdateNode,
                    onDeleteNode: onDeleteNode,
                  ),
                const SizedBox(height: 16),
                _JsonActions(
                  onCopyJson: onCopyJson,
                  onPasteJson: onPasteJson,
                  onSave: onSave,
                ),
                const SizedBox(height: 10),
                _CodeBox(document.toPrettyJson()),
              ],
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

  final MBDesignDocument document;
  final ValueChanged<MBDesignDocument> onUpdateDocument;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Card layout'),
        _NumberSlider(
          label: 'Card width',
          value: document.cardWidth,
          min: 170,
          max: 330,
          divisions: 64,
          onChanged: (value) => _updateLayout('cardWidth', value),
        ),
        _NumberSlider(
          label: 'Aspect ratio',
          value: document.aspectRatio,
          min: 0.42,
          max: 0.90,
          divisions: 48,
          decimals: 2,
          onChanged: (value) => _updateLayout('aspectRatio', value),
        ),
        _NumberSlider(
          label: 'Min height',
          value: document.minHeight,
          min: 240,
          max: 600,
          divisions: 72,
          onChanged: (value) => _updateLayout('minHeight', value),
        ),
        _NumberSlider(
          label: 'Max height',
          value: document.maxHeight,
          min: 280,
          max: 760,
          divisions: 96,
          onChanged: (value) => _updateLayout('maxHeight', value),
        ),
        const SizedBox(height: 14),
        _SectionLabel('Selection'),
        const Text(
          'Click any empty place on the preview card to select the card itself. '
          'Click an element to inspect it.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            height: 1.32,
          ),
        ),
      ],
    );
  }

  void _updateLayout(String key, double value) {
    onUpdateDocument(
      document.copyWith(
        layout: <String, Object?>{
          ...document.layout,
          key: value,
        },
      ),
    );
  }
}

class _NodeInspector extends StatelessWidget {
  const _NodeInspector({
    required this.node,
    required this.onUpdateNode,
    required this.onDeleteNode,
  });

  final MBDesignNode node;
  final ValueChanged<MBDesignNode> onUpdateNode;
  final ValueChanged<String> onDeleteNode;

  @override
  Widget build(BuildContext context) {
    final variants = MBDesignNodeVariantRegistry.byElementType(
      node.elementType,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Element'),
        _ReadonlyValue(label: 'Node ID', value: node.id),
        _ReadonlyValue(
          label: 'Element type',
          value: MBDesignNodeVariantRegistry.labelForElementType(
            node.elementType,
          ),
        ),
        const SizedBox(height: 8),
        if (variants.isNotEmpty)
          DropdownButtonFormField<String>(
            initialValue: variants.any((item) => item.id == node.variantId)
                ? node.variantId
                : variants.first.id,
            decoration: _inputDecoration('Variant'),
            items: [
              for (final variant in variants)
                DropdownMenuItem(
                  value: variant.id,
                  child: Text(variant.label),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              onUpdateNode(node.copyWith(variantId: value));
            },
          ),
        const SizedBox(height: 14),
        _SectionLabel('Position'),
        _NumberSlider(
          label: 'X',
          value: node.position.x,
          min: 0,
          max: 1,
          divisions: 100,
          decimals: 3,
          onChanged: (value) {
            onUpdateNode(
              node.copyWith(
                position: node.position.copyWith(x: value),
              ),
            );
          },
        ),
        _NumberSlider(
          label: 'Y',
          value: node.position.y,
          min: 0,
          max: 1,
          divisions: 100,
          decimals: 3,
          onChanged: (value) {
            onUpdateNode(
              node.copyWith(
                position: node.position.copyWith(y: value),
              ),
            );
          },
        ),
        _NumberSlider(
          label: 'Layer Z',
          value: node.position.z.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            onUpdateNode(
              node.copyWith(
                position: node.position.copyWith(z: value.round()),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        _SectionLabel('Size'),
        _NumberSlider(
          label: 'Width',
          value: node.size.width ?? _defaultWidth(node.elementType),
          min: 20,
          max: 260,
          divisions: 120,
          onChanged: (value) {
            onUpdateNode(
              node.copyWith(
                size: node.size.copyWith(width: value),
              ),
            );
          },
        ),
        _NumberSlider(
          label: 'Height',
          value: node.size.height ?? _defaultHeight(node.elementType),
          min: 20,
          max: 260,
          divisions: 120,
          onChanged: (value) {
            onUpdateNode(
              node.copyWith(
                size: node.size.copyWith(height: value),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        _SectionLabel('Quick style'),
        _StyleTextField(
          label: 'Text color HEX',
          value: node.style['textColorHex']?.toString() ?? '',
          hint: '#FFFFFF',
          onChanged: (value) => _setStyle('textColorHex', value),
        ),
        _StyleTextField(
          label: 'Background HEX',
          value: node.style['backgroundHex']?.toString() ?? '',
          hint: '#FF6500',
          onChanged: (value) => _setStyle('backgroundHex', value),
        ),
        _StyleTextField(
          label: 'Border / ring HEX',
          value: node.style['borderHex']?.toString() ?? '',
          hint: '#FFFFFF',
          onChanged: (value) => _setStyle('borderHex', value),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF6500),
            foregroundColor: Colors.white,
          ),
          onPressed: () => onDeleteNode(node.id),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Delete element'),
        ),
      ],
    );
  }

  void _setStyle(String key, String value) {
    final normalized = value.trim();
    final nextStyle = <String, Object?>{
      ...node.style,
    };

    if (normalized.isEmpty) {
      nextStyle.remove(key);
    } else {
      nextStyle[key] = normalized;
    }

    onUpdateNode(node.copyWith(style: nextStyle));
  }

  double _defaultWidth(String elementType) {
    return switch (elementType) {
      'media' => 160,
      'priceBadge' => 58,
      'secondaryCta' || 'primaryCta' => 70,
      'deliveryHint' || 'timer' => 110,
      _ => 150,
    };
  }

  double _defaultHeight(String elementType) {
    return switch (elementType) {
      'media' => 160,
      'priceBadge' => 58,
      'secondaryCta' || 'primaryCta' => 32,
      'deliveryHint' || 'timer' => 26,
      'subtitle' => 44,
      _ => 34,
    };
  }
}

class _JsonActions extends StatelessWidget {
  const _JsonActions({
    required this.onCopyJson,
    required this.onPasteJson,
    required this.onSave,
  });

  final VoidCallback onCopyJson;
  final VoidCallback onPasteJson;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: onCopyJson,
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copy JSON'),
        ),
        OutlinedButton.icon(
          onPressed: onPasteJson,
          icon: const Icon(Icons.paste_rounded),
          label: const Text('Paste JSON'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF6500),
            foregroundColor: Colors.white,
          ),
          onPressed: onSave,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Use design'),
        ),
      ],
    );
  }
}

class _NumberSlider extends StatelessWidget {
  const _NumberSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.decimals = 0,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final int decimals;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(min, max).toDouble();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 8, 4),
          child: Column(
            children: [
              Row(
                children: [
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
                  Text(
                    decimals == 0
                        ? safeValue.toStringAsFixed(0)
                        : safeValue.toStringAsFixed(decimals),
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Slider(
                value: safeValue,
                min: min,
                max: max,
                divisions: divisions,
                activeColor: const Color(0xFFFF6500),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyleTextField extends StatelessWidget {
  const _StyleTextField({
    required this.label,
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  final String label;
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        key: ValueKey('$label-$value'),
        initialValue: value,
        decoration: _inputDecoration(label).copyWith(hintText: hint),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9#]')),
          LengthLimitingTextInputFormatter(9),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ReadonlyValue extends StatelessWidget {
  const _ReadonlyValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7A7F8D),
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
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8EF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SelectableText(
          text,
          style: const TextStyle(
            color: Color(0xFF172033),
            fontSize: 10.5,
            height: 1.25,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6500)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF747B8A),
                    fontSize: 11,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFFF6500),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    isDense: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  );
}
