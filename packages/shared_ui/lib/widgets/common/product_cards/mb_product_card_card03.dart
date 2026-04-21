import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

class MBProductCardCard03 extends StatelessWidget {
  const MBProductCardCard03({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showAddToCart = true,
    this.showFavorite = true,
    this.accentColor = MBColors.primaryOrange,
  });

  final MBProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool showAddToCart;
  final bool showFavorite;
  final Color accentColor;

  static const List<String> _fallbackSizes = <String>['XS', 'S', 'M', 'L', 'XL'];

  @override
  Widget build(BuildContext context) {
    final title = 'CARD03 TEST';
    final subtitle = 'CARD03 TEST';
    final imageUrl = _imageUrlFor(product);
    final currentPrice = _effectivePrice(product);
    final regularPrice = product.price;
    final hasDiscount = _hasDiscount(product);
    final rating = _ratingFor(product);
    final quantity = _quantityFor(product);

    final attributeGroups = _attributeGroupsFor(product);
    final sizeValues = _sizeValues(attributeGroups);
    final selectedSizeIndex = _selectedIndex(product, sizeValues.length);
    final colorGroups = _colorGroups(attributeGroups);
    final colorDots = _colorDotsFor(colorGroups);
    final displayGroups = _displayAttributeGroups(attributeGroups);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: MBColors.shadow.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.elliptical(160, 60),
                              topRight: Radius.elliptical(160, 60),
                              bottomLeft: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Center(
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: MBAppText.headline3(context).copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Center(
                                  child: Text(
                                    subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: MBAppText.caption(context).copyWith(
                                      color: MBColors.textSecondary,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                AspectRatio(
                                  aspectRatio: 1.42,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F5F7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: imageUrl.isEmpty
                                        ? _Card03Placeholder(accentColor: accentColor)
                                        : Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _Card03Placeholder(accentColor: accentColor),
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return _Card03Placeholder(accentColor: accentColor);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '\$${currentPrice.toStringAsFixed(0)}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: MBAppText.headline2(context).copyWith(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF1B2B3A),
                                            ),
                                          ),
                                          if (hasDiscount)
                                            Text(
                                              '\$${regularPrice.toStringAsFixed(0)}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: MBAppText.caption(context).copyWith(
                                                color: MBColors.textMuted,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    _StarsRow(rating: rating),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _QtyStepper(
                                      quantity: quantity,
                                      onMinusTap: null,
                                      onPlusTap: showAddToCart ? onAddToCart : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ..._buildAttributeSections(
                                  context: context,
                                  sizeValues: sizeValues,
                                  selectedSizeIndex: selectedSizeIndex,
                                  colorDots: colorDots,
                                  displayGroups: displayGroups,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showAddToCart)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAddToCart,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                    child: Ink(
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB703),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(18),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'CARD03 TEST',
                          style: MBAppText.body(context).copyWith(
                            color: const Color(0xFF182433),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
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

  List<Widget> _buildAttributeSections({
    required BuildContext context,
    required List<String> sizeValues,
    required int selectedSizeIndex,
    required List<Color> colorDots,
    required List<_AttributeGroup> displayGroups,
  }) {
    final widgets = <Widget>[];

    if (sizeValues.isNotEmpty) {
      widgets.add(
        Text(
          'CARD03 TEST',
          style: MBAppText.caption(context).copyWith(
            fontWeight: FontWeight.w800,
            color: MBColors.textSecondary,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));
      widgets.add(
        Row(
          children: List.generate(sizeValues.length, (index) {
            final isSelected = index == selectedSizeIndex;
            return Padding(
              padding: EdgeInsets.only(right: index == sizeValues.length - 1 ? 0 : 10),
              child: Text(
                sizeValues[index],
                style: MBAppText.caption(context).copyWith(
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected ? const Color(0xFF1B2B3A) : MBColors.textMuted,
                ),
              ),
            );
          }),
        ),
      );
      widgets.add(const SizedBox(height: 10));
    }

    if (colorDots.isNotEmpty) {
      widgets.add(
        Text(
      'CARD03 TEST',
          style: MBAppText.caption(context).copyWith(
            fontWeight: FontWeight.w800,
            color: MBColors.textSecondary,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 7));
      widgets.add(
        Row(
          children: List.generate(colorDots.length, (index) {
            final color = colorDots[index];
            final isPrimary = index == 0;
            return Padding(
              padding: EdgeInsets.only(right: index == colorDots.length - 1 ? 0 : 9),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: Border.all(
                    color: isPrimary ? Colors.white : Colors.transparent,
                    width: 1.6,
                  ),
                  boxShadow: [
                    if (isPrimary)
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 0,
                        spreadRadius: 1.4,
                      ),
                  ],
                ),
                child: isPrimary
                    ? const Center(
                  child: Icon(
                    Icons.check,
                    size: 11,
                    color: Colors.white,
                  ),
                )
                    : null,
              ),
            );
          }),
        ),
      );
      widgets.add(const SizedBox(height: 10));
    }

    for (final group in displayGroups) {
      widgets.add(
        Text(
          group.name,
          style: MBAppText.caption(context).copyWith(
            fontWeight: FontWeight.w800,
            color: MBColors.textSecondary,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));
      widgets.add(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: group.values
              .map(
                (value) => Text(
              value,
              style: MBAppText.caption(context).copyWith(
                fontWeight: FontWeight.w600,
                color: MBColors.textMuted,
              ),
            ),
          )
              .toList(growable: false),
        ),
      );
      widgets.add(const SizedBox(height: 10));
    }

    if (widgets.isNotEmpty) {
      widgets.removeLast();
    }

    return widgets;
  }

  String _titleFor(MBProduct product) {
    final en = product.titleEn.trim();
    if (en.isNotEmpty) return en.toUpperCase();
    final bn = product.titleBn.trim();
    if (bn.isNotEmpty) return bn;
    return 'PRODUCT CARD';
  }

  String _subtitleFor(MBProduct product) {
    final shortEn = product.shortDescriptionEn.trim();
    if (shortEn.isNotEmpty) return shortEn;
    final shortBn = product.shortDescriptionBn.trim();
    if (shortBn.isNotEmpty) return shortBn;
    final desc = product.descriptionEn.trim();
    if (desc.isNotEmpty) return desc;
    return 'Preview layout inspired by the provided fashion-style reference card.';
  }

  String _imageUrlFor(MBProduct product) {
    final thumb = product.thumbnailUrl.trim();
    if (thumb.isNotEmpty) return thumb;
    if (product.imageUrls.isNotEmpty) return product.imageUrls.first.trim();
    return '';
  }

  double _effectivePrice(MBProduct product) {
    final sale = product.salePrice;
    if (sale != null && sale > 0 && sale < product.price) {
      return sale;
    }
    return product.price;
  }

  bool _hasDiscount(MBProduct product) {
    final sale = product.salePrice;
    return sale != null && sale > 0 && sale < product.price;
  }

  int _ratingFor(MBProduct product) {
    return 3 + (product.id.hashCode.abs() % 3);
  }

  int _quantityFor(MBProduct product) {
    return 1 + (product.id.hashCode.abs() % 3);
  }

  int _selectedIndex(MBProduct product, int length) {
    if (length <= 0) return 0;
    return product.id.hashCode.abs() % length;
  }

  List<String> _sizeValues(List<_AttributeGroup> groups) {
    for (final group in groups) {
      if (group.name == 'SIZE' && group.values.isNotEmpty) {
        return group.values;
      }
    }
    return _fallbackSizes;
  }

  List<_AttributeGroup> _colorGroups(List<_AttributeGroup> groups) {
    return groups.where((group) => group.name == 'COLORS').toList(growable: false);
  }

  List<_AttributeGroup> _displayAttributeGroups(List<_AttributeGroup> groups) {
    return groups
        .where((group) => group.name != 'SIZE' && group.name != 'COLORS')
        .toList(growable: false);
  }

  List<Color> _colorDotsFor(List<_AttributeGroup> colorGroups) {
    final count = colorGroups.isNotEmpty ? colorGroups.first.values.length : 3;
    final palette = <Color>[
      accentColor,
      const Color(0xFFB8C4E8),
      const Color(0xFF1C2A39),
      const Color(0xFFF7B500),
      const Color(0xFFE3E7EF),
    ];

    return List<Color>.generate(count.clamp(1, 5), (index) {
      if (index == 0) return accentColor;
      return palette[index % palette.length];
    });
  }

  List<_AttributeGroup> _attributeGroupsFor(MBProduct product) {
    if (product.attributes.isEmpty) return const <_AttributeGroup>[];

    final sortedAttributes = [...product.attributes]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final groups = <_AttributeGroup>[];

    for (final attribute in sortedAttributes) {
      if (!attribute.isVisible) continue;
      if (!attribute.hasValues) continue;

      final rawName = attribute.nameEn.trim().isNotEmpty
          ? attribute.nameEn.trim()
          : attribute.nameBn.trim();

      if (rawName.isEmpty) continue;

      final sortedValues = [...attribute.values]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      final seen = <String>{};
      final values = <String>[];

      for (final item in sortedValues) {
        if (!item.isEnabled) continue;

        final value = item.value.trim();
        if (value.isEmpty) continue;

        final key = value.toLowerCase();
        if (seen.add(key)) {
          values.add(value);
        }
      }

      if (values.isEmpty) continue;

      final normalizedName = attribute.isColorType ? 'COLORS' : rawName.toUpperCase();

      groups.add(
        _AttributeGroup(
          name: normalizedName,
          values: values,
        ),
      );
    }

    return groups;
  }
}

class _Card03Placeholder extends StatelessWidget {
  const _Card03Placeholder({
    required this.accentColor,
  });

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.10),
            accentColor.withValues(alpha: 0.26),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.checkroom_outlined,
          size: 42,
          color: accentColor.withValues(alpha: 0.90),
        ),
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({
    required this.rating,
  });

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final active = index < rating;
        return Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : 1),
          child: Icon(
            Icons.star_rounded,
            size: 16,
            color: active ? const Color(0xFFFFB703) : const Color(0xFFB8C2D1),
          ),
        );
      }),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    required this.onMinusTap,
    required this.onPlusTap,
  });

  final int quantity;
  final VoidCallback? onMinusTap;
  final VoidCallback? onPlusTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QtyButton(
          icon: Icons.remove_rounded,
          onTap: onMinusTap,
        ),
        const SizedBox(width: 5),
        Text(
          '$quantity',
          style: MBAppText.caption(context).copyWith(
            color: MBColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 5),
        _QtyButton(
          icon: Icons.add_rounded,
          onTap: onPlusTap,
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Ink(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: const Color(0xFFD7DDEA),
            ),
          ),
          child: Icon(
            icon,
            size: 12,
            color: enabled ? const Color(0xFF9AA6B5) : const Color(0xFFC8D0DC),
          ),
        ),
      ),
    );
  }
}

class _AttributeGroup {
  final String name;
  final List<String> values;

  const _AttributeGroup({
    required this.name,
    required this.values,
  });
}
