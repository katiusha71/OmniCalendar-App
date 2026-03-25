import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Database? _prefsDb;

  Future<Database> get _database async {
    if (_prefsDb != null) return _prefsDb!;
    final dbPath = await getDatabasesPath();
    _prefsDb = await openDatabase(
      '$dbPath/omni_prefs.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE prefs (key TEXT PRIMARY KEY, value TEXT)',
        );
      },
    );
    return _prefsDb!;
  }

  Future<void> save(String key, String value) async {
    try {
      final db = await _database;
      await db.insert(
        'prefs',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('StorageService save error: $e');
    }
  }

  Future<String?> get(String key) async {
    try {
      final db = await _database;
      final result = await db.query('prefs', where: 'key = ?', whereArgs: [key]);
      if (result.isNotEmpty) {
        return result.first['value'] as String?;
      }
    } catch (e) {
      debugPrint('StorageService get error: $e');
    }
    return null;
  }

  Future<void> remove(String key) async {
    try {
      final db = await _database;
      await db.delete('prefs', where: 'key = ?', whereArgs: [key]);
    } catch (e) {
      debugPrint('StorageService remove error: $e');
    }
  }
}
