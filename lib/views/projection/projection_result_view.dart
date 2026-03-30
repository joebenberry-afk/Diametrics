import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/projection_result.dart';

/// Displays the Phase 1 Hovorka glucose projection result after a meal is
/// saved, including a 4-hour glucose curve, key metrics, and risk assessment.
class ProjectionResultView extends StatelessWidget {
  final ProjectionResult result;
  final String unit;

  const ProjectionResultView({
    super.key,
    required this.result,
    this.unit = 'mg/dL',
  });

  bool get _isMmol => unit == 'mmol/L';

  // Conversion factor: mg/dL to mmol/L
  double _toUser(double mgdl) => _isMmol ? mgdl / 18.0182 : mgdl;

  Color _riskColor() => switch (result.riskLevel) {
        'normal' => AppThemeTokens.brandSuccess,
        'elevated' => AppThemeTokens.warning,
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Chart ──
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
                        _buildChartData(result.points, _riskColor()),
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
                  Navigator.pop(context);
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

  LineChartData _buildChartData(List<ProjectionPoint> points, Color riskColor) {
    if (points.isEmpty) return LineChartData();

    final userPoints = points.map((p) => FlSpot(p.timeMinutes.toDouble(), _toUser(p.glucoseValue))).toList();
    final allYValues = userPoints.map((s) => s.y);
    final rawMin = allYValues.reduce(min);
    final rawMax = allYValues.reduce(max);

    // Dynamic intervals based on units
    final interval = _isMmol ? 2.0 : 50.0;
    final buffer = _isMmol ? 1.0 : 20.0;

    final yMin = (max(0.0, rawMin - buffer) / interval).floor() * interval;
    final yMax = ((rawMax + buffer) / interval).ceil() * interval;

    final spots = userPoints;

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
                style: const TextStyle(color: Colors.grey, fontSize: 10),
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
              if (value == 0) return const Text('0', style: TextStyle(color: Colors.grey, fontSize: 10));
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${(value / 60).toInt()}hr',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppThemeTokens.brandPrimary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) {
              final isPeak = spot.y == rawMax;
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
      ],
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: _toUser(70),
            color: AppThemeTokens.brandSuccess.withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          HorizontalLine(
            y: _toUser(140),
            color: AppThemeTokens.brandSuccess.withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          HorizontalLine(
            y: _toUser(180),
            color: AppThemeTokens.warning.withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [5, 5],
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
