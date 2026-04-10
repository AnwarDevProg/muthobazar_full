import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';

import '../controllers/admin_product_controller.dart';
import 'admin_product_form_support.dart';

// File: admin_product_form_dialog.dart

class AdminProductRelationOption {
  const AdminProductRelationOption({
    required this.id,
    required this.nameEn,
    this.nameBn = '',
    this.slug = '',
  });

  final String id;
  final String nameEn;
  final String nameBn;
  final String slug;
}

class AdminProductFormDialog extends StatefulWidget {
  const AdminProductFormDialog({
    super.key,
    required this.actorUid,
    this.actorName,
    this.actorPhone,
    this.actorRole,
    this.controller,
    this.initialProduct,
    this.availableCategories = const <AdminProductRelationOption>[],
    this.availableBrands = const <AdminProductRelationOption>[],
    this.dialogTitle,
    this.onSaved,
  });

  final String actorUid;
  final String? actorName;
  final String? actorPhone;
  final String? actorRole;
  final AdminProductController? controller;
  final MBProduct? initialProduct;
  final List<AdminProductRelationOption> availableCategories;
  final List<AdminProductRelationOption> availableBrands;
  final String? dialogTitle;
  final ValueChanged<MBProduct>? onSaved;

  static Future<MBProduct?> show(
      BuildContext context, {
        required String actorUid,
        String? actorName,
        String? actorPhone,
        String? actorRole,
        AdminProductController? controller,
        MBProduct? initialProduct,
        List<AdminProductRelationOption> availableCategories =
        const <AdminProductRelationOption>[],
        List<AdminProductRelationOption> availableBrands =
        const <AdminProductRelationOption>[],
        String? dialogTitle,
        ValueChanged<MBProduct>? onSaved,
      }) {
    return showDialog<MBProduct>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 1180,
          height: 820,
          child: AdminProductFormDialog(
            actorUid: actorUid,
            actorName: actorName,
            actorPhone: actorPhone,
            actorRole: actorRole,
            controller: controller,
            initialProduct: initialProduct,
            availableCategories: availableCategories,
            availableBrands: availableBrands,
            dialogTitle: dialogTitle,
            onSaved: onSaved,
          ),
        ),
      ),
    );
  }

  @override
  State<AdminProductFormDialog> createState() =>
      _AdminProductFormDialogState();
}

