import 'dart:convert';
import 'dart:typed_data';

// File: mb_product_media.dart
// MB Product Media Model
// ----------------------
// Backward-compatible rich media item for product thumbnail, gallery,
// detail, variation preview, and future video use.
//
// Media pipeline notes:
// - Keeps legacy `url`, `storagePath`, `width`, `height`, `sizeBytes` fields.
// - Supports original/full/card/thumb/tiny generated images.
// - Upload should never hide the original view.
// - Card crop is optional; default card image can be contain-fit.

class MBProductMedia {
  final String id;

  // Legacy / generic fields kept for backward compatibility.
  final String url;
  final String storagePath;

  // Generated image versions.
  final String originalUrl;
  final String originalStoragePath;
  final String fullUrl;
  final String fullStoragePath;
  final String cardUrl;
  final String cardStoragePath;
  final String thumbUrl;
  final String thumbStoragePath;
  final String tinyUrl;
  final String tinyStoragePath;

  final String type;
  final String role;
  final String labelEn;
  final String labelBn;
  final String altEn;
  final String altBn;
  final int sortOrder;
  final bool isPrimary;
  final bool isEnabled;

  // Display/crop metadata.
  final String fitMode; // contain, cover, manualCrop
  final int? cropAspectRatioX;
  final int? cropAspectRatioY;
  final int? cropWidth;
  final int? cropHeight;
  final int? cropSizeBytes;
  final double? cropZoomScale;
  final double? focalPointX;
  final double? focalPointY;

  // Legacy / generic metadata kept for backward compatibility.
  final int? width;
  final int? height;
  final int? sizeBytes;

  final int? originalWidth;
  final int? originalHeight;
  final int? originalSizeBytes;

  final int? fullWidth;
  final int? fullHeight;
  final int? fullSizeBytes;

  final int? cardWidth;
  final int? cardHeight;
  final int? cardSizeBytes;

  final int? thumbWidth;
  final int? thumbHeight;
  final int? thumbSizeBytes;

  final int? tinyWidth;
  final int? tinyHeight;
  final int? tinySizeBytes;

  // Non-persisted admin draft bytes.
  // These are intentionally omitted from toMap()/fromMap() so Firestore never
  // stores image bytes. They live only while the product form dialog is open.
  final Uint8List? pendingOriginalBytes;
  final Uint8List? pendingFullBytes;
  final Uint8List? pendingCardBytes;
  final Uint8List? pendingThumbBytes;
  final Uint8List? pendingTinyBytes;
  final String pendingOriginalFileName;
  final String pendingBaseName;
  final String pendingMimeType;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MBProductMedia({
    required this.id,
    this.url = '',
    this.storagePath = '',
    this.originalUrl = '',
    this.originalStoragePath = '',
    this.fullUrl = '',
    this.fullStoragePath = '',
    this.cardUrl = '',
    this.cardStoragePath = '',
    this.thumbUrl = '',
    this.thumbStoragePath = '',
    this.tinyUrl = '',
    this.tinyStoragePath = '',
    this.type = 'image',
    this.role = 'gallery',
    this.labelEn = '',
    this.labelBn = '',
    this.altEn = '',
    this.altBn = '',
    this.sortOrder = 0,
    this.isPrimary = false,
    this.isEnabled = true,
    this.fitMode = 'contain',
    this.cropAspectRatioX,
    this.cropAspectRatioY,
    this.cropWidth,
    this.cropHeight,
    this.cropSizeBytes,
    this.cropZoomScale,
    this.focalPointX,
    this.focalPointY,
    this.width,
    this.height,
    this.sizeBytes,
    this.originalWidth,
    this.originalHeight,
    this.originalSizeBytes,
    this.fullWidth,
    this.fullHeight,
    this.fullSizeBytes,
    this.cardWidth,
    this.cardHeight,
    this.cardSizeBytes,
    this.thumbWidth,
    this.thumbHeight,
    this.thumbSizeBytes,
    this.tinyWidth,
    this.tinyHeight,
    this.tinySizeBytes,
    this.pendingOriginalBytes,
    this.pendingFullBytes,
    this.pendingCardBytes,
    this.pendingThumbBytes,
    this.pendingTinyBytes,
    this.pendingOriginalFileName = '',
    this.pendingBaseName = '',
    this.pendingMimeType = 'image/jpeg',
    this.createdAt,
    this.updatedAt,
  });

