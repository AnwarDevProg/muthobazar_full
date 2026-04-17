import 'dart:convert';

// File: mb_product_media.dart
// MB Product Media Model
// ----------------------
// Backward-compatible rich media item for product thumbnail, gallery,
// detail, variation preview, and future video use.
//
// Upgrade notes:
// - Keeps legacy `url`, `storagePath`, `width`, `height`, `sizeBytes` fields.
// - Adds separate thumb/full image support for accurate preview handling.
// - Safely reads old documents that only stored a single `url`.

class MBProductMedia {
  final String id;

  // Legacy / generic fields kept for backward compatibility.
  final String url;
  final String storagePath;

  // New paired image fields.
  final String fullUrl;
  final String fullStoragePath;
  final String thumbUrl;
  final String thumbStoragePath;
  final String originalUrl;
  final String originalStoragePath;

  final String type;
  final String role;
  final String labelEn;
  final String labelBn;
  final String altEn;
  final String altBn;
  final int sortOrder;
  final bool isPrimary;
  final bool isEnabled;

  // Legacy / generic metadata kept for backward compatibility.
  final int? width;
  final int? height;
  final int? sizeBytes;

  // New full image metadata.
  final int? fullWidth;
  final int? fullHeight;
  final int? fullSizeBytes;

  // New thumbnail metadata.
  final int? thumbWidth;
  final int? thumbHeight;
  final int? thumbSizeBytes;

  // Optional original source metadata.
  final int? originalWidth;
  final int? originalHeight;
  final int? originalSizeBytes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MBProductMedia({
    required this.id,
    this.url = '',
    this.storagePath = '',
    this.fullUrl = '',
    this.fullStoragePath = '',
    this.thumbUrl = '',
    this.thumbStoragePath = '',
    this.originalUrl = '',
    this.originalStoragePath = '',
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
    this.fullWidth,
    this.fullHeight,
    this.fullSizeBytes,
    this.thumbWidth,
    this.thumbHeight,
    this.thumbSizeBytes,
    this.originalWidth,
    this.originalHeight,
    this.originalSizeBytes,
    this.createdAt,
    this.updatedAt,
  });

  static const MBProductMedia empty = MBProductMedia(id: '');

