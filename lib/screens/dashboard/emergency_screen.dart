import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/glassy_card.dart';

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
              // Massive SOS Button within GlassyCard
              GlassyCard(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
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
                  child: Semantics(
                    button: true,
                    label: 'Send SOS Emergency Alert',
                    child: AspectRatio(
                      aspectRatio: 1.0, // perfect square
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFED1C24), // Bright mockup red
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
                              fontSize: 80,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Send an emergency alert to all linked users.',
                textAlign: TextAlign.center,
                style: SeniorTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
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
