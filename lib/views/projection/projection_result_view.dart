import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/projection_result.dart';
import '../../viewmodels/profile_viewmodel.dart';

/// Displays the Phase 2 Hovorka glucose projection result after a meal is
/// saved, including a 4-hour glucose curve with confidence band, key metrics,
/// convergence indicator, and risk assessment.
class ProjectionResultView extends ConsumerWidget {
  final ProjectionResult result;
  final String unit;
  final int mealCount;

  const ProjectionResultView({
    super.key,
    required this.result,
    this.unit = 'mg/dL',
    this.mealCount = 0,
  });

  bool get _isMmol => unit == 'mmol/L';

  // Conversion factor: mg/dL to mmol/L
  double _toUser(double mgdl) => _isMmol ? mgdl / 18.0182 : mgdl;

  Color _riskColor() => switch (result.riskLevel) {
        'normal' => AppThemeTokens.brandSuccess,
        'elevated' => AppThemeTokens.warningText,
        'high' => AppThemeTokens.error,
        'hypo_risk' => const Color(0xFF7B2D8B),
        _ => AppThemeTokens.brandPrimary,
      };

  IconData _riskIcon() => switch (result.riskLevel) {
        'normal' => LucideIcons.checkCircle,
        'elevated' => LucideIcons.alertTriangle,
        'high' => LucideIcons.alertOctagon,
        'hypo_risk' => LucideIcons.alertTriangle,
        _ => LucideIcons.info,
      };

  String _riskLabel() => switch (result.riskLevel) {
        'normal' => 'Normal',
        'elevated' => 'Elevated',
        'high' => 'High',
        'hypo_risk' => 'Hypo Risk',
        _ => 'Unknown',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Read user's actual glucose targets (stored in mg/dL)
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final targetMin = profile?.targetGlucoseMin ?? 70.0;
    final targetMax = profile?.targetGlucoseMax ?? 140.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Glucose Projection',
          style: TextStyle(
            color: isDark ? Colors.white : AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppThemeTokens.textPrimary,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Chart with Confidence Band ──
              Container(
                height: 260,
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeTokens.bgSurfaceDark : Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppThemeTokens.radiusLg),
                  border: Border.all(
                    color: AppThemeTokens.brandPrimary.withValues(alpha: 0.1),
                  ),
                ),
                child: result.points.isEmpty
                    ? const Center(child: Text('No projection data available'))
                    : LineChart(
                        _buildChartData(result.points, _riskColor(), targetMin, targetMax),
                      ),
              ),

              const SizedBox(height: AppThemeTokens.spaceSm),

