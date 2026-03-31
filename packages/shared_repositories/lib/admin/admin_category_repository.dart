import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/catalog/mb_category.dart';

class AdminCategoryRepository {
  AdminCategoryRepository._();

  static final AdminCategoryRepository instance = AdminCategoryRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get categoriesCollection =>
      _firestore.collection('categories');

  Stream<List<MBCategory>> watchCategories() {
    return categoriesCollection.snapshots().map((snapshot) {
      final List<MBCategory> items = <MBCategory>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final map = {
          ...data,
          'id': data['id'] ?? doc.id,
        };

        try {
          items.add(MBCategory.fromMap(map));
        } catch (e) {
          throw Exception(
            'Failed to parse category document "${doc.id}". '
                'Please check field types in Firestore. Original error: $e',
          );
        }
      }

      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return items;
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

      final List<MBCategory> items = <MBCategory>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final map = {
          ...data,
          'id': data['id'] ?? doc.id,
        };

        try {
          items.add(MBCategory.fromMap(map));
        } catch (e) {
          throw Exception(
            'Failed to parse category document "${doc.id}". '
                'Please check field types in Firestore. Original error: $e',
          );
        }
      }

      items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
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
      final query = await categoriesCollection
          .where('slug', isEqualTo: slug)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while checking slug uniqueness.');
        },
      );

      if (query.docs.isEmpty) return false;

      if (excludeCategoryId == null || excludeCategoryId.trim().isEmpty) {
        return true;
      }

      return query.docs.any((doc) => doc.id != excludeCategoryId);
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
          : categoriesCollection.doc(category.id);

      final now = DateTime.now();

      final payload = category.copyWith(
        id: doc.id,
        createdAt: category.createdAt ?? now,
        updatedAt: now,
      );

      await doc.set(payload.toMap()).timeout(
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
    if (category.id.trim().isEmpty) {
      throw Exception('Category id is required for update.');
    }

    try {
      final now = DateTime.now();

      await categoriesCollection.doc(category.id).set(
        category.copyWith(updatedAt: now).toMap(),
        SetOptions(merge: true),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while updating category.');
        },
      );
    } on FirebaseException catch (e) {
      throw Exception(_readableFirebaseError(e));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await categoriesCollection.doc(categoryId).delete().timeout(
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
    try {
      await categoriesCollection.doc(categoryId).set(
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
        return 'Firestore query failed due to missing index or invalid precondition.';
      case 'not-found':
        return 'Requested Firestore resource was not found.';
      default:
        return 'Firebase error (${e.code}): ${e.message ?? 'Unknown error'}';
    }
  }
}