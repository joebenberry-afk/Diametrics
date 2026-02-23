import 'package:flutter/material.dart';
import '../../theme.dart';

/// Emergency Alert screen - displays a large SOS button and description.
/// Matches the "Emergency alert" mockup from design image 1 (right panel).
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // SOS Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Emergency alert sent to all linked users!',
                        style: SeniorTheme.bodyStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: Container(
                  width: 220,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Send an emergency alert to all linked users.',
                textAlign: TextAlign.center,
                style: SeniorTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
