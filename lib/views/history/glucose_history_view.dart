import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/glucose_log.dart';
import '../../router/route_names.dart';
import '../../viewmodels/health_data_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';

const _contextLabels = {
  'morning_fasting': 'Morning Fasting',
  'pre_meal': 'Before Meal',
  'post_meal_30': '30 Min After Meal',
  'post_meal_60': '60 Min After Meal',
  'post_meal_120': '2 Hours After Meal',
  'post_meal_180': '3 Hours After Meal',
  'bedtime': 'Bedtime',
  'general': 'General',
};

String _friendlyContext(String context) =>
    _contextLabels[context] ??
    context
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');

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
                  onPressed: () => ref.invalidate(glucoseLogsProvider),
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
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return Dismissible(
                key: ValueKey(log.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppThemeTokens.spaceLg),
                  color: AppThemeTokens.error,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete reading?'),
                      content: const Text(
                        'This reading will be permanently deleted.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ) ?? false;
                },
                onDismissed: (_) {
                  final deleted = log;
                  ref
                      .read(glucoseLogsProvider.notifier)
                      .deleteGlucoseLog(deleted.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Reading deleted'),
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          ref
                              .read(healthDataRepositoryProvider)
                              .addGlucoseLog(deleted);
                          ref.invalidate(glucoseLogsProvider);
                        },
                      ),
                    ),
                  );
                },
                child: _GlucoseHistoryTile(log: log, profile: profile),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.logGlucose),
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
        '${_friendlyContext(log.context)} • ${DateFormatter.formatDateTime(log.timestamp)}',
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
