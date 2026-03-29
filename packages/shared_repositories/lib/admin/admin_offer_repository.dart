import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';

class AdminOfferRepository {
  AdminOfferRepository._();

  static final AdminOfferRepository instance = AdminOfferRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get offersCollection =>
      _firestore.collection('offers');

  // =========================================================
  // WATCH OFFERS
  // =========================================================

  Stream<List<MBOffer>> watchOffers() {
    return offersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => MBOffer.fromMap(doc.data()))
          .toList(),
    );
  }

  // =========================================================
  // FETCH OFFERS ONCE
  // =========================================================

  Future<List<MBOffer>> fetchOffersOnce() async {
    final snapshot =
    await offersCollection.orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) => MBOffer.fromMap(doc.data()))
        .toList();
  }

  // =========================================================
  // CREATE OFFER
  // =========================================================

  Future<void> createOffer(MBOffer offer) async {
    final doc = offer.id.trim().isEmpty
        ? offersCollection.doc()
        : offersCollection.doc(offer.id);

    final now = DateTime.now();

    final data = offer
        .copyWith(
      id: doc.id,
      createdAt: offer.createdAt ?? now,
      updatedAt: now,
    )
        .toMap();

    await doc.set(data);
  }

  // =========================================================
  // UPDATE OFFER
  // =========================================================

  Future<void> updateOffer(MBOffer offer) async {
    final id = offer.id.trim();
    if (id.isEmpty) {
      throw Exception('Offer id is required for update.');
    }

    final docRef = offersCollection.doc(id);
    final existing = await docRef.get();

    if (!existing.exists) {
      throw Exception('Offer not found.');
    }

    final data = offer.copyWith(updatedAt: DateTime.now()).toMap();

    await docRef.set(data, SetOptions(merge: true));
  }

  // =========================================================
  // DELETE OFFER
  // =========================================================

  Future<void> deleteOffer(String id) async {
    final offerId = id.trim();
    if (offerId.isEmpty) {
      throw Exception('Offer id is required for delete.');
    }

    await offersCollection.doc(offerId).delete();
  }

  // =========================================================
  // TOGGLE ACTIVE STATE
  // =========================================================

  Future<void> setOfferActiveState({
    required String offerId,
    required bool isActive,
  }) async {
    final id = offerId.trim();
    if (id.isEmpty) {
      throw Exception('Offer id is required.');
    }

    await offersCollection.doc(id).update({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}