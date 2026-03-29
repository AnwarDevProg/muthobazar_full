import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';

class AdminPromoRepository {
  AdminPromoRepository._();

  static final AdminPromoRepository instance = AdminPromoRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get promosCollection =>
      _firestore.collection('promo_codes');

  // =========================================================
  // WATCH PROMOS (REAL-TIME)
  // =========================================================

  Stream<List<MBPromoCode>> watchPromos() {
    return promosCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => MBPromoCode.fromMap(doc.data()))
          .toList(),
    );
  }

  // =========================================================
  // FETCH ONCE
  // =========================================================

  Future<List<MBPromoCode>> fetchPromosOnce() async {
    final snapshot = await promosCollection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MBPromoCode.fromMap(doc.data()))
        .toList();
  }

  // =========================================================
  // CREATE PROMO
  // =========================================================

  Future<void> createPromo(MBPromoCode promo) async {
    final doc = promosCollection.doc(promo.id);

    // Ensure unique promo code
    final existing = await promosCollection
        .where('code', isEqualTo: promo.code)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Promo code already exists.');
    }

    await doc.set(promo.toMap());
  }

  // =========================================================
  // UPDATE PROMO
  // =========================================================

  Future<void> updatePromo(MBPromoCode promo) async {
    final doc = promosCollection.doc(promo.id);

    final exists = await doc.get();
    if (!exists.exists) {
      throw Exception('Promo not found.');
    }

    await doc.set(
      promo.toMap(),
      SetOptions(merge: true),
    );
  }

  // =========================================================
  // DELETE PROMO (SOFT DELETE RECOMMENDED)
  // =========================================================

  Future<void> deletePromo(String promoId) async {
    final doc = promosCollection.doc(promoId);

    final exists = await doc.get();
    if (!exists.exists) {
      throw Exception('Promo not found.');
    }

    // 🔒 Enterprise-safe: archive instead of delete
    await doc.update({
      'isArchived': true,
    });
  }

  // =========================================================
  // TOGGLE ACTIVE STATE
  // =========================================================

  Future<void> setPromoActiveState({
    required String promoId,
    required bool isActive,
  }) async {
    final doc = promosCollection.doc(promoId);

    await doc.update({
      'isActive': isActive,
    });
  }

  // =========================================================
  // OPTIONAL: HARD DELETE (RARELY USED)
  // =========================================================

  Future<void> hardDeletePromo(String promoId) async {
    await promosCollection.doc(promoId).delete();
  }

  // =========================================================
  // OPTIONAL: INCREMENT USAGE COUNT (ORDER SYSTEM)
  // =========================================================

  Future<void> incrementUsage(String promoId) async {
    await promosCollection.doc(promoId).update({
      'usageCount': FieldValue.increment(1),
    });
  }
}