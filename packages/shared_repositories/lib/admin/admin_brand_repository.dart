import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_models/catalog/mb_brand.dart';

import 'core/mb_admin_callable_repository_base.dart';

class AdminBrandRepository extends MBAdminCallableRepositoryBase<MBBrand> {
  AdminBrandRepository._() : super();

  static final AdminBrandRepository instance = AdminBrandRepository._();

  @override
  String get collectionPath => 'brands';

  CollectionReference<Map<String, dynamic>> get brandsCollection => collection;

  @override
  MBBrand fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    final Map<String, dynamic> map = <String, dynamic>{
      ...data,
      'id': (data['id'] ?? doc.id).toString(),
    };

    try {
      return MBBrand.fromMap(map);
    } catch (error) {
      throw Exception(
        'Failed to parse brand document "${doc.id}". '
            'Please check Firestore field names and types. '
            'Original error: $error',
      );
    }
  }

  @override
  List<MBBrand> sortItems(List<MBBrand> items) {
    items.sort((a, b) {
      final int bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;
      return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
    });
    return items;
  }

  Map<String, dynamic> _brandPayload(MBBrand brand) {
    return <String, dynamic>{
      'nameEn': brand.nameEn.trim(),
      'nameBn': brand.nameBn.trim(),
      'descriptionEn': brand.descriptionEn.trim(),
      'descriptionBn': brand.descriptionBn.trim(),
      'imageUrl': brand.imageUrl.trim(),
      'logoUrl': brand.logoUrl.trim(),
      'imagePath': brand.imagePath.trim(),
      'thumbPath': brand.thumbPath.trim(),
      'slug': normalizeSlug(brand.slug),
      'isFeatured': brand.isFeatured,
      'showOnHome': brand.showOnHome,
      'isActive': brand.isActive,
      'sortOrder': brand.sortOrder,
    };
  }

  Stream<List<MBBrand>> watchBrands() {
    return watchAll();
  }

  Future<List<MBBrand>> fetchBrandsOnce() {
    return fetchAll(
      timeoutMessage:
      'Timed out while loading brands from Firestore. '
          'Check internet connection, Firebase config, or browser console.',
    );
  }

  Future<int> suggestSortOrder({
    String? excludeBrandId,
  }) {
    return suggestLowestMissingNonNegativeInt(
      selector: (item) => item.sortOrder,
      excludeId: excludeBrandId,
      idSelector: (item) => item.id,
    );
  }


  Future<bool> sortExists({
    required int sortOrder,
    String? excludeBrandId,
  }) {
    return intFieldExists(
      value: sortOrder,
      fieldName: 'sortOrder',
      excludeId: excludeBrandId,
      timeoutMessage: 'Timed out while checking brand sort order.',
    );
  }

  Future<String?> getDeleteBlockReason(String brandId) async {
    final String id = brandId.trim();
    if (id.isEmpty) {
      return 'Brand id is required for delete.';
    }

    return guardFirestore(() async {
      final DocumentSnapshot<Map<String, dynamic>> doc =
      await brandsCollection.doc(id).get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while checking brand delete eligibility.');
        },
      );

      if (!doc.exists) {
        return 'Brand not found.';
      }

      final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
      final int productsCount = parseInt(data['productsCount']);
      if (productsCount > 0) {
        return 'This brand cannot be deleted because it contains $productsCount product(s).';
      }

      return null;
    });
  }

  Future<String> createBrand(MBBrand brand) async {
    return guardCallable(() async {
      final HttpsCallable callableRef = callable('createBrand');
      final HttpsCallableResult<Map<String, dynamic>> result =
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'brand': _brandPayload(brand),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while creating brand.');
        },
      );

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(result.data ?? const <String, dynamic>{});
      final String brandId = (data['brandId'] ?? '').toString().trim();
      if (brandId.isEmpty) {
        throw Exception('Brand was created but no brandId was returned.');
      }
      return brandId;
    }, fallback: 'Cloud Function error while creating brand.');
  }

  Future<void> updateBrand(MBBrand brand) async {
    final String brandId = brand.id.trim();
    if (brandId.isEmpty) {
      throw Exception('Brand id is required for update.');
    }

    await guardCallable(() async {
      final HttpsCallable callableRef = callable('updateBrand');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'brandId': brandId,
          'brand': _brandPayload(brand),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating brand.');
        },
      );
    }, fallback: 'Cloud Function error while updating brand.');
  }

  Future<void> deleteBrand(
      String brandId, {
        String? reason,
      }) async {
    final String id = brandId.trim();
    if (id.isEmpty) {
      throw Exception('Brand id is required for delete.');
    }

    await guardCallable(() async {
      final HttpsCallable callableRef = callable('deleteBrand');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'brandId': id,
          'reason': reason?.trim(),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while deleting brand.');
        },
      );
    }, fallback: 'Cloud Function error while deleting brand.');
  }

  Future<void> setBrandActiveState({
    required String brandId,
    required bool isActive,
    String? reason,
  }) async {
    final String id = brandId.trim();
    if (id.isEmpty) {
      throw Exception('Brand id is required for status update.');
    }

    await guardCallable(() async {
      final HttpsCallable callableRef = callable('setBrandActiveState');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'brandId': id,
          'isActive': isActive,
          'reason': reason?.trim(),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating brand status.');
        },
      );
    }, fallback: 'Cloud Function error while updating brand status.');
  }
}
