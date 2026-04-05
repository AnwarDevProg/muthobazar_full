import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/admin/mb_admin_activity_log.dart';

class AdminActivityLogRepository {
  AdminActivityLogRepository._();

  static final AdminActivityLogRepository instance =
  AdminActivityLogRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('admin_activity_logs');

  // 🔥 MAIN STREAM FOR UI
  Stream<List<MBAdminActivityLog>> watchActivityLogs({
    int limit = 200,
  }) {
    return _collection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(_fromDoc).toList();
    });
  }

  // 🔥 PAGINATION (KEEPED)
  Future<List<MBAdminActivityLog>> fetchLogs({
    int limit = 50,
  }) async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map(_fromDoc).toList();
  }

  // 🔥 INTERNAL
  MBAdminActivityLog _fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return MBAdminActivityLog.fromMap({
      ...data,
      'id': doc.id,
    });
  }
}