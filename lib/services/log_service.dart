import 'package:diametrics/database/db_instance.dart';
import 'package:diametrics/database/database.dart';

class LogService {
  Future<void> addGlucose(double value, {String unit = 'mmol/L'}) async {
  await db.insertGlucoseLog(
    timestamp: DateTime.now(),
    bgValue: value,
    bgUnit: unit,
  );
}

  Future<List<Log>> getLogsLast7Days() => db.getLogsLastDays(7);
}