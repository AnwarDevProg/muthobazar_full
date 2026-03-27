import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mobile_admin_purchase_model.dart';

class MobileAdminPurchaseRepository {
  MobileAdminPurchaseRepository._();

  static final MobileAdminPurchaseRepository instance =
  MobileAdminPurchaseRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _purchaseCollection =>
      _firestore.collection('purchases');

  Stream<List<MobileAdminPurchaseModel>> watchPurchases() {
    return _purchaseCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MobileAdminPurchaseModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<List<MobileAdminPurchaseModel>> fetchPurchasesOnce() async {
    final snapshot =
    await _purchaseCollection.orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) => MobileAdminPurchaseModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<MobileAdminPurchaseModel?> fetchPurchaseById(String id) async {
    final doc = await _purchaseCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;

    return MobileAdminPurchaseModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> createPurchase({
    required MobileAdminPurchaseModel purchase,
    required String actorUid,
  }) async {
    final doc = _purchaseCollection.doc();

    await doc.set({
      ...purchase.copyWith(
        id: doc.id,
        createdByUid: actorUid,
        updatedByUid: actorUid,
      ).toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePurchase({
    required MobileAdminPurchaseModel purchase,
    required String actorUid,
  }) async {
    await _purchaseCollection.doc(purchase.id).set(
      {
        ...purchase.copyWith(
          updatedByUid: actorUid,
        ).toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> deletePurchase(String purchaseId) async {
    await _purchaseCollection.doc(purchaseId).delete();
  }
}











