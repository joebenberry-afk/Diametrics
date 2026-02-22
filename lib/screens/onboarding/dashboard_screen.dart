import 'package:flutter/material.dart';

import '../logging/glucose_log_screen.dart';
import '../logging/meal_log_screen.dart';
import '../logging/insulin_log_screen.dart';
import '../history/history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diametrics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dashboardButton(
              context,
              'Log Blood Glucose',
              const GlucoseLogScreen(),
            ),
            _dashboardButton(
              context,
              'Log Meal',
              const MealLogScreen(),
            ),
            _dashboardButton(
              context,
              'Log Insulin',
              const InsulinLogScreen(),
            ),
            const SizedBox(height: 12),
            _dashboardButton(
              context,
              'View History',
              const HistoryScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardButton(BuildContext context, String text, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          },
          child: Text(
            text,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}