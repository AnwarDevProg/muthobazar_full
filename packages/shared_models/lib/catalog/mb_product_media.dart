import 'dart:convert';

// File: mb_product_media.dart
// MB Product Media Model
// ----------------------
// Rich media item for product thumbnail, gallery, detail, and future video use.

class MBProductMedia {
  final String id;
  final String url;
  final String storagePath;
  final String type;
  final String role;
  final String labelEn;
  final String labelBn;
  final String altEn;
  final String altBn;
  final int sortOrder;
  final bool isPrimary;
  final bool isEnabled;
  final int? width;
  final int? height;
  final int? sizeBytes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MBProductMedia({
    required this.id,
    required this.url,
    this.storagePath = '',
    this.type = 'image',
    this.role = 'gallery',
    this.labelEn = '',
    this.labelBn = '',
    this.altEn = '',
    this.altBn = '',
    this.sortOrder = 0,
    this.isPrimary = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.sizeBytes,
    this.createdAt,
    this.updatedAt,
  });

  static const MBProductMedia empty = MBProductMedia(
    id: '',
    url: '',
  );

  MBProductMedia copyWith({
    String? id,
    String? url,
    String? storagePath,
    String? type,
    String? role,
    String? labelEn,
    String? labelBn,
    String? altEn,
    String? altBn,
    int? sortOrder,
    bool? isPrimary,
    bool? isEnabled,
    int? width,
    bool clearWidth = false,
    int? height,
    bool clearHeight = false,
    int? sizeBytes,
    bool clearSizeBytes = false,
    DateTime? createdAt,
    bool clearCreatedAt = false,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return MBProductMedia(
      id: id ?? this.id,
      url: url ?? this.url,
      storagePath: storagePath ?? this.storagePath,
      type: type ?? this.type,
      role: role ?? this.role,
      labelEn: labelEn ?? this.labelEn,
      labelBn: labelBn ?? this.labelBn,
      altEn: altEn ?? this.altEn,
      altBn: altBn ?? this.altBn,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      isEnabled: isEnabled ?? this.isEnabled,
      width: clearWidth ? null : (width ?? this.width),
      height: clearHeight ? null : (height ?? this.height),
      sizeBytes: clearSizeBytes ? null : (sizeBytes ?? this.sizeBytes),
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  bool get isImage => type == 'image';

  bool get isVideo => type == 'video';

  bool get isThumbnail => role == 'thumbnail';

  bool get isGallery => role == 'gallery';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'storagePath': storagePath,
      'type': type,
      'role': role,
      'labelEn': labelEn,
      'labelBn': labelBn,
      'altEn': altEn,
      'altBn': altBn,
      'sortOrder': sortOrder,
      'isPrimary': isPrimary,
      'isEnabled': isEnabled,
      'width': width,
      'height': height,
      'sizeBytes': sizeBytes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBProductMedia.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    return MBProductMedia(
      id: (map['id'] ?? '').toString(),
      url: (map['url'] ?? '').toString(),
      storagePath: (map['storagePath'] ?? '').toString(),
      type: (map['type'] ?? 'image').toString(),
      role: (map['role'] ?? 'gallery').toString(),
      labelEn: (map['labelEn'] ?? '').toString(),
      labelBn: (map['labelBn'] ?? '').toString(),
      altEn: (map['altEn'] ?? '').toString(),
      altBn: (map['altBn'] ?? '').toString(),
      sortOrder: _asInt(map['sortOrder'], fallback: 0),
      isPrimary: _asBool(map['isPrimary'], fallback: false),
      isEnabled: _asBool(map['isEnabled'], fallback: true),
      width: _asNullableInt(map['width']),
      height: _asNullableInt(map['height']),
      sizeBytes: _asNullableInt(map['sizeBytes']),
      createdAt: _asNullableDateTime(map['createdAt']),
      updatedAt: _asNullableDateTime(map['updatedAt']),
    );
  }

  factory MBProductMedia.fromLegacyUrl(
      String url, {
        String id = '',
        String role = 'gallery',
        int sortOrder = 0,
        bool isPrimary = false,
      }) {
    return MBProductMedia(
      id: id,
      url: url,
      role: role,
      sortOrder: sortOrder,
      isPrimary: isPrimary,
      isEnabled: true,
      type: 'image',
    );
  }

  String toJson() => json.encode(toMap());

  factory MBProductMedia.fromJson(String source) =>
      MBProductMedia.fromMap(json.decode(source) as Map<String, dynamic>);
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return fallback;
}

DateTime? _asNullableDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}