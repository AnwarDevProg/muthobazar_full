import 'dart:convert';

// MB Product Variation Model
// --------------------------
// Defines a concrete sellable variation of a product.
//
// Examples:
// - Size M / Color Red
// - 500g pack
// - Boneless cut
//
// Upgrade notes:
// - Keeps legacy `imageUrl` behavior for old data and old UI code.
// - Adds separate thumbnail/full/original image fields for variation preview.
// - Safely reads old Firestore documents that only stored a single image URL.

class MBProductVariation {
  final String id;
  final String sku;
  final String? barcode;
  final String titleEn;
  final String titleBn;

  // Legacy / compatibility image fields.
  final String imageUrl;
  final String imageStoragePath;

  // New variation image fields.
  final String fullImageUrl;
  final String fullImageStoragePath;
  final String thumbImageUrl;
  final String thumbImageStoragePath;
  final String originalImageUrl;
  final String originalImageStoragePath;

  final int? imageWidth;
  final int? imageHeight;
  final int? imageSizeBytes;

  final int? fullImageWidth;
  final int? fullImageHeight;
  final int? fullImageSizeBytes;

  final int? thumbImageWidth;
  final int? thumbImageHeight;
  final int? thumbImageSizeBytes;

  final int? originalImageWidth;
  final int? originalImageHeight;
  final int? originalImageSizeBytes;

  final String descriptionEn;
  final String descriptionBn;
  final double price;
  final double? salePrice;
  final double? costPrice;
  final int stockQty;
  final int reservedQty;
  final bool trackInventory;
  final bool allowBackorder;
  final Map<String, String> attributeValues;
  final int sortOrder;
  final bool isDefault;
  final bool isEnabled;

  const MBProductVariation({
    required this.id,
    this.sku = '',
    this.barcode,
    this.titleEn = '',
    this.titleBn = '',
    this.imageUrl = '',
    this.imageStoragePath = '',
    this.fullImageUrl = '',
    this.fullImageStoragePath = '',
    this.thumbImageUrl = '',
    this.thumbImageStoragePath = '',
    this.originalImageUrl = '',
    this.originalImageStoragePath = '',
    this.imageWidth,
    this.imageHeight,
    this.imageSizeBytes,
    this.fullImageWidth,
    this.fullImageHeight,
    this.fullImageSizeBytes,
    this.thumbImageWidth,
    this.thumbImageHeight,
    this.thumbImageSizeBytes,
    this.originalImageWidth,
    this.originalImageHeight,
    this.originalImageSizeBytes,
    this.descriptionEn = '',
    this.descriptionBn = '',
    this.price = 0.0,
    this.salePrice,
    this.costPrice,
    this.stockQty = 0,
    this.reservedQty = 0,
    this.trackInventory = true,
    this.allowBackorder = false,
    this.attributeValues = const {},
    this.sortOrder = 0,
    this.isDefault = false,
    this.isEnabled = true,
  });

  static const MBProductVariation empty = MBProductVariation(id: '');

