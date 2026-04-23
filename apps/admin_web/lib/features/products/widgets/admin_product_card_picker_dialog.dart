import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_card_config_resolver.dart';
import 'package:shared_ui/widgets/common/product_cards/system/mb_product_card_variant_router.dart';

class AdminProductCardPickerResult {
  const AdminProductCardPickerResult({
    required this.variantId,
  });

  final String variantId;

  MBCardVariant get variant => MBCardVariantHelper.parse(
    variantId,
    fallback: MBCardVariant.compact01,
  );
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

  late final TextEditingController _searchController;
  String _searchText = '';
  MBCardFamily? _activeFamily;
  MBCardVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedVariant = MBCardVariantHelper.parse(
      widget.initialVariantId,
      fallback: MBCardVariant.compact01,
    );
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

  List<MBCardVariant> _variantsForFamily(MBCardFamily family) {
    final query = _searchText.trim().toLowerCase();

    final variants = MBCardVariant.values
        .where((variant) => variant.family == family)
        .where((variant) {
      if (query.isEmpty) {
        return true;
      }

      return variant.id.toLowerCase().contains(query) ||
          family.label.toLowerCase().contains(query);
    })
        .toList(growable: false)
      ..sort((a, b) => a.id.compareTo(b.id));

    return variants;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final insets = MediaQuery.viewInsetsOf(context);

    final maxWidth = media.width < 1500 ? media.width - 24 : 1420.0;
    final maxHeight = media.height < 940 ? media.height - 32 : 900.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                child: Row(
                  children: <Widget>[
                    _buildLeftPanel(context),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _buildGallery(context),
                    ),
                  ],
                ),
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
                  'Compare each family inside one family block. Half-width variants use a real 2-column phone-row preview. Full-width variants use a real single-row phone preview.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
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

  Widget _buildLeftPanel(BuildContext context) {
    final selectedVariant = _selectedVariant;
    final selectedFamily = selectedVariant?.family;

    return SizedBox(
      width: 320,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
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
            const SizedBox(height: 18),
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
                    label: Text(family.label),
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
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Selected card',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Family',
                    value: selectedFamily?.label ?? 'Not selected',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Variant',
                    value: selectedVariant?.id ?? 'Not selected',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Footprint',
                    value: selectedVariant == null
                        ? 'Unknown'
                        : (selectedVariant.isFullWidth
                        ? 'Full width'
                        : 'Half width'),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Preview',
                    value: _previewProductLabel(widget.previewProduct),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Each preview is rendered on a virtual phone-width surface, so the card spacing and width behave much closer to the real customer app.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(BuildContext context) {
    final families = _visibleFamilies;
    final sections = <Widget>[];

    for (final family in families) {
      final variants = _variantsForFamily(family);
      if (variants.isEmpty) {
        continue;
      }

      sections.add(
        _FamilySection(
          family: family,
          variants: variants,
          previewProduct: widget.previewProduct,
          selectedVariant: _selectedVariant,
          onCardTap: (variant) {
            setState(() {
              _selectedVariant = variant;
            });
          },
          onSelectTap: (variant) {
            Navigator.of(context).pop(
              AdminProductCardPickerResult(variantId: variant.id),
            );
          },
          onEditTap: (variant) async {
            if (widget.onEditCard != null) {
              await widget.onEditCard!(context, variant);
              return;
            }

            if (!mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Edit card for ${variant.id} will be wired next.'),
              ),
            );
          },
        ),
      );
      sections.add(const SizedBox(height: 18));
    }

    if (sections.isNotEmpty) {
      sections.removeLast();
    }

    if (sections.isEmpty) {
      return Center(
        child: Text(
          'No variants found for the current filter.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
      );
    }

    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections,
        ),
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

class _FamilySection extends StatelessWidget {
  const _FamilySection({
    required this.family,
    required this.variants,
    required this.previewProduct,
    required this.selectedVariant,
    required this.onCardTap,
    required this.onSelectTap,
    required this.onEditTap,
  });

  final MBCardFamily family;
  final List<MBCardVariant> variants;
  final MBProduct previewProduct;
  final MBCardVariant? selectedVariant;
  final ValueChanged<MBCardVariant> onCardTap;
  final ValueChanged<MBCardVariant> onSelectTap;
  final ValueChanged<MBCardVariant> onEditTap;

  bool get _isFullWidthFamily {
    if (variants.isEmpty) {
      return false;
    }
    return variants.first.isFullWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final maxWidth = constraints.maxWidth;
        final columns = _resolveColumns(maxWidth);
        final tileWidth =
            (maxWidth - (spacing * math.max(0, columns - 1))) / columns;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    family.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E8),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${variants.length} variants',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE67E22),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: variants.map((variant) {
                  return SizedBox(
                    width: tileWidth,
                    child: _VariantPreviewTile(
                      variant: variant,
                      product: previewProduct,
                      isSelected: selectedVariant == variant,
                      onTap: () => onCardTap(variant),
                      onSelectTap: () => onSelectTap(variant),
                      onEditTap: () => onEditTap(variant),
                    ),
                  );
                }).toList(growable: false),
              ),
            ],
          ),
        );
      },
    );
  }

  int _resolveColumns(double maxWidth) {
    if (_isFullWidthFamily) {
      if (maxWidth >= 1200) return 3;
      if (maxWidth >= 760) return 2;
      return 1;
    }

    if (maxWidth >= 1280) return 6;
    if (maxWidth >= 1040) return 5;
    if (maxWidth >= 820) return 4;
    if (maxWidth >= 620) return 3;
    return 2;
  }
}

