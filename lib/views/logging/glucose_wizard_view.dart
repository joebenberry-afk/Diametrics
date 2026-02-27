import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_tokens.dart';
import '../../viewmodels/logging_wizard_viewmodel.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GlucoseWizardView extends ConsumerWidget {
  const GlucoseWizardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loggingWizardProvider);
    final viewModel = ref.read(loggingWizardProvider.notifier);
    final theme = Theme.of(context);

    // Context options mapped to the prediction phases in the implementation plan
    final contextOptions = [
      {'value': 'fasting', 'label': 'Morning Fasting'},
      {'value': 'pre_meal', 'label': 'Before Meal (Baseline)'},
      {'value': 'post_meal_30', 'label': '30 Mins After (RLS Feedback)'},
      {'value': 'post_meal_120', 'label': '2 Hours After'},
      {'value': 'bedtime', 'label': 'Bedtime'},
      {'value': 'night_time', 'label': 'Night Time'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Blood Glucose'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Cancel',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemeTokens.spaceLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppThemeTokens.spaceLg),
              // Prominent numeric entry
              Text(
                'Enter Reading',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemeTokens.spaceLg),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      initialValue: state.pendingGlucoseValue?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: AppThemeTokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '---',
                        hintStyle: TextStyle(
                          color: AppThemeTokens.textSecondary,
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null) {
                          viewModel.updateGlucoseValue(parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppThemeTokens.spaceSm),
                  Text(
                    state.glucoseUnit,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppThemeTokens.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppThemeTokens.spaceXl),
              Text(
                'When was this reading taken?',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),

              // Context Selectors (Crucial for AI Baseline & Feedback)
              Expanded(
                child: ListView.separated(
                  itemCount: contextOptions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppThemeTokens.spaceSm),
                  itemBuilder: (context, index) {
                    final option = contextOptions[index];
                    final isSelected = state.glucoseContext == option['value'];

                    return InkWell(
                      onTap: () =>
                          viewModel.updateGlucoseContext(option['value']!),
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusMd,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppThemeTokens.brandPrimary.withValues(
                                  alpha: 0.1,
                                )
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppThemeTokens.brandPrimary
                                : Colors.grey.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppThemeTokens.radiusMd,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppThemeTokens.brandPrimary
                                  : Colors.grey,
                            ),
                            const SizedBox(width: AppThemeTokens.spaceMd),
                            Text(
                              option['label']!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (option['value'] == 'pre_meal' ||
                                option['value'] == 'post_meal_30') ...[
                              const Spacer(),
                              Icon(
                                Icons.bolt,
                                color: AppThemeTokens.brandAccent,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AI Input',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppThemeTokens.brandAccent,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppThemeTokens.spaceMd,
                  ),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: AppThemeTokens.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Save Button
              ElevatedButton(
                onPressed:
                    state.isSubmitting || state.pendingGlucoseValue == null
                    ? null
                    : () async {
                        final success = await viewModel.saveGlucoseLog();
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Glucose reading saved!'),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeTokens.brandPrimary,
                  foregroundColor: AppThemeTokens.textPrimaryInverse,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppThemeTokens.spaceLg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusLg,
                    ),
                  ),
                ),
                child: state.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Reading',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: AppThemeTokens.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}
