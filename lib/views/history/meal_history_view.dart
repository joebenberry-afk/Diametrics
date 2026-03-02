import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/meal_log.dart';
import '../../viewmodels/health_data_viewmodel.dart';
import '../logging/meal_wizard_view.dart';

class MealHistoryView extends ConsumerWidget {
  const MealHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(mealLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
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
                    Icons.restaurant_outlined,
                    size: 64,
                    color: AppThemeTokens.brandSuccess.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppThemeTokens.spaceMd),
                  const Text(
                    'No meals logged yet.\nTap \'+\' to log your first meal.',
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

          final sortedLogs = List<MealLog>.from(logs)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              vertical: AppThemeTokens.spaceMd,
            ),
            itemCount: sortedLogs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return _MealHistoryTile(log: log);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MealWizardView()),
          );
        },
        backgroundColor: AppThemeTokens.brandSuccess,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MealHistoryTile extends StatelessWidget {
  final MealLog log;

  const _MealHistoryTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final defaultTitle =
        '${log.mealType[0].toUpperCase()}${log.mealType.substring(1)} meal';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppThemeTokens.spaceLg,
        vertical: AppThemeTokens.spaceSm,
      ),
      leading: CircleAvatar(
        backgroundColor: AppThemeTokens.brandSuccess.withValues(alpha: 0.15),
        child: const Icon(Icons.restaurant, color: AppThemeTokens.brandSuccess),
      ),
      title: Text(
        log.name?.isNotEmpty == true ? log.name! : defaultTitle,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${log.carbohydrates.toStringAsFixed(0)}g carbs • ${log.proteins.toStringAsFixed(0)}g protein • ${log.fats.toStringAsFixed(0)}g fat',
            style: TextStyle(
              color: isDark ? Colors.white70 : AppThemeTokens.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormatter.formatDateTime(log.timestamp),
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontSize: 12,
            ),
          ),
          if (log.containsAlcohol || log.containsCaffeine)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: AppThemeTokens.spaceSm,
                children: [
                  if (log.containsAlcohol)
                    _MiniChip(
                      label: 'Alcohol',
                      color: AppThemeTokens.error,
                      icon: Icons.local_drink,
                    ),
                  if (log.containsCaffeine)
                    _MiniChip(
                      label: 'Caffeine',
                      color: AppThemeTokens.warning,
                      icon: Icons.coffee,
                    ),
                ],
              ),
            ),
        ],
      ),
      trailing: log.calories > 0
          ? Text(
              '${log.calories.toStringAsFixed(0)} kcal',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            )
          : null,
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _MiniChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
