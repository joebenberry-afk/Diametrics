import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class MicroChart extends StatelessWidget {
  final List<double> dataPoints;
  final Color color;

  const MicroChart({
    super.key,
    required this.dataPoints,
    this.color = AppThemeTokens.brandPrimary,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    return Semantics(
      label: 'Micro trend chart displaying data variations',
      child: CustomPaint(
        size: const Size(100, 40),
        painter: _MicroTrendPainter(dataPoints, color),
      ),
    );
  }
}

class _MicroTrendPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color color;

  _MicroTrendPainter(this.dataPoints, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final stepX = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = size.height - ((dataPoints[i] - minVal) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
