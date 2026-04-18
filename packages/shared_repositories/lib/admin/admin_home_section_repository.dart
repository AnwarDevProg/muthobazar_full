import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';

class AdminHomeSectionRepository {
  AdminHomeSectionRepository._();

  static final AdminHomeSectionRepository instance =
  AdminHomeSectionRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get sectionsCollection =>
      _firestore.collection('home_sections');

  Stream<List<MBHomeSection>> watchSections() {
    return sectionsCollection.snapshots().map((snapshot) {
      final items = snapshot.docs.map(_fromDoc).toList(growable: false);
      return _sortItems(items);
    });
  }

  Future<List<MBHomeSection>> fetchSectionsOnce() async {
    final snapshot = await sectionsCollection.get();
    final items = snapshot.docs.map(_fromDoc).toList(growable: false);
    return _sortItems(items);
  }

  Future<int> suggestSortOrder({
    String? excludeSectionId,
  }) async {
    final snapshot = await sectionsCollection.get();
    final excludedId = (excludeSectionId ?? '').trim();

    final used = <int>{};

    for (final doc in snapshot.docs) {
      if (excludedId.isNotEmpty && doc.id == excludedId) {
        continue;
      }

      final raw = doc.data();
      final dynamic sortValue = raw['sortOrder'];
      final int? sortOrder = switch (sortValue) {
        int value => value,
        String value => int.tryParse(value.trim()),
        _ => null,
      };

      if (sortOrder != null && sortOrder >= 0) {
        used.add(sortOrder);
      }
    }

    var next = 0;
    while (used.contains(next)) {
      next++;
    }
    return next;
  }

  Future<bool> sortExists({
    required int sortOrder,
    String? excludeSectionId,
  }) async {
    final snapshot = await sectionsCollection
        .where('sortOrder', isEqualTo: sortOrder)
        .get();

    final excludedId = (excludeSectionId ?? '').trim();

    for (final doc in snapshot.docs) {
      if (excludedId.isNotEmpty && doc.id == excludedId) {
        continue;
      }
      return true;
    }

    return false;
  }

  Future<String> createSection(MBHomeSection section) async {
    final doc = section.id.trim().isEmpty
        ? sectionsCollection.doc()
        : sectionsCollection.doc(section.id.trim());

    final data = _sanitizeForSave(
      section.copyWith(id: doc.id),
    ).toMap();

    await doc.set(data);
    return doc.id;
  }

  Future<void> updateSection(MBHomeSection section) async {
    final id = section.id.trim();
    if (id.isEmpty) {
      throw Exception('Home section id is required for update.');
    }

    final docRef = sectionsCollection.doc(id);
    final existing = await docRef.get();
    if (!existing.exists) {
      throw Exception('Home section not found.');
    }

    final data = _sanitizeForSave(section).toMap();
    await docRef.set(data, SetOptions(merge: true));
  }

  Future<void> deleteSection(String sectionId) async {
    final id = sectionId.trim();
    if (id.isEmpty) {
      throw Exception('Home section id is required for delete.');
    }

    await sectionsCollection.doc(id).delete();
  }

  Future<void> setSectionActiveState({
    required String sectionId,
    required bool isActive,
  }) async {
    final id = sectionId.trim();
    if (id.isEmpty) {
      throw Exception('Home section id is required.');
    }

    await sectionsCollection.doc(id).update({
      'isActive': isActive,
    });
  }

  MBHomeSection _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final raw = Map<String, dynamic>.from(doc.data());
    raw['id'] = (raw['id'] ?? doc.id).toString();
    return MBHomeSection.fromMap(raw);
  }

  List<MBHomeSection> _sortItems(List<MBHomeSection> items) {
    final sorted = List<MBHomeSection>.from(items);
    sorted.sort((a, b) {
      final bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;

      final byType = a.sectionType
          .trim()
          .toLowerCase()
          .compareTo(b.sectionType.trim().toLowerCase());
      if (byType != 0) return byType;

      return a.titleEn.trim().toLowerCase().compareTo(
        b.titleEn.trim().toLowerCase(),
      );
    });
    return sorted;
  }

  MBHomeSection _sanitizeForSave(MBHomeSection section) {
    final sectionType = section.sectionType.trim().toLowerCase();
    final layoutStyle = section.layoutStyle.trim().toLowerCase();
    final dataSourceType = section.dataSourceType.trim().toLowerCase();

    final keepSourceCategoryId = dataSourceType == 'category';
    final keepSourceBrandId = dataSourceType == 'brand';

    return section.copyWith(
      id: section.id.trim(),
      titleEn: section.titleEn.trim(),
      titleBn: section.titleBn.trim(),
      subtitleEn: section.subtitleEn.trim(),
      subtitleBn: section.subtitleBn.trim(),
      sectionType: sectionType.isEmpty ? 'product_horizontal' : sectionType,
      layoutStyle: layoutStyle.isEmpty ? 'standard' : layoutStyle,
      bannerIds: _normalizeIdList(section.bannerIds),
      offerIds: _normalizeIdList(section.offerIds),
      productIds: _normalizeIdList(section.productIds),
      categoryIds: _normalizeIdList(section.categoryIds),
      brandIds: _normalizeIdList(section.brandIds),
      dataSourceType: dataSourceType.isEmpty ? 'manual' : dataSourceType,
      sourceCategoryId: keepSourceCategoryId
          ? _normalizedOrNull(section.sourceCategoryId)
          : null,
      clearSourceCategoryId: !keepSourceCategoryId,
      sourceBrandId:
      keepSourceBrandId ? _normalizedOrNull(section.sourceBrandId) : null,
      clearSourceBrandId: !keepSourceBrandId,
      itemLimit: section.itemLimit < 1 ? 1 : section.itemLimit,
      sortOrder: section.sortOrder < 0 ? 0 : section.sortOrder,
    );
  }

  List<String> _normalizeIdList(List<dynamic> values) {
    final result = <String>[];
    final seen = <String>{};

    for (final value in values) {
      final normalized = value.toString().trim();
      if (normalized.isEmpty) {
        continue;
      }
      if (seen.add(normalized)) {
        result.add(normalized);
      }
    }

    return result;
  }

  String? _normalizedOrNull(String? value) {
    final normalized = (value ?? '').trim();
    return normalized.isEmpty ? null : normalized;
  }
}
