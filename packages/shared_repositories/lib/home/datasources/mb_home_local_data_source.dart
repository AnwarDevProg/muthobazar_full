import 'dart:convert';

import 'package:hive/hive.dart';

import '../models/mb_home_cache_bundle.dart';

// MB Home Local Data Source
// -------------------------
// Real persistent local cache using Hive.
// Stores full home bundle as JSON string.
//
// Why JSON string?
// - no Hive adapters needed
// - works with current model toMap/fromMap structure
// - easy migration later

abstract class MBHomeLocalDataSource {
  Future<MBHomeCacheBundle?> readHomeBundle();
  Future<void> saveHomeBundle(MBHomeCacheBundle bundle);
  Future<void> clearHomeBundle();
}

class MBHiveHomeLocalDataSource implements MBHomeLocalDataSource {
  static const String _boxName = 'mb_home_cache_box';
  static const String _bundleKey = 'home_bundle';

  Future<Box<String>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return Hive.openBox<String>(_boxName);
  }

  @override
  Future<MBHomeCacheBundle?> readHomeBundle() async {
    final box = await _openBox();
    final rawJson = box.get(_bundleKey);

    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final map = json.decode(rawJson) as Map<String, dynamic>;
      return MBHomeCacheBundle.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveHomeBundle(MBHomeCacheBundle bundle) async {
    final box = await _openBox();
    final rawJson = json.encode(bundle.toMap());
    await box.put(_bundleKey, rawJson);
  }

  @override
  Future<void> clearHomeBundle() async {
    final box = await _openBox();
    await box.delete(_bundleKey);
  }
}











