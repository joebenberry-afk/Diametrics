import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../viewmodels/logging_wizard_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';

class GlucoseWizardView extends ConsumerStatefulWidget {
  const GlucoseWizardView({super.key});

  @override
  ConsumerState<GlucoseWizardView> createState() => _GlucoseWizardViewState();
}

class _GlucoseWizardViewState extends ConsumerState<GlucoseWizardView> {
  final _glucoseCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Invalidate to guarantee a clean slate — prevents stale state
    // leaking from a previously opened wizard (shared provider, #10).
    ref.invalidate(loggingWizardProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Load the user's preferred glucose unit so logged readings use the
      // correct unit tag rather than always defaulting to 'mg/dL'.
      final profile = ref.read(userProfileProvider).valueOrNull;
      final unit = profile?.preferredGlucoseUnit ?? 'mg/dL';
      ref.read(loggingWizardProvider.notifier).initGlucoseUnit(unit);
    });
  }

  @override
  void dispose() {
    _glucoseCtrl.dispose();
    super.dispose();
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

    final hasData = state.pendingGlucoseValue != null;

    return PopScope(
      canPop: !hasData,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldDiscard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text(
              'You have an unsaved glucose reading. Are you sure you want to leave?',
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
        title: const Text('Log Blood Glucose'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
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
                    width: 200,
                    child: Semantics(
                      label: 'Blood glucose value',
                      child: TextFormField(
                      controller: _glucoseCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: isDark
                            ? Colors.white
                            : AppThemeTokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '---',
                        hintStyle: TextStyle(
                          color: AppThemeTokens.textSecondary,
                        ),
                        errorStyle: TextStyle(fontSize: 14),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed == null) return;
                        final isValid = state.glucoseUnit == 'mmol/L'
                            ? parsed >= 1.1 && parsed <= 27.8
                            : parsed >= 20 && parsed <= 500;
                        if (isValid) {
                          viewModel.updateGlucoseValue(parsed);
                        }
                      },
                      validator: (val) {
                        final v = double.tryParse(val ?? '');
                        if (v == null) return 'Enter a number';
                        final unit = state.glucoseUnit;
                        if (unit == 'mmol/L' && (v < 1.1 || v > 27.8)) {
                          return 'Enter a value between 1.1 and 27.8 mmol/L';
                        }
                        if (unit == 'mg/dL' && (v < 20 || v > 500)) {
                          return 'Enter a value between 20 and 500 mg/dL';
                        }
                        return null;
                      },
                    ),
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
                              ? AppThemeTokens.brandPrimary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppThemeTokens.brandPrimary
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
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            const SizedBox(width: AppThemeTokens.spaceMd),
                            Text(
                              option['label']!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected ? Colors.white : null,
                              ),
                            ),
                            if (option['value'] == 'pre_meal' ||
                                option['value'] == 'post_meal_30') ...[
                              const Spacer(),
                              Icon(
                                Icons.bolt,
                                color: isSelected ? Colors.white70 : AppThemeTokens.brandAccent,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AI Input',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isSelected ? Colors.white70 : AppThemeTokens.brandAccent,
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
                        if (!context.mounted) return;
                        if (success) {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Glucose reading saved!'),
                            ),
                          );
                        } else {
                          final errorMsg = ref
                              .read(loggingWizardProvider)
                              .error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                errorMsg ??
                                    'Could not save reading. Please try again.',
                              ),
                              backgroundColor: AppThemeTokens.error,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeTokens.brandPrimary,
                  foregroundColor: AppThemeTokens.textPrimaryInverse,
                  disabledBackgroundColor: AppThemeTokens.brandPrimary
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
                        state.pendingGlucoseValue == null
                            ? 'Enter a reading to save'
                            : 'Save Reading',
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
