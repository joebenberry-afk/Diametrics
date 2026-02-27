import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/medication_log.dart';
import '../../viewmodels/health_data_viewmodel.dart';
import '../logging/medication_wizard_view.dart';

class MedicationHistoryView extends ConsumerWidget {
  const MedicationHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(medicationLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication History'),
        surfaceTintColor: Colors.transparent,
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading history: $e')),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: AppThemeTokens.brandAccent.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppThemeTokens.spaceMd),
                  const Text(
                    'No medication logged yet.\nTap \'+\' to log your first dose.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppThemeTokens.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final sortedLogs = List<MedicationLog>.from(logs)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              vertical: AppThemeTokens.spaceMd,
            ),
            itemCount: sortedLogs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return _MedicationHistoryTile(log: log);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MedicationWizardView()),
          );
        },
        backgroundColor: AppThemeTokens.brandAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MedicationHistoryTile extends StatelessWidget {
  final MedicationLog log;

  const _MedicationHistoryTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppThemeTokens.spaceLg,
        vertical: AppThemeTokens.spaceXs,
      ),
      leading: CircleAvatar(
        backgroundColor: AppThemeTokens.brandAccent.withValues(alpha: 0.15),
        child: const Icon(Icons.medication, color: AppThemeTokens.brandAccent),
      ),
      title: Text(
        log.name?.isNotEmpty == true
            ? log.name!
            : log.medicationType.replaceAll('_', ' '),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${log.units.toStringAsFixed(1)} units • ${DateFormatter.formatDateTime(log.timestamp)}',
        style: const TextStyle(
          color: AppThemeTokens.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: log.notes?.isNotEmpty == true
          ? const Icon(
              Icons.note_outlined,
              size: 20,
              color: AppThemeTokens.brandSecondary,
            )
          : null,
    );
  }
}
