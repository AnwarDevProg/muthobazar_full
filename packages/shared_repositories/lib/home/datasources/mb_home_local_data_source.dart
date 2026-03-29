import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:shared_models/home/mb_home_cache_bundle.dart';

// MB Home Local Data Source
// -------------------------
// Real persistent local cache using Hive.
// Stores full home bundle as JSON string.

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
    final Box<String> box = await _openBox();
    final String? rawJson = box.get(_bundleKey);

    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      final Object decoded = json.decode(rawJson);

      if (decoded is! Map) {
        await box.delete(_bundleKey);
        return null;
      }

      return MBHomeCacheBundle.fromMap(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      await box.delete(_bundleKey);
      return null;
    }
  }

  @override
  Future<void> saveHomeBundle(MBHomeCacheBundle bundle) async {
    final Box<String> box = await _openBox();
    final String rawJson = json.encode(bundle.toMap());
    await box.put(_bundleKey, rawJson);
  }

  @override
  Future<void> clearHomeBundle() async {
    final Box<String> box = await _openBox();
    await box.delete(_bundleKey);
  }
}