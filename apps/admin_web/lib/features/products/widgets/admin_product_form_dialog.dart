import 'dart:math';

import 'package:admin_web/features/products/controllers/admin_product_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminProductFormDialog extends StatefulWidget {
  const AdminProductFormDialog({
    super.key,
    this.product,
  });

  final MBProduct? product;

  bool get isEdit => product != null;

  @override
  State<AdminProductFormDialog> createState() => _AdminProductFormDialogState();
}

class _AdminProductFormDialogState extends State<AdminProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleEnController;
  late final TextEditingController _titleBnController;
  late final TextEditingController _shortDescriptionEnController;
  late final TextEditingController _shortDescriptionBnController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionBnController;
  late final TextEditingController _productCodeController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _stockQtyController;
  late final TextEditingController _regularStockQtyController;
  late final TextEditingController _reservedInstantQtyController;
  late final TextEditingController _todayInstantCapController;
  late final TextEditingController _todayInstantSoldController;
  late final TextEditingController _maxScheduleQtyPerDayController;
  late final TextEditingController _estimatedSchedulePriceController;
  late final TextEditingController _instantCutoffTimeController;
  late final TextEditingController _minScheduleNoticeHoursController;
  late final TextEditingController _tagsController;
  late final TextEditingController _keywordsController;
  late final TextEditingController _quantityValueController;
  late final TextEditingController _toleranceController;
  late final TextEditingController _saleEndsAtController;

  String? _categoryId;
  String? _brandId;

  String _inventoryMode = 'stocked';
  bool _trackInventory = true;
  bool _supportsInstantOrder = true;
  bool _supportsScheduledOrder = false;
  String _schedulePriceType = 'fixed';
  bool _isFeatured = false;
  bool _isFlashSale = false;
  bool _isEnabled = true;
  bool _isNewArrival = false;
  bool _isBestSeller = false;
  String _quantityType = 'pcs';
  String _toleranceType = 'g';
  bool _isToleranceActive = false;
  String _deliveryShift = 'any';

  bool _hasAttributes = false;
  bool _hasVariations = false;
  bool _hasPurchaseOptions = false;

  AdminPickedImageFile? _thumbnailFile;
  List<AdminPickedImageFile> _galleryFiles = <AdminPickedImageFile>[];

  List<_AttributeFormItem> _attributes = <_AttributeFormItem>[];
  List<_VariationFormItem> _variations = <_VariationFormItem>[];
  List<_PurchaseOptionFormItem> _purchaseOptions = <_PurchaseOptionFormItem>[];

  final Map<String, AdminPickedImageFile> _variationImageFiles =
  <String, AdminPickedImageFile>{};

  AdminProductController get controller => Get.find<AdminProductController>();

  @override
  void initState() {
    super.initState();

    final p = widget.product;

    _titleEnController = TextEditingController(text: p?.titleEn ?? '');
    _titleBnController = TextEditingController(text: p?.titleBn ?? '');
    _shortDescriptionEnController =
        TextEditingController(text: p?.shortDescriptionEn ?? '');
    _shortDescriptionBnController =
        TextEditingController(text: p?.shortDescriptionBn ?? '');
    _descriptionEnController =
        TextEditingController(text: p?.descriptionEn ?? '');
    _descriptionBnController =
        TextEditingController(text: p?.descriptionBn ?? '');
    _productCodeController =
        TextEditingController(text: p?.productCode ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _priceController =
        TextEditingController(text: p != null ? '${p.price}' : '');
    _salePriceController =
        TextEditingController(text: p?.salePrice != null ? '${p!.salePrice}' : '');
    _stockQtyController =
        TextEditingController(text: p != null ? '${p.stockQty}' : '0');
    _regularStockQtyController =
        TextEditingController(text: p != null ? '${p.regularStockQty}' : '0');
    _reservedInstantQtyController = TextEditingController(
      text: p != null ? '${p.reservedInstantQty}' : '0',
    );
    _todayInstantCapController =
        TextEditingController(text: p != null ? '${p.todayInstantCap}' : '999999');
    _todayInstantSoldController =
        TextEditingController(text: p != null ? '${p.todayInstantSold}' : '0');
    _maxScheduleQtyPerDayController = TextEditingController(
      text: p != null ? '${p.maxScheduleQtyPerDay}' : '999999',
    );
    _estimatedSchedulePriceController = TextEditingController(
      text: p?.estimatedSchedulePrice != null
          ? '${p!.estimatedSchedulePrice}'
          : '',
    );
    _instantCutoffTimeController =
        TextEditingController(text: p?.instantCutoffTime ?? '');
    _minScheduleNoticeHoursController = TextEditingController(
      text: p != null ? '${p.minScheduleNoticeHours}' : '0',
    );
    _tagsController = TextEditingController(text: p?.tags.join(', ') ?? '');
    _keywordsController =
        TextEditingController(text: p?.keywords.join(', ') ?? '');
    _quantityValueController = TextEditingController(
      text: p != null ? '${p.quantityValue}' : '0',
    );
    _toleranceController = TextEditingController(
      text: p != null ? '${p.tolerance}' : '0',
    );
    _saleEndsAtController = TextEditingController(
      text: p?.saleEndsAt?.toIso8601String() ?? '',
    );

    _categoryId = p?.categoryId;
    _brandId = p?.brandId;
    _inventoryMode = p?.inventoryMode ?? 'stocked';
    _trackInventory = p?.trackInventory ?? true;
    _supportsInstantOrder = p?.supportsInstantOrder ?? true;
    _supportsScheduledOrder = p?.supportsScheduledOrder ?? false;
    _schedulePriceType = p?.schedulePriceType ?? 'fixed';
    _isFeatured = p?.isFeatured ?? false;
    _isFlashSale = p?.isFlashSale ?? false;
    _isEnabled = p?.isEnabled ?? true;
    _isNewArrival = p?.isNewArrival ?? false;
    _isBestSeller = p?.isBestSeller ?? false;
    _quantityType = p?.quantityType ?? 'pcs';
    _toleranceType = p?.toleranceType ?? 'g';
    _isToleranceActive = p?.isToleranceActive ?? false;
    _deliveryShift = p?.deliveryShift ?? 'any';

    _hasAttributes = p?.hasAttributes ?? false;
    _hasVariations = p?.hasVariations ?? false;
    _hasPurchaseOptions = p?.hasPurchaseOptions ?? false;

    _attributes = (p?.attributes ?? const <MBProductAttribute>[])
        .map(_AttributeFormItem.fromModel)
        .toList();

    _variations = (p?.variations ?? const <MBProductVariation>[])
        .map(_VariationFormItem.fromModel)
        .toList();

    _purchaseOptions =
        (p?.purchaseOptions ?? const <MBProductPurchaseOption>[])
            .map(_PurchaseOptionFormItem.fromModel)
            .toList();
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleBnController.dispose();
    _shortDescriptionEnController.dispose();
    _shortDescriptionBnController.dispose();
    _descriptionEnController.dispose();
    _descriptionBnController.dispose();
    _productCodeController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _stockQtyController.dispose();
    _regularStockQtyController.dispose();
    _reservedInstantQtyController.dispose();
    _todayInstantCapController.dispose();
    _todayInstantSoldController.dispose();
    _maxScheduleQtyPerDayController.dispose();
    _estimatedSchedulePriceController.dispose();
    _instantCutoffTimeController.dispose();
    _minScheduleNoticeHoursController.dispose();
    _tagsController.dispose();
    _keywordsController.dispose();
    _quantityValueController.dispose();
    _toleranceController.dispose();
    _saleEndsAtController.dispose();

    for (final item in _attributes) {
      item.dispose();
    }
    for (final item in _variations) {
      item.dispose();
    }
    for (final item in _purchaseOptions) {
      item.dispose();
    }

    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    setState(() {
      _thumbnailFile = AdminPickedImageFile(
        name: file.name,
        bytes: file.bytes,
        mimeType: file.extension != null ? 'image/${file.extension}' : 'image/*',
      );
    });
  }

  Future<void> _pickGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _galleryFiles = result.files
          .map(
            (file) => AdminPickedImageFile(
          name: file.name,
          bytes: file.bytes,
          mimeType: file.extension != null ? 'image/${file.extension}' : 'image/*',
        ),
      )
          .toList();
    });
  }

  Future<void> _pickVariationImage(String variationId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    setState(() {
      _variationImageFiles[variationId] = AdminPickedImageFile(
        name: file.name,
        bytes: file.bytes,
        mimeType: file.extension != null ? 'image/${file.extension}' : 'image/*',
      );
    });
  }

  void _addAttribute() {
    setState(() {
      _attributes.add(_AttributeFormItem.empty());
    });
  }

  void _removeAttribute(int index) {
    setState(() {
      _attributes[index].dispose();
      _attributes.removeAt(index);
    });
  }

  void _addVariation() {
    setState(() {
      _variations.add(_VariationFormItem.empty());
    });
  }

  void _removeVariation(int index) {
    setState(() {
      final id = _variations[index].id;
      _variationImageFiles.remove(id);
      _variations[index].dispose();
      _variations.removeAt(index);
    });
  }

  void _addPurchaseOption() {
    setState(() {
      _purchaseOptions.add(_PurchaseOptionFormItem.empty());
    });
  }

  void _removePurchaseOption(int index) {
    setState(() {
      _purchaseOptions[index].dispose();
      _purchaseOptions.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedCategory = controller.categories.firstWhereOrNull(
          (e) => e.id == _categoryId,
    );

    if (_categoryId == null || selectedCategory == null) {
      Get.snackbar(
        'Missing category',
        'Please select a valid category.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final now = DateTime.now();

    final builtAttributes = _hasAttributes
        ? _attributes.map((e) => e.toModel()).whereType<MBProductAttribute>().toList()
        : <MBProductAttribute>[];

    final builtVariations = _hasVariations
        ? _variations.map((e) => e.toModel()).whereType<MBProductVariation>().toList()
        : <MBProductVariation>[];

    final builtPurchaseOptions = _hasPurchaseOptions
        ? _purchaseOptions
        .map((e) => e.toModel())
        .whereType<MBProductPurchaseOption>()
        .toList()
        : <MBProductPurchaseOption>[];

    final product = MBProduct(
      id: widget.product?.id ?? '',
      productCode: _emptyToNull(_productCodeController.text),
      sku: _emptyToNull(_skuController.text),
      titleEn: _titleEnController.text.trim(),
      titleBn: _titleBnController.text.trim(),
      shortDescriptionEn: _shortDescriptionEnController.text.trim(),
      shortDescriptionBn: _shortDescriptionBnController.text.trim(),
      descriptionEn: _descriptionEnController.text.trim(),
      descriptionBn: _descriptionBnController.text.trim(),
      thumbnailUrl: widget.product?.thumbnailUrl ?? '',
      imageUrls: widget.product?.imageUrls ?? const <String>[],
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      salePrice: _nullableDouble(_salePriceController.text),
      stockQty: int.tryParse(_stockQtyController.text.trim()) ?? 0,
      inventoryMode: _inventoryMode,
      trackInventory: _trackInventory,
      supportsInstantOrder: _supportsInstantOrder,
      supportsScheduledOrder: _supportsScheduledOrder,
      regularStockQty: int.tryParse(_regularStockQtyController.text.trim()) ?? 0,
      reservedInstantQty:
      int.tryParse(_reservedInstantQtyController.text.trim()) ?? 0,
      todayInstantCap:
      int.tryParse(_todayInstantCapController.text.trim()) ?? 999999,
      todayInstantSold:
      int.tryParse(_todayInstantSoldController.text.trim()) ?? 0,
      maxScheduleQtyPerDay:
      int.tryParse(_maxScheduleQtyPerDayController.text.trim()) ?? 999999,
      schedulePriceType: _schedulePriceType,
      estimatedSchedulePrice:
      _nullableDouble(_estimatedSchedulePriceController.text),
      instantCutoffTime: _emptyToNull(_instantCutoffTimeController.text),
      minScheduleNoticeHours:
      int.tryParse(_minScheduleNoticeHoursController.text.trim()) ?? 0,
      categoryId: _categoryId,
      brandId: _brandId,
      productType: _hasVariations ? 'variable' : 'simple',
      tags: _splitCsv(_tagsController.text),
      keywords: _splitCsv(_keywordsController.text),
      attributes: builtAttributes,
      variations: builtVariations,
      purchaseOptions: builtPurchaseOptions,
      isFeatured: _isFeatured,
      isFlashSale: _isFlashSale,
      isEnabled: _isEnabled,
      isNewArrival: _isNewArrival,
      isBestSeller: _isBestSeller,
      views: widget.product?.views ?? 0,
      totalSold: widget.product?.totalSold ?? 0,
      addToCartCount: widget.product?.addToCartCount ?? 0,
      quantityType: _quantityType,
      quantityValue: double.tryParse(_quantityValueController.text.trim()) ?? 0,
      toleranceType: _toleranceType,
      tolerance: double.tryParse(_toleranceController.text.trim()) ?? 0,
      isToleranceActive: _isToleranceActive,
      deliveryShift: _deliveryShift,
      saleEndsAt: _nullableDateTime(_saleEndsAtController.text),
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (widget.isEdit) {
        await controller.updateProduct(
          existing: widget.product!,
          product: product,
          thumbnailFile: _thumbnailFile,
          galleryFiles: _galleryFiles,
          variationImageFiles: _variationImageFiles,
        );
      } else {
        await controller.createProduct(
          product: product,
          thumbnailFile: _thumbnailFile,
          galleryFiles: _galleryFiles,
          variationImageFiles: _variationImageFiles,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      Get.snackbar(
        'Save failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<String> _splitCsv(String input) {
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String? _emptyToNull(String input) {
    final value = input.trim();
    return value.isEmpty ? null : value;
  }

  double? _nullableDouble(String input) {
    final value = input.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value);
  }

  DateTime? _nullableDateTime(String input) {
    final value = input.trim();
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1220,
          maxHeight: 860,
        ),
        child: Obx(() {
          return AbsorbPointer(
            absorbing: controller.isSaving.value,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(MBSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.isEdit ? 'Edit Product' : 'Add Product',
                          style: MBTextStyles.sectionTitle.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(MBSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _panel(
                                  title: 'Basic Information',
                                  child: Column(
                                    children: [
                                      _textField(
                                        controller: _titleEnController,
                                        label: 'Title (English)',
                                        validator: _required,
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      _textField(
                                        controller: _titleBnController,
                                        label: 'Title (Bangla)',
                                        validator: _required,
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _textField(
                                              controller: _productCodeController,
                                              label: 'Product Code',
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: _textField(
                                              controller: _skuController,
                                              label: 'SKU',
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      _textField(
                                        controller: _shortDescriptionEnController,
                                        label: 'Short Description (English)',
                                        maxLines: 2,
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      _textField(
                                        controller: _shortDescriptionBnController,
                                        label: 'Short Description (Bangla)',
                                        maxLines: 2,
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      _textField(
                                        controller: _descriptionEnController,
                                        label: 'Description (English)',
                                        maxLines: 4,
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      _textField(
                                        controller: _descriptionBnController,
                                        label: 'Description (Bangla)',
                                        maxLines: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                MBSpacing.h(MBSpacing.lg),
                                _panel(
                                  title: 'Catalog, Pricing & Inventory',
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<String>(
                                              value: _categoryId,
                                              decoration: const InputDecoration(
                                                labelText: 'Category',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: controller.categories
                                                  .map(
                                                    (e) => DropdownMenuItem(
                                                  value: e.id,
                                                  child: Text(e.name),
                                                ),
                                              )
                                                  .toList(),
                                              onChanged: (value) =>
                                                  setState(() => _categoryId = value),
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: DropdownButtonFormField<String?>(
                                              value: _brandId,
                                              decoration: const InputDecoration(
                                                labelText: 'Brand',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: [
                                                const DropdownMenuItem<String?>(
                                                  value: null,
                                                  child: Text('No Brand'),
                                                ),
                                                ...controller.brands.map(
                                                      (e) => DropdownMenuItem<String?>(
                                                    value: e.id,
                                                    child: Text(e.name),
                                                  ),
                                                ),
                                              ],
                                              onChanged: (value) =>
                                                  setState(() => _brandId = value),
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _textField(
                                              controller: _priceController,
                                              label: 'Price',
                                              keyboardType: TextInputType.number,
                                              validator: _required,
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: _textField(
                                              controller: _salePriceController,
                                              label: 'Sale Price',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _textField(
                                              controller: _stockQtyController,
                                              label: 'Legacy Stock Qty',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: _textField(
                                              controller: _regularStockQtyController,
                                              label: 'Regular Stock Qty',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _textField(
                                              controller: _reservedInstantQtyController,
                                              label: 'Reserved Instant Qty',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: _textField(
                                              controller: _todayInstantCapController,
                                              label: 'Today Instant Cap',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _textField(
                                              controller: _todayInstantSoldController,
                                              label: 'Today Instant Sold',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: _textField(
                                              controller:
                                              _maxScheduleQtyPerDayController,
                                              label: 'Max Schedule Qty / Day',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                MBSpacing.h(MBSpacing.lg),
                                _panel(
                                  title: 'Business Configuration',
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<String>(
                                              value: _inventoryMode,
                                              decoration: const InputDecoration(
                                                labelText: 'Inventory Mode',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'stocked',
                                                  child: Text('stocked'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'hybrid_fresh',
                                                  child: Text('hybrid_fresh'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'schedule_only',
                                                  child: Text('schedule_only'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'untracked',
                                                  child: Text('untracked'),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() => _inventoryMode = value);
                                                }
                                              },
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: DropdownButtonFormField<String>(
                                              value: _schedulePriceType,
                                              decoration: const InputDecoration(
                                                labelText: 'Schedule Price Type',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'fixed',
                                                  child: Text('fixed'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'estimated',
                                                  child: Text('estimated'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'market',
                                                  child: Text('market'),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(
                                                          () => _schedulePriceType = value);
                                                }
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
                                              value: _deliveryShift,
                                              decoration: const InputDecoration(
                                                labelText: 'Delivery Shift',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'any',
                                                  child: Text('any'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'morning',
                                                  child: Text('morning'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'evening',
                                                  child: Text('evening'),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() => _deliveryShift = value);
                                                }
                                              },
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: _textField(
                                              controller:
                                              _estimatedSchedulePriceController,
                                              label: 'Estimated Schedule Price',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _textField(
                                              controller:
                                              _instantCutoffTimeController,
                                              label: 'Instant Cutoff Time',
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: _textField(
                                              controller:
                                              _minScheduleNoticeHoursController,
                                              label: 'Min Schedule Notice Hours',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<String>(
                                              value: _quantityType,
                                              decoration: const InputDecoration(
                                                labelText: 'Quantity Type',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'pcs',
                                                  child: Text('pcs'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'kg',
                                                  child: Text('kg'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'g',
                                                  child: Text('g'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'ltr',
                                                  child: Text('ltr'),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() => _quantityType = value);
                                                }
                                              },
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: _textField(
                                              controller: _quantityValueController,
                                              label: 'Quantity Value',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<String>(
                                              value: _toleranceType,
                                              decoration: const InputDecoration(
                                                labelText: 'Tolerance Type',
                                                border: OutlineInputBorder(),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'g',
                                                  child: Text('g'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'kg',
                                                  child: Text('kg'),
                                                ),
                                                DropdownMenuItem(
                                                  value: '%',
                                                  child: Text('%'),
                                                ),
                                              ],
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() => _toleranceType = value);
                                                }
                                              },
                                            ),
                                          ),
                                          MBSpacing.w(MBSpacing.md),
                                          Expanded(
                                            child: _textField(
                                              controller: _toleranceController,
                                              label: 'Tolerance',
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      _textField(
                                        controller: _tagsController,
                                        label: 'Tags (comma separated)',
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      _textField(
                                        controller: _keywordsController,
                                        label: 'Keywords (comma separated)',
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      _textField(
                                        controller: _saleEndsAtController,
                                        label: 'Sale Ends At (ISO8601)',
                                      ),
                                    ],
                                  ),
                                ),
                                MBSpacing.h(MBSpacing.lg),
                                _panel(
                                  title: 'Advanced Product Builder',
                                  child: Column(
                                    children: [
                                      SwitchListTile(
                                        value: _hasAttributes,
                                        onChanged: (v) =>
                                            setState(() => _hasAttributes = v),
                                        title: const Text('Has Attributes'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      if (_hasAttributes) ...[
                                        MBSpacing.h(MBSpacing.sm),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton.icon(
                                            onPressed: _addAttribute,
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add Attribute'),
                                          ),
                                        ),
                                        MBSpacing.h(MBSpacing.md),
                                        ...List.generate(_attributes.length, (index) {
                                          final item = _attributes[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: MBSpacing.md,
                                            ),
                                            child: _AttributeCard(
                                              item: item,
                                              onRemove: () =>
                                                  _removeAttribute(index),
                                            ),
                                          );
                                        }),
                                      ],
                                      MBSpacing.h(MBSpacing.md),
                                      SwitchListTile(
                                        value: _hasVariations,
                                        onChanged: (v) =>
                                            setState(() => _hasVariations = v),
                                        title: const Text('Has Variations'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      if (_hasVariations) ...[
                                        MBSpacing.h(MBSpacing.sm),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton.icon(
                                            onPressed: _addVariation,
                                            icon: const Icon(Icons.add),
                                            label: const Text('Add Variation'),
                                          ),
                                        ),
                                        MBSpacing.h(MBSpacing.md),
                                        ...List.generate(_variations.length, (index) {
                                          final item = _variations[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: MBSpacing.md,
                                            ),
                                            child: _VariationCard(
                                              item: item,
                                              pickedFile:
                                              _variationImageFiles[item.id],
                                              onPickImage: () =>
                                                  _pickVariationImage(item.id),
                                              onRemove: () =>
                                                  _removeVariation(index),
                                            ),
                                          );
                                        }),
                                      ],
                                      MBSpacing.h(MBSpacing.md),
                                      SwitchListTile(
                                        value: _hasPurchaseOptions,
                                        onChanged: (v) => setState(
                                                () => _hasPurchaseOptions = v),
                                        title: const Text('Has Purchase Options'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      if (_hasPurchaseOptions) ...[
                                        MBSpacing.h(MBSpacing.sm),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton.icon(
                                            onPressed: _addPurchaseOption,
                                            icon: const Icon(Icons.add),
                                            label:
                                            const Text('Add Purchase Option'),
                                          ),
                                        ),
                                        MBSpacing.h(MBSpacing.md),
                                        ...List.generate(
                                            _purchaseOptions.length, (index) {
                                          final item = _purchaseOptions[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: MBSpacing.md,
                                            ),
                                            child: _PurchaseOptionCard(
                                              item: item,
                                              onRemove: () =>
                                                  _removePurchaseOption(index),
                                            ),
                                          );
                                        }),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          MBSpacing.w(MBSpacing.lg),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _panel(
                                  title: 'Media',
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: _pickThumbnail,
                                        icon: const Icon(Icons.image_outlined),
                                        label: Text(
                                          _thumbnailFile == null
                                              ? 'Pick Thumbnail'
                                              : _thumbnailFile!.name,
                                        ),
                                      ),
                                      MBSpacing.h(MBSpacing.md),
                                      OutlinedButton.icon(
                                        onPressed: _pickGallery,
                                        icon: const Icon(
                                            Icons.photo_library_outlined),
                                        label: Text(
                                          _galleryFiles.isEmpty
                                              ? 'Pick Gallery Images'
                                              : '${_galleryFiles.length} images selected',
                                        ),
                                      ),
                                      if (widget.product != null &&
                                          widget.product!.thumbnailUrl.isNotEmpty) ...[
                                        MBSpacing.h(MBSpacing.md),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            MBRadius.md,
                                          ),
                                          child: Image.network(
                                            widget.product!.thumbnailUrl,
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                MBSpacing.h(MBSpacing.lg),
                                _panel(
                                  title: 'Flags & Toggles',
                                  child: Column(
                                    children: [
                                      SwitchListTile(
                                        value: _isEnabled,
                                        onChanged: (v) =>
                                            setState(() => _isEnabled = v),
                                        title: const Text('Enabled'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      SwitchListTile(
                                        value: _isFeatured,
                                        onChanged: (v) =>
                                            setState(() => _isFeatured = v),
                                        title: const Text('Featured'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      SwitchListTile(
                                        value: _isFlashSale,
                                        onChanged: (v) =>
                                            setState(() => _isFlashSale = v),
                                        title: const Text('Flash Sale'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      SwitchListTile(
                                        value: _isNewArrival,
                                        onChanged: (v) =>
                                            setState(() => _isNewArrival = v),
                                        title: const Text('New Arrival'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      SwitchListTile(
                                        value: _isBestSeller,
                                        onChanged: (v) =>
                                            setState(() => _isBestSeller = v),
                                        title: const Text('Best Seller'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      SwitchListTile(
                                        value: _trackInventory,
                                        onChanged: (v) =>
                                            setState(() => _trackInventory = v),
                                        title: const Text('Track Inventory'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      SwitchListTile(
                                        value: _supportsInstantOrder,
                                        onChanged: (v) => setState(
                                                () => _supportsInstantOrder = v),
                                        title:
                                        const Text('Supports Instant Order'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      SwitchListTile(
                                        value: _supportsScheduledOrder,
                                        onChanged: (v) => setState(() =>
                                        _supportsScheduledOrder = v),
                                        title: const Text(
                                            'Supports Scheduled Order'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      SwitchListTile(
                                        value: _isToleranceActive,
                                        onChanged: (v) => setState(
                                                () => _isToleranceActive = v),
                                        title: const Text('Tolerance Active'),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(MBSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      MBSpacing.w(MBSpacing.sm),
                      ElevatedButton(
                        onPressed: controller.isSaving.value ? null : _save,
                        child: controller.isSaving.value
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(widget.isEdit
                            ? 'Update Product'
                            : 'Create Product'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _panel({
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MBRadius.lg),
        side: BorderSide(
          color: MBColors.border.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MBSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: MBTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            child,
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}

class _AttributeCard extends StatelessWidget {
  const _AttributeCard({
    required this.item,
    required this.onRemove,
  });

  final _AttributeFormItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: MBColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MBRadius.md),
        side: BorderSide(
          color: MBColors.border.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MBSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Attribute',
                    style: MBTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            TextFormField(
              controller: item.nameEnController,
              decoration: const InputDecoration(
                labelText: 'Name (English)',
                border: OutlineInputBorder(),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            TextFormField(
              controller: item.nameBnController,
              decoration: const InputDecoration(
                labelText: 'Name (Bangla)',
                border: OutlineInputBorder(),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.valuesController,
                    decoration: const InputDecoration(
                      labelText: 'Values (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                SizedBox(
                  width: 140,
                  child: TextFormField(
                    controller: item.sortOrderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sort Order',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            SwitchListTile(
              value: item.isVisible,
              onChanged: (v) => item.isVisible = v,
              contentPadding: EdgeInsets.zero,
              title: const Text('Visible'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariationCard extends StatelessWidget {
  const _VariationCard({
    required this.item,
    required this.pickedFile,
    required this.onPickImage,
    required this.onRemove,
  });

  final _VariationFormItem item;
  final AdminPickedImageFile? pickedFile;
  final VoidCallback onPickImage;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: MBColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MBRadius.md),
        side: BorderSide(
          color: MBColors.border.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MBSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Variation',
                    style: MBTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.idController,
                    decoration: const InputDecoration(
                      labelText: 'Variation ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: item.skuController,
                    decoration: const InputDecoration(
                      labelText: 'Variation SKU',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            TextFormField(
              controller: item.descriptionEnController,
              decoration: const InputDecoration(
                labelText: 'Description (English)',
                border: OutlineInputBorder(),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            TextFormField(
              controller: item.descriptionBnController,
              decoration: const InputDecoration(
                labelText: 'Description (Bangla)',
                border: OutlineInputBorder(),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: item.salePriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sale Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: item.stockQtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock Qty',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            TextFormField(
              controller: item.attributeValuesController,
              decoration: const InputDecoration(
                labelText: 'Attribute Values (e.g. Size=M,Color=Red)',
                border: OutlineInputBorder(),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    pickedFile == null ? 'Pick Image' : pickedFile!.name,
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: item.imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Existing Image URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            SwitchListTile(
              value: item.isEnabled,
              onChanged: (v) => item.isEnabled = v,
              contentPadding: EdgeInsets.zero,
              title: const Text('Enabled'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseOptionCard extends StatelessWidget {
  const _PurchaseOptionCard({
    required this.item,
    required this.onRemove,
  });

  final _PurchaseOptionFormItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: MBColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MBRadius.md),
        side: BorderSide(
          color: MBColors.border.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MBSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Purchase Option',
                    style: MBTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.idController,
                    decoration: const InputDecoration(
                      labelText: 'Option ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: item.modeController,
                    decoration: const InputDecoration(
                      labelText: 'Mode',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.labelEnController,
                    decoration: const InputDecoration(
                      labelText: 'Label (English)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: item.labelBnController,
                    decoration: const InputDecoration(
                      labelText: 'Label (Bangla)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: item.salePriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sale Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.minScheduleDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Schedule Days',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: item.maxScheduleDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Schedule Days',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            MBSpacing.h(MBSpacing.md),
            TextFormField(
              controller: item.availableShiftsController,
              decoration: const InputDecoration(
                labelText: 'Available Shifts (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            TextFormField(
              controller: item.cutoffTimeController,
              decoration: const InputDecoration(
                labelText: 'Cutoff Time',
                border: OutlineInputBorder(),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            TextFormField(
              controller: item.helperTextEnController,
              decoration: const InputDecoration(
                labelText: 'Helper Text (English)',
                border: OutlineInputBorder(),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            TextFormField(
              controller: item.helperTextBnController,
              decoration: const InputDecoration(
                labelText: 'Helper Text (Bangla)',
                border: OutlineInputBorder(),
              ),
            ),
            MBSpacing.h(MBSpacing.md),
            SwitchListTile(
              value: item.isEnabled,
              onChanged: (v) => item.isEnabled = v,
              contentPadding: EdgeInsets.zero,
              title: const Text('Enabled'),
            ),
            SwitchListTile(
              value: item.supportsDateSelection,
              onChanged: (v) => item.supportsDateSelection = v,
              contentPadding: EdgeInsets.zero,
              title: const Text('Supports Date Selection'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttributeFormItem {
  _AttributeFormItem({
    required this.nameEnController,
    required this.nameBnController,
    required this.valuesController,
    required this.sortOrderController,
    required this.isVisible,
  });

  final TextEditingController nameEnController;
  final TextEditingController nameBnController;
  final TextEditingController valuesController;
  final TextEditingController sortOrderController;
  bool isVisible;

  factory _AttributeFormItem.empty() {
    return _AttributeFormItem(
      nameEnController: TextEditingController(),
      nameBnController: TextEditingController(),
      valuesController: TextEditingController(),
      sortOrderController: TextEditingController(text: '0'),
      isVisible: true,
    );
  }

  factory _AttributeFormItem.fromModel(MBProductAttribute model) {
    return _AttributeFormItem(
      nameEnController: TextEditingController(text: model.nameEn),
      nameBnController: TextEditingController(text: model.nameBn),
      valuesController: TextEditingController(text: model.values.join(', ')),
      sortOrderController:
      TextEditingController(text: model.sortOrder.toString()),
      isVisible: model.isVisible,
    );
  }

  MBProductAttribute? toModel() {
    final nameEn = nameEnController.text.trim();
    final nameBn = nameBnController.text.trim();
    if (nameEn.isEmpty && nameBn.isEmpty) return null;

    return MBProductAttribute(
      nameEn: nameEn,
      nameBn: nameBn,
      values: valuesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      sortOrder: int.tryParse(sortOrderController.text.trim()) ?? 0,
      isVisible: isVisible,
    );
  }

  void dispose() {
    nameEnController.dispose();
    nameBnController.dispose();
    valuesController.dispose();
    sortOrderController.dispose();
  }
}

class _VariationFormItem {
  _VariationFormItem({
    required this.idController,
    required this.skuController,
    required this.imageUrlController,
    required this.descriptionEnController,
    required this.descriptionBnController,
    required this.priceController,
    required this.salePriceController,
    required this.stockQtyController,
    required this.attributeValuesController,
    required this.isEnabled,
  });

  final TextEditingController idController;
  final TextEditingController skuController;
  final TextEditingController imageUrlController;
  final TextEditingController descriptionEnController;
  final TextEditingController descriptionBnController;
  final TextEditingController priceController;
  final TextEditingController salePriceController;
  final TextEditingController stockQtyController;
  final TextEditingController attributeValuesController;
  bool isEnabled;

  String get id => idController.text.trim();

  factory _VariationFormItem.empty() {
    final randomId = 'var_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999)}';
    return _VariationFormItem(
      idController: TextEditingController(text: randomId),
      skuController: TextEditingController(),
      imageUrlController: TextEditingController(),
      descriptionEnController: TextEditingController(),
      descriptionBnController: TextEditingController(),
      priceController: TextEditingController(text: '0'),
      salePriceController: TextEditingController(),
      stockQtyController: TextEditingController(text: '0'),
      attributeValuesController: TextEditingController(),
      isEnabled: true,
    );
  }

  factory _VariationFormItem.fromModel(MBProductVariation model) {
    final attributesCsv = model.attributeValues.entries
        .map((e) => '${e.key}=${e.value}')
        .join(',');

    return _VariationFormItem(
      idController: TextEditingController(text: model.id),
      skuController: TextEditingController(text: model.sku),
      imageUrlController: TextEditingController(text: model.imageUrl),
      descriptionEnController: TextEditingController(text: model.descriptionEn),
      descriptionBnController: TextEditingController(text: model.descriptionBn),
      priceController: TextEditingController(text: model.price.toString()),
      salePriceController: TextEditingController(
        text: model.salePrice?.toString() ?? '',
      ),
      stockQtyController: TextEditingController(text: model.stockQty.toString()),
      attributeValuesController: TextEditingController(text: attributesCsv),
      isEnabled: model.isEnabled,
    );
  }

  MBProductVariation? toModel() {
    final id = idController.text.trim();
    if (id.isEmpty) return null;

    final attrs = <String, String>{};
    for (final part in attributeValuesController.text.split(',')) {
      final raw = part.trim();
      if (raw.isEmpty || !raw.contains('=')) continue;
      final pieces = raw.split('=');
      if (pieces.length < 2) continue;
      attrs[pieces.first.trim()] = pieces.sublist(1).join('=').trim();
    }

    return MBProductVariation(
      id: id,
      sku: skuController.text.trim(),
      imageUrl: imageUrlController.text.trim(),
      descriptionEn: descriptionEnController.text.trim(),
      descriptionBn: descriptionBnController.text.trim(),
      price: double.tryParse(priceController.text.trim()) ?? 0,
      salePrice: _nullableDouble(salePriceController.text),
      stockQty: int.tryParse(stockQtyController.text.trim()) ?? 0,
      attributeValues: attrs,
      isEnabled: isEnabled,
    );
  }

  void dispose() {
    idController.dispose();
    skuController.dispose();
    imageUrlController.dispose();
    descriptionEnController.dispose();
    descriptionBnController.dispose();
    priceController.dispose();
    salePriceController.dispose();
    stockQtyController.dispose();
    attributeValuesController.dispose();
  }
}

class _PurchaseOptionFormItem {
  _PurchaseOptionFormItem({
    required this.idController,
    required this.modeController,
    required this.labelEnController,
    required this.labelBnController,
    required this.priceController,
    required this.salePriceController,
    required this.isEnabled,
    required this.supportsDateSelection,
    required this.minScheduleDaysController,
    required this.maxScheduleDaysController,
    required this.availableShiftsController,
    required this.cutoffTimeController,
    required this.helperTextEnController,
    required this.helperTextBnController,
  });

  final TextEditingController idController;
  final TextEditingController modeController;
  final TextEditingController labelEnController;
  final TextEditingController labelBnController;
  final TextEditingController priceController;
  final TextEditingController salePriceController;
  bool isEnabled;
  bool supportsDateSelection;
  final TextEditingController minScheduleDaysController;
  final TextEditingController maxScheduleDaysController;
  final TextEditingController availableShiftsController;
  final TextEditingController cutoffTimeController;
  final TextEditingController helperTextEnController;
  final TextEditingController helperTextBnController;

  factory _PurchaseOptionFormItem.empty() {
    final randomId =
        'opt_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999)}';
    return _PurchaseOptionFormItem(
      idController: TextEditingController(text: randomId),
      modeController: TextEditingController(text: 'instant'),
      labelEnController: TextEditingController(),
      labelBnController: TextEditingController(),
      priceController: TextEditingController(text: '0'),
      salePriceController: TextEditingController(),
      isEnabled: true,
      supportsDateSelection: false,
      minScheduleDaysController: TextEditingController(text: '0'),
      maxScheduleDaysController: TextEditingController(text: '0'),
      availableShiftsController: TextEditingController(),
      cutoffTimeController: TextEditingController(),
      helperTextEnController: TextEditingController(),
      helperTextBnController: TextEditingController(),
    );
  }

  factory _PurchaseOptionFormItem.fromModel(MBProductPurchaseOption model) {
    return _PurchaseOptionFormItem(
      idController: TextEditingController(text: model.id),
      modeController: TextEditingController(text: model.mode),
      labelEnController: TextEditingController(text: model.labelEn),
      labelBnController: TextEditingController(text: model.labelBn),
      priceController: TextEditingController(text: model.price.toString()),
      salePriceController: TextEditingController(
        text: model.salePrice?.toString() ?? '',
      ),
      isEnabled: model.isEnabled,
      supportsDateSelection: model.supportsDateSelection,
      minScheduleDaysController:
      TextEditingController(text: model.minScheduleDays.toString()),
      maxScheduleDaysController:
      TextEditingController(text: model.maxScheduleDays.toString()),
      availableShiftsController:
      TextEditingController(text: model.availableShifts.join(', ')),
      cutoffTimeController: TextEditingController(text: model.cutoffTime ?? ''),
      helperTextEnController:
      TextEditingController(text: model.helperTextEn ?? ''),
      helperTextBnController:
      TextEditingController(text: model.helperTextBn ?? ''),
    );
  }

  MBProductPurchaseOption? toModel() {
    final id = idController.text.trim();
    final mode = modeController.text.trim();
    if (id.isEmpty || mode.isEmpty) return null;

    return MBProductPurchaseOption(
      id: id,
      mode: mode,
      labelEn: labelEnController.text.trim(),
      labelBn: labelBnController.text.trim(),
      price: double.tryParse(priceController.text.trim()) ?? 0,
      salePrice: _nullableDouble(salePriceController.text),
      isEnabled: isEnabled,
      supportsDateSelection: supportsDateSelection,
      minScheduleDays:
      int.tryParse(minScheduleDaysController.text.trim()) ?? 0,
      maxScheduleDays:
      int.tryParse(maxScheduleDaysController.text.trim()) ?? 0,
      availableShifts: availableShiftsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      cutoffTime: _emptyToNull(cutoffTimeController.text),
      helperTextEn: _emptyToNull(helperTextEnController.text),
      helperTextBn: _emptyToNull(helperTextBnController.text),
    );
  }

  void dispose() {
    idController.dispose();
    modeController.dispose();
    labelEnController.dispose();
    labelBnController.dispose();
    priceController.dispose();
    salePriceController.dispose();
    minScheduleDaysController.dispose();
    maxScheduleDaysController.dispose();
    availableShiftsController.dispose();
    cutoffTimeController.dispose();
    helperTextEnController.dispose();
    helperTextBnController.dispose();
  }
}

double? _nullableDouble(String input) {
  final value = input.trim();
  if (value.isEmpty) return null;
  return double.tryParse(value);
}

String? _emptyToNull(String input) {
  final value = input.trim();
  return value.isEmpty ? null : value;
}