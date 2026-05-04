import 'package:admin_web/features/products/widgets/admin_product_form_dialog.dart';
import 'package:shared_models/shared_models.dart';
import 'package:shared_repositories/shared_repositories.dart';

// File: admin_product_lookup_support.dart

class AdminProductLookupSupport {
  AdminProductLookupSupport({
    AdminCategoryRepository? categoryRepository,
    AdminBrandRepository? brandRepository,
  })  : _categoryRepository = categoryRepository ?? AdminCategoryRepository.instance,
        _brandRepository = brandRepository ?? AdminBrandRepository.instance;

  final AdminCategoryRepository _categoryRepository;
  final AdminBrandRepository _brandRepository;

  Future<List<AdminProductRelationOption>> loadCategoryOptions({
    bool onlyActive = true,
    bool sortByName = true,
  }) async {
    final List<MBCategory> items = await _categoryRepository.fetchCategoriesOnce();

    Iterable<MBCategory> filtered = items;
    if (onlyActive) {
      filtered = filtered.where((item) => item.isActive);
    }

    final List<MBCategory> normalized = filtered.toList();
    if (sortByName) {
      normalized.sort(
            (a, b) => a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()),
      );
    }

    return normalized
        .map(
          (item) => AdminProductRelationOption(
        id: item.id,
        nameEn: item.nameEn,
        nameBn: item.nameBn,
        slug: item.slug,
        imageUrl: item.imageUrl,
        iconUrl: item.iconUrl,
      ),
    )
        .toList(growable: false);
  }

  Future<List<AdminProductRelationOption>> loadBrandOptions({
    bool onlyActive = true,
    bool sortByName = true,
  }) async {
    final List<MBBrand> items = await _brandRepository.fetchBrandsOnce();

    Iterable<MBBrand> filtered = items;
    if (onlyActive) {
      filtered = filtered.where((item) => item.isActive);
    }

    final List<MBBrand> normalized = filtered.toList();
    if (sortByName) {
      normalized.sort(
            (a, b) => a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()),
      );
    }

    return normalized
        .map(
          (item) => AdminProductRelationOption(
        id: item.id,
        nameEn: item.nameEn,
        nameBn: item.nameBn,
        slug: item.slug,
        imageUrl: item.imageUrl,
        logoUrl: item.logoUrl,
      ),
    )
        .toList(growable: false);
  }

  Future<AdminProductLookupBundle> loadLookupBundle({
    bool onlyActive = true,
  }) async {
    final results = await Future.wait<dynamic>([
      loadCategoryOptions(onlyActive: onlyActive),
      loadBrandOptions(onlyActive: onlyActive),
    ]);

    return AdminProductLookupBundle(
      categories: List<AdminProductRelationOption>.from(results[0] as List),
      brands: List<AdminProductRelationOption>.from(results[1] as List),
    );
  }

  Future<List<AdminProductRelationOption>> safeLoadCategoryOptions({
    bool onlyActive = true,
    bool sortByName = true,
  }) async {
    try {
      return await loadCategoryOptions(
        onlyActive: onlyActive,
        sortByName: sortByName,
      );
    } catch (_) {
      return const <AdminProductRelationOption>[];
    }
  }

  Future<List<AdminProductRelationOption>> safeLoadBrandOptions({
    bool onlyActive = true,
    bool sortByName = true,
  }) async {
    try {
      return await loadBrandOptions(
        onlyActive: onlyActive,
        sortByName: sortByName,
      );
    } catch (_) {
      return const <AdminProductRelationOption>[];
    }
  }

  Future<AdminProductLookupBundle> safeLoadLookupBundle({
    bool onlyActive = true,
  }) async {
    try {
      return await loadLookupBundle(onlyActive: onlyActive);
    } catch (_) {
      return const AdminProductLookupBundle();
    }
  }
}

class AdminProductLookupBundle {
  const AdminProductLookupBundle({
    this.categories = const <AdminProductRelationOption>[],
    this.brands = const <AdminProductRelationOption>[],
  });

  final List<AdminProductRelationOption> categories;
  final List<AdminProductRelationOption> brands;

  bool get isEmpty => categories.isEmpty && brands.isEmpty;
}
