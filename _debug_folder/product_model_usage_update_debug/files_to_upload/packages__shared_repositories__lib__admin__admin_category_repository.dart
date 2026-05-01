import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_models/catalog/mb_category.dart';

import 'core/mb_admin_callable_repository_base.dart';
import 'core/mb_admin_repository_errors.dart';

class AdminCategoryRepository extends MBAdminCallableRepositoryBase<MBCategory> {
  AdminCategoryRepository._() : super();

  static final AdminCategoryRepository instance = AdminCategoryRepository._();

  @override
  String get collectionPath => 'categories';

  CollectionReference<Map<String, dynamic>> get categoriesCollection => collection;

  @override
  MBCategory fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    final Map<String, dynamic> map = <String, dynamic>{
      ...data,
      'id': (data['id'] ?? doc.id).toString(),
    };

    try {
      return MBCategory.fromMap(map);
    } catch (error) {
      throw Exception(
        'Failed to parse category document "${doc.id}". '
        'Please check Firestore field names and types. '
        'Original error: $error',
      );
    }
  }

  @override
  List<MBCategory> sortItems(List<MBCategory> items) {
    items.sort((a, b) {
      final String aGroup = groupIdFromParentId(a.parentId);
      final String bGroup = groupIdFromParentId(b.parentId);
      final int byGroup = aGroup.compareTo(bGroup);
      if (byGroup != 0) return byGroup;

      final int bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;

      return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
    });
    return items;
  }

  String normalizeParentId(String? parentId) {
    return (parentId ?? '').trim();
  }

  String groupIdFromParentId(String? parentId) {
    final String normalizedParentId = normalizeParentId(parentId);
    return normalizedParentId.isEmpty ? 'root' : normalizedParentId;
  }

  Map<String, dynamic> _categoryPayload(MBCategory category) {
    final String normalizedParentId = normalizeParentId(category.parentId);

    return <String, dynamic>{
      'nameEn': category.nameEn.trim(),
      'nameBn': category.nameBn.trim(),
      'descriptionEn': category.descriptionEn.trim(),
      'descriptionBn': category.descriptionBn.trim(),
      'imageUrl': category.imageUrl.trim(),
      'iconUrl': category.iconUrl.trim(),
      'imagePath': category.imagePath.trim(),
      'thumbPath': category.thumbPath.trim(),
      'slug': normalizeSlug(category.slug),
      'parentId': normalizedParentId.isEmpty ? null : normalizedParentId,
      'isFeatured': category.isFeatured,
      'showOnHome': category.showOnHome,
      'isActive': category.isActive,
      'sortOrder': category.sortOrder,
    };
  }

  Stream<List<MBCategory>> watchCategories() {
    return watchAll();
  }

  Future<List<MBCategory>> fetchCategoriesOnce() {
    return fetchAll(
      timeoutMessage:
          'Timed out while loading categories from Firestore. '
          'Check internet connection, Firebase config, or browser console.',
    );
  }

  Future<List<MBCategory>> fetchSiblingGroupCategories({
    String? parentId,
    String? excludeCategoryId,
  }) async {
    return guardFirestore(() async {
      final String groupId = groupIdFromParentId(parentId);
      final String excludedId = excludeCategoryId?.trim() ?? '';

      final QuerySnapshot<Map<String, dynamic>> snapshot = await categoriesCollection
          .where('groupId', isEqualTo: groupId)
          .get()
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while loading sibling categories.');
        },
      );

      final List<MBCategory> items = <MBCategory>[];
      for (final doc in snapshot.docs) {
        if (excludedId.isNotEmpty && doc.id == excludedId) {
          continue;
        }
        items.add(fromDoc(doc));
      }

      items.sort((a, b) {
        final int bySort = a.sortOrder.compareTo(b.sortOrder);
        if (bySort != 0) return bySort;
        return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
      });

      return items;
    });
  }

  Future<int> suggestSortOrder({
    String? parentId,
    String? excludeCategoryId,
  }) async {
    final List<MBCategory> siblings = await fetchSiblingGroupCategories(
      parentId: parentId,
      excludeCategoryId: excludeCategoryId,
    );

    final List<int> used = siblings
        .map((item) => item.sortOrder)
        .where((value) => value >= 0)
        .toSet()
        .toList()
      ..sort();

    int expected = 0;
    for (final int value in used) {
      if (value != expected) {
        return expected;
      }
      expected += 1;
    }
    return expected;
  }


  Future<bool> sortExistsInSiblingGroup({
    required int sortOrder,
    String? parentId,
    String? excludeCategoryId,
  }) async {
    final List<MBCategory> siblings = await fetchSiblingGroupCategories(
      parentId: parentId,
      excludeCategoryId: excludeCategoryId,
    );
    return siblings.any((item) => item.sortOrder == sortOrder);
  }

  Future<String> createCategory(MBCategory category) async {
    return guardCallable(() async {
      final HttpsCallable callableRef = callable('createCategory');
      final HttpsCallableResult<Map<String, dynamic>> result =
          await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'category': _categoryPayload(category),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while creating category.');
        },
      );

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(result.data ?? const <String, dynamic>{});
      final String categoryId = (data['categoryId'] ?? '').toString().trim();
      if (categoryId.isEmpty) {
        throw Exception('Category was created but no categoryId was returned.');
      }
      return categoryId;
    }, fallback: 'Cloud Function error while creating category.');
  }

  Future<void> updateCategory(MBCategory category) async {
    final String categoryId = category.id.trim();
    if (categoryId.isEmpty) {
      throw Exception('Category id is required for update.');
    }

    await guardCallable(() async {
      final HttpsCallable callableRef = callable('updateCategory');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'categoryId': categoryId,
          'category': _categoryPayload(category),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating category.');
        },
      );
    }, fallback: 'Cloud Function error while updating category.');
  }

  Future<void> reorderCategoryGroup({
    required String? parentId,
    required List<String> orderedCategoryIds,
  }) async {
    if (orderedCategoryIds.isEmpty) return;

    await guardCallable(() async {
      final HttpsCallable callableRef = callable('reorderCategoryGroup');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'groupId': groupIdFromParentId(parentId),
          'orderedCategoryIds': orderedCategoryIds,
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while saving reordered categories.');
        },
      );
    }, fallback: 'Cloud Function error while reordering categories.');
  }

  Future<void> fixCategoryGroupSort({
    required String? parentId,
  }) async {
    await guardCallable(() async {
      final HttpsCallable callableRef = callable('fixCategoryGroupSort');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'groupId': groupIdFromParentId(parentId),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while fixing category sort order.');
        },
      );
    }, fallback: 'Cloud Function error while fixing category sorting.');
  }

  Future<String?> getDeleteBlockReason(String categoryId) async {
    final String id = categoryId.trim();
    if (id.isEmpty) {
      return 'Category id is required for delete.';
    }

    return guardFirestore(() async {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await categoriesCollection.doc(id).get().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timed out while checking category delete eligibility.');
        },
      );

      if (!doc.exists) {
        return 'Category not found.';
      }

      final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
      final int productsCount = parseInt(data['productsCount']);
      if (productsCount > 0) {
        return 'This category cannot be deleted because it contains $productsCount product(s).';
      }

      final QuerySnapshot<Map<String, dynamic>> childSnapshot =
          await categoriesCollection
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
    });
  }

  Future<void> deleteCategory(
    String categoryId, {
    String? reason,
  }) async {
    final String id = categoryId.trim();
    if (id.isEmpty) {
      throw Exception('Category id is required for delete.');
    }

    await guardCallable(() async {
      final HttpsCallable callableRef = callable('deleteCategory');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'categoryId': id,
          'reason': reason?.trim(),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while deleting category.');
        },
      );
    }, fallback: 'Cloud Function error while deleting category.');
  }

  Future<void> setCategoryActiveState({
    required String categoryId,
    required bool isActive,
    String? reason,
  }) async {
    final String id = categoryId.trim();
    if (id.isEmpty) {
      throw Exception('Category id is required for status update.');
    }

    await guardCallable(() async {
      final HttpsCallable callableRef = callable('setCategoryActiveState');
      await callableRef.call<Map<String, dynamic>>(
        <String, dynamic>{
          'categoryId': id,
          'isActive': isActive,
          'reason': reason?.trim(),
        },
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception('Timed out while updating category status.');
        },
      );
    }, fallback: 'Cloud Function error while updating category status.');
  }
}
