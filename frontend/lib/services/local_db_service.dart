import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class LocalDbService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'WealthWise_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE app_settings (
            id TEXT PRIMARY KEY,
            settings_json TEXT
          )
        ''');
      },
    );
  }

  static Future<void> saveSettings(String id, Map<String, dynamic> settings) async {
    try {
      final db = await database;
      // Merge with existing settings if any
      final existing = await getSettings(id);
      final finalSettings = {
        ...?existing,
        ...settings,
      };
      
      final jsonStr = jsonEncode(finalSettings);
      await db.insert(
        'app_settings',
        {'id': id, 'settings_json': jsonStr},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('LocalDbService save error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getSettings(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'app_settings',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return jsonDecode(maps.first['settings_json'] as String) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('LocalDbService get error: $e');
    }
    return null;
  }
}
