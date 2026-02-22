import 'package:flutter/material.dart';

class MealLogScreen extends StatelessWidget {
  const MealLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Meal')),
      body: const Center(
        child: Text('Meal logging screen', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}