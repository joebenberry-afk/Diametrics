import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../core/theme/app_tokens.dart';
import '../../models/glucose_log.dart';
import '../../models/meal_log.dart';
import '../../models/medication_log.dart';
import '../../router/route_names.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/trends_viewmodel.dart';

class TrendsView extends ConsumerWidget {
  const TrendsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDays = ref.watch(selectedRangeProvider);
    final trendsAsync = ref.watch(trendsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;

    final targetMin = profile?.targetGlucoseMin ?? 70.0;
    final targetMax = profile?.targetGlucoseMax ?? 180.0;
    final unit = profile?.preferredGlucoseUnit ?? 'mg/dL';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucose Trends'),
        backgroundColor: AppThemeTokens.brandPrimary,
        foregroundColor: AppThemeTokens.textPrimaryInverse,
        actions: [
          TextButton.icon(
            onPressed: () => context.push(Routes.glucoseHistory),
            icon: const Icon(
              Icons.list_alt,
              color: AppThemeTokens.textPrimaryInverse,
              size: 18,
            ),
            label: const Text(
              'All readings',
              style: TextStyle(color: AppThemeTokens.textPrimaryInverse),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: trendsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (data) => _TrendsContent(
            data: data,
            selectedDays: selectedDays,
            targetMin: targetMin,
            targetMax: targetMax,
            unit: unit,
          ),
        ),
      ),
    );
  }
}

class _TrendsContent extends StatelessWidget {
  final TrendsData data;
  final int selectedDays;
  final double targetMin;
  final double targetMax;
  final String unit;

  const _TrendsContent({
    required this.data,
    required this.selectedDays,
    required this.targetMin,
    required this.targetMax,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppThemeTokens.spaceMd),
        _RangeChips(selectedDays: selectedDays),
        const SizedBox(height: AppThemeTokens.spaceMd),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.38,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppThemeTokens.spaceMd,
            ),
            child: _GlucoseChart(
              glucoseLogs: data.glucoseLogs,
              mealLogs: data.mealLogs,
              medicationLogs: data.medicationLogs,
              targetMin: targetMin,
              targetMax: targetMax,
              preferredUnit: unit,
              selectedDays: selectedDays,
            ),
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceMd),
        _StatsRow(
          glucoseLogs: data.glucoseLogs,
          targetMin: targetMin,
          targetMax: targetMax,
          unit: unit,
          selectedDays: selectedDays,
        ),
        const Divider(height: AppThemeTokens.spaceLg),
        Expanded(
          child: _GlucoseLogList(logs: data.glucoseLogs, unit: unit),
        ),
      ],
    );
  }
}

// ── Range selector chips ────────────────────────────────────────────────────