  MBProductVariation copyWith({
    String? id,
    String? sku,
    String? barcode,
    bool clearBarcode = false,
    String? titleEn,
    String? titleBn,
    String? imageUrl,
    String? imageStoragePath,
    String? fullImageUrl,
    String? fullImageStoragePath,
    String? thumbImageUrl,
    String? thumbImageStoragePath,
    String? originalImageUrl,
    String? originalImageStoragePath,
    int? imageWidth,
    bool clearImageWidth = false,
    int? imageHeight,
    bool clearImageHeight = false,
    int? imageSizeBytes,
    bool clearImageSizeBytes = false,
    int? fullImageWidth,
    bool clearFullImageWidth = false,
    int? fullImageHeight,
    bool clearFullImageHeight = false,
    int? fullImageSizeBytes,
    bool clearFullImageSizeBytes = false,
    int? thumbImageWidth,
    bool clearThumbImageWidth = false,
    int? thumbImageHeight,
    bool clearThumbImageHeight = false,
    int? thumbImageSizeBytes,
    bool clearThumbImageSizeBytes = false,
    int? originalImageWidth,
    bool clearOriginalImageWidth = false,
    int? originalImageHeight,
    bool clearOriginalImageHeight = false,
    int? originalImageSizeBytes,
    bool clearOriginalImageSizeBytes = false,
    String? descriptionEn,
    String? descriptionBn,
    double? price,
    double? salePrice,
    bool clearSalePrice = false,
    double? costPrice,
    bool clearCostPrice = false,
    int? stockQty,
    int? reservedQty,
    bool? trackInventory,
    bool? allowBackorder,
    Map<String, String>? attributeValues,
    int? sortOrder,
    bool? isDefault,
    bool? isEnabled,
  }) {
    return MBProductVariation(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      barcode: clearBarcode ? null : (barcode ?? this.barcode),
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      imageUrl: imageUrl ?? this.imageUrl,
      imageStoragePath: imageStoragePath ?? this.imageStoragePath,
      fullImageUrl: fullImageUrl ?? this.fullImageUrl,
      fullImageStoragePath: fullImageStoragePath ?? this.fullImageStoragePath,
      thumbImageUrl: thumbImageUrl ?? this.thumbImageUrl,
      thumbImageStoragePath:
      thumbImageStoragePath ?? this.thumbImageStoragePath,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      originalImageStoragePath:
      originalImageStoragePath ?? this.originalImageStoragePath,
      imageWidth: clearImageWidth ? null : (imageWidth ?? this.imageWidth),
      imageHeight: clearImageHeight ? null : (imageHeight ?? this.imageHeight),
      imageSizeBytes: clearImageSizeBytes
          ? null
          : (imageSizeBytes ?? this.imageSizeBytes),
      fullImageWidth: clearFullImageWidth
          ? null
          : (fullImageWidth ?? this.fullImageWidth),
      fullImageHeight: clearFullImageHeight
          ? null
          : (fullImageHeight ?? this.fullImageHeight),
      fullImageSizeBytes: clearFullImageSizeBytes
          ? null
          : (fullImageSizeBytes ?? this.fullImageSizeBytes),
      thumbImageWidth: clearThumbImageWidth
          ? null
          : (thumbImageWidth ?? this.thumbImageWidth),
      thumbImageHeight: clearThumbImageHeight
          ? null
          : (thumbImageHeight ?? this.thumbImageHeight),
      thumbImageSizeBytes: clearThumbImageSizeBytes
          ? null
          : (thumbImageSizeBytes ?? this.thumbImageSizeBytes),
      originalImageWidth: clearOriginalImageWidth
          ? null
          : (originalImageWidth ?? this.originalImageWidth),
      originalImageHeight: clearOriginalImageHeight
          ? null
          : (originalImageHeight ?? this.originalImageHeight),
      originalImageSizeBytes: clearOriginalImageSizeBytes
          ? null
          : (originalImageSizeBytes ?? this.originalImageSizeBytes),
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      price: price ?? this.price,
      salePrice: clearSalePrice ? null : (salePrice ?? this.salePrice),
      costPrice: clearCostPrice ? null : (costPrice ?? this.costPrice),
      stockQty: stockQty ?? this.stockQty,
      reservedQty: reservedQty ?? this.reservedQty,
      trackInventory: trackInventory ?? this.trackInventory,
      allowBackorder: allowBackorder ?? this.allowBackorder,
      attributeValues: attributeValues ?? this.attributeValues,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  bool get hasDiscount => salePrice != null && salePrice! > 0 && salePrice! < price;

  double get effectivePrice => hasDiscount ? salePrice! : price;

  int get discountPercent {
    if (!hasDiscount || price <= 0) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }

  int get availableStock {
    final value = stockQty - reservedQty;
    return value < 0 ? 0 : value;
  }

  bool get inStock => allowBackorder || availableStock > 0;

  String get effectiveFullImageUrl {
    if (fullImageUrl.trim().isNotEmpty) return fullImageUrl.trim();
    if (imageUrl.trim().isNotEmpty) return imageUrl.trim();
    if (originalImageUrl.trim().isNotEmpty) return originalImageUrl.trim();
    return '';
  }

  String get effectiveThumbImageUrl {
    if (thumbImageUrl.trim().isNotEmpty) return thumbImageUrl.trim();
    return effectiveFullImageUrl;
  }

  String get effectiveOriginalImageUrl {
    if (originalImageUrl.trim().isNotEmpty) return originalImageUrl.trim();
    return effectiveFullImageUrl;
  }

  String get effectiveFullImageStoragePath {
    if (fullImageStoragePath.trim().isNotEmpty) {
      return fullImageStoragePath.trim();
    }
    if (imageStoragePath.trim().isNotEmpty) return imageStoragePath.trim();
    if (originalImageStoragePath.trim().isNotEmpty) {
      return originalImageStoragePath.trim();
    }
    return '';
  }

  String get effectiveThumbImageStoragePath {
    if (thumbImageStoragePath.trim().isNotEmpty) {
      return thumbImageStoragePath.trim();
    }
    return effectiveFullImageStoragePath;
  }

  String get effectiveOriginalImageStoragePath {
    if (originalImageStoragePath.trim().isNotEmpty) {
      return originalImageStoragePath.trim();
    }
    return effectiveFullImageStoragePath;
  }

  int? get effectiveFullImageWidth =>
      fullImageWidth ?? imageWidth ?? originalImageWidth;
  int? get effectiveFullImageHeight =>
      fullImageHeight ?? imageHeight ?? originalImageHeight;
  int? get effectiveFullImageSizeBytes =>
      fullImageSizeBytes ?? imageSizeBytes ?? originalImageSizeBytes;

  int? get effectiveThumbImageWidth =>
      thumbImageWidth ?? effectiveFullImageWidth;
  int? get effectiveThumbImageHeight =>
      thumbImageHeight ?? effectiveFullImageHeight;
  int? get effectiveThumbImageSizeBytes =>
      thumbImageSizeBytes ?? effectiveFullImageSizeBytes;

  int? get effectiveOriginalImageWidth =>
      originalImageWidth ?? effectiveFullImageWidth;
  int? get effectiveOriginalImageHeight =>
      originalImageHeight ?? effectiveFullImageHeight;
  int? get effectiveOriginalImageSizeBytes =>
      originalImageSizeBytes ?? effectiveFullImageSizeBytes;

  String get previewImageUrl => effectiveThumbImageUrl;
  String get displayImageUrl => effectiveFullImageUrl;

  bool get hasImage => displayImageUrl.isNotEmpty;
  bool get hasSeparateThumbnail =>
      thumbImageUrl.trim().isNotEmpty && previewImageUrl != displayImageUrl;
  bool get hasOriginalImage => originalImageUrl.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'barcode': barcode,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'imageUrl': imageUrl.isNotEmpty ? imageUrl : effectiveFullImageUrl,
      'imageStoragePath': imageStoragePath.isNotEmpty
          ? imageStoragePath
          : effectiveFullImageStoragePath,
      'fullImageUrl': fullImageUrl.isNotEmpty ? fullImageUrl : effectiveFullImageUrl,
      'fullImageStoragePath': fullImageStoragePath.isNotEmpty
          ? fullImageStoragePath
          : effectiveFullImageStoragePath,
      'thumbImageUrl': thumbImageUrl.isNotEmpty ? thumbImageUrl : '',
      'thumbImageStoragePath':
      thumbImageStoragePath.isNotEmpty ? thumbImageStoragePath : '',
      'originalImageUrl': originalImageUrl.isNotEmpty ? originalImageUrl : '',
      'originalImageStoragePath':
      originalImageStoragePath.isNotEmpty ? originalImageStoragePath : '',
      'imageWidth': imageWidth ?? effectiveFullImageWidth,
      'imageHeight': imageHeight ?? effectiveFullImageHeight,
      'imageSizeBytes': imageSizeBytes ?? effectiveFullImageSizeBytes,
      'fullImageWidth': fullImageWidth ?? effectiveFullImageWidth,
      'fullImageHeight': fullImageHeight ?? effectiveFullImageHeight,
      'fullImageSizeBytes': fullImageSizeBytes ?? effectiveFullImageSizeBytes,
      'thumbImageWidth': thumbImageWidth,
      'thumbImageHeight': thumbImageHeight,
      'thumbImageSizeBytes': thumbImageSizeBytes,
      'originalImageWidth': originalImageWidth,
      'originalImageHeight': originalImageHeight,
      'originalImageSizeBytes': originalImageSizeBytes,
      'descriptionEn': descriptionEn,
      'descriptionBn': descriptionBn,
      'price': price,
      'salePrice': salePrice,
      'costPrice': costPrice,
      'stockQty': stockQty,
      'reservedQty': reservedQty,
      'trackInventory': trackInventory,
      'allowBackorder': allowBackorder,
      'attributeValues': attributeValues,
      'sortOrder': sortOrder,
      'isDefault': isDefault,
      'isEnabled': isEnabled,
    };
  }