  MBProductMedia copyWith({
    String? id,
    String? url,
    String? storagePath,
    String? fullUrl,
    String? fullStoragePath,
    String? thumbUrl,
    String? thumbStoragePath,
    String? originalUrl,
    String? originalStoragePath,
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
    int? fullWidth,
    bool clearFullWidth = false,
    int? fullHeight,
    bool clearFullHeight = false,
    int? fullSizeBytes,
    bool clearFullSizeBytes = false,
    int? thumbWidth,
    bool clearThumbWidth = false,
    int? thumbHeight,
    bool clearThumbHeight = false,
    int? thumbSizeBytes,
    bool clearThumbSizeBytes = false,
    int? originalWidth,
    bool clearOriginalWidth = false,
    int? originalHeight,
    bool clearOriginalHeight = false,
    int? originalSizeBytes,
    bool clearOriginalSizeBytes = false,
    DateTime? createdAt,
    bool clearCreatedAt = false,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return MBProductMedia(
      id: id ?? this.id,
      url: url ?? this.url,
      storagePath: storagePath ?? this.storagePath,
      fullUrl: fullUrl ?? this.fullUrl,
      fullStoragePath: fullStoragePath ?? this.fullStoragePath,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      thumbStoragePath: thumbStoragePath ?? this.thumbStoragePath,
      originalUrl: originalUrl ?? this.originalUrl,
      originalStoragePath: originalStoragePath ?? this.originalStoragePath,
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
      fullWidth: clearFullWidth ? null : (fullWidth ?? this.fullWidth),
      fullHeight: clearFullHeight ? null : (fullHeight ?? this.fullHeight),
      fullSizeBytes:
      clearFullSizeBytes ? null : (fullSizeBytes ?? this.fullSizeBytes),
      thumbWidth: clearThumbWidth ? null : (thumbWidth ?? this.thumbWidth),
      thumbHeight: clearThumbHeight ? null : (thumbHeight ?? this.thumbHeight),
      thumbSizeBytes:
      clearThumbSizeBytes ? null : (thumbSizeBytes ?? this.thumbSizeBytes),
      originalWidth:
      clearOriginalWidth ? null : (originalWidth ?? this.originalWidth),
      originalHeight:
      clearOriginalHeight ? null : (originalHeight ?? this.originalHeight),
      originalSizeBytes: clearOriginalSizeBytes
          ? null
          : (originalSizeBytes ?? this.originalSizeBytes),
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isThumbnail => role == 'thumbnail';
  bool get isGallery => role == 'gallery';

  String get effectiveFullUrl {
    if (fullUrl.trim().isNotEmpty) return fullUrl.trim();
    if (url.trim().isNotEmpty) return url.trim();
    if (originalUrl.trim().isNotEmpty) return originalUrl.trim();
    return '';
  }

  String get effectiveThumbUrl {
    if (thumbUrl.trim().isNotEmpty) return thumbUrl.trim();
    if (isThumbnail && url.trim().isNotEmpty) return url.trim();
    return effectiveFullUrl;
  }

  String get effectiveOriginalUrl {
    if (originalUrl.trim().isNotEmpty) return originalUrl.trim();
    return effectiveFullUrl;
  }

  String get effectiveFullStoragePath {
    if (fullStoragePath.trim().isNotEmpty) return fullStoragePath.trim();
    if (storagePath.trim().isNotEmpty) return storagePath.trim();
    if (originalStoragePath.trim().isNotEmpty) return originalStoragePath.trim();
    return '';
  }

  String get effectiveThumbStoragePath {
    if (thumbStoragePath.trim().isNotEmpty) return thumbStoragePath.trim();
    if (isThumbnail && storagePath.trim().isNotEmpty) return storagePath.trim();
    return effectiveFullStoragePath;
  }

  String get effectiveOriginalStoragePath {
    if (originalStoragePath.trim().isNotEmpty) {
      return originalStoragePath.trim();
    }
    return effectiveFullStoragePath;
  }

  int? get effectiveFullWidth => fullWidth ?? width ?? originalWidth;
  int? get effectiveFullHeight => fullHeight ?? height ?? originalHeight;
  int? get effectiveFullSizeBytes => fullSizeBytes ?? sizeBytes ?? originalSizeBytes;

  int? get effectiveThumbWidth => thumbWidth ?? effectiveFullWidth;
  int? get effectiveThumbHeight => thumbHeight ?? effectiveFullHeight;
  int? get effectiveThumbSizeBytes => thumbSizeBytes ?? effectiveFullSizeBytes;

  int? get effectiveOriginalWidth => originalWidth ?? effectiveFullWidth;
  int? get effectiveOriginalHeight => originalHeight ?? effectiveFullHeight;
  int? get effectiveOriginalSizeBytes => originalSizeBytes ?? effectiveFullSizeBytes;

  String get previewUrl => effectiveThumbUrl;
  String get displayUrl => effectiveFullUrl;

  bool get hasUrl => displayUrl.isNotEmpty;
  bool get hasSeparateThumbnail =>
      thumbUrl.trim().isNotEmpty && effectiveThumbUrl != effectiveFullUrl;
  bool get hasOriginalSource => originalUrl.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url.isNotEmpty ? url : effectiveFullUrl,
      'storagePath': storagePath.isNotEmpty ? storagePath : effectiveFullStoragePath,
      'fullUrl': fullUrl.isNotEmpty ? fullUrl : effectiveFullUrl,
      'fullStoragePath': fullStoragePath.isNotEmpty
          ? fullStoragePath
          : effectiveFullStoragePath,
      'thumbUrl': thumbUrl.isNotEmpty ? thumbUrl : '',
      'thumbStoragePath': thumbStoragePath.isNotEmpty ? thumbStoragePath : '',
      'originalUrl': originalUrl.isNotEmpty ? originalUrl : '',
      'originalStoragePath':
      originalStoragePath.isNotEmpty ? originalStoragePath : '',
      'type': type,
      'role': role,
      'labelEn': labelEn,
      'labelBn': labelBn,
      'altEn': altEn,
      'altBn': altBn,
      'sortOrder': sortOrder,
      'isPrimary': isPrimary,
      'isEnabled': isEnabled,
      'width': width ?? effectiveFullWidth,
      'height': height ?? effectiveFullHeight,
      'sizeBytes': sizeBytes ?? effectiveFullSizeBytes,
      'fullWidth': fullWidth ?? effectiveFullWidth,
      'fullHeight': fullHeight ?? effectiveFullHeight,
      'fullSizeBytes': fullSizeBytes ?? effectiveFullSizeBytes,
      'thumbWidth': thumbWidth,
      'thumbHeight': thumbHeight,
      'thumbSizeBytes': thumbSizeBytes,
      'originalWidth': originalWidth,
      'originalHeight': originalHeight,
      'originalSizeBytes': originalSizeBytes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBProductMedia.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    final legacyUrl = _asString(map['url']);
    final legacyStoragePath = _asString(map['storagePath']);
    final parsedFullUrl = _asString(map['fullUrl']);
    final parsedThumbUrl = _asString(map['thumbUrl']);
    final parsedOriginalUrl = _asString(map['originalUrl']);
    final parsedFullStoragePath = _asString(map['fullStoragePath']);
    final parsedThumbStoragePath = _asString(map['thumbStoragePath']);
    final parsedOriginalStoragePath = _asString(map['originalStoragePath']);

    return MBProductMedia(
      id: _asString(map['id']),
      url: legacyUrl.isNotEmpty ? legacyUrl : parsedFullUrl,
      storagePath: legacyStoragePath.isNotEmpty
          ? legacyStoragePath
          : parsedFullStoragePath,
      fullUrl: parsedFullUrl.isNotEmpty ? parsedFullUrl : legacyUrl,
      fullStoragePath: parsedFullStoragePath.isNotEmpty
          ? parsedFullStoragePath
          : legacyStoragePath,
      thumbUrl: parsedThumbUrl,
      thumbStoragePath: parsedThumbStoragePath,
      originalUrl: parsedOriginalUrl,
      originalStoragePath: parsedOriginalStoragePath,
      type: _asString(map['type'], fallback: 'image'),
      role: _asString(map['role'], fallback: 'gallery'),
      labelEn: _asString(map['labelEn']),
      labelBn: _asString(map['labelBn']),
      altEn: _asString(map['altEn']),
      altBn: _asString(map['altBn']),
      sortOrder: _asInt(map['sortOrder'], fallback: 0),
      isPrimary: _asBool(map['isPrimary'], fallback: false),
      isEnabled: _asBool(map['isEnabled'], fallback: true),
      width: _asNullableInt(map['width']),
      height: _asNullableInt(map['height']),
      sizeBytes: _asNullableInt(map['sizeBytes']),
      fullWidth: _asNullableInt(map['fullWidth']) ?? _asNullableInt(map['width']),
      fullHeight:
      _asNullableInt(map['fullHeight']) ?? _asNullableInt(map['height']),
      fullSizeBytes: _asNullableInt(map['fullSizeBytes']) ??
          _asNullableInt(map['sizeBytes']),
      thumbWidth: _asNullableInt(map['thumbWidth']),
      thumbHeight: _asNullableInt(map['thumbHeight']),
      thumbSizeBytes: _asNullableInt(map['thumbSizeBytes']),
      originalWidth: _asNullableInt(map['originalWidth']),
      originalHeight: _asNullableInt(map['originalHeight']),
      originalSizeBytes: _asNullableInt(map['originalSizeBytes']),
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
    final normalizedUrl = url.trim();
    return MBProductMedia(
      id: id,
      url: normalizedUrl,
      fullUrl: normalizedUrl,
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

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final parsed = value.toString().trim();
  return parsed.isEmpty ? fallback : parsed;
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