class _RangeChips extends ConsumerWidget {
  final int selectedDays;
  const _RangeChips({required this.selectedDays});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [7, 30, 90].map((days) {
        final label = days == 7
            ? '7D'
            : days == 30
            ? '30D'
            : '90D';
        final isSelected = selectedDays == days;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemeTokens.spaceXs,
          ),
          child: ChoiceChip(
            label: Text(label),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) =>
                ref.read(selectedRangeProvider.notifier).state = days,
            selectedColor: AppThemeTokens.brandPrimary,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppThemeTokens.bgSurface,
            side: BorderSide(
              color: isSelected
                  ? AppThemeTokens.brandPrimary
                  : isDark
                  ? Colors.white.withValues(alpha: 0.35)
                  : AppThemeTokens.textSecondary.withValues(alpha: 0.3),
            ),
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isDark
                  ? Colors.white
                  : AppThemeTokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Chart ───────────────────────────────────────────────────────────────────

class _GlucoseChart extends StatelessWidget {
  final List<GlucoseLog> glucoseLogs;
  final List<MealLog> mealLogs;
  final List<MedicationLog> medicationLogs;
  final double targetMin;
  final double targetMax;
  final String preferredUnit;
  final int selectedDays;

  const _GlucoseChart({
    required this.glucoseLogs,
    required this.mealLogs,
    required this.medicationLogs,
    required this.targetMin,
    required this.targetMax,
    required this.preferredUnit,
    required this.selectedDays,
  });

  @override
  Widget build(BuildContext context) {
    if (glucoseLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.show_chart,
                size: 56,
                color: AppThemeTokens.brandPrimary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              const Text(
                'No glucose readings yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppThemeTokens.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),
              Text(
                'Log a glucose reading from the dashboard to see your trend chart here.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppThemeTokens.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Normalize a log value to the user's preferred unit.
    double toPreferred(double value, String logUnit) {
      if (logUnit == preferredUnit) return value;
      if (preferredUnit == 'mmol/L') return value / 18.0182;
      return value * 18.0182;
    }

    // Convert targetMin/targetMax (stored in mg/dL) to the preferred unit.
    final tMin = preferredUnit == 'mmol/L' ? targetMin / 18.0182 : targetMin;
    final tMax = preferredUnit == 'mmol/L' ? targetMax / 18.0182 : targetMax;

    final rangeStart = glucoseLogs.first.timestamp;

    double toX(DateTime ts) => ts.difference(rangeStart).inMinutes.toDouble();

    final spots = glucoseLogs
        .map((g) => FlSpot(toX(g.timestamp), toPreferred(g.value, g.unit)))
        .toList();

    final mealLines = mealLogs
        .map(
          (m) => VerticalLine(
            x: toX(m.timestamp),
            color: AppThemeTokens.brandSuccess.withValues(alpha: 0.6),
            strokeWidth: 1.5,
            dashArray: [4, 4],
            label: VerticalLineLabel(
              show: true,
              labelResolver: (_) => '🍽',
              style: const TextStyle(fontSize: 12),
              alignment: Alignment.topCenter,
            ),
          ),
        )
        .toList();

    final medLines = medicationLogs
        .where((m) => m.medicationType == 'rapid_acting_insulin')
        .map(
          (m) => VerticalLine(
            x: toX(m.timestamp),
            color: AppThemeTokens.brandAccent.withValues(alpha: 0.6),
            strokeWidth: 1.5,
            dashArray: [4, 4],
            label: VerticalLineLabel(
              show: true,
              labelResolver: (_) => '💉',
              style: const TextStyle(fontSize: 12),
              alignment: Alignment.topCenter,
            ),
          ),
        )
        .toList();

    final maxX = spots.last.x;
    final allY = spots.map((s) => s.y).toList()..addAll([tMin, tMax]);
    final padding = preferredUnit == 'mmol/L' ? 1.1 : 20.0;
    final clampMax = preferredUnit == 'mmol/L' ? 33.3 : 600.0;
    final minY = (allY.reduce((a, b) => a < b ? a : b) - padding)
        .clamp(0, clampMax)
        .toDouble();
    final maxY = (allY.reduce((a, b) => a > b ? a : b) + padding)
        .clamp(0, clampMax)
        .toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppThemeTokens.brandPrimary,
            barWidth: 2,
            dotData: FlDotData(
              show: spots.length <= 20,
              getDotPainter: (spot, xPercentage, bar, index) =>
                  FlDotCirclePainter(
                    radius: 3,
                    color: AppThemeTokens.brandPrimary,
                    strokeWidth: 0,
                  ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: tMin,
              color: AppThemeTokens.brandSuccess.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [6, 4],
            ),
            HorizontalLine(
              y: tMax,
              color: AppThemeTokens.error.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [6, 4],
            ),
          ],
          verticalLines: [...mealLines, ...medLines],
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                preferredUnit == 'mmol/L'
                    ? value.toStringAsFixed(1)
                    : value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: maxX > 0 ? maxX / 4 : 1,
              getTitlesWidget: (value, _) {
                final dt = rangeStart.add(Duration(minutes: value.toInt()));
                final label = '${dt.month}/${dt.day}';
                return Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppThemeTokens.textSecondary,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppThemeTokens.brandAccent.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
      ),
    );
  }
}

// ── Stats row ───────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<GlucoseLog> glucoseLogs;
  final double targetMin;
  final double targetMax;
  final String unit;
  final int selectedDays;

  const _StatsRow({
    required this.glucoseLogs,
    required this.targetMin,
    required this.targetMax,
    required this.unit,
    required this.selectedDays,
  });

  @override
  Widget build(BuildContext context) {
    if (glucoseLogs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert each log's value to mg/dL using that log's own unit field
    double fromMgdL(double v) => unit == 'mmol/L' ? v / 18.0182 : v;

    final mgValues = glucoseLogs.map((g) {
      return g.unit == 'mmol/L' ? g.value * 18.0182 : g.value;
    }).toList();
    final avg = mgValues.reduce((a, b) => a + b) / mgValues.length;

    // targetMin/targetMax are stored in mg/dL — compare against mg/dL values directly
    final inRange = mgValues
        .where((v) => v >= targetMin && v <= targetMax)
        .length;
    final tir = mgValues.isEmpty ? 0.0 : (inRange / mgValues.length) * 100;

    // ADAG formula: eA1c = (avgGlucose_mgdL + 46.7) / 28.7
    final hba1c = (avg + 46.7) / 28.7;

    final displayAvg = unit == 'mmol/L'
        ? '${fromMgdL(avg).toStringAsFixed(1)} mmol/L'
        : '${avg.toStringAsFixed(0)} mg/dL';

    final hba1cStr = mgValues.isEmpty ? '—' : '${hba1c.toStringAsFixed(1)}%';
    final hba1cSub = selectedDays >= 90 ? 'Est. HbA1c' : 'Est. HbA1c*';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppThemeTokens.spaceMd),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCell(label: 'Avg', value: displayAvg),
              _StatCell(label: 'In Range', value: '${tir.toStringAsFixed(0)}%'),
              _StatCell(label: hba1cSub, value: hba1cStr),
            ],
          ),
          if (selectedDays < 90 && mgValues.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '* Estimate requires 90 days of data for full accuracy.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppThemeTokens.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppThemeTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Log list ────────────────────────────────────────────────────────────────

class _GlucoseLogList extends StatelessWidget {
  final List<GlucoseLog> logs;
  final String unit;

  const _GlucoseLogList({required this.logs, required this.unit});

  @override
  Widget build(BuildContext context) {
    final sorted = logs.reversed.toList();

    if (sorted.isEmpty) {
      return Center(
        child: Text(
          'No readings logged in this period.',
          style: TextStyle(color: AppThemeTokens.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final g = sorted[i];
        final ts = g.timestamp;
        final dateStr =
            '${ts.day}/${ts.month}/${ts.year}  ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
        // Normalise the log value to the user's preferred display unit.
        final displayValue = g.unit == unit
            ? g.value
            : unit == 'mmol/L'
            ? g.value / 18.0182
            : g.value * 18.0182;
        return ListTile(
          dense: true,
          leading: const Icon(
            Icons.water_drop_outlined,
            color: AppThemeTokens.brandPrimary,
          ),
          title: Text(
            '${displayValue.toStringAsFixed(unit == 'mmol/L' ? 1 : 0)} $unit',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${g.context.replaceAll('_', ' ')} · $dateStr',
            style: const TextStyle(fontSize: 14),
          ),
        );
      },
    );
  }
}
