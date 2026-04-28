import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

import '../controllers/admin_product_controller.dart';
import 'admin_product_card_picker_dialog.dart';
import 'admin_product_form_support.dart';
import 'admin_product_card_settings_dialog.dart';
import 'card_design/admin_card_design_studio_dialog.dart';
import 'card_studio/admin_product_card_studio_dialog.dart';

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
  late String _cardLayoutType;

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
  bool get _showProductLevelInventory => !_isVariableProduct;

  bool get _showProductLevelQuantity => !_isVariableProduct;

  bool kProductSaveDebugDumpEnabled = true;

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
  bool get _isVariableProduct => _productType.trim().toLowerCase() == 'variable';

  AdminProductCardSettingsResult? _cardSettingsDraft;
  /// New design-family card JSON returned from MBCardDesignStudio.
  ///
  /// This lives beside the old cardConfig while the new design engine is
  /// being rolled out.
  String? _cardDesignJson;

  bool get _hasCardDesignJson {
    final value = _cardDesignJson;
    return value != null && value.trim().isNotEmpty;
  }
  MBCardInstanceConfig? _cardConfigDraft;

  MBProductVariation? get _primaryVariationForOwnership {
    for (final item in _variations) {
      if (item.isEnabled && item.isDefault) {
        return item;
      }
    }

    for (final item in _variations) {
      if (item.isEnabled) {
        return item;
      }
    }

    if (_variations.isNotEmpty) {
      return _variations.first;
    }

    return null;
  }

  List<MBProductMedia> get _effectiveProductMediaItems {
    if (_isVariableProduct) {
      return const <MBProductMedia>[];
    }

    final media = [..._mediaItems]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return media;
  }

  String? get _effectiveThumbnailUrl {
    if (_isVariableProduct) {
      final url =
          _primaryVariationForOwnership?.effectiveThumbImageUrl.trim() ?? '';
      return url.isEmpty ? null : url;
    }

    return deriveThumbnailUrl(_effectiveProductMediaItems);
  }

  List<String> get _effectiveImageUrls {
    if (_isVariableProduct) {
      final url =
          _primaryVariationForOwnership?.effectiveFullImageUrl.trim() ?? '';
      if (url.isEmpty) return <String>[];
      return <String>[url];
    }

    return _effectiveProductMediaItems
        .where((item) => item.isEnabled && item.type == 'image')
        .map((item) => item.effectiveFullUrl.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  double get _effectiveRootPrice {
    if (_isVariableProduct) {
      return _primaryVariationForOwnership?.price ?? 0;
    }

    return parseDouble(_priceController.text);
  }

  double? get _effectiveRootSalePrice {
    if (_isVariableProduct) {
      return _primaryVariationForOwnership?.salePrice;
    }

    return parseNullableDouble(_salePriceController.text);
  }

  double? get _effectiveRootCostPrice {
    if (_isVariableProduct) {
      return _primaryVariationForOwnership?.costPrice;
    }

    return parseNullableDouble(_costPriceController.text);
  }

  double get _effectivePreviewPrice {
    if (_isVariableProduct) {
      return _primaryVariationForOwnership?.effectivePrice ?? 0;
    }

    final preview = _buildProductFromForm();
    return preview.effectivePrice;
  }

  bool get _showProductLevelMedia => !_isVariableProduct;

  bool get _showProductLevelPricing => !_isVariableProduct;

  bool get _showAttributesSection => _isVariableProduct;

  bool get _showVariationsSection => _isVariableProduct;

  String get _productTypeHelpText {
    if (_isVariableProduct) {
      return 'Variable product: pricing, media, and future merchandising flags should be managed inside variations. Root merchandising flags should not be treated as the source of truth.';
    }

    return 'Non-variable product: pricing, media, and merchandising are managed at product level.';
  }

  String _normalizedDialogKey(String value) => value.trim().toLowerCase();

  List<MBProductAttribute> get _variationAttributesSnapshot {
    final items = _attributes
        .where(
          (attribute) =>
      attribute.useForVariation &&
          attribute.values.any(
                (value) => value.isEnabled && value.value.trim().isNotEmpty,
          ),
    )
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return items;
  }

  Future<void> _showDialogPrompt(String title, String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSelectedCardSettingsDialog(BuildContext context) async {
    await _openCardStudioDialog(
      context,
      initialMode: AdminProductCardStudioMode.edit,
    );
  }


  String? _findDuplicateAttributeMessage(
      MBProductAttribute candidate, {
        String? excludeId,
      }) {
    final candidateId = _normalizedDialogKey(candidate.id);
    final candidateCode = _normalizedDialogKey(candidate.code);
    final candidateNameEn = _normalizedDialogKey(candidate.nameEn);

    for (final item in _attributes) {
      if (excludeId != null && item.id == excludeId) {
        continue;
      }

      if (candidateId.isNotEmpty &&
          _normalizedDialogKey(item.id) == candidateId) {
        return 'An attribute with the same id already exists.';
      }

      if (candidateCode.isNotEmpty &&
          _normalizedDialogKey(item.code) == candidateCode) {
        return 'An attribute with the same code already exists.';
      }

      if (candidateNameEn.isNotEmpty &&
          _normalizedDialogKey(item.nameEn) == candidateNameEn) {
        return 'An attribute with the same English name already exists.';
      }
    }

    return null;
  }

  String _variationSignatureOnPage(MBProductVariation variation) {
    final parts = <String>[];

    for (final attribute in _variationAttributesSnapshot) {
      final code = attribute.code.trim();
      final byId = variation.attributeValues[attribute.id]?.trim() ?? '';
      final byCode = code.isEmpty
          ? ''
          : (variation.attributeValues[code]?.trim() ?? '');
      final selected = byId.isNotEmpty ? byId : byCode;

      if (selected.isNotEmpty) {
        parts.add(
          '${_normalizedDialogKey(attribute.id)}=${_normalizedDialogKey(selected)}',
        );
      }
    }

    parts.sort();
    return parts.join('|');
  }

  String? _findDuplicateVariationMessage(
      MBProductVariation candidate, {
        String? excludeId,
      }) {
    final candidateId = _normalizedDialogKey(candidate.id);
    final candidateSku = _normalizedDialogKey(candidate.sku);
    final candidateBarcode =
    _normalizedDialogKey((candidate.barcode ?? '').trim());
    final candidateSignature = _variationSignatureOnPage(candidate);

    for (final item in _variations) {
      if (excludeId != null && item.id == excludeId) {
        continue;
      }

      if (candidateId.isNotEmpty &&
          _normalizedDialogKey(item.id) == candidateId) {
        return 'A variation with the same id already exists.';
      }

      if (candidateSku.isNotEmpty &&
          _normalizedDialogKey(item.sku) == candidateSku) {
        return 'A variation with the same SKU already exists.';
      }

      if (candidateBarcode.isNotEmpty &&
          _normalizedDialogKey((item.barcode ?? '').trim()) == candidateBarcode) {
        return 'A variation with the same barcode already exists.';
      }

      final existingSignature = _variationSignatureOnPage(item);
      if (candidateSignature.isNotEmpty &&
          existingSignature.isNotEmpty &&
          candidateSignature == existingSignature) {
        return 'A variation with the same attribute combination already exists.';
      }
    }

    return null;
  }

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
    final initialCardConfig = _source.effectiveCardConfig.normalized();
    _cardLayoutType = _normalizeAdminCardVariantId(initialCardConfig.variantId);
    _cardSettingsDraft = _cardSettingsDraftFromConfig(initialCardConfig);
    _cardDesignJson = _source.cardDesignJson;
    _cardConfigDraft = initialCardConfig;

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

                        // PERSISTED FIELDS ONLY BELOW

                        _buildVisibilitySection(context),

                        const SizedBox(height: 16),

                        if (_showProductLevelMedia) ...[
                          _buildMediaSection(context),
                          const SizedBox(height: 16),
                        ],

                        if (_showProductLevelPricing) ...[
                          _buildPricingSection(context),
                          const SizedBox(height: 16),
                        ],

                        if (_showProductLevelInventory) ...[
                          _buildInventorySection(context),
                          const SizedBox(height: 16),
                        ],

                        if (_showProductLevelQuantity) ...[
                          _buildQuantitySection(context),
                          const SizedBox(height: 16),
                        ],

                        if (_showAttributesSection) ...[
                          _buildAttributesSection(context),
                          const SizedBox(height: 16),
                        ],

                        if (_showVariationsSection) ...[
                          _buildVariationsSection(context),
                          const SizedBox(height: 16),
                        ],

                        _buildPurchaseOptionsSection(context),
                        const SizedBox(height: 16),

                        _buildCardStyleSection(context),
                        const SizedBox(height: 16),
                        _buildAuditSection(context),
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
                        _buildEditingModeGuideSection(context),
                        const SizedBox(height: 16),
                        _buildLiveCompositionSummarySection(context),
                        const SizedBox(height: 16),
                        if (_isVariableProduct) ...[
                          _buildVariationMerchandisingSummarySection(context),
                          const SizedBox(height: 16),
                        ],
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
                      ? 'Create a product with type-aware editing. The left panel contains Firestore-persisted fields only, while the right panel is preview and summary only.'
                      : 'Update product information with persisted product fields on the left and preview-only helper sections on the right.',
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


  Widget _buildEditingModeGuideSection(BuildContext context) {
    return SectionCard(
      title: 'Editing Mode Guide',
      subtitle: 'Right panel helper only. This block is not saved to Firestore.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModeGuideRow(
            context,
            icon: Icons.layers_outlined,
            title: _isVariableProduct ? 'Variable Product Mode' : 'Simple Product Mode',
            description: _isVariableProduct
                ? 'Use attributes and variations for sellable combinations. Product-level media, pricing, inventory, and quantity fields are hidden because ownership moves to variations.'
                : 'Use product-level media, pricing, inventory, quantity, and merchandising flags directly on the root product document.',
          ),
          const SizedBox(height: 12),
          _buildModeGuideRow(
            context,
            icon: Icons.save_outlined,
            title: 'What saves from the left panel',
            description:
            'Basic info, category/brand, visibility, card style, product media, pricing, inventory, quantity, attributes, variations, purchase options, and audit fields.',
          ),
          const SizedBox(height: 12),
          _buildModeGuideRow(
            context,
            icon: Icons.visibility_outlined,
            title: 'What does NOT save from the right panel',
            description:
            'This guide, the live composition summary, and preview blocks are helper-only. They should not write anything unless a value is explicitly mapped in _buildProductFromForm().',
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCompositionSummarySection(BuildContext context) {
    final variationCount = _variations.length;
    final enabledVariationCount = _variations.where((item) => item.isEnabled).length;
    final defaultVariationCount = _variations.where((item) => item.isDefault).length;

    return SectionCard(
      title: 'Live Composition Summary',
      subtitle: 'Right panel helper only. Quick overview of what will be composed.',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          buildInfoChip('type: $_productType'),
          buildInfoChip('root media: ${_mediaItems.length}'),
          buildInfoChip('attributes: ${_attributes.length}'),
          buildInfoChip('variations: $variationCount'),
          buildInfoChip('enabled variations: $enabledVariationCount'),
          buildInfoChip('default variations: $defaultVariationCount'),
          buildInfoChip('purchase options: ${_purchaseOptions.length}'),
          buildInfoChip('root featured: $_isFeatured'),
          buildInfoChip('root flash sale: $_isFlashSale'),
          buildInfoChip('root new arrival: $_isNewArrival'),
          buildInfoChip('root best seller: $_isBestSeller'),
        ],
      ),
    );
  }

  Widget _buildVariationMerchandisingSummarySection(BuildContext context) {
    return SectionCard(
      title: 'Variation Merchandising Summary',
      subtitle: 'Right panel helper only. Phase 1 note for variable-product merchandising.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variable products should not rely on root merchandising flags for auto home-section logic.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Phase 1 rule in this dialog: root flags are not persisted for variable products. Variation-level flags must be added in MBProductVariation and VariationDialog next.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (_variations.isEmpty)
            const Text('No variations added yet.')
          else
            Column(
              children: _variations
                  .map(
                    (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.titleEn.trim().isEmpty ? item.sku : item.titleEn,
                  ),
                  subtitle: Text(
                    'enabled: ${item.isEnabled} • default: ${item.isDefault} • sort: ${item.sortOrder}',
                  ),
                ),
              )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  Widget _buildModeGuideRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _isVariableProduct
                      ? Icons.account_tree_outlined
                      : Icons.inventory_2_outlined,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _productTypeHelpText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
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
      subtitle:
      'Single-product media only. Up to 10 images. The first image becomes the thumbnail automatically.',
      action: FilledButton.icon(
        onPressed: _addMediaItem,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add Media'),
      ),
      child: _mediaItems.isEmpty
          ? const EmptyBlock(
        message:
        'No media items added yet. Add up to 10 product images. The first image becomes the product thumbnail automatically.',
      )
          : Column(
        children: _mediaItems
            .map(
              (item) => EditableTile(
            title: item.labelEn.trim().isEmpty ? item.effectiveFullUrl : item.labelEn,
            subtitle:
            'role: ${item.role} • type: ${item.type} • primary: ${item.isPrimary} • order: ${item.sortOrder}',
            leading: item.effectiveThumbUrl.trim().isEmpty
                ? const Icon(Icons.image_not_supported_outlined)
                : PreviewImage(url: item.effectiveThumbUrl),
            onEdit: () => _editMediaItem(item),
            onDelete: () {
              setState(() {
                _mediaItems.removeWhere((element) => element.id == item.id);
                _normalizeProductMediaPrimary();
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

  int _variationCardsPerRow(double maxWidth) {
    if (maxWidth >= 1200) return 4;
    if (maxWidth >= 860) return 3;
    return 2;
  }

  List<String> _variationAttributeLines(MBProductVariation variation) {
    final lines = <String>[];

    for (final attribute in _variationAttributesSnapshot) {
      final code = attribute.code.trim();
      final byId = variation.attributeValues[attribute.id]?.trim() ?? '';
      final byCode =
      code.isEmpty ? '' : (variation.attributeValues[code]?.trim() ?? '');
      final selected = byId.isNotEmpty ? byId : byCode;

      if (selected.isEmpty) continue;

      final matchedValue = attribute.values.cast<MBProductAttributeValue?>().firstWhere(
            (item) => item != null && item.value.trim() == selected,
        orElse: () => null,
      );

      final attributeLabel = attribute.nameEn.trim().isEmpty
          ? (attribute.code.trim().isEmpty ? attribute.id : attribute.code)
          : attribute.nameEn.trim();

      final valueLabel = matchedValue == null
          ? selected
          : (matchedValue.labelEn.trim().isEmpty
          ? matchedValue.value
          : matchedValue.labelEn.trim());

      lines.add('$attributeLabel: $valueLabel');
    }

    if (lines.isNotEmpty) return lines;

    variation.attributeValues.forEach((key, value) {
      final normalizedValue = value.trim();
      if (normalizedValue.isEmpty) return;
      lines.add('$key: $normalizedValue');
    });

    return lines;
  }

  Widget _buildVariationCardImage(BuildContext context, MBProductVariation item) {
    final imageUrl = item.effectiveFullImageUrl.trim();

    if (imageUrl.isEmpty) {
      return Container(
        height: 170,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Icon(Icons.image_outlined, size: 44),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        imageUrl,
        height: 170,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: const Icon(Icons.broken_image_outlined, size: 44),
        ),
      ),
    );
  }

  Widget _buildVariationGridCard(
      BuildContext context,
      MBProductVariation item,
      double cardWidth,
      ) {
    final attributeLines = _variationAttributeLines(item);
    final hasSale = item.salePrice != null && item.salePrice! > 0;

    return SizedBox(
      width: cardWidth,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVariationCardImage(context, item),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.titleEn.trim().isEmpty ? 'Untitled Variation' : item.titleEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if (item.titleBn.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.titleBn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'Price: ${item.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    hasSale
                        ? 'Sale: ${item.salePrice!.toStringAsFixed(2)}'
                        : 'Sale: -',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  if (attributeLines.isEmpty)
                    Text(
                      'No attribute values',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: attributeLines
                          .map(
                            (line) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            line,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'default: ${item.isDefault}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit variation',
                        onPressed: () => _editVariation(item),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete variation',
                        onPressed: () {
                          setState(() {
                            _variations.removeWhere((element) => element.id == item.id);
                          });
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
          : LayoutBuilder(
        builder: (context, constraints) {
          final items = [..._variations]
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          final columns = _variationCardsPerRow(constraints.maxWidth);
          const spacing = 12.0;
          final totalSpacing = spacing * (columns - 1);
          final cardWidth = (constraints.maxWidth - totalSpacing) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: items
                .map(
                  (item) => _buildVariationGridCard(
                context,
                item,
                cardWidth,
              ),
            )
                .toList(),
          );
        },
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
    final bool persistRootMerchandisingFlags = !_isVariableProduct;

    return SectionCard(
      title: 'Visibility and Merchandising',
      subtitle: _isVariableProduct
          ? 'Persisted fields. For variable products, root merchandising flags are display-only in Phase 1 and will not be saved to the root document.'
          : 'Persisted fields. Root publishing, status, and merchandising flags for simple products.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isVariableProduct)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Text(
                'Variable product rule: featured / flash sale / new arrival / best seller must move to variations. Root toggles below are shown only as temporary editor state in Phase 1.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
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
                label: persistRootMerchandisingFlags ? 'Featured' : 'Featured (root off)',
                selected: _isFeatured,
                onSelected: (value) => setState(() => _isFeatured = value),
              ),
              buildFilterChip(
                label: persistRootMerchandisingFlags ? 'Flash Sale' : 'Flash Sale (root off)',
                selected: _isFlashSale,
                onSelected: (value) => setState(() => _isFlashSale = value),
              ),
              buildFilterChip(
                label: persistRootMerchandisingFlags ? 'New Arrival' : 'New Arrival (root off)',
                selected: _isNewArrival,
                onSelected: (value) => setState(() => _isNewArrival = value),
              ),
              buildFilterChip(
                label: persistRootMerchandisingFlags ? 'Best Seller' : 'Best Seller (root off)',
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





  String _normalizeAdminCardVariantId(String raw) {
    final normalized = raw.trim().toLowerCase();

    if (normalized.isEmpty) {
      return MBCardVariant.compact01.id;
    }

    for (final variant in MBCardVariant.values) {
      if (variant.id.toLowerCase() == normalized) {
        return variant.id;
      }
    }

    // New design only: no old layout aliases are accepted here.
    // Invalid values safely fall back to the default new variant.
    return MBCardVariant.compact01.id;
  }

  MBCardVariant get _selectedAdminCardVariant {
    return MBCardVariantHelper.parse(
      _normalizeAdminCardVariantId(_cardLayoutType),
      fallback: MBCardVariant.compact01,
    );
  }

  MBCardInstanceConfig get _selectedCardInstanceConfig {
    final variant = _selectedAdminCardVariant;

    return MBCardInstanceConfig(
      family: variant.family,
      variant: variant,
      settings: _buildCardSettingsOverride(),
    ).normalized();
  }


  Future<void> _openCardDesignStudioDialog(BuildContext context) async {
    final result = await AdminCardDesignStudioDialog.show(
      context,
      previewProduct: _source,
      initialDesignJson: _cardDesignJson,
      title: 'Product Card Design Studio',
    );

    if (result == null) {
      return;
    }

    setState(() {
      _cardDesignJson = result.designJson.trim().isEmpty
          ? null
          : result.designJson.trim();
    });
  }

  Widget _buildCardDesignInfoChip(
    BuildContext context,
    String label,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildCardDesignStudioBridgePanel(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _hasCardDesignJson
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _hasCardDesignJson
              ? theme.colorScheme.primary.withValues(alpha: 0.35)
              : theme.dividerColor.withValues(alpha: 0.70),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.design_services_rounded,
                color: _hasCardDesignJson
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'New Design Studio',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_hasCardDesignJson)
                _buildCardDesignInfoChip(context, 'saved design JSON'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _hasCardDesignJson
                ? 'A free-design card layout is attached to this product. Open the studio to edit, drag, resize, copy, or paste the design JSON.'
                : 'Open the new design-family studio to create a free-position card design. This is saved beside the legacy cardConfig.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => _openCardDesignStudioDialog(context),
                icon: const Icon(Icons.brush_rounded),
                label: Text(
                  _hasCardDesignJson
                      ? 'Edit Design Studio'
                      : 'Open Design Studio',
                ),
              ),
              if (_hasCardDesignJson)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _cardDesignJson = null);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Clear design JSON'),
                ),
            ],
          ),
        ],
      ),
    );
  }
  Future<void> _openCardPickerDialog(BuildContext context) async {
    await _openCardStudioDialog(
      context,
      initialMode: AdminProductCardStudioMode.pick,
    );
  }


  Future<void> _openCardStudioDialog(
    BuildContext context, {
    required AdminProductCardStudioMode initialMode,
  }) async {
    final result = await AdminProductCardStudioDialog.show(
      context,
      initialMode: initialMode,
      initialConfig: _selectedCardInstanceConfig,
      previewProductBuilder: _buildProductForCardStudioPreview,
    );

    if (!mounted || result == null) {
      return;
    }

    final normalized = result.cardConfig.normalized();

    setState(() {
      _cardLayoutType = normalized.variantId;
      _cardConfigDraft = normalized;
      _cardSettingsDraft = _cardSettingsDraftFromConfig(normalized);
    });
  }

  MBProduct _buildProductForCardStudioPreview(
    MBCardInstanceConfig cardConfig,
  ) {
    final normalized = cardConfig.normalized();

    return _buildProductFromForm().copyWith(
      cardLayoutType: normalized.variantId,
      cardConfig: normalized,
    );
  }
  MBCardSettingsOverride _buildCardSettingsOverride() {
    final selectedVariant = _selectedAdminCardVariant;
    final configDraft = _cardConfigDraft?.normalized();

    if (configDraft != null && configDraft.variant == selectedVariant) {
      return configDraft.settings;
    }

    final draft = _cardSettingsDraft;

    if (draft == null || draft.variantId != selectedVariant.id) {
      return const MBCardSettingsOverride();
    }

    return MBCardSettingsOverride(
      price: MBCardPriceSettings(
        showDiscountBadge: draft.showDiscountBadge,
        showSavingsText: draft.showSavingsText,
        emphasizeFinalPrice: draft.emphasizeFinalPrice,
      ),
      actions: MBCardActionSettings(
        showAddToCart: draft.showAddToCart,
        showViewDetails: draft.showViewDetails,
      ),
      meta: MBCardMetaSettings(
        showSubtitle: draft.showSubtitle,
        showBrand: draft.showBrand,
        showUnitLabel: draft.showUnitLabel,
        showStockHint: draft.showStockHint,
        showDeliveryHint: draft.showDeliveryHint,
      ),
      borderEffect: MBCardBorderEffectSettings(
        showBorder: draft.showBorder,
      ),
      accent: MBCardAccentSettings(
        showPromoStrip: draft.showPromoStrip,
      ),
    );
  }


  AdminProductCardSettingsResult? _cardSettingsDraftFromConfig(
      MBCardInstanceConfig config,
      ) {
    final normalizedConfig = config.normalized();
    final settings = normalizedConfig.settings;

    if (settings.isEmpty) {
      return null;
    }

    const defaultPrice = MBCardPriceSettings();
    const defaultActions = MBCardActionSettings();
    const defaultMeta = MBCardMetaSettings();
    const defaultBorderEffect = MBCardBorderEffectSettings();
    const defaultAccent = MBCardAccentSettings();

    final price = settings.price ?? defaultPrice;
    final actions = settings.actions ?? defaultActions;
    final meta = settings.meta ?? defaultMeta;
    final borderEffect = settings.borderEffect ?? defaultBorderEffect;
    final accent = settings.accent ?? defaultAccent;

    return AdminProductCardSettingsResult(
      variantId: normalizedConfig.variantId,
      showDiscountBadge: price.showDiscountBadge,
      showSavingsText: price.showSavingsText,
      emphasizeFinalPrice: price.emphasizeFinalPrice,
      showAddToCart: actions.showAddToCart,
      showViewDetails: actions.showViewDetails,
      showSubtitle: meta.showSubtitle,
      showBrand: meta.showBrand,
      showUnitLabel: meta.showUnitLabel,
      showStockHint: meta.showStockHint,
      showDeliveryHint: meta.showDeliveryHint,
      showBorder: borderEffect.showBorder,
      showPromoStrip: accent.showPromoStrip,
    );
  }


  Widget _buildSelectedCardPreview(BuildContext context) {
    final previewProduct = _buildProductFromForm();
    final variant = _selectedAdminCardVariant;
    final resolved = MBCardConfigResolver.resolveByVariant(
      variant,
      settings: _buildCardSettingsOverride(),
    );

    Widget preview = MBProductCardVariantRouter.build(
      context: context,
      resolved: resolved,
      product: previewProduct,
      onTap: () {},
      onAddToCartTap: () {},
    );

    if (resolved.footprint.isFullWidth) {
      preview = SizedBox(
        height: 320,
        child: preview,
      );
    }

    return AbsorbPointer(
      absorbing: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: preview,
      ),
    );
  }



  Widget _buildCardStyleSection(BuildContext context) {
    final selectedVariant = _selectedAdminCardVariant;
    final hasCustomConfig =
        _cardConfigDraft?.normalized().settings.isNotEmpty == true ||
        (_cardSettingsDraft != null &&
            _cardSettingsDraft!.variantId == selectedVariant.id);

    return SectionCard(
      title: 'Customer App Card Style',
      subtitle:
          'Select the product-card variant and tune its settings in the Card Studio. The studio shows a persistent live mobile preview.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                    _buildCardDesignStudioBridgePanel(context),
          const SizedBox(height: 12),
Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildInfoChip('family: ${selectedVariant.family.label}'),
              buildInfoChip('variant: ${selectedVariant.id}'),
              buildInfoChip(
                selectedVariant.isFullWidth
                    ? 'footprint: full'
                    : 'footprint: half',
              ),
              if (hasCustomConfig) buildInfoChip('custom settings: on'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Text(
              'The product dialog now keeps this section clean. Use Card Studio for side-by-side family/variant selection and live phone preview.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openCardPickerDialog(context),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('Select card'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openSelectedCardSettingsDialog(context),
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Edit card'),
                ),
              ),
            ],
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
          if (_isVariableProduct) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Text(
                'Variable product preview uses the primary variation for image and price compatibility. Product-level media is not the owner anymore.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
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
              buildInfoChip('effective price: ${_effectivePreviewPrice.toStringAsFixed(2)}'),
              buildInfoChip('base price: ${preview.price.toStringAsFixed(2)}'),
              buildInfoChip('enabled: ${preview.isEnabled}'),
              buildInfoChip('deleted: ${preview.isDeleted}'),
              buildInfoChip('product media: ${preview.mediaItems.length}'),
              buildInfoChip(
                'variation image: ${_primaryVariationForOwnership?.effectiveFullImageUrl.trim().isNotEmpty == true}',
              ),
              buildInfoChip('attributes: ${preview.attributes.length}'),
              buildInfoChip('variations: ${preview.variations.length}'),
              buildInfoChip('options: ${preview.purchaseOptions.length}'),
              buildInfoChip('card: ${preview.effectiveCardVariantId}'),
              buildInfoChip('card family: ${preview.effectiveCardFamilyId}'),
            ],
          ),
          const SizedBox(height: 12),
          buildReadOnlyInfoRow('Category', preview.categoryNameEn ?? '-'),
          buildReadOnlyInfoRow('Brand', preview.brandNameEn ?? '-'),
          buildReadOnlyInfoRow('Stock', preview.stockQty.toString()),
          buildReadOnlyInfoRow(
            'Effective Price',
            _effectivePreviewPrice.toStringAsFixed(2),
          ),
          buildReadOnlyInfoRow(
            'Sale Active Now',
            (_isVariableProduct
                ? (_primaryVariationForOwnership?.isSaleActiveNow ?? false)
                : preview.isSaleActive)
                .toString(),
          ),
          buildReadOnlyInfoRow(
            'Published Now',
            preview.isPublishedNow.toString(),
          ),
          buildReadOnlyInfoRow('In Stock', preview.inStock.toString()),
        ],
      ),
    );
  }

  Future<void> _downloadProductSaveDebugFile(MBProduct product) async {
    final now = DateTime.now();
    final mode = _source.id.trim().isEmpty ? 'create_new_product' : 'edit_product';
    final namePart = _safeDebugFileNamePart(product.titleEn.trim());
    final timestamp = _safeDebugFileNamePart(now.toIso8601String());
    final fileName = '${mode}_${namePart}_$timestamp.txt';
    final selectedCardConfig = _selectedCardInstanceConfig.normalized();
    final productCardConfig = product.effectiveCardConfig.normalized();
    final selectedVariant = selectedCardConfig.variant;

    final dump = <String, Object?>{
      'debugPurpose':
          'Generated before AdminProductController.saveProduct(...) from Save Product button.',
      'generatedAt': now.toIso8601String(),
      'mode': mode,
      'sourceProductId': _source.id,
      'productIdBeforeSave': product.id,
      'controller': <String, Object?>{
        'isSaving': _controller.isSaving.value,
        'errorMessage': _controller.errorMessage.value,
      },
      'cardStateFromDialog': <String, Object?>{
        'rawState_cardLayoutType': _cardLayoutType,
        'selectedVariantId': selectedVariant.id,
        'selectedFamilyName': selectedVariant.family.name,
        'selectedFamilyLabel': selectedVariant.family.label,
        'selectedIsFullWidth': selectedVariant.isFullWidth,
        'hasCardSettingsDraft': _cardSettingsDraft != null,
        'cardSettingsDraft': _cardSettingsDraft?.toMap(),
        'selectedCardInstanceConfig': selectedCardConfig.toMap(),
        'buildCardSettingsOverride': _buildCardSettingsOverride().toMap(),
      },
      'cardStateFromBuiltProduct': <String, Object?>{
        'product.cardLayoutType': product.cardLayoutType,
        'product.effectiveCardVariantId': product.effectiveCardVariantId,
        'product.effectiveCardFamilyId': product.effectiveCardFamilyId,
        'product.effectiveCardConfig': productCardConfig.toMap(),
      },
      'importantFormState': <String, Object?>{
        'productType': _productType,
        'isVariableProduct': _isVariableProduct,
        'selectedCategoryId': _selectedCategoryId,
        'selectedBrandId': _selectedBrandId,
        'isFeatured': _isFeatured,
        'isFlashSale': _isFlashSale,
        'isEnabled': _isEnabled,
        'isNewArrival': _isNewArrival,
        'isBestSeller': _isBestSeller,
        'mediaItemsCount': _mediaItems.length,
        'attributesCount': _attributes.length,
        'variationsCount': _variations.length,
        'purchaseOptionsCount': _purchaseOptions.length,
        'effectiveThumbnailUrl': _effectiveThumbnailUrl,
        'effectiveImageUrls': _effectiveImageUrls,
      },
      'editorCollections': <String, Object?>{
        'mediaItems': _mediaItems.map((item) => item.toMap()).toList(),
        'attributes': _attributes.map((item) => item.toMap()).toList(),
        'variations': _variations.map((item) => item.toMap()).toList(),
        'purchaseOptions': _purchaseOptions.map((item) => item.toMap()).toList(),
      },
      'productToMapBeforeSave': product.toMap(),
    };

    final content = const JsonEncoder.withIndent('  ').convert(
      _debugJsonSafe(dump),
    );

    final bytes = utf8.encode(content);
    final blob = html.Blob(<Object>[bytes], 'text/plain;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  Object? _debugJsonSafe(Object? value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is DateTime) return value.toIso8601String();
    if (value is Enum) return value.name;
    if (value is Map) {
      final output = <String, Object?>{};
      value.forEach((key, item) {
        output[key.toString()] = _debugJsonSafe(item);
      });
      return output;
    }
    if (value is Iterable) {
      return value.map(_debugJsonSafe).toList();
    }
    return value.toString();
  }

  String _safeDebugFileNamePart(String value) {
    final normalized = value.trim().replaceAll(
          RegExp(r'[^a-zA-Z0-9._-]+'),
          '_',
        );
    if (normalized.isEmpty) return 'empty';
    if (normalized.length <= 80) return normalized;
    return normalized.substring(0, 80);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final product = _buildProductFromForm();

    if (kProductSaveDebugDumpEnabled) {
      await _downloadProductSaveDebugFile(product);
    }
    var saved = await _controller.saveProduct(
      product: product,
      actorUid: widget.actorUid,
      actorName: widget.actorName,
      actorPhone: widget.actorPhone,
      actorRole: widget.actorRole,
    );

    //saved ??= await _waitForRecoveredSavedProduct(product);

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




  MBProduct _buildProductFromForm() {
    final now = DateTime.now();
    final primaryVariation =
    _isVariableProduct ? _primaryVariationForOwnership : null;

    final effectiveSaleStartsAt =
        primaryVariation?.saleStartsAt ?? _saleStartsAt;
    final effectiveSaleEndsAt =
        primaryVariation?.saleEndsAt ?? _saleEndsAt;

    final effectiveStockQty =
        primaryVariation?.stockQty ?? parseInt(_stockQtyController.text);
    final effectiveRegularStockQty =
        primaryVariation?.stockQty ?? parseInt(_regularStockQtyController.text);
    final effectiveReservedQty =
        primaryVariation?.reservedQty ??
            parseInt(_reservedInstantQtyController.text);

    final effectiveInventoryMode =
        primaryVariation?.inventoryMode ?? _inventoryMode;
    final effectiveTrackInventory =
        primaryVariation?.trackInventory ?? _trackInventory;
    final effectiveSupportsInstantOrder =
        primaryVariation?.supportsInstantOrder ?? _supportsInstantOrder;
    final effectiveSupportsScheduledOrder =
        primaryVariation?.supportsScheduledOrder ?? _supportsScheduledOrder;
    final effectiveAllowBackorder =
        primaryVariation?.allowBackorder ?? _allowBackorder;

    final effectiveInstantCutoffTime =
        primaryVariation?.instantCutoffTime ??
            _instantCutoffTimeController.text.trim();
    final effectiveTodayInstantCap =
        primaryVariation?.todayInstantCap ??
            parseInt(_todayInstantCapController.text, fallback: 999999);
    final effectiveTodayInstantSold =
        primaryVariation?.todayInstantSold ??
            parseInt(_todayInstantSoldController.text);
    final effectiveMaxScheduleQtyPerDay =
        primaryVariation?.maxScheduleQtyPerDay ??
            parseInt(_maxScheduleQtyPerDayController.text, fallback: 999999);
    final effectiveMinScheduleNoticeHours =
        primaryVariation?.minScheduleNoticeHours ??
            parseInt(_minScheduleNoticeHoursController.text);
    final effectiveReorderLevel =
        primaryVariation?.reorderLevel ?? parseInt(_reorderLevelController.text);

    final effectiveQuantityType =
        primaryVariation?.quantityType ?? _quantityType;
    final effectiveQuantityValue =
        primaryVariation?.quantityValue ?? parseDouble(_quantityValueController.text);
    final effectiveToleranceType =
        primaryVariation?.toleranceType ?? _toleranceType;
    final effectiveTolerance =
        primaryVariation?.tolerance ?? parseDouble(_toleranceController.text);
    final effectiveIsToleranceActive =
        primaryVariation?.isToleranceActive ?? _isToleranceActive;
    final effectiveDeliveryShift =
        primaryVariation?.deliveryShift ?? _deliveryShift;

    final effectiveMinOrderQty =
        primaryVariation?.minOrderQty ??
            parseNullableDouble(_minOrderQtyController.text);
    final effectiveMaxOrderQty =
        primaryVariation?.maxOrderQty ??
            parseNullableDouble(_maxOrderQtyController.text);
    final effectiveStepQty =
        primaryVariation?.stepQty ?? parseNullableDouble(_stepQtyController.text);

    final effectiveUnitLabelEn =
        primaryVariation?.unitLabelEn ?? _unitLabelEnController.text.trim();
    final effectiveUnitLabelBn =
        primaryVariation?.unitLabelBn ?? _unitLabelBnController.text.trim();
    final media = _effectiveProductMediaItems;
    final derivedThumbnail = _effectiveThumbnailUrl;
    final derivedImageUrls = _effectiveImageUrls;
    final selectedCardConfig = _selectedCardInstanceConfig;

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
      price: _effectiveRootPrice,
      salePrice: _effectiveRootSalePrice,
      clearSalePrice: _effectiveRootSalePrice == null,
      costPrice: _effectiveRootCostPrice,
      clearCostPrice: _effectiveRootCostPrice == null,


      saleStartsAt: effectiveSaleStartsAt,
      clearSaleStartsAt: effectiveSaleStartsAt == null,
      saleEndsAt: effectiveSaleEndsAt,
      clearSaleEndsAt: effectiveSaleEndsAt == null,
      stockQty: effectiveStockQty,
      inventoryMode: effectiveInventoryMode,
      trackInventory: effectiveTrackInventory,
      supportsInstantOrder: effectiveSupportsInstantOrder,
      supportsScheduledOrder: effectiveSupportsScheduledOrder,
      regularStockQty: effectiveRegularStockQty,
      reservedInstantQty: effectiveReservedQty,
      todayInstantCap: effectiveTodayInstantCap,
      todayInstantSold: effectiveTodayInstantSold,
      maxScheduleQtyPerDay: effectiveMaxScheduleQtyPerDay,
      instantCutoffTime:
      effectiveInstantCutoffTime.isEmpty ? null : effectiveInstantCutoffTime,
      clearInstantCutoffTime: effectiveInstantCutoffTime.isEmpty,
      minScheduleNoticeHours: effectiveMinScheduleNoticeHours,
      reorderLevel: effectiveReorderLevel,
      allowBackorder: effectiveAllowBackorder,


      schedulePriceType: _schedulePriceType,
      estimatedSchedulePrice: parseNullableDouble(
        _estimatedSchedulePriceController.text,
      ),
      clearEstimatedSchedulePrice:
      parseNullableDouble(_estimatedSchedulePriceController.text) == null,





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
      cardLayoutType: selectedCardConfig.variantId,
      cardConfig: selectedCardConfig,
      cardDesignJson: _cardDesignJson?.trim().isEmpty ?? true
          ? null
          : _cardDesignJson!.trim(),
      clearCardDesignJson: _cardDesignJson?.trim().isEmpty ?? true,
      isFeatured: !_isVariableProduct && _isFeatured,
      isFlashSale: !_isVariableProduct && _isFlashSale,
      isEnabled: _isEnabled,
      isNewArrival: !_isVariableProduct && _isNewArrival,
      isBestSeller: !_isVariableProduct && _isBestSeller,
      sortOrder: _sortOrder,
      publishAt: _publishAt,
      clearPublishAt: _publishAt == null,
      unpublishAt: _unpublishAt,
      clearUnpublishAt: _unpublishAt == null,


      quantityType: effectiveQuantityType,
      quantityValue: effectiveQuantityValue,
      toleranceType: effectiveToleranceType,
      tolerance: effectiveTolerance,
      isToleranceActive: effectiveIsToleranceActive,
      deliveryShift: effectiveDeliveryShift,
      minOrderQty: effectiveMinOrderQty,
      clearMinOrderQty: effectiveMinOrderQty == null,
      maxOrderQty: effectiveMaxOrderQty,
      clearMaxOrderQty: effectiveMaxOrderQty == null,
      stepQty: effectiveStepQty,
      clearStepQty: effectiveStepQty == null,
      unitLabelEn: effectiveUnitLabelEn.isEmpty ? null : effectiveUnitLabelEn,
      clearUnitLabelEn: effectiveUnitLabelEn.isEmpty,
      unitLabelBn: effectiveUnitLabelBn.isEmpty ? null : effectiveUnitLabelBn,
      clearUnitLabelBn: effectiveUnitLabelBn.isEmpty,



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

  static const int _maxProductMediaItems = 10;

  Future<void> _showProductMediaPrompt(String title, String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _normalizeProductMediaPrimary() {
    if (_mediaItems.isEmpty) return;

    _mediaItems.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    bool primaryAssigned = false;
    for (var i = 0; i < _mediaItems.length; i++) {
      final item = _mediaItems[i];
      final shouldBePrimary = !primaryAssigned && (item.isPrimary || i == 0);

      _mediaItems[i] = item.copyWith(
        isPrimary: shouldBePrimary,
        role: shouldBePrimary ? 'thumbnail' : (item.role.trim().isEmpty ? 'gallery' : item.role),
        sortOrder: i,
      );

      if (shouldBePrimary) {
        primaryAssigned = true;
      }
    }

    if (!primaryAssigned && _mediaItems.isNotEmpty) {
      final first = _mediaItems.first;
      _mediaItems[0] = first.copyWith(
        isPrimary: true,
        role: 'thumbnail',
        sortOrder: 0,
      );
    }
  }

  Future<void> _addMediaItem() async {
    if (_isVariableProduct) {
      await _showProductMediaPrompt(
        'Variation-owned Media',
        'For variable products, media should be managed inside each variation. Product-level media is only for non-variable products.',
      );
      return;
    }

    if (_mediaItems.length >= _maxProductMediaItems) {
      await _showProductMediaPrompt(
        'Media Limit Reached',
        'A single product can have up to $_maxProductMediaItems images.',
      );
      return;
    }

    final result = await showDialog<MBProductMedia>(
      context: context,
      builder: (_) => MediaItemDialog(
        initialValue: MBProductMedia(
          id: makeEditorId('media'),
          url: '',
          sortOrder: _mediaItems.length,
          isPrimary: _mediaItems.isEmpty,
          role: _mediaItems.isEmpty ? 'thumbnail' : 'gallery',
          type: 'image',
          isEnabled: true,
        ),
        maxItems: _maxProductMediaItems,
        currentItemCount: _mediaItems.length,
        useProductPortraitPreset: true,
        forceImageOnly: true,
      ),
    );

    if (result == null) return;

    setState(() {
      _mediaItems.add(result);
      _normalizeProductMediaPrimary();
    });
  }

  Future<void> _editMediaItem(MBProductMedia item) async {
    final result = await showDialog<MBProductMedia>(
      context: context,
      builder: (_) => MediaItemDialog(
        initialValue: item,
        maxItems: _maxProductMediaItems,
        currentItemCount: _mediaItems.length,
        useProductPortraitPreset: true,
        forceImageOnly: true,
      ),
    );

    if (result == null) return;

    setState(() {
      final index = _mediaItems.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _mediaItems[index] = result;
        _normalizeProductMediaPrimary();
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
          code: '',
          sortOrder: _attributes.length,
          isVisible: true,
          useForVariation: true,
          isRequired: false,
          displayType: 'text',
        ),
      ),
    );

    if (result == null) return;

    final duplicateMessage = _findDuplicateAttributeMessage(result);
    if (duplicateMessage != null) {
      await _showDialogPrompt('Duplicate Attribute', duplicateMessage);
      return;
    }

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

    final duplicateMessage = _findDuplicateAttributeMessage(
      result,
      excludeId: item.id,
    );
    if (duplicateMessage != null) {
      await _showDialogPrompt('Duplicate Attribute', duplicateMessage);
      return;
    }

    setState(() {
      final index = _attributes.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        _attributes[index] = result;
        _attributes.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
    });
  }

  Future<void> _addVariation() async {
    final variationAttributes = _variationAttributesSnapshot;

    if (variationAttributes.isEmpty) {
      await _showDialogPrompt(
        'Variation Attribute Required',
        'Before adding a variation, create at least one attribute, turn on "Use For Variation", and add at least one enabled attribute value.',
      );
      return;
    }

    final result = await showDialog<MBProductVariation>(
      context: context,
      builder: (_) => VariationDialog(
        initialValue: MBProductVariation(
          id: makeEditorId('variation'),
          sortOrder: _variations.length,
        ),
        variationAttributes: variationAttributes,
      ),
    );

    if (result == null) return;

    final duplicateMessage = _findDuplicateVariationMessage(result);
    if (duplicateMessage != null) {
      await _showDialogPrompt('Duplicate Variation', duplicateMessage);
      return;
    }

    setState(() {
      _variations.add(result);
      _variations.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Future<void> _editVariation(MBProductVariation item) async {
    final variationAttributes = _variationAttributesSnapshot;

    if (variationAttributes.isEmpty) {
      await _showDialogPrompt(
        'Variation Attribute Required',
        'This product currently has no usable variation attributes. Add at least one attribute with enabled values first.',
      );
      return;
    }

    final result = await showDialog<MBProductVariation>(
      context: context,
      builder: (_) => VariationDialog(
        initialValue: item,
        variationAttributes: variationAttributes,
      ),
    );

    if (result == null) return;

    final duplicateMessage = _findDuplicateVariationMessage(
      result,
      excludeId: item.id,
    );
    if (duplicateMessage != null) {
      await _showDialogPrompt('Duplicate Variation', duplicateMessage);
      return;
    }

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






