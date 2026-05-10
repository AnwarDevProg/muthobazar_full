// MuthoBazar Studio V4 Document Adapter
//
// Purpose:
// - Converts the current Studio V3 advanced document into the future V4 schema.
// - This keeps migration work isolated and allows Studio V3 to remain active.

import 'package:shared_models/shared_models.dart';

import '../../design_studio_advanced/models/mb_advanced_card_design_document.dart';

class MBStudioV4DocumentAdapter {
  const MBStudioV4DocumentAdapter._();

  static MBCardDesignDocumentV4 fromAdvancedDocument(
    MBAdvancedCardDesignDocument source, {
    String? id,
    String? name,
  }) {
    return MBCardDesignDocumentV4(
      id: id ?? 'v4_from_v3_${DateTime.now().microsecondsSinceEpoch}',
      name: name ?? 'Migrated Studio V4 card',
      canvas: MBDesignCanvasSpecV4(
        width: source.cardWidth,
        height: source.cardHeight,
        layoutType: source.cardLayoutType,
        backgroundMode: 'gradient',
        backgroundColor: _asNullableString(source.palette['backgroundHex']),
        backgroundGradientId: _asNullableString(source.palette['presetId']),
        borderRadius: source.borderRadius,
      ),
      nodes: <MBDesignNodeV4>[
        for (final node in source.nodes) _nodeFromAdvanced(node),
      ]..sort(MBDesignNodeV4.compareByLayer),
      metadata: <String, dynamic>{
        'sourceSchema': source.type,
        'sourceVersion': source.version,
        'sourceTemplateId': source.templateId,
        'sourceDesignFamilyId': source.designFamilyId,
        'cardLayoutType': source.cardLayoutType,
      },
    );
  }

  static MBDesignNodeV4 _nodeFromAdvanced(MBAdvancedDesignNode source) {
    return MBDesignNodeV4(
      id: source.id,
      name: source.label ?? source.variantId,
      type: _mapElementType(source.elementType),
      visible: source.visible,
      locked: source.locked,
      transform: MBDesignTransformV4(
        x: source.position.x,
        y: source.position.y,
        width: source.size.width,
        height: source.size.height,
        zIndex: source.position.z,
        anchor: source.position.anchor,
        opacity: _asDouble(source.style['opacity'], 1).clamp(0.0, 1.0).toDouble(),
      ),
      style: MBDesignStyleV4(
        fill: _asNullableString(source.style['backgroundHex']),
        radius: source.style.containsKey('borderRadius')
            ? _asDouble(source.style['borderRadius'], 0)
            : null,
        border: source.style.containsKey('borderHex') || source.style.containsKey('borderWidth')
            ? MBBorderStyleV4(
                color: _asString(source.style['borderHex'], '#000000'),
                width: _asDouble(source.style['borderWidth'], 1),
              )
            : null,
        textStyleId: _asNullableString(source.style['textStyleId']),
        extra: <String, dynamic>{...source.style},
      ),
      binding: MBDesignBindingV4(
        source: _bindingSource(source.binding),
        path: source.binding,
        fallbackMode: 'empty',
      ),
      props: <String, dynamic>{
        'v3ElementType': source.elementType,
        'v3VariantId': source.variantId,
        ...source.metadata,
      },
    );
  }

  static MBDesignNodeTypeV4 _mapElementType(String elementType) {
    switch (elementType.trim()) {
      case 'title':
      case 'subtitle':
      case 'description':
      case 'brand':
      case 'category':
      case 'unit':
      case 'savingText':
      case 'feature':
        return MBDesignNodeTypeV4.text;
      case 'media':
      case 'imageOverlay':
        return MBDesignNodeTypeV4.media;
      case 'price':
      case 'mrp':
      case 'compare':
        return MBDesignNodeTypeV4.price;
      case 'badge':
      case 'discount':
      case 'priceBadge':
      case 'promoBadge':
      case 'flashBadge':
      case 'ribbon':
        return MBDesignNodeTypeV4.badge;
      case 'cta':
      case 'secondaryCta':
        return MBDesignNodeTypeV4.button;
      case 'delivery':
        return MBDesignNodeTypeV4.delivery;
      case 'timer':
        return MBDesignNodeTypeV4.timer;
      case 'stock':
        return MBDesignNodeTypeV4.stock;
      case 'rating':
        return MBDesignNodeTypeV4.rating;
      case 'divider':
        return MBDesignNodeTypeV4.divider;
      case 'icon':
      case 'wishlist':
      case 'share':
        return MBDesignNodeTypeV4.icon;
      case 'shape':
      case 'panel':
      case 'border':
      case 'shadow':
      case 'effect':
        return MBDesignNodeTypeV4.shape;
      default:
        return MBDesignNodeTypeV4.unknown;
    }
  }

  static String _bindingSource(String binding) {
    final normalized = binding.trim();
    if (normalized.startsWith('product.')) return 'product';
    if (normalized.startsWith('action.')) return 'action';
    if (normalized.startsWith('static.')) return 'static';
    return 'unknown';
  }
}

String _asString(Object? value, String fallback) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return fallback;
  return text;
}

String? _asNullableString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

double _asDouble(Object? value, double fallback) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}
