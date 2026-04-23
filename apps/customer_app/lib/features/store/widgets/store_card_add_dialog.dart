import 'package:customer_app/features/store/models/mb_store_card_preview_entry.dart';
import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

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
  late final List<_StoreCardFamilyOption> _familyOptions;

  int? _selectedProductIndex;
  MBCardFamily? _selectedFamily;
  MBCardVariant? _selectedVariant;

  MBProduct? get _selectedProduct {
    final index = _selectedProductIndex;
    if (index == null || index < 0 || index >= widget.products.length) {
      return null;
    }
    return widget.products[index];
  }

  _StoreCardFamilyOption? get _selectedFamilyOption {
    final family = _selectedFamily;
    if (family == null) {
      return null;
    }

    for (final option in _familyOptions) {
      if (option.family == family) {
        return option;
      }
    }
    return null;
  }

  List<_StoreCardVariantOption> get _visibleVariants {
    return _selectedFamilyOption?.variants ?? const <_StoreCardVariantOption>[];
  }

  _StoreCardVariantOption? get _selectedVariantOption {
    final variant = _selectedVariant;
    if (variant == null) {
      return null;
    }

    for (final option in _visibleVariants) {
      if (option.variant == variant) {
        return option;
      }
    }
    return null;
  }

  bool get _canSubmit => _selectedProduct != null && _selectedVariantOption != null;

  @override
  void initState() {
    super.initState();

    _familyOptions = _buildFamilyOptions();

    if (widget.products.isNotEmpty) {
      _selectedProductIndex = 0;
    }

    if (_familyOptions.isNotEmpty) {
      _selectedFamily = _familyOptions.first.family;
      if (_familyOptions.first.variants.isNotEmpty) {
        _selectedVariant = _familyOptions.first.variants.first.variant;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final insets = MediaQuery.viewInsetsOf(context);

    final selectedProduct = _selectedProduct;
    final selectedFamily = _selectedFamilyOption;
    final selectedVariant = _selectedVariantOption;

    final maxDialogWidth = media.width < 560 ? media.width - 24 : 520.0;
    final maxDialogHeight = media.height * 0.82;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxDialogWidth,
            maxHeight: maxDialogHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                child: Text(
                                  _productLabel(product),
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                        Text(
                          'Choose family',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: _familyOptions
                              .map(
                                (option) => ChoiceChip(
                              label: Text(option.title),
                              selected: _selectedFamily == option.family,
                              onSelected: (_) => _selectFamily(option.family),
                            ),
                          )
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          selectedFamily == null
                              ? 'Choose variant'
                              : 'Choose variant in ${selectedFamily.title}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<MBCardVariant>(
                          initialValue: _selectedVariant,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Variant',
                            border: OutlineInputBorder(),
                          ),
                          items: _visibleVariants
                              .map(
                                (option) => DropdownMenuItem<MBCardVariant>(
                              value: option.variant,
                              child: Text(
                                '${option.title} • ${option.footprintLabel}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                              .toList(growable: false),
                          onChanged: _visibleVariants.isEmpty
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
                          familyLabel: selectedFamily?.title ?? 'No family selected',
                          variantLabel:
                          selectedVariant?.title ?? 'No variant selected',
                          footprintLabel:
                          selectedVariant?.footprintLabel ?? 'Unknown size',
                          description: selectedVariant?.description,
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
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _canSubmit ? _submit : null,
                        child: Text(widget.confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_StoreCardFamilyOption> _buildFamilyOptions() {
    const familyTitles = <MBCardFamily, String>{
      MBCardFamily.compact: 'Compact',
      MBCardFamily.price: 'Price',
      MBCardFamily.horizontal: 'Horizontal',
      MBCardFamily.premium: 'Premium',
      MBCardFamily.wide: 'Wide',
      MBCardFamily.featured: 'Featured',
      MBCardFamily.promo: 'Promo',
      MBCardFamily.flashSale: 'FlashSale',
    };

    const familyOrder = <MBCardFamily>[
      MBCardFamily.compact,
      MBCardFamily.price,
      MBCardFamily.horizontal,
      MBCardFamily.premium,
      MBCardFamily.wide,
      MBCardFamily.featured,
      MBCardFamily.promo,
      MBCardFamily.flashSale,
    ];

    final grouped = <MBCardFamily, List<_StoreCardVariantOption>>{};

    for (final variant in MBCardVariant.values) {
      grouped.putIfAbsent(variant.family, () => <_StoreCardVariantOption>[]).add(
        _StoreCardVariantOption(
          variant: variant,
          title: variant.id,
          description: _variantDescription(variant),
          footprintLabel: variant.isFullWidth ? 'Full width' : 'Half width',
        ),
      );
    }

    final result = <_StoreCardFamilyOption>[];

    for (final family in familyOrder) {
      final variants = grouped[family] ?? <_StoreCardVariantOption>[];
      variants.sort(
            (a, b) => a.variant.id.compareTo(b.variant.id),
      );

      result.add(
        _StoreCardFamilyOption(
          family: family,
          title: familyTitles[family] ?? family.id,
          variants: List<_StoreCardVariantOption>.unmodifiable(variants),
        ),
      );
    }

    return List<_StoreCardFamilyOption>.unmodifiable(result);
  }

  void _selectFamily(MBCardFamily family) {
    final familyOption = _familyOptions.firstWhere(
          (option) => option.family == family,
    );

    setState(() {
      _selectedFamily = family;

      final currentVariant = _selectedVariant;
      final stillValid = familyOption.variants.any(
            (option) => option.variant == currentVariant,
      );

      if (!stillValid) {
        _selectedVariant = familyOption.variants.isEmpty
            ? null
            : familyOption.variants.first.variant;
      }
    });
  }

  void _submit() {
    final selectedProduct = _selectedProduct;
    final selectedVariant = _selectedVariantOption;

    if (selectedProduct == null || selectedVariant == null) {
      return;
    }

    Navigator.of(context).pop(
      MBStoreCardPreviewEntry.create(
        productId: _productId(selectedProduct),
        variantId: selectedVariant.variant.id,
        sectionKey: widget.sectionKey,
        sortOrder: widget.nextSortOrder,
      ),
    );
  }

  String _variantDescription(MBCardVariant variant) {
    switch (variant.family) {
      case MBCardFamily.compact:
        return 'Compact family product card';
      case MBCardFamily.price:
        return 'Price-focused family product card';
      case MBCardFamily.horizontal:
        return 'Horizontal row product card';
      case MBCardFamily.premium:
        return 'Premium family product card';
      case MBCardFamily.wide:
        return 'Wide image-led product card';
      case MBCardFamily.featured:
        return 'Featured hero-style product card';
      case MBCardFamily.promo:
        return 'Promo campaign product card';
      case MBCardFamily.flashSale:
        return 'Flash-sale urgency product card';
      case MBCardFamily.combo:
        return 'Combo bundle product card';
      case MBCardFamily.variant:
        return 'Variant-focused product card';
      case MBCardFamily.minimal:
        return 'Minimal lightweight product card';
      case MBCardFamily.infoRich:
        return 'Info-rich detailed product card';
    }
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
    final titleEn = product.titleEn.trim();
    if (titleEn.isNotEmpty) {
      return titleEn;
    }

    final titleBn = product.titleBn.trim();
    if (titleBn.isNotEmpty) {
      return titleBn;
    }

    final slug = product.slug.trim();
    if (slug.isNotEmpty) {
      return slug;
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
    required this.familyLabel,
    required this.variantLabel,
    required this.footprintLabel,
    this.description,
  });

  final String productLabel;
  final String familyLabel;
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
          _SummaryRow(label: 'Family', value: familyLabel),
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

class _StoreCardFamilyOption {
  const _StoreCardFamilyOption({
    required this.family,
    required this.title,
    required this.variants,
  });

  final MBCardFamily family;
  final String title;
  final List<_StoreCardVariantOption> variants;
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