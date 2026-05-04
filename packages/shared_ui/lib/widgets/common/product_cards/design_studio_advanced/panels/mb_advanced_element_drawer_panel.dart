// MuthoBazar Advanced Product Card Design Studio
// Patch 12.1 left element drawer.
// Patch 12.4 adds preview-only contrast-safe text colors.
//
// Purpose:
// - Uses the data-driven V12 element catalog.
// - Shows current product-data previews in drawer items.
// - Keeps drag-only insertion: clicking a drawer item does not add anything.
// - Keeps the existing MBAdvancedElementVariant drag/drop contract.

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/mb_advanced_binding_registry.dart';
import '../models/mb_advanced_binding_resolver.dart';
import '../models/mb_advanced_card_design_document.dart';
import '../models/mb_advanced_element_catalog_v12.dart';
import '../models/mb_advanced_element_variant.dart';

class MBAdvancedElementDrawerPanel extends StatelessWidget {
  const MBAdvancedElementDrawerPanel({
    super.key,
    required this.productTitle,
    required this.productSubtitle,
    this.previewProduct,
    this.previewBrand,
    this.previewCategory,
    this.previewVariation,
    this.previewPurchaseOption,
    this.previewProductAttribute,
    this.previewAttributeValue,
    this.previewAttributePreset,
    required this.onAddVariant,
    required this.onApplyCardVariant,
  });

  final String productTitle;
  final String productSubtitle;
  final dynamic previewProduct;
  final dynamic previewBrand;
  final dynamic previewCategory;
  final dynamic previewVariation;
  final dynamic previewPurchaseOption;
  final dynamic previewProductAttribute;
  final dynamic previewAttributeValue;
  final dynamic previewAttributePreset;
  final ValueChanged<MBAdvancedElementVariant> onAddVariant;
  final ValueChanged<MBAdvancedElementVariant> onApplyCardVariant;