  static const MBProductMedia empty = MBProductMedia(id: '');

  MBProductMedia copyWith({
    String? id,
    String? url,
    String? storagePath,
    String? originalUrl,
    String? originalStoragePath,
    String? fullUrl,
    String? fullStoragePath,
    String? cardUrl,
    String? cardStoragePath,
    String? thumbUrl,
    String? thumbStoragePath,
    String? tinyUrl,
    String? tinyStoragePath,
    String? type,
    String? role,
    String? labelEn,
    String? labelBn,
    String? altEn,
    String? altBn,
    int? sortOrder,
    bool? isPrimary,
    bool? isEnabled,
    String? fitMode,
    int? cropAspectRatioX,
    bool clearCropAspectRatioX = false,
    int? cropAspectRatioY,
    bool clearCropAspectRatioY = false,
    int? cropWidth,
    bool clearCropWidth = false,
    int? cropHeight,
    bool clearCropHeight = false,
    int? cropSizeBytes,
    bool clearCropSizeBytes = false,
    double? cropZoomScale,
    bool clearCropZoomScale = false,
    double? focalPointX,
    bool clearFocalPointX = false,
    double? focalPointY,
    bool clearFocalPointY = false,
    int? width,
    bool clearWidth = false,
    int? height,
    bool clearHeight = false,
    int? sizeBytes,
    bool clearSizeBytes = false,
    int? originalWidth,
    bool clearOriginalWidth = false,
    int? originalHeight,
    bool clearOriginalHeight = false,
    int? originalSizeBytes,
    bool clearOriginalSizeBytes = false,
    int? fullWidth,
    bool clearFullWidth = false,
    int? fullHeight,
    bool clearFullHeight = false,
    int? fullSizeBytes,
    bool clearFullSizeBytes = false,
    int? cardWidth,
    bool clearCardWidth = false,
    int? cardHeight,
    bool clearCardHeight = false,
    int? cardSizeBytes,
    bool clearCardSizeBytes = false,
    int? thumbWidth,
    bool clearThumbWidth = false,
    int? thumbHeight,
    bool clearThumbHeight = false,
    int? thumbSizeBytes,
    bool clearThumbSizeBytes = false,
    int? tinyWidth,
    bool clearTinyWidth = false,
    int? tinyHeight,
    bool clearTinyHeight = false,
    int? tinySizeBytes,
    bool clearTinySizeBytes = false,
    Uint8List? pendingOriginalBytes,
    bool clearPendingOriginalBytes = false,
    Uint8List? pendingFullBytes,
    bool clearPendingFullBytes = false,
    Uint8List? pendingCardBytes,
    bool clearPendingCardBytes = false,
    Uint8List? pendingThumbBytes,
    bool clearPendingThumbBytes = false,
    Uint8List? pendingTinyBytes,
    bool clearPendingTinyBytes = false,
    String? pendingOriginalFileName,
    String? pendingBaseName,
    String? pendingMimeType,
    bool clearPendingUpload = false,
    DateTime? createdAt,
    bool clearCreatedAt = false,
    DateTime? updatedAt,
    bool clearUpdatedAt = false,
  }) {
    return MBProductMedia(
      id: id ?? this.id,
      url: url ?? this.url,
      storagePath: storagePath ?? this.storagePath,
      originalUrl: originalUrl ?? this.originalUrl,
      originalStoragePath: originalStoragePath ?? this.originalStoragePath,
      fullUrl: fullUrl ?? this.fullUrl,
      fullStoragePath: fullStoragePath ?? this.fullStoragePath,
      cardUrl: cardUrl ?? this.cardUrl,
      cardStoragePath: cardStoragePath ?? this.cardStoragePath,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      thumbStoragePath: thumbStoragePath ?? this.thumbStoragePath,
      tinyUrl: tinyUrl ?? this.tinyUrl,
      tinyStoragePath: tinyStoragePath ?? this.tinyStoragePath,
      type: type ?? this.type,
      role: role ?? this.role,
      labelEn: labelEn ?? this.labelEn,
      labelBn: labelBn ?? this.labelBn,
      altEn: altEn ?? this.altEn,
      altBn: altBn ?? this.altBn,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      isEnabled: isEnabled ?? this.isEnabled,
      fitMode: fitMode ?? this.fitMode,
      cropAspectRatioX: clearCropAspectRatioX
          ? null
          : (cropAspectRatioX ?? this.cropAspectRatioX),
      cropAspectRatioY: clearCropAspectRatioY
          ? null
          : (cropAspectRatioY ?? this.cropAspectRatioY),
      cropWidth: clearCropWidth ? null : (cropWidth ?? this.cropWidth),
      cropHeight: clearCropHeight ? null : (cropHeight ?? this.cropHeight),
      cropSizeBytes:
          clearCropSizeBytes ? null : (cropSizeBytes ?? this.cropSizeBytes),
      cropZoomScale:
          clearCropZoomScale ? null : (cropZoomScale ?? this.cropZoomScale),
      focalPointX: clearFocalPointX ? null : (focalPointX ?? this.focalPointX),
      focalPointY: clearFocalPointY ? null : (focalPointY ?? this.focalPointY),
      width: clearWidth ? null : (width ?? this.width),
      height: clearHeight ? null : (height ?? this.height),
      sizeBytes: clearSizeBytes ? null : (sizeBytes ?? this.sizeBytes),
      originalWidth:
          clearOriginalWidth ? null : (originalWidth ?? this.originalWidth),
      originalHeight:
          clearOriginalHeight ? null : (originalHeight ?? this.originalHeight),
      originalSizeBytes: clearOriginalSizeBytes
          ? null
          : (originalSizeBytes ?? this.originalSizeBytes),
      fullWidth: clearFullWidth ? null : (fullWidth ?? this.fullWidth),
      fullHeight: clearFullHeight ? null : (fullHeight ?? this.fullHeight),
      fullSizeBytes:
          clearFullSizeBytes ? null : (fullSizeBytes ?? this.fullSizeBytes),
      cardWidth: clearCardWidth ? null : (cardWidth ?? this.cardWidth),
      cardHeight: clearCardHeight ? null : (cardHeight ?? this.cardHeight),
      cardSizeBytes:
          clearCardSizeBytes ? null : (cardSizeBytes ?? this.cardSizeBytes),
      thumbWidth: clearThumbWidth ? null : (thumbWidth ?? this.thumbWidth),
      thumbHeight: clearThumbHeight ? null : (thumbHeight ?? this.thumbHeight),
      thumbSizeBytes:
          clearThumbSizeBytes ? null : (thumbSizeBytes ?? this.thumbSizeBytes),
      tinyWidth: clearTinyWidth ? null : (tinyWidth ?? this.tinyWidth),
      tinyHeight: clearTinyHeight ? null : (tinyHeight ?? this.tinyHeight),
      tinySizeBytes:
          clearTinySizeBytes ? null : (tinySizeBytes ?? this.tinySizeBytes),
      pendingOriginalBytes: clearPendingUpload || clearPendingOriginalBytes
          ? null
          : (pendingOriginalBytes ?? this.pendingOriginalBytes),
      pendingFullBytes: clearPendingUpload || clearPendingFullBytes
          ? null
          : (pendingFullBytes ?? this.pendingFullBytes),
      pendingCardBytes: clearPendingUpload || clearPendingCardBytes
          ? null
          : (pendingCardBytes ?? this.pendingCardBytes),
      pendingThumbBytes: clearPendingUpload || clearPendingThumbBytes
          ? null
          : (pendingThumbBytes ?? this.pendingThumbBytes),
      pendingTinyBytes: clearPendingUpload || clearPendingTinyBytes
          ? null
          : (pendingTinyBytes ?? this.pendingTinyBytes),
      pendingOriginalFileName: clearPendingUpload
          ? ''
          : (pendingOriginalFileName ?? this.pendingOriginalFileName),
      pendingBaseName:
          clearPendingUpload ? '' : (pendingBaseName ?? this.pendingBaseName),
      pendingMimeType: clearPendingUpload
          ? 'image/jpeg'
          : (pendingMimeType ?? this.pendingMimeType),
      createdAt: clearCreatedAt ? null : (createdAt ?? this.createdAt),
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isThumbnail => role == 'thumbnail';
  bool get isGallery => role == 'gallery';

  bool get hasPendingUpload =>
      pendingOriginalBytes != null &&
      pendingFullBytes != null &&
      pendingCardBytes != null &&
      pendingThumbBytes != null &&
      pendingTinyBytes != null;

  bool get hasPendingCardCrop => pendingCardBytes != null;

  int get pendingTotalByteLength =>
      (pendingOriginalBytes?.lengthInBytes ?? 0) +
      (pendingFullBytes?.lengthInBytes ?? 0) +
      (pendingCardBytes?.lengthInBytes ?? 0) +
      (pendingThumbBytes?.lengthInBytes ?? 0) +
      (pendingTinyBytes?.lengthInBytes ?? 0);

  String get effectiveOriginalUrl {
    if (originalUrl.trim().isNotEmpty) return originalUrl.trim();
    return effectiveFullUrl;
  }

  String get effectiveFullUrl {
    if (fullUrl.trim().isNotEmpty) return fullUrl.trim();
    if (url.trim().isNotEmpty) return url.trim();
    if (cardUrl.trim().isNotEmpty) return cardUrl.trim();
    if (thumbUrl.trim().isNotEmpty) return thumbUrl.trim();
    if (originalUrl.trim().isNotEmpty) return originalUrl.trim();
    return '';
  }

  String get effectiveCardUrl {
    if (cardUrl.trim().isNotEmpty) return cardUrl.trim();
    return effectiveFullUrl;
  }

  String get effectiveThumbUrl {
    if (thumbUrl.trim().isNotEmpty) return thumbUrl.trim();
    if (isThumbnail && url.trim().isNotEmpty) return url.trim();
    return effectiveCardUrl;
  }

  String get effectiveTinyUrl {
    if (tinyUrl.trim().isNotEmpty) return tinyUrl.trim();
    return effectiveThumbUrl;
  }

  String get effectiveOriginalStoragePath {
    if (originalStoragePath.trim().isNotEmpty) {
      return originalStoragePath.trim();
    }
    return effectiveFullStoragePath;
  }

  String get effectiveFullStoragePath {
    if (fullStoragePath.trim().isNotEmpty) return fullStoragePath.trim();
    if (storagePath.trim().isNotEmpty) return storagePath.trim();
    if (cardStoragePath.trim().isNotEmpty) return cardStoragePath.trim();
    if (thumbStoragePath.trim().isNotEmpty) return thumbStoragePath.trim();
    if (originalStoragePath.trim().isNotEmpty) return originalStoragePath.trim();
    return '';
  }

  String get effectiveCardStoragePath {
    if (cardStoragePath.trim().isNotEmpty) return cardStoragePath.trim();
    return effectiveFullStoragePath;
  }

  String get effectiveThumbStoragePath {
    if (thumbStoragePath.trim().isNotEmpty) return thumbStoragePath.trim();
    if (isThumbnail && storagePath.trim().isNotEmpty) return storagePath.trim();
    return effectiveCardStoragePath;
  }

  String get effectiveTinyStoragePath {
    if (tinyStoragePath.trim().isNotEmpty) return tinyStoragePath.trim();
    return effectiveThumbStoragePath;
  }

  int? get effectiveOriginalWidth => originalWidth ?? effectiveFullWidth;
  int? get effectiveOriginalHeight => originalHeight ?? effectiveFullHeight;
  int? get effectiveOriginalSizeBytes =>
      originalSizeBytes ?? effectiveFullSizeBytes;

  int? get effectiveFullWidth => fullWidth ?? width ?? originalWidth;
  int? get effectiveFullHeight => fullHeight ?? height ?? originalHeight;
  int? get effectiveFullSizeBytes =>
      fullSizeBytes ?? sizeBytes ?? originalSizeBytes;

  int? get effectiveCardWidth => cardWidth ?? effectiveFullWidth;
  int? get effectiveCardHeight => cardHeight ?? effectiveFullHeight;
  int? get effectiveCardSizeBytes => cardSizeBytes ?? effectiveFullSizeBytes;

  int? get effectiveThumbWidth => thumbWidth ?? effectiveCardWidth;
  int? get effectiveThumbHeight => thumbHeight ?? effectiveCardHeight;
  int? get effectiveThumbSizeBytes => thumbSizeBytes ?? effectiveCardSizeBytes;

  int? get effectiveTinyWidth => tinyWidth ?? effectiveThumbWidth;
  int? get effectiveTinyHeight => tinyHeight ?? effectiveThumbHeight;
  int? get effectiveTinySizeBytes => tinySizeBytes ?? effectiveThumbSizeBytes;

  String get previewUrl => effectiveThumbUrl;
  String get displayUrl => effectiveFullUrl;

  bool get hasUrl => displayUrl.isNotEmpty;
  bool get hasSeparateThumbnail =>
      thumbUrl.trim().isNotEmpty && effectiveThumbUrl != effectiveFullUrl;
  bool get hasCardImage => cardUrl.trim().isNotEmpty;
  bool get hasTinyImage => tinyUrl.trim().isNotEmpty;
  bool get hasOriginalSource => originalUrl.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url.isNotEmpty ? url : effectiveFullUrl,
      'storagePath':
          storagePath.isNotEmpty ? storagePath : effectiveFullStoragePath,
      'originalUrl': originalUrl.isNotEmpty ? originalUrl : '',
      'originalStoragePath':
          originalStoragePath.isNotEmpty ? originalStoragePath : '',
      'fullUrl': fullUrl.isNotEmpty ? fullUrl : effectiveFullUrl,
      'fullStoragePath':
          fullStoragePath.isNotEmpty ? fullStoragePath : effectiveFullStoragePath,
      'cardUrl': cardUrl.isNotEmpty ? cardUrl : '',
      'cardStoragePath': cardStoragePath.isNotEmpty ? cardStoragePath : '',
      'thumbUrl': thumbUrl.isNotEmpty ? thumbUrl : '',
      'thumbStoragePath': thumbStoragePath.isNotEmpty ? thumbStoragePath : '',
      'tinyUrl': tinyUrl.isNotEmpty ? tinyUrl : '',
      'tinyStoragePath': tinyStoragePath.isNotEmpty ? tinyStoragePath : '',
      'type': type,
      'role': role,
      'labelEn': labelEn,
      'labelBn': labelBn,
      'altEn': altEn,
      'altBn': altBn,
      'sortOrder': sortOrder,
      'isPrimary': isPrimary,
      'isEnabled': isEnabled,
      'fitMode': fitMode,
      'cropAspectRatioX': cropAspectRatioX,
      'cropAspectRatioY': cropAspectRatioY,
      'cropWidth': cropWidth,
      'cropHeight': cropHeight,
      'cropSizeBytes': cropSizeBytes,
      'cropZoomScale': cropZoomScale,
      'focalPointX': focalPointX,
      'focalPointY': focalPointY,
      'width': width ?? effectiveFullWidth,
      'height': height ?? effectiveFullHeight,
      'sizeBytes': sizeBytes ?? effectiveFullSizeBytes,
      'originalWidth': originalWidth,
      'originalHeight': originalHeight,
      'originalSizeBytes': originalSizeBytes,
      'fullWidth': fullWidth ?? effectiveFullWidth,
      'fullHeight': fullHeight ?? effectiveFullHeight,
      'fullSizeBytes': fullSizeBytes ?? effectiveFullSizeBytes,
      'cardWidth': cardWidth,
      'cardHeight': cardHeight,
      'cardSizeBytes': cardSizeBytes,
      'thumbWidth': thumbWidth,
      'thumbHeight': thumbHeight,
      'thumbSizeBytes': thumbSizeBytes,
      'tinyWidth': tinyWidth,
      'tinyHeight': tinyHeight,
      'tinySizeBytes': tinySizeBytes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBProductMedia.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    final legacyUrl = _asString(map['url']);
    final legacyStoragePath = _asString(map['storagePath']);
    final parsedOriginalUrl = _asString(map['originalUrl']);
    final parsedFullUrl = _asString(map['fullUrl']);
    final parsedCardUrl = _asString(map['cardUrl']);
    final parsedThumbUrl = _asString(map['thumbUrl']);
    final parsedTinyUrl = _asString(map['tinyUrl']);
    final parsedOriginalStoragePath = _asString(map['originalStoragePath']);
    final parsedFullStoragePath = _asString(map['fullStoragePath']);
    final parsedCardStoragePath = _asString(map['cardStoragePath']);
    final parsedThumbStoragePath = _asString(map['thumbStoragePath']);
    final parsedTinyStoragePath = _asString(map['tinyStoragePath']);

    return MBProductMedia(
      id: _asString(map['id']),
      url: legacyUrl.isNotEmpty ? legacyUrl : parsedFullUrl,
      storagePath: legacyStoragePath.isNotEmpty
          ? legacyStoragePath
          : parsedFullStoragePath,
      originalUrl: parsedOriginalUrl,
      originalStoragePath: parsedOriginalStoragePath,
      fullUrl: parsedFullUrl.isNotEmpty ? parsedFullUrl : legacyUrl,
      fullStoragePath: parsedFullStoragePath.isNotEmpty
          ? parsedFullStoragePath
          : legacyStoragePath,
      cardUrl: parsedCardUrl,
      cardStoragePath: parsedCardStoragePath,
      thumbUrl: parsedThumbUrl,
      thumbStoragePath: parsedThumbStoragePath,
      tinyUrl: parsedTinyUrl,
      tinyStoragePath: parsedTinyStoragePath,
      type: _asString(map['type'], fallback: 'image'),
      role: _asString(map['role'], fallback: 'gallery'),
      labelEn: _asString(map['labelEn']),
      labelBn: _asString(map['labelBn']),
      altEn: _asString(map['altEn']),
      altBn: _asString(map['altBn']),
      sortOrder: _asInt(map['sortOrder'], fallback: 0),
      isPrimary: _asBool(map['isPrimary'], fallback: false),
      isEnabled: _asBool(map['isEnabled'], fallback: true),
      fitMode: _asString(map['fitMode'], fallback: 'contain'),
      cropAspectRatioX: _asNullableInt(map['cropAspectRatioX']),
      cropAspectRatioY: _asNullableInt(map['cropAspectRatioY']),
      cropWidth: _asNullableInt(map['cropWidth']),
      cropHeight: _asNullableInt(map['cropHeight']),
      cropSizeBytes: _asNullableInt(map['cropSizeBytes']),
      cropZoomScale: _asNullableDouble(map['cropZoomScale']),
      focalPointX: _asNullableDouble(map['focalPointX']),
      focalPointY: _asNullableDouble(map['focalPointY']),
      width: _asNullableInt(map['width']),
      height: _asNullableInt(map['height']),
      sizeBytes: _asNullableInt(map['sizeBytes']),
      originalWidth: _asNullableInt(map['originalWidth']),
      originalHeight: _asNullableInt(map['originalHeight']),
      originalSizeBytes: _asNullableInt(map['originalSizeBytes']),
      fullWidth: _asNullableInt(map['fullWidth']) ?? _asNullableInt(map['width']),
      fullHeight:
          _asNullableInt(map['fullHeight']) ?? _asNullableInt(map['height']),
      fullSizeBytes:
          _asNullableInt(map['fullSizeBytes']) ?? _asNullableInt(map['sizeBytes']),
      cardWidth: _asNullableInt(map['cardWidth']),
      cardHeight: _asNullableInt(map['cardHeight']),
      cardSizeBytes: _asNullableInt(map['cardSizeBytes']),
      thumbWidth: _asNullableInt(map['thumbWidth']),
      thumbHeight: _asNullableInt(map['thumbHeight']),
      thumbSizeBytes: _asNullableInt(map['thumbSizeBytes']),
      tinyWidth: _asNullableInt(map['tinyWidth']),
      tinyHeight: _asNullableInt(map['tinyHeight']),
      tinySizeBytes: _asNullableInt(map['tinySizeBytes']),
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

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
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
