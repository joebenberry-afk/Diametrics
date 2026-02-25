import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

import 'database.dart';

/// Global singleton database instance.
///
/// Uses [openEncryptedDatabase] to create an AES-256 encrypted
/// SQLite database via SQLCipher. Must be initialized with [initDatabase]
/// before use.
AppDatabase? _db;

/// Returns the initialized [AppDatabase]. Throws if [initDatabase] has not
/// been called yet.
AppDatabase get db {
  final instance = _db;
  if (instance == null) {
    throw StateError('Database not initialized. Call initDatabase() first.');
  }
  return instance;
}

/// Initializes the encrypted database. Safe to call multiple times; subsequent
/// calls are no-ops if the database is already open.
Future<void> initDatabase() async {
  if (_db != null) return;
  final executor = await openEncryptedDatabase();
  _db = AppDatabase(executor);
}

/// Migrates or generates a secure AES-256 key and returns the encrypted database connection.
Future<QueryExecutor> openEncryptedDatabase() async {
  // On Android, we must tell the sqlite3 package to load libsqlcipher.so
  // instead of the default libsqlite3.so (which is not bundled).
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
  }

  const secureStorage = FlutterSecureStorage();
  String? dbKey = await secureStorage.read(key: 'sqlcipher_db_key');

  if (dbKey == null) {
    // 1. Try to migrate from insecure SharedPreferences (if it exists)
    final prefs = await SharedPreferences.getInstance();
    // Use the generic key name the user might have used during testing
    dbKey = prefs.getString('db_key');

    if (dbKey != null) {
      // 2. Migrate to secure storage and delete the vulnerable plaintext copy
      await secureStorage.write(key: 'sqlcipher_db_key', value: dbKey);
      await prefs.remove('db_key');
      debugPrint(
        'Security: Migrated database key from SharedPreferences to Keystore.',
      );
    } else {
      // 3. Generate a brand new cryptographically secure 256-bit key
      final random = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
      dbKey = base64UrlEncode(keyBytes);

      await secureStorage.write(key: 'sqlcipher_db_key', value: dbKey);
      debugPrint('Security: Generated new hardware-backed database key.');
    }
  }

  // Get the database path
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'app.db'));

  // 4. Return the database with the encryption pragma injected on setup
  return NativeDatabase.createInBackground(
    file,
    setup: (db) {
      // PRAGMA key must be the very first command executed on the database
      // The key is wrapped in single quotes as required by SQLCipher
      db.execute("PRAGMA key = '$dbKey'");
    },
  );
}
