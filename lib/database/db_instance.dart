import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

AppDatabase? _db;

/// Test-only seam: injects an [AppDatabase] (typically an in-memory instance)
/// so services that read the global [db] can be exercised without a real
/// device database.
@visibleForTesting
void setDbForTesting(AppDatabase database) => _db = database;

/// Returns the initialized [AppDatabase]. Throws if [initDatabase] has not
/// been called yet.
AppDatabase get db {
  final instance = _db;
  if (instance == null) {
    throw StateError('Database not initialized. Call initDatabase() first.');
  }
  return instance;
}

/// Opens the SQLite database. Safe to call multiple times; subsequent calls
/// are no-ops if the database is already open.
///
/// Intentionally does NOT send a warmup query here — that would block
/// [main()] before [runApp()] and show a frozen native splash. The background
/// isolate spins up concurrently while Flutter is drawing its first frame.
Future<void> initDatabase() async {
  if (_db != null) return;
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'app.db'));
  _db = AppDatabase(NativeDatabase.createInBackground(file));
}
