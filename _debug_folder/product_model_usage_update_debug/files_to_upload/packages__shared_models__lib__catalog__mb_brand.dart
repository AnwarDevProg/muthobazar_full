import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

// MB Brand Model
// ----------------
// Bilingual brand model for product filtering and home presentation.
// Upgraded to match the category image workflow style.

class MBBrand {
  final String id;
  final String nameEn;
  final String nameBn;
  final String descriptionEn;
  final String descriptionBn;

  // Main image / thumb fields aligned with category workflow
  final String imageUrl;
  final String logoUrl;
  final String imagePath;
  final String thumbPath;

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
    this.imageUrl = '',
    this.logoUrl = '',
    this.imagePath = '',
    this.thumbPath = '',
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
    String? imageUrl,
    String? logoUrl,
    String? imagePath,
    String? thumbPath,
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
      imageUrl: imageUrl ?? this.imageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      imagePath: imagePath ?? this.imagePath,
      thumbPath: thumbPath ?? this.thumbPath,
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
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'imagePath': imagePath,
      'thumbPath': thumbPath,
      'slug': slug,
      'isFeatured': isFeatured,
      'showOnHome': showOnHome,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'productsCount': productsCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory MBBrand.fromMap(Map<String, dynamic>? map, {String? documentId}) {
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
        final lower = value.toLowerCase().trim();
        if (lower == 'true') return true;
        if (lower == 'false') return false;
      }
      return defaultValue;
    }

    return MBBrand(
      id: documentId ?? (map['id'] ?? '').toString(),
      nameEn: (map['nameEn'] ?? '').toString(),
      nameBn: (map['nameBn'] ?? '').toString(),
      descriptionEn: (map['descriptionEn'] ?? '').toString(),
      descriptionBn: (map['descriptionBn'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      logoUrl: (map['logoUrl'] ?? map['thumbPath'] ?? '').toString(),
      imagePath: (map['imagePath'] ?? '').toString(),
      thumbPath: (map['thumbPath'] ?? '').toString(),
      slug: (map['slug'] ?? '').toString(),
      isFeatured: parseBool(map['isFeatured']),
      showOnHome: parseBool(map['showOnHome']),
      isActive: parseBool(map['isActive'], defaultValue: true),
      sortOrder: parseInt(map['sortOrder']),
      productsCount: parseInt(map['productsCount']),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  factory MBBrand.fromLegacyMap(
      Map<String, dynamic>? map, {
        String? documentId,
      }) {
    if (map == null) return empty;

    return MBBrand(
      id: documentId ?? (map['Id'] ?? '').toString(),
      nameEn: (map['Name'] ?? '').toString(),
      nameBn: '',
      imageUrl: (map['Image'] ?? '').toString(),
      logoUrl: (map['Image'] ?? '').toString(),
      imagePath: '',
      thumbPath: '',
      slug: (map['Slug'] ?? '').toString(),
      isFeatured: map['IsFeatured'] ?? false,
      showOnHome: map['ShowOnHome'] ?? false,
      isActive: map['IsActive'] ?? true,
      sortOrder: (map['SortOrder'] ?? 0) is int
          ? (map['SortOrder'] ?? 0) as int
          : int.tryParse((map['SortOrder'] ?? '0').toString()) ?? 0,
      productsCount: (map['ProductsCount'] ?? 0) is int
          ? (map['ProductsCount'] ?? 0) as int
          : int.tryParse((map['ProductsCount'] ?? '0').toString()) ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBBrand.fromJson(String source) =>
      MBBrand.fromMap(json.decode(source) as Map<String, dynamic>);
}