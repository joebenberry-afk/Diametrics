import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/glassy_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              // Home Dashboard Header with Mascot
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'DiaMetrics Robot Mascot',
                    child: Image.asset(
                      'assets/images/robot_mascot.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Hello!\nReady to log today?',
                      style: SeniorTheme.headingStyle.copyWith(
                        fontSize: 24,
                        color: SeniorTheme.primaryCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Top two cards row
              Row(
                children: [
                  // Track glucose card
                  Expanded(
                    child: GlassyCard(
                      height: 90,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Track glucose\nhere.',
                            style: SeniorTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(Icons.arrow_forward, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sticker collection card
                  Expanded(
                    child: GlassyCard(
                      height: 90,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Check out your\nsticker collection!',
                              style: SeniorTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Text('🐶', style: TextStyle(fontSize: 28)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Daily glucose chart card
              GlassyCard(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dark chart area
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'High',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          // Simulated bar chart
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(12, (i) {
                              final heights = [
                                40.0,
                                65.0,
                                50.0,
                                70.0,
                                35.0,
                                55.0,
                                48.0,
                                62.0,
                                45.0,
                                58.0,
                                42.0,
                                30.0,
                              ];
                              return Container(
                                width: 8,
                                height: heights[i],
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5CE1E6),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Container(height: 1, color: Colors.red.shade400),
                          Text(
                            'Low',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '12:00 AM',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                '6:00 AM',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                '12:00 PM',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                '6:00',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daily glucose and insulin levels',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bottom row: Medication + Journal
              Row(
                children: [
                  Expanded(
                    child: GlassyCard(
                      height: 80,
                      padding: const EdgeInsets.all(14),
                      child: Center(
                        child: Text(
                          'Did you take your\nmedication today?',
                          textAlign: TextAlign.center,
                          style: SeniorTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB2EBF2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Center(
                        child: Text(
                          'How are you\nfeeling? Journal\nhere.',
                          textAlign: TextAlign.center,
                          style: SeniorTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
