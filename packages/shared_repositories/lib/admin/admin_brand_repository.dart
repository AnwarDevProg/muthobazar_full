import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/catalog/mb_brand.dart';

class AdminBrandRepository {
  AdminBrandRepository._();

  static final AdminBrandRepository instance = AdminBrandRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get brandsCollection =>
      _firestore.collection('brands');

  Stream<List<MBBrand>> watchBrands() {
    return brandsCollection
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final map = {
          ...data,
          'id': data['id'] ?? doc.id,
        };
        return MBBrand.fromMap(map);
      }).toList();
    });
  }

  Future<List<MBBrand>> fetchBrandsOnce() async {
    final snapshot = await brandsCollection.orderBy('sortOrder').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final map = {
        ...data,
        'id': data['id'] ?? doc.id,
      };
      return MBBrand.fromMap(map);
    }).toList();
  }

  Future<void> createBrand(MBBrand brand) async {
    final doc =
    brand.id.trim().isEmpty ? brandsCollection.doc() : brandsCollection.doc(brand.id);

    final now = DateTime.now();

    final payload = brand.copyWith(
      id: doc.id,
      createdAt: brand.createdAt ?? now,
      updatedAt: now,
    );

    await doc.set(payload.toMap());
  }

  Future<void> updateBrand(MBBrand brand) async {
    if (brand.id.trim().isEmpty) {
      throw Exception('Brand id is required for update.');
    }

    final now = DateTime.now();

    await brandsCollection.doc(brand.id).set(
      brand.copyWith(updatedAt: now).toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteBrand(String brandId) async {
    await brandsCollection.doc(brandId).delete();
  }

  Future<void> setBrandActiveState({
    required String brandId,
    required bool isActive,
  }) async {
    await brandsCollection.doc(brandId).set({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}











