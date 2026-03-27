import 'dart:convert';

// MB Category Model
// -----------------
// Bilingual product category model.
// Supports home visibility, featured state, sorting, and future subcategories.

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
    this.descriptionEn = '',
    this.descriptionBn = '',
    this.imageUrl = '',
    this.iconUrl = '',
    this.slug = '',
    this.parentId,
    this.isFeatured = false,
    this.showOnHome = false,
    this.isActive = true,
    this.sortOrder = 0,
    this.productsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  static const MBCategory empty = MBCategory(
    id: '',
    nameEn: '',
    nameBn: '',
  );

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
    bool clearParentId = false,
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
      parentId: clearParentId ? null : (parentId ?? this.parentId),
      isFeatured: isFeatured ?? this.isFeatured,
      showOnHome: showOnHome ?? this.showOnHome,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      productsCount: productsCount ?? this.productsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBCategory.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

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
      sortOrder: (map['sortOrder'] ?? 0) is int
          ? (map['sortOrder'] ?? 0) as int
          : int.tryParse((map['sortOrder'] ?? '0').toString()) ?? 0,
      productsCount: (map['productsCount'] ?? 0) is int
          ? (map['productsCount'] ?? 0) as int
          : int.tryParse((map['productsCount'] ?? '0').toString()) ?? 0,
      createdAt: map['createdAt'] == null
          ? null
          : DateTime.tryParse(map['createdAt'].toString()),
      updatedAt: map['updatedAt'] == null
          ? null
          : DateTime.tryParse(map['updatedAt'].toString()),
    );
  }

  // Legacy compatibility from old CategoryModelV2
  factory MBCategory.fromLegacyMap(Map<String, dynamic>? map, {String? documentId}) {
    if (map == null) return empty;

    return MBCategory(
      id: documentId ?? (map['Id'] ?? '').toString(),
      nameEn: (map['Name'] ?? '').toString(),
      nameBn: '',
      imageUrl: (map['Image'] ?? '').toString(),
      iconUrl: (map['Icon'] ?? '').toString(),
      isFeatured: map['IsFeatured'] ?? false,
      productsCount: (map['ProductsCount'] ?? 0) is int
          ? (map['ProductsCount'] ?? 0) as int
          : int.tryParse((map['ProductsCount'] ?? '0').toString()) ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBCategory.fromJson(String source) =>
      MBCategory.fromMap(json.decode(source) as Map<String, dynamic>);
}












