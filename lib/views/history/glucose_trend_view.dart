import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/glucose_log.dart';
import '../../viewmodels/health_data_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';

class GlucoseTrendView extends ConsumerStatefulWidget {
  const GlucoseTrendView({super.key});

  @override
  ConsumerState<GlucoseTrendView> createState() => _GlucoseTrendViewState();
}

class _GlucoseTrendViewState extends ConsumerState<GlucoseTrendView> {
  int _selectedPeriod = 1; // 0=Today, 1=7 Days, 2=30 Days

  List<GlucoseLog> _filterByPeriod(List<GlucoseLog> logs, int period) {
    final now = DateTime.now();
    final cutoff = switch (period) {
      0 => DateTime(now.year, now.month, now.day),
      1 => now.subtract(const Duration(days: 7)),
      2 => now.subtract(const Duration(days: 30)),
      _ => now.subtract(const Duration(days: 7)),
    };
    return logs.where((l) => l.timestamp.isAfter(cutoff)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(glucoseLogsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final targetMin = profile?.targetGlucoseMin ?? 70.0;
    final targetMax = profile?.targetGlucoseMax ?? 180.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucose Trends'),
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Period Selector
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppThemeTokens.spaceLg,
              vertical: AppThemeTokens.spaceMd,
            ),
            child: Row(
              children: [
                _PeriodTab(
                  label: 'Today',
                  isSelected: _selectedPeriod == 0,
                  onTap: () => setState(() => _selectedPeriod = 0),
                ),
                const SizedBox(width: AppThemeTokens.spaceSm),
                _PeriodTab(
                  label: '7 Days',
                  isSelected: _selectedPeriod == 1,
                  onTap: () => setState(() => _selectedPeriod = 1),
                ),
                const SizedBox(width: AppThemeTokens.spaceSm),
                _PeriodTab(
                  label: '30 Days',
                  isSelected: _selectedPeriod == 2,
                  onTap: () => setState(() => _selectedPeriod = 2),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: logsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (logs) {
                final filtered = _filterByPeriod(logs, _selectedPeriod);

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No glucose readings for this period.',
                      style: TextStyle(color: AppThemeTokens.textSecondary),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Summary Stats
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppThemeTokens.spaceLg,
                        ),
                        child: _SummaryRow(
                          logs: filtered,
                          targetMin: targetMin,
                          targetMax: targetMax,
                        ),
                      ),
                      const SizedBox(height: AppThemeTokens.spaceXl),

                      // Chart
                      Padding(
                        padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                        child: SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _GlucoseTrendChart(
                              logs: filtered,
                              targetMin: targetMin,
                              targetMax: targetMax,
                              isDark:
                                  Theme.of(context).brightness ==
                                  Brightness.dark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppThemeTokens.brandPrimary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
            border: Border.all(
              color: isSelected
                  ? AppThemeTokens.brandPrimary
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : AppThemeTokens.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<GlucoseLog> logs;
  final double targetMin;
  final double targetMax;

  const _SummaryRow({
    required this.logs,
    required this.targetMin,
    required this.targetMax,
  });

  @override
  Widget build(BuildContext context) {
    final avg = logs.isEmpty
        ? 0.0
        : logs.map((l) => l.value).reduce((a, b) => a + b) / logs.length;
    final minVal = logs.isEmpty
        ? 0.0
        : logs.map((l) => l.value).reduce((a, b) => a < b ? a : b);
    final maxVal = logs.isEmpty
        ? 0.0
        : logs.map((l) => l.value).reduce((a, b) => a > b ? a : b);

    final inRangeCount = logs
        .where((l) => l.value >= targetMin && l.value <= targetMax)
        .length;
    final tir = logs.isEmpty ? 0.0 : (inRangeCount / logs.length) * 100;

    return Row(
      children: [
        _StatBox(label: 'Avg', value: avg.toStringAsFixed(0), unit: 'mg/dL'),
        const SizedBox(width: AppThemeTokens.spaceSm),
        _StatBox(label: 'Min', value: minVal.toStringAsFixed(0), unit: 'mg/dL'),
        const SizedBox(width: AppThemeTokens.spaceSm),
        _StatBox(label: 'Max', value: maxVal.toStringAsFixed(0), unit: 'mg/dL'),
        const SizedBox(width: AppThemeTokens.spaceSm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppThemeTokens.spaceSm,
            ),
            decoration: BoxDecoration(
              color: tir >= 70
                  ? AppThemeTokens.brandSuccess.withValues(alpha: 0.1)
                  : tir >= 50
                  ? AppThemeTokens.warning.withValues(alpha: 0.1)
                  : AppThemeTokens.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
              border: Border.all(
                color: tir >= 70
                    ? AppThemeTokens.brandSuccess.withValues(alpha: 0.5)
                    : tir >= 50
                    ? AppThemeTokens.warning.withValues(alpha: 0.5)
                    : AppThemeTokens.error.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${tir.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: tir >= 70
                        ? AppThemeTokens.brandSuccess
                        : tir >= 50
                        ? AppThemeTokens.warning
                        : AppThemeTokens.error,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'TIR',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppThemeTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatBox({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppThemeTokens.spaceSm),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppThemeTokens.bgSurfaceDark
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppThemeTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppThemeTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlucoseTrendChart extends CustomPainter {
  final List<GlucoseLog> logs;
  final double targetMin;
  final double targetMax;
  final bool isDark;

  _GlucoseTrendChart({
    required this.logs,
    required this.targetMin,
    required this.targetMax,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (logs.isEmpty) return;

    final paddingLeft = 40.0;
    final paddingBottom = 24.0;
    final graphWidth = size.width - paddingLeft;
    final graphHeight = size.height - paddingBottom;

    // 1. Calculate boundaries
    final minTime = logs.first.timestamp.millisecondsSinceEpoch;
    final maxTime = logs.last.timestamp.millisecondsSinceEpoch;
    final timeSpan = max(maxTime - minTime, 1);

    double minV = logs.map((l) => l.value).reduce((a, b) => a < b ? a : b);
    double maxV = logs.map((l) => l.value).reduce((a, b) => a > b ? a : b);

    // Add margin to Y axis
    minV = min(minV, targetMin) - 20;
    maxV = max(maxV, targetMax) + 20;
    final vSpan = max(maxV - minV, 1);

    // Helpers to map data to screen coordinates
    double x(int time) =>
        paddingLeft + ((time - minTime) / timeSpan) * graphWidth;
    double y(double val) =>
        graphHeight - (((val - minV) / vSpan) * graphHeight);

    // 2. Draw Target Band Background
    final yTargetMax = y(targetMax);
    final yTargetMin = y(targetMin);

    final bandPaint = Paint()
      ..color = AppThemeTokens.brandSuccess.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(paddingLeft, yTargetMax, size.width, yTargetMin),
      bandPaint,
    );

    // 3. Draw Grid Lines & Labels
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    final targetLinePaint = Paint()
      ..color = AppThemeTokens.brandSuccess.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: AppThemeTokens.textSecondary,
      fontSize: 10,
    );

    // Draw Y axis labels and grid lines
    final steps = 4;
    for (int i = 0; i <= steps; i++) {
      final val = minV + (vSpan * (i / steps));
      final yPos = y(val);

      // Grid line
      canvas.drawLine(
        Offset(paddingLeft, yPos),
        Offset(size.width, yPos),
        gridPaint,
      );

      // Label
      final span = TextSpan(text: val.toStringAsFixed(0), style: textStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(
        canvas,
        Offset(paddingLeft - tp.width - 8, yPos - (tp.height / 2)),
      );
    }

    // Draw solid target lines
    canvas.drawLine(
      Offset(paddingLeft, yTargetMax),
      Offset(size.width, yTargetMax),
      targetLinePaint,
    );
    canvas.drawLine(
      Offset(paddingLeft, yTargetMin),
      Offset(size.width, yTargetMin),
      targetLinePaint,
    );

    // 4. Draw Path
    if (logs.length > 1) {
      final path = Path();
      path.moveTo(
        x(logs[0].timestamp.millisecondsSinceEpoch),
        y(logs[0].value),
      );

      for (int i = 1; i < logs.length; i++) {
        path.lineTo(
          x(logs[i].timestamp.millisecondsSinceEpoch),
          y(logs[i].value),
        );
      }

      final linePaint = Paint()
        ..color = AppThemeTokens.brandPrimary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, linePaint);
    }

    // 5. Draw Data Points
    for (final log in logs) {
      final px = x(log.timestamp.millisecondsSinceEpoch);
      final py = y(log.value);

      Color dotColor = AppThemeTokens.brandSuccess;
      if (log.value < targetMin) dotColor = AppThemeTokens.warning;
      if (log.value > targetMax) dotColor = AppThemeTokens.error;

      final dotPaint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isDark ? AppThemeTokens.bgSurfaceDark : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(Offset(px, py), 4, dotPaint);
      canvas.drawCircle(Offset(px, py), 4, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlucoseTrendChart oldDelegate) {
    return oldDelegate.logs != logs ||
        oldDelegate.targetMin != targetMin ||
        oldDelegate.targetMax != targetMax ||
        oldDelegate.isDark != isDark;
  }
}
