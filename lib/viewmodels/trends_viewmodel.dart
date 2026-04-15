import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/glucose_log.dart';
import '../models/meal_log.dart';
import '../models/medication_log.dart';
import 'health_data_viewmodel.dart';

class TrendsData {
  final List<GlucoseLog> glucoseLogs;
  final List<MealLog> mealLogs;
  final List<MedicationLog> medicationLogs;

  const TrendsData({
    required this.glucoseLogs,
    required this.mealLogs,
    required this.medicationLogs,
  });
}

/// Selected time range in days. Defaults to 7.
final selectedRangeProvider = StateProvider<int>((ref) => 7);

/// Currently selected day for intra-day drill-down. Null = overview mode.
final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

final trendsProvider =
    AsyncNotifierProvider<TrendsViewModel, TrendsData>(TrendsViewModel.new);

class TrendsViewModel extends AsyncNotifier<TrendsData> {
  @override
  Future<TrendsData> build() async {
    final days = ref.watch(selectedRangeProvider);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final repo = ref.read(healthDataRepositoryProvider);

    final allGlucose = await repo.getGlucoseLogs();
    final allMeals = await repo.getMealLogs();
    final allMeds = await repo.getMedicationLogs();

    return TrendsData(
      glucoseLogs: allGlucose
          .where((g) => g.timestamp.isAfter(cutoff))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
      mealLogs: allMeals.where((m) => m.timestamp.isAfter(cutoff)).toList(),
      medicationLogs:
          allMeds.where((m) => m.timestamp.isAfter(cutoff)).toList(),
    );
  }
}
