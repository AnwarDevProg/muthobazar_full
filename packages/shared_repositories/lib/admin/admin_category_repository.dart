import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/catalog/mb_category.dart';


class AdminCategoryRepository {
  AdminCategoryRepository._();

  static final AdminCategoryRepository instance = AdminCategoryRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get categoriesCollection =>
      _firestore.collection('categories');

  Stream<List<MBCategory>> watchCategories() {
    return categoriesCollection
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final map = {
          ...data,
          'id': data['id'] ?? doc.id,
        };
        return MBCategory.fromMap(map);
      }).toList();
    });
  }

  Future<List<MBCategory>> fetchCategoriesOnce() async {
    final snapshot = await categoriesCollection.orderBy('sortOrder').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final map = {
        ...data,
        'id': data['id'] ?? doc.id,
      };
      return MBCategory.fromMap(map);
    }).toList();
  }

  Future<void> createCategory(MBCategory category) async {
    final doc = category.id.trim().isEmpty
        ? categoriesCollection.doc()
        : categoriesCollection.doc(category.id);

    final now = DateTime.now();

    final payload = category.copyWith(
      id: doc.id,
      createdAt: category.createdAt ?? now,
      updatedAt: now,
    );

    await doc.set(payload.toMap());
  }

  Future<void> updateCategory(MBCategory category) async {
    if (category.id.trim().isEmpty) {
      throw Exception('Category id is required for update.');
    }

    final now = DateTime.now();

    await categoriesCollection.doc(category.id).set(
      category.copyWith(updatedAt: now).toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteCategory(String categoryId) async {
    await categoriesCollection.doc(categoryId).delete();
  }

  Future<void> setCategoryActiveState({
    required String categoryId,
    required bool isActive,
  }) async {
    await categoriesCollection.doc(categoryId).set({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}











