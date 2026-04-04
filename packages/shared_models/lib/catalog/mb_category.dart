import 'package:cloud_firestore/cloud_firestore.dart';

class MBCategory {
  final String id;
  final String nameEn;
  final String nameBn;
  final String descriptionEn;
  final String descriptionBn;

  final String imageUrl;
  final String iconUrl;

  // 🔥 NEW (IMPORTANT)
  final String imagePath;
  final String thumbPath;

  final String slug;
  final String? parentId;
  final bool isFeatured;
  final bool showOnHome;
  final bool isActive;
  final int sortOrder;
  final int productsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MBCategory({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.imageUrl,
    required this.iconUrl,
    required this.imagePath,
    required this.thumbPath,
    required this.slug,
    this.parentId,
    required this.isFeatured,
    required this.showOnHome,
    required this.isActive,
    required this.sortOrder,
    required this.productsCount,
    this.createdAt,
    this.updatedAt,
  });

  static const empty = MBCategory(
    id: '',
    nameEn: '',
    nameBn: '',
    descriptionEn: '',
    descriptionBn: '',
    imageUrl: '',
    iconUrl: '',
    imagePath: '',
    thumbPath: '',
    slug: '',
    parentId: null,
    isFeatured: false,
    showOnHome: false,
    isActive: true,
    sortOrder: 0,
    productsCount: 0,
    createdAt: null,
    updatedAt: null,
  );

  factory MBCategory.fromMap(Map<String, dynamic>? map,
      {String? documentId}) {
    if (map == null) return empty;

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    bool parseBool(dynamic value, {bool defaultValue = false}) {
      if (value is bool) return value;
      if (value is String) {
        final v = value.toLowerCase();
        if (v == 'true') return true;
        if (v == 'false') return false;
      }
      return defaultValue;
    }

    return MBCategory(
      id: documentId ?? (map['id'] ?? '').toString(),
      nameEn: (map['nameEn'] ?? '').toString(),
      nameBn: (map['nameBn'] ?? '').toString(),
      descriptionEn: (map['descriptionEn'] ?? '').toString(),
      descriptionBn: (map['descriptionBn'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      iconUrl: (map['iconUrl'] ?? '').toString(),

      // 🔥 NEW
      imagePath: (map['imagePath'] ?? '').toString(),
      thumbPath: (map['thumbPath'] ?? '').toString(),

      slug: (map['slug'] ?? '').toString(),
      parentId: map['parentId']?.toString(),
      isFeatured: parseBool(map['isFeatured']),
      showOnHome: parseBool(map['showOnHome']),
      isActive: parseBool(map['isActive'], defaultValue: true),
      sortOrder: parseInt(map['sortOrder']),
      productsCount: parseInt(map['productsCount']),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  factory MBCategory.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return MBCategory.fromMap(doc.data(), documentId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameBn': nameBn,
      'descriptionEn': descriptionEn,
      'descriptionBn': descriptionBn,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,

      // 🔥 NEW
      'imagePath': imagePath,
      'thumbPath': thumbPath,

      'slug': slug,
      'parentId': parentId,
      'isFeatured': isFeatured,
      'showOnHome': showOnHome,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'productsCount': productsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  MBCategory copyWith({
    String? id,
    String? nameEn,
    String? nameBn,
    String? descriptionEn,
    String? descriptionBn,
    String? imageUrl,
    String? iconUrl,
    String? imagePath,
    String? thumbPath,
    String? slug,
    String? parentId,
    bool? isFeatured,
    bool? showOnHome,
    bool? isActive,
    int? sortOrder,
    int? productsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MBCategory(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameBn: nameBn ?? this.nameBn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      imagePath: imagePath ?? this.imagePath,
      thumbPath: thumbPath ?? this.thumbPath,
      slug: slug ?? this.slug,
      parentId: parentId ?? this.parentId,
      isFeatured: isFeatured ?? this.isFeatured,
      showOnHome: showOnHome ?? this.showOnHome,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      productsCount: productsCount ?? this.productsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}