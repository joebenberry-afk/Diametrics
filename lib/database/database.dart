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
