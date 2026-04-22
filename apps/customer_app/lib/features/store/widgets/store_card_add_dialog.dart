import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

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
  static const List<_StoreCardVariantOption> _variantOptions =
  <_StoreCardVariantOption>[
    _StoreCardVariantOption(
      variant: MBCardVariant.compact01,
      title: 'compact01',
      description: 'Everyday dense grid card',
      footprintLabel: 'Half width',
    ),
    _StoreCardVariantOption(
      variant: MBCardVariant.compact02,
      title: 'compact02',
      description: 'Structured compact grid card',
      footprintLabel: 'Half width',
    ),
    _StoreCardVariantOption(
      variant: MBCardVariant.price01,
      title: 'price01',
      description: 'Deal-first price card',
      footprintLabel: 'Half width',
    ),
    _StoreCardVariantOption(
      variant: MBCardVariant.horizontal01,
      title: 'horizontal01',
      description: 'Row-style quick scan card',
      footprintLabel: 'Full width',
    ),
    _StoreCardVariantOption(
      variant: MBCardVariant.premium01,
      title: 'premium01',
      description: 'Clean premium product card',
      footprintLabel: 'Half width',
    ),
    _StoreCardVariantOption(
      variant: MBCardVariant.wide01,
      title: 'wide01',
      description: 'Image-led wide anchor card',
      footprintLabel: 'Full width',
    ),
    _StoreCardVariantOption(
      variant: MBCardVariant.featured01,
      title: 'featured01',
      description: 'Hero featured product card',
      footprintLabel: 'Full width',
    ),
    _StoreCardVariantOption(
      variant: MBCardVariant.promo01,
      title: 'promo01',
      description: 'Campaign / promo product card',
      footprintLabel: 'Full width',
    ),
    _StoreCardVariantOption(
      variant: MBCardVariant.flash01,
      title: 'flash01',
      description: 'High-urgency flash sale card',
      footprintLabel: 'Half width',
    ),
  ];

  int? _selectedProductIndex;
  MBCardVariant? _selectedVariant;

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

  _StoreCardVariantOption? get _selectedOption {
    final variant = _selectedVariant;
    if (variant == null) {
      return null;
    }

    for (final option in _variantOptions) {
      if (option.variant == variant) {
        return option;
      }
    }
    return null;
  }

  bool get _canSubmit => _selectedProduct != null && _selectedOption != null;

  @override
  void initState() {
    super.initState();
    if (widget.products.isNotEmpty) {
      _selectedProductIndex = 0;
    }
    if (_variantOptions.isNotEmpty) {
      _selectedVariant = _variantOptions.first.variant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedProduct = _selectedProduct;
    final selectedOption = _selectedOption;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 460,
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
            DropdownButtonFormField<MBCardVariant>(
              initialValue: _selectedVariant,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Card type',
                border: OutlineInputBorder(),
              ),
              items: _variantOptions
                  .map(
                    (option) => DropdownMenuItem<MBCardVariant>(
                  value: option.variant,
                  child: Text(option.title),
                ),
              )
                  .toList(growable: false),
              onChanged: _variantOptions.isEmpty
                  ? null
                  : (value) {
                setState(() {
                  _selectedVariant = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _SelectionSummaryCard(
              productLabel: selectedProduct == null
                  ? 'No product selected'
                  : _productLabel(selectedProduct),
              variantLabel: selectedOption == null
                  ? 'No card type selected'
                  : selectedOption.title,
              footprintLabel: selectedOption == null
                  ? 'Unknown size'
                  : selectedOption.footprintLabel,
              description: selectedOption?.description,
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
    final selectedOption = _selectedOption;
    if (selectedProduct == null || selectedOption == null) {
      return;
    }

    Navigator.of(context).pop(
      MBStoreCardPreviewEntry.create(
        productId: _productId(selectedProduct),
        variantId: selectedOption.variant.id,
        sectionKey: widget.sectionKey,
        sortOrder: widget.nextSortOrder,
      ),
    );
  }

  String _productId(MBProduct product) {
    final id = product.id.trim();
    if (id.isNotEmpty) {
      return id;
    }

    final slug = product.slug.trim();
    if (slug.isNotEmpty) {
      return slug;
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
    if (product.slug.trim().isNotEmpty) {
      return product.slug.trim();
    }

    final id = product.id.trim();
    if (id.isNotEmpty) {
      return id;
    }

    return 'Unnamed product';
  }
}

class _SelectionSummaryCard extends StatelessWidget {
  const _SelectionSummaryCard({
    required this.productLabel,
    required this.variantLabel,
    required this.footprintLabel,
    this.description,
  });

  final String productLabel;
  final String variantLabel;
  final String footprintLabel;
  final String? description;

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
          _SummaryRow(label: 'Variant', value: variantLabel),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Footprint', value: footprintLabel),
          if (description != null && description!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            _SummaryRow(label: 'Style', value: description!.trim()),
          ],
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

class _StoreCardVariantOption {
  const _StoreCardVariantOption({
    required this.variant,
    required this.title,
    required this.description,
    required this.footprintLabel,
  });

  final MBCardVariant variant;
  final String title;
  final String description;
  final String footprintLabel;
}