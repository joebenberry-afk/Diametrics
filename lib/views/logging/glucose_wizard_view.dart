import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_tokens.dart';
import '../../viewmodels/logging_wizard_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';

class GlucoseWizardView extends ConsumerStatefulWidget {
  const GlucoseWizardView({super.key});

  @override
  ConsumerState<GlucoseWizardView> createState() => _GlucoseWizardViewState();
}

class _GlucoseWizardViewState extends ConsumerState<GlucoseWizardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Reset any stale state from a previously opened wizard.
      ref.read(loggingWizardProvider.notifier).reset();
      // Load the user's preferred glucose unit so logged readings use the
      // correct unit tag rather than always defaulting to 'mg/dL'.
      final profile = ref.read(userProfileProvider).valueOrNull;
      final unit = profile?.preferredGlucoseUnit ?? 'mg/dL';
      ref.read(loggingWizardProvider.notifier).initGlucoseUnit(unit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loggingWizardProvider);
    final viewModel = ref.read(loggingWizardProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        actions: const [],
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
                        color: isDark ? Colors.white : AppThemeTokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '---',
                        hintStyle: TextStyle(
                          color: AppThemeTokens.textSecondary,
                        ),
                        errorStyle: TextStyle(fontSize: 11),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed == null) return;
                        final isValid = state.glucoseUnit == 'mmol/L'
                            ? parsed >= 1.1 && parsed <= 33.3
                            : parsed >= 20 && parsed <= 600;
                        if (isValid) {
                          viewModel.updateGlucoseValue(parsed);
                        }
                      },
                      validator: (val) {
                        final v = double.tryParse(val ?? '');
                        if (v == null) return 'Enter a number';
                        final unit = state.glucoseUnit;
                        if (unit == 'mmol/L' && (v < 1.1 || v > 33.3)) {
                          return 'Enter a value between 1.1 and 33.3 mmol/L';
                        }
                        if (unit == 'mg/dL' && (v < 20 || v > 600)) {
                          return 'Enter a value between 20 and 600 mg/dL';
                        }
                        return null;
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
