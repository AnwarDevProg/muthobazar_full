import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_card_config_resolver.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_variant_router.dart';

class AdminProductCardPickerResult {
  const AdminProductCardPickerResult({
    required this.variantId,
  });

  final String variantId;

  MBCardVariant get variant => MBCardVariantHelper.parse(variantId);
}

typedef AdminProductCardEditCallback = Future<void> Function(
    BuildContext context,
    MBCardVariant variant,
    );

class AdminProductCardPickerDialog extends StatefulWidget {
  const AdminProductCardPickerDialog({
    super.key,
    required this.previewProduct,
    this.initialVariantId,
    this.onEditCard,
    this.title = 'Pick a card',
  });

  final MBProduct previewProduct;
  final String? initialVariantId;
  final AdminProductCardEditCallback? onEditCard;
  final String title;

  static Future<AdminProductCardPickerResult?> show(
      BuildContext context, {
        required MBProduct previewProduct,
        String? initialVariantId,
        AdminProductCardEditCallback? onEditCard,
        String title = 'Pick a card',
      }) {
    return showDialog<AdminProductCardPickerResult>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AdminProductCardPickerDialog(
        previewProduct: previewProduct,
        initialVariantId: initialVariantId,
        onEditCard: onEditCard,
        title: title,
      ),
    );
  }

  @override
  State<AdminProductCardPickerDialog> createState() =>
      _AdminProductCardPickerDialogState();
}

