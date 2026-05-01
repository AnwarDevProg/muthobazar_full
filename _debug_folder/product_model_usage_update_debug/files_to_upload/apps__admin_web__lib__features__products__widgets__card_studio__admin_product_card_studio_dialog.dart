import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/mb_product_card_renderer.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_card_config_resolver.dart';

// File: admin_product_card_studio_dialog.dart
// Location:
// apps/admin_web/lib/features/products/widgets/card_studio/admin_product_card_studio_dialog.dart
//
// Purpose:
// Admin product-card studio for product create/edit.
//
// Final UX:
// - Product dialog opens this one dialog for both card selection and card editing.
// - Left side changes between Pick mode and Edit mode.
// - Right side is one persistent medium mobile-phone preview.
// - No duplicate/small preview is shown inside the picker or settings panel.
// - Preview stays alive while selecting variants or changing settings.
// - Preview closes only when this studio dialog closes.
//
// Integration:
// Call AdminProductCardStudioDialog.show(...) from the product dialog.
// previewProductBuilder must build an MBProduct from the current unsaved form
// values and apply the supplied MBCardInstanceConfig.

typedef AdminProductCardPreviewBuilder = MBProduct Function(
  MBCardInstanceConfig cardConfig,
);

enum AdminProductCardStudioMode {
  pick,
  edit,
}

class AdminProductCardStudioResult {
  const AdminProductCardStudioResult({
    required this.cardConfig,
    required this.variant,
    required this.family,
  });

  final MBCardInstanceConfig cardConfig;
  final MBCardVariant variant;
  final MBCardFamily family;

  String get variantId => variant.id;
  String get familyId => family.id;
}

class AdminProductCardStudioDialog extends StatefulWidget {
  const AdminProductCardStudioDialog({
    super.key,
    required this.previewProductBuilder,
    this.initialConfig,
    this.availableVariants,
    this.initialMode = AdminProductCardStudioMode.pick,
    this.title = 'Product Card Studio',
    this.subtitle =
        'Pick a card variant and tune its settings with one persistent mobile preview.',
  });

  final AdminProductCardPreviewBuilder previewProductBuilder;
  final MBCardInstanceConfig? initialConfig;
  final List<MBCardVariant>? availableVariants;
  final AdminProductCardStudioMode initialMode;
  final String title;
  final String subtitle;

  static Future<AdminProductCardStudioResult?> show(
    BuildContext context, {
    required AdminProductCardPreviewBuilder previewProductBuilder,
    MBCardInstanceConfig? initialConfig,
    List<MBCardVariant>? availableVariants,
    AdminProductCardStudioMode initialMode = AdminProductCardStudioMode.pick,
  }) {
    return showDialog<AdminProductCardStudioResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AdminProductCardStudioDialog(
          previewProductBuilder: previewProductBuilder,
          initialConfig: initialConfig,
          availableVariants: availableVariants,
          initialMode: initialMode,
        );
      },
    );
  }

  @override
  State<AdminProductCardStudioDialog> createState() =>
      _AdminProductCardStudioDialogState();
}

