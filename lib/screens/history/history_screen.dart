// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diametrics/services/log_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LogService();
    final fmt = DateFormat('EEE, dd MMM yyyy • HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('History (Last 7 Days)')),
      body: FutureBuilder(
        future: service.getLogsLast7Days(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Something went wrong:\n${snapshot.error}',
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return const Center(
              child: Text(
                'No logs yet.\nStart by logging your blood glucose.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final l = logs[i];

              final title = (l.bgValue == null)
                  ? 'Log Entry'
                  : 'Blood Glucose: ${l.bgValue!.toStringAsFixed(1)} ${l.bgUnit}';

              final subtitle = fmt.format(l.timestamp);

              return Semantics(
                button: true,
                label: '$title, $subtitle',
                child: ListTile(
                  title: Text(title, style: const TextStyle(fontSize: 18)),
                  subtitle: Text(subtitle, style: const TextStyle(fontSize: 16)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}