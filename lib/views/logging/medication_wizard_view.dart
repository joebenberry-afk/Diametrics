import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../viewmodels/logging_wizard_viewmodel.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MedicationWizardView extends ConsumerStatefulWidget {
  const MedicationWizardView({super.key});

  @override
  ConsumerState<MedicationWizardView> createState() =>
      _MedicationWizardViewState();
}

class _MedicationWizardViewState extends ConsumerState<MedicationWizardView> {
  final _dosageCtrl = TextEditingController();

  String _dosageUnit(String medicationType) {
    switch (medicationType) {
      case 'rapid_acting_insulin':
      case 'long_acting_insulin':
        return 'units';
      case 'pill':
        return 'pills';
      default:
        return 'units';
    }
  }

  @override
  void initState() {
    super.initState();
    // Invalidate to guarantee a clean slate — prevents stale state
    // leaking from a previously opened wizard (shared provider, #10).
    ref.invalidate(loggingWizardProvider);
  }

  @override
  void dispose() {
    _dosageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    final hasData = state.pendingMedicationUnits != null;

    return PopScope(
      canPop: !hasData,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text(
              'You have an unsaved medication entry. Are you sure you want to leave?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep editing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if (shouldDiscard == true && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Log Medication'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () {
              if (hasData) {
                Navigator.maybePop(context);
              } else {
                context.pop();
              }
            },
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
              if (state.medicationType != 'pill')
                Text(
                  'Used for Insulin-on-Board calculations in glucose projection',
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
                    width: 200,
                    child: Semantics(
                      label: 'Medication dosage',
                      child: TextFormField(
                      controller: _dosageCtrl,
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
                  ),
                  const SizedBox(width: AppThemeTokens.spaceSm),
                  Text(
                    _dosageUnit(state.medicationType),
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
                                : AppThemeTokens.border.withValues(alpha: 0.8),
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
                    (state.isSubmitting ||
                        state.medicationType.isEmpty ||
                        state.pendingMedicationUnits == null)
                    ? null
                    : () async {
                        final success = await viewModel.saveMedicationLog();
                        if (!context.mounted) return;
                        if (success) {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Medication logged!')),
                          );
                        } else {
                          final errorMsg = ref
                              .read(loggingWizardProvider)
                              .error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                errorMsg ??
                                    'Could not save medication. Please try again.',
                              ),
                              backgroundColor: AppThemeTokens.error,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeTokens.brandAccent,
                  foregroundColor: AppThemeTokens.textPrimaryInverse,
                  disabledBackgroundColor: AppThemeTokens.brandAccent
                      .withValues(alpha: 0.4),
                  disabledForegroundColor: Colors.white54,
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
                    : Text(
                        state.pendingMedicationUnits == null
                            ? 'Enter dosage to save'
                            : 'Save Medication',
                        style: const TextStyle(
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
    ),
    );
  }
}
