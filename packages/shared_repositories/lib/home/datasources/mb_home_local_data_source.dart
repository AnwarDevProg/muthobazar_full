import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    return Hive.openBox<dynamic>(_boxName);
  }

  @override
  Future<MBHomeCacheBundle?> readHomeBundle() async {
    final Box<dynamic> box = await _openBox();
    final String? rawJson = box.get(_bundleKey) as String?;

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
    final Box<dynamic> box = await _openBox();

    final Map<String, dynamic> rawMap =
    Map<String, dynamic>.from(bundle.toMap());

    final Object? safeMap = _jsonSafe(rawMap);
    final String rawJson = json.encode(safeMap);

    await box.put(_bundleKey, rawJson);
  }

  @override
  Future<void> clearHomeBundle() async {
    final Box<dynamic> box = await _openBox();
    await box.delete(_bundleKey);
  }

  Object? _jsonSafe(Object? value) {
    if (value == null ||
        value is String ||
        value is num ||
        value is bool) {
      return value;
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }

    if (value is Iterable) {
      return value.map(_jsonSafe).toList(growable: false);
    }

    if (value is Map) {
      return value.map(
            (key, val) => MapEntry(
          key.toString(),
          _jsonSafe(val),
        ),
      );
    }

    if (value is Enum) {
      return value.name;
    }

    return value.toString();
  }
}