  factory MBProductVariation.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return empty;

    final legacyImageUrl = _asString(map['imageUrl']);
    final legacyImageStoragePath = _asString(map['imageStoragePath']);
    final parsedFullImageUrl = _asString(map['fullImageUrl']);
    final parsedThumbImageUrl = _asString(map['thumbImageUrl']);
    final parsedOriginalImageUrl = _asString(map['originalImageUrl']);
    final parsedFullImageStoragePath = _asString(map['fullImageStoragePath']);
    final parsedThumbImageStoragePath = _asString(map['thumbImageStoragePath']);
    final parsedOriginalImageStoragePath =
    _asString(map['originalImageStoragePath']);

    return MBProductVariation(
      id: _asString(map['id']),
      sku: _asString(map['sku']),
      barcode: map['barcode']?.toString(),
      titleEn: _asString(map['titleEn']),
      titleBn: _asString(map['titleBn']),
      imageUrl: legacyImageUrl.isNotEmpty ? legacyImageUrl : parsedFullImageUrl,
      imageStoragePath: legacyImageStoragePath.isNotEmpty
          ? legacyImageStoragePath
          : parsedFullImageStoragePath,
      fullImageUrl:
      parsedFullImageUrl.isNotEmpty ? parsedFullImageUrl : legacyImageUrl,
      fullImageStoragePath: parsedFullImageStoragePath.isNotEmpty
          ? parsedFullImageStoragePath
          : legacyImageStoragePath,
      thumbImageUrl: parsedThumbImageUrl,
      thumbImageStoragePath: parsedThumbImageStoragePath,
      originalImageUrl: parsedOriginalImageUrl,
      originalImageStoragePath: parsedOriginalImageStoragePath,
      imageWidth: _asNullableInt(map['imageWidth']),
      imageHeight: _asNullableInt(map['imageHeight']),
      imageSizeBytes: _asNullableInt(map['imageSizeBytes']),
      fullImageWidth:
      _asNullableInt(map['fullImageWidth']) ?? _asNullableInt(map['imageWidth']),
      fullImageHeight: _asNullableInt(map['fullImageHeight']) ??
          _asNullableInt(map['imageHeight']),
      fullImageSizeBytes: _asNullableInt(map['fullImageSizeBytes']) ??
          _asNullableInt(map['imageSizeBytes']),
      thumbImageWidth: _asNullableInt(map['thumbImageWidth']),
      thumbImageHeight: _asNullableInt(map['thumbImageHeight']),
      thumbImageSizeBytes: _asNullableInt(map['thumbImageSizeBytes']),
      originalImageWidth: _asNullableInt(map['originalImageWidth']),
      originalImageHeight: _asNullableInt(map['originalImageHeight']),
      originalImageSizeBytes: _asNullableInt(map['originalImageSizeBytes']),
      descriptionEn: _asString(map['descriptionEn']),
      descriptionBn: _asString(map['descriptionBn']),
      price: _asDouble(map['price'], fallback: 0.0),
      salePrice: _asNullableDouble(map['salePrice']),
      costPrice: _asNullableDouble(map['costPrice']),
      stockQty: _asInt(map['stockQty'], fallback: 0),
      reservedQty: _asInt(map['reservedQty'], fallback: 0),
      trackInventory: _asBool(map['trackInventory'], fallback: true),
      allowBackorder: _asBool(map['allowBackorder'], fallback: false),
      attributeValues: _asStringMap(map['attributeValues']),
      sortOrder: _asInt(map['sortOrder'], fallback: 0),
      isDefault: _asBool(map['isDefault'], fallback: false),
      isEnabled: _asBool(map['isEnabled'], fallback: true),
    );
  }

  factory MBProductVariation.fromLegacyMap(Map<dynamic, dynamic>? map) {
    if (map == null) return empty;

    final dynamic rawAttributeValues =
        map['AttributeValues'] ?? map['AttributeValue'] ?? const {};
    final legacyImage = _asString(map['Image']);

    return MBProductVariation(
      id: _asString(map['Id']),
      sku: _asString(map['SKU']),
      barcode: map['Barcode']?.toString(),
      titleEn: _asString(map['Title']),
      titleBn: '',
      imageUrl: legacyImage,
      fullImageUrl: legacyImage,
      descriptionEn: _asString(map['Description']),
      descriptionBn: '',
      price: _asDouble(map['Price'], fallback: 0.0),
      salePrice: _asNullableDouble(map['SalePrice']),
      costPrice: _asNullableDouble(map['CostPrice']),
      stockQty: _asInt(map['Stock'], fallback: 0),
      reservedQty: _asInt(map['ReservedQty'], fallback: 0),
      trackInventory: true,
      allowBackorder: false,
      attributeValues: _asStringMap(rawAttributeValues),
      sortOrder: 0,
      isDefault: false,
      isEnabled: true,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBProductVariation.fromJson(String source) =>
      MBProductVariation.fromMap(json.decode(source) as Map<dynamic, dynamic>);
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final parsed = value.toString().trim();
  return parsed.isEmpty ? fallback : parsed;
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
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

Map<String, String> _asStringMap(dynamic value) {
  if (value is Map) {
    return value.map(
          (key, item) => MapEntry(key.toString(), item?.toString() ?? ''),
    );
  }
  return const {};
}
