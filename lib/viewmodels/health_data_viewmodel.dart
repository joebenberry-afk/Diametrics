import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/health_data_repository.dart';
import 'package:flutter/material.dart';
import '../models/glucose_log.dart';
import '../models/meal_log.dart';
import '../models/medication_log.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../core/theme/app_tokens.dart';

final healthDataRepositoryProvider = Provider<HealthDataRepository>((ref) {
  return HealthDataRepository();
});

final glucoseLogsProvider =
    AsyncNotifierProvider<GlucoseLogsViewModel, List<GlucoseLog>>(
      GlucoseLogsViewModel.new,
    );

class GlucoseLogsViewModel extends AsyncNotifier<List<GlucoseLog>> {
  @override
  FutureOr<List<GlucoseLog>> build() async {
    return _fetchLogs();
  }

  Future<List<GlucoseLog>> _fetchLogs() async {
    final repo = ref.read(healthDataRepositoryProvider);
    return repo.getGlucoseLogs();
  }

  Future<void> addLog(GlucoseLog log) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(healthDataRepositoryProvider);
      await repo.addGlucoseLog(log);
      return _fetchLogs();
    });
  }
}

final mealLogsProvider =
    AsyncNotifierProvider<MealLogsViewModel, List<MealLog>>(
      MealLogsViewModel.new,
    );

class MealLogsViewModel extends AsyncNotifier<List<MealLog>> {
  @override
  FutureOr<List<MealLog>> build() async {
    return _fetchLogs();
  }

  Future<List<MealLog>> _fetchLogs() async {
    final repo = ref.read(healthDataRepositoryProvider);
    return repo.getMealLogs();
  }

  Future<void> addLog(MealLog log) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(healthDataRepositoryProvider);
      await repo.addMealLog(log);
      return _fetchLogs();
    });
  }
}

final medicationLogsProvider =
    AsyncNotifierProvider<MedicationLogsViewModel, List<MedicationLog>>(
      MedicationLogsViewModel.new,
    );

class MedicationLogsViewModel extends AsyncNotifier<List<MedicationLog>> {
  @override
  FutureOr<List<MedicationLog>> build() async {
    return _fetchLogs();
  }

  Future<List<MedicationLog>> _fetchLogs() async {
    final repo = ref.read(healthDataRepositoryProvider);
    return repo.getMedicationLogs();
  }

  Future<void> addLog(MedicationLog log) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(healthDataRepositoryProvider);
      await repo.addMedicationLog(log);
      return _fetchLogs();
    });
  }
}

/// Latest glucose reading (most recent GlucoseLog, any context).
final latestGlucoseProvider = Provider<AsyncValue<GlucoseLog?>>((ref) {
  return ref.watch(glucoseLogsProvider).whenData((logs) {
    if (logs.isEmpty) return null;
    final sorted = List<GlucoseLog>.from(logs);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.first;
  });
});

/// Today's total calories from MealLogs.
final todayCaloriesProvider = Provider<AsyncValue<double>>((ref) {
  return ref.watch(mealLogsProvider).whenData((logs) {
    final today = DateTime.now();
    return logs
        .where(
          (l) =>
              l.timestamp.year == today.year &&
              l.timestamp.month == today.month &&
              l.timestamp.day == today.day,
        )
        .fold(0.0, (sum, l) => sum + l.calories);
  });
});

/// Today's medication dose count.
final todayDoseCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(medicationLogsProvider).whenData((logs) {
    final today = DateTime.now();
    return logs
        .where(
          (l) =>
              l.timestamp.year == today.year &&
              l.timestamp.month == today.month &&
              l.timestamp.day == today.day,
        )
        .length;
  });
});

enum GlucoseAlertLevel { none, hypo, hyperElevated, hyperHigh }

/// Returns the alert level for the most recent glucose reading against user targets.
final glucoseAlertProvider = Provider<GlucoseAlertLevel>((ref) {
  final latest = ref.watch(latestGlucoseProvider).valueOrNull;
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (latest == null || profile == null) return GlucoseAlertLevel.none;

  final v = latest.value;
  if (v < profile.targetGlucoseMin) return GlucoseAlertLevel.hypo;
  if (v > profile.targetGlucoseMax + 70) return GlucoseAlertLevel.hyperHigh;
  if (v > profile.targetGlucoseMax) return GlucoseAlertLevel.hyperElevated;
  return GlucoseAlertLevel.none;
});