class _AdminProductFormDialogState extends State<AdminProductFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final AdminProductController _controller;
  late final bool _ownsController;
  late final MBProduct _source;

  late final TextEditingController _titleEnController;
  late final TextEditingController _titleBnController;
  late final TextEditingController _slugController;
  late final TextEditingController _productCodeController;
  late final TextEditingController _skuController;
  late final TextEditingController _shortDescriptionEnController;
  late final TextEditingController _shortDescriptionBnController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionBnController;
  late final TextEditingController _tagsController;
  late final TextEditingController _keywordsController;

  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _estimatedSchedulePriceController;
  late final TextEditingController _stockQtyController;
  late final TextEditingController _regularStockQtyController;
  late final TextEditingController _reservedInstantQtyController;
  late final TextEditingController _todayInstantCapController;
  late final TextEditingController _todayInstantSoldController;
  late final TextEditingController _maxScheduleQtyPerDayController;
  late final TextEditingController _minScheduleNoticeHoursController;
  late final TextEditingController _reorderLevelController;
  late final TextEditingController _instantCutoffTimeController;

  late final TextEditingController _quantityValueController;
  late final TextEditingController _toleranceController;
  late final TextEditingController _minOrderQtyController;
  late final TextEditingController _maxOrderQtyController;
  late final TextEditingController _stepQtyController;
  late final TextEditingController _unitLabelEnController;
  late final TextEditingController _unitLabelBnController;

  late final TextEditingController _categoryIdController;
  late final TextEditingController _categoryNameEnController;
  late final TextEditingController _categoryNameBnController;
  late final TextEditingController _categorySlugController;
  late final TextEditingController _brandIdController;
  late final TextEditingController _brandNameEnController;
  late final TextEditingController _brandNameBnController;
  late final TextEditingController _brandSlugController;

  late final TextEditingController _saleStartsAtController;
  late final TextEditingController _saleEndsAtController;
  late final TextEditingController _publishAtController;
  late final TextEditingController _unpublishAtController;
  late final TextEditingController _createdByController;
  late final TextEditingController _updatedByController;
  late final TextEditingController _deletedByController;
  late final TextEditingController _deleteReasonController;

  late String _productType;
  late String _inventoryMode;
  late String _schedulePriceType;
  late String _quantityType;
  late String _toleranceType;
  late String _deliveryShift;

  late bool _trackInventory;
  late bool _supportsInstantOrder;
  late bool _supportsScheduledOrder;
  late bool _allowBackorder;
  late bool _isFeatured;
  late bool _isFlashSale;
  late bool _isEnabled;
  late bool _isNewArrival;
  late bool _isBestSeller;
  late bool _isToleranceActive;
  late bool _isDeleted;

  late int _sortOrder;

  DateTime? _saleStartsAt;
  DateTime? _saleEndsAt;
  DateTime? _publishAt;
  DateTime? _unpublishAt;
  DateTime? _deletedAt;

  late List<MBProductMedia> _mediaItems;
  late List<MBProductAttribute> _attributes;
  late List<MBProductVariation> _variations;
  late List<MBProductPurchaseOption> _purchaseOptions;

  String? _selectedCategoryId;
  String? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? Get.put(AdminProductController());
    _ownsController = widget.controller == null;
    _source = widget.initialProduct ?? MBProduct.empty();

    _titleEnController = TextEditingController(text: _source.titleEn);
    _titleBnController = TextEditingController(text: _source.titleBn);
    _slugController = TextEditingController(text: _source.slug);
    _productCodeController = TextEditingController(
      text: _source.productCode ?? '',
    );
    _skuController = TextEditingController(text: _source.sku ?? '');
    _shortDescriptionEnController = TextEditingController(
      text: _source.shortDescriptionEn,
    );
    _shortDescriptionBnController = TextEditingController(
      text: _source.shortDescriptionBn,
    );
    _descriptionEnController = TextEditingController(
      text: _source.descriptionEn,
    );
    _descriptionBnController = TextEditingController(
      text: _source.descriptionBn,
    );
    _tagsController = TextEditingController(text: _source.tags.join(', '));
    _keywordsController = TextEditingController(
      text: _source.keywords.join(', '),
    );

    _priceController = TextEditingController(text: asTextDouble(_source.price));
    _salePriceController = TextEditingController(
      text: asTextNullableDouble(_source.salePrice),
    );
    _costPriceController = TextEditingController(
      text: asTextNullableDouble(_source.costPrice),
    );
    _estimatedSchedulePriceController = TextEditingController(
      text: asTextNullableDouble(_source.estimatedSchedulePrice),
    );
    _stockQtyController = TextEditingController(
      text: _source.stockQty.toString(),
    );
    _regularStockQtyController = TextEditingController(
      text: _source.regularStockQty.toString(),
    );
    _reservedInstantQtyController = TextEditingController(
      text: _source.reservedInstantQty.toString(),
    );
    _todayInstantCapController = TextEditingController(
      text: _source.todayInstantCap.toString(),
    );
    _todayInstantSoldController = TextEditingController(
      text: _source.todayInstantSold.toString(),
    );
    _maxScheduleQtyPerDayController = TextEditingController(
      text: _source.maxScheduleQtyPerDay.toString(),
    );
    _minScheduleNoticeHoursController = TextEditingController(
      text: _source.minScheduleNoticeHours.toString(),
    );
    _reorderLevelController = TextEditingController(
      text: _source.reorderLevel.toString(),
    );
    _instantCutoffTimeController = TextEditingController(
      text: _source.instantCutoffTime ?? '',
    );

    _quantityValueController = TextEditingController(
      text: asTextDouble(_source.quantityValue),
    );
    _toleranceController = TextEditingController(
      text: asTextDouble(_source.tolerance),
    );
    _minOrderQtyController = TextEditingController(
      text: asTextNullableDouble(_source.minOrderQty),
    );
    _maxOrderQtyController = TextEditingController(
      text: asTextNullableDouble(_source.maxOrderQty),
    );
    _stepQtyController = TextEditingController(
      text: asTextNullableDouble(_source.stepQty),
    );
    _unitLabelEnController = TextEditingController(
      text: _source.unitLabelEn ?? '',
    );
    _unitLabelBnController = TextEditingController(
      text: _source.unitLabelBn ?? '',
    );

    _categoryIdController = TextEditingController(
      text: _source.categoryId ?? '',
    );
    _categoryNameEnController = TextEditingController(
      text: _source.categoryNameEn ?? '',
    );
    _categoryNameBnController = TextEditingController(
      text: _source.categoryNameBn ?? '',
    );
    _categorySlugController = TextEditingController(
      text: _source.categorySlug ?? '',
    );
    _brandIdController = TextEditingController(text: _source.brandId ?? '');
    _brandNameEnController = TextEditingController(
      text: _source.brandNameEn ?? '',
    );
    _brandNameBnController = TextEditingController(
      text: _source.brandNameBn ?? '',
    );
    _brandSlugController = TextEditingController(
      text: _source.brandSlug ?? '',
    );

    _saleStartsAt = _source.saleStartsAt;
    _saleEndsAt = _source.saleEndsAt;
    _publishAt = _source.publishAt;
    _unpublishAt = _source.unpublishAt;
    _deletedAt = _source.deletedAt;

    _saleStartsAtController = TextEditingController(
      text: formatDateTime(_saleStartsAt),
    );
    _saleEndsAtController = TextEditingController(
      text: formatDateTime(_saleEndsAt),
    );
    _publishAtController = TextEditingController(
      text: formatDateTime(_publishAt),
    );
    _unpublishAtController = TextEditingController(
      text: formatDateTime(_unpublishAt),
    );
    _createdByController = TextEditingController(
      text: _source.createdBy ?? '',
    );
    _updatedByController = TextEditingController(
      text: _source.updatedBy ?? '',
    );
    _deletedByController = TextEditingController(
      text: _source.deletedBy ?? '',
    );
    _deleteReasonController = TextEditingController(
      text: _source.deleteReason ?? '',
    );

    _productType = _source.productType.isEmpty ? 'simple' : _source.productType;
    _inventoryMode = _source.inventoryMode.isEmpty
        ? 'stocked'
        : _source.inventoryMode;
    _schedulePriceType = _source.schedulePriceType.isEmpty
        ? 'fixed'
        : _source.schedulePriceType;
    _quantityType = _source.quantityType.isEmpty
        ? 'pcs'
        : _source.quantityType;
    _toleranceType = _source.toleranceType.isEmpty
        ? 'g'
        : _source.toleranceType;
    _deliveryShift = _source.deliveryShift.isEmpty
        ? 'any'
        : _source.deliveryShift;

    _trackInventory = _source.trackInventory;
    _supportsInstantOrder = _source.supportsInstantOrder;
    _supportsScheduledOrder = _source.supportsScheduledOrder;
    _allowBackorder = _source.allowBackorder;
    _isFeatured = _source.isFeatured;
    _isFlashSale = _source.isFlashSale;
    _isEnabled = _source.isEnabled;
    _isNewArrival = _source.isNewArrival;
    _isBestSeller = _source.isBestSeller;
    _isToleranceActive = _source.isToleranceActive;
    _isDeleted = _source.isDeleted;

    _sortOrder = _source.sortOrder;

    _mediaItems = [..._source.mediaItems]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _attributes = [..._source.attributes]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _variations = [..._source.variations]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _purchaseOptions = [..._source.purchaseOptions]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    _selectedCategoryId = _source.categoryId;
    _selectedBrandId = _source.brandId;

    _titleEnController.addListener(_autoGenerateSlug);
  }

  @override
  void dispose() {
    _titleEnController.removeListener(_autoGenerateSlug);

    for (final controller in <TextEditingController>[
      _titleEnController,
      _titleBnController,
      _slugController,
      _productCodeController,
      _skuController,
      _shortDescriptionEnController,
      _shortDescriptionBnController,
      _descriptionEnController,
      _descriptionBnController,
      _tagsController,
      _keywordsController,
      _priceController,
      _salePriceController,
      _costPriceController,
      _estimatedSchedulePriceController,
      _stockQtyController,
      _regularStockQtyController,
      _reservedInstantQtyController,
      _todayInstantCapController,
      _todayInstantSoldController,
      _maxScheduleQtyPerDayController,
      _minScheduleNoticeHoursController,
      _reorderLevelController,
      _instantCutoffTimeController,
      _quantityValueController,
      _toleranceController,
      _minOrderQtyController,
      _maxOrderQtyController,
      _stepQtyController,
      _unitLabelEnController,
      _unitLabelBnController,
      _categoryIdController,
      _categoryNameEnController,
      _categoryNameBnController,
      _categorySlugController,
      _brandIdController,
      _brandNameEnController,
      _brandNameBnController,
      _brandSlugController,
      _saleStartsAtController,
      _saleEndsAtController,
      _publishAtController,
      _unpublishAtController,
      _createdByController,
      _updatedByController,
      _deletedByController,
      _deleteReasonController,
    ]) {
      controller.dispose();
    }

    if (_ownsController) {
      Get.delete<AdminProductController>();
    }
    super.dispose();
  }

  void _autoGenerateSlug() {
    final current = _slugController.text.trim();
    if (current.isNotEmpty && current != simpleSlug(_source.titleEn)) {
      return;
    }

    final generated = simpleSlug(_titleEnController.text);
    if (_slugController.text != generated) {
      _slugController.value = TextEditingValue(
        text: generated,
        selection: TextSelection.collapsed(offset: generated.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = _source.id.trim().isEmpty;

    return Column(
      children: [
        _buildHeader(context, isCreate),
        Expanded(
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfoSection(context),
                        const SizedBox(height: 16),
                        _buildRelationSection(context),
                        const SizedBox(height: 16),
                        _buildMediaSection(context),
                        const SizedBox(height: 16),
                        _buildPricingSection(context),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, color: Theme.of(context).dividerColor),
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVisibilitySection(context),
                        const SizedBox(height: 16),
                        _buildAuditSection(context),
                        const SizedBox(height: 16),
                        _buildPreviewSection(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isCreate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.dialogTitle ??
                      (isCreate ? 'Create Product' : 'Edit Product'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  isCreate
                      ? 'Create a product with media, attributes, variations, and purchase options.'
                      : 'Update product information and advanced selling rules.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Obx(
            () => Row(
          children: [
            Expanded(
              child: _controller.errorMessage.value.trim().isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                _controller.errorMessage.value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: _controller.isSaving.value
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _controller.isSaving.value ? null : _handleSave,
              icon: _controller.isSaving.value
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _controller.isSaving.value ? 'Saving...' : 'Save Product',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return SectionCard(
      title: 'Basic Information',
      subtitle: 'Main identity, descriptions, search tags, and product type.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildTextField(
                  controller: _titleEnController,
                  label: 'Title (English)',
                  validator: requiredValidator,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _titleBnController,
                  label: 'Title (Bangla)',
                  validator: requiredValidator,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildTextField(
                  controller: _slugController,
                  label: 'Slug',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _productCodeController,
                  label: 'Product Code',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _skuController,
                  label: 'Base SKU',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          buildDropdownField<String>(
            label: 'Product Type',
            value: _productType,
            items: const [
              DropdownMenuItem(value: 'simple', child: Text('simple')),
              DropdownMenuItem(value: 'variable', child: Text('variable')),
              DropdownMenuItem(value: 'bundle', child: Text('bundle')),
              DropdownMenuItem(value: 'service_like', child: Text('service_like')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _productType = value);
            },
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildTextField(
                  controller: _shortDescriptionEnController,
                  label: 'Short Description (English)',
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _shortDescriptionBnController,
                  label: 'Short Description (Bangla)',
                  maxLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildTextField(
                  controller: _descriptionEnController,
                  label: 'Description (English)',
                  maxLines: 6,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _descriptionBnController,
                  label: 'Description (Bangla)',
                  maxLines: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildTextField(
                  controller: _tagsController,
                  label: 'Tags (comma separated)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _keywordsController,
                  label: 'Keywords (comma separated)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelationSection(BuildContext context) {
    return SectionCard(
      title: 'Category and Brand',
      subtitle: 'Source relation ids plus display snapshot fields.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildDropdownField<String?>(
                  label: 'Category',
                  value: normalizeDropdownValue(
                    value: _selectedCategoryId,
                    options: widget.availableCategories.map((e) => e.id).toList(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No category'),
                    ),
                    ...widget.availableCategories.map(
                          (item) => DropdownMenuItem<String?>(
                        value: item.id,
                        child: Text('${item.nameEn} (${item.id})'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                      _applyCategorySelection(value);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildDropdownField<String?>(
                  label: 'Brand',
                  value: normalizeDropdownValue(
                    value: _selectedBrandId,
                    options: widget.availableBrands.map((e) => e.id).toList(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No brand'),
                    ),
                    ...widget.availableBrands.map(
                          (item) => DropdownMenuItem<String?>(
                        value: item.id,
                        child: Text('${item.nameEn} (${item.id})'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedBrandId = value;
                      _applyBrandSelection(value);
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildTextField(
                  controller: _categoryIdController,
                  label: 'Category ID',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _categorySlugController,
                  label: 'Category Slug',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildTextField(
                  controller: _categoryNameEnController,
                  label: 'Category Name (English)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _categoryNameBnController,
                  label: 'Category Name (Bangla)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildTextField(
                  controller: _brandIdController,
                  label: 'Brand ID',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _brandSlugController,
                  label: 'Brand Slug',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildTextField(
                  controller: _brandNameEnController,
                  label: 'Brand Name (English)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _brandNameBnController,
                  label: 'Brand Name (Bangla)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    return SectionCard(
      title: 'Media',
      subtitle: 'Rich media items with role, alt text, and ordering.',
      action: FilledButton.icon(
        onPressed: _addMediaItem,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add Media'),
      ),
      child: _mediaItems.isEmpty
          ? const EmptyBlock(message: 'No media items added yet.')
          : Column(
        children: _mediaItems
            .map(
              (item) => EditableTile(
            title: item.labelEn.trim().isEmpty ? item.url : item.labelEn,
            subtitle:
            'role: ${item.role} • type: ${item.type} • order: ${item.sortOrder}',
            leading: item.url.trim().isEmpty
                ? const Icon(Icons.image_not_supported_outlined)
                : PreviewImage(url: item.url),
            onEdit: () => _editMediaItem(item),
            onDelete: () {
              setState(() {
                _mediaItems.removeWhere((element) => element.id == item.id);
              });
            },
          ),
        )
            .toList(),
      ),
    );
  }
  Widget _buildPricingSection(BuildContext context) {
    return SectionCard(
      title: 'Pricing',
      subtitle: 'Regular, sale, cost, and scheduling pricing behavior.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildNumberField(
                  controller: _priceController,
                  label: 'Price',
                  validator: requiredValidator,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildNumberField(
                  controller: _salePriceController,
                  label: 'Sale Price',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildNumberField(
                  controller: _costPriceController,
                  label: 'Cost Price',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildDateTimeField(
                  controller: _saleStartsAtController,
                  label: 'Sale Starts At',
                  onPick: () async {
                    final value = await pickDateTime(context, initial: _saleStartsAt);
                    if (value == null) return;
                    setState(() {
                      _saleStartsAt = value;
                      _saleStartsAtController.text = formatDateTime(value);
                    });
                  },
                  onClear: () {
                    setState(() {
                      _saleStartsAt = null;
                      _saleStartsAtController.clear();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildDateTimeField(
                  controller: _saleEndsAtController,
                  label: 'Sale Ends At',
                  onPick: () async {
                    final value = await pickDateTime(context, initial: _saleEndsAt);
                    if (value == null) return;
                    setState(() {
                      _saleEndsAt = value;
                      _saleEndsAtController.text = formatDateTime(value);
                    });
                  },
                  onClear: () {
                    setState(() {
                      _saleEndsAt = null;
                      _saleEndsAtController.clear();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildDropdownField<String>(
                  label: 'Schedule Price Type',
                  value: _schedulePriceType,
                  items: const [
                    DropdownMenuItem(value: 'fixed', child: Text('fixed')),
                    DropdownMenuItem(value: 'estimated', child: Text('estimated')),
                    DropdownMenuItem(value: 'market', child: Text('market')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _schedulePriceType = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildNumberField(
                  controller: _estimatedSchedulePriceController,
                  label: 'Estimated Schedule Price',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySection(BuildContext context) {
    return SectionCard(
      title: 'Inventory and Availability',
      subtitle: 'Inventory mode, stock, schedule capacity, and backorder rules.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildDropdownField<String>(
                  label: 'Inventory Mode',
                  value: _inventoryMode,
                  items: const [
                    DropdownMenuItem(value: 'stocked', child: Text('stocked')),
                    DropdownMenuItem(value: 'hybrid_fresh', child: Text('hybrid_fresh')),
                    DropdownMenuItem(value: 'schedule_only', child: Text('schedule_only')),
                    DropdownMenuItem(value: 'untracked', child: Text('untracked')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _inventoryMode = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _instantCutoffTimeController,
                  label: 'Instant Cutoff Time',
                  hintText: 'e.g. 17:00',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              buildFilterChip(
                label: 'Track Inventory',
                selected: _trackInventory,
                onSelected: (value) => setState(() => _trackInventory = value),
              ),
              buildFilterChip(
                label: 'Supports Instant Order',
                selected: _supportsInstantOrder,
                onSelected: (value) => setState(() => _supportsInstantOrder = value),
              ),
              buildFilterChip(
                label: 'Supports Scheduled Order',
                selected: _supportsScheduledOrder,
                onSelected: (value) => setState(() => _supportsScheduledOrder = value),
              ),
              buildFilterChip(
                label: 'Allow Backorder',
                selected: _allowBackorder,
                onSelected: (value) => setState(() => _allowBackorder = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildIntField(
                  controller: _stockQtyController,
                  label: 'Legacy Stock Qty',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildIntField(
                  controller: _regularStockQtyController,
                  label: 'Regular Stock Qty',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildIntField(
                  controller: _reservedInstantQtyController,
                  label: 'Reserved Instant Qty',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildIntField(
                  controller: _todayInstantCapController,
                  label: 'Today Instant Cap',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildIntField(
                  controller: _todayInstantSoldController,
                  label: 'Today Instant Sold',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildIntField(
                  controller: _maxScheduleQtyPerDayController,
                  label: 'Max Schedule Qty / Day',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildIntField(
                  controller: _minScheduleNoticeHoursController,
                  label: 'Min Schedule Notice Hours',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildIntField(
                  controller: _reorderLevelController,
                  label: 'Reorder Level',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(BuildContext context) {
    return SectionCard(
      title: 'Quantity, Packaging, and Tolerance',
      subtitle: 'Units, minimum and maximum quantities, and weight tolerance rules.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildDropdownField<String>(
                  label: 'Quantity Type',
                  value: _quantityType,
                  items: const [
                    DropdownMenuItem(value: 'pcs', child: Text('pcs')),
                    DropdownMenuItem(value: 'kg', child: Text('kg')),
                    DropdownMenuItem(value: 'g', child: Text('g')),
                    DropdownMenuItem(value: 'litre', child: Text('litre')),
                    DropdownMenuItem(value: 'ml', child: Text('ml')),
                    DropdownMenuItem(value: 'pack', child: Text('pack')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _quantityType = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildNumberField(
                  controller: _quantityValueController,
                  label: 'Quantity Value',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildDropdownField<String>(
                  label: 'Tolerance Type',
                  value: _toleranceType,
                  items: const [
                    DropdownMenuItem(value: 'g', child: Text('g')),
                    DropdownMenuItem(value: 'kg', child: Text('kg')),
                    DropdownMenuItem(value: '%', child: Text('%')),
                    DropdownMenuItem(value: 'ml', child: Text('ml')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _toleranceType = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildNumberField(
                  controller: _toleranceController,
                  label: 'Tolerance',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildNumberField(
                  controller: _minOrderQtyController,
                  label: 'Min Order Qty',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildNumberField(
                  controller: _maxOrderQtyController,
                  label: 'Max Order Qty',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildNumberField(
                  controller: _stepQtyController,
                  label: 'Step Qty',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _unitLabelEnController,
                  label: 'Unit Label (English)',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTextField(
                  controller: _unitLabelBnController,
                  label: 'Unit Label (Bangla)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildDropdownField<String>(
                  label: 'Delivery Shift',
                  value: _deliveryShift,
                  items: const [
                    DropdownMenuItem(value: 'any', child: Text('any')),
                    DropdownMenuItem(value: 'morning', child: Text('morning')),
                    DropdownMenuItem(value: 'afternoon', child: Text('afternoon')),
                    DropdownMenuItem(value: 'evening', child: Text('evening')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _deliveryShift = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: buildFilterChip(
                    label: 'Tolerance Active',
                    selected: _isToleranceActive,
                    onSelected: (value) {
                      setState(() => _isToleranceActive = value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesSection(BuildContext context) {
    return SectionCard(
      title: 'Attributes',
      subtitle: 'Rich attribute groups with value objects.',
      action: FilledButton.icon(
        onPressed: _addAttribute,
        icon: const Icon(Icons.add),
        label: const Text('Add Attribute'),
      ),
      child: _attributes.isEmpty
          ? const EmptyBlock(message: 'No attributes added yet.')
          : Column(
        children: _attributes
            .map(
              (item) => EditableTile(
            title: item.nameEn,
            subtitle:
            'values: ${item.values.length} • variation: ${item.useForVariation} • order: ${item.sortOrder}',
            onEdit: () => _editAttribute(item),
            onDelete: () {
              setState(() {
                _attributes.removeWhere((element) => element.id == item.id);
              });
            },
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildVariationsSection(BuildContext context) {
    return SectionCard(
      title: 'Variations',
      subtitle: 'Concrete sellable variations for variable products.',
      action: FilledButton.icon(
        onPressed: _addVariation,
        icon: const Icon(Icons.add),
        label: const Text('Add Variation'),
      ),
      child: _variations.isEmpty
          ? const EmptyBlock(message: 'No variations added yet.')
          : Column(
        children: _variations
            .map(
              (item) => EditableTile(
            title: item.titleEn.trim().isEmpty ? item.id : item.titleEn,
            subtitle:
            'price: ${item.price} • stock: ${item.stockQty} • default: ${item.isDefault}',
            onEdit: () => _editVariation(item),
            onDelete: () {
              setState(() {
                _variations.removeWhere((element) => element.id == item.id);
              });
            },
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildPurchaseOptionsSection(BuildContext context) {
    return SectionCard(
      title: 'Purchase Options',
      subtitle: 'Instant and scheduled selling modes.',
      action: FilledButton.icon(
        onPressed: _addPurchaseOption,
        icon: const Icon(Icons.add),
        label: const Text('Add Purchase Option'),
      ),
      child: _purchaseOptions.isEmpty
          ? const EmptyBlock(message: 'No purchase options added yet.')
          : Column(
        children: _purchaseOptions
            .map(
              (item) => EditableTile(
            title: item.labelEn,
            subtitle:
            'mode: ${item.mode} • price: ${item.price} • default: ${item.isDefault}',
            onEdit: () => _editPurchaseOption(item),
            onDelete: () {
              setState(() {
                _purchaseOptions.removeWhere((element) => element.id == item.id);
              });
            },
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildVisibilitySection(BuildContext context) {
    return SectionCard(
      title: 'Visibility and Merchandising',
      subtitle: 'Publishing, status, and merchandising flags.',
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              buildFilterChip(
                label: 'Enabled',
                selected: _isEnabled,
                onSelected: (value) => setState(() => _isEnabled = value),
              ),
              buildFilterChip(
                label: 'Featured',
                selected: _isFeatured,
                onSelected: (value) => setState(() => _isFeatured = value),
              ),
              buildFilterChip(
                label: 'Flash Sale',
                selected: _isFlashSale,
                onSelected: (value) => setState(() => _isFlashSale = value),
              ),
              buildFilterChip(
                label: 'New Arrival',
                selected: _isNewArrival,
                onSelected: (value) => setState(() => _isNewArrival = value),
              ),
              buildFilterChip(
                label: 'Best Seller',
                selected: _isBestSeller,
                onSelected: (value) => setState(() => _isBestSeller = value),
              ),
              buildFilterChip(
                label: 'Deleted',
                selected: _isDeleted,
                onSelected: (value) => setState(() => _isDeleted = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          buildIntStepper(
            context,
            label: 'Sort Order',
            value: _sortOrder,
            onChanged: (value) => setState(() => _sortOrder = value),
          ),
          const SizedBox(height: 12),
          buildDateTimeField(
            controller: _publishAtController,
            label: 'Publish At',
            onPick: () async {
              final value = await pickDateTime(context, initial: _publishAt);
              if (value == null) return;
              setState(() {
                _publishAt = value;
                _publishAtController.text = formatDateTime(value);
              });
            },
            onClear: () {
              setState(() {
                _publishAt = null;
                _publishAtController.clear();
              });
            },
          ),
          const SizedBox(height: 12),
          buildDateTimeField(
            controller: _unpublishAtController,
            label: 'Unpublish At',
            onPick: () async {
              final value = await pickDateTime(context, initial: _unpublishAt);
              if (value == null) return;
              setState(() {
                _unpublishAt = value;
                _unpublishAtController.text = formatDateTime(value);
              });
            },
            onClear: () {
              setState(() {
                _unpublishAt = null;
                _unpublishAtController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuditSection(BuildContext context) {
    return SectionCard(
      title: 'Audit Metadata',
      subtitle: 'Operational and delete metadata.',
      child: Column(
        children: [
          buildTextField(
            controller: _createdByController,
            label: 'Created By',
          ),
          const SizedBox(height: 12),
          buildTextField(
            controller: _updatedByController,
            label: 'Updated By',
          ),
          const SizedBox(height: 12),
          buildTextField(
            controller: _deletedByController,
            label: 'Deleted By',
          ),
          const SizedBox(height: 12),
          buildTextField(
            controller: _deleteReasonController,
            label: 'Delete Reason',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          buildReadOnlyInfoRow('Created At', formatDateTime(_source.createdAt)),
          buildReadOnlyInfoRow('Updated At', formatDateTime(_source.updatedAt)),
          buildReadOnlyInfoRow('Deleted At', formatDateTime(_deletedAt)),
        ],
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    final preview = _buildProductFromForm();

    return SectionCard(
      title: 'Live Preview Summary',
      subtitle: 'Quick sanity-check before save.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (preview.resolvedThumbnailUrl.trim().isNotEmpty)
            PreviewLargeImage(url: preview.resolvedThumbnailUrl)
          else
            const EmptyPreviewImage(),
          const SizedBox(height: 12),
          Text(
            preview.titleEn.isEmpty ? 'Untitled Product' : preview.titleEn,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'slug: ${preview.slug.isEmpty ? '-' : preview.slug}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildInfoChip('type: ${preview.productType}'),
              buildInfoChip('price: ${preview.price.toStringAsFixed(2)}'),
              buildInfoChip('enabled: ${preview.isEnabled}'),
              buildInfoChip('deleted: ${preview.isDeleted}'),
              buildInfoChip('media: ${preview.mediaItems.length}'),
              buildInfoChip('attributes: ${preview.attributes.length}'),
              buildInfoChip('variations: ${preview.variations.length}'),
              buildInfoChip('options: ${preview.purchaseOptions.length}'),
            ],
          ),
          const SizedBox(height: 12),
          buildReadOnlyInfoRow('Category', preview.categoryNameEn ?? '-'),
          buildReadOnlyInfoRow('Brand', preview.brandNameEn ?? '-'),
          buildReadOnlyInfoRow('Stock', preview.stockQty.toString()),
          buildReadOnlyInfoRow(
            'Published Now',
            preview.isPublishedNow.toString(),
          ),
          buildReadOnlyInfoRow('In Stock', preview.inStock.toString()),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final product = _buildProductFromForm();
    var saved = await _controller.saveProduct(
      product: product,
      actorUid: widget.actorUid,
      actorName: widget.actorName,
      actorPhone: widget.actorPhone,
      actorRole: widget.actorRole,
    );

    saved ??= await _waitForRecoveredSavedProduct(product);

    if (!mounted || saved == null) return;

    _controller.clearError();

    final navigator = Navigator.of(context);
    navigator.pop(saved);

    try {
      widget.onSaved?.call(saved);
    } catch (_) {
      // Ignore callback failures after the dialog has already closed.
    }
  }

  Future<MBProduct?> _waitForRecoveredSavedProduct(MBProduct draft) async {
    for (var attempt = 0; attempt < 12; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      final recovered = _matchRecoveredProduct(draft);
      if (recovered != null) {
        return recovered;
      }
    }

    return null;
  }

  MBProduct? _matchRecoveredProduct(MBProduct draft) {
    final draftId = draft.id.trim();
    final draftSlug = draft.slug.trim().toLowerCase();
    final draftCode = (draft.productCode ?? '').trim().toLowerCase();
    final draftSku = (draft.sku ?? '').trim().toLowerCase();
    final draftTitleEn = draft.titleEn.trim().toLowerCase();
    final draftTitleBn = draft.titleBn.trim().toLowerCase();

    for (final item in _controller.products) {
      final itemId = item.id.trim();
      final itemSlug = item.slug.trim().toLowerCase();
      final itemCode = (item.productCode ?? '').trim().toLowerCase();
      final itemSku = (item.sku ?? '').trim().toLowerCase();
      final itemTitleEn = item.titleEn.trim().toLowerCase();
      final itemTitleBn = item.titleBn.trim().toLowerCase();

      if (draftId.isNotEmpty && itemId == draftId) {
        return item;
      }

      if (draftSlug.isNotEmpty &&
          (itemSlug == draftSlug || itemSlug.startsWith('$draftSlug-'))) {
        return item;
      }

      if (draftCode.isNotEmpty && itemCode == draftCode) {
        return item;
      }

      if (draftSku.isNotEmpty && itemSku == draftSku) {
        return item;
      }

      if (draftTitleEn.isNotEmpty && itemTitleEn == draftTitleEn) {
        return item;
      }

      if (draftTitleBn.isNotEmpty && itemTitleBn == draftTitleBn) {
        return item;
      }
    }

    return null;
  }

  MBProduct _buildProductFromForm() {
    final now = DateTime.now();
    final media = [..._mediaItems]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final derivedThumbnail = deriveThumbnailUrl(media);
    final derivedImageUrls = media
        .where((item) => item.isEnabled && item.type == 'image')
        .map((item) => item.url.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();

    return (_source.id.trim().isEmpty ? MBProduct.empty() : _source).copyWith(
      id: _source.id,
      slug: _slugController.text.trim(),
      productCode: _productCodeController.text.trim().isEmpty
          ? null
          : _productCodeController.text.trim(),
      clearProductCode: _productCodeController.text.trim().isEmpty,
      sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
      clearSku: _skuController.text.trim().isEmpty,
      titleEn: _titleEnController.text.trim(),
      titleBn: _titleBnController.text.trim(),
      shortDescriptionEn: _shortDescriptionEnController.text.trim(),
      shortDescriptionBn: _shortDescriptionBnController.text.trim(),
      descriptionEn: _descriptionEnController.text.trim(),
      descriptionBn: _descriptionBnController.text.trim(),
      thumbnailUrl: derivedThumbnail,
      imageUrls: derivedImageUrls,
      mediaItems: media,
      price: parseDouble(_priceController.text),
      salePrice: parseNullableDouble(_salePriceController.text),
      clearSalePrice: parseNullableDouble(_salePriceController.text) == null,
      costPrice: parseNullableDouble(_costPriceController.text),
      clearCostPrice: parseNullableDouble(_costPriceController.text) == null,
      saleStartsAt: _saleStartsAt,
      clearSaleStartsAt: _saleStartsAt == null,
      saleEndsAt: _saleEndsAt,
      clearSaleEndsAt: _saleEndsAt == null,
      stockQty: parseInt(_stockQtyController.text),
      inventoryMode: _inventoryMode,
      trackInventory: _trackInventory,
      supportsInstantOrder: _supportsInstantOrder,
      supportsScheduledOrder: _supportsScheduledOrder,
      regularStockQty: parseInt(_regularStockQtyController.text),
      reservedInstantQty: parseInt(_reservedInstantQtyController.text),
      todayInstantCap: parseInt(
        _todayInstantCapController.text,
        fallback: 999999,
      ),
      todayInstantSold: parseInt(_todayInstantSoldController.text),
      maxScheduleQtyPerDay: parseInt(
        _maxScheduleQtyPerDayController.text,
        fallback: 999999,
      ),
      schedulePriceType: _schedulePriceType,
      estimatedSchedulePrice: parseNullableDouble(
        _estimatedSchedulePriceController.text,
      ),
      clearEstimatedSchedulePrice:
      parseNullableDouble(_estimatedSchedulePriceController.text) == null,
      instantCutoffTime: _instantCutoffTimeController.text.trim().isEmpty
          ? null
          : _instantCutoffTimeController.text.trim(),
      clearInstantCutoffTime: _instantCutoffTimeController.text.trim().isEmpty,
      minScheduleNoticeHours: parseInt(_minScheduleNoticeHoursController.text),
      reorderLevel: parseInt(_reorderLevelController.text),
      allowBackorder: _allowBackorder,
      categoryId: _categoryIdController.text.trim().isEmpty
          ? null
          : _categoryIdController.text.trim(),
      clearCategoryId: _categoryIdController.text.trim().isEmpty,
      categoryNameEn: _categoryNameEnController.text.trim().isEmpty
          ? null
          : _categoryNameEnController.text.trim(),
      clearCategoryNameEn: _categoryNameEnController.text.trim().isEmpty,
      categoryNameBn: _categoryNameBnController.text.trim().isEmpty
          ? null
          : _categoryNameBnController.text.trim(),
      clearCategoryNameBn: _categoryNameBnController.text.trim().isEmpty,
      categorySlug: _categorySlugController.text.trim().isEmpty
          ? null
          : _categorySlugController.text.trim(),
      clearCategorySlug: _categorySlugController.text.trim().isEmpty,
      brandId: _brandIdController.text.trim().isEmpty
          ? null
          : _brandIdController.text.trim(),
      clearBrandId: _brandIdController.text.trim().isEmpty,
      brandNameEn: _brandNameEnController.text.trim().isEmpty
          ? null
          : _brandNameEnController.text.trim(),
      clearBrandNameEn: _brandNameEnController.text.trim().isEmpty,
      brandNameBn: _brandNameBnController.text.trim().isEmpty
          ? null
          : _brandNameBnController.text.trim(),
      clearBrandNameBn: _brandNameBnController.text.trim().isEmpty,
      brandSlug: _brandSlugController.text.trim().isEmpty
          ? null
          : _brandSlugController.text.trim(),
      clearBrandSlug: _brandSlugController.text.trim().isEmpty,
      productType: _productType,
      tags: splitCsv(_tagsController.text),
      keywords: splitCsv(_keywordsController.text),
      attributes: [..._attributes]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      variations: [..._variations]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      purchaseOptions: [..._purchaseOptions]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      isFeatured: _isFeatured,
      isFlashSale: _isFlashSale,
      isEnabled: _isEnabled,
      isNewArrival: _isNewArrival,
      isBestSeller: _isBestSeller,
      sortOrder: _sortOrder,
      publishAt: _publishAt,
      clearPublishAt: _publishAt == null,
      unpublishAt: _unpublishAt,
      clearUnpublishAt: _unpublishAt == null,
      quantityType: _quantityType,
      quantityValue: parseDouble(_quantityValueController.text),
      toleranceType: _toleranceType,
      tolerance: parseDouble(_toleranceController.text),
      isToleranceActive: _isToleranceActive,
      deliveryShift: _deliveryShift,
      minOrderQty: parseNullableDouble(_minOrderQtyController.text),
      clearMinOrderQty: parseNullableDouble(_minOrderQtyController.text) == null,
      maxOrderQty: parseNullableDouble(_maxOrderQtyController.text),
      clearMaxOrderQty: parseNullableDouble(_maxOrderQtyController.text) == null,
      stepQty: parseNullableDouble(_stepQtyController.text),
      clearStepQty: parseNullableDouble(_stepQtyController.text) == null,
      unitLabelEn: _unitLabelEnController.text.trim().isEmpty
          ? null
          : _unitLabelEnController.text.trim(),
      clearUnitLabelEn: _unitLabelEnController.text.trim().isEmpty,
      unitLabelBn: _unitLabelBnController.text.trim().isEmpty
          ? null
          : _unitLabelBnController.text.trim(),
      clearUnitLabelBn: _unitLabelBnController.text.trim().isEmpty,
      isDeleted: _isDeleted,
      deletedAt: _isDeleted ? (_deletedAt ?? now) : null,
      clearDeletedAt: !_isDeleted,
      deletedBy: _deletedByController.text.trim().isEmpty
          ? (_isDeleted ? widget.actorUid : null)
          : _deletedByController.text.trim(),
      clearDeletedBy: !_isDeleted && _deletedByController.text.trim().isEmpty,
      deleteReason: _deleteReasonController.text.trim().isEmpty
          ? null
          : _deleteReasonController.text.trim(),
      clearDeleteReason: _deleteReasonController.text.trim().isEmpty,
      createdBy: _createdByController.text.trim().isEmpty
          ? null
          : _createdByController.text.trim(),
      clearCreatedBy: _createdByController.text.trim().isEmpty,
      updatedBy: _updatedByController.text.trim().isEmpty
          ? null
          : _updatedByController.text.trim(),
      clearUpdatedBy: _updatedByController.text.trim().isEmpty,
      createdAt: _source.createdAt,
      updatedAt: now,
    );
  }

  void _applyCategorySelection(String? value) {
    final option = widget.availableCategories.firstWhereOrNull(
          (item) => item.id == value,
    );
    _categoryIdController.text = option?.id ?? '';
    _categoryNameEnController.text = option?.nameEn ?? '';
    _categoryNameBnController.text = option?.nameBn ?? '';
    _categorySlugController.text = option?.slug ?? '';
  }

  void _applyBrandSelection(String? value) {
    final option = widget.availableBrands.firstWhereOrNull(
          (item) => item.id == value,
    );
    _brandIdController.text = option?.id ?? '';
    _brandNameEnController.text = option?.nameEn ?? '';
    _brandNameBnController.text = option?.nameBn ?? '';
    _brandSlugController.text = option?.slug ?? '';
  }

  Future<void> _addMediaItem() async {
    final result = await showDialog<MBProductMedia>(
      context: context,
      builder: (_) => MediaItemDialog(
        initialValue: MBProductMedia(
          id: makeEditorId('media'),
          url: '',
          sortOrder: _mediaItems.length,
          isPrimary: _mediaItems.isEmpty,
          role: _mediaItems.isEmpty ? 'thumbnail' : 'gallery',
        ),
      ),
    );

    if (result == null) return;
    setState(() {
      _mediaItems.add(result);
      _mediaItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Future<void> _editMediaItem(MBProductMedia item) async {
    final result = await showDialog<MBProductMedia>(
      context: context,
      builder: (_) => MediaItemDialog(initialValue: item),
    );

    if (result == null) return;
    setState(() {
      final index = _mediaItems.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _mediaItems[index] = result;
        _mediaItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
    });
  }

  Future<void> _addAttribute() async {
    final result = await showDialog<MBProductAttribute>(
      context: context,
      builder: (_) => AttributeDialog(
        initialValue: MBProductAttribute(
          id: makeEditorId('attribute'),
          nameEn: '',
          nameBn: '',
          sortOrder: _attributes.length,
        ),
      ),
    );

    if (result == null) return;
    setState(() {
      _attributes.add(result);
      _attributes.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Future<void> _editAttribute(MBProductAttribute item) async {
    final result = await showDialog<MBProductAttribute>(
      context: context,
      builder: (_) => AttributeDialog(initialValue: item),
    );

    if (result == null) return;
    setState(() {
      final index = _attributes.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _attributes[index] = result;
        _attributes.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
    });
  }

  Future<void> _addVariation() async {
    final result = await showDialog<MBProductVariation>(
      context: context,
      builder: (_) => VariationDialog(
        initialValue: MBProductVariation(
          id: makeEditorId('variation'),
          sortOrder: _variations.length,
        ),
      ),
    );

    if (result == null) return;
    setState(() {
      _variations.add(result);
      _variations.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Future<void> _editVariation(MBProductVariation item) async {
    final result = await showDialog<MBProductVariation>(
      context: context,
      builder: (_) => VariationDialog(initialValue: item),
    );

    if (result == null) return;
    setState(() {
      final index = _variations.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _variations[index] = result;
        _variations.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
    });
  }

  Future<void> _addPurchaseOption() async {
    final result = await showDialog<MBProductPurchaseOption>(
      context: context,
      builder: (_) => PurchaseOptionDialog(
        initialValue: MBProductPurchaseOption(
          id: makeEditorId('option'),
          mode: 'instant',
          labelEn: '',
          labelBn: '',
          price: 0,
          sortOrder: _purchaseOptions.length,
        ),
      ),
    );

    if (result == null) return;
    setState(() {
      _purchaseOptions.add(result);
      _purchaseOptions.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Future<void> _editPurchaseOption(MBProductPurchaseOption item) async {
    final result = await showDialog<MBProductPurchaseOption>(
      context: context,
      builder: (_) => PurchaseOptionDialog(initialValue: item),
    );

    if (result == null) return;
    setState(() {
      final index = _purchaseOptions.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _purchaseOptions[index] = result;
        _purchaseOptions.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
    });
  }
}

