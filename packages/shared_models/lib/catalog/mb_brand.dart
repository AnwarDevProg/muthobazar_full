import 'dart:convert';

// MB Brand Model
// --------------
// Bilingual brand model for product filtering and home presentation.

class MBBrand {
  final String id;
  final String nameEn;
  final String nameBn;
  final String descriptionEn;
  final String descriptionBn;
  final String logoUrl;
  final String slug;
  final bool isFeatured;
  final bool showOnHome;
  final bool isActive;
  final int sortOrder;
  final int productsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MBBrand({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    this.descriptionEn = '',
    this.descriptionBn = '',
    this.logoUrl = '',
    this.slug = '',
    this.isFeatured = false,
    this.showOnHome = false,
    this.isActive = true,
    this.sortOrder = 0,
    this.productsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  static const MBBrand empty = MBBrand(
    id: '',
    nameEn: '',
    nameBn: '',
  );

  MBBrand copyWith({
    String? id,
    String? nameEn,
    String? nameBn,
    String? descriptionEn,
    String? descriptionBn,
    String? logoUrl,
    String? slug,
    bool? isFeatured,
    bool? showOnHome,
    bool? isActive,
    int? sortOrder,
    int? productsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MBBrand(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameBn: nameBn ?? this.nameBn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      logoUrl: logoUrl ?? this.logoUrl,
      slug: slug ?? this.slug,
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
      'logoUrl': logoUrl,
      'slug': slug,
      'isFeatured': isFeatured,
      'showOnHome': showOnHome,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'productsCount': productsCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MBBrand.fromMap(Map<String, dynamic>? map) {
    if (map == null) return empty;

    return MBBrand(
      id: (map['id'] ?? '').toString(),
      nameEn: (map['nameEn'] ?? '').toString(),
      nameBn: (map['nameBn'] ?? '').toString(),
      descriptionEn: (map['descriptionEn'] ?? '').toString(),
      descriptionBn: (map['descriptionBn'] ?? '').toString(),
      logoUrl: (map['logoUrl'] ?? '').toString(),
      slug: (map['slug'] ?? '').toString(),
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

  // Legacy compatibility from old BrandModelV2
  factory MBBrand.fromLegacyMap(Map<String, dynamic>? map, {String? documentId}) {
    if (map == null) return empty;

    return MBBrand(
      id: documentId ?? (map['Id'] ?? '').toString(),
      nameEn: (map['Name'] ?? '').toString(),
      nameBn: '',
      logoUrl: (map['Image'] ?? '').toString(),
      isFeatured: map['IsFeatured'] ?? false,
      productsCount: (map['ProductsCount'] ?? 0) is int
          ? (map['ProductsCount'] ?? 0) as int
          : int.tryParse((map['ProductsCount'] ?? '0').toString()) ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBBrand.fromJson(String source) =>
      MBBrand.fromMap(json.decode(source) as Map<String, dynamic>);
}