class _AdminProductCardStudioDialogState
    extends State<AdminProductCardStudioDialog> {
  late AdminProductCardStudioMode _mode;
  late MBCardVariant _selectedVariant;
  late MBCardInstanceConfig _draftConfig;

  String _familyFilter = 'all';
  String _searchText = '';

  @override
  void initState() {
    super.initState();

    final normalized = widget.initialConfig?.normalized();

    _selectedVariant = normalized?.variant ?? MBCardVariant.compact01;
    _draftConfig = normalized ??
        MBCardInstanceConfig(
          family: _selectedVariant.family,
          variant: _selectedVariant,
          settings: _defaultSettingsFor(_selectedVariant),
        ).normalized();

    _mode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    final previewProduct = widget.previewProductBuilder(
      _draftConfig.normalized(),
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1340,
          maxHeight: 860,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: const Color(0xFFF8FAFC),
            child: Column(
              children: [
                _buildHeader(context),
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 13,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          child: _mode == AdminProductCardStudioMode.pick
                              ? _buildPickPanel(context)
                              : _buildEditPanel(context),
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      SizedBox(
                        width: 430,
                        child: _PersistentPhonePreviewPanel(
                          product: previewProduct,
                          cardConfig: _draftConfig,
                          selectedVariant: _selectedVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final modeLabel =
        _mode == AdminProductCardStudioMode.pick ? 'Pick mode' : 'Edit mode';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(22, 16, 16, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: const Icon(
              Icons.view_carousel_rounded,
              color: Color(0xFFF97316),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          _statusPill(context, modeLabel),
          const SizedBox(width: 10),
          _modeSwitcher(context),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _modeSwitcher(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeButton(
            context,
            label: 'Pick',
            icon: Icons.grid_view_rounded,
            selected: _mode == AdminProductCardStudioMode.pick,
            onTap: () => setState(() => _mode = AdminProductCardStudioMode.pick),
          ),
          _modeButton(
            context,
            label: 'Edit',
            icon: Icons.tune_rounded,
            selected: _mode == AdminProductCardStudioMode.edit,
            onTap: () => setState(() => _mode = AdminProductCardStudioMode.edit),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF97316) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : const Color(0xFF9A3412),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected ? Colors.white : const Color(0xFF9A3412),
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickPanel(BuildContext context) {
    final variants = _filteredVariants();
    final groups = <MBCardFamily, List<MBCardVariant>>{};

    for (final variant in variants) {
      groups.putIfAbsent(variant.family, () => <MBCardVariant>[]).add(variant);
    }

    return Container(
      key: const ValueKey('pick-panel'),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPickToolbar(context),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
              children: [
                for (final entry in groups.entries) ...[
                  _familyHeader(context, entry.key),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tileWidth = constraints.maxWidth >= 880
                          ? (constraints.maxWidth - 24) / 3
                          : constraints.maxWidth >= 580
                              ? (constraints.maxWidth - 12) / 2
                              : constraints.maxWidth;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final variant in entry.value)
                            SizedBox(
                              width: tileWidth,
                              child: _variantTile(context, variant),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                ],
                if (groups.isEmpty)
                  const _StudioEmptyState(
                    title: 'No matching card found',
                    subtitle:
                        'Try another family filter or remove the search text.',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() => _searchText = value.trim().toLowerCase());
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search family or variant...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _selectedCardSummary(context),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _familyFilterChip(context, id: 'all', label: 'All'),
                for (final family in _familiesForFilter())
                  _familyFilterChip(
                    context,
                    id: family.id,
                    label: family.label,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedCardSummary(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 310),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFFF97316),
            size: 17,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              '${_selectedVariant.family.label} · ${_selectedVariant.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF9A3412),
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _familyFilterChip(
    BuildContext context, {
    required String id,
    required String label,
  }) {
    final selected = _familyFilter == id;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _familyFilter = id),
        selectedColor: const Color(0xFFF97316),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
        ),
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : const Color(0xFF374151),
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _familyHeader(BuildContext context, MBCardFamily family) {
    return Row(
      children: [
        Text(
          family.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _familyDescription(family),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
          ),
        ),
      ],
    );
  }

  Widget _variantTile(BuildContext context, MBCardVariant variant) {
    final selected = variant == _selectedVariant;
    final resolved = _safeResolvedForVariant(variant);
    final familyColor = _familyColor(variant.family);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _selectVariant(variant),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: const Color(0xFFF97316).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _variantIconMark(familyColor, resolved.footprint),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variant.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _variantDescription(variant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _tinyChip(context, variant.family.label),
                      _tinyChip(context, resolved.footprint.label),
                      _tinyChip(context, 'preview'),
                    ],
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFFF97316),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _variantIconMark(Color color, MBCardFootprint footprint) {
    final isFull = footprint.isFullWidth;

    return Container(
      width: 50,
      height: 62,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            height: 11,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: 27,
            left: isFull ? 7 : 13,
            right: isFull ? 7 : 13,
            height: isFull ? 14 : 22,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: isFull ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: isFull ? BorderRadius.circular(999) : null,
                border: Border.all(color: color.withValues(alpha: 0.32)),
              ),
            ),
          ),
          Positioned(
            left: 9,
            right: 9,
            bottom: 7,
            height: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditPanel(BuildContext context) {
    return ListView(
      key: const ValueKey('edit-panel'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      children: [
        _sectionTitle(
          context,
          title: 'Edit ${_selectedVariant.id}',
          subtitle:
              'Settings update the persistent mobile preview on the right instantly.',
        ),
        const SizedBox(height: 16),
        _surfaceControls(context),
        _typographyControls(context),
        _mediaControls(context),
        _priceControls(context),
        _actionControls(context),
        _backgroundControls(context),
        _borderControls(context),
      ],
    );
  }

  Widget _surfaceControls(BuildContext context) {
    final surface = _draftConfig.settings.surface ??
        const MBCardSurfaceSettings(
          borderRadius: 18,
          elevationLevel: 2,
          paddingScale: 1,
          showShadow: true,
        );

    return _settingsCard(
      context,
      title: 'Surface',
      icon: Icons.layers_rounded,
      children: [
        _slider(
          context,
          label: 'Corner radius',
          value: surface.borderRadius,
          min: 0,
          max: 32,
          divisions: 32,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              surface: surface.copyWith(borderRadius: value),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Shadow / elevation',
          value: surface.elevationLevel,
          min: 0,
          max: 8,
          divisions: 8,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              surface: surface.copyWith(
                elevationLevel: value,
                showShadow: value > 0,
              ),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Padding scale',
          value: surface.paddingScale,
          min: 0.75,
          max: 1.30,
          divisions: 11,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              surface: surface.copyWith(paddingScale: value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _typographyControls(BuildContext context) {
    final typography = _draftConfig.settings.typography ??
        const MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          titleFontSize: 14.5,
          titleMinFontSize: 11,
          subtitleFontSize: 11.5,
          priceFontSize: 18,
          oldPriceFontSize: 12,
          titleAutoShrink: true,
          italicTitle: true,
          italicSubtitle: true,
        );

    return _settingsCard(
      context,
      title: 'Typography',
      icon: Icons.text_fields_rounded,
      children: [
        _slider(
          context,
          label: 'Title font size',
          value: typography.titleFontSize ?? 14.5,
          min: 11,
          max: 20,
          divisions: 18,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              typography: typography.copyWith(titleFontSize: value),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Title min font size',
          value: typography.titleMinFontSize,
          min: 9,
          max: 15,
          divisions: 12,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              typography: typography.copyWith(titleMinFontSize: value),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Subtitle font size',
          value: typography.subtitleFontSize ?? 11.5,
          min: 9,
          max: 15,
          divisions: 12,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              typography: typography.copyWith(subtitleFontSize: value),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Final price font size',
          value: typography.priceFontSize ?? 18,
          min: 14,
          max: 24,
          divisions: 10,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              typography: typography.copyWith(priceFontSize: value),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Old price font size',
          value: typography.oldPriceFontSize ?? 12,
          min: 9,
          max: 16,
          divisions: 14,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              typography: typography.copyWith(oldPriceFontSize: value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mediaControls(BuildContext context) {
    final media = _draftConfig.settings.media ??
        const MBCardMediaSettings(
          imageShape: 'circle',
          imageFitMode: 'cover',
          imageSizeRatio: 0.72,
          imageTopRatio: 0.305,
          imageRingThickness: 8,
          showImageShadow: true,
        );

    return _settingsCard(
      context,
      title: 'Media',
      icon: Icons.image_rounded,
      children: [
        _slider(
          context,
          label: 'Image size ratio',
          value: media.imageSizeRatio ?? 0.72,
          min: 0.55,
          max: 0.88,
          divisions: 33,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              media: media.copyWith(imageSizeRatio: value),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Image top ratio',
          value: media.imageTopRatio ?? 0.305,
          min: 0.20,
          max: 0.42,
          divisions: 22,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              media: media.copyWith(imageTopRatio: value),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Image ring thickness',
          value: media.imageRingThickness ?? 8,
          min: 0,
          max: 16,
          divisions: 16,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              media: media.copyWith(imageRingThickness: value),
            ),
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Image shadow'),
          value: media.showImageShadow,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              media: media.copyWith(showImageShadow: value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceControls(BuildContext context) {
    final price = _draftConfig.settings.price ??
        const MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: true,
          showSavingsText: true,
          showOriginalPriceWhenSaleActive: true,
          savingsDisplayMode: 'percent',
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        );

    return _settingsCard(
      context,
      title: 'Price / Sale',
      icon: Icons.payments_rounded,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show original price beside final price'),
          value: price.showOriginalPriceWhenSaleActive,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              price: price.copyWith(showOriginalPriceWhenSaleActive: value),
            ),
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show savings chip near image'),
          value: price.showSavingsText,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              price: price.copyWith(showSavingsText: value),
            ),
          ),
        ),
        _dropdown(
          context,
          label: 'Savings display mode',
          value: price.savingsDisplayMode,
          values: const ['percent', 'amount', 'both'],
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              price: price.copyWith(savingsDisplayMode: value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionControls(BuildContext context) {
    final actions = _draftConfig.settings.actions ??
        const MBCardActionSettings(
          showAddToCart: true,
          showBuyNow: true,
          ctaText: 'Buy',
          ctaStylePreset: 'cta_strong_pill',
          ctaColorToken: 'cta_orange',
        );

    return _settingsCard(
      context,
      title: 'Action',
      icon: Icons.touch_app_rounded,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show Buy button'),
          value: actions.showAddToCart || actions.showBuyNow,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              actions: actions.copyWith(
                showAddToCart: value,
                showBuyNow: value,
              ),
            ),
          ),
        ),
        _dropdown(
          context,
          label: 'Button text',
          value: _safeDropdownValue(
            actions.ctaText,
            const ['Buy', 'Add', 'Order', 'View'],
            fallback: 'Buy',
          ),
          values: const ['Buy', 'Add', 'Order', 'View'],
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              actions: actions.copyWith(ctaText: value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _backgroundControls(BuildContext context) {
    final background = _draftConfig.settings.background ??
        const MBCardBackgroundSettings(
          showTopPanel: true,
          panelShape: 'diagonal',
          diagonalStartRatio: 0.58,
          diagonalEndRatio: 0.38,
          panelHeightRatio: 0.46,
        );

    return _settingsCard(
      context,
      title: 'Background / Diagonal',
      icon: Icons.gradient_rounded,
      children: [
        _slider(
          context,
          label: 'Left diagonal depth',
          value: background.diagonalStartRatio ?? 0.58,
          min: 0.42,
          max: 0.72,
          divisions: 30,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              background: background.copyWith(diagonalStartRatio: value),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Right diagonal depth',
          value: background.diagonalEndRatio ?? 0.38,
          min: 0.22,
          max: 0.56,
          divisions: 34,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              background: background.copyWith(diagonalEndRatio: value),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Curve control',
          value: background.panelHeightRatio ?? 0.46,
          min: 0.30,
          max: 0.62,
          divisions: 32,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              background: background.copyWith(panelHeightRatio: value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _borderControls(BuildContext context) {
    final border = _draftConfig.settings.borderEffect ??
        const MBCardBorderEffectSettings(
          showBorder: false,
          effectPreset: 'none',
          effectIntensity: 0,
        );

    return _settingsCard(
      context,
      title: 'Border / Effect',
      icon: Icons.auto_awesome_rounded,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show outer line'),
          value: border.showBorder,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              borderEffect: border.copyWith(showBorder: value),
            ),
          ),
        ),
        _dropdown(
          context,
          label: 'Outer line effect',
          value: _safeDropdownValue(
            border.effectPreset,
            const ['none', 'simple', 'soft_glow', 'wave', 'electric'],
            fallback: 'none',
          ),
          values: const ['none', 'simple', 'soft_glow', 'wave', 'electric'],
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              borderEffect: border.copyWith(effectPreset: value),
            ),
          ),
        ),
        _slider(
          context,
          label: 'Effect intensity',
          value: border.effectIntensity,
          min: 0,
          max: 1,
          divisions: 10,
          onChanged: (value) => _updateSettings(
            _draftConfig.settings.copyWith(
              borderEffect: border.copyWith(effectIntensity: value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFF97316)),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _slider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _dropdown(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    final safeValue = _safeDropdownValue(value, values, fallback: values.first);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        items: [
          for (final item in values)
            DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
        ],
        onChanged: (next) {
          if (next == null) return;
          onChanged(next);
        },
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.30,
              ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Selected: ${_selectedVariant.family.label} · ${_selectedVariant.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _draftConfig = MBCardInstanceConfig(
                  family: _selectedVariant.family,
                  variant: _selectedVariant,
                  settings: _defaultSettingsFor(_selectedVariant),
                ).normalized();
              });
            },
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Reset'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _mode = _mode == AdminProductCardStudioMode.pick
                    ? AdminProductCardStudioMode.edit
                    : AdminProductCardStudioMode.pick;
              });
            },
            icon: Icon(
              _mode == AdminProductCardStudioMode.pick
                  ? Icons.tune_rounded
                  : Icons.grid_view_rounded,
            ),
            label: Text(
              _mode == AdminProductCardStudioMode.pick
                  ? 'Edit selected card'
                  : 'Back to picker',
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _apply,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Use selected card'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tinyChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF374151),
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _statusPill(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF9A3412),
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }

  void _selectVariant(MBCardVariant variant) {
    setState(() {
      _selectedVariant = variant;
      _draftConfig = MBCardInstanceConfig(
        family: variant.family,
        variant: variant,
        presetId: _draftConfig.presetId,
        settings: _defaultSettingsFor(variant),
      ).normalized();
    });
  }

  void _updateSettings(MBCardSettingsOverride settings) {
    setState(() {
      _draftConfig = MBCardInstanceConfig(
        family: _selectedVariant.family,
        variant: _selectedVariant,
        presetId: _draftConfig.presetId,
        settings: settings,
      ).normalized();
    });
  }

  void _apply() {
    final normalized = _draftConfig.normalized();

    Navigator.of(context).pop(
      AdminProductCardStudioResult(
        cardConfig: normalized,
        variant: normalized.variant,
        family: normalized.family,
      ),
    );
  }

  MBResolvedCardConfig _safeResolvedForVariant(MBCardVariant variant) {
    try {
      return MBCardConfigResolver.resolveByVariant(variant);
    } catch (_) {
      return MBCardConfigResolver.resolveByVariant(MBCardVariant.compact01);
    }
  }

  List<MBCardVariant> _availableVariants() {
    return (widget.availableVariants ?? MBCardVariant.values).toList();
  }

  List<MBCardVariant> _filteredVariants() {
    final query = _searchText.trim().toLowerCase();

    return _availableVariants().where((variant) {
      final familyOk =
          _familyFilter == 'all' || variant.family.id == _familyFilter;

      if (!familyOk) return false;
      if (query.isEmpty) return true;

      return variant.id.toLowerCase().contains(query) ||
          variant.family.id.toLowerCase().contains(query) ||
          variant.family.label.toLowerCase().contains(query);
    }).toList();
  }

  List<MBCardFamily> _familiesForFilter() {
    final result = <MBCardFamily>{};

    for (final variant in _availableVariants()) {
      result.add(variant.family);
    }

    return result.toList()
      ..sort((a, b) => a.label.toLowerCase().compareTo(
            b.label.toLowerCase(),
          ));
  }

  MBCardSettingsOverride _defaultSettingsFor(MBCardVariant variant) {
    if (variant.id == 'compact01') {
      return const MBCardSettingsOverride(
        surface: MBCardSurfaceSettings(
          borderRadius: 18,
          elevationLevel: 2,
          paddingScale: 1,
          showShadow: true,
        ),
        layout: MBCardLayoutSettings(
          aspectRatio: 240 / 348,
        ),
        background: MBCardBackgroundSettings(
          showTopPanel: true,
          panelShape: 'diagonal',
          diagonalStartRatio: 0.58,
          diagonalEndRatio: 0.38,
          panelHeightRatio: 0.46,
        ),
        typography: MBCardTypographySettings(
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          titleFontSize: 14.5,
          titleMinFontSize: 11,
          subtitleFontSize: 11.5,
          priceFontSize: 18,
          oldPriceFontSize: 12,
          titleAutoShrink: true,
          subtitleAutoShrink: false,
          titleBold: true,
          priceBold: true,
          italicTitle: true,
          italicSubtitle: true,
        ),
        media: MBCardMediaSettings(
          imageFitMode: 'cover',
          imageShape: 'circle',
          imageFrameStyle: 'circle',
          imageSizeRatio: 0.72,
          imageTopRatio: 0.305,
          imageRingThickness: 8,
          showImageShadow: true,
        ),
        price: MBCardPriceSettings(
          priceMode: MBCardPriceMode.originalAndFinal,
          showDiscountBadge: true,
          showSavingsText: true,
          showOriginalPriceWhenSaleActive: true,
          savingsDisplayMode: 'percent',
          emphasizeFinalPrice: true,
          showCurrencySymbol: true,
        ),
        actions: MBCardActionSettings(
          showAddToCart: true,
          showBuyNow: true,
          ctaText: 'Buy',
          ctaStylePreset: 'cta_strong_pill',
          ctaColorToken: 'cta_orange',
        ),
        borderEffect: MBCardBorderEffectSettings(
          showBorder: false,
          effectPreset: 'none',
          effectIntensity: 0,
        ),
        meta: MBCardMetaSettings(
          showSubtitle: true,
          showShortDescription: true,
          showBrand: false,
          showUnitLabel: false,
        ),
      );
    }

    return MBCardSettingsOverride(
      surface: const MBCardSurfaceSettings(
        borderRadius: 18,
        elevationLevel: 2,
        paddingScale: 1,
      ),
      media: MBCardMediaSettings(
        imageFitMode: 'cover',
        imageShape: variant.isFullWidth ? 'rounded' : 'circle',
        showImageShadow: true,
      ),
      price: const MBCardPriceSettings(
        priceMode: MBCardPriceMode.originalAndFinal,
        showCurrencySymbol: true,
        emphasizeFinalPrice: true,
      ),
      actions: const MBCardActionSettings(
        showAddToCart: true,
        showBuyNow: true,
        ctaText: 'Buy',
      ),
    );
  }

  String _familyDescription(MBCardFamily family) {
    switch (family.id) {
      case 'compact':
        return 'Dense everyday browse cards for mobile two-column grids.';
      case 'price':
        return 'Deal-first cards with strong price and discount focus.';
      case 'horizontal':
        return 'Full-width row cards for fast product scanning.';
      case 'premium':
        return 'Clean branded cards with refined spacing.';
      case 'wide':
        return 'Image-led full-width product showcase cards.';
      case 'featured':
        return 'Hero-like product cards for section anchors.';
      case 'promo':
        return 'Campaign-aware product presentation cards.';
      case 'flash_sale':
        return 'Urgency-driven sale cards.';
      default:
        return 'Product card family.';
    }
  }

  String _variantDescription(MBCardVariant variant) {
    if (variant.id == 'compact01') {
      return 'Diagonal compact card with circular media, save chip, bottom price row, and Buy button.';
    }

    switch (variant.family.id) {
      case 'compact':
        return 'Compact grid product-card variant.';
      case 'price':
        return 'Price and discount focused product card.';
      case 'horizontal':
        return 'Horizontal row-style product card.';
      case 'premium':
        return 'Premium presentation product card.';
      case 'wide':
        return 'Full-width showcase product card.';
      case 'featured':
        return 'Large featured product card.';
      case 'promo':
        return 'Promo campaign product card.';
      case 'flash_sale':
        return 'Urgency-led sale product card.';
      default:
        return 'Product-card variant.';
    }
  }

  Color _familyColor(MBCardFamily family) {
    switch (family.id) {
      case 'compact':
        return const Color(0xFFF97316);
      case 'price':
        return const Color(0xFFDC2626);
      case 'horizontal':
        return const Color(0xFF2563EB);
      case 'premium':
        return const Color(0xFF7C3AED);
      case 'wide':
        return const Color(0xFF0891B2);
      case 'featured':
        return const Color(0xFFCA8A04);
      case 'promo':
        return const Color(0xFFDB2777);
      case 'flash_sale':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF4B5563);
    }
  }

  String _safeDropdownValue(
    String? value,
    List<String> values, {
    required String fallback,
  }) {
    final normalized = value?.trim();
    if (normalized != null && values.contains(normalized)) {
      return normalized;
    }

    return fallback;
  }
}

class _PersistentPhonePreviewPanel extends StatelessWidget {
  const _PersistentPhonePreviewPanel({
    required this.product,
    required this.cardConfig,
    required this.selectedVariant,
  });

  final MBProduct product;
  final MBCardInstanceConfig cardConfig;
  final MBCardVariant selectedVariant;

  @override
  Widget build(BuildContext context) {
    final resolved = MBCardConfigResolver.resolve(cardConfig);
    final footprint = resolved.footprint;
    final cardWidth = _cardWidthFor(footprint);

    return Container(
      color: const Color(0xFFFFF7ED),
      child: Column(
        children: [
          _previewHeader(context, resolved),
          Expanded(
            child: Center(
              child: _PhoneFrame(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 34, 18, 34),
                  child: Center(
                    child: SizedBox(
                      width: cardWidth,
                      child: MBProductCardRenderer(
                        product: product,
                        contextType: footprint.isFullWidth
                            ? MBProductCardRenderContext.featured
                            : MBProductCardRenderContext.grid,
                        onTap: () {},
                        onAddToCartTap: () {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewHeader(BuildContext context, MBResolvedCardConfig resolved) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.smartphone_rounded,
            color: Color(0xFFF97316),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Live mobile preview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111827),
                  ),
            ),
          ),
          _pill(context, selectedVariant.id),
          const SizedBox(width: 8),
          _pill(context, resolved.footprint.label),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF9A3412),
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }

  double _cardWidthFor(MBCardFootprint footprint) {
    if (footprint.isFullWidth) {
      return 310;
    }

    if (footprint.id == 'two_by_two') {
      return 310;
    }

    return 170;
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 690,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(46),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 42,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF3EA),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: child),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 112,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFF111827),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudioEmptyState extends StatelessWidget {
  const _StudioEmptyState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFF97316),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
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
