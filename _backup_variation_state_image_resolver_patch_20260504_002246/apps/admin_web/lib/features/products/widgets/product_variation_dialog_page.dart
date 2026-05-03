import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';
import 'package:shared_ui/widgets/common/product_cards/design_studio_advanced/mb_card_design_studio_advanced_exports.dart';

import 'admin_product_form_support.dart';

// File: product_variation_dialog_page.dart
// MuthoBazar product variation dialog page.
//
// Purpose:
// - Full-width variation editor dialog for the admin product form.
// - Uses a left expandable section selector like the product dialog.
// - Uses a right variation information panel like the product dialog.
// - Keeps the variation form sections in the agreed order.

class ProductVariationDialog extends StatefulWidget {
  const ProductVariationDialog({
    super.key,
    required this.initialValue,
    this.variationAttributes = const <MBProductAttribute>[],
  });

  final MBProductVariation initialValue;
  final List<MBProductAttribute> variationAttributes;

  @override
  State<ProductVariationDialog> createState() => _ProductVariationDialogState();
}

class _VariationSectionNavItem {
  const _VariationSectionNavItem({
    required this.title,
    required this.icon,
    required this.targetKey,
  });

  final String title;
  final IconData icon;
  final GlobalKey targetKey;
}

class ProductVariationDialogResult {
  const ProductVariationDialogResult({
    required this.variation,
    this.pendingImage,
    this.imageFileStem = '',
  });

  final MBProductVariation variation;
  final MBPreparedImageSet? pendingImage;
  final String imageFileStem;

  bool get hasPendingImage => pendingImage != null;
}

