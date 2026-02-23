import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/glassy_card.dart';

/// Food Recording screen - camera interface for meal photos.
/// Matches the "Food recording page" mockup from design image 3 (right panel).
class AddFoodScreen extends StatelessWidget {
  const AddFoodScreen({super.key});

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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Camera viewfinder area
              GlassyCard(
                width: double.infinity,
                height: 350,
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Take a photo of your meal here.',
                style: SeniorTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              // Bottom action bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomButton(
                    Icons.note_add_outlined,
                    'Additional notes',
                  ),
                  _buildBottomButton(Icons.restaurant_outlined, 'Add food'),
                  _buildBottomButton(Icons.analytics_outlined, 'Meal analysis'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade600, width: 2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
