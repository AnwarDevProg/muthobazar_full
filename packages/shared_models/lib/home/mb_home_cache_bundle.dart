import '../../../../models/catalog/mb_brand.dart';
import '../../../../models/catalog/mb_category.dart';
import '../../../../models/catalog/mb_product.dart';
import '../../../../models/home/mb_home_config.dart';

// MB Home Cache Bundle
// --------------------
// Unified home payload used across controller/repository/datasources.

class MBHomeCacheBundle {
  final MBHomeConfig config;
  final List<MBCategory> categories;
  final List<MBBrand> brands;
  final List<MBProduct> products;
  final DateTime cachedAt;

  const MBHomeCacheBundle({
    required this.config,
    required this.categories,
    required this.brands,
    required this.products,
    required this.cachedAt,
  });

  factory MBHomeCacheBundle.empty() => MBHomeCacheBundle(
    config: MBHomeConfig.empty(),
    categories: const [],
    brands: const [],
    products: const [],
    cachedAt: DateTime.now(),
  );

  bool get hasData =>
      categories.isNotEmpty ||
          brands.isNotEmpty ||
          products.isNotEmpty ||
          config.sections.isNotEmpty ||
          config.banners.isNotEmpty ||
          config.offers.isNotEmpty;

  MBHomeCacheBundle copyWith({
    MBHomeConfig? config,
    List<MBCategory>? categories,
    List<MBBrand>? brands,
    List<MBProduct>? products,
    DateTime? cachedAt,
  }) {
    return MBHomeCacheBundle(
      config: config ?? this.config,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      products: products ?? this.products,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'config': config.toMap(),
      'categories': categories.map((e) => e.toMap()).toList(),
      'brands': brands.map((e) => e.toMap()).toList(),
      'products': products.map((e) => e.toMap()).toList(),
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  factory MBHomeCacheBundle.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBHomeCacheBundle.empty();

    return MBHomeCacheBundle(
      config: MBHomeConfig.fromMap(map['config'] as Map<String, dynamic>?),
      categories: (map['categories'] as List<dynamic>? ?? const [])
          .map((e) => MBCategory.fromMap(e as Map<String, dynamic>))
          .toList(),
      brands: (map['brands'] as List<dynamic>? ?? const [])
          .map((e) => MBBrand.fromMap(e as Map<String, dynamic>))
          .toList(),
      products: (map['products'] as List<dynamic>? ?? const [])
          .map((e) => MBProduct.fromMap(e as Map<String, dynamic>))
          .toList(),
      cachedAt: map['cachedAt'] == null
          ? DateTime.now()
          : DateTime.tryParse(map['cachedAt'].toString()) ?? DateTime.now(),
    );
  }
}











