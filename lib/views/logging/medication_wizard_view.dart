import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_tokens.dart';
import '../../viewmodels/logging_wizard_viewmodel.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MedicationWizardView extends ConsumerWidget {
  const MedicationWizardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loggingWizardProvider);
    final viewModel = ref.read(loggingWizardProvider.notifier);
    final theme = Theme.of(context);

    // Context options mapped to FDA IOB (Insulin on Board) safety constraints
    final typeOptions = [
      {
        'value': 'rapid_acting_insulin',
        'label': 'Rapid-Acting Insulin (Meal Bolus)',
      },
      {'value': 'long_acting_insulin', 'label': 'Long-Acting Insulin (Basal)'},
      {'value': 'pill', 'label': 'Oral Medication (Pill)'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Medication'),
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
              Text(
                'Enter Dosage Units',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),
              Text(
                'Required for Insulin-on-Board calculations',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppThemeTokens.textSecondary,
                ),
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
                      initialValue:
                          state.pendingMedicationUnits?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: AppThemeTokens.brandAccent,
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
                          viewModel.updateMedicationUnits(parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppThemeTokens.spaceSm),
                  Text(
                    'Units',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppThemeTokens.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppThemeTokens.spaceXl),
              Text(
                'Medication Type',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),

              // Type Selectors
              Expanded(
                child: ListView.separated(
                  itemCount: typeOptions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppThemeTokens.spaceSm),
                  itemBuilder: (context, index) {
                    final option = typeOptions[index];
                    final isSelected = state.medicationType == option['value'];

                    return InkWell(
                      onTap: () =>
                          viewModel.updateMedicationType(option['value']!),
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusMd,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppThemeTokens.brandAccent.withValues(
                                  alpha: 0.1,
                                )
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppThemeTokens.brandAccent
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
                                  ? AppThemeTokens.brandAccent
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
                    state.isSubmitting || state.pendingMedicationUnits == null
                    ? null
                    : () async {
                        final success = await viewModel.saveMedicationLog();
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Medication logged!')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeTokens.brandAccent,
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
                        'Save Medication',
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
