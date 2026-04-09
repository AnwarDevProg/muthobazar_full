import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'mb_admin_repository_errors.dart';
import 'mb_admin_slug_utils.dart';

// Reusable ca([github.com](https://github.com/AnwarDevProg/muthobazar_full/tree/main/packages/shared_repositories/lib))ry base for flat admin entities.
// Category and brand can both use this for the shared Firestore + Functions
// access pattern while keeping their entity-specific parsing and guards.
abstract class MBAdminCallableRepositoryBase<T> {
  MBAdminCallableRepositoryBase({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    this.region = 'asia-south1',
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instanceFor(region: region);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final String region;

  String get collectionPath;

  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(collectionPath);

  HttpsCallable callable(String name) => _functions.httpsCallable(name);

  T fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc);

  List<T> sortItems(List<T> items) => items;

  String normalizeSlug(String value) => MBAdminSlugUtils.normalize(value);

  int parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String parseString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return defaultValue;
  }

  Exception firestoreException(
    FirebaseException error, {
    String? fallback,
  }) {
    return MBAdminRepositoryErrors.asException(
      MBAdminRepositoryErrors.firestore(error, fallback: fallback),
    );
  }

  Exception callableException(
    FirebaseFunctionsException error, {
    String fallback = 'Cloud Function request failed.',
  }) {
    return MBAdminRepositoryErrors.asException(
      MBAdminRepositoryErrors.callable(error, fallback: fallback),
    );
  }

  Future<R> guardFirestore<R>(Future<R> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      throw firestoreException(error);
    }
  }

  Future<R> guardCallable<R>(
    Future<R> Function() action, {
    String fallback = 'Cloud Function request failed.',
  }) async {
    try {
      return await action();
    } on FirebaseFunctionsException catch (error) {
      throw callableException(error, fallback: fallback);
    } on FirebaseException catch (error) {
      throw firestoreException(error);
    }
  }

  Stream<List<T>> watchAll({
    Duration timeout = const Duration(seconds: 15),
  }) {
    return collection.snapshots().map((snapshot) {
      final List<T> items = <T>[];
      for (final doc in snapshot.docs) {
        items.add(fromDoc(doc));
      }
      return sortItems(items);
    }).handleError((Object error) {
      if (error is FirebaseException) {
        throw firestoreException(error);
      }
      throw error;
    });
  }

  Future<List<T>> fetchAll({
    Duration timeout = const Duration(seconds: 15),
    String? timeoutMessage,
  }) async {
    return guardFirestore(() async {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await collection.get().timeout(
        timeout,
        onTimeout: () {
          throw Exception(
            timeoutMessage ??
                'Timed out while loading admin data from Firestore.',
          );
        },
      );

      if (snapshot.docs.isEmpty) {
        return <T>[];
      }

      final List<T> items = <T>[];
      for (final doc in snapshot.docs) {
        items.add(fromDoc(doc));
      }
      return sortItems(items);
    });
  }

  Future<bool> slugExists({
    required String slug,
    String? excludeId,
    String fieldName = 'slug',
    Duration timeout = const Duration(seconds: 15),
    String timeoutMessage = 'Timed out while checking slug uniqueness.',
  }) async {
    return guardFirestore(() async {
      final String normalizedSlug = normalizeSlug(slug);
      if (normalizedSlug.isEmpty) return false;

      final QuerySnapshot<Map<String, dynamic>> query = await collection
          .where(fieldName, isEqualTo: normalizedSlug)
          .get()
          .timeout(
        timeout,
        onTimeout: () {
          throw Exception(timeoutMessage);
        },
      );

      if (query.docs.isEmpty) {
        return false;
      }

      final String safeExcludeId = excludeId?.trim() ?? '';
      if (safeExcludeId.isEmpty) {
        return true;
      }

      return query.docs.any((doc) => doc.id != safeExcludeId);
    });
  }

  Future<bool> intFieldExists({
    required int value,
    required String fieldName,
    String? excludeId,
    Duration timeout = const Duration(seconds: 15),
    String timeoutMessage = 'Timed out while checking field uniqueness.',
  }) async {
    return guardFirestore(() async {
      final QuerySnapshot<Map<String, dynamic>> query = await collection
          .where(fieldName, isEqualTo: value)
          .get()
          .timeout(
        timeout,
        onTimeout: () {
          throw Exception(timeoutMessage);
        },
      );

      if (query.docs.isEmpty) {
        return false;
      }

      final String safeExcludeId = excludeId?.trim() ?? '';
      if (safeExcludeId.isEmpty) {
        return true;
      }

      return query.docs.any((doc) => doc.id != safeExcludeId);
    });
  }

  Future<int> suggestLowestMissingNonNegativeInt({
    required int Function(T item) selector,
    String? excludeId,
    String Function(T item)? idSelector,
  }) async {
    final List<T> items = await fetchAll();
    final String safeExcludeId = excludeId?.trim() ?? '';

    final List<int> used = items
        .where((item) {
          if (safeExcludeId.isEmpty || idSelector == null) {
            return true;
          }
          return idSelector(item).trim() != safeExcludeId;
        })
        .map(selector)
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
}
