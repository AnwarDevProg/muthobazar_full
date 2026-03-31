import 'package:cloud_firestore/cloud_firestore.dart';

class MBCategory {
  final String id;
  final String nameEn;
  final String nameBn;
  final String descriptionEn;
  final String descriptionBn;
  final String imageUrl;
  final String iconUrl;
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

  // 🔥 FIXED PARSER
  factory MBCategory.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is String) {
        return DateTime.tryParse(value);
      }

      return null;
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return MBCategory(
      id: (map['id'] ?? '').toString(),
      nameEn: (map['nameEn'] ?? '').toString(),
      nameBn: (map['nameBn'] ?? '').toString(),
      descriptionEn: (map['descriptionEn'] ?? '').toString(),
      descriptionBn: (map['descriptionBn'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      iconUrl: (map['iconUrl'] ?? '').toString(),
      slug: (map['slug'] ?? '').toString(),
      parentId: map['parentId']?.toString(),
      isFeatured: map['isFeatured'] ?? false,
      showOnHome: map['showOnHome'] ?? false,
      isActive: map['isActive'] ?? true,
      sortOrder: parseInt(map['sortOrder']),
      productsCount: parseInt(map['productsCount']),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
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