import 'package:shared_models/shared_models.dart';

class MBStoreCardPreviewEntry {
  const MBStoreCardPreviewEntry({
    required this.id,
    required this.productId,
    required this.variantId,
    this.sectionKey,
    this.sortOrder = 0,
  });

  final String id;
  final String productId;
  final String variantId;
  final String? sectionKey;
  final int sortOrder;

  MBCardVariant get variant => MBCardVariantHelper.parse(
    _normalizeVariantId(variantId),
    fallback: MBCardVariant.compact01,
  );

  String get normalizedVariantId => variant.id;
  String get variantLabel => variant.label;
  String get familyId => variant.familyId;
  bool get isFullWidth => variant.isFullWidth;
  bool get isHalfWidth => !variant.isFullWidth;

  // Temporary compatibility bridge for older preview/store files.
  MBProductCardLayout get layout => _variantToLegacyLayout(variant);

  // Temporary compatibility bridge for older preview/store files.
  String get layoutLabel => variant.label;

  MBStoreCardPreviewEntry copyWith({
    String? id,
    String? productId,
    String? variantId,
    String? sectionKey,
    bool clearSectionKey = false,
    int? sortOrder,
  }) {
    return MBStoreCardPreviewEntry(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      sectionKey: clearSectionKey ? null : (sectionKey ?? this.sectionKey),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory MBStoreCardPreviewEntry.create({
    required String productId,
    required String variantId,
    String? id,
    String? sectionKey,
    int? sortOrder,
  }) {
    return MBStoreCardPreviewEntry(
      id: _clean(id).isEmpty ? _generateId() : _clean(id),
      productId: _clean(productId),
      variantId: _normalizeVariantId(variantId),
      sectionKey: _cleanNullable(sectionKey),
      sortOrder: sortOrder ?? 0,
    );
  }

  factory MBStoreCardPreviewEntry.fromMap(Map<String, dynamic> map) {
    final rawId =
        map['id'] ?? map['entryId'] ?? map['previewEntryId'] ?? map['cardId'];

    final rawProductId =
        map['productId'] ?? map['productDocId'] ?? map['itemId'] ?? '';

    final rawVariantId = map['variantId'] ??
        map['cardVariantId'] ??
        map['cardVariant'] ??
        map['cardLayoutType'] ??
        map['cardStyle'] ??
        map['cardType'] ??
        map['layout'];

    final rawSectionKey =
        map['sectionKey'] ?? map['sectionId'] ?? map['section'];

    final rawSortOrder = map['sortOrder'] ?? map['order'] ?? map['index'];

    return MBStoreCardPreviewEntry(
      id: _clean(rawId).isEmpty ? _generateId() : _clean(rawId),
      productId: _clean(rawProductId),
      variantId: _normalizeVariantId(rawVariantId),
      sectionKey: _cleanNullable(rawSectionKey),
      sortOrder: _readInt(rawSortOrder),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'variantId': normalizedVariantId,
      'sectionKey': sectionKey,
      'sortOrder': sortOrder,
      // Temporary legacy bridge
      'layout': layout.value,
      'layoutValue': layout.value,
    };
  }

  static List<MBStoreCardPreviewEntry> fromMapList(List<dynamic> items) {
    return items
        .whereType<Map>()
        .map(
          (item) => MBStoreCardPreviewEntry.fromMap(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList(growable: false);
  }

  static int sortComparator(
      MBStoreCardPreviewEntry a,
      MBStoreCardPreviewEntry b,
      ) {
    final bySort = a.sortOrder.compareTo(b.sortOrder);
    if (bySort != 0) {
      return bySort;
    }

    return a.id.compareTo(b.id);
  }

  static String _normalizeVariantId(dynamic raw) {
    final normalized = _clean(raw).toLowerCase();

    switch (normalized) {
    // Family ids accidentally stored instead of exact variant ids.
      case 'compact':
        return MBCardVariant.compact01.id;
      case 'price':
        return MBCardVariant.price01.id;
      case 'horizontal':
        return MBCardVariant.horizontal01.id;
      case 'premium':
        return MBCardVariant.premium01.id;
      case 'wide':
        return MBCardVariant.wide01.id;
      case 'featured':
        return MBCardVariant.featured01.id;
      case 'promo':
        return MBCardVariant.promo01.id;
      case 'flash':
      case 'flashsale':
      case 'flash_sale':
        return MBCardVariant.flash01.id;

    // Old layout bridge.
      case 'standard':
        return MBCardVariant.horizontal01.id;
      case 'deal':
        return MBCardVariant.flash01.id;
      case 'card01':
        return MBCardVariant.price01.id;
      case 'card02':
        return MBCardVariant.premium01.id;
      case 'card03':
        return MBCardVariant.featured01.id;

      default:
        return normalized.isEmpty ? MBCardVariant.compact01.id : normalized;
    }
  }

  static MBProductCardLayout _variantToLegacyLayout(MBCardVariant variant) {
    switch (variant) {
      case MBCardVariant.compact01:
      case MBCardVariant.compact02:
      case MBCardVariant.compact03:
      case MBCardVariant.compact04:
      case MBCardVariant.compact05:
        return MBProductCardLayout.compact;

      case MBCardVariant.price01:
      case MBCardVariant.price02:
      case MBCardVariant.price03:
      case MBCardVariant.price04:
      case MBCardVariant.price05:
        return MBProductCardLayout.card01;

      case MBCardVariant.horizontal01:
      case MBCardVariant.horizontal02:
      case MBCardVariant.horizontal03:
      case MBCardVariant.horizontal04:
      case MBCardVariant.horizontal05:
        return MBProductCardLayout.standard;

      case MBCardVariant.premium01:
      case MBCardVariant.premium02:
      case MBCardVariant.premium03:
      case MBCardVariant.premium04:
      case MBCardVariant.premium05:
        return MBProductCardLayout.card02;

      case MBCardVariant.wide01:
      case MBCardVariant.wide02:
      case MBCardVariant.wide03:
      case MBCardVariant.wide04:
      case MBCardVariant.wide05:
        return MBProductCardLayout.featured;

      case MBCardVariant.featured01:
      case MBCardVariant.featured02:
      case MBCardVariant.featured03:
      case MBCardVariant.featured04:
      case MBCardVariant.featured05:
        return MBProductCardLayout.card03;

      case MBCardVariant.promo01:
      case MBCardVariant.promo02:
      case MBCardVariant.promo03:
      case MBCardVariant.promo04:
      case MBCardVariant.promo05:
        return MBProductCardLayout.featured;

      case MBCardVariant.flash01:
      case MBCardVariant.flash02:
      case MBCardVariant.flash03:
      case MBCardVariant.flash04:
      case MBCardVariant.flash05:
        return MBProductCardLayout.deal;
    }
  }

  static int _readInt(dynamic raw) {
    if (raw is int) {
      return raw;
    }
    if (raw is double) {
      return raw.round();
    }
    return int.tryParse(_clean(raw)) ?? 0;
  }

  static String _clean(dynamic raw) {
    if (raw == null) {
      return '';
    }
    if (raw is String) {
      return raw.trim();
    }
    return raw.toString().trim();
  }

  static String? _cleanNullable(dynamic raw) {
    final value = _clean(raw);
    return value.isEmpty ? null : value;
  }

  static String _generateId() {
    return 'preview_${DateTime.now().microsecondsSinceEpoch}';
  }
}