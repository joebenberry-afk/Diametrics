import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/glucose_log.dart';
import '../../viewmodels/health_data_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../logging/glucose_wizard_view.dart';

class GlucoseHistoryView extends ConsumerWidget {
  const GlucoseHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(glucoseLogsProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucose History'),
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
                    Icons.bloodtype_outlined,
                    size: 64,
                    color: AppThemeTokens.brandPrimary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppThemeTokens.spaceMd),
                  const Text(
                    'No glucose readings yet.\nTap \'+\' to log your first reading.',
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

          final sortedLogs = List<GlucoseLog>.from(logs)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              vertical: AppThemeTokens.spaceMd,
            ),
            itemCount: sortedLogs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return _GlucoseHistoryTile(log: log, profile: profile);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GlucoseWizardView()),
          );
        },
        backgroundColor: AppThemeTokens.brandPrimary,
        foregroundColor: AppThemeTokens.textPrimaryInverse,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GlucoseHistoryTile extends StatelessWidget {
  final GlucoseLog log;
  final dynamic profile;

  const _GlucoseHistoryTile({required this.log, required this.profile});

  @override
  Widget build(BuildContext context) {
    final targetMin = profile?.targetGlucoseMin ?? 70.0;
    final targetMax = profile?.targetGlucoseMax ?? 180.0;

    Color statusColor = AppThemeTokens.brandSuccess;
    if (log.value < targetMin) {
      statusColor = AppThemeTokens.warning;
    } else if (log.value > targetMax) {
      statusColor = AppThemeTokens.error;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppThemeTokens.spaceLg,
        vertical: AppThemeTokens.spaceXs,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          log.value.toStringAsFixed(0),
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        '${log.value.toStringAsFixed(0)} ${log.unit}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${log.context.replaceAll('_', ' ')} • ${DateFormatter.formatDateTime(log.timestamp)}',
        style: const TextStyle(
          color: AppThemeTokens.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: log.notes?.isNotEmpty == true
          ? const Icon(
              Icons.note_outlined,
              size: 20,
              color: AppThemeTokens.brandAccent,
            )
          : null,
    );
  }
}