class _ProductVariationDialogState extends State<ProductVariationDialog> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _helpKey = GlobalKey();
  final GlobalKey _identityKey = GlobalKey();
  final GlobalKey _descriptionsKey = GlobalKey();
  final GlobalKey _attributeValuesKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _purchaseOptionsKey = GlobalKey();
  final GlobalKey _merchandisingKey = GlobalKey();
  final GlobalKey _merchandisingSummaryKey = GlobalKey();
  final GlobalKey _statusPublishingKey = GlobalKey();
  final GlobalKey _inventoryKey = GlobalKey();
  final GlobalKey _quantityKey = GlobalKey();
  final GlobalKey _taxShippingAnalyticsKey = GlobalKey();
  final GlobalKey _imageCardKey = GlobalKey();
  final GlobalKey _cardOverrideAuditKey = GlobalKey();

  bool _sectionDrawerExpanded = true;
  bool _isImageProcessing = false;
  String? _imageErrorText;
  MBPreparedImageSet? _preparedImage;

  late final TextEditingController _idController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _titleEnController;
  late final TextEditingController _titleBnController;
  late final TextEditingController _shortDescriptionEnController;
  late final TextEditingController _shortDescriptionBnController;
  late final TextEditingController _descriptionEnController;
  late final TextEditingController _descriptionBnController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _thumbImageUrlController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _saleStartsAtController;
  late final TextEditingController _saleEndsAtController;
  late final TextEditingController _estimatedSchedulePriceController;
  late final TextEditingController _publishAtController;
  late final TextEditingController _unpublishAtController;
  late final TextEditingController _stockQtyController;
  late final TextEditingController _reservedQtyController;
  late final TextEditingController _instantCutoffTimeController;
  late final TextEditingController _todayInstantCapController;
  late final TextEditingController _todayInstantSoldController;
  late final TextEditingController _maxScheduleQtyPerDayController;
  late final TextEditingController _minScheduleNoticeHoursController;
  late final TextEditingController _reorderLevelController;
  late final TextEditingController _quantityValueController;
  late final TextEditingController _toleranceController;
  late final TextEditingController _minOrderQtyController;
  late final TextEditingController _maxOrderQtyController;
  late final TextEditingController _stepQtyController;
  late final TextEditingController _unitLabelEnController;
  late final TextEditingController _unitLabelBnController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _viewsController;
  late final TextEditingController _totalSoldController;
  late final TextEditingController _addToCartCountController;
  late final TextEditingController _cardLayoutTypeController;
  late final TextEditingController _cardDesignJsonController;
  late final TextEditingController _taxClassIdController;
  late final TextEditingController _vatRateController;
  late final TextEditingController _weightValueController;
  late final TextEditingController _weightUnitController;
  late final TextEditingController _lengthController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _dimensionUnitController;
  late final TextEditingController _shippingClassIdController;
  late final TextEditingController _adminNoteController;
  late final TextEditingController _metadataJsonController;
  late final TextEditingController _createdByController;
  late final TextEditingController _updatedByController;
  late final TextEditingController _deletedByController;
  late final TextEditingController _deleteReasonController;

  late String _inventoryMode;
  late String _schedulePriceType;
  late String _status;
  late String _quantityType;
  late String _toleranceType;
  late String _deliveryShift;

  late bool _trackInventory;
  late bool _supportsInstantOrder;
  late bool _supportsScheduledOrder;
  late bool _allowBackorder;
  late bool _isToleranceActive;
  late bool _isDefault;
  late bool _isEnabled;
  late bool _isTaxIncluded;
  late bool _isDeleted;
  late bool _isFeatured;
  late bool _isFlashSale;
  late bool _isNewArrival;
  late bool _isBestSeller;

  DateTime? _saleStartsAt;
  DateTime? _saleEndsAt;
  DateTime? _publishAt;
  DateTime? _unpublishAt;
  DateTime? _deletedAt;

  late List<MBProductPurchaseOption> _purchaseOptions;
  late Map<String, String?> _selectedAttributeValues;

  static const int _variationFullMaxWidth = 1400;
  static const int _variationFullMaxHeight = 1400;
  static const int _variationFullJpegQuality = 84;
  static const int _variationThumbWidth = 240;
  static const int _variationThumbHeight = 300;
  static const int _variationThumbSize = 240;
  static const int _variationThumbJpegQuality = 76;
  static const int _variationOriginalMaxLongSide = 2048;
  static const int _variationOriginalJpegQuality = 90;
  static const int _variationCardWidth = 600;
  static const int _variationCardHeight = 750;
  static const int _variationCardJpegQuality = 80;
  static const int _variationTinyWidth = 120;
  static const int _variationTinyHeight = 150;
  static const int _variationTinyJpegQuality = 72;

  static double _dialogHorizontalInset(double screenWidth) {
    if (screenWidth >= 1200) return 16;
    if (screenWidth >= 900) return 12;
    return 0;
  }

  static double _dialogVerticalInset(double screenHeight) {
    if (screenHeight >= 760) return 20;
    if (screenHeight >= 620) return 12;
    return 0;
  }

  static double _dialogWidthFor(double screenWidth) {
    final availableWidth = screenWidth - (_dialogHorizontalInset(screenWidth) * 2);
    return availableWidth <= 0 ? screenWidth : availableWidth;
  }

  static double _dialogHeightFor(double screenHeight) {
    final availableHeight = screenHeight - (_dialogVerticalInset(screenHeight) * 2);
    return availableHeight <= 0 ? screenHeight : availableHeight;
  }

  @override
  void initState() {
    super.initState();
    final value = widget.initialValue;

    _idController = TextEditingController(
      text: value.id.trim().isEmpty ? makeEditorId('variation') : value.id,
    );
    _skuController = TextEditingController(text: value.sku);
    _barcodeController = TextEditingController(text: value.barcode ?? '');
    _titleEnController = TextEditingController(text: value.titleEn);
    _titleBnController = TextEditingController(text: value.titleBn);
    _shortDescriptionEnController = TextEditingController(text: value.shortDescriptionEn);
    _shortDescriptionBnController = TextEditingController(text: value.shortDescriptionBn);
    _descriptionEnController = TextEditingController(text: value.descriptionEn);
    _descriptionBnController = TextEditingController(text: value.descriptionBn);
    _imageUrlController = TextEditingController(text: value.effectiveFullImageUrl);
    _thumbImageUrlController = TextEditingController(text: value.effectiveThumbImageUrl);
    _priceController = TextEditingController(text: asTextDouble(value.price));
    _salePriceController = TextEditingController(text: asTextNullableDouble(value.salePrice));
    _costPriceController = TextEditingController(text: asTextNullableDouble(value.costPrice));
    _saleStartsAt = value.saleStartsAt;
    _saleEndsAt = value.saleEndsAt;
    _saleStartsAtController = TextEditingController(text: formatDateTime(_saleStartsAt));
    _saleEndsAtController = TextEditingController(text: formatDateTime(_saleEndsAt));
    _estimatedSchedulePriceController = TextEditingController(text: asTextNullableDouble(value.estimatedSchedulePrice));
    _publishAt = value.publishAt;
    _unpublishAt = value.unpublishAt;
    _publishAtController = TextEditingController(text: formatDateTime(_publishAt));
    _unpublishAtController = TextEditingController(text: formatDateTime(_unpublishAt));
    _stockQtyController = TextEditingController(text: value.stockQty.toString());
    _reservedQtyController = TextEditingController(text: value.reservedQty.toString());
    _instantCutoffTimeController = TextEditingController(text: value.instantCutoffTime ?? '');
    _todayInstantCapController = TextEditingController(text: value.todayInstantCap.toString());
    _todayInstantSoldController = TextEditingController(text: value.todayInstantSold.toString());
    _maxScheduleQtyPerDayController = TextEditingController(text: value.maxScheduleQtyPerDay.toString());
    _minScheduleNoticeHoursController = TextEditingController(text: value.minScheduleNoticeHours.toString());
    _reorderLevelController = TextEditingController(text: value.reorderLevel.toString());
    _quantityValueController = TextEditingController(text: asTextDouble(value.quantityValue));
    _toleranceController = TextEditingController(text: asTextDouble(value.tolerance));
    _minOrderQtyController = TextEditingController(text: asTextNullableDouble(value.minOrderQty));
    _maxOrderQtyController = TextEditingController(text: asTextNullableDouble(value.maxOrderQty));
    _stepQtyController = TextEditingController(text: asTextNullableDouble(value.stepQty));
    _unitLabelEnController = TextEditingController(text: value.unitLabelEn ?? '');
    _unitLabelBnController = TextEditingController(text: value.unitLabelBn ?? '');
    _sortOrderController = TextEditingController(text: value.sortOrder.toString());
    _viewsController = TextEditingController(text: value.views.toString());
    _totalSoldController = TextEditingController(text: value.totalSold.toString());
    _addToCartCountController = TextEditingController(text: value.addToCartCount.toString());
    _cardLayoutTypeController = TextEditingController(text: value.cardLayoutType ?? '');
    _cardDesignJsonController = TextEditingController(text: value.cardDesignJson ?? '');
    _taxClassIdController = TextEditingController(text: value.taxClassId ?? '');
    _vatRateController = TextEditingController(text: asTextNullableDouble(value.vatRate));
    _weightValueController = TextEditingController(text: asTextNullableDouble(value.weightValue));
    _weightUnitController = TextEditingController(text: value.weightUnit ?? '');
    _lengthController = TextEditingController(text: asTextNullableDouble(value.length));
    _widthController = TextEditingController(text: asTextNullableDouble(value.width));
    _heightController = TextEditingController(text: asTextNullableDouble(value.height));
    _dimensionUnitController = TextEditingController(text: value.dimensionUnit ?? '');
    _shippingClassIdController = TextEditingController(text: value.shippingClassId ?? '');
    _adminNoteController = TextEditingController(text: value.adminNote ?? '');
    _metadataJsonController = TextEditingController(text: _metadataJsonText(value.metadata));
    _createdByController = TextEditingController(text: value.createdBy ?? '');
    _updatedByController = TextEditingController(text: value.updatedBy ?? '');
    _deletedByController = TextEditingController(text: value.deletedBy ?? '');
    _deleteReasonController = TextEditingController(text: value.deleteReason ?? '');

    _inventoryMode = value.inventoryMode.trim().isEmpty ? 'stocked' : value.inventoryMode;
    _schedulePriceType = value.schedulePriceType.trim().isEmpty ? 'fixed' : value.schedulePriceType;
    _status = value.status.trim().isEmpty ? 'active' : value.status;
    _quantityType = value.quantityType.trim().isEmpty ? 'pcs' : value.quantityType;
    _toleranceType = value.toleranceType.trim().isEmpty ? 'g' : value.toleranceType;
    _deliveryShift = value.deliveryShift.trim().isEmpty ? 'any' : value.deliveryShift;

    _trackInventory = value.trackInventory;
    _supportsInstantOrder = value.supportsInstantOrder;
    _supportsScheduledOrder = value.supportsScheduledOrder;
    _allowBackorder = value.allowBackorder;
    _isToleranceActive = value.isToleranceActive;
    _isDefault = value.isDefault;
    _isEnabled = value.isEnabled;
    _isFeatured = value.isFeatured;
    _isFlashSale = value.isFlashSale;
    _isNewArrival = value.isNewArrival;
    _isBestSeller = value.isBestSeller;
    _isTaxIncluded = value.isTaxIncluded;
    _isDeleted = value.isDeleted;
    _deletedAt = value.deletedAt;
    _purchaseOptions = [...value.purchaseOptions]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    _selectedAttributeValues = <String, String?>{};
    for (final attribute in widget.variationAttributes) {
      _selectedAttributeValues[attribute.id] = _initialSelectedValueFor(attribute, value);
    }
  }

  @override
  void dispose() {
    for (final controller in <TextEditingController>[
      _idController,
      _skuController,
      _barcodeController,
      _titleEnController,
      _titleBnController,
      _shortDescriptionEnController,
      _shortDescriptionBnController,
      _descriptionEnController,
      _descriptionBnController,
      _imageUrlController,
      _thumbImageUrlController,
      _priceController,
      _salePriceController,
      _costPriceController,
      _saleStartsAtController,
      _saleEndsAtController,
      _estimatedSchedulePriceController,
      _publishAtController,
      _unpublishAtController,
      _stockQtyController,
      _reservedQtyController,
      _instantCutoffTimeController,
      _todayInstantCapController,
      _todayInstantSoldController,
      _maxScheduleQtyPerDayController,
      _minScheduleNoticeHoursController,
      _reorderLevelController,
      _quantityValueController,
      _toleranceController,
      _minOrderQtyController,
      _maxOrderQtyController,
      _stepQtyController,
      _unitLabelEnController,
      _unitLabelBnController,
      _sortOrderController,
      _viewsController,
      _totalSoldController,
      _addToCartCountController,
      _cardLayoutTypeController,
      _cardDesignJsonController,
      _taxClassIdController,
      _vatRateController,
      _weightValueController,
      _weightUnitController,
      _lengthController,
      _widthController,
      _heightController,
      _dimensionUnitController,
      _shippingClassIdController,
      _adminNoteController,
      _metadataJsonController,
      _createdByController,
      _updatedByController,
      _deletedByController,
      _deleteReasonController,
    ]) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  String _metadataJsonText(Map<String, dynamic> metadata) {
    if (metadata.isEmpty) return '';
    try {
      return const JsonEncoder.withIndent('  ').convert(metadata);
    } catch (_) {
      return jsonEncode(metadata);
    }
  }

  Map<String, dynamic> _parseMetadataJson(
    String raw, {
    Map<String, dynamic> fallback = const <String, dynamic>{},
  }) {
    final value = raw.trim();
    if (value.isEmpty) return const <String, dynamic>{};
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return fallback;
    }
    return fallback;
  }

  String? _metadataJsonValidator(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return null;
    } catch (_) {
      return 'Metadata must be a valid JSON object.';
    }
    return 'Metadata must be a JSON object like {"key":"value"}.';
  }

  String _normalizeAdvancedCardTemplateId(String raw) {
    final normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case 'hero_poster_circle_diagonal_v1':
      case 'hero_poster_circle_diagonal_v2':
      case 'hero_poster_circle_diagonal':
      case 'hero_poster_circle':
        return 'hero_poster_circle_diagonal_v1';
      default:
        return raw.trim();
    }
  }

  String? _normalizedCardDesignJsonForSave(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return null;

    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        final layoutRaw = map['layout'];
        final layoutType = layoutRaw is Map
            ? (layoutRaw['cardLayoutType'] ?? '').toString()
            : '';
        final normalizedTemplate = _normalizeAdvancedCardTemplateId(
          (map['templateId'] ?? layoutType).toString(),
        );

        if (normalizedTemplate.isNotEmpty) {
          map['templateId'] = normalizedTemplate;
          final layout = map['layout'];
          if (layout is Map) {
            final layoutMap = Map<String, dynamic>.from(layout);
            layoutMap['cardLayoutType'] = normalizedTemplate;
            map['layout'] = layoutMap;
          }
          final metadata = map['metadata'];
          if (metadata is Map) {
            final metadataMap = Map<String, dynamic>.from(metadata);
            metadataMap['cardLayoutType'] = normalizedTemplate;
            map['metadata'] = metadataMap;
          }
        }

        return const JsonEncoder.withIndent('  ').convert(map);
      }
    } catch (_) {
      return text;
    }

    return text;
  }

  String _cardLayoutTypeFromDesignJsonForSave(String? cardDesignJson) {
    final text = cardDesignJson?.trim();
    if (text == null || text.isEmpty) return '';
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        final templateId = (decoded['templateId'] ?? '').toString().trim();
        if (templateId.isNotEmpty) return _normalizeAdvancedCardTemplateId(templateId);
        final layout = decoded['layout'];
        if (layout is Map) {
          final layoutType = (layout['cardLayoutType'] ?? '').toString().trim();
          if (layoutType.isNotEmpty) return _normalizeAdvancedCardTemplateId(layoutType);
        }
      }
    } catch (_) {
      // Fallback below.
    }
    return 'hero_poster_circle_diagonal_v1';
  }

  String _normalizeCardLayoutTypeForSave(
    String raw, {
    String? cardDesignJson,
  }) {
    final designLayoutType = _cardLayoutTypeFromDesignJsonForSave(cardDesignJson);
    if (designLayoutType.isNotEmpty) return designLayoutType;
    final advanced = _normalizeAdvancedCardTemplateId(raw);
    if (advanced == 'hero_poster_circle_diagonal_v1') return advanced;
    if (advanced.trim().isNotEmpty) return advanced.trim();
    return MBCardVariant.compact01.id;
  }

  List<MBProductAttributeValue> _enabledValuesFor(MBProductAttribute attribute) {
    final values = attribute.values
        .where((value) => value.isEnabled && value.value.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return values;
  }

  String? _initialSelectedValueFor(
    MBProductAttribute attribute,
    MBProductVariation variation,
  ) {
    final byId = variation.attributeValues[attribute.id]?.trim() ?? '';
    if (byId.isNotEmpty) return byId;
    final code = attribute.code.trim();
    if (code.isNotEmpty) {
      final byCode = variation.attributeValues[code]?.trim() ?? '';
      if (byCode.isNotEmpty) return byCode;
    }
    final enabledValues = _enabledValuesFor(attribute);
    if (enabledValues.length == 1) return enabledValues.first.value.trim();
    return null;
  }

  Map<String, String> _buildSelectedAttributeMap() {
    final result = <String, String>{};
    for (final attribute in widget.variationAttributes) {
      final selected = (_selectedAttributeValues[attribute.id] ?? '').trim();
      if (selected.isNotEmpty) result[attribute.id] = selected;
    }
    return result;
  }

  String _ratioText(int width, int height) {
    if (height == 0) return '-';
    return (width / height).toStringAsFixed(3);
  }

  String _bytesText(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
    return '${(value / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _dataImageUrl(List<int>? bytes) {
    if (bytes == null || bytes.isEmpty) return '';
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  String get _pendingVariationFullPreviewUrl =>
      _dataImageUrl(_preparedImage?.fullBytes);

  String get _pendingVariationThumbPreviewUrl =>
      _dataImageUrl(_preparedImage?.thumbBytes ?? _preparedImage?.cardBytes);

  String get _pendingVariationOriginalPreviewUrl =>
      _dataImageUrl(_preparedImage?.originalBytes ?? _preparedImage?.fullBytes);

  String get _pendingVariationCardPreviewUrl =>
      _dataImageUrl(_preparedImage?.cardBytes ?? _preparedImage?.fullBytes);

  String get _pendingVariationTinyPreviewUrl =>
      _dataImageUrl(_preparedImage?.tinyBytes ?? _preparedImage?.thumbBytes);

  String get _currentVariationFullPreviewUrl {
    final pending = _pendingVariationFullPreviewUrl;
    if (pending.isNotEmpty) return pending;

    final current = _imageUrlController.text.trim();
    if (current.isNotEmpty) return current;
    return widget.initialValue.effectiveFullImageUrl.trim();
  }

  String get _currentVariationThumbPreviewUrl {
    final pending = _pendingVariationThumbPreviewUrl;
    if (pending.isNotEmpty) return pending;

    final current = _thumbImageUrlController.text.trim();
    if (current.isNotEmpty) return current;

    return widget.initialValue.effectiveThumbImageUrl.trim();
  }

  String get _currentVariationOriginalPreviewUrl {
    final pending = _pendingVariationOriginalPreviewUrl;
    if (pending.isNotEmpty) return pending;

    final initialOriginal = widget.initialValue.effectiveOriginalImageUrl.trim();
    if (initialOriginal.isNotEmpty) return initialOriginal;

    return _currentVariationFullPreviewUrl;
  }

  String get _currentVariationCardPreviewUrl {
    final pending = _pendingVariationCardPreviewUrl;
    if (pending.isNotEmpty) return pending;

    final initialCard = widget.initialValue.effectiveCardImageUrl.trim();
    if (initialCard.isNotEmpty) return initialCard;

    return _currentVariationFullPreviewUrl;
  }

  String get _currentVariationTinyPreviewUrl {
    final pending = _pendingVariationTinyPreviewUrl;
    if (pending.isNotEmpty) return pending;

    final initialTiny = widget.initialValue.effectiveTinyImageUrl.trim();
    if (initialTiny.isNotEmpty) return initialTiny;

    return _currentVariationThumbPreviewUrl;
  }

  String? get _currentVariationCardDesignJson {
    final current = _cardDesignJsonController.text.trim();
    if (current.isNotEmpty) return _normalizedCardDesignJsonForSave(current);
    final initial = widget.initialValue.cardDesignJson?.trim();
    if (initial != null && initial.isNotEmpty) {
      return _normalizedCardDesignJsonForSave(initial);
    }
    return null;
  }

  String get _currentVariationCardLayoutType {
    final designJson = _currentVariationCardDesignJson;
    final current = _cardLayoutTypeController.text.trim();
    if (current.isNotEmpty) {
      return _normalizeCardLayoutTypeForSave(current, cardDesignJson: designJson);
    }
    final initial = widget.initialValue.cardLayoutType?.trim();
    if (initial != null && initial.isNotEmpty) {
      return _normalizeCardLayoutTypeForSave(initial, cardDesignJson: designJson);
    }
    return _normalizeCardLayoutTypeForSave(MBCardVariant.compact01.id);
  }

  MBCardInstanceConfig get _currentVariationCardConfig {
    final existing = widget.initialValue.cardConfig;
    if (existing != null) return existing;
    return const MBCardInstanceConfig(
      family: MBCardFamily.compact,
      variant: MBCardVariant.compact01,
    );
  }

  MBProduct _buildVariationPreviewProduct() {
    final now = DateTime.now();
    final fullUrl = _currentVariationFullPreviewUrl.trim();
    final originalUrl = _currentVariationOriginalPreviewUrl.trim();
    final cardUrl = _currentVariationCardPreviewUrl.trim();
    final thumbUrl = _currentVariationThumbPreviewUrl.trim().isNotEmpty
        ? _currentVariationThumbPreviewUrl.trim()
        : fullUrl;
    final tinyUrl = _currentVariationTinyPreviewUrl.trim();
    final media = MBProductMedia(
      id: 'variation_${_idController.text.trim()}_preview',
      url: fullUrl,
      originalUrl: originalUrl,
      fullUrl: fullUrl,
      cardUrl: cardUrl,
      thumbUrl: thumbUrl,
      tinyUrl: tinyUrl,
      type: 'image',
      role: 'thumbnail',
      isPrimary: true,
      isEnabled: true,
      sortOrder: 0,
    );

    return MBProduct(
      id: _idController.text.trim().isEmpty
          ? widget.initialValue.id
          : _idController.text.trim(),
      titleEn: _titleEnController.text.trim().isEmpty
          ? widget.initialValue.titleEn
          : _titleEnController.text.trim(),
      titleBn: _titleBnController.text.trim().isEmpty
          ? widget.initialValue.titleBn
          : _titleBnController.text.trim(),
      shortDescriptionEn: _shortDescriptionEnController.text.trim().isEmpty
          ? widget.initialValue.shortDescriptionEn
          : _shortDescriptionEnController.text.trim(),
      shortDescriptionBn: _shortDescriptionBnController.text.trim().isEmpty
          ? widget.initialValue.shortDescriptionBn
          : _shortDescriptionBnController.text.trim(),
      descriptionEn: _descriptionEnController.text.trim().isEmpty
          ? widget.initialValue.descriptionEn
          : _descriptionEnController.text.trim(),
      descriptionBn: _descriptionBnController.text.trim().isEmpty
          ? widget.initialValue.descriptionBn
          : _descriptionBnController.text.trim(),
      thumbnailUrl: thumbUrl,
      imageUrls: fullUrl.isEmpty ? const <String>[] : <String>[fullUrl],
      mediaItems: fullUrl.isEmpty ? const <MBProductMedia>[] : <MBProductMedia>[media],
      price: parseDouble(_priceController.text, fallback: widget.initialValue.price),
      salePrice: _salePriceController.text.trim().isEmpty
          ? widget.initialValue.salePrice
          : parseNullableDouble(_salePriceController.text),
      productType: 'simple',
      cardLayoutType: _currentVariationCardLayoutType,
      cardConfig: _currentVariationCardConfig,
      cardDesignJson: _currentVariationCardDesignJson,
      isEnabled: _isEnabled,
      quantityType: _quantityType,
      quantityValue: parseDouble(
        _quantityValueController.text,
        fallback: widget.initialValue.quantityValue,
      ),
      unitLabelEn: _unitLabelEnController.text.trim().isEmpty
          ? widget.initialValue.unitLabelEn
          : _unitLabelEnController.text.trim(),
      unitLabelBn: _unitLabelBnController.text.trim().isEmpty
          ? widget.initialValue.unitLabelBn
          : _unitLabelBnController.text.trim(),
      createdAt: widget.initialValue.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _addVariationPurchaseOption() async {
    final nextIndex = _purchaseOptions.length;
    final result = await showDialog<MBProductPurchaseOption>(
      context: context,
      builder: (_) => PurchaseOptionDialog(
        initialValue: MBProductPurchaseOption(
          id: makeEditorId('purchase_option'),
          mode: _supportsScheduledOrder ? 'scheduled' : 'instant',
          labelEn: _supportsScheduledOrder ? 'Scheduled' : 'Instant',
          labelBn: '',
          price: parseDouble(_priceController.text),
          salePrice: parseNullableDouble(_salePriceController.text),
          sortOrder: nextIndex,
          isDefault: _purchaseOptions.isEmpty,
          supportsDateSelection: _supportsScheduledOrder,
          fulfillmentType: _supportsScheduledOrder ? 'scheduled' : 'instant',
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _purchaseOptions = [..._purchaseOptions, result]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Future<void> _editVariationPurchaseOption(MBProductPurchaseOption option) async {
    final result = await showDialog<MBProductPurchaseOption>(
      context: context,
      builder: (_) => PurchaseOptionDialog(initialValue: option),
    );
    if (result == null) return;
    setState(() {
      _purchaseOptions = _purchaseOptions
          .map((item) => item.id == option.id ? result : item)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  Future<void> _pickResizeAndUploadVariationImage() async {
    setState(() {
      _isImageProcessing = true;
      _imageErrorText = null;
    });

    try {
      final MBOriginalPickedImage? original =
          await MBImagePipelineService.instance.pickOriginalImage();
      if (original == null) {
        setState(() => _isImageProcessing = false);
        return;
      }

      final MBPreparedImageSet prepared =
          await MBImagePipelineService.instance.prepareImageSetFromOriginal(
        original: original,
        fullMaxWidth: _variationFullMaxWidth,
        fullMaxHeight: _variationFullMaxHeight,
        fullJpegQuality: _variationFullJpegQuality,
        thumbSize: _variationThumbSize,
        thumbJpegQuality: _variationThumbJpegQuality,
        requestSquareCrop: false,
        requestAspectCrop: false,
        cropAspectRatioX: 4,
        cropAspectRatioY: 5,
        thumbWidth: _variationThumbWidth,
        thumbHeight: _variationThumbHeight,
        originalMaxLongSide: _variationOriginalMaxLongSide,
        originalJpegQuality: _variationOriginalJpegQuality,
        cardWidth: _variationCardWidth,
        cardHeight: _variationCardHeight,
        cardJpegQuality: _variationCardJpegQuality,
        tinyWidth: _variationTinyWidth,
        tinyHeight: _variationTinyHeight,
        tinyJpegQuality: _variationTinyJpegQuality,
      );

      setState(() {
        _preparedImage = prepared;
        // Do not upload here. The main Save Product button uploads this
        // pending variation image and then writes the final URL fields.
        _isImageProcessing = false;
      });
    } catch (error) {
      setState(() {
        _isImageProcessing = false;
        _imageErrorText = error.toString();
      });
    }
  }

  Future<void> _openVariationCardDesignStudioV3Dialog(BuildContext context) async {
    final previewProduct = _buildVariationPreviewProduct();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          child: SizedBox(
            width: size.width * 0.96,
            height: size.height * 0.92,
            child: MBCardDesignStudioAdvanced(
              products: [previewProduct],
              initialProductIndex: 0,
              initialDesignJson: _currentVariationCardDesignJson,
              title: 'Variation Card Design Studio V3',
              wrapWithScaffold: false,
              onSave: (json) => Navigator.of(dialogContext).pop(json),
            ),
          ),
        );
      },
    );
    if (!mounted || result == null) return;
    setState(() {
      final normalized = _normalizedCardDesignJsonForSave(result) ?? result.trim();
      _cardDesignJsonController.text = normalized;
      _cardLayoutTypeController.text = _normalizeCardLayoutTypeForSave(
        _cardLayoutTypeController.text,
        cardDesignJson: normalized,
      );
    });
  }

  MBProductVariation _buildResultVariation() {
    final parsedMetadata = _parseMetadataJson(
      _metadataJsonController.text,
      fallback: widget.initialValue.metadata,
    );
    final now = DateTime.now();
    final normalizedCardDesignJson =
        _normalizedCardDesignJsonForSave(_cardDesignJsonController.text);
    final normalizedCardLayoutType = _normalizeCardLayoutTypeForSave(
      _cardLayoutTypeController.text,
      cardDesignJson: normalizedCardDesignJson,
    );

    return widget.initialValue.copyWith(
      id: _idController.text.trim(),
      sku: _skuController.text.trim(),
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      clearBarcode: _barcodeController.text.trim().isEmpty,
      titleEn: _titleEnController.text.trim(),
      titleBn: _titleBnController.text.trim(),
      shortDescriptionEn: _shortDescriptionEnController.text.trim(),
      shortDescriptionBn: _shortDescriptionBnController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      fullImageUrl: _imageUrlController.text.trim(),
      thumbImageUrl: _thumbImageUrlController.text.trim(),
      originalImageUrl: widget.initialValue.originalImageUrl,
      originalImageStoragePath: widget.initialValue.originalImageStoragePath,
      cardImageUrl: widget.initialValue.cardImageUrl,
      cardImageStoragePath: widget.initialValue.cardImageStoragePath,
      tinyImageUrl: widget.initialValue.tinyImageUrl,
      tinyImageStoragePath: widget.initialValue.tinyImageStoragePath,
      fullImageStoragePath: widget.initialValue.fullImageStoragePath,
      thumbImageStoragePath: widget.initialValue.thumbImageStoragePath,
      fullImageWidth: _preparedImage?.fullWidth ?? widget.initialValue.fullImageWidth,
      fullImageHeight: _preparedImage?.fullHeight ?? widget.initialValue.fullImageHeight,
      thumbImageWidth: _preparedImage?.thumbWidth ?? widget.initialValue.thumbImageWidth,
      thumbImageHeight: _preparedImage?.thumbHeight ?? widget.initialValue.thumbImageHeight,
      fullImageSizeBytes:
          _preparedImage?.fullByteLength ?? widget.initialValue.fullImageSizeBytes,
      thumbImageSizeBytes:
          _preparedImage?.thumbByteLength ?? widget.initialValue.thumbImageSizeBytes,
      originalImageWidth:
          _preparedImage?.sourceWidth ?? widget.initialValue.originalImageWidth,
      originalImageHeight:
          _preparedImage?.sourceHeight ?? widget.initialValue.originalImageHeight,
      descriptionEn: _descriptionEnController.text.trim(),
      descriptionBn: _descriptionBnController.text.trim(),
      price: parseDouble(_priceController.text),
      salePrice: parseNullableDouble(_salePriceController.text),
      clearSalePrice: _salePriceController.text.trim().isEmpty,
      costPrice: parseNullableDouble(_costPriceController.text),
      clearCostPrice: _costPriceController.text.trim().isEmpty,
      saleStartsAt: _saleStartsAt,
      clearSaleStartsAt: _saleStartsAt == null,
      saleEndsAt: _saleEndsAt,
      clearSaleEndsAt: _saleEndsAt == null,
      schedulePriceType: _schedulePriceType,
      estimatedSchedulePrice: parseNullableDouble(_estimatedSchedulePriceController.text),
      clearEstimatedSchedulePrice: _estimatedSchedulePriceController.text.trim().isEmpty,
      stockQty: parseInt(_stockQtyController.text),
      reservedQty: parseInt(_reservedQtyController.text),
      inventoryMode: _inventoryMode,
      trackInventory: _trackInventory,
      supportsInstantOrder: _supportsInstantOrder,
      supportsScheduledOrder: _supportsScheduledOrder,
      allowBackorder: _allowBackorder,
      instantCutoffTime: _instantCutoffTimeController.text.trim().isEmpty
          ? null
          : _instantCutoffTimeController.text.trim(),
      clearInstantCutoffTime: _instantCutoffTimeController.text.trim().isEmpty,
      todayInstantCap: parseInt(_todayInstantCapController.text, fallback: 999999),
      todayInstantSold: parseInt(_todayInstantSoldController.text),
      maxScheduleQtyPerDay: parseInt(_maxScheduleQtyPerDayController.text, fallback: 999999),
      minScheduleNoticeHours: parseInt(_minScheduleNoticeHoursController.text),
      reorderLevel: parseInt(_reorderLevelController.text),
      quantityType: _quantityType,
      quantityValue: parseDouble(_quantityValueController.text),
      toleranceType: _toleranceType,
      tolerance: parseDouble(_toleranceController.text),
      isToleranceActive: _isToleranceActive,
      deliveryShift: _deliveryShift,
      minOrderQty: parseNullableDouble(_minOrderQtyController.text),
      clearMinOrderQty: _minOrderQtyController.text.trim().isEmpty,
      maxOrderQty: parseNullableDouble(_maxOrderQtyController.text),
      clearMaxOrderQty: _maxOrderQtyController.text.trim().isEmpty,
      stepQty: parseNullableDouble(_stepQtyController.text),
      clearStepQty: _stepQtyController.text.trim().isEmpty,
      unitLabelEn: _unitLabelEnController.text.trim().isEmpty
          ? null
          : _unitLabelEnController.text.trim(),
      clearUnitLabelEn: _unitLabelEnController.text.trim().isEmpty,
      unitLabelBn: _unitLabelBnController.text.trim().isEmpty
          ? null
          : _unitLabelBnController.text.trim(),
      clearUnitLabelBn: _unitLabelBnController.text.trim().isEmpty,
      purchaseOptions: [..._purchaseOptions]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
      attributeValues: _buildSelectedAttributeMap(),
      sortOrder: parseInt(_sortOrderController.text),
      isDefault: _isDefault,
      isEnabled: _isEnabled,
      isFeatured: _isFeatured,
      isFlashSale: _isFlashSale,
      isNewArrival: _isNewArrival,
      isBestSeller: _isBestSeller,
      publishAt: _publishAt,
      clearPublishAt: _publishAt == null,
      unpublishAt: _unpublishAt,
      clearUnpublishAt: _unpublishAt == null,
      views: parseInt(_viewsController.text),
      totalSold: parseInt(_totalSoldController.text),
      addToCartCount: parseInt(_addToCartCountController.text),
      cardLayoutType: normalizedCardLayoutType.trim().isEmpty
          ? null
          : normalizedCardLayoutType.trim(),
      clearCardLayoutType: normalizedCardLayoutType.trim().isEmpty,
      cardConfig: widget.initialValue.cardConfig,
      cardDesignJson: normalizedCardDesignJson,
      clearCardDesignJson:
          normalizedCardDesignJson == null || normalizedCardDesignJson.isEmpty,
      status: _status.trim().isEmpty ? 'active' : _status.trim(),
      taxClassId: _taxClassIdController.text.trim().isEmpty
          ? null
          : _taxClassIdController.text.trim(),
      clearTaxClassId: _taxClassIdController.text.trim().isEmpty,
      vatRate: parseNullableDouble(_vatRateController.text),
      clearVatRate: _vatRateController.text.trim().isEmpty,
      isTaxIncluded: _isTaxIncluded,
      weightValue: parseNullableDouble(_weightValueController.text),
      clearWeightValue: _weightValueController.text.trim().isEmpty,
      weightUnit: _weightUnitController.text.trim().isEmpty
          ? null
          : _weightUnitController.text.trim(),
      clearWeightUnit: _weightUnitController.text.trim().isEmpty,
      length: parseNullableDouble(_lengthController.text),
      clearLength: _lengthController.text.trim().isEmpty,
      width: parseNullableDouble(_widthController.text),
      clearWidth: _widthController.text.trim().isEmpty,
      height: parseNullableDouble(_heightController.text),
      clearHeight: _heightController.text.trim().isEmpty,
      dimensionUnit: _dimensionUnitController.text.trim().isEmpty
          ? null
          : _dimensionUnitController.text.trim(),
      clearDimensionUnit: _dimensionUnitController.text.trim().isEmpty,
      shippingClassId: _shippingClassIdController.text.trim().isEmpty
          ? null
          : _shippingClassIdController.text.trim(),
      clearShippingClassId: _shippingClassIdController.text.trim().isEmpty,
      adminNote: _adminNoteController.text.trim().isEmpty
          ? null
          : _adminNoteController.text.trim(),
      clearAdminNote: _adminNoteController.text.trim().isEmpty,
      metadata: parsedMetadata,
      isDeleted: _isDeleted,
      deletedAt: _isDeleted ? (_deletedAt ?? now) : null,
      clearDeletedAt: !_isDeleted,
      deletedBy: _deletedByController.text.trim().isEmpty
          ? (_isDeleted ? 'admin' : null)
          : _deletedByController.text.trim(),
      clearDeletedBy: !_isDeleted && _deletedByController.text.trim().isEmpty,
      deleteReason: _deleteReasonController.text.trim().isEmpty
          ? null
          : _deleteReasonController.text.trim(),
      clearDeleteReason: _deleteReasonController.text.trim().isEmpty,
      createdBy: _createdByController.text.trim().isEmpty
          ? widget.initialValue.createdBy
          : _createdByController.text.trim(),
      updatedBy: _updatedByController.text.trim().isEmpty
          ? widget.initialValue.updatedBy
          : _updatedByController.text.trim(),
      createdAt: widget.initialValue.createdAt ?? now,
      updatedAt: now,
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    final hasExistingImage = _imageUrlController.text.trim().isNotEmpty ||
        widget.initialValue.effectiveFullImageUrl.trim().isNotEmpty;
    final hasPendingImage = _preparedImage != null;

    if (!hasExistingImage && !hasPendingImage) {
      setState(() {
        _imageErrorText = 'Please select one variation image first.';
      });
      return;
    }

    Navigator.of(context).pop(
      ProductVariationDialogResult(
        variation: _buildResultVariation(),
        pendingImage: _preparedImage,
        imageFileStem: _titleEnController.text.trim().isEmpty
            ? (_preparedImage?.baseName ?? 'variation')
            : _titleEnController.text.trim(),
      ),
    );
  }

  List<_VariationSectionNavItem> _buildSectionNavItems() {
    return <_VariationSectionNavItem>[
      _VariationSectionNavItem(title: 'Help', icon: Icons.info_outline, targetKey: _helpKey),
      _VariationSectionNavItem(title: 'Identity', icon: Icons.badge_outlined, targetKey: _identityKey),
      _VariationSectionNavItem(title: 'Descriptions', icon: Icons.notes_outlined, targetKey: _descriptionsKey),
      _VariationSectionNavItem(title: 'Attribute Values', icon: Icons.tune_outlined, targetKey: _attributeValuesKey),
      _VariationSectionNavItem(title: 'Pricing', icon: Icons.sell_outlined, targetKey: _pricingKey),
      _VariationSectionNavItem(title: 'Purchase Options', icon: Icons.shopping_bag_outlined, targetKey: _purchaseOptionsKey),
      _VariationSectionNavItem(title: 'Merchandising', icon: Icons.local_offer_outlined, targetKey: _merchandisingKey),
      _VariationSectionNavItem(title: 'Merch Summary', icon: Icons.summarize_outlined, targetKey: _merchandisingSummaryKey),
      _VariationSectionNavItem(title: 'Status', icon: Icons.visibility_outlined, targetKey: _statusPublishingKey),
      _VariationSectionNavItem(title: 'Inventory', icon: Icons.inventory_2_outlined, targetKey: _inventoryKey),
      _VariationSectionNavItem(title: 'Quantity', icon: Icons.scale_outlined, targetKey: _quantityKey),
      _VariationSectionNavItem(title: 'Tax & Analytics', icon: Icons.analytics_outlined, targetKey: _taxShippingAnalyticsKey),
      _VariationSectionNavItem(title: 'Image & Card', icon: Icons.dashboard_customize_outlined, targetKey: _imageCardKey),
      _VariationSectionNavItem(title: 'Card & Audit', icon: Icons.verified_user_outlined, targetKey: _cardOverrideAuditKey),
    ];
  }

  Future<void> _scrollToSection(GlobalKey targetKey) async {
    final targetContext = targetKey.currentContext;
    if (targetContext == null) return;
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  Widget _buildSectionDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpanded = _sectionDrawerExpanded;
    final items = _buildSectionNavItems();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: isExpanded ? 210 : 48,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Tooltip(
            message: isExpanded ? 'Collapse sections' : 'Expand sections',
            waitDuration: const Duration(milliseconds: 350),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _sectionDrawerExpanded = !_sectionDrawerExpanded),
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: isExpanded ? 14 : 0),
                  alignment: isExpanded ? Alignment.centerLeft : Alignment.center,
                  child: Row(
                    mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                    children: [
                      Icon(
                        isExpanded ? Icons.keyboard_double_arrow_left_rounded : Icons.menu_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      if (isExpanded) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sections',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = items[index];
                return Tooltip(
                  message: item.title,
                  waitDuration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isExpanded ? 8 : 6),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _scrollToSection(item.targetKey),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.symmetric(
                            horizontal: isExpanded ? 10 : 0,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                            children: [
                              Icon(item.icon, size: 18, color: colorScheme.onSurfaceVariant),
                              if (isExpanded) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required GlobalKey key,
    required Widget child,
  }) {
    return KeyedSubtree(
      key: key,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: child,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Variation', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Edit one sellable variation with its own attributes, price, inventory, image, and card design.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isImageProcessing ? null : () => Navigator.of(context).pop(),
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
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _imageErrorText == null || _imageErrorText!.trim().isEmpty
                ? const SizedBox.shrink()
                : Text(
                    _imageErrorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          TextButton(
            onPressed: _isImageProcessing ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _isImageProcessing ? null : _handleSave,
            icon: _isImageProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isImageProcessing ? 'Processing...' : 'Save Variation'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return SectionCard(
      title: 'Help / instruction banner',
      subtitle: 'Variation editing rules.',
      child: Text(
        'Each variation keeps its own image, pricing, inventory, quantity settings, merchandising flags, and card design. For variable products, featured / flash sale / new arrival / best seller should be managed here.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildIdentitySection(BuildContext context) {
    return SectionCard(
      title: 'Identity',
      subtitle: 'Variation id, SKU, barcode, and display title.',
      child: Column(
        children: [
          dialogTextField(_idController, 'Id', validator: requiredValidator),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_skuController, 'SKU')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_barcodeController, 'Barcode')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_titleEnController, 'Title (English)', validator: requiredValidator)),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_titleBnController, 'Title (Bangla)')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_shortDescriptionEnController, 'Short Description (English)', maxLines: 2)),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_shortDescriptionBnController, 'Short Description (Bangla)', maxLines: 2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionsSection(BuildContext context) {
    return SectionCard(
      title: 'Variation Descriptions',
      subtitle: 'Long variation descriptions.',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: dialogTextField(_descriptionEnController, 'Description (English)', maxLines: 4)),
          const SizedBox(width: 12),
          Expanded(child: dialogTextField(_descriptionBnController, 'Description (Bangla)', maxLines: 4)),
        ],
      ),
    );
  }

  Widget _buildAttributeValuesSection(BuildContext context) {
    if (widget.variationAttributes.isEmpty) {
      return const SectionCard(
        title: 'Attribute Values',
        subtitle: 'Select one value for each variation attribute.',
        child: EmptyBlock(
          message: 'No variation attributes available. Add an attribute with "Use For Variation" and at least one enabled value first.',
        ),
      );
    }

    return SectionCard(
      title: 'Attribute Values',
      subtitle: 'Select one value for each variation attribute.',
      child: Column(
        children: widget.variationAttributes.map((attribute) {
          final values = _enabledValuesFor(attribute);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              initialValue: (_selectedAttributeValues[attribute.id] ?? '').trim().isEmpty
                  ? null
                  : _selectedAttributeValues[attribute.id],
              decoration: InputDecoration(
                labelText: attribute.nameEn.isEmpty
                    ? attribute.id
                    : '${attribute.nameEn} (${attribute.id})',
                border: const OutlineInputBorder(),
              ),
              items: values
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.value.trim(),
                      child: Text(
                        item.labelEn.trim().isEmpty
                            ? item.value
                            : '${item.labelEn} (${item.value})',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedAttributeValues[attribute.id] = value),
              validator: (value) {
                if (!attribute.useForVariation) return null;
                if ((value ?? '').trim().isEmpty) {
                  return 'Select a value for ${attribute.nameEn.isEmpty ? attribute.id : attribute.nameEn}';
                }
                return null;
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context) {
    return SectionCard(
      title: 'Variation Pricing',
      subtitle: 'Regular, sale, cost, and schedule pricing.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: dialogTextField(_priceController, 'Price', validator: requiredValidator)),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_salePriceController, 'Sale Price')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_costPriceController, 'Cost Price')),
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
                    final picked = await pickDateTime(context, initial: _saleStartsAt);
                    if (picked == null) return;
                    setState(() {
                      _saleStartsAt = picked;
                      _saleStartsAtController.text = formatDateTime(picked);
                    });
                  },
                  onClear: () => setState(() {
                    _saleStartsAt = null;
                    _saleStartsAtController.clear();
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildDateTimeField(
                  controller: _saleEndsAtController,
                  label: 'Sale Ends At',
                  onPick: () async {
                    final picked = await pickDateTime(context, initial: _saleEndsAt);
                    if (picked == null) return;
                    setState(() {
                      _saleEndsAt = picked;
                      _saleEndsAtController.text = formatDateTime(picked);
                    });
                  },
                  onClear: () => setState(() {
                    _saleEndsAt = null;
                    _saleEndsAtController.clear();
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: dialogDropdown(
                  label: 'Schedule Price Type',
                  value: _schedulePriceType,
                  items: const ['fixed', 'estimated', 'market'],
                  onChanged: (value) => setState(() => _schedulePriceType = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_estimatedSchedulePriceController, 'Estimated Schedule Price')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOptionsSection(BuildContext context) {
    return SectionCard(
      title: 'Variation Purchase Options',
      subtitle: 'Optional variation-specific instant/scheduled purchase modes.',
      action: FilledButton.icon(
        onPressed: _addVariationPurchaseOption,
        icon: const Icon(Icons.add),
        label: const Text('Add Option'),
      ),
      child: _purchaseOptions.isEmpty
          ? const EmptyBlock(message: 'No variation-specific purchase options added.')
          : Column(
              children: _purchaseOptions
                  .map(
                    (item) => EditableTile(
                      title: item.labelEn.trim().isEmpty ? item.id : item.labelEn,
                      subtitle: 'mode: ${item.mode} • price: ${item.price} • default: ${item.isDefault}',
                      onEdit: () => _editVariationPurchaseOption(item),
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

  Widget _buildMerchandisingSection(BuildContext context) {
    return SectionCard(
      title: 'Variation Merchandising',
      subtitle: 'Variation-level dynamic section flags.',
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          buildFilterChip(label: 'Featured', selected: _isFeatured, onSelected: (value) => setState(() => _isFeatured = value)),
          buildFilterChip(label: 'Flash Sale', selected: _isFlashSale, onSelected: (value) => setState(() => _isFlashSale = value)),
          buildFilterChip(label: 'New Arrival', selected: _isNewArrival, onSelected: (value) => setState(() => _isNewArrival = value)),
          buildFilterChip(label: 'Best Seller', selected: _isBestSeller, onSelected: (value) => setState(() => _isBestSeller = value)),
        ],
      ),
    );
  }

  Widget _buildMerchandisingSummarySection(BuildContext context) {
    return SectionCard(
      title: 'Merchandising summary chips',
      subtitle: 'Quick review of selected merchandising flags.',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          buildInfoChip('featured: $_isFeatured'),
          buildInfoChip('flash_sale: $_isFlashSale'),
          buildInfoChip('new_arrival: $_isNewArrival'),
          buildInfoChip('best_seller: $_isBestSeller'),
        ],
      ),
    );
  }

  Widget _buildStatusPublishingSection(BuildContext context) {
    return SectionCard(
      title: 'Variation Status and Publishing',
      subtitle: 'Status, default/enabled/delete flags, and publish window.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: dialogDropdown(
                  label: 'Status',
                  value: _status,
                  items: const ['draft', 'active', 'inactive', 'scheduled', 'archived', 'out_of_stock'],
                  onChanged: (value) => setState(() => _status = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    buildFilterChip(label: 'Default', selected: _isDefault, onSelected: (value) => setState(() => _isDefault = value)),
                    buildFilterChip(label: 'Enabled', selected: _isEnabled, onSelected: (value) => setState(() => _isEnabled = value)),
                    buildFilterChip(label: 'Deleted', selected: _isDeleted, onSelected: (value) => setState(() => _isDeleted = value)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildDateTimeField(
                  controller: _publishAtController,
                  label: 'Publish At',
                  onPick: () async {
                    final picked = await pickDateTime(context, initial: _publishAt);
                    if (picked == null) return;
                    setState(() {
                      _publishAt = picked;
                      _publishAtController.text = formatDateTime(picked);
                    });
                  },
                  onClear: () => setState(() {
                    _publishAt = null;
                    _publishAtController.clear();
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildDateTimeField(
                  controller: _unpublishAtController,
                  label: 'Unpublish At',
                  onPick: () async {
                    final picked = await pickDateTime(context, initial: _unpublishAt);
                    if (picked == null) return;
                    setState(() {
                      _unpublishAt = picked;
                      _unpublishAtController.text = formatDateTime(picked);
                    });
                  },
                  onClear: () => setState(() {
                    _unpublishAt = null;
                    _unpublishAtController.clear();
                  }),
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
      title: 'Variation Inventory and Availability',
      subtitle: 'Stock, inventory mode, order support, capacity, and backorder rules.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: dialogDropdown(
                  label: 'Inventory Mode',
                  value: _inventoryMode,
                  items: const ['stocked', 'hybrid_fresh', 'schedule_only', 'untracked'],
                  onChanged: (value) => setState(() => _inventoryMode = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_instantCutoffTimeController, 'Instant Cutoff Time')),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              buildFilterChip(label: 'Track Inventory', selected: _trackInventory, onSelected: (value) => setState(() => _trackInventory = value)),
              buildFilterChip(label: 'Supports Instant Order', selected: _supportsInstantOrder, onSelected: (value) => setState(() => _supportsInstantOrder = value)),
              buildFilterChip(label: 'Supports Scheduled Order', selected: _supportsScheduledOrder, onSelected: (value) => setState(() => _supportsScheduledOrder = value)),
              buildFilterChip(label: 'Allow Backorder', selected: _allowBackorder, onSelected: (value) => setState(() => _allowBackorder = value)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_stockQtyController, 'Stock Qty')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_reservedQtyController, 'Reserved Qty')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_reorderLevelController, 'Reorder Level')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_todayInstantCapController, 'Today Instant Cap')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_todayInstantSoldController, 'Today Instant Sold')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_maxScheduleQtyPerDayController, 'Max Schedule Qty / Day')),
            ],
          ),
          const SizedBox(height: 12),
          dialogTextField(_minScheduleNoticeHoursController, 'Min Schedule Notice Hours'),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(BuildContext context) {
    return SectionCard(
      title: 'Variation Quantity, Packaging, and Tolerance',
      subtitle: 'Quantity unit, tolerance, min/max order, step, and delivery shift.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: dialogDropdown(
                  label: 'Quantity Type',
                  value: _quantityType,
                  items: const ['pcs', 'kg', 'g', 'litre', 'ml', 'pack'],
                  onChanged: (value) => setState(() => _quantityType = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_quantityValueController, 'Quantity Value')),
              const SizedBox(width: 12),
              Expanded(
                child: dialogDropdown(
                  label: 'Tolerance Type',
                  value: _toleranceType,
                  items: const ['g', 'kg', '%', 'ml'],
                  onChanged: (value) => setState(() => _toleranceType = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_toleranceController, 'Tolerance')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_minOrderQtyController, 'Min Order Qty')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_maxOrderQtyController, 'Max Order Qty')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_stepQtyController, 'Step Qty')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_unitLabelEnController, 'Unit Label (English)')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_unitLabelBnController, 'Unit Label (Bangla)')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: dialogDropdown(
                  label: 'Delivery Shift',
                  value: _deliveryShift,
                  items: const ['any', 'morning', 'afternoon', 'evening'],
                  onChanged: (value) => setState(() => _deliveryShift = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: buildFilterChip(
                    label: 'Tolerance Active',
                    selected: _isToleranceActive,
                    onSelected: (value) => setState(() => _isToleranceActive = value),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxShippingAnalyticsSection(BuildContext context) {
    return SectionCard(
      title: 'Tax, Shipping, Physical Info, and Analytics',
      subtitle: 'Tax, weight, dimensions, shipping class, and counters.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: dialogTextField(_taxClassIdController, 'Tax Class ID')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_vatRateController, 'VAT Rate (%)')),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: buildFilterChip(
                    label: 'Tax Included',
                    selected: _isTaxIncluded,
                    onSelected: (value) => setState(() => _isTaxIncluded = value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_weightValueController, 'Weight Value')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_weightUnitController, 'Weight Unit')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_shippingClassIdController, 'Shipping Class ID')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_lengthController, 'Length')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_widthController, 'Width')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_heightController, 'Height')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_dimensionUnitController, 'Dimension Unit')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_viewsController, 'Views')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_totalSoldController, 'Total Sold')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_addToCartCountController, 'Add To Cart Count')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariationPrimaryImageSurface(BuildContext context) {
    final Widget child;
    if (_preparedImage?.previewBytes != null) {
      child = Image.memory(
        _preparedImage!.previewBytes,
        height: 320,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    } else if (_currentVariationFullPreviewUrl.trim().isNotEmpty) {
      child = Image.network(
        _currentVariationFullPreviewUrl.trim(),
        height: 320,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 48),
      );
    } else {
      child = const Icon(Icons.image_outlined, size: 56);
    }

    return Container(
      height: 320,
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
    );
  }

  Widget _buildVariationRealCardPreviewSurface(BuildContext context) {
    final previewProduct = _buildVariationPreviewProduct();
    return Container(
      height: 320,
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: SizedBox(
        width: 220,
        child: MBProductCardRenderer(
          product: previewProduct,
          contextType: MBProductCardRenderContext.grid,
        ),
      ),
    );
  }

  Widget _buildVariationActionBox(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget preview,
    required Widget action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          preview,
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: action),
        ],
      ),
    );
  }

  Widget _buildVariationImageCardSection(BuildContext context) {
    return SectionCard(
      title: 'Variation Image & Card Design',
      subtitle: 'One variation image plus the real customer-app card preview/design.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stack = constraints.maxWidth < 760;
              final leftBox = _buildVariationActionBox(
                context,
                title: 'Variation Image',
                subtitle: 'Max 1 image. Generates original, full, card, thumb, and tiny sizes.',
                preview: _buildVariationPrimaryImageSurface(context),
                action: FilledButton.icon(
                  onPressed: _isImageProcessing ? null : _pickResizeAndUploadVariationImage,
                  icon: _isImageProcessing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.image_outlined),
                  label: const Text('Select Image'),
                ),
              );
              final rightBox = _buildVariationActionBox(
                context,
                title: 'Card Preview',
                subtitle: 'Uses the real card renderer path used by saved Studio V3 designs.',
                preview: _buildVariationRealCardPreviewSurface(context),
                action: FilledButton.icon(
                  onPressed: () => _openVariationCardDesignStudioV3Dialog(context),
                  icon: const Icon(Icons.auto_awesome_motion_rounded),
                  label: const Text('Card Design'),
                ),
              );
              if (stack) {
                return Column(children: [leftBox, const SizedBox(height: 12), rightBox]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: leftBox),
                  const SizedBox(width: 12),
                  Expanded(child: rightBox),
                ],
              );
            },
          ),
          if (_imageErrorText != null && _imageErrorText!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              _imageErrorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildVariationImageInfo(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_thumbImageUrlController, 'Variation Thumb URL')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_imageUrlController, 'Variation Full URL')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVariationImageInfo() {
    if (_preparedImage == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Original Pixels: -'),
          Text('Original Ratio: -'),
          Text('Cropped Pixels: -'),
          Text('Crop Ratio: -'),
          Text('Crop Zoom: -'),
          Text('Cropped Size: -'),
          Text('Full Pixels: -'),
          Text('Full Size: -'),
          Text('Thumb Pixels: -'),
          Text('Thumb Size: -'),
        ],
      );
    }
    final p = _preparedImage!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Original Pixels: ${p.sourceWidth} x ${p.sourceHeight}'),
        Text('Original Ratio: ${_ratioText(p.sourceWidth, p.sourceHeight)}'),
        Text('Cropped Pixels: ${p.croppedWidth} x ${p.croppedHeight}'),
        Text('Crop Ratio: ${p.cropAspectRatioX}:${p.cropAspectRatioY}'),
        Text('Crop Zoom: ${p.zoomScale.toStringAsFixed(2)}'),
        Text('Cropped Size: ${_bytesText(p.croppedByteLength)}'),
        Text('Full Pixels: ${p.fullWidth} x ${p.fullHeight}'),
        Text('Full Size: ${_bytesText(p.fullByteLength)}'),
        Text('Thumb Pixels: ${p.thumbWidth} x ${p.thumbHeight}'),
        Text('Thumb Size: ${_bytesText(p.thumbByteLength)}'),
      ],
    );
  }

  Widget _buildCardOverrideAuditSection(BuildContext context) {
    return SectionCard(
      title: 'Card Override and Audit',
      subtitle: 'Advanced card override fields plus admin/audit metadata.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: dialogTextField(_cardLayoutTypeController, 'Card Layout Type Override')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_createdByController, 'Created By')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_updatedByController, 'Updated By')),
            ],
          ),
          const SizedBox(height: 12),
          dialogTextField(_cardDesignJsonController, 'Card Design JSON Override', maxLines: 3),
          const SizedBox(height: 12),
          dialogTextField(_adminNoteController, 'Admin Note', maxLines: 3),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: dialogTextField(_deletedByController, 'Deleted By')),
              const SizedBox(width: 12),
              Expanded(child: dialogTextField(_deleteReasonController, 'Delete Reason')),
            ],
          ),
          const SizedBox(height: 12),
          dialogTextField(_metadataJsonController, 'Metadata JSON', maxLines: 5, validator: _metadataJsonValidator),
        ],
      ),
    );
  }

  Widget _buildRightInfoPanel(BuildContext context) {
    final selectedAttributeCount = _buildSelectedAttributeMap().length;
    final hasImage = _currentVariationFullPreviewUrl.trim().isNotEmpty;
    final hasCardDesign = _currentVariationCardDesignJson?.trim().isNotEmpty == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            title: 'Variation Information',
            subtitle: 'Right panel helper only. This panel is not stored separately.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleEnController.text.trim().isEmpty ? 'Untitled Variation' : _titleEnController.text.trim(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    buildInfoChip('id: ${_idController.text.trim().isEmpty ? '-' : _idController.text.trim()}'),
                    buildInfoChip('sku: ${_skuController.text.trim().isEmpty ? '-' : _skuController.text.trim()}'),
                    buildInfoChip('price: ${parseDouble(_priceController.text, fallback: widget.initialValue.price).toStringAsFixed(2)}'),
                    buildInfoChip('sale: ${parseNullableDouble(_salePriceController.text)?.toStringAsFixed(2) ?? '-'}'),
                    buildInfoChip('attributes: $selectedAttributeCount'),
                    buildInfoChip('image: $hasImage'),
                    buildInfoChip('card design: $hasCardDesign'),
                    buildInfoChip('enabled: $_isEnabled'),
                    buildInfoChip('default: $_isDefault'),
                    buildInfoChip('status: $_status'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Save checklist',
            subtitle: 'Quick sanity check before saving.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildReadOnlyInfoRow('Image selected', hasImage.toString()),
                buildReadOnlyInfoRow('Card design', hasCardDesign ? 'custom V3 design' : 'default/fallback'),
                buildReadOnlyInfoRow('Selected attributes', selectedAttributeCount.toString()),
                buildReadOnlyInfoRow('Inventory mode', _inventoryMode),
                buildReadOnlyInfoRow('Quantity type', _quantityType),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalInset = _dialogHorizontalInset(screenSize.width);
    final verticalInset = _dialogVerticalInset(screenSize.height);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: horizontalInset, vertical: verticalInset),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: _dialogWidthFor(screenSize.width),
        height: _dialogHeightFor(screenSize.height),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    _buildSectionDrawer(context),
                    Container(width: 1, color: Theme.of(context).dividerColor),
                    Expanded(
                      flex: 7,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _section(key: _helpKey, child: _buildHelpSection(context)),
                            _section(key: _identityKey, child: _buildIdentitySection(context)),
                            _section(key: _descriptionsKey, child: _buildDescriptionsSection(context)),
                            _section(key: _attributeValuesKey, child: _buildAttributeValuesSection(context)),
                            _section(key: _pricingKey, child: _buildPricingSection(context)),
                            _section(key: _purchaseOptionsKey, child: _buildPurchaseOptionsSection(context)),
                            _section(key: _merchandisingKey, child: _buildMerchandisingSection(context)),
                            _section(key: _merchandisingSummaryKey, child: _buildMerchandisingSummarySection(context)),
                            _section(key: _statusPublishingKey, child: _buildStatusPublishingSection(context)),
                            _section(key: _inventoryKey, child: _buildInventorySection(context)),
                            _section(key: _quantityKey, child: _buildQuantitySection(context)),
                            _section(key: _taxShippingAnalyticsKey, child: _buildTaxShippingAnalyticsSection(context)),
                            _section(key: _imageCardKey, child: _buildVariationImageCardSection(context)),
                            _section(key: _cardOverrideAuditKey, child: _buildCardOverrideAuditSection(context)),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1, color: Theme.of(context).dividerColor),
                    Expanded(flex: 3, child: _buildRightInfoPanel(context)),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }
}
