import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_models/catalog/mb_category.dart';

class AdminCategoryRepository {
  AdminCategoryRepository._();

  static final AdminCategoryRepository instance = AdminCategoryRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  CollectionReference<Map<String, dynamic>> get categoriesCollection =>
      _firestore.collection('categories');

  MBCategory _parseCategoryDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final map = <String, dynamic>{
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

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _normalizeParentId(String? parentId) {
    final value = parentId?.trim() ?? '';
    return value;
  }

  String _groupIdFromParentId(String? parentId) {
    final normalizedParentId = _normalizeParentId(parentId);
    return normalizedParentId.isEmpty ? 'root' : normalizedParentId;
  }

  Stream<List<MBCategory>> watchCategories() {
    return categoriesCollection.snapshots().map((snapshot) {
      final List<MBCategory> items = <MBCategory>[];

      for (final doc in snapshot.docs) {
        items.add(_parseCategoryDoc(doc));
      }

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
        return <MBCategory>[];
      }

      final List<MBCategory> items = <MBCategory>[];

      for (final doc in snapshot.docs) {
        items.add(_parseCategoryDoc(doc));
      }

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
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> slugExists({
    required String slug,
    String? excludeCategoryId,
  }) async {
    try {
      final normalizedSlug = slug.trim();
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
      final groupId = _groupIdFromParentId(parentId);

      final snapshot = await categoriesCollection
          .where('groupId', isEqualTo: groupId)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while checking sort uniqueness.');
        },
      );

      final excludedId = excludeCategoryId?.trim() ?? '';

      for (final doc in snapshot.docs) {
        if (excludedId.isNotEmpty && doc.id == excludedId) {
          continue;
        }

        final data = doc.data();
        final docSortOrder = _parseInt(data['sortOrder']);

        if (docSortOrder == sortOrder) {
          return true;
        }
      }

      return false;
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createCategory(MBCategory category) async {
    try {
      final doc = category.id.trim().isEmpty
          ? categoriesCollection.doc()
          : categoriesCollection.doc(category.id.trim());

      final now = DateTime.now();
      final groupId = _groupIdFromParentId(category.parentId);

      final payload = category.copyWith(
        id: doc.id,
        createdAt: category.createdAt ?? now,
        updatedAt: now,
      );

      final bool sortExists = await sortExistsInSiblingGroup(
        sortOrder: payload.sortOrder,
        parentId: payload.parentId,
      );

      if (sortExists) {
        throw Exception(
          'Sort number already exists in this group. Please use another.',
        );
      }

      final map = <String, dynamic>{
        ...payload.toMap(),
        'groupId': groupId,
        'parentId': _normalizeParentId(payload.parentId).isEmpty
            ? ''
            : _normalizeParentId(payload.parentId),
      };

      await doc.set(map).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while creating category.');
        },
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
      final docRef = categoriesCollection.doc(categoryId);

      final existingDoc = await docRef.get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while loading category before update.');
        },
      );

      final existingData = existingDoc.data() ?? <String, dynamic>{};

      final oldImagePath = (existingData['imagePath'] ?? '').toString();
      final oldThumbPath = (existingData['thumbPath'] ?? '').toString();

      final newImagePath = category.imagePath;
      final newThumbPath = category.thumbPath;

      final bool sortExists = await sortExistsInSiblingGroup(
        sortOrder: category.sortOrder,
        parentId: category.parentId,
        excludeCategoryId: categoryId,
      );

      if (sortExists) {
        throw Exception(
          'Sort number already exists in this group. Please use another.',
        );
      }

      final now = DateTime.now();
      final groupId = _groupIdFromParentId(category.parentId);

      final map = <String, dynamic>{
        ...category.copyWith(updatedAt: now).toMap(),
        'groupId': groupId,
        'parentId': _normalizeParentId(category.parentId).isEmpty
            ? ''
            : _normalizeParentId(category.parentId),
      };

      await docRef.set(
        map,
        SetOptions(merge: true),
      );

      if (oldImagePath.isNotEmpty && oldImagePath != newImagePath) {
        try {
          await _storage.ref(oldImagePath).delete();
        } catch (_) {}
      }

      if (oldThumbPath.isNotEmpty && oldThumbPath != newThumbPath) {
        try {
          await _storage.ref(oldThumbPath).delete();
        } catch (_) {}
      }
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
      final callable = _functions.httpsCallable('reorderCategoryGroup');

      await callable.call({
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
        e.message ?? 'Cloud Function error while reordering categories.',
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
      final callable = _functions.httpsCallable('fixCategoryGroupSort');

      await callable.call({
        'groupId': _groupIdFromParentId(parentId),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while fixing category sort order.');
        },
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ?? 'Cloud Function error while fixing category sorting.',
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

      final data = doc.data() ?? <String, dynamic>{};
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

  Future<void> deleteCategory(String categoryId) async {
    final id = categoryId.trim();
    if (id.isEmpty) {
      throw Exception('Category id is required for delete.');
    }

    try {
      final String? blockReason = await getDeleteBlockReason(id);
      if (blockReason != null) {
        throw Exception(blockReason);
      }

      final docRef = categoriesCollection.doc(id);
      final doc = await docRef.get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while loading category before delete.');
        },
      );

      if (!doc.exists) return;

      final data = doc.data() ?? <String, dynamic>{};

      final String imagePath = (data['imagePath'] ?? '').toString().trim();
      final String thumbPath = (data['thumbPath'] ?? '').toString().trim();

      if (imagePath.isNotEmpty) {
        try {
          await _storage.ref(imagePath).delete();
        } catch (_) {}
      }

      if (thumbPath.isNotEmpty && thumbPath != imagePath) {
        try {
          await _storage.ref(thumbPath).delete();
        } catch (_) {}
      }

      await docRef.delete().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while deleting category.');
        },
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
  }) async {
    final id = categoryId.trim();
    if (id.isEmpty) {
      throw Exception('Category id is required for status update.');
    }

    try {
      await categoriesCollection.doc(id).set(
        {
          'isActive': isActive,
          'updatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while updating category status.');
        },
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