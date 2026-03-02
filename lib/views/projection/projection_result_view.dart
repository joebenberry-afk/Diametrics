import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/projection_result.dart';

/// Displays the Phase 1 Hovorka glucose projection result after a meal is
/// saved, including a 4-hour glucose curve, key metrics, and risk assessment.
class ProjectionResultView extends StatelessWidget {
  final ProjectionResult result;

  const ProjectionResultView({super.key, required this.result});

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
                child: CustomPaint(
                  painter: _GlucoseCurvePainter(
                    points: result.points,
                    riskColor: _riskColor(),
                  ),
                  size: Size.infinite,
                ),
              ),

              const SizedBox(height: AppThemeTokens.spaceLg),

              // ── Key Metrics Row ──
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'Peak',
                      value: result.peakGlucose.toStringAsFixed(0),
                      unit: 'mg/dL',
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
                      value: result.twoHourGlucose.toStringAsFixed(0),
                      unit: 'mg/dL',
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
                  // Pop back to dashboard (meal wizard was pushReplacement'd)
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeTokens.brandPrimary,
                  foregroundColor: AppThemeTokens.textPrimaryInverse,
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
}

// ── Metric Tile ─────────────────────────────────────────────────────────

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

// ── Custom Painter: Glucose Curve ───────────────────────────────────────

class _GlucoseCurvePainter extends CustomPainter {
  final List<ProjectionPoint> points;
  final Color riskColor;

  _GlucoseCurvePainter({required this.points, required this.riskColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const double leftPad = 40;
    const double bottomPad = 28;
    const double topPad = 12;
    const double rightPad = 8;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    // Determine Y range with padding
    final allValues = points.map((p) => p.glucoseValue);
    final rawMin = allValues.reduce(min);
    final rawMax = allValues.reduce(max);
    final yMin = (rawMin - 20).clamp(0.0, 500.0);
    final yMax = rawMax + 20;

    double xOf(int t) => leftPad + (t / 240.0) * chartW;
    double yOf(double g) =>
        topPad + chartH - ((g - yMin) / (yMax - yMin)) * chartH;

    // ── Background glucose zones ──
    void drawZone(double lo, double hi, Color c) {
      final top = yOf(hi.clamp(yMin, yMax));
      final bot = yOf(lo.clamp(yMin, yMax));
      if (bot <= top) return;
      canvas.drawRect(
        Rect.fromLTRB(leftPad, top, leftPad + chartW, bot),
        Paint()..color = c.withValues(alpha: 0.08),
      );
    }

    drawZone(70, 140, AppThemeTokens.brandSuccess); // target zone
    drawZone(140, 180, AppThemeTokens.warning); // elevated
    drawZone(180, yMax, AppThemeTokens.error); // high

    // ── Grid lines ──
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    // Horizontal grid lines (every 50 mg/dL)
    for (double g = (yMin / 50).ceilToDouble() * 50; g <= yMax; g += 50) {
      final y = yOf(g);
      canvas.drawLine(Offset(leftPad, y), Offset(leftPad + chartW, y), gridPaint);

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: g.toStringAsFixed(0),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 4, y - tp.height / 2));
    }

    // Vertical grid lines (every 60 min = 1 hour)
    for (int t = 0; t <= 240; t += 60) {
      final x = xOf(t);
      canvas.drawLine(Offset(x, topPad), Offset(x, topPad + chartH), gridPaint);

      final label = t == 0 ? '0' : '${t ~/ 60}hr';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x - tp.width / 2, topPad + chartH + 6),
      );
    }

    // ── Glucose curve ──
    if (points.length < 2) return;

    final curvePath = Path()
      ..moveTo(xOf(points.first.timeMinutes), yOf(points.first.glucoseValue));

    for (int i = 1; i < points.length; i++) {
      curvePath.lineTo(
        xOf(points[i].timeMinutes),
        yOf(points[i].glucoseValue),
      );
    }

    canvas.drawPath(
      curvePath,
      Paint()
        ..color = AppThemeTokens.brandPrimary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // ── Fill under curve ──
    final fillPath = Path.from(curvePath)
      ..lineTo(xOf(points.last.timeMinutes), topPad + chartH)
      ..lineTo(xOf(points.first.timeMinutes), topPad + chartH)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppThemeTokens.brandPrimary.withValues(alpha: 0.15),
            AppThemeTokens.brandPrimary.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromLTRB(leftPad, topPad, leftPad + chartW, topPad + chartH),
        ),
    );

    // ── Peak dot ──
    final peakPoint = points.reduce(
      (a, b) => a.glucoseValue >= b.glucoseValue ? a : b,
    );
    final peakX = xOf(peakPoint.timeMinutes);
    final peakY = yOf(peakPoint.glucoseValue);

    canvas.drawCircle(
      Offset(peakX, peakY),
      5,
      Paint()..color = riskColor,
    );
    canvas.drawCircle(
      Offset(peakX, peakY),
      3,
      Paint()..color = Colors.white,
    );

    // Peak label
    final peakTp = TextPainter(
      text: TextSpan(
        text: peakPoint.glucoseValue.toStringAsFixed(0),
        style: TextStyle(
          color: riskColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    peakTp.paint(canvas, Offset(peakX - peakTp.width / 2, peakY - 18));
  }

  @override
  bool shouldRepaint(covariant _GlucoseCurvePainter oldDelegate) =>
      oldDelegate.points != points;
}
