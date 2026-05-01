import 'package:shared_models/shared_models.dart';

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

  factory MBHomeCacheBundle.empty() {
    return MBHomeCacheBundle(
      config: MBHomeConfig.empty(),
      categories: const <MBCategory>[],
      brands: const <MBBrand>[],
      products: const <MBProduct>[],
      cachedAt: DateTime.now(),
    );
  }

  bool get hasData {
    return categories.isNotEmpty ||
        brands.isNotEmpty ||
        products.isNotEmpty ||
        config.sections.isNotEmpty ||
        config.banners.isNotEmpty ||
        config.offers.isNotEmpty;
  }

  MBHomeCacheBundle copyWith({
    MBHomeConfig? config,
    List<MBCategory>? categories,
    List<MBBrand>? brands,
    List<MBProduct>? products,
    DateTime? cachedAt,
  }) {
    return MBHomeCacheBundle(
      config: config ?? this.config,
      categories: List<MBCategory>.unmodifiable(
        categories ?? this.categories,
      ),
      brands: List<MBBrand>.unmodifiable(
        brands ?? this.brands,
      ),
      products: List<MBProduct>.unmodifiable(
        products ?? this.products,
      ),
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'config': config.toMap(),
      'categories': categories.map((e) => e.toMap()).toList(),
      'brands': brands.map((e) => e.toMap()).toList(),
      'products': products.map((e) => e.toMap()).toList(),
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  factory MBHomeCacheBundle.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MBHomeCacheBundle.empty();

    final Object? rawConfig = map['config'];
    final Object? rawCategories = map['categories'];
    final Object? rawBrands = map['brands'];
    final Object? rawProducts = map['products'];
    final Object? rawCachedAt = map['cachedAt'];

    return MBHomeCacheBundle(
      config: rawConfig is Map
          ? MBHomeConfig.fromMap(Map<String, dynamic>.from(rawConfig))
          : MBHomeConfig.empty(),
      categories: _mapCategoryList(rawCategories),
      brands: _mapBrandList(rawBrands),
      products: _mapProductList(rawProducts),
      cachedAt: rawCachedAt == null
          ? DateTime.now()
          : DateTime.tryParse(rawCachedAt.toString()) ?? DateTime.now(),
    );
  }

  static List<MBCategory> _mapCategoryList(Object? raw) {
    if (raw is! List) return const <MBCategory>[];

    return raw
        .whereType<Map>()
        .map((e) => MBCategory.fromMap(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  static List<MBBrand> _mapBrandList(Object? raw) {
    if (raw is! List) return const <MBBrand>[];

    return raw
        .whereType<Map>()
        .map((e) => MBBrand.fromMap(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  static List<MBProduct> _mapProductList(Object? raw) {
    if (raw is! List) return const <MBProduct>[];

    return raw
        .whereType<Map>()
        .map((e) => MBProduct.fromMap(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }
}