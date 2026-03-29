import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/admin/mb_admin_activity_log.dart';



class AdminActivityLogRepository {
  AdminActivityLogRepository._();

  static final AdminActivityLogRepository instance =
  AdminActivityLogRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get activityLogsCollection =>
      _firestore.collection('admin_activity_logs');

  Future<void> writeLog(MBAdminActivityLog log) async {
    final doc =
    log.id.trim().isEmpty ? activityLogsCollection.doc() : activityLogsCollection.doc(log.id);

    final now = DateTime.now();

    final payload = log.copyWith(
      id: doc.id,
      createdAt: now,
    );

    await doc.set(payload.toMap());
  }

  Stream<List<MBAdminActivityLog>> watchLogs({
    int limit = 100,
  }) {
    return activityLogsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MBAdminActivityLog.fromMap({
          ...data,
          'id': data['id'] ?? doc.id,
        });
      }).toList();
    });
  }

  Future<List<MBAdminActivityLog>> fetchLogsOnce({
    int limit = 100,
  }) async {
    final snapshot = await activityLogsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MBAdminActivityLog.fromMap({
        ...data,
        'id': data['id'] ?? doc.id,
      });
    }).toList();
  }
}











