import 'package:shared_models/shared_models.dart';

class MBStoreCardPreviewEntry {
  const MBStoreCardPreviewEntry({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.sortOrder,
    this.sectionKey,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String productId;
  final String variantId;
  final int sortOrder;
  final String? sectionKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static MBStoreCardPreviewEntry create({
    required String productId,
    required String variantId,
    String? sectionKey,
    int? sortOrder,
  }) {
    final now = DateTime.now();
    final stamp = now.microsecondsSinceEpoch.toString();

    return MBStoreCardPreviewEntry(
      id: 'store_card_$stamp',
      productId: _cleanText(productId),
      variantId: MBCardVariantHelper.normalize(variantId),
      sortOrder: sortOrder ?? 0,
      sectionKey: _cleanNullable(sectionKey),
      createdAt: now,
      updatedAt: now,
    );
  }

  MBCardVariant get variant => MBCardVariantHelper.parse(variantId);

  String get variantLabel => variant.label;

  bool get isFullWidth => variant.isFullWidth;

  MBStoreCardPreviewEntry copyWith({
    String? id,
    String? productId,
    String? variantId,
    int? sortOrder,
    String? sectionKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearSectionKey = false,
  }) {
    return MBStoreCardPreviewEntry(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId == null
          ? this.variantId
          : MBCardVariantHelper.normalize(variantId),
      sortOrder: sortOrder ?? this.sortOrder,
      sectionKey: clearSectionKey ? null : (sectionKey ?? this.sectionKey),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'variantId': variantId,
      'sortOrder': sortOrder,
      'sectionKey': sectionKey,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBStoreCardPreviewEntry.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now();

    final rawVariantId = _readFirstText(
      map,
      const <String>[
        'variantId',
        'variant_id',
      ],
    );

    final legacyLayout = _readFirstText(
      map,
      const <String>[
        'layout',
        'layoutValue',
        'layout_value',
      ],
    );

    final resolvedVariantId = rawVariantId != null && rawVariantId.isNotEmpty
        ? MBCardVariantHelper.normalize(rawVariantId)
        : _legacyLayoutToVariantId(legacyLayout);

    return MBStoreCardPreviewEntry(
      id: _readFirstText(
        map,
        const <String>[
          'id',
          'entryId',
          'entry_id',
        ],
      ) ??
          'store_card_${now.microsecondsSinceEpoch}',
      productId: _readFirstText(
        map,
        const <String>[
          'productId',
          'product_id',
        ],
      ) ??
          '',
      variantId: resolvedVariantId,
      sortOrder: _readInt(
        map['sortOrder'] ?? map['sort_order'],
        fallback: 0,
      ),
      sectionKey: _cleanNullable(
        _readFirstText(
          map,
          const <String>[
            'sectionKey',
            'section_key',
          ],
        ),
      ),
      createdAt: _readDateTime(map['createdAt'] ?? map['created_at']),
      updatedAt: _readDateTime(map['updatedAt'] ?? map['updated_at']),
    );
  }

  static int sortComparator(
      MBStoreCardPreviewEntry a,
      MBStoreCardPreviewEntry b,
      ) {
    final bySort = a.sortOrder.compareTo(b.sortOrder);
    if (bySort != 0) {
      return bySort;
    }

    final aTime = a.createdAt?.microsecondsSinceEpoch ?? 0;
    final bTime = b.createdAt?.microsecondsSinceEpoch ?? 0;
    final byTime = aTime.compareTo(bTime);
    if (byTime != 0) {
      return byTime;
    }

    return a.id.compareTo(b.id);
  }

  static String _legacyLayoutToVariantId(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
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

  static String? _readFirstText(
      Map<String, dynamic> map,
      List<String> keys,
      ) {
    for (final key in keys) {
      final value = map[key];
      final text = _cleanNullable(value?.toString());
      if (text != null) {
        return text;
      }
    }
    return null;
  }

  static int _readInt(dynamic raw, {required int fallback}) {
    if (raw == null) {
      return fallback;
    }
    if (raw is int) {
      return raw;
    }
    if (raw is num) {
      return raw.toInt();
    }
    return int.tryParse(raw.toString()) ?? fallback;
  }

  static DateTime? _readDateTime(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is DateTime) {
      return raw;
    }
    if (raw is String) {
      return DateTime.tryParse(raw);
    }
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }
    if (raw is num) {
      return DateTime.fromMillisecondsSinceEpoch(raw.toInt());
    }

    try {
      final dynamic value = raw;
      final date = value.toDate();
      if (date is DateTime) {
        return date;
      }
    } catch (_) {}

    return null;
  }

  static String _cleanText(String raw) {
    return raw.trim();
  }

  static String? _cleanNullable(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}