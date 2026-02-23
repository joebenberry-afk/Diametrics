import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/glassy_card.dart';

/// Monthly Statistics screen - displays glucose/insulin chart and actions.
/// Matches the "Monthly statistics" mockup from design image 2 (right panel).
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE0F7FA), Color(0xFFF5F5DC), Color(0xFFE0F7FA)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'See your insulin and glucose levels for this month here.',
                style: SeniorTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              // Monthly chart card
              GlassyCard(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 2,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Glucose',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 12,
                                height: 2,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Insulin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Y-axis labels + chart area
                          Expanded(
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (final v in [
                                      '180',
                                      '160',
                                      '140',
                                      '120',
                                      '100',
                                      '80',
                                      '60',
                                      '40',
                                      '20',
                                    ])
                                      Text(
                                        v,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 9,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: CustomPaint(
                                    painter: _MonthlyChartPainter(),
                                    size: const Size(
                                      double.infinity,
                                      double.infinity,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // X-axis labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (final v in [
                                '0',
                                '5',
                                '10',
                                '15',
                                '20',
                                '25',
                                '30',
                              ])
                                Text(
                                  v,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 9,
                                  ),
                                ),
                            ],
                          ),
                          Center(
                            child: Text(
                              'Days',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Bottom action cards
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB2EBF2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'See your trend analysis here.',
                            style: SeniorTheme.labelStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GlassyCard(
                      height: 80,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generate pdf of results.',
                            style: SeniorTheme.labelStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for simulated monthly glucose/insulin line chart.
class _MonthlyChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glucosePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final insulinPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Simulated glucose line
    final glucosePath = Path();
    final glucosePoints = [
      0.55,
      0.50,
      0.60,
      0.48,
      0.58,
      0.45,
      0.55,
      0.52,
      0.60,
      0.47,
      0.53,
      0.58,
      0.50,
      0.56,
      0.48,
      0.62,
      0.52,
      0.55,
      0.48,
      0.57,
      0.50,
      0.54,
      0.58,
      0.46,
      0.53,
      0.60,
      0.48,
      0.55,
      0.50,
      0.52,
    ];
    for (int i = 0; i < glucosePoints.length; i++) {
      final x = (i / (glucosePoints.length - 1)) * size.width;
      final y = (1 - glucosePoints[i]) * size.height;
      if (i == 0) {
        glucosePath.moveTo(x, y);
      } else {
        glucosePath.lineTo(x, y);
      }
    }
    canvas.drawPath(glucosePath, glucosePaint);

    // Simulated insulin line
    final insulinPath = Path();
    final insulinPoints = [
      0.30,
      0.35,
      0.28,
      0.38,
      0.32,
      0.25,
      0.30,
      0.35,
      0.28,
      0.33,
      0.36,
      0.30,
      0.34,
      0.28,
      0.32,
      0.36,
      0.30,
      0.33,
      0.28,
      0.35,
      0.31,
      0.28,
      0.34,
      0.30,
      0.32,
      0.28,
      0.35,
      0.30,
      0.33,
      0.28,
    ];
    for (int i = 0; i < insulinPoints.length; i++) {
      final x = (i / (insulinPoints.length - 1)) * size.width;
      final y = (1 - insulinPoints[i]) * size.height;
      if (i == 0) {
        insulinPath.moveTo(x, y);
      } else {
        insulinPath.lineTo(x, y);
      }
    }
    canvas.drawPath(insulinPath, insulinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
