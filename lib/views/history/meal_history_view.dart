import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/meal_log.dart';
import '../../router/route_names.dart';
import '../../viewmodels/health_data_viewmodel.dart';
import '../../viewmodels/logging_wizard_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/glucose_log.dart';

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
  final formKey = GlobalKey<FormState>();
  DateTime editedTimestamp = log.timestamp;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppThemeTokens.radiusLg),
      ),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
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
          child: Form(
            key: formKey,
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

              // Timestamp editor
              InkWell(
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: editedTimestamp,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date == null) return;
                  if (!ctx.mounted) return;
                  final time = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.fromDateTime(editedTimestamp),
                  );
                  if (time == null) return;
                  setSheetState(() {
                    editedTimestamp = DateTime(
                      date.year, date.month, date.day,
                      time.hour, time.minute,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppThemeTokens.border),
                    borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 20, color: AppThemeTokens.textSecondary),
                      const SizedBox(width: AppThemeTokens.spaceSm),
                      Expanded(
                        child: Text(
                          DateFormatter.formatDateTime(editedTimestamp),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const Icon(Icons.edit_outlined, size: 16, color: AppThemeTokens.textSecondary),
                    ],
                  ),
                ),
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
                  final carbs = double.tryParse(carbsCtrl.text);
                  final protein = double.tryParse(proteinCtrl.text);
                  final fat = double.tryParse(fatCtrl.text);
                  final cal = double.tryParse(calCtrl.text);

                  // Validate non-negative
                  if ((carbs != null && carbs < 0) ||
                      (protein != null && protein < 0) ||
                      (fat != null && fat < 0) ||
                      (cal != null && cal < 0)) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Values cannot be negative.'),
                        backgroundColor: AppThemeTokens.error,
                      ),
                    );
                    return;
                  }

                  final updated = log.copyWith(
                    name: nameCtrl.text.trim().isEmpty
                        ? null
                        : nameCtrl.text.trim(),
                    timestamp: editedTimestamp,
                    carbohydrates: carbs ?? log.carbohydrates,
                    proteins: protein ?? log.proteins,
                    fats: fat ?? log.fats,
                    calories: cal ?? log.calories,
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

void _showPostMealGlucoseSheet(
  BuildContext context,
  WidgetRef ref,
  MealLog log,
) {
  final glucoseCtrl = TextEditingController();
  final profile = ref.read(userProfileProvider).valueOrNull;
  final unit = profile?.preferredGlucoseUnit ?? 'mg/dL';
  String selectedContext = 'post_meal_120';
  bool isSubmitting = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppThemeTokens.radiusLg),
      ),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
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
                        'Post-Meal Glucose',
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
                const SizedBox(height: AppThemeTokens.spaceSm),
                Text(
                  'How is your blood glucose after this meal?',
                  style: TextStyle(
                    color: AppThemeTokens.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppThemeTokens.spaceLg),
                Row(
                  children: [
                    Expanded(
                      child: _TimingChip(
                        label: '30 min after',
                        isSelected: selectedContext == 'post_meal_30',
                        onTap: () => setSheetState(() => selectedContext = 'post_meal_30'),
                      ),
                    ),
                    const SizedBox(width: AppThemeTokens.spaceSm),
                    Expanded(
                      child: _TimingChip(
                        label: '2 hours after',
                        isSelected: selectedContext == 'post_meal_120',
                        onTap: () => setSheetState(() => selectedContext = 'post_meal_120'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppThemeTokens.spaceLg),
                TextFormField(
                  controller: glucoseCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{0,3}\.?\d{0,1}$'),
                    ),
                  ],
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                    ),
                    hintText: '---',
                    suffixText: unit,
                  ),
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
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final parsed = double.tryParse(glucoseCtrl.text);
                          if (parsed == null || parsed <= 0) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Enter a valid glucose reading.'),
                                backgroundColor: AppThemeTokens.error,
                              ),
                            );
                            return;
                          }
                          final isMmol = unit == 'mmol/L';
                          final max = isMmol ? 27.8 : 500.0;
                          if (parsed > max) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text('Maximum value is ${max.toStringAsFixed(isMmol ? 1 : 0)} $unit'),
                                backgroundColor: AppThemeTokens.error,
                              ),
                            );
                            return;
                          }
                          setSheetState(() => isSubmitting = true);
                          final success = await ref
                              .read(loggingWizardProvider.notifier)
                              .savePostMealGlucose(
                                value: parsed,
                                unit: unit,
                                mealId: log.id,
                                context: selectedContext,
                              );
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          if (success) {
                            ref.invalidate(linkedGlucoseProvider(log.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Post-meal glucose saved!'),
                                backgroundColor: AppThemeTokens.brandSuccess,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Reading',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
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
                  child: _MealHistoryTile(
                    log: log,
                    onAddPostMealGlucose: () => _showPostMealGlucoseSheet(context, ref, log),
                  ),
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

class _MealHistoryTile extends ConsumerWidget {
  final MealLog log;
  final VoidCallback onAddPostMealGlucose;

  const _MealHistoryTile({
    required this.log,
    required this.onAddPostMealGlucose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultTitle =
        '${log.mealType[0].toUpperCase()}${log.mealType.substring(1)} meal';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final unit = profile?.preferredGlucoseUnit ?? 'mg/dL';
    final linkedGlucoseAsync = ref.watch(linkedGlucoseProvider(log.id));

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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${log.carbohydrates.toStringAsFixed(0)}g carbs • ${log.proteins.toStringAsFixed(0)}g protein • ${log.fats.toStringAsFixed(0)}g fat',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
          linkedGlucoseAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (linkedLogs) {
              if (linkedLogs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: onAddPostMealGlucose,
                    borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppThemeTokens.spaceSm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemeTokens.brandPrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
                        border: Border.all(
                          color: AppThemeTokens.brandPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 16,
                            color: AppThemeTokens.brandPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Add Post-Meal Glucose',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppThemeTokens.brandPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildComparisonRow(linkedLogs, unit),
                );
              }
            },
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
          IconButton(
            icon: const Icon(Icons.replay_outlined, size: 18),
            tooltip: 'Log similar meal',
            color: AppThemeTokens.brandSuccess,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            onPressed: () {
              ref.read(loggingWizardProvider.notifier).initFromMeal(log);
              if (context.mounted) context.push(Routes.logMeal);
            },
          ),
          const Icon(Icons.edit_outlined, size: 16, color: AppThemeTokens.textSecondary),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(List<GlucoseLog> linkedLogs, String unit) {
    final postMealLog = linkedLogs.firstWhere(
      (g) => g.context == 'post_meal_120',
      orElse: () => linkedLogs.first,
    );

    final actualValue = postMealLog.unit == unit
        ? postMealLog.value
        : unit == 'mmol/L'
            ? postMealLog.value / 18.0182
            : postMealLog.value * 18.0182;

    final predictedValue = log.projectionTwoHourMgDl > 0
        ? (unit == 'mmol/L'
            ? log.projectionTwoHourMgDl / 18.0182
            : log.projectionTwoHourMgDl)
        : null;

    final displayActual = unit == 'mmol/L'
        ? actualValue.toStringAsFixed(1)
        : actualValue.toStringAsFixed(0);

    return Wrap(
      spacing: AppThemeTokens.spaceSm,
      children: [
        _MiniChip(
          label: 'Actual: $displayActual $unit',
          color: AppThemeTokens.brandSuccessLight,
          icon: Icons.check_circle_outline,
        ),
        if (predictedValue != null)
          _MiniChip(
            label: 'Predicted: ${unit == 'mmol/L' ? predictedValue.toStringAsFixed(1) : predictedValue.toStringAsFixed(0)} $unit',
            color: AppThemeTokens.brandAccent,
            icon: Icons.auto_graph,
          ),
      ],
    );
  }
}

class _MacroField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _MacroField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}\.?\d{0,1}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return null;
        final v = double.tryParse(val);
        if (v == null) return 'Invalid number';
        if (v < 0) return 'Cannot be negative';
        return null;
      },
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

class _TimingChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimingChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppThemeTokens.spaceMd,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeTokens.brandPrimary
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppThemeTokens.brandPrimary
                : AppThemeTokens.border,
          ),
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
