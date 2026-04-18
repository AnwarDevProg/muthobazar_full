import 'package:admin_web/features/marketing/controllers/admin_home_section_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class AdminHomeSectionFormDialog extends StatefulWidget {
  const AdminHomeSectionFormDialog({
    super.key,
    this.section,
  });

  final MBHomeSection? section;

  @override
  State<AdminHomeSectionFormDialog> createState() =>
      _AdminHomeSectionFormDialogState();
}

class _AdminHomeSectionFormDialogState
    extends State<AdminHomeSectionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleEnController;
  late final TextEditingController _titleBnController;
  late final TextEditingController _subtitleEnController;
  late final TextEditingController _subtitleBnController;
  late final TextEditingController _sourceCategoryIdController;
  late final TextEditingController _sourceBrandIdController;
  late final TextEditingController _bannerIdsController;
  late final TextEditingController _offerIdsController;
  late final TextEditingController _productIdsController;
  late final TextEditingController _categoryIdsController;
  late final TextEditingController _brandIdsController;
  late final TextEditingController _itemLimitController;
  late final TextEditingController _sortOrderController;

  late String _sectionType;
  late String _layoutStyle;
  late String _dataSourceType;
  late bool _showViewAll;
  late bool _isActive;

  bool _loadingSuggestedSort = false;

  bool get _isEdit => widget.section != null;

  @override
  void initState() {
    super.initState();

    final MBHomeSection section = widget.section ?? MBHomeSection.empty();

    _titleEnController = TextEditingController(text: section.titleEn);
    _titleBnController = TextEditingController(text: section.titleBn);
    _subtitleEnController = TextEditingController(text: section.subtitleEn);
    _subtitleBnController = TextEditingController(text: section.subtitleBn);
    _sourceCategoryIdController = TextEditingController(
      text: section.sourceCategoryId ?? '',
    );
    _sourceBrandIdController = TextEditingController(
      text: section.sourceBrandId ?? '',
    );
    _bannerIdsController = TextEditingController(
      text: _joinIds(section.bannerIds),
    );
    _offerIdsController = TextEditingController(
      text: _joinIds(section.offerIds),
    );
    _productIdsController = TextEditingController(
      text: _joinIds(section.productIds),
    );
    _categoryIdsController = TextEditingController(
      text: _joinIds(section.categoryIds),
    );
    _brandIdsController = TextEditingController(
      text: _joinIds(section.brandIds),
    );
    _itemLimitController = TextEditingController(
      text: section.itemLimit.toString(),
    );
    _sortOrderController = TextEditingController(
      text: section.sortOrder.toString(),
    );

    _sectionType = section.sectionType.trim().isEmpty
        ? 'product_horizontal'
        : section.sectionType.trim().toLowerCase();
    _layoutStyle = section.layoutStyle.trim().isEmpty
        ? 'standard'
        : section.layoutStyle.trim().toLowerCase();
    _dataSourceType = section.dataSourceType.trim().isEmpty
        ? 'manual'
        : section.dataSourceType.trim().toLowerCase();
    _showViewAll = section.showViewAll;
    _isActive = section.isActive;

    if (!_isEdit) {
      _loadSuggestedSortOrder();
    }
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleBnController.dispose();
    _subtitleEnController.dispose();
    _subtitleBnController.dispose();
    _sourceCategoryIdController.dispose();
    _sourceBrandIdController.dispose();
    _bannerIdsController.dispose();
    _offerIdsController.dispose();
    _productIdsController.dispose();
    _categoryIdsController.dispose();
    _brandIdsController.dispose();
    _itemLimitController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestedSortOrder() async {
    final controller = Get.find<AdminHomeSectionController>();

    setState(() {
      _loadingSuggestedSort = true;
    });

    try {
      final int sortOrder = await controller.suggestSortOrder();
      if (!mounted) return;
      _sortOrderController.text = sortOrder.toString();
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingSuggestedSort = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AdminHomeSectionController controller = Get.find();

    return Dialog(
      insetPadding: const EdgeInsets.all(MBSpacing.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MBRadius.xl),
      ),
      child: Container(
        width: 980,
        constraints: const BoxConstraints(maxHeight: 860),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MBRadius.xl),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(MBSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoCard(),
                      MBSpacing.h(MBSpacing.lg),
                      _buildLayoutCard(),
                      MBSpacing.h(MBSpacing.lg),
                      _buildSourceCard(),
                      MBSpacing.h(MBSpacing.lg),
                      _buildIdMappingCard(),
                      MBSpacing.h(MBSpacing.lg),
                      _buildSettingsCard(),
                    ],
                  ),
                ),
              ),
            ),
            Obx(
                  () => _buildFooter(
                isSaving: controller.isSaving.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MBColors.border.withValues(alpha: 0.85),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit ? 'Edit Home Section' : 'Create Home Section',
                  style: MBTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MBSpacing.h(MBSpacing.xxs),
                Text(
                  'Configure how this section should appear on the customer app home screen.',
                  style: MBTextStyles.body.copyWith(
                    color: MBColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _SectionCard(
      title: 'Basic Information',
      subtitle: 'Titles and subtitles for English and Bangla.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _titleEnController,
                  decoration: const InputDecoration(
                    labelText: 'Title (English)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'English title is required.';
                    }
                    return null;
                  },
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: _titleBnController,
                  decoration: const InputDecoration(
                    labelText: 'Title (Bangla)',
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
                  controller: _subtitleEnController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle (English)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: _subtitleBnController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle (Bangla)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutCard() {
    return _SectionCard(
      title: 'Section Layout',
      subtitle: 'Choose the type of section and visual layout style.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sectionType,
                  decoration: const InputDecoration(
                    labelText: 'Section Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _sectionTypeOptions
                      .map(
                        (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(_labelize(value)),
                    ),
                  )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _sectionType = value;
                      if (_sectionType == 'hero_banner' ||
                          _sectionType == 'promo_banner') {
                        _dataSourceType = 'manual';
                      }
                    });
                  },
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _layoutStyle,
                  decoration: const InputDecoration(
                    labelText: 'Layout Style',
                    border: OutlineInputBorder(),
                  ),
                  items: _layoutStyleOptions
                      .map(
                        (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(_labelize(value)),
                    ),
                  )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _layoutStyle = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard() {
    final bool allowCategorySource =
        _sectionType == 'product_horizontal' ||
            _sectionType == 'product_grid' ||
            _sectionType == 'category_grid';
    final bool allowBrandSource =
        _sectionType == 'product_horizontal' ||
            _sectionType == 'product_grid' ||
            _sectionType == 'brand_row';

    final List<String> sourceOptions = [
      'manual',
      if (_sectionType == 'product_horizontal' || _sectionType == 'product_grid')
        ...[
          'featured',
          'flash_sale',
          'new_arrival',
          'best_seller',
          'recommended',
        ],
      if (allowCategorySource) 'category',
      if (allowBrandSource) 'brand',
    ];

    return _SectionCard(
      title: 'Data Source',
      subtitle: 'Select how this section will resolve its content.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue:
                  sourceOptions.contains(_dataSourceType) ? _dataSourceType : 'manual',
                  decoration: const InputDecoration(
                    labelText: 'Data Source Type',
                    border: OutlineInputBorder(),
                  ),
                  items: sourceOptions
                      .map(
                        (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(_labelize(value)),
                    ),
                  )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _dataSourceType = value;
                      if (_dataSourceType != 'category') {
                        _sourceCategoryIdController.clear();
                      }
                      if (_dataSourceType != 'brand') {
                        _sourceBrandIdController.clear();
                      }
                    });
                  },
                ),
              ),
              if (_dataSourceType == 'category') ...[
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _sourceCategoryIdController,
                    decoration: const InputDecoration(
                      labelText: 'Source Category ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_dataSourceType == 'category' &&
                          (value ?? '').trim().isEmpty) {
                        return 'Category id is required.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
              if (_dataSourceType == 'brand') ...[
                MBSpacing.w(MBSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _sourceBrandIdController,
                    decoration: const InputDecoration(
                      labelText: 'Source Brand ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_dataSourceType == 'brand' &&
                          (value ?? '').trim().isEmpty) {
                        return 'Brand id is required.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdMappingCard() {
    final bool isBannerSection =
        _sectionType == 'hero_banner' || _sectionType == 'promo_banner';
    final bool isOfferSection = _sectionType == 'offer_strip';
    final bool isCategorySection = _sectionType == 'category_grid';
    final bool isBrandSection = _sectionType == 'brand_row';
    final bool isProductSection =
        _sectionType == 'product_horizontal' || _sectionType == 'product_grid';

    return _SectionCard(
      title: 'Manual ID Mapping',
      subtitle:
      'Enter ids separated by comma or new line. Only the relevant fields are used for the selected section.',
      child: Column(
        children: [
          if (isBannerSection)
            _buildIdField(
              controller: _bannerIdsController,
              label: 'Banner IDs',
              hint: 'banner_doc_id_1\nbanner_doc_id_2',
            ),
          if (isOfferSection)
            _buildIdField(
              controller: _offerIdsController,
              label: 'Offer IDs',
              hint: 'offer_doc_id_1\noffer_doc_id_2',
            ),
          if (isCategorySection)
            _buildIdField(
              controller: _categoryIdsController,
              label: 'Category IDs',
              hint: 'category_doc_id_1\ncategory_doc_id_2',
            ),
          if (isBrandSection)
            _buildIdField(
              controller: _brandIdsController,
              label: 'Brand IDs',
              hint: 'brand_doc_id_1\nbrand_doc_id_2',
            ),
          if (isProductSection) ...[
            if (_dataSourceType == 'manual')
              _buildIdField(
                controller: _productIdsController,
                label: 'Product IDs',
                hint: 'product_doc_id_1\nproduct_doc_id_2',
              ),
            if (_dataSourceType == 'manual') ...[
              MBSpacing.h(MBSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildIdField(
                      controller: _categoryIdsController,
                      label: 'Optional Category IDs',
                      hint: 'category_doc_id_1\ncategory_doc_id_2',
                    ),
                  ),
                  MBSpacing.w(MBSpacing.md),
                  Expanded(
                    child: _buildIdField(
                      controller: _brandIdsController,
                      label: 'Optional Brand IDs',
                      hint: 'brand_doc_id_1\nbrand_doc_id_2',
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (!isBannerSection &&
              !isOfferSection &&
              !isCategorySection &&
              !isBrandSection &&
              !isProductSection)
            Text(
              'No id mapping fields are needed for this section type.',
              style: MBTextStyles.body.copyWith(
                color: MBColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return _SectionCard(
      title: 'Display Settings',
      subtitle: 'Sort order, item limit, visibility, and status.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _itemLimitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Item Limit',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final int? parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null || parsed < 1) {
                      return 'Enter a valid limit.';
                    }
                    return null;
                  },
                ),
              ),
              MBSpacing.w(MBSpacing.md),
              Expanded(
                child: TextFormField(
                  controller: _sortOrderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Sort Order',
                    border: const OutlineInputBorder(),
                    suffixIcon: _loadingSuggestedSort
                        ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                        : IconButton(
                      tooltip: 'Suggest next sort order',
                      onPressed: _loadSuggestedSortOrder,
                      icon: const Icon(Icons.auto_fix_high_rounded),
                    ),
                  ),
                  validator: (value) {
                    final int? parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid sort order.';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          MBSpacing.h(MBSpacing.md),
          SwitchListTile.adaptive(
            value: _showViewAll,
            onChanged: (value) {
              setState(() {
                _showViewAll = value;
              });
            },
            contentPadding: EdgeInsets.zero,
            title: const Text('Show View All'),
            subtitle: const Text('Display the View All action for this section.'),
          ),
          SwitchListTile.adaptive(
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            contentPadding: EdgeInsets.zero,
            title: const Text('Active'),
            subtitle: const Text('Inactive sections are saved but hidden from home.'),
          ),
        ],
      ),
    );
  }

  Widget _buildIdField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      minLines: 4,
      maxLines: 6,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildFooter({required bool isSaving}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: MBColors.border.withValues(alpha: 0.85),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: isSaving ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          MBSpacing.w(MBSpacing.sm),
          ElevatedButton.icon(
            onPressed: isSaving ? null : _submit,
            icon: isSaving
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Icon(_isEdit ? Icons.save_outlined : Icons.add_rounded),
            label: Text(_isEdit ? 'Update Section' : 'Create Section'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Get.find<AdminHomeSectionController>();

    final int itemLimit = int.tryParse(_itemLimitController.text.trim()) ?? 10;
    final int sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 0;

    final bool sortExists = await controller.sortExists(
      sortOrder: sortOrder,
      excludeSectionId: widget.section?.id,
    );

    if (sortExists) {
      Get.snackbar(
        'Duplicate Sort Order',
        'Another home section already uses sort order $sortOrder.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final MBHomeSection section = MBHomeSection(
      id: widget.section?.id ?? '',
      titleEn: _titleEnController.text.trim(),
      titleBn: _titleBnController.text.trim(),
      subtitleEn: _subtitleEnController.text.trim(),
      subtitleBn: _subtitleBnController.text.trim(),
      sectionType: _sectionType,
      layoutStyle: _layoutStyle,
      bannerIds: _shouldUseBannerIds ? _parseIds(_bannerIdsController.text) : const [],
      offerIds: _shouldUseOfferIds ? _parseIds(_offerIdsController.text) : const [],
      productIds: _shouldUseProductIds ? _parseIds(_productIdsController.text) : const [],
      categoryIds: _shouldUseCategoryIds ? _parseIds(_categoryIdsController.text) : const [],
      brandIds: _shouldUseBrandIds ? _parseIds(_brandIdsController.text) : const [],
      dataSourceType: _dataSourceType,
      sourceCategoryId: _dataSourceType == 'category'
          ? _normalizedOrNull(_sourceCategoryIdController.text)
          : null,
      sourceBrandId: _dataSourceType == 'brand'
          ? _normalizedOrNull(_sourceBrandIdController.text)
          : null,
      itemLimit: itemLimit,
      showViewAll: _showViewAll,
      isActive: _isActive,
      sortOrder: sortOrder,
    );

    final bool success = _isEdit
        ? await controller.updateSection(section)
        : (await controller.createSection(section)) != null;

    if (success && mounted) {
      Get.back();
    }
  }

  bool get _shouldUseBannerIds =>
      _sectionType == 'hero_banner' || _sectionType == 'promo_banner';

  bool get _shouldUseOfferIds => _sectionType == 'offer_strip';

  bool get _shouldUseProductIds =>
      (_sectionType == 'product_horizontal' || _sectionType == 'product_grid') &&
          _dataSourceType == 'manual';

  bool get _shouldUseCategoryIds =>
      _sectionType == 'category_grid' ||
          ((_sectionType == 'product_horizontal' || _sectionType == 'product_grid') &&
              _dataSourceType == 'manual');

  bool get _shouldUseBrandIds =>
      _sectionType == 'brand_row' ||
          ((_sectionType == 'product_horizontal' || _sectionType == 'product_grid') &&
              _dataSourceType == 'manual');

  List<String> _parseIds(String raw) {
    return raw
        .split(RegExp(r'[,\n]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  String _joinIds(List<dynamic> values) {
    return values.map((item) => item.toString()).join('\n');
  }

  String? _normalizedOrNull(String value) {
    final String normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  String _labelize(String value) {
    final parts = value.trim().split('_').where((part) => part.isNotEmpty);
    return parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static const List<String> _sectionTypeOptions = [
    'hero_banner',
    'category_grid',
    'product_horizontal',
    'product_grid',
    'offer_strip',
    'promo_banner',
    'brand_row',
  ];

  static const List<String> _layoutStyleOptions = [
    'compact',
    'standard',
    'large',
    'card',
    'slider',
  ];
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MBRadius.lg),
        border: Border.all(
          color: MBColors.border.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MBTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          MBSpacing.h(MBSpacing.xxs),
          Text(
            subtitle,
            style: MBTextStyles.caption.copyWith(
              color: MBColors.textSecondary,
            ),
          ),
          MBSpacing.h(MBSpacing.md),
          child,
        ],
      ),
    );
  }
}
