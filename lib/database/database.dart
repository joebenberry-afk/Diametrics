import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
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
  AppDatabase() : super(_openConnection());

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
  return (select(logs)
        ..orderBy([(l) => OrderingTerm.desc(l.timestamp)]))
      .get();
}

Future deleteLog(int id) =>
    (delete(logs)..where((t) => t.id.equals(id))).go();

  Future<List<Log>> getRecentLogs(Duration window) {
    final cutoff = DateTime.now().subtract(window);
    return (select(logs)..where((l) => l.timestamp.isBiggerThanValue(cutoff)))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.db'));
    return NativeDatabase(file);
  });
}