/// Last 5 log entries across all types, sorted newest first.
/// Each entry is a map with keys: type (String), label (String), subtitle (String), timestamp (DateTime), icon (IconData), color (Color).
final recentActivityProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((
  ref,
) {
  final glucoseAsync = ref.watch(glucoseLogsProvider);
  final mealsAsync = ref.watch(mealLogsProvider);
  final medsAsync = ref.watch(medicationLogsProvider);

  if (glucoseAsync.isLoading || mealsAsync.isLoading || medsAsync.isLoading) {
    return const AsyncLoading();
  }

  final entries = <Map<String, dynamic>>[];

  glucoseAsync.valueOrNull?.forEach(
    (g) => entries.add({
      'type': 'glucose',
      'label': '${g.value.toStringAsFixed(0)} ${g.unit}',
      'subtitle': g.context.replaceAll('_', ' '),
      'timestamp': g.timestamp,
      'icon': Icons.bloodtype_outlined,
      'color': AppThemeTokens.brandPrimary,
    }),
  );

  mealsAsync.valueOrNull?.forEach(
    (m) => entries.add({
      'type': 'meal',
      'label':
          m.name ?? '${m.mealType[0].toUpperCase()}${m.mealType.substring(1)}',
      'subtitle':
          '${m.carbohydrates.toStringAsFixed(0)}g carbs • ${m.calories.toStringAsFixed(0)} kcal',
      'timestamp': m.timestamp,
      'icon': Icons.restaurant_outlined,
      'color': AppThemeTokens.brandSuccess,
    }),
  );

  medsAsync.valueOrNull?.forEach(
    (med) => entries.add({
      'type': 'medication',
      'label': med.name ?? med.medicationType.replaceAll('_', ' '),
      'subtitle': '${med.units.toStringAsFixed(1)} units',
      'timestamp': med.timestamp,
      'icon': Icons.medication_outlined,
      'color': AppThemeTokens.brandAccent,
    }),
  );

  entries.sort(
    (a, b) =>
        (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
  );
  return AsyncData(entries.take(5).toList());
});

class DailySummary {
  final double avgGlucose;
  final double totalCarbs;
  final double totalCalories;
  final int glucoseReadings;
  final int mealsLogged;
  final int dosesLogged;
  final double timeInRangePct;

  const DailySummary({
    required this.avgGlucose,
    required this.totalCarbs,
    required this.totalCalories,
    required this.glucoseReadings,
    required this.mealsLogged,
    required this.dosesLogged,
    required this.timeInRangePct,
  });
}

final dailySummaryProvider = Provider<AsyncValue<DailySummary>>((ref) {
  final glucoseAsync = ref.watch(glucoseLogsProvider);
  final mealsAsync = ref.watch(mealLogsProvider);
  final medsAsync = ref.watch(medicationLogsProvider);
  final profile = ref.watch(userProfileProvider).valueOrNull;

  if (glucoseAsync.isLoading || mealsAsync.isLoading || medsAsync.isLoading) {
    return const AsyncLoading();
  }

  final today = DateTime.now();
  bool isToday(DateTime dt) =>
      dt.year == today.year && dt.month == today.month && dt.day == today.day;

  final todayGlucose = (glucoseAsync.valueOrNull ?? [])
      .where((l) => isToday(l.timestamp))
      .toList();
  final todayMeals = (mealsAsync.valueOrNull ?? [])
      .where((l) => isToday(l.timestamp))
      .toList();
  final todayMeds = (medsAsync.valueOrNull ?? [])
      .where((l) => isToday(l.timestamp))
      .toList();

  final targetMin = profile?.targetGlucoseMin ?? 70.0;
  final targetMax = profile?.targetGlucoseMax ?? 180.0;

  final avgGlucose = todayGlucose.isEmpty
      ? 0.0
      : todayGlucose.map((g) => g.value).reduce((a, b) => a + b) /
            todayGlucose.length;
  final inRange = todayGlucose
      .where((g) => g.value >= targetMin && g.value <= targetMax)
      .length;
  final tir = todayGlucose.isEmpty
      ? 0.0
      : (inRange / todayGlucose.length) * 100;
  final totalCarbs = todayMeals.fold(0.0, (sum, m) => sum + m.carbohydrates);
  final totalCalories = todayMeals.fold(0.0, (sum, m) => sum + m.calories);

  return AsyncData(
    DailySummary(
      avgGlucose: avgGlucose,
      totalCarbs: totalCarbs,
      totalCalories: totalCalories,
      glucoseReadings: todayGlucose.length,
      mealsLogged: todayMeals.length,
      dosesLogged: todayMeds.length,
      timeInRangePct: tir,
    ),
  );
});
