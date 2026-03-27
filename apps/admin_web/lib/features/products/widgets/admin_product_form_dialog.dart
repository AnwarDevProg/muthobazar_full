import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_ui/shared_ui.dart';
import '../../../../models/catalog/mb_product.dart';
import '../../../../models/catalog/mb_product_attribute.dart';
import '../../../../models/catalog/mb_product_purchase_option.dart';
import '../../../../models/catalog/mb_product_variation.dart';
import '../../controllers/admin_brand_controller.dart';
import '../../controllers/admin_category_controller.dart';
import '../../controllers/admin_product_controller.dart';

class AdminProductFormDialog extends StatefulWidget {
  final MBProduct? product;

  const AdminProductFormDialog({
    super.key,
    this.product,
  });

  @override
  State<AdminProductFormDialog> createState() => _AdminProductFormDialogState();
}

class _AdminProductFormDialogState extends State<AdminProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _productCodeController;
  late final TextEditingController _skuController;
  late final TextEditingController _titleEnController;
  late final TextEditingController _titleBnController;
  late final TextEditingController _shortDescriptionEnController;
  late final TextEditingController _shortDescriptionBnController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionBnController;
  late final TextEditingController _thumbnailUrlController;
  late final TextEditingController _imageUrlsController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _stockQtyController;
  late final TextEditingController _tagsController;
  late final TextEditingController _keywordsController;
  late final TextEditingController _viewsController;
  late final TextEditingController _totalSoldController;
  late final TextEditingController _addToCartCountController;
  late final TextEditingController _quantityValueController;
  late final TextEditingController _toleranceController;
  late final TextEditingController _saleEndsAtController;

  String? _categoryId;
  String? _brandId;
  String _productType = 'simple';
  String _quantityType = 'pcs';
  String _toleranceType = 'g';
  String _deliveryShift = 'any';

  bool _isFeatured = false;
  bool _isFlashSale = false;
  bool _isEnabled = true;
  bool _isNewArrival = false;
  bool _isBestSeller = false;
  bool _isToleranceActive = false;

  List<MBProductAttribute> _attributes = [];
  List<MBProductVariation> _variations = [];
  List<MBProductPurchaseOption> _purchaseOptions = [];

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    final product = widget.product;

    _productCodeController =
        TextEditingController(text: product?.productCode ?? '');
    _skuController = TextEditingController(text: product?.sku ?? '');
    _titleEnController = TextEditingController(text: product?.titleEn ?? '');
    _titleBnController = TextEditingController(text: product?.titleBn ?? '');
    _shortDescriptionEnController =
        TextEditingController(text: product?.shortDescriptionEn ?? '');
    _shortDescriptionBnController =
        TextEditingController(text: product?.shortDescriptionBn ?? '');
    _descriptionEnController =
        TextEditingController(text: product?.descriptionEn ?? '');
    _descriptionBnController =
        TextEditingController(text: product?.descriptionBn ?? '');
    _thumbnailUrlController =
        TextEditingController(text: product?.thumbnailUrl ?? '');
    _imageUrlsController =
        TextEditingController(text: product?.imageUrls.join(', ') ?? '');
    _priceController =
        TextEditingController(text: '${product?.price ?? 0}');
    _salePriceController =
        TextEditingController(text: product?.salePrice?.toString() ?? '');
    _stockQtyController =
        TextEditingController(text: '${product?.stockQty ?? 0}');
    _tagsController = TextEditingController(text: product?.tags.join(', ') ?? '');
    _keywordsController =
        TextEditingController(text: product?.keywords.join(', ') ?? '');
    _viewsController =
        TextEditingController(text: '${product?.views ?? 0}');
    _totalSoldController =
        TextEditingController(text: '${product?.totalSold ?? 0}');
    _addToCartCountController =
        TextEditingController(text: '${product?.addToCartCount ?? 0}');
    _quantityValueController =
        TextEditingController(text: '${product?.quantityValue ?? 0}');
    _toleranceController =
        TextEditingController(text: '${product?.tolerance ?? 0}');
    _saleEndsAtController =
        TextEditingController(text: product?.saleEndsAt?.toIso8601String() ?? '');

    _categoryId = product?.categoryId;
    _brandId = product?.brandId;
    _productType = product?.productType ?? 'simple';
    _quantityType = product?.quantityType ?? 'pcs';
    _toleranceType = product?.toleranceType ?? 'g';
    _deliveryShift = product?.deliveryShift ?? 'any';

    _isFeatured = product?.isFeatured ?? false;
    _isFlashSale = product?.isFlashSale ?? false;
    _isEnabled = product?.isEnabled ?? true;
    _isNewArrival = product?.isNewArrival ?? false;
    _isBestSeller = product?.isBestSeller ?? false;
    _isToleranceActive = product?.isToleranceActive ?? false;

    _attributes = List<MBProductAttribute>.from(product?.attributes ?? []);
    _variations = List<MBProductVariation>.from(product?.variations ?? []);
    _purchaseOptions =
    List<MBProductPurchaseOption>.from(product?.purchaseOptions ?? []);
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _skuController.dispose();
    _titleEnController.dispose();
    _titleBnController.dispose();
    _shortDescriptionEnController.dispose();
    _shortDescriptionBnController.dispose();
    _descriptionEnController.dispose();
    _descriptionBnController.dispose();
    _thumbnailUrlController.dispose();
    _imageUrlsController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _stockQtyController.dispose();
    _tagsController.dispose();
    _keywordsController.dispose();
    _viewsController.dispose();
    _totalSoldController.dispose();
    _addToCartCountController.dispose();
    _quantityValueController.dispose();
    _toleranceController.dispose();
    _saleEndsAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminProductController>();
    final categoryController = Get.find<AdminCategoryController>();
    final brandController = Get.find<AdminBrandController>();

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 1100,
        height: 760,
        padding: const EdgeInsets.all(MBSpacing.xl),
        child: Obx(
              () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit Product' : 'Create Product',
                style: MBTextStyles.sectionTitle,
              ),
              MBSpacing.h(MBSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _titleEnController,
                                labelText: 'Title (English)',
                                validator: (value) {
                                  if ((value ?? '').trim().isEmpty) {
                                    return 'Enter English title';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _titleBnController,
                                labelText: 'Title (Bangla)',
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _productCodeController,
                                labelText: 'Product Code',
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _skuController,
                                labelText: 'SKU',
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                initialValue: _categoryId,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('No Category'),
                                  ),
                                  ...categoryController.categories.map((e) {
                                    return DropdownMenuItem<String?>(
                                      value: e.id,
                                      child: Text(e.nameEn),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _categoryId = value;
                                  });
                                },
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                initialValue: _brandId,
                                decoration: const InputDecoration(
                                  labelText: 'Brand',
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('No Brand'),
                                  ),
                                  ...brandController.brands.map((e) {
                                    return DropdownMenuItem<String?>(
                                      value: e.id,
                                      child: Text(e.nameEn),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _brandId = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _productType,
                                decoration: const InputDecoration(
                                  labelText: 'Product Type',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'simple',
                                    child: Text('Simple'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'variable',
                                    child: Text('Variable'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _productType = value ?? 'simple';
                                  });
                                },
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _thumbnailUrlController,
                                labelText: 'Thumbnail URL',
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        MBTextField(
                          controller: _imageUrlsController,
                          labelText: 'Image URLs (comma separated)',
                          maxLines: 2,
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _priceController,
                                labelText: 'Price',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _salePriceController,
                                labelText: 'Sale Price',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _stockQtyController,
                                labelText: 'Stock Qty',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _shortDescriptionEnController,
                                labelText: 'Short Description (English)',
                                maxLines: 3,
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _shortDescriptionBnController,
                                labelText: 'Short Description (Bangla)',
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _descriptionEnController,
                                labelText: 'Description (English)',
                                maxLines: 5,
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _descriptionBnController,
                                labelText: 'Description (Bangla)',
                                maxLines: 5,
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _tagsController,
                                labelText: 'Tags (comma separated)',
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _keywordsController,
                                labelText: 'Keywords (comma separated)',
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _quantityType,
                                decoration: const InputDecoration(
                                  labelText: 'Quantity Type',
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'pcs', child: Text('pcs')),
                                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                                  DropdownMenuItem(value: 'g', child: Text('g')),
                                  DropdownMenuItem(value: 'ltr', child: Text('ltr')),
                                  DropdownMenuItem(value: 'ml', child: Text('ml')),
                                  DropdownMenuItem(value: 'pack', child: Text('pack')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _quantityType = value ?? 'pcs';
                                  });
                                },
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _quantityValueController,
                                labelText: 'Quantity Value',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _deliveryShift,
                                decoration: const InputDecoration(
                                  labelText: 'Delivery Shift',
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'any', child: Text('any')),
                                  DropdownMenuItem(value: 'morning', child: Text('morning')),
                                  DropdownMenuItem(value: 'evening', child: Text('evening')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _deliveryShift = value ?? 'any';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _toleranceType,
                                decoration: const InputDecoration(
                                  labelText: 'Tolerance Type',
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'g', child: Text('g')),
                                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                                  DropdownMenuItem(value: 'ml', child: Text('ml')),
                                  DropdownMenuItem(value: 'ltr', child: Text('ltr')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _toleranceType = value ?? 'g';
                                  });
                                },
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _toleranceController,
                                labelText: 'Tolerance',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _saleEndsAtController,
                                labelText: 'Sale Ends At (ISO)',
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: MBTextField(
                                controller: _viewsController,
                                labelText: 'Views',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _totalSoldController,
                                labelText: 'Total Sold',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            MBSpacing.w(MBSpacing.md),
                            Expanded(
                              child: MBTextField(
                                controller: _addToCartCountController,
                                labelText: 'Add To Cart Count',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        MBSpacing.h(MBSpacing.md),
                        MBCard(
                          child: Column(
                            children: [
                              SwitchListTile(
                                value: _isFeatured,
                                onChanged: (value) {
                                  setState(() {
                                    _isFeatured = value;
                                  });
                                },
                                title: const Text('Featured'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              SwitchListTile(
                                value: _isFlashSale,
                                onChanged: (value) {
                                  setState(() {
                                    _isFlashSale = value;
                                  });
                                },
                                title: const Text('Flash Sale'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              SwitchListTile(
                                value: _isEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _isEnabled = value;
                                  });
                                },
                                title: const Text('Enabled'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              SwitchListTile(
                                value: _isNewArrival,
                                onChanged: (value) {
                                  setState(() {
                                    _isNewArrival = value;
                                  });
                                },
                                title: const Text('New Arrival'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              SwitchListTile(
                                value: _isBestSeller,
                                onChanged: (value) {
                                  setState(() {
                                    _isBestSeller = value;
                                  });
                                },
                                title: const Text('Best Seller'),
                                contentPadding: EdgeInsets.zero,
                              ),
                              SwitchListTile(
                                value: _isToleranceActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isToleranceActive = value;
                                  });
                                },
                                title: const Text('Tolerance Active'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        MBSpacing.h(MBSpacing.lg),
                        _ListSectionCard<MBProductAttribute>(
                          title: 'Attributes',
                          items: _attributes,
                          itemLabel: (item) => item.nameEn,
                          onAdd: () async {
                            final result =
                            await _showAttributeDialog(context, null);
                            if (result != null) {
                              setState(() {
                                _attributes.add(result);
                              });
                            }
                          },
                          onEdit: (index) async {
                            final result = await _showAttributeDialog(
                              context,
                              _attributes[index],
                            );
                            if (result != null) {
                              setState(() {
                                _attributes[index] = result;
                              });
                            }
                          },
                          onDelete: (index) {
                            setState(() {
                              _attributes.removeAt(index);
                            });
                          },
                        ),
                        MBSpacing.h(MBSpacing.lg),
                        _ListSectionCard<MBProductVariation>(
                          title: 'Variations',
                          items: _variations,
                          itemLabel: (item) => item.id.isEmpty
                              ? (item.sku.isEmpty ? 'Variation' : item.sku)
                              : item.id,
                          onAdd: () async {
                            final result =
                            await _showVariationDialog(context, null);
                            if (result != null) {
                              setState(() {
                                _variations.add(result);
                              });
                            }
                          },
                          onEdit: (index) async {
                            final result = await _showVariationDialog(
                              context,
                              _variations[index],
                            );
                            if (result != null) {
                              setState(() {
                                _variations[index] = result;
                              });
                            }
                          },
                          onDelete: (index) {
                            setState(() {
                              _variations.removeAt(index);
                            });
                          },
                        ),
                        MBSpacing.h(MBSpacing.lg),
                        _ListSectionCard<MBProductPurchaseOption>(
                          title: 'Purchase Options',
                          items: _purchaseOptions,
                          itemLabel: (item) =>
                          item.labelEn.isEmpty ? item.mode : item.labelEn,
                          onAdd: () async {
                            final result =
                            await _showPurchaseOptionDialog(context, null);
                            if (result != null) {
                              setState(() {
                                _purchaseOptions.add(result);
                              });
                            }
                          },
                          onEdit: (index) async {
                            final result = await _showPurchaseOptionDialog(
                              context,
                              _purchaseOptions[index],
                            );
                            if (result != null) {
                              setState(() {
                                _purchaseOptions[index] = result;
                              });
                            }
                          },
                          onDelete: (index) {
                            setState(() {
                              _purchaseOptions.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              MBSpacing.h(MBSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: MBSecondaryButton(
                      text: 'Cancel',
                      isLoading: controller.isSaving.value,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: MBPrimaryButton(
                      text: isEdit ? 'Update Product' : 'Create Product',
                      isLoading: controller.isSaving.value,
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<AdminProductController>();
    final existing = widget.product;
    final now = DateTime.now();

    final product = MBProduct(
      id: existing?.id ?? '',
      productCode: _nullIfEmpty(_productCodeController.text),
      sku: _nullIfEmpty(_skuController.text),
      titleEn: _titleEnController.text.trim(),
      titleBn: _titleBnController.text.trim(),
      shortDescriptionEn: _shortDescriptionEnController.text.trim(),
      shortDescriptionBn: _shortDescriptionBnController.text.trim(),
      descriptionEn: _descriptionEnController.text.trim(),
      descriptionBn: _descriptionBnController.text.trim(),
      thumbnailUrl: _thumbnailUrlController.text.trim(),
      imageUrls: _splitCsv(_imageUrlsController.text),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      salePrice: _salePriceController.text.trim().isEmpty
          ? null
          : double.tryParse(_salePriceController.text.trim()),
      stockQty: int.tryParse(_stockQtyController.text.trim()) ?? 0,
      categoryId: _categoryId,
      brandId: _brandId,
      productType: _productType,
      tags: _splitCsv(_tagsController.text),
      keywords: _splitCsv(_keywordsController.text),
      attributes: _attributes,
      variations: _variations,
      purchaseOptions: _purchaseOptions,
      isFeatured: _isFeatured,
      isFlashSale: _isFlashSale,
      isEnabled: _isEnabled,
      isNewArrival: _isNewArrival,
      isBestSeller: _isBestSeller,
      views: int.tryParse(_viewsController.text.trim()) ?? 0,
      totalSold: int.tryParse(_totalSoldController.text.trim()) ?? 0,
      addToCartCount: int.tryParse(_addToCartCountController.text.trim()) ?? 0,
      quantityType: _quantityType,
      quantityValue: double.tryParse(_quantityValueController.text.trim()) ?? 0,
      toleranceType: _toleranceType,
      tolerance: double.tryParse(_toleranceController.text.trim()) ?? 0,
      isToleranceActive: _isToleranceActive,
      deliveryShift: _deliveryShift,
      saleEndsAt: _saleEndsAtController.text.trim().isEmpty
          ? null
          : DateTime.tryParse(_saleEndsAtController.text.trim()),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (existing == null) {
      await controller.createProduct(product);
    } else {
      await controller.updateProduct(product);
    }

    if (mounted) {
      Get.back();
    }
  }

  List<String> _splitCsv(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String? _nullIfEmpty(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}

class _ListSectionCard<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T item) itemLabel;
  final VoidCallback onAdd;
  final Future<void> Function(int index) onEdit;
  final void Function(int index) onDelete;

  const _ListSectionCard({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return MBCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: MBTextStyles.sectionTitle),
              const Spacer(),
              SizedBox(
                width: 130,
                child: MBPrimaryButton(
                  text: 'Add',
                  height: 40,
                  onPressed: onAdd,
                ),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.md),
          if (items.isEmpty)
            Text(
              'No $title added.',
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            )
          else
            Column(
              children: List.generate(items.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: MBSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          itemLabel(items[index]),
                          style: MBTextStyles.body,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onEdit(index),
                        child: const Text('Edit'),
                      ),
                      TextButton(
                        onPressed: () => onDelete(index),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

Future<MBProductAttribute?> _showAttributeDialog(
    BuildContext context,
    MBProductAttribute? existing,
    ) async {
  final nameEnController =
  TextEditingController(text: existing?.nameEn ?? '');
  final nameBnController =
  TextEditingController(text: existing?.nameBn ?? '');
  final valuesController =
  TextEditingController(text: existing?.values.join(', ') ?? '');
  final sortOrderController =
  TextEditingController(text: '${existing?.sortOrder ?? 0}');
  bool isVisible = existing?.isVisible ?? true;

  return showDialog<MBProductAttribute>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Attribute' : 'Edit Attribute'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MBTextField(
                      controller: nameEnController,
                      labelText: 'Name (English)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: nameBnController,
                      labelText: 'Name (Bangla)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: valuesController,
                      labelText: 'Values (comma separated)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: sortOrderController,
                      labelText: 'Sort Order',
                      keyboardType: TextInputType.number,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    SwitchListTile(
                      value: isVisible,
                      onChanged: (value) {
                        setState(() {
                          isVisible = value;
                        });
                      },
                      title: const Text('Visible'),
                      contentPadding: EdgeInsets.zero,
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    MBProductAttribute(
                      nameEn: nameEnController.text.trim(),
                      nameBn: nameBnController.text.trim(),
                      values: valuesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      sortOrder:
                      int.tryParse(sortOrderController.text.trim()) ?? 0,
                      isVisible: isVisible,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<MBProductVariation?> _showVariationDialog(
    BuildContext context,
    MBProductVariation? existing,
    ) async {
  final idController = TextEditingController(text: existing?.id ?? '');
  final skuController = TextEditingController(text: existing?.sku ?? '');
  final imageUrlController =
  TextEditingController(text: existing?.imageUrl ?? '');
  final descriptionEnController =
  TextEditingController(text: existing?.descriptionEn ?? '');
  final descriptionBnController =
  TextEditingController(text: existing?.descriptionBn ?? '');
  final priceController =
  TextEditingController(text: '${existing?.price ?? 0}');
  final salePriceController =
  TextEditingController(text: existing?.salePrice?.toString() ?? '');
  final stockQtyController =
  TextEditingController(text: '${existing?.stockQty ?? 0}');
  final attributeValuesController = TextEditingController(
    text: existing?.attributeValues.entries
        .map((e) => '${e.key}:${e.value}')
        .join(', ') ??
        '',
  );
  bool isEnabled = existing?.isEnabled ?? true;

  return showDialog<MBProductVariation>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add Variation' : 'Edit Variation'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MBTextField(
                      controller: idController,
                      labelText: 'Variation ID',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: skuController,
                      labelText: 'SKU',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: imageUrlController,
                      labelText: 'Image URL',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: descriptionEnController,
                      labelText: 'Description (English)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: descriptionBnController,
                      labelText: 'Description (Bangla)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: priceController,
                      labelText: 'Price',
                      keyboardType: TextInputType.number,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: salePriceController,
                      labelText: 'Sale Price',
                      keyboardType: TextInputType.number,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: stockQtyController,
                      labelText: 'Stock Qty',
                      keyboardType: TextInputType.number,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: attributeValuesController,
                      labelText: 'Attribute Values (key:value, key:value)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    SwitchListTile(
                      value: isEnabled,
                      onChanged: (value) {
                        setState(() {
                          isEnabled = value;
                        });
                      },
                      title: const Text('Enabled'),
                      contentPadding: EdgeInsets.zero,
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
              TextButton(
                onPressed: () {
                  final map = <String, String>{};
                  final pairs = attributeValuesController.text.split(',');
                  for (final pair in pairs) {
                    final parts = pair.split(':');
                    if (parts.length == 2) {
                      map[parts[0].trim()] = parts[1].trim();
                    }
                  }

                  Navigator.of(context).pop(
                    MBProductVariation(
                      id: idController.text.trim(),
                      sku: skuController.text.trim(),
                      imageUrl: imageUrlController.text.trim(),
                      descriptionEn: descriptionEnController.text.trim(),
                      descriptionBn: descriptionBnController.text.trim(),
                      price: double.tryParse(priceController.text.trim()) ?? 0,
                      salePrice: salePriceController.text.trim().isEmpty
                          ? null
                          : double.tryParse(salePriceController.text.trim()),
                      stockQty:
                      int.tryParse(stockQtyController.text.trim()) ?? 0,
                      attributeValues: map,
                      isEnabled: isEnabled,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<MBProductPurchaseOption?> _showPurchaseOptionDialog(
    BuildContext context,
    MBProductPurchaseOption? existing,
    ) async {
  final idController = TextEditingController(text: existing?.id ?? '');
  final modeController = TextEditingController(text: existing?.mode ?? '');
  final labelEnController =
  TextEditingController(text: existing?.labelEn ?? '');
  final labelBnController =
  TextEditingController(text: existing?.labelBn ?? '');
  final priceController =
  TextEditingController(text: '${existing?.price ?? 0}');
  final salePriceController =
  TextEditingController(text: existing?.salePrice?.toString() ?? '');
  final minDaysController =
  TextEditingController(text: '${existing?.minScheduleDays ?? 0}');
  final maxDaysController =
  TextEditingController(text: '${existing?.maxScheduleDays ?? 0}');
  final shiftsController = TextEditingController(
    text: existing?.availableShifts.join(', ') ?? '',
  );
  final cutoffController =
  TextEditingController(text: existing?.cutoffTime ?? '');
  final helperEnController =
  TextEditingController(text: existing?.helperTextEn ?? '');
  final helperBnController =
  TextEditingController(text: existing?.helperTextBn ?? '');

  bool isEnabled = existing?.isEnabled ?? true;
  bool supportsDateSelection = existing?.supportsDateSelection ?? false;

  return showDialog<MBProductPurchaseOption>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              existing == null
                  ? 'Add Purchase Option'
                  : 'Edit Purchase Option',
            ),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    MBTextField(
                      controller: idController,
                      labelText: 'Option ID',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: modeController,
                      labelText: 'Mode',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: labelEnController,
                      labelText: 'Label (English)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: labelBnController,
                      labelText: 'Label (Bangla)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: priceController,
                      labelText: 'Price',
                      keyboardType: TextInputType.number,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: salePriceController,
                      labelText: 'Sale Price',
                      keyboardType: TextInputType.number,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: minDaysController,
                      labelText: 'Min Schedule Days',
                      keyboardType: TextInputType.number,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: maxDaysController,
                      labelText: 'Max Schedule Days',
                      keyboardType: TextInputType.number,
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: shiftsController,
                      labelText: 'Available Shifts (comma separated)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: cutoffController,
                      labelText: 'Cutoff Time',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: helperEnController,
                      labelText: 'Helper Text (English)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    MBTextField(
                      controller: helperBnController,
                      labelText: 'Helper Text (Bangla)',
                    ),
                    MBSpacing.h(MBSpacing.md),
                    SwitchListTile(
                      value: isEnabled,
                      onChanged: (value) {
                        setState(() {
                          isEnabled = value;
                        });
                      },
                      title: const Text('Enabled'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      value: supportsDateSelection,
                      onChanged: (value) {
                        setState(() {
                          supportsDateSelection = value;
                        });
                      },
                      title: const Text('Supports Date Selection'),
                      contentPadding: EdgeInsets.zero,
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    MBProductPurchaseOption(
                      id: idController.text.trim(),
                      mode: modeController.text.trim(),
                      labelEn: labelEnController.text.trim(),
                      labelBn: labelBnController.text.trim(),
                      price: double.tryParse(priceController.text.trim()) ?? 0,
                      salePrice: salePriceController.text.trim().isEmpty
                          ? null
                          : double.tryParse(salePriceController.text.trim()),
                      isEnabled: isEnabled,
                      supportsDateSelection: supportsDateSelection,
                      minScheduleDays:
                      int.tryParse(minDaysController.text.trim()) ?? 0,
                      maxScheduleDays:
                      int.tryParse(maxDaysController.text.trim()) ?? 0,
                      availableShifts: shiftsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      cutoffTime: cutoffController.text.trim().isEmpty
                          ? null
                          : cutoffController.text.trim(),
                      helperTextEn: helperEnController.text.trim().isEmpty
                          ? null
                          : helperEnController.text.trim(),
                      helperTextBn: helperBnController.text.trim().isEmpty
                          ? null
                          : helperBnController.text.trim(),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}