class _AdminProductCardPickerDialogState
    extends State<AdminProductCardPickerDialog> {
  static const List<MBCardFamily> _familyOrder = <MBCardFamily>[
    MBCardFamily.compact,
    MBCardFamily.price,
    MBCardFamily.horizontal,
    MBCardFamily.premium,
    MBCardFamily.wide,
    MBCardFamily.featured,
    MBCardFamily.promo,
    MBCardFamily.flashSale,
  ];

  static const double _kGalleryGap = 14.0;
  static const double _kPreviewCanvasWidth = 320.0;
  static const double _kPreviewCanvasPadding = 12.0;
  static const double _kPreviewCanvasGap = 12.0;

  late final TextEditingController _searchController;

  String _searchText = '';
  MBCardFamily? _activeFamily;
  MBCardVariant? _selectedVariant;

  double get _kLargeHalfCardWidth =>
      (_kPreviewCanvasWidth - (_kPreviewCanvasPadding * 2) - _kPreviewCanvasGap) /
          2;

  double get _kLargeFullCardWidth =>
      _kPreviewCanvasWidth - (_kPreviewCanvasPadding * 2);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedVariant =
        MBCardVariantHelper.parse(widget.initialVariantId ?? 'compact01');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MBCardFamily> get _availableFamilies {
    final existingFamilies = MBCardVariant.values
        .map((variant) => variant.family)
        .toSet();

    return _familyOrder
        .where(existingFamilies.contains)
        .toList(growable: false);
  }

  List<MBCardFamily> get _visibleFamilies {
    if (_activeFamily == null) {
      return _availableFamilies;
    }

    return _availableFamilies
        .where((family) => family == _activeFamily)
        .toList(growable: false);
  }

  List<MBCardVariant> _filteredVariantsForFamily(MBCardFamily family) {
    final query = _searchText.trim().toLowerCase();

    final variants = MBCardVariant.values
        .where((variant) => variant.family == family)
        .where((variant) {
      if (query.isEmpty) {
        return true;
      }

      return variant.id.toLowerCase().contains(query) ||
          _familyLabel(family).toLowerCase().contains(query);
    })
        .toList(growable: false)
      ..sort((a, b) => a.id.compareTo(b.id));

    return variants;
  }

  MBProduct _buildPreviewProduct() {
    return widget.previewProduct;
  }

  void _setSelectedVariant(MBCardVariant variant) {
    setState(() {
      _selectedVariant = variant;
    });
  }

  Future<void> _onEditCardPressed(MBCardVariant variant) async {
    _setSelectedVariant(variant);

    if (widget.onEditCard != null) {
      await widget.onEditCard!(context, variant);
    }
  }

  void _onUseSelectedCardPressed(MBCardVariant variant) {
    _setSelectedVariant(variant);
    Navigator.of(context).pop(
      AdminProductCardPickerResult(variantId: variant.id),
    );
  }

  MBCardVariant _peerVariantFor(MBCardVariant currentVariant) {
    final siblings = MBCardVariant.values
        .where((item) => item.family == currentVariant.family)
        .toList(growable: false);

    for (final sibling in siblings) {
      if (sibling != currentVariant) {
        return sibling;
      }
    }

    return currentVariant;
  }

  bool _isHalfWidthFamily(MBCardFamily family) {
    switch (family) {
      case MBCardFamily.compact:
      case MBCardFamily.price:
      case MBCardFamily.premium:
      case MBCardFamily.flashSale:
        return true;
      case MBCardFamily.horizontal:
      case MBCardFamily.wide:
      case MBCardFamily.featured:
      case MBCardFamily.promo:
      case MBCardFamily.combo:
      case MBCardFamily.variant:
      case MBCardFamily.minimal:
      case MBCardFamily.infoRich:
        return false;
    }
  }

  String _footprintLabel(MBCardVariant variant) {
    return variant.isFullWidth ? 'Full width' : 'Half width';
  }

  String _familyLabel(MBCardFamily family) {
    switch (family) {
      case MBCardFamily.compact:
        return 'Compact';
      case MBCardFamily.price:
        return 'Price';
      case MBCardFamily.horizontal:
        return 'Horizontal';
      case MBCardFamily.premium:
        return 'Premium';
      case MBCardFamily.wide:
        return 'Wide';
      case MBCardFamily.featured:
        return 'Featured';
      case MBCardFamily.promo:
        return 'Promo';
      case MBCardFamily.flashSale:
        return 'Flash Sale';
      case MBCardFamily.combo:
        return 'Combo';
      case MBCardFamily.variant:
        return 'Variant';
      case MBCardFamily.minimal:
        return 'Minimal';
      case MBCardFamily.infoRich:
        return 'Info Rich';
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final insets = MediaQuery.viewInsetsOf(context);

    final maxWidth = media.width < 1540 ? media.width - 24 : 1460.0;
    final maxHeight = media.height < 940 ? media.height - 28 : 900.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          child: Column(
            children: <Widget>[
              _buildHeader(context),
              const Divider(height: 1),
              Expanded(
                child: _buildDialogContent(context),
              ),
              const Divider(height: 1),
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Left side shows one larger live preview. Right side shows simpler readable comparison thumbnails.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final leftWidth = totalWidth >= 1360 ? 390.0 : 360.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: leftWidth,
              child: _buildPinnedLeftRail(context),
            ),
            Container(
              width: 1,
              color: const Color(0xFFE5E7EB),
            ),
            Expanded(
              child: _buildGalleryPane(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPinnedLeftRail(BuildContext context) {
    final selected = _selectedVariant;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSearchField(context),
          const SizedBox(height: 18),
          _buildFamilyFilterSection(context),
          const SizedBox(height: 18),
          _buildSelectedCardInfoPanel(context),
          const SizedBox(height: 18),
          Expanded(
            child: _buildPinnedPreviewSection(context, selected),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Filters',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search variant',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchText.trim().isEmpty
                ? null
                : IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchText = '';
                });
              },
              icon: const Icon(Icons.close),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFamilyFilterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Families',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: <Widget>[
            ChoiceChip(
              label: const Text('All'),
              selected: _activeFamily == null,
              onSelected: (_) {
                setState(() {
                  _activeFamily = null;
                });
              },
            ),
            ..._availableFamilies.map(
                  (family) => ChoiceChip(
                label: Text(_familyLabel(family)),
                selected: _activeFamily == family,
                onSelected: (_) {
                  setState(() {
                    _activeFamily = family;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedCardInfoPanel(BuildContext context) {
    final selected = _selectedVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Selected card',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Family',
            selected == null ? 'Not selected' : _familyLabel(selected.family),
          ),
          _buildInfoRow('Variant', selected?.id ?? '—'),
          _buildInfoRow(
            'Footprint',
            selected == null ? '—' : _footprintLabel(selected),
          ),
          _buildInfoRow(
            'Preview',
            _previewProductLabel(widget.previewProduct),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedPreviewSection(
      BuildContext context,
      MBCardVariant? selected,
      ) {
    if (selected == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Text(
          'Select any variant to preview it here.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Live preview',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _buildFootprintChip(_footprintLabel(selected)),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: _buildLargePreviewCanvas(selected),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: () => _onEditCardPressed(selected),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Edit card'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: () => _onUseSelectedCardPressed(selected),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Select card'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'This preview stays visible while the gallery scrolls on the right.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLargePreviewCanvas(MBCardVariant variant) {
    final peer = _peerVariantFor(variant);

    return Container(
      width: _kPreviewCanvasWidth,
      padding: const EdgeInsets.all(_kPreviewCanvasPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: variant.isFullWidth
          ? Column(
        children: <Widget>[
          SizedBox(
            width: _kLargeFullCardWidth,
            child: _buildRenderedPreviewCard(variant),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: _kLargeFullCardWidth,
            child: Opacity(
              opacity: 0.82,
              child: _buildRenderedPreviewCard(peer),
            ),
          ),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: _kLargeHalfCardWidth,
            child: _buildRenderedPreviewCard(variant),
          ),
          const SizedBox(width: _kPreviewCanvasGap),
          SizedBox(
            width: _kLargeHalfCardWidth,
            child: Opacity(
              opacity: 0.82,
              child: _buildRenderedPreviewCard(peer),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryPane(BuildContext context) {
    final families = _visibleFamilies;

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final family in families) ...<Widget>[
              _buildFamilyBlock(context, family: family),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyBlock(
      BuildContext context, {
        required MBCardFamily family,
      }) {
    final variants = _filteredVariantsForFamily(family);
    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isHalfFamily = _isHalfWidthFamily(family);
        final tileWidth = _tileWidthForFamily(
          availableWidth: constraints.maxWidth - 28,
          isHalfFamily: isHalfFamily,
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: <Widget>[
                  Text(
                    _familyLabel(family),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${variants.length} variants',
                      style: const TextStyle(
                        color: Color(0xFFE87817),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: _kGalleryGap,
                runSpacing: _kGalleryGap,
                children: variants
                    .map(
                      (variant) => SizedBox(
                    width: tileWidth,
                    child: _buildVariantTile(
                      context,
                      variant: variant,
                    ),
                  ),
                )
                    .toList(growable: false),
              ),
            ],
          ),
        );
      },
    );
  }

  double _tileWidthForFamily({
    required double availableWidth,
    required bool isHalfFamily,
  }) {
    if (isHalfFamily) {
      if (availableWidth >= 1180) {
        return (availableWidth - (_kGalleryGap * 3)) / 4;
      }
      if (availableWidth >= 860) {
        return (availableWidth - (_kGalleryGap * 2)) / 3;
      }
      return (availableWidth - _kGalleryGap) / 2;
    }

    if (availableWidth >= 980) {
      return (availableWidth - _kGalleryGap) / 2;
    }
    return availableWidth;
  }

  Widget _buildVariantTile(
      BuildContext context, {
        required MBCardVariant variant,
      }) {
    final selected = _selectedVariant == variant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? const Color(0xFFF08A24) : const Color(0xFFE5E7EB),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: selected ? 0.05 : 0.03),
            blurRadius: selected ? 20 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _setSelectedVariant(variant),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    variant.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildFootprintChip(_footprintLabel(variant)),
              ],
            ),
            const SizedBox(height: 10),
            _buildThumbnailPreview(variant),
            if (selected) ...<Widget>[
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _onEditCardPressed(variant),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _onUseSelectedCardPressed(variant),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Select'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFootprintChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildThumbnailPreview(MBCardVariant variant) {
    final resolved = MBCardConfigResolver.resolveByVariant(variant);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: Colors.white,
          child: AbsorbPointer(
            absorbing: true,
            child: MBProductCardVariantRouter.build(
              context: context,
              resolved: resolved,
              product: _buildPreviewProduct(),
              onTap: () {},
              onAddToCartTap: () {},
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRenderedPreviewCard(MBCardVariant variant) {
    final resolved = MBCardConfigResolver.resolveByVariant(variant);

    return AbsorbPointer(
      absorbing: true,
      child: MBProductCardVariantRouter.build(
        context: context,
        resolved: resolved,
        product: _buildPreviewProduct(),
        onTap: () {},
        onAddToCartTap: () {},
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              _selectedVariant == null
                  ? 'No card selected yet'
                  : 'Selected: ${_selectedVariant!.id}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: _selectedVariant == null
                ? null
                : () {
              Navigator.of(context).pop(
                AdminProductCardPickerResult(
                  variantId: _selectedVariant!.id,
                ),
              );
            },
            child: const Text('Use selected card'),
          ),
        ],
      ),
    );
  }

  String _previewProductLabel(MBProduct product) {
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

    return 'Preview product';
  }
}