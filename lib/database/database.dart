import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// NOTE: Temporarily using shared_preferences for the encryption key since flutter_secure_storage
// is failing to compile on Windows due to a missing C++ header dependency.
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Logs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get bgValue => real().nullable()();
  TextColumn get bgUnit => text().withDefault(const Constant('mmol/L'))();
  TextColumn get contextTags => text().nullable()();
  TextColumn get foodVolume => text().nullable()();
  BoolColumn get finishedMeal => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Logs])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Constructor for testing with custom executor (e.g., in-memory database)
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  Future<int> insertGlucoseLog({
    required DateTime timestamp,
    required double bgValue,
    String bgUnit = 'mmol/L',
  }) {
    return into(logs).insert(
      LogsCompanion.insert(
        timestamp: timestamp,
        bgValue: Value(bgValue),
        bgUnit: Value(bgUnit),
      ),
    );
  }

  Future<List<Log>> getLogsLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (select(logs)
          ..where((l) => l.timestamp.isBiggerThanValue(cutoff))
          ..orderBy([(l) => OrderingTerm.desc(l.timestamp)]))
        .get();
  }

  Future<List<Log>> getAllLogs() {
    return (select(
      logs,
    )..orderBy([(l) => OrderingTerm.desc(l.timestamp)])).get();
  }

  Future deleteLog(int id) =>
      (delete(logs)..where((t) => t.id.equals(id))).go();

  Future<List<Log>> getRecentLogs(Duration window) {
    final cutoff = DateTime.now().subtract(window);
    return (select(
      logs,
    )..where((l) => l.timestamp.isBiggerThanValue(cutoff))).get();
  }
}

/// Securely generates or retrieves the AES-256 encryption key.
///
/// Due to local build constraints on Windows with `flutter_secure_storage`,
/// this fallback temporarily uses SharedPreferences.
Future<String> _getOrCreateEncryptionKey() async {
  final prefs = await SharedPreferences.getInstance();
  const keyName = 'diametrics_db_key_fallback';

  String? existingKey = prefs.getString(keyName);
  if (existingKey != null) {
    return existingKey;
  }

  // Generate a 32-byte (256-bit) random key as hex
  final random = Random.secure();
  final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
  final newKey = keyBytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  await prefs.setString(keyName, newKey);
  return newKey;
}

/// Opens an AES-256 encrypted SQLite database using SQLCipher.
Future<NativeDatabase> openEncryptedDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'app.db'));
  final encryptionKey = await _getOrCreateEncryptionKey();

  return NativeDatabase(
    file,
    setup: (rawDb) {
      // PRAGMA key must be the first statement executed on the database.
      // This sets the AES-256 encryption key for SQLCipher.
      rawDb.execute("PRAGMA key = '$encryptionKey'");
    },
  );
}
