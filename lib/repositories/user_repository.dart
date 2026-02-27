import 'package:sqflite/sqflite.dart';

import '../core/database/database_helper.dart';
import '../models/user_profile.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> saveProfile(UserProfile profile) async {
    final db = await _dbHelper.database;
    final map = profile.toJson();

    // Convert booleans to SQLite integers and dates to ISO8601 strings
    map['usesInsulin'] = profile.usesInsulin ? 1 : 0;
    map['usesPills'] = profile.usesPills ? 1 : 0;
    map['usesCgm'] = profile.usesCgm ? 1 : 0;
    map['hasAgreedToDisclaimer'] = profile.hasAgreedToDisclaimer ? 1 : 0;
    map['createdAt'] = profile.createdAt.toIso8601String();
    map['updatedAt'] = profile.updatedAt.toIso8601String();

    await db.insert(
      'user_profiles',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getProfile() async {
    final db = await _dbHelper.database;
    final maps = await db.query('user_profiles', limit: 1);

    if (maps.isEmpty) return null;

    final map = Map<String, dynamic>.from(maps.first);

    // Convert SQLite integers back to booleans
    map['usesInsulin'] = map['usesInsulin'] == 1;
    map['usesPills'] = map['usesPills'] == 1;
    map['usesCgm'] = map['usesCgm'] == 1;
    map['hasAgreedToDisclaimer'] = map['hasAgreedToDisclaimer'] == 1;

    return UserProfile.fromJson(map);
  }
}