  @override
  Widget build(BuildContext context) {
    final previewContext = MBAdvancedPreviewContext(
      product: previewProduct ??
          <String, dynamic>{
            'titleEn': productTitle,
            'shortDescriptionEn': productSubtitle,
            'price': 120,
            'salePrice': 99,
            'thumbnailUrl': '',
          },
      brand: previewBrand,
      category: previewCategory,
      selectedVariation: previewVariation,
      selectedPurchaseOption: previewPurchaseOption,
      selectedProductAttribute: previewProductAttribute,
      selectedAttributeValue: previewAttributeValue,
      selectedAttributePreset: previewAttributePreset,
      fallbackTitle: productTitle.trim().isEmpty ? 'Product title' : productTitle,
      fallbackSubtitle: productSubtitle.trim().isEmpty
          ? 'Fresh product detail'
          : productSubtitle,
    );

    final groups = _buildVisibleGroups(previewContext);

    return Container(
      width: 322,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE6E8EF)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _DrawerHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final group = groups[index];
                return _ElementGroupTile(
                  group: group,
                  previewContext: previewContext,
                  initiallyExpanded: index < 3 ||
                      group.id == 'media' ||
                      group.id == 'price',
                  onTapVariant: (_) {
                    // Patch 12.1 keeps drawer click as safe/no-op.
                    // Drag to canvas is the only way to insert a node.
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


List<MBAdvancedElementGroup> _buildVisibleGroups(
  MBAdvancedPreviewContext previewContext,
) {
  final baseGroups = MBAdvancedElementCatalogV12.groups();
  final visibleGroups = <MBAdvancedElementGroup>[];
  final showVariationGroups = _isVariableProductPreview(previewContext);

  for (final group in baseGroups) {
    if (_hiddenDrawerGroupIds.contains(group.id)) {
      continue;
    }

    // Simple/bundle/service-like products must not show variation-only drawer
    // groups. These groups are useful only when the current product type is
    // variable and the product has variation-aware data.
    if (group.id == 'variation' && !showVariationGroups) {
      continue;
    }

    final filteredVariants = group.id == 'variation'
        ? group.variants
            .where((variant) =>
                variant.binding != MBAdvancedBindingKey.variationAttributeSummary)
            .toList(growable: false)
        : group.variants;

    visibleGroups.add(
      MBAdvancedElementGroup(
        id: group.id,
        title: group.title,
        subtitle: group.subtitle,
        variants: filteredVariants,
      ),
    );

    if (group.id == 'variation' && showVariationGroups) {
      visibleGroups.add(_buildVariationAttributeGroup(previewContext));
    }
  }

  return visibleGroups;
}

bool _isVariableProductPreview(MBAdvancedPreviewContext previewContext) {
  if (previewContext.selectedVariation != null) {
    return true;
  }

  final product = previewContext.product;
  final typeText = _readProductTypeText(product).toLowerCase();

  if (typeText.contains('variable')) {
    return true;
  }

  if (_hasNonEmptyCollection(product, const <String>[
    'variations',
    'variationItems',
    'productVariations',
  ])) {
    return true;
  }

  return false;
}

String _readProductTypeText(dynamic product) {
  if (product == null) return '';

  try {
    if (product is Map) {
      for (final key in const <String>[
        'productType',
        'type',
        'kind',
        'productKind',
      ]) {
        final value = product[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }
  } catch (_) {}

  try {
    final value = product.productType?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  } catch (_) {}

  try {
    final value = product.type?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  } catch (_) {}

  try {
    final value = product.kind?.toString().trim() ?? '';
    if (value.isNotEmpty) return value;
  } catch (_) {}

  return '';
}

bool _hasNonEmptyCollection(dynamic source, List<String> fields) {
  if (source == null) return false;

  for (final field in fields) {
    dynamic value;

    try {
      if (source is Map && source.containsKey(field)) {
        value = source[field];
      }
    } catch (_) {}

    if (value == null) {
      try {
        switch (field) {
          case 'variations':
            value = source.variations;
            break;
          case 'variationItems':
            value = source.variationItems;
            break;
          case 'productVariations':
            value = source.productVariations;
            break;
        }
      } catch (_) {}
    }

    if (value is Iterable && value.isNotEmpty) {
      return true;
    }

    if (value is Map && value.isNotEmpty) {
      return true;
    }
  }

  return false;
}
const Set<String> _hiddenDrawerGroupIds = <String>{
  'product_attribute',
  'attribute_value',
  'attribute_preset',
};

MBAdvancedElementGroup _buildVariationAttributeGroup(
  MBAdvancedPreviewContext previewContext,
) {
  final attributes = _extractVariationAttributes(previewContext.selectedVariation);
  final variants = <MBAdvancedElementVariant>[];
  final entries = attributes.entries.toList(growable: false);

  if (entries.isEmpty) {
    variants.addAll(
      <MBAdvancedElementVariant>[
        _variationAttributeVariant(
          id: 'variation_attribute_text_fallback',
          title: 'Variation attribute text',
          description: 'variation.attribute.value',
          binding: 'variation.attribute.attribute',
          x: 0.50,
          y: 0.76,
          width: 148,
          height: 24,
          style: _textStyle(
            textHex: '#FFF4E8',
            fontSize: 10.5,
            fontWeight: 'w800',
            textAlign: 'center',
          ),
        ),
        _variationAttributeVariant(
          id: 'variation_attribute_chip_fallback',
          title: 'Variation attribute chip',
          description: 'variation.attribute.value',
          binding: 'variation.attribute.attribute',
          x: 0.50,
          y: 0.76,
          width: 138,
          height: 26,
          style: _chipStyle(
            backgroundHex: '#FFFFFF',
            textHex: '#FF6500',
            fontSize: 10.0,
            fontWeight: 'w900',
          ),
        ),
      ],
    );
  } else {
    for (final entry in entries) {
      final safeId = _safeId(entry.key);
      final binding = 'variation.attribute.${entry.key}';
      variants.add(
        _variationAttributeVariant(
          id: 'variation_attribute_${safeId}_text',
          title: '${entry.key} text',
          description: entry.value,
          binding: binding,
          x: 0.50,
          y: 0.76,
          width: 148,
          height: 24,
          style: _textStyle(
            textHex: '#FFF4E8',
            fontSize: 10.5,
            fontWeight: 'w800',
            textAlign: 'center',
          ),
        ),
      );
      variants.add(
        _variationAttributeVariant(
          id: 'variation_attribute_${safeId}_chip',
          title: '${entry.key} chip',
          description: entry.value,
          binding: binding,
          x: 0.50,
          y: 0.76,
          width: 132,
          height: 26,
          style: _chipStyle(
            backgroundHex: '#FFFFFF',
            textHex: '#FF6500',
            fontSize: 10.0,
            fontWeight: 'w900',
          ),
        ),
      );
    }
  }

  return MBAdvancedElementGroup(
    id: 'variation_attribute',
    title: 'Variation Attribute',
    subtitle: 'Available variation attribute values',
    variants: variants,
  );
}

Map<String, String> _extractVariationAttributes(dynamic variation) {
  final result = <String, String>{};
  if (variation == null) return result;

  try {
    final raw = variation is Map ? variation['attributes'] : variation.attributes;
    if (raw is Map && raw.isNotEmpty) {
      for (final entry in raw.entries) {
        final key = entry.key?.toString().trim() ?? '';
        final value = entry.value?.toString().trim() ?? '';
        if (key.isEmpty || value.isEmpty) continue;
        result[key] = value;
      }
      if (result.isNotEmpty) return result;
    }

    if (raw is Iterable && raw.isNotEmpty) {
      for (final item in raw) {
        final name = _readPreviewField(item, const <String>[
          'nameEn',
          'nameBn',
          'attributeName',
          'attributeKey',
          'key',
          'label',
          'title',
        ]);
        final value = _readPreviewField(item, const <String>[
          'valueEn',
          'valueBn',
          'value',
          'labelEn',
          'labelBn',
          'label',
          'text',
          'displayName',
          'name',
        ]);
        if (name.isEmpty || value.isEmpty) continue;
        result[name] = value;
      }
      if (result.isNotEmpty) return result;
    }
  } catch (_) {}

  final summary = MBAdvancedBindingResolver.resolveText(
    MBAdvancedPreviewContext(product: const <String, dynamic>{}, selectedVariation: variation),
    MBAdvancedBindingKey.variationAttributeSummary,
    fallback: '',
  );
  if (summary.isEmpty) return result;

  for (final part in summary.split(',')) {
    final piece = part.trim();
    if (piece.isEmpty) continue;
    final separatorIndex = piece.indexOf(':');
    if (separatorIndex > 0) {
      final key = piece.substring(0, separatorIndex).trim();
      final value = piece.substring(separatorIndex + 1).trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        result[key] = value;
      }
    }
  }

  return result;
}

String _readPreviewField(dynamic source, List<String> fields) {
  for (final field in fields) {
    final value = _readPreviewSingleField(source, field);
    if (value.isNotEmpty) return value;
  }
  return '';
}

String _readPreviewSingleField(dynamic source, String field) {
  if (source == null) return '';

  try {
    if (source is Map && source.containsKey(field)) {
      final value = source[field]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
  } catch (_) {}

  try {
    switch (field) {
      case 'nameEn':
        return source.nameEn?.toString().trim() ?? '';
      case 'nameBn':
        return source.nameBn?.toString().trim() ?? '';
      case 'attributeName':
        return source.attributeName?.toString().trim() ?? '';
      case 'attributeKey':
        return source.attributeKey?.toString().trim() ?? '';
      case 'key':
        return source.key?.toString().trim() ?? '';
      case 'label':
        return source.label?.toString().trim() ?? '';
      case 'title':
        return source.title?.toString().trim() ?? '';
      case 'valueEn':
        return source.valueEn?.toString().trim() ?? '';
      case 'valueBn':
        return source.valueBn?.toString().trim() ?? '';
      case 'value':
        return source.value?.toString().trim() ?? '';
      case 'labelEn':
        return source.labelEn?.toString().trim() ?? '';
      case 'labelBn':
        return source.labelBn?.toString().trim() ?? '';
      case 'text':
        return source.text?.toString().trim() ?? '';
      case 'displayName':
        return source.displayName?.toString().trim() ?? '';
      case 'name':
        return source.name?.toString().trim() ?? '';
    }
  } catch (_) {}

  return '';
}

MBAdvancedElementVariant _variationAttributeVariant({
  required String id,
  required String title,
  required String description,
  required String binding,
  required double x,
  required double y,
  required double width,
  required double height,
  required Map<String, dynamic> style,
}) {
  return MBAdvancedElementVariant(
    id: id,
    groupId: 'variation_attribute',
    elementType: 'variation',
    title: title,
    description: description,
    binding: binding,
    defaultPosition: MBAdvancedDesignNodePosition(x: x, y: y, z: 38),
    defaultSize: MBAdvancedDesignNodeSize(width: width, height: height),
    defaultStyle: style,
  );
}

Map<String, dynamic> _textStyle({
  required String textHex,
  required double fontSize,
  required String fontWeight,
  required String textAlign,
}) {
  return <String, dynamic>{
    'textHex': textHex,
    'fontSize': fontSize,
    'fontWeight': fontWeight,
    'textAlign': textAlign,
    'maxLines': 2,
  };
}

Map<String, dynamic> _chipStyle({
  required String backgroundHex,
  required String textHex,
  required double fontSize,
  required String fontWeight,
}) {
  return <String, dynamic>{
    'backgroundHex': backgroundHex,
    'textHex': textHex,
    'fontSize': fontSize,
    'fontWeight': fontWeight,
    'paddingHorizontal': 10.0,
    'paddingVertical': 4.0,
    'borderRadius': 999.0,
  };
}

String _safeId(String value) {
  final cleaned = value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return cleaned.isEmpty ? 'attribute' : cleaned;
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFFFE3D0)),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.widgets_rounded,
                color: Color(0xFFFF6500),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Element Drawer',
                  style: TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Patch 12.7.3: variation-aware drawer previews. Drag items to the canvas.',
            style: TextStyle(
              color: Color(0xFF747B8A),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementGroupTile extends StatelessWidget {
  const _ElementGroupTile({
    required this.group,
    required this.previewContext,
    required this.initiallyExpanded,
    required this.onTapVariant,
  });

  final MBAdvancedElementGroup group;
  final MBAdvancedPreviewContext previewContext;
  final bool initiallyExpanded;
  final ValueChanged<MBAdvancedElementVariant> onTapVariant;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE9ECF3)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
            initiallyExpanded: initiallyExpanded,
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    group.title,
                    style: const TextStyle(
                      color: Color(0xFF172033),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${group.variants.length}',
                    style: const TextStyle(
                      color: Color(0xFFFF6500),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              group.subtitle,
              style: const TextStyle(
                color: Color(0xFF747B8A),
                fontSize: 10.5,
                height: 1.25,
              ),
            ),
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE6E8EF)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final variant in group.variants)
                      _VariantBox(
                        variant: variant,
                        previewContext: previewContext,
                        onTap: () => onTapVariant(variant),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VariantBox extends StatelessWidget {
  const _VariantBox({
    required this.variant,
    required this.previewContext,
    required this.onTap,
  });

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final box = SizedBox(
      width: 134,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: null,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E6EF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 48,
                  child: _VariantPreview(
                    variant: variant,
                    previewContext: previewContext,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  variant.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  variant.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF747B8A),
                    fontSize: 9.5,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Draggable<MBAdvancedElementVariant>(
      data: variant,
      feedback: _VariantDragFeedback(
        variant: variant,
        previewContext: previewContext,
      ),
      childWhenDragging: Opacity(opacity: 0.45, child: box),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: box,
      ),
    );
  }
}

class _VariantDragFeedback extends StatelessWidget {
  const _VariantDragFeedback({
    required this.variant,
    required this.previewContext,
  });

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFB074), width: 1.4),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 42,
              child: _VariantPreview(
                variant: variant,
                previewContext: previewContext,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              variant.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantPreview extends StatelessWidget {
  const _VariantPreview({
    required this.variant,
    required this.previewContext,
  });

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;

  @override
  Widget build(BuildContext context) {
    switch (variant.elementType) {
      case 'card':
        return _PreviewCardShape(variant: variant);
      case 'media':
        return _PreviewMedia(variant: variant, previewContext: previewContext);
      case 'price':
      case 'mrp':
      case 'discount':
      case 'badge':
      case 'promoBadge':
      case 'flashBadge':
      case 'timer':
      case 'rating':
      case 'stock':
      case 'delivery':
      case 'unit':
      case 'quantity':
      case 'feature':
      case 'savingText':
      case 'ribbon':
      case 'cta':
      case 'secondaryCta':
      case 'wishlist':
      case 'compare':
      case 'share':
      case 'animation':
        return _PreviewPillOrText(
          variant: variant,
          previewContext: previewContext,
        );
      case 'divider':
      case 'shape':
      case 'panel':
      case 'imageOverlay':
      case 'progress':
      case 'dots':
      case 'border':
      case 'effect':
      case 'shadow':
      case 'spacing':
        return _PreviewVisualShape(variant: variant);
      case 'title':
      case 'subtitle':
      case 'description':
      case 'brand':
      case 'category':
      default:
        return _PreviewText(
          variant: variant,
          previewContext: previewContext,
        );
    }
  }
}

class _PreviewCardShape extends StatelessWidget {
  const _PreviewCardShape({required this.variant});

  final MBAdvancedElementVariant variant;

  @override
  Widget build(BuildContext context) {
    final background = _hexColor(
      variant.cardPalettePatch['backgroundHex'],
      const Color(0xFFFF6500),
    );
    final background2 = _hexColor(
      variant.cardPalettePatch['backgroundHex2'],
      const Color(0xFFFF9A3D),
    );
    final width = _asDouble(variant.cardLayoutPatch['cardWidth'], 185) >= 300 ? 108.0 : 56.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: <Color>[background, background2]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E8EF)),
        ),
      ),
    );
  }
}

