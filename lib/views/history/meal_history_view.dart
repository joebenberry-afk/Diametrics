import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/meal_log.dart';
import '../../router/route_names.dart';
import '../../viewmodels/health_data_viewmodel.dart';

void _showMealEditSheet(
  BuildContext context,
  WidgetRef ref,
  MealLog log,
) {
  final nameCtrl = TextEditingController(text: log.name ?? '');
  final carbsCtrl =
      TextEditingController(text: log.carbohydrates.toStringAsFixed(1));
  final proteinCtrl =
      TextEditingController(text: log.proteins.toStringAsFixed(1));
  final fatCtrl = TextEditingController(text: log.fats.toStringAsFixed(1));
  final calCtrl =
      TextEditingController(text: log.calories.toStringAsFixed(0));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppThemeTokens.radiusLg),
      ),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppThemeTokens.spaceLg,
            AppThemeTokens.spaceMd,
            AppThemeTokens.spaceLg,
            AppThemeTokens.spaceLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Meal',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Meal name (optional)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: _MacroField(
                      controller: carbsCtrl,
                      label: 'Carbs (g)',
                    ),
                  ),
                  const SizedBox(width: AppThemeTokens.spaceSm),
                  Expanded(
                    child: _MacroField(
                      controller: proteinCtrl,
                      label: 'Protein (g)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),
              Row(
                children: [
                  Expanded(
                    child: _MacroField(
                      controller: fatCtrl,
                      label: 'Fat (g)',
                    ),
                  ),
                  const SizedBox(width: AppThemeTokens.spaceSm),
                  Expanded(
                    child: _MacroField(
                      controller: calCtrl,
                      label: 'Calories (kcal)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppThemeTokens.spaceLg),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeTokens.brandPrimary,
                  foregroundColor: AppThemeTokens.textPrimaryInverse,
                  minimumSize: const Size.fromHeight(AppThemeTokens.minTapTarget),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                  ),
                ),
                onPressed: () {
                  final updated = log.copyWith(
                    name: nameCtrl.text.trim().isEmpty
                        ? null
                        : nameCtrl.text.trim(),
                    carbohydrates: double.tryParse(carbsCtrl.text) ??
                        log.carbohydrates,
                    proteins:
                        double.tryParse(proteinCtrl.text) ?? log.proteins,
                    fats: double.tryParse(fatCtrl.text) ?? log.fats,
                    calories:
                        double.tryParse(calCtrl.text) ?? log.calories,
                  );
                  ref
                      .read(mealLogsProvider.notifier)
                      .updateMealLog(updated);
                  Navigator.pop(ctx);
                },
                child: const Text('Save changes'),
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppThemeTokens.error,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmDeleteMeal(context, ref, log);
                },
                child: const Text('Delete this meal'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _confirmDeleteMeal(
  BuildContext context,
  WidgetRef ref,
  MealLog log,
) {
  ref.read(mealLogsProvider.notifier).deleteMealLog(log.id);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Meal deleted'),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          ref.read(healthDataRepositoryProvider).addMealLog(log);
          ref.invalidate(mealLogsProvider);
        },
      ),
    ),
  );
}

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
                  onPressed: () => ref.invalidate(mealLogsProvider),
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
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = sortedLogs[index];
              return GestureDetector(
                onTap: () => _showMealEditSheet(context, ref, log),
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
                  onDismissed: (_) => _confirmDeleteMeal(context, ref, log),
                  child: _MealHistoryTile(log: log),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.logMeal),
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
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormatter.formatDateTime(log.timestamp),
            style: const TextStyle(
              color: AppThemeTokens.textSecondary,
              fontSize: 14,
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
                      color: AppThemeTokens.warningText,
                      icon: Icons.coffee,
                    ),
                ],
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (log.calories > 0)
            Text(
              '${log.calories.toStringAsFixed(0)} kcal',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.edit_outlined, size: 16, color: AppThemeTokens.textSecondary),
        ],
      ),
    );
  }
}

class _MacroField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _MacroField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
