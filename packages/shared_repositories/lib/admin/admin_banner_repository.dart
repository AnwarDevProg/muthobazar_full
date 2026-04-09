import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/marketing/mb_banner.dart';


class AdminBannerRepository {
  AdminBannerRepository._();

  static final AdminBannerRepository instance = AdminBannerRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get bannersCollection =>
      _firestore.collection('banners');

  Stream<List<MBBanner>> watchBanners() {
    return bannersCollection
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final map = {
          ...data,
          'id': data['id'] ?? doc.id,
        };
        return MBBanner.fromMap(map);
      }).toList();
    });
  }

  Future<List<MBBanner>> fetchBannersOnce() async {
    final snapshot = await bannersCollection.orderBy('sortOrder').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final map = {
        ...data,
        'id': data['id'] ?? doc.id,
      };
      return MBBanner.fromMap(map);
    }).toList();
  }

  Future<void> createBanner(MBBanner banner) async {
    final doc =
    banner.id.trim().isEmpty ? bannersCollection.doc() : bannersCollection.doc(banner.id);

    final now = DateTime.now();

    final payload = banner.copyWith(
      id: doc.id,
    );

    await doc.set({
      ...payload.toMap(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> updateBanner(MBBanner banner) async {
    if (banner.id.trim().isEmpty) {
      throw Exception('Banner id is required for update.');
    }

    final now = DateTime.now();

    await bannersCollection.doc(banner.id).set({
      ...banner.toMap(),
      'updatedAt': now.toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteBanner(String bannerId) async {
    await bannersCollection.doc(bannerId).delete();
  }

  Future<void> setBannerActiveState({
    required String bannerId,
    required bool isActive,
  }) async {
    await bannersCollection.doc(bannerId).set({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}