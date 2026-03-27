import 'dart:convert';

// MB Home Section Model
// ---------------------
// Dynamic home section renderer configuration for MuthoBazar.

class MBHomeSection {
  final String id;

  final String titleEn;
  final String titleBn;

  final String subtitleEn;
  final String subtitleBn;

  /// hero_banner | category_grid | product_horizontal | product_grid
  /// offer_strip | promo_banner | brand_row
  final String sectionType;

  /// compact | standard | large | card | slider
  final String layoutStyle;

  final List<String> bannerIds;
  final List<String> offerIds;
  final List<String> productIds;
  final List<String> categoryIds;
  final List<String> brandIds;

  /// manual | featured | flash_sale | new_arrival | best_seller
  /// recommended | category | offer | banner
  final String dataSourceType;

  final String? sourceCategoryId;
  final String? sourceBrandId;

  final int itemLimit;

  final bool showViewAll;
  final bool isActive;

  final int sortOrder;

  const MBHomeSection({
    required this.id,
    this.titleEn = '',
    this.titleBn = '',
    this.subtitleEn = '',
    this.subtitleBn = '',
    this.sectionType = 'product_horizontal',
    this.layoutStyle = 'standard',
    this.bannerIds = const [],
    this.offerIds = const [],
    this.productIds = const [],
    this.categoryIds = const [],
    this.brandIds = const [],
    this.dataSourceType = 'manual',
    this.sourceCategoryId,
    this.sourceBrandId,
    this.itemLimit = 10,
    this.showViewAll = true,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory MBHomeSection.empty() => const MBHomeSection(id: '');

  MBHomeSection copyWith({
    String? id,
    String? titleEn,
    String? titleBn,
    String? subtitleEn,
    String? subtitleBn,
    String? sectionType,
    String? layoutStyle,
    List<String>? bannerIds,
    List<String>? offerIds,
    List<String>? productIds,
    List<String>? categoryIds,
    List<String>? brandIds,
    String? dataSourceType,
    String? sourceCategoryId,
    bool clearSourceCategoryId = false,
    String? sourceBrandId,
    bool clearSourceBrandId = false,
    int? itemLimit,
    bool? showViewAll,
    bool? isActive,
    int? sortOrder,
  }) {
    return MBHomeSection(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleBn: titleBn ?? this.titleBn,
      subtitleEn: subtitleEn ?? this.subtitleEn,
      subtitleBn: subtitleBn ?? this.subtitleBn,
      sectionType: sectionType ?? this.sectionType,
      layoutStyle: layoutStyle ?? this.layoutStyle,
      bannerIds: bannerIds ?? this.bannerIds,
      offerIds: offerIds ?? this.offerIds,
      productIds: productIds ?? this.productIds,
      categoryIds: categoryIds ?? this.categoryIds,
      brandIds: brandIds ?? this.brandIds,
      dataSourceType: dataSourceType ?? this.dataSourceType,
      sourceCategoryId: clearSourceCategoryId
          ? null
          : (sourceCategoryId ?? this.sourceCategoryId),
      sourceBrandId:
      clearSourceBrandId ? null : (sourceBrandId ?? this.sourceBrandId),
      itemLimit: itemLimit ?? this.itemLimit,
      showViewAll: showViewAll ?? this.showViewAll,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleEn': titleEn,
      'titleBn': titleBn,
      'subtitleEn': subtitleEn,
      'subtitleBn': subtitleBn,
      'sectionType': sectionType,
      'layoutStyle': layoutStyle,
      'bannerIds': bannerIds,
      'offerIds': offerIds,
      'productIds': productIds,
      'categoryIds': categoryIds,
      'brandIds': brandIds,
      'dataSourceType': dataSourceType,
      'sourceCategoryId': sourceCategoryId,
      'sourceBrandId': sourceBrandId,
      'itemLimit': itemLimit,
      'showViewAll': showViewAll,
      'isActive': isActive,
      'sortOrder': sortOrder,
    };
  }

  factory MBHomeSection.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBHomeSection.empty();

    return MBHomeSection(
      id: (map['id'] ?? '').toString(),
      titleEn: (map['titleEn'] ?? '').toString(),
      titleBn: (map['titleBn'] ?? '').toString(),
      subtitleEn: (map['subtitleEn'] ?? '').toString(),
      subtitleBn: (map['subtitleBn'] ?? '').toString(),
      sectionType: (map['sectionType'] ?? 'product_horizontal').toString(),
      layoutStyle: (map['layoutStyle'] ?? 'standard').toString(),
      bannerIds: List<String>.from(map['bannerIds'] ?? const []),
      offerIds: List<String>.from(map['offerIds'] ?? const []),
      productIds: List<String>.from(map['productIds'] ?? const []),
      categoryIds: List<String>.from(map['categoryIds'] ?? const []),
      brandIds: List<String>.from(map['brandIds'] ?? const []),
      dataSourceType: (map['dataSourceType'] ?? 'manual').toString(),
      sourceCategoryId: map['sourceCategoryId']?.toString(),
      sourceBrandId: map['sourceBrandId']?.toString(),
      itemLimit: (map['itemLimit'] ?? 10) is int
          ? map['itemLimit'] as int
          : int.tryParse((map['itemLimit'] ?? '10').toString()) ?? 10,
      showViewAll: map['showViewAll'] ?? true,
      isActive: map['isActive'] ?? true,
      sortOrder: (map['sortOrder'] ?? 0) is int
          ? map['sortOrder'] as int
          : int.tryParse((map['sortOrder'] ?? '0').toString()) ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBHomeSection.fromJson(String source) =>
      MBHomeSection.fromMap(json.decode(source) as Map<String, dynamic>);
}