class _VariantPreviewTile extends StatelessWidget {
  const _VariantPreviewTile({
    required this.variant,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.onSelectTap,
    required this.onEditTap,
  });

  static const double _kPhoneWidth = 390;
  static const double _kPhonePadding = 14;
  static const double _kGridSpacing = 12;
  static const double _kPhoneRadius = 22;

  final MBCardVariant variant;
  final MBProduct product;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSelectTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final isHalfWidth = !variant.isFullWidth;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF8A00)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isSelected
                  ? const Color(0x22FF8A00)
                  : const Color(0x10000000),
              blurRadius: isSelected ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _VariantTileHeader(
              variant: variant,
              isSelected: isSelected,
            ),
            const SizedBox(height: 10),
            _buildPhonePreview(context),
            if (isSelected) ...<Widget>[
              const SizedBox(height: 10),
              _SelectedActionRow(
                compactLabels: isHalfWidth,
                onEditTap: onEditTap,
                onSelectTap: onSelectTap,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhonePreview(BuildContext context) {
    final resolved = MBCardConfigResolver.resolveByVariant(variant);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final previewScale =
        math.min(1.0, availableWidth / _kPhoneWidth.clamp(1, double.infinity));
        final phoneContentWidth = _kPhoneWidth - (_kPhonePadding * 2);
        final halfItemWidth =
            (phoneContentWidth - _kGridSpacing) / 2;

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: _kPhoneWidth,
              child: Container(
                padding: const EdgeInsets.all(_kPhonePadding),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(_kPhoneRadius),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: resolved.footprint.isFullWidth
                    ? SizedBox(
                  width: phoneContentWidth,
                  child: _buildPreviewCard(
                    context: context,
                    resolved: resolved,
                  ),
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: halfItemWidth,
                      child: _buildPreviewCard(
                        context: context,
                        resolved: resolved,
                      ),
                    ),
                    const SizedBox(width: _kGridSpacing),
                    SizedBox(
                      width: halfItemWidth,
                      child: _GhostGridSlot(
                        scale: previewScale,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewCard({
    required BuildContext context,
    required MBResolvedCardConfig resolved,
  }) {
    return AbsorbPointer(
      absorbing: true,
      child: MBProductCardVariantRouter.build(
        context: context,
        resolved: resolved,
        product: product,
        onTap: () {},
        onAddToCartTap: () {},
      ),
    );
  }
}

class _GhostGridSlot extends StatelessWidget {
  const _GhostGridSlot({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    final clampedScale = scale.clamp(0.55, 1.0);
    final height = 250 * clampedScale;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDCE1E8),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.grid_view_rounded,
          size: 26,
          color: Colors.grey.withValues(alpha: 0.42),
        ),
      ),
    );
  }
}

class _SelectedActionRow extends StatelessWidget {
  const _SelectedActionRow({
    required this.compactLabels,
    required this.onEditTap,
    required this.onSelectTap,
  });

  final bool compactLabels;
  final VoidCallback onEditTap;
  final VoidCallback onSelectTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            onPressed: onEditTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(compactLabels ? 'Edit' : 'Edit card'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: onSelectTap,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(38),
              backgroundColor: const Color(0xFFFF8A00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(compactLabels ? 'Select' : 'Select card'),
          ),
        ),
      ],
    );
  }
}

class _VariantTileHeader extends StatelessWidget {
  const _VariantTileHeader({
    required this.variant,
    required this.isSelected,
  });

  final MBCardVariant variant;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final footprint = variant.isFullWidth ? 'Full width' : 'Half width';

    return Row(
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFF4E8)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            footprint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? const Color(0xFFE67E22)
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
          width: 82,
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