              // ── Confidence Band Legend ──
              if (result.upperBand.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppThemeTokens.spaceSm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppThemeTokens.brandPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: AppThemeTokens.brandPrimary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+/- ${_isMmol ? _toUser(result.confidenceWidth).toStringAsFixed(1) : result.confidenceWidth.toStringAsFixed(0)} $unit confidence band',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppThemeTokens.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppThemeTokens.spaceLg),

              // ── Key Metrics Row ──
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'Peak',
                      value: _toUser(result.peakGlucose).toStringAsFixed(_isMmol ? 1 : 0),
                      unit: unit,
                      color: _riskColor(),
                    ),
                  ),
                  const SizedBox(width: AppThemeTokens.spaceMd),
                  Expanded(
                    child: _MetricTile(
                      label: 'Time to Peak',
                      value: '${result.peakTimeMinutes}',
                      unit: 'min',
                      color: AppThemeTokens.brandSecondary,
                    ),
                  ),
                  const SizedBox(width: AppThemeTokens.spaceMd),
                  Expanded(
                    child: _MetricTile(
                      label: '2-Hour',
                      value: _toUser(result.twoHourGlucose).toStringAsFixed(_isMmol ? 1 : 0),
                      unit: unit,
                      color: AppThemeTokens.brandPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppThemeTokens.spaceMd),

              // ── TAG Info ──
              Container(
                padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeTokens.bgSurfaceDark : AppThemeTokens.bgSurface,
                  borderRadius:
                      BorderRadius.circular(AppThemeTokens.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.calculator,
                        size: 18, color: AppThemeTokens.textSecondary),
                    const SizedBox(width: AppThemeTokens.spaceSm),
                    Text(
                      'Total Available Glucose (TAG): '
                      '${result.totalAvailableGlucose.toStringAsFixed(1)} g',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppThemeTokens.spaceMd),

              // ── Convergence Progress Indicator ──
              _ConvergenceIndicator(mealCount: mealCount),

              const SizedBox(height: AppThemeTokens.spaceMd),

              // ── Risk Banner ──
              Container(
                padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                decoration: BoxDecoration(
                  color: _riskColor().withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppThemeTokens.radiusLg),
                  border: Border.all(
                    color: _riskColor().withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_riskIcon(), color: _riskColor(), size: 24),
                        const SizedBox(width: AppThemeTokens.spaceSm),
                        Text(
                          'Risk: ${_riskLabel()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _riskColor(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppThemeTokens.spaceSm),
                    Text(
                      result.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white.withValues(alpha: 0.85) : AppThemeTokens.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppThemeTokens.spaceXl),

              // ── Done Button ──
              ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeTokens.brandPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppThemeTokens.spaceLg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppThemeTokens.radiusLg),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: AppThemeTokens.spaceMd),

              // ── Disclaimer ──
              Text(
                'This projection is for informational purposes only and does '
                'not constitute medical advice. Always consult your healthcare '
                'provider before adjusting medication.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppThemeTokens.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemeTokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData _buildChartData(
    List<ProjectionPoint> points,
    Color riskColor,
    double targetMinMgdl,
    double targetMaxMgdl,
  ) {
    if (points.isEmpty) return LineChartData();

    final userPoints = points.map((p) => FlSpot(p.timeMinutes.toDouble(), _toUser(p.glucoseValue))).toList();

    // Include band points in Y-axis range calculation
    final allYValues = <double>[
      ...userPoints.map((s) => s.y),
    ];
    if (result.upperBand.isNotEmpty) {
      allYValues.addAll(result.upperBand.map((p) => _toUser(p.glucoseValue)));
    }
    if (result.lowerBand.isNotEmpty) {
      allYValues.addAll(result.lowerBand.map((p) => _toUser(p.glucoseValue)));
    }

    final rawMin = allYValues.reduce(min);
    final rawMax = allYValues.reduce(max);

    // Dynamic intervals based on units
    final interval = _isMmol ? 2.0 : 50.0;
    final buffer = _isMmol ? 1.0 : 20.0;

    final yMin = (max(0.0, rawMin - buffer) / interval).floor() * interval;
    final yMax = ((rawMax + buffer) / interval).ceil() * interval;

    final spots = userPoints;

    // Build band line data if available
    final lineBarsData = <LineChartBarData>[
      // Upper confidence band (invisible line, used for betweenBars fill)
      if (result.upperBand.isNotEmpty)
        LineChartBarData(
          spots: result.upperBand
              .map((p) => FlSpot(p.timeMinutes.toDouble(), _toUser(p.glucoseValue)))
              .toList(),
          isCurved: true,
          color: Colors.transparent,
          barWidth: 0,
          dotData: const FlDotData(show: false),
        ),
      // Lower confidence band (invisible line, used for betweenBars fill)
      if (result.lowerBand.isNotEmpty)
        LineChartBarData(
          spots: result.lowerBand
              .map((p) => FlSpot(p.timeMinutes.toDouble(), _toUser(p.glucoseValue)))
              .toList(),
          isCurved: true,
          color: Colors.transparent,
          barWidth: 0,
          dotData: const FlDotData(show: false),
        ),
      // Main projection curve
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: AppThemeTokens.brandPrimary,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            final isPeak = spot.y == userPoints.map((s) => s.y).reduce(max);
            return isPeak;
          },
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: riskColor,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppThemeTokens.brandPrimary.withValues(alpha: 0.3),
              AppThemeTokens.brandPrimary.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    ];

    // Confidence band fill between upper and lower curves
    final betweenBarsData = <BetweenBarsData>[];
    if (result.upperBand.isNotEmpty && result.lowerBand.isNotEmpty) {
      betweenBarsData.add(
        BetweenBarsData(
          fromIndex: 0, // upper band line index
          toIndex: 1, // lower band line index
          color: AppThemeTokens.brandPrimary.withValues(alpha: 0.12),
        ),
      );
    }

    return LineChartData(
      minX: 0,
      maxX: 240,
      minY: yMin,
      maxY: yMax,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: interval,
        verticalInterval: 60,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withValues(alpha: 0.2),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.grey.withValues(alpha: 0.2),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 44,
            getTitlesWidget: (value, meta) {
              return Text(
                _isMmol ? value.toStringAsFixed(1) : value.toInt().toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 60,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const Text('0', style: TextStyle(color: Colors.grey, fontSize: 12));
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${(value / 60).toInt()}hr',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: lineBarsData,
      betweenBarsData: betweenBarsData,
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          // Lower target line (user's targetGlucoseMin)
          HorizontalLine(
            y: _toUser(targetMinMgdl),
            color: AppThemeTokens.brandSuccess.withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          // Upper target line (user's targetGlucoseMax)
          HorizontalLine(
            y: _toUser(targetMaxMgdl),
            color: AppThemeTokens.brandSuccess.withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          // Warning threshold: 30 mg/dL above target max
          HorizontalLine(
            y: _toUser(targetMaxMgdl + 30),
            color: AppThemeTokens.warning.withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ],
      ),
    );
  }
}

/// Convergence progress indicator showing how many post-meal readings
/// have contributed to personalisation. Encourages users to keep logging.
class _ConvergenceIndicator extends StatelessWidget {
  final int mealCount;

  /// Target number of meals for full convergence.
  static const int _targetMeals = 20;

  const _ConvergenceIndicator({required this.mealCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = (mealCount / _targetMeals).clamp(0.0, 1.0);
    final isConverged = mealCount >= _targetMeals;

    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      decoration: BoxDecoration(
        color: isDark ? AppThemeTokens.bgSurfaceDark : AppThemeTokens.bgSurface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(
          color: isConverged
              ? AppThemeTokens.brandSuccess.withValues(alpha: 0.3)
              : AppThemeTokens.brandPrimary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConverged ? LucideIcons.checkCircle : LucideIcons.brain,
                size: 16,
                color: isConverged
                    ? AppThemeTokens.brandSuccess
                    : AppThemeTokens.brandPrimary,
              ),
              const SizedBox(width: AppThemeTokens.spaceSm),
              Expanded(
                child: Text(
                  isConverged
                      ? 'Personalisation complete'
                      : 'Personalisation progress',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isConverged
                        ? AppThemeTokens.brandSuccess
                        : AppThemeTokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$mealCount / $_targetMeals meals',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppThemeTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(
                isConverged
                    ? AppThemeTokens.brandSuccess
                    : AppThemeTokens.brandPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isConverged
                ? 'Predictions are tailored to your metabolism.'
                : 'Your predictions improve with more logged meals.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppThemeTokens.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppThemeTokens.spaceMd,
        horizontal: AppThemeTokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppThemeTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
