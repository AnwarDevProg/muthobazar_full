import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_ui/shared_ui.dart';

@immutable
class MBStoreCardPreviewEntry {
  const MBStoreCardPreviewEntry({
    required this.entryId,
    required this.productId,
    required this.layout,
    this.sectionKey,
    this.sortOrder,
  });

  factory MBStoreCardPreviewEntry.create({
    required String productId,
    required MBProductCardLayout layout,
    String? sectionKey,
    int? sortOrder,
  }) {
    return MBStoreCardPreviewEntry(
      entryId: DateTime.now().microsecondsSinceEpoch.toString(),
      productId: productId,
      layout: layout,
      sectionKey: _normalizeNullable(sectionKey),
      sortOrder: sortOrder,
    );
  }

  factory MBStoreCardPreviewEntry.fromMap(Map<String, dynamic> map) {
    return MBStoreCardPreviewEntry(
      entryId: _readString(map['entryId']),
      productId: _readString(map['productId']),
      layout: MBProductCardLayoutHelper.parse(_readString(map['layout'])),
      sectionKey: _readNullableString(map['sectionKey']),
      sortOrder: _readNullableInt(map['sortOrder']),
    );
  }

  final String entryId;
  final String productId;
  final MBProductCardLayout layout;
  final String? sectionKey;
  final int? sortOrder;

  String get layoutType => layout.value;
  String get layoutLabel => layout.label;

  MBStoreCardPreviewEntry copyWith({
    String? entryId,
    String? productId,
    MBProductCardLayout? layout,
    Object? sectionKey = _sentinel,
    Object? sortOrder = _sentinel,
  }) {
    return MBStoreCardPreviewEntry(
      entryId: entryId ?? this.entryId,
      productId: productId ?? this.productId,
      layout: layout ?? this.layout,
      sectionKey: identical(sectionKey, _sentinel)
          ? this.sectionKey
          : _normalizeNullable(sectionKey as String?),
      sortOrder: identical(sortOrder, _sentinel)
          ? this.sortOrder
          : sortOrder as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'entryId': entryId,
      'productId': productId,
      'layout': layout.value,
      'sectionKey': sectionKey,
      'sortOrder': sortOrder,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MBStoreCardPreviewEntry &&
        other.entryId == entryId &&
        other.productId == productId &&
        other.layout == layout &&
        other.sectionKey == sectionKey &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(
      entryId,
      productId,
      layout,
      sectionKey,
      sortOrder,
    );
  }

  @override
  String toString() {
    return 'MBStoreCardPreviewEntry('
        'entryId: $entryId, '
        'productId: $productId, '
        'layout: ${layout.value}, '
        'sectionKey: $sectionKey, '
        'sortOrder: $sortOrder'
        ')';
  }

  static int sortComparator(
      MBStoreCardPreviewEntry a,
      MBStoreCardPreviewEntry b,
      ) {
    final aSort = a.sortOrder ?? 1 << 30;
    final bSort = b.sortOrder ?? 1 << 30;
    final bySort = aSort.compareTo(bSort);
    if (bySort != 0) {
      return bySort;
    }
    return a.entryId.compareTo(b.entryId);
  }

  static const Object _sentinel = Object();

  static String _readString(Object? value) {
    final normalized = value?.toString().trim() ?? '';
    return normalized;
  }

  static String? _readNullableString(Object? value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString().trim());
  }

  static String? _normalizeNullable(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
