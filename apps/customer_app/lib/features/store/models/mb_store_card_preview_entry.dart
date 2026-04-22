import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

@immutable
class MBStoreCardPreviewEntry {
  const MBStoreCardPreviewEntry({
    required this.id,
    required this.productId,
    required this.variantId,
    this.sectionKey,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String productId;
  final String variantId;
  final String? sectionKey;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MBStoreCardPreviewEntry.create({
    required String productId,
    required String variantId,
    String? sectionKey,
    int? sortOrder,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();

    return MBStoreCardPreviewEntry(
      id: _normalizeId(id) ?? now.microsecondsSinceEpoch.toString(),
      productId: _normalizeId(productId) ?? now.microsecondsSinceEpoch.toString(),
      variantId: _normalizeVariantId(variantId),
      sectionKey: _normalizeNullableString(sectionKey),
      sortOrder: sortOrder ?? 0,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? createdAt ?? now,
    );
  }

  factory MBStoreCardPreviewEntry.fromMap(Map<String, dynamic> map) {
    return MBStoreCardPreviewEntry(
      id: _readNullableString(map['id']) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      productId: _readNullableString(
        map['productId'] ?? map['product_id'],
      ) ??
          '',
      variantId: _resolveVariantIdFromMap(map),
      sectionKey: _readNullableString(map['sectionKey'] ?? map['section_key']),
      sortOrder: _readInt(map['sortOrder'] ?? map['sort_order'], 0),
      createdAt: _readDateTime(map['createdAt'] ?? map['created_at']) ??
          DateTime.now(),
      updatedAt: _readDateTime(map['updatedAt'] ?? map['updated_at']) ??
          _readDateTime(map['createdAt'] ?? map['created_at']) ??
          DateTime.now(),
    );
  }

  MBCardVariant get variant => _parseVariantId(variantId);

  String get variantLabel => variant.label;

  bool get isFullWidth {
    switch (variant) {
      case MBCardVariant.horizontal01:
      case MBCardVariant.wide01:
      case MBCardVariant.featured01:
      case MBCardVariant.promo01:
        return true;
      case MBCardVariant.compact01:
      case MBCardVariant.price01:
      case MBCardVariant.premium01:
      case MBCardVariant.flash01:
        return false;
    }
  }

  MBStoreCardPreviewEntry copyWith({
    String? id,
    String? productId,
    String? variantId,
    Object? sectionKey = _sentinel,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MBStoreCardPreviewEntry(
      id: _normalizeId(id) ?? this.id,
      productId: _normalizeId(productId) ?? this.productId,
      variantId: variantId == null
          ? this.variantId
          : _normalizeVariantId(variantId),
      sectionKey: identical(sectionKey, _sentinel)
          ? this.sectionKey
          : _normalizeNullableString(sectionKey as String?),
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'variantId': variantId,
      'sectionKey': sectionKey,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static int sortComparator(
      MBStoreCardPreviewEntry a,
      MBStoreCardPreviewEntry b,
      ) {
    final bySort = a.sortOrder.compareTo(b.sortOrder);
    if (bySort != 0) {
      return bySort;
    }

    final byCreated = a.createdAt.compareTo(b.createdAt);
    if (byCreated != 0) {
      return byCreated;
    }

    return a.id.compareTo(b.id);
  }

  @override
  String toString() {
    return 'MBStoreCardPreviewEntry('
        'id: $id, '
        'productId: $productId, '
        'variantId: $variantId, '
        'sectionKey: $sectionKey, '
        'sortOrder: $sortOrder'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBStoreCardPreviewEntry &&
        other.id == id &&
        other.productId == productId &&
        other.variantId == variantId &&
        other.sectionKey == sectionKey &&
        other.sortOrder == sortOrder &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      productId,
      variantId,
      sectionKey,
      sortOrder,
      createdAt,
      updatedAt,
    );
  }

  static String _resolveVariantIdFromMap(Map<String, dynamic> map) {
    final directVariantId = _readNullableString(
      map['variantId'] ?? map['variant_id'] ?? map['cardVariantId'],
    );
    if (directVariantId != null && directVariantId.isNotEmpty) {
      return _normalizeVariantId(directVariantId);
    }

    final legacyLayoutValue = _readNullableString(
      map['layout'] ?? map['layoutValue'] ?? map['layout_value'],
    );
    if (legacyLayoutValue != null && legacyLayoutValue.isNotEmpty) {
      return _legacyLayoutValueToVariantId(legacyLayoutValue);
    }

    return MBCardVariant.compact01.id;
  }

  static String _normalizeVariantId(String raw) {
    return _parseVariantId(raw).id;
  }

  static MBCardVariant _parseVariantId(String raw) {
    final value = raw.trim().toLowerCase();

    switch (value) {
      case 'compact01':
        return MBCardVariant.compact01;
      case 'price01':
        return MBCardVariant.price01;
      case 'horizontal01':
        return MBCardVariant.horizontal01;
      case 'premium01':
        return MBCardVariant.premium01;
      case 'wide01':
        return MBCardVariant.wide01;
      case 'featured01':
        return MBCardVariant.featured01;
      case 'promo01':
        return MBCardVariant.promo01;
      case 'flash01':
        return MBCardVariant.flash01;
      default:
        return MBCardVariant.compact01;
    }
  }

  static String _legacyLayoutValueToVariantId(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'compact':
        return MBCardVariant.compact01.id;
      case 'card01':
        return MBCardVariant.price01.id;
      case 'standard':
        return MBCardVariant.horizontal01.id;
      case 'card02':
        return MBCardVariant.premium01.id;
      case 'featured':
        return MBCardVariant.wide01.id;
      case 'card03':
        return MBCardVariant.featured01.id;
      case 'deal':
        return MBCardVariant.flash01.id;
      default:
        return MBCardVariant.compact01.id;
    }
  }

  static String? _normalizeId(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static String? _normalizeNullableString(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static String? _readNullableString(Object? value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static int _readInt(Object? value, int fallback) {
    if (value == null) {
      return fallback;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString().trim()) ?? fallback;
  }

  static DateTime? _readDateTime(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    final normalized = value.toString().trim();
    if (normalized.isEmpty) {
      return null;
    }

    return DateTime.tryParse(normalized);
  }

  static const Object _sentinel = Object();
}
