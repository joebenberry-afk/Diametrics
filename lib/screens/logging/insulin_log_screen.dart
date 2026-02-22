import 'package:flutter/material.dart';

class InsulinLogScreen extends StatelessWidget {
  const InsulinLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Insulin')),
      body: const Center(
        child: Text('Insulin logging screen', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}