class _PreviewText extends StatelessWidget {
  const _PreviewText({required this.variant, required this.previewContext});

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;

  @override
  Widget build(BuildContext context) {
    final text = MBAdvancedBindingResolver.resolveText(
      previewContext,
      variant.binding,
      fallback: variant.title,
    );
    final background = _hexColor(variant.defaultStyle['backgroundHex'], Colors.transparent);
    final isChip = background != Colors.transparent ||
        variant.id.contains('chip') ||
        variant.id.contains('badge');
    final textColor = _drawerPreviewReadableTextColor(
      requested: variant.defaultStyle['textColorHex'],
      previewSurface: background == Colors.transparent ? Colors.white : background,
      hasElementBackground: isChip,
      fallback: background == Colors.transparent
          ? const Color(0xFF172033)
          : const Color(0xFFFF6500),
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 118),
        padding: isChip
            ? const EdgeInsets.symmetric(horizontal: 9, vertical: 6)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(
            _asDouble(variant.defaultStyle['borderRadius'], 999),
          ),
        ),
        child: Text(
          text,
          maxLines: isChip ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: isChip ? 10 : 11.5,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _PreviewPillOrText extends StatelessWidget {
  const _PreviewPillOrText({required this.variant, required this.previewContext});

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;

  @override
  Widget build(BuildContext context) {
    final text = MBAdvancedBindingResolver.resolveText(
      previewContext,
      variant.binding,
      fallback: variant.title,
    );
    final background = _hexColor(variant.defaultStyle['backgroundHex'], Colors.transparent);
    final textColor = _drawerPreviewReadableTextColor(
      requested: variant.defaultStyle['textColorHex'],
      previewSurface: background == Colors.transparent ? Colors.white : background,
      hasElementBackground: background != Colors.transparent,
      fallback: background == Colors.transparent
          ? const Color(0xFFFF6500)
          : const Color(0xFF151922),
    );
    final isIcon = variant.elementType == 'wishlist' ||
        variant.elementType == 'compare' ||
        variant.elementType == 'share' ||
        variant.elementType == 'animation';
    final width = isIcon ? 36.0 : 82.0;
    final height = isIcon ? 36.0 : 30.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: background == Colors.transparent ? Colors.white : background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFFD6BA)),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: isIcon ? 15 : 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

Uint8List? _drawerPendingOriginalBytes(dynamic media) {
  try {
    final value = media.pendingOriginalBytes;
    if (value is Uint8List && value.isNotEmpty) return value;
  } catch (_) {}
  return null;
}

Uint8List? _drawerPendingFullBytes(dynamic media) {
  try {
    final value = media.pendingFullBytes;
    if (value is Uint8List && value.isNotEmpty) return value;
  } catch (_) {}
  return null;
}

Uint8List? _drawerPendingCardBytes(dynamic media) {
  try {
    final value = media.pendingCardBytes;
    if (value is Uint8List && value.isNotEmpty) return value;
  } catch (_) {}
  return null;
}

Uint8List? _drawerPendingThumbBytes(dynamic media) {
  try {
    final value = media.pendingThumbBytes;
    if (value is Uint8List && value.isNotEmpty) return value;
  } catch (_) {}
  return null;
}

Uint8List? _drawerPendingTinyBytes(dynamic media) {
  try {
    final value = media.pendingTinyBytes;
    if (value is Uint8List && value.isNotEmpty) return value;
  } catch (_) {}
  return null;
}

Uint8List? _drawerFirstPendingBytes(List<Uint8List?> values) {
  for (final value in values) {
    if (value != null && value.isNotEmpty) return value;
  }
  return null;
}

dynamic _drawerPrimaryMedia(MBAdvancedPreviewContext previewContext) {
  try {
    return previewContext.product.primaryMediaItem;
  } catch (_) {
    return null;
  }
}

Uint8List? _drawerResolveImageBytes(
  MBAdvancedPreviewContext previewContext,
  String binding,
) {
  final normalizedBinding = binding.trim();

  // Pending in-memory bytes belong to the product image only.
  // Brand/category media bindings must resolve through their own URL bindings
  // (brand.logoUrl, category.imageUrl, category.iconUrl) instead of accidentally
  // reusing the product image preview bytes.
  if (!normalizedBinding.startsWith('product.')) {
    return null;
  }

  final media = _drawerPrimaryMedia(previewContext);
  if (media == null) return null;

  final original = _drawerPendingOriginalBytes(media);
  final full = _drawerPendingFullBytes(media);
  final card = _drawerPendingCardBytes(media);
  final thumb = _drawerPendingThumbBytes(media);
  final tiny = _drawerPendingTinyBytes(media);

  switch (binding.trim()) {
    case 'product.resolvedOriginalImageUrl':
      return _drawerFirstPendingBytes(<Uint8List?>[original, full, card, thumb, tiny]);
    case 'product.resolvedFullImageUrl':
      return _drawerFirstPendingBytes(<Uint8List?>[full, original, card, thumb, tiny]);
    case 'product.resolvedThumbImageUrl':
    case 'product.thumbnailUrl':
      return _drawerFirstPendingBytes(<Uint8List?>[thumb, card, full, original, tiny]);
    case 'product.resolvedTinyImageUrl':
      return _drawerFirstPendingBytes(<Uint8List?>[tiny, thumb, card, full, original]);
    case 'product.resolvedCardImageUrl':
    case 'product.imageUrl':
    case 'product.imageUrls.first':
    default:
      return _drawerFirstPendingBytes(<Uint8List?>[card, full, thumb, original, tiny]);
  }
}

class _PreviewMedia extends StatelessWidget {
  const _PreviewMedia({required this.variant, required this.previewContext});

  final MBAdvancedElementVariant variant;
  final MBAdvancedPreviewContext previewContext;

  @override
  Widget build(BuildContext context) {
    final imageBytes = _drawerResolveImageBytes(
      previewContext,
      variant.binding,
    );
    final imageUrl = MBAdvancedBindingResolver.resolveImageUrl(
      previewContext,
      variant.binding,
    );
    final isCircle = _asDouble(variant.defaultStyle['borderRadius'], 0) >= 500;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: isCircle ? 48 : 62,
        height: isCircle ? 48 : 42,
        padding: EdgeInsets.all(
          _asDouble(variant.defaultStyle['ringWidth'], 4) * 0.45,
        ),
        decoration: BoxDecoration(
          color: _hexColor(variant.defaultStyle['borderHex'], Colors.white),
          borderRadius: BorderRadius.circular(isCircle ? 999 : 14),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isCircle ? 999 : 10),
          child: imageBytes != null && imageBytes.isNotEmpty
              ? Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const _ImageFallback(),
                )
              : imageUrl.isEmpty
                  ? const _ImageFallback()
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => const _ImageFallback(),
                    ),
        ),
      ),
    );
  }
}
class _PreviewVisualShape extends StatelessWidget {
  const _PreviewVisualShape({required this.variant});

  final MBAdvancedElementVariant variant;

  @override
  Widget build(BuildContext context) {
    final color = _hexColor(
      variant.defaultStyle['backgroundHex'],
      const Color(0xFFFF6500),
    ).withValues(
      alpha: _asDouble(variant.defaultStyle['opacity'], 0.35).clamp(0.0, 1.0),
    );

    if (variant.elementType == 'progress') {
      return Align(
        alignment: Alignment.centerLeft,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 98,
            height: 10,
            color: const Color(0xFFFFE2CC),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _asDouble(variant.defaultStyle['progress'], 0.72),
              child: Container(color: const Color(0xFFFF6500)),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: variant.elementType == 'divider' ? 112 : 62,
        height: variant.elementType == 'divider' ? 4 : 38,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(
            _asDouble(variant.defaultStyle['borderRadius'], 18),
          ),
          border: Border.all(color: const Color(0xFFFFD6BA)),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF0E6),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_rounded,
        color: Color(0xFFFF6500),
        size: 18,
      ),
    );
  }
}


Color _drawerPreviewReadableTextColor({
  required Object? requested,
  required Color previewSurface,
  required bool hasElementBackground,
  required Color fallback,
}) {
  final raw = requested?.toString().trim();

  if (raw == null ||
      raw.isEmpty ||
      raw == '#00000000' ||
      raw.toLowerCase() == 'transparent') {
    return fallback;
  }

  final requestedColor = _hexColor(raw, fallback);
  final surfaceBrightness = ThemeData.estimateBrightnessForColor(previewSurface);
  final textBrightness = ThemeData.estimateBrightnessForColor(requestedColor);
  final sameBrightness = surfaceBrightness == textBrightness;

  if (!sameBrightness || hasElementBackground) {
    return requestedColor;
  }

  if (surfaceBrightness == Brightness.light) {
    return const Color(0xFF172033);
  }

  return Colors.white;
}
Color _hexColor(Object? value, Color fallback) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty || raw == '#00000000') return fallback;

  var hex = raw.replaceAll('#', '').toUpperCase();
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return fallback;

  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return fallback;

  return Color(parsed);
}

double _asDouble(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
}





