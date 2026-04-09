import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_models/catalog/mb_brand.dart';

class AdminBrandRepository {
  AdminBrandRepository._();

  static final AdminBrandRepository instance = AdminBrandRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'asia-south1',
  );

  CollectionReference<Map<String, dynamic>> get brandsCollection =>
      _firestore.collection('brands');

  HttpsCallable _callable(String name) => _functions.httpsCallable(name);

  MBBrand _parseBrandDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();
    final map = <String, dynamic>{
      ...data,
      'id': (data['id'] ?? doc.id).toString(),
    };

    try {
      return MBBrand.fromMap(map);
    } catch (e) {
      throw Exception(
        'Failed to parse brand document "${doc.id}". '
            'Please check Firestore field names and types. '
            'Original error: $e',
      );
    }
  }

  String _extractFunctionMessage(
      FirebaseFunctionsException e,
      String fallback,
      ) {
    final message = (e.message ?? '').trim();
    return message.isEmpty ? fallback : message;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _normalizeSlug(String value) {
    return value.trim().toLowerCase();
  }

  Map<String, dynamic> _brandPayload(MBBrand brand) {
    final normalizedImageUrl = brand.imageUrl.trim();
    final normalizedLogoUrl = brand.logoUrl.trim();
    final normalizedImagePath = brand.imagePath.trim();
    final normalizedThumbPath = brand.thumbPath.trim();

    return <String, dynamic>{
      'nameEn': brand.nameEn.trim(),
      'nameBn': brand.nameBn.trim(),
      'descriptionEn': brand.descriptionEn.trim(),
      'descriptionBn': brand.descriptionBn.trim(),
      'imageUrl': normalizedImageUrl,
      'logoUrl': normalizedLogoUrl,
      'imagePath': normalizedImagePath,
      'thumbPath': normalizedThumbPath,
      'slug': _normalizeSlug(brand.slug),
      'isFeatured': brand.isFeatured,
      'showOnHome': brand.showOnHome,
      'isActive': brand.isActive,
      'sortOrder': brand.sortOrder,
    };
  }

  List<MBBrand> _sortBrands(List<MBBrand> items) {
    items.sort((a, b) {
      final int bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;

      return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
    });

    return items;
  }

  Stream<List<MBBrand>> watchBrands() {
    return brandsCollection.snapshots().map((snapshot) {
      final List<MBBrand> items = <MBBrand>[];

      for (final doc in snapshot.docs) {
        items.add(_parseBrandDoc(doc));
      }

      return _sortBrands(items);
    }).handleError((error) {
      if (error is FirebaseException) {
        throw Exception(_readableFirebaseError(error));
      }
      throw error;
    });
  }

  Future<List<MBBrand>> fetchBrandsOnce() async {
    try {
      final snapshot = await brandsCollection.get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
            'Timed out while loading brands from Firestore. '
                'Check internet connection, Firebase config, or browser console.',
          );
        },
      );

      if (snapshot.docs.isEmpty) {
        return <MBBrand>[];
      }

      final List<MBBrand> items = <MBBrand>[];

      for (final doc in snapshot.docs) {
        items.add(_parseBrandDoc(doc));
      }

      return _sortBrands(items);
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<int> suggestSortOrder({
    String? excludeBrandId,
  }) async {
    final brands = await fetchBrandsOnce();
    final excludedId = excludeBrandId?.trim() ?? '';

    final used = brands
        .where((item) => excludedId.isEmpty || item.id != excludedId)
        .map((item) => item.sortOrder)
        .where((value) => value >= 0)
        .toSet()
        .toList()
      ..sort();

    int expected = 0;
    for (final value in used) {
      if (value != expected) {
        return expected;
      }
      expected += 1;
    }

    return expected;
  }

  Future<bool> slugExists({
    required String slug,
    String? excludeBrandId,
  }) async {
    try {
      final normalizedSlug = _normalizeSlug(slug);
      if (normalizedSlug.isEmpty) return false;

      final query = await brandsCollection
          .where('slug', isEqualTo: normalizedSlug)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while checking brand slug uniqueness.');
        },
      );

      if (query.docs.isEmpty) return false;

      final excludedId = excludeBrandId?.trim();
      if (excludedId == null || excludedId.isEmpty) {
        return true;
      }

      return query.docs.any((doc) => doc.id != excludedId);
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sortExists({
    required int sortOrder,
    String? excludeBrandId,
  }) async {
    try {
      final brands = await fetchBrandsOnce();
      final excludedId = excludeBrandId?.trim() ?? '';

      return brands.any(
            (item) => item.sortOrder == sortOrder && item.id != excludedId,
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getDeleteBlockReason(String brandId) async {
    final id = brandId.trim();
    if (id.isEmpty) {
      return 'Brand id is required for delete.';
    }

    try {
      final doc = await brandsCollection.doc(id).get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while checking brand delete eligibility.');
        },
      );

      if (!doc.exists) {
        return 'Brand not found.';
      }

      final data = doc.data() ?? <String, dynamic>{};
      final int productsCount = _parseInt(data['productsCount']);

      if (productsCount > 0) {
        return 'This brand cannot be deleted because it contains '
            '$productsCount product(s).';
      }

      return null;
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createBrand(MBBrand brand) async {
    try {
      final callable = _callable('createBrand');

      final result = await callable.call<Map<String, dynamic>>({
        'brand': _brandPayload(brand),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while creating brand.');
        },
      );

      final data = Map<String, dynamic>.from(result.data ?? const {});
      final brandId = (data['brandId'] ?? '').toString().trim();

      if (brandId.isEmpty) {
        throw Exception('Brand was created but no brandId was returned.');
      }

      return brandId;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _extractFunctionMessage(
          e,
          'Cloud Function error while creating brand.',
        ),
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBrand(MBBrand brand) async {
    final brandId = brand.id.trim();
    if (brandId.isEmpty) {
      throw Exception('Brand id is required for update.');
    }

    try {
      final callable = _callable('updateBrand');

      await callable.call<Map<String, dynamic>>({
        'brandId': brandId,
        'brand': _brandPayload(brand),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating brand.');
        },
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _extractFunctionMessage(
          e,
          'Cloud Function error while updating brand.',
        ),
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBrand(
      String brandId, {
        String? reason,
      }) async {
    final id = brandId.trim();
    if (id.isEmpty) {
      throw Exception('Brand id is required for delete.');
    }

    try {
      final callable = _callable('deleteBrand');

      await callable.call<Map<String, dynamic>>({
        'brandId': id,
        'reason': reason?.trim(),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while deleting brand.');
        },
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _extractFunctionMessage(
          e,
          'Cloud Function error while deleting brand.',
        ),
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setBrandActiveState({
    required String brandId,
    required bool isActive,
    String? reason,
  }) async {
    final id = brandId.trim();
    if (id.isEmpty) {
      throw Exception('Brand id is required for status update.');
    }

    try {
      final callable = _callable('setBrandActiveState');

      await callable.call<Map<String, dynamic>>({
        'brandId': id,
        'isActive': isActive,
        'reason': reason?.trim(),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating brand status.');
        },
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _extractFunctionMessage(
          e,
          'Cloud Function error while updating brand status.',
        ),
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  static String _readableFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Firestore permission denied for brands.';
      case 'unavailable':
        return 'Firebase service is unavailable. Check your internet connection.';
      case 'failed-precondition':
        return 'Firestore query failed due to a missing index or invalid precondition.';
      case 'not-found':
        return 'Requested Firestore resource was not found.';
      default:
        return 'Firebase error (${e.code}): ${e.message ?? 'Unknown error'}';
    }
  }
}