import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../models/mb_store_card_preview_entry.dart';

class StoreCardAddDialog extends StatefulWidget {
  const StoreCardAddDialog({
    super.key,
    required this.products,
    this.sectionKey,
    this.nextSortOrder,
    this.title = 'Add product card',
    this.confirmText = 'Add',
  });

  final List<MBProduct> products;
  final String? sectionKey;
  final int? nextSortOrder;
  final String title;
  final String confirmText;

  static Future<MBStoreCardPreviewEntry?> show(
      BuildContext context, {
        required List<MBProduct> products,
        String? sectionKey,
        int? nextSortOrder,
        String title = 'Add product card',
        String confirmText = 'Add',
      }) {
    return showDialog<MBStoreCardPreviewEntry>(
      context: context,
      builder: (_) => StoreCardAddDialog(
        products: products,
        sectionKey: sectionKey,
        nextSortOrder: nextSortOrder,
        title: title,
        confirmText: confirmText,
      ),
    );
  }

  @override
  State<StoreCardAddDialog> createState() => _StoreCardAddDialogState();
}

class _StoreCardAddDialogState extends State<StoreCardAddDialog> {
  int? _selectedProductIndex;
  MBProductCardLayout? _selectedLayout;

  List<MBProductCardLayout> get _layouts {
    final layouts = MBProductCardRenderer.availableLayouts;
    return List<MBProductCardLayout>.from(layouts);
  }

  MBProduct? get _selectedProduct {
    final index = _selectedProductIndex;
    if (index == null) {
      return null;
    }
    if (index < 0 || index >= widget.products.length) {
      return null;
    }
    return widget.products[index];
  }

  bool get _canSubmit => _selectedProduct != null && _selectedLayout != null;

  @override
  void initState() {
    super.initState();
    if (widget.products.isNotEmpty) {
      _selectedProductIndex = 0;
    }
    if (_layouts.isNotEmpty) {
      _selectedLayout = _layouts.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedProduct = _selectedProduct;
    final selectedLayout = _selectedLayout;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<int>(
              initialValue: _selectedProductIndex,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(),
              ),
              items: List<DropdownMenuItem<int>>.generate(
                widget.products.length,
                    (index) {
                  final product = widget.products[index];
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(_productLabel(product)),
                  );
                },
              ),
              onChanged: widget.products.isEmpty
                  ? null
                  : (value) {
                setState(() {
                  _selectedProductIndex = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MBProductCardLayout>(
              initialValue: _selectedLayout,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Card type',
                border: OutlineInputBorder(),
              ),
              items: _layouts
                  .map(
                    (layout) => DropdownMenuItem<MBProductCardLayout>(
                  value: layout,
                  child: Text(_layoutLabel(layout)),
                ),
              )
                  .toList(),
              onChanged: _layouts.isEmpty
                  ? null
                  : (value) {
                setState(() {
                  _selectedLayout = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _SelectionSummaryCard(
              productLabel: selectedProduct == null
                  ? 'No product selected'
                  : _productLabel(selectedProduct),
              layoutLabel: selectedLayout == null
                  ? 'No card type selected'
                  : _layoutLabel(selectedLayout),
              layoutFootprint: selectedLayout == null
                  ? 'Unknown size'
                  : _footprintLabel(selectedLayout),
            ),
            if (widget.products.isEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                'No products available yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(widget.confirmText),
        ),
      ],
    );
  }

  void _submit() {
    final selectedProduct = _selectedProduct;
    final selectedLayout = _selectedLayout;
    if (selectedProduct == null || selectedLayout == null) {
      return;
    }

    Navigator.of(context).pop(
      MBStoreCardPreviewEntry.create(
        productId: _productId(selectedProduct),
        layout: selectedLayout,
        sectionKey: widget.sectionKey,
        sortOrder: widget.nextSortOrder,
      ),
    );
  }

  String _layoutLabel(MBProductCardLayout layout) {
    return MBProductCardRenderer.previewFallbackLabelFor(layout);
  }

  String _footprintLabel(MBProductCardLayout layout) {
    switch (layout) {
      case MBProductCardLayout.compact:
      case MBProductCardLayout.featured:
      case MBProductCardLayout.card03:
        return 'Full width';
      default:
        return 'Half width';
    }
  }

  String _productId(MBProduct product) {
    if (product.id.trim().isNotEmpty) {
      return product.id.trim();
    }
    if (product.slug.trim().isNotEmpty) {
      return product.slug.trim();
    }
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  String _productLabel(MBProduct product) {
    if (product.titleEn.trim().isNotEmpty) {
      return product.titleEn.trim();
    }
    if (product.titleBn.trim().isNotEmpty) {
      return product.titleBn.trim();
    }
    if ((product.productCode ?? '').trim().isNotEmpty) {
      return product.productCode!.trim();
    }
    if ((product.sku ?? '').trim().isNotEmpty) {
      return product.sku!.trim();
    }
    if (product.slug.trim().isNotEmpty) {
      return product.slug.trim();
    }
    if (product.id.trim().isNotEmpty) {
      return product.id.trim();
    }
    return 'Unnamed product';
  }
}

class _SelectionSummaryCard extends StatelessWidget {
  const _SelectionSummaryCard({
    required this.productLabel,
    required this.layoutLabel,
    required this.layoutFootprint,
  });

  final String productLabel;
  final String layoutLabel;
  final String layoutFootprint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Selection summary',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Product', value: productLabel),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Card type', value: layoutLabel),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Footprint', value: layoutFootprint),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
