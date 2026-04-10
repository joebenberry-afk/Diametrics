import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/medication_log.dart';
import '../../router/route_names.dart';
import '../../viewmodels/health_data_viewmodel.dart';

void _showMedicationDeleteSheet(
  BuildContext context,
  WidgetRef ref,
  MedicationLog log,
) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppThemeTokens.error),
            title: const Text(
              'Delete this medication log',
              style: TextStyle(color: AppThemeTokens.error),
            ),
            onTap: () {
              Navigator.pop(context);
              ref
                  .read(medicationLogsProvider.notifier)
                  .deleteMedicationLog(log.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Medication deleted'),
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      ref
                          .read(healthDataRepositoryProvider)
                          .addMedicationLog(log);
                      ref.invalidate(medicationLogsProvider);
                    },
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

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
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppThemeTokens.error,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong loading your history.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(medicationLogsProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
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
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return GestureDetector(
                onLongPress: () =>
                    _showMedicationDeleteSheet(context, ref, log),
                child: Dismissible(
                  key: ValueKey(log.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(
                      right: AppThemeTokens.spaceLg,
                    ),
                    color: AppThemeTokens.error,
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    final deleted = log;
                    ref
                        .read(medicationLogsProvider.notifier)
                        .deleteMedicationLog(deleted.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Medication deleted'),
                        duration: const Duration(seconds: 4),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            ref
                                .read(healthDataRepositoryProvider)
                                .addMedicationLog(deleted);
                            ref.invalidate(medicationLogsProvider);
                          },
                        ),
                      ),
                    );
                  },
                  child: _MedicationHistoryTile(log: log),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.logMedication),
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
          fontSize: 14,
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
