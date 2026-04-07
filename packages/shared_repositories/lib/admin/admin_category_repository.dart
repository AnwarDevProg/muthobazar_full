import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_models/catalog/mb_category.dart';

class AdminCategoryRepository {
  AdminCategoryRepository._();

  static final AdminCategoryRepository instance = AdminCategoryRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'asia-south1',
  );

  CollectionReference<Map<String, dynamic>> get categoriesCollection =>
      _firestore.collection('categories');

  HttpsCallable _callable(String name) => _functions.httpsCallable(name);

  MBCategory _parseCategoryDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();
    final map = {
      ...data,
      'id': (data['id'] ?? doc.id).toString(),
    };

    try {
      return MBCategory.fromMap(map);
    } catch (e) {
      throw Exception(
        'Failed to parse category document "${doc.id}". '
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

  String _normalizeParentId(String? parentId) {
    return (parentId ?? '').trim();
  }

  String _groupIdFromParentId(String? parentId) {
    final normalizedParentId = _normalizeParentId(parentId);
    return normalizedParentId.isEmpty ? 'root' : normalizedParentId;
  }

  String _normalizeSlug(String value) {
    return value.trim().toLowerCase();
  }

  Map<String, dynamic> _categoryPayload(MBCategory category) {
    final normalizedParentId = _normalizeParentId(category.parentId);

    return {
      'nameEn': category.nameEn.trim(),
      'nameBn': category.nameBn.trim(),
      'descriptionEn': category.descriptionEn.trim(),
      'descriptionBn': category.descriptionBn.trim(),
      'imageUrl': category.imageUrl.trim(),
      'iconUrl': category.iconUrl.trim(),
      'imagePath': category.imagePath.trim(),
      'thumbPath': category.thumbPath.trim(),
      'slug': _normalizeSlug(category.slug),
      'parentId': normalizedParentId.isEmpty ? null : normalizedParentId,
      'isFeatured': category.isFeatured,
      'showOnHome': category.showOnHome,
      'isActive': category.isActive,
      'sortOrder': category.sortOrder,
    };
  }

  List<MBCategory> _sortCategories(List<MBCategory> items) {
    items.sort((a, b) {
      final String aGroup = _groupIdFromParentId(a.parentId);
      final String bGroup = _groupIdFromParentId(b.parentId);
      final int byGroup = aGroup.compareTo(bGroup);
      if (byGroup != 0) return byGroup;

      final int bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;

      return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
    });
    return items;
  }

  Stream<List<MBCategory>> watchCategories() {
    return categoriesCollection.snapshots().map((snapshot) {
      final List<MBCategory> items = [];

      for (final doc in snapshot.docs) {
        items.add(_parseCategoryDoc(doc));
      }

      return _sortCategories(items);
    }).handleError((error) {
      if (error is FirebaseException) {
        throw Exception(_readableFirebaseError(error));
      }
      throw error;
    });
  }

  Future<List<MBCategory>> fetchCategoriesOnce() async {
    try {
      final snapshot = await categoriesCollection.get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
            'Timed out while loading categories from Firestore. '
                'Check internet connection, Firebase config, or browser console.',
          );
        },
      );

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<MBCategory> items = [];
      for (final doc in snapshot.docs) {
        items.add(_parseCategoryDoc(doc));
      }

      return _sortCategories(items);
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MBCategory>> fetchSiblingGroupCategories({
    String? parentId,
    String? excludeCategoryId,
  }) async {
    try {
      final groupId = _groupIdFromParentId(parentId);
      final excludedId = excludeCategoryId?.trim() ?? '';

      final snapshot = await categoriesCollection
          .where('groupId', isEqualTo: groupId)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while loading sibling categories.');
        },
      );

      final List<MBCategory> items = [];
      for (final doc in snapshot.docs) {
        if (excludedId.isNotEmpty && doc.id == excludedId) {
          continue;
        }
        items.add(_parseCategoryDoc(doc));
      }

      items.sort((a, b) {
        final int bySort = a.sortOrder.compareTo(b.sortOrder);
        if (bySort != 0) return bySort;
        return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
      });

      return items;
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<int> suggestSortOrder({
    String? parentId,
    String? excludeCategoryId,
  }) async {
    final siblings = await fetchSiblingGroupCategories(
      parentId: parentId,
      excludeCategoryId: excludeCategoryId,
    );

    final used = siblings
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
    String? excludeCategoryId,
  }) async {
    try {
      final normalizedSlug = _normalizeSlug(slug);
      if (normalizedSlug.isEmpty) return false;

      final query = await categoriesCollection
          .where('slug', isEqualTo: normalizedSlug)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while checking slug uniqueness.');
        },
      );

      if (query.docs.isEmpty) return false;

      final excludedId = excludeCategoryId?.trim();
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

  Future<bool> sortExistsInSiblingGroup({
    required int sortOrder,
    String? parentId,
    String? excludeCategoryId,
  }) async {
    try {
      final siblings = await fetchSiblingGroupCategories(
        parentId: parentId,
        excludeCategoryId: excludeCategoryId,
      );

      return siblings.any((item) => item.sortOrder == sortOrder);
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createCategory(MBCategory category) async {
    try {
      final callable = _callable('createCategory');

      final result = await callable.call<Map<String, dynamic>>({
        'category': _categoryPayload(category),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while creating category.');
        },
      );

      final data = Map<String, dynamic>.from(result.data ?? const {});
      final categoryId = (data['categoryId'] ?? '').toString().trim();

      if (categoryId.isEmpty) {
        throw Exception('Category was created but no categoryId was returned.');
      }

      return categoryId;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _extractFunctionMessage(e, 'Cloud Function error while creating category.'),
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(MBCategory category) async {
    final categoryId = category.id.trim();
    if (categoryId.isEmpty) {
      throw Exception('Category id is required for update.');
    }

    try {
      final callable = _callable('updateCategory');

      await callable.call<Map<String, dynamic>>({
        'categoryId': categoryId,
        'category': _categoryPayload(category),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating category.');
        },
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _extractFunctionMessage(e, 'Cloud Function error while updating category.'),
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reorderCategoryGroup({
    required String? parentId,
    required List<String> orderedCategoryIds,
  }) async {
    if (orderedCategoryIds.isEmpty) return;

    try {
      final callable = _callable('reorderCategoryGroup');

      await callable.call<Map<String, dynamic>>({
        'groupId': _groupIdFromParentId(parentId),
        'orderedCategoryIds': orderedCategoryIds,
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while saving reordered categories.');
        },
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _extractFunctionMessage(e, 'Cloud Function error while reordering categories.'),
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fixCategoryGroupSort({
    required String? parentId,
  }) async {
    try {
      final callable = _callable('fixCategoryGroupSort');

      await callable.call<Map<String, dynamic>>({
        'groupId': _groupIdFromParentId(parentId),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while fixing category sort order.');
        },
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _extractFunctionMessage(e, 'Cloud Function error while fixing category sorting.'),
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getDeleteBlockReason(String categoryId) async {
    final id = categoryId.trim();
    if (id.isEmpty) {
      return 'Category id is required for delete.';
    }

    try {
      final doc = await categoriesCollection.doc(id).get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while checking category delete eligibility.');
        },
      );

      if (!doc.exists) {
        return 'Category not found.';
      }

      final data = doc.data() ?? {};
      final int productsCount = _parseInt(data['productsCount']);
      if (productsCount > 0) {
        return 'This category cannot be deleted because it contains $productsCount product(s).';
      }

      final childSnapshot = await categoriesCollection
          .where('parentId', isEqualTo: id)
          .limit(1)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while checking child categories.');
        },
      );

      if (childSnapshot.docs.isNotEmpty) {
        return 'This category cannot be deleted because it has child categories.';
      }

      return null;
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(
      String categoryId, {
        String? reason,
      }) async {
    final id = categoryId.trim();
    if (id.isEmpty) {
      throw Exception('Category id is required for delete.');
    }

    try {
      final callable = _callable('deleteCategory');

      await callable.call<Map<String, dynamic>>({
        'categoryId': id,
        'reason': reason?.trim(),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while deleting category.');
        },
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _extractFunctionMessage(e, 'Cloud Function error while deleting category.'),
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setCategoryActiveState({
    required String categoryId,
    required bool isActive,
    String? reason,
  }) async {
    final id = categoryId.trim();
    if (id.isEmpty) {
      throw Exception('Category id is required for status update.');
    }

    try {
      final callable = _callable('setCategoryActiveState');

      await callable.call<Map<String, dynamic>>({
        'categoryId': id,
        'isActive': isActive,
        'reason': reason?.trim(),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating category status.');
        },
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        _extractFunctionMessage(e, 'Cloud Function error while updating category status.'),
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
        return 'Firestore permission denied for categories.';
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
