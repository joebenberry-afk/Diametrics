import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_tokens.dart';
import '../../repositories/user_repository.dart';
import '../../src/domain/entities/food_scanner_result.dart';
import '../../viewmodels/logging_wizard_viewmodel.dart';
import 'package:go_router/go_router.dart';
import '../../models/projection_result.dart';
import '../../router/projection_route_args.dart';
import '../../router/route_names.dart';

class MealWizardView extends ConsumerStatefulWidget {
  const MealWizardView({super.key});

  @override
  ConsumerState<MealWizardView> createState() => _MealWizardViewState();
}

class _MealWizardViewState extends ConsumerState<MealWizardView> {
  // User profile weight for projection
  double _weightKg = 70.0;
  String _preferredGlucoseUnit = 'mg/dL';

  // Controllers for macro fields so they can be updated programmatically by AI
  final _carbsCtrl = TextEditingController();
  final _fiberCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Reset any stale state from a previously opened (but cancelled) wizard.
      ref.read(loggingWizardProvider.notifier).reset();
      ref.read(loggingWizardProvider.notifier).checkRecentPreMealGlucose();
      _loadUserWeight();
    });
  }

  @override
  void dispose() {
    _carbsCtrl.dispose();
    _fiberCtrl.dispose();
    _proteinCtrl.dispose();
    _fatsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserWeight() async {
    final profile = await UserRepository().getProfile();
    if (profile != null && mounted) {
      setState(() {
        _weightKg = profile.weightKg;
        _preferredGlucoseUnit = profile.preferredGlucoseUnit;
      });
    }
  }

  /// Pushes FoodScannerView and applies the confirmed result to the meal form.
  Future<void> _openFoodScanner() async {
    final result = await context.push<FoodScannerResult>(
      Routes.logMealFoodScanner,
    );
    if (result == null || !mounted) return;

    ref.read(loggingWizardProvider.notifier).updateMealMacros(
      carbs: result.totalCarbs,
      proteins: result.totalProtein,
      fats: result.totalFat,
      calories: result.totalCalories,
    );

    _carbsCtrl.text = result.totalCarbs.toStringAsFixed(1);
    _proteinCtrl.text = result.totalProtein.toStringAsFixed(1);
    _fatsCtrl.text = result.totalFat.toStringAsFixed(1);

    if (mounted) {
      final itemNames = result.items.map((i) => i.name).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.items.length} item(s) added: $itemNames',
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: AppThemeTokens.brandSuccess,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Simple scan-food button — replaces the old camera area widget.
  Widget _buildFoodScanButton() {
    return OutlinedButton.icon(
      icon: const Icon(LucideIcons.scanLine, size: 18),
      label: const Text('Scan Food'),
      onPressed: _openFoodScanner,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppThemeTokens.brandAccent,
        side: BorderSide(color: AppThemeTokens.brandAccent.withValues(alpha: 0.7)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        ),
        minimumSize: const Size.fromHeight(AppThemeTokens.minTapTarget),
      ),
    );
  }

  // ── Pre-meal Glucose Section ────────────────────────────────────────

  Widget _buildPreMealGlucoseSection(
    ThemeData theme,
    bool isDark,
    LoggingWizardState state,
    LoggingWizardViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeTokens.brandSecondary.withValues(alpha: 0.15)
            : AppThemeTokens.brandPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color: state.preMealGlucose != null
              ? AppThemeTokens.brandSuccessLight.withValues(alpha: 0.6)
              : AppThemeTokens.brandAccent.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.heartPulse,
                color: AppThemeTokens.brandAccent,
                size: 20,
              ),
              const SizedBox(width: AppThemeTokens.spaceSm),
              Expanded(
                child: Text(
                  'Pre-Meal Blood Glucose',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppThemeTokens.brandAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusFull),
                  border: Border.all(
                    color: AppThemeTokens.brandAccent.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt,
                        color: AppThemeTokens.brandAccent, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      'Required',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppThemeTokens.brandAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),

          // Auto-detected value
          if (state.hasAutoDetectedGlucose && state.preMealGlucose != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppThemeTokens.spaceMd,
                vertical: AppThemeTokens.spaceSm,
              ),
              decoration: BoxDecoration(
                color: AppThemeTokens.brandSuccessLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.checkCircle,
                      color: AppThemeTokens.brandSuccessLight, size: 18),
                  const SizedBox(width: AppThemeTokens.spaceSm),
                  Text(
                    '${state.preMealGlucose!.toStringAsFixed(0)} $_preferredGlucoseUnit',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppThemeTokens.brandSuccessLight,
                    ),
                  ),
                  const SizedBox(width: AppThemeTokens.spaceSm),
                  Expanded(
                    child: Text(
                      'recent reading auto-detected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
                    onTap: () {
                      ref.read(loggingWizardProvider.notifier)
                          .setPreMealGlucose(0);
                      // Clear so user can enter manually
                      ref.read(loggingWizardProvider.notifier)
                          .checkRecentPreMealGlucose();
                    },
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: AppThemeTokens.brandAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              'Enter your current blood glucose level',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}$')),
                    ],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '---',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white30
                            : AppThemeTokens.textSecondary.withValues(alpha: 0.5),
                        fontSize: 32,
                      ),
                      suffixText: _preferredGlucoseUnit,
                      suffixStyle: TextStyle(
                        color: isDark ? Colors.white60 : AppThemeTokens.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        final isMmol = _preferredGlucoseUnit == 'mmol/L';
                        final max = isMmol ? 33.3 : 600.0;
                        if (parsed <= max) {
                          viewModel.setPreMealGlucose(parsed);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Main Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loggingWizardProvider);
    final viewModel = ref.read(loggingWizardProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final canSave = !state.isSubmitting &&
        state.preMealGlucose != null &&
        state.preMealGlucose! > 0 &&
        state.pendingCarbs != null &&
        state.pendingProteins != null &&
        state.pendingFats != null;

    return Scaffold(
      backgroundColor: isDark
          ? AppThemeTokens.bgBackgroundDark
          : AppThemeTokens.bgBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppThemeTokens.bgSurfaceDark
            : AppThemeTokens.bgSurface,
        elevation: 0,
        title: Text(
          'Log Meal',
          style: TextStyle(
            color: isDark ? Colors.white : AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppThemeTokens.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.x,
              color: isDark ? Colors.white70 : AppThemeTokens.textSecondary,
            ),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Cancel',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Pre-Meal Glucose Gate ──────────────────────────────
              _buildPreMealGlucoseSection(theme, isDark, state, viewModel),
              const SizedBox(height: AppThemeTokens.spaceLg),

              // ── AI Food Camera ────────────────────────────────────
              _SectionHeader(
                label: 'AI Food Analysis',
                icon: LucideIcons.sparkles,
                isDark: isDark,
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),
              _buildFoodScanButton(),
              const SizedBox(height: AppThemeTokens.spaceLg),

              // ── Macronutrients ────────────────────────────────────
              _SectionHeader(
                label: 'Macronutrients',
                subtitle: 'Review AI values or enter manually',
                icon: LucideIcons.barChart2,
                isDark: isDark,
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),

              Container(
                padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeTokens.bgSurfaceDark
                      : Colors.white,
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  children: [
                    _MacroInputRow(
                      label: 'Carbohydrates',
                      unit: 'g',
                      controller: _carbsCtrl,
                      icon: LucideIcons.wheat,
                      accentColor: const Color(0xFFFFB703),
                      isDark: isDark,
                      onChanged: (val) => viewModel.updateMealMacros(
                        carbs: double.tryParse(val),
                        fiber: state.pendingFiber,
                        proteins: state.pendingProteins,
                        fats: state.pendingFats,
                      ),
                    ),
                    const Divider(height: 1),
                    _MacroInputRow(
                      label: 'Dietary Fiber',
                      unit: 'g',
                      controller: _fiberCtrl,
                      icon: LucideIcons.leaf,
                      accentColor: AppThemeTokens.brandSuccessLight,
                      isDark: isDark,
                      optional: true,
                      onChanged: (val) => viewModel.updateMealMacros(
                        carbs: state.pendingCarbs,
                        fiber: double.tryParse(val),
                        proteins: state.pendingProteins,
                        fats: state.pendingFats,
                      ),
                    ),
                    const Divider(height: 1),
                    _MacroInputRow(
                      label: 'Protein',
                      unit: 'g',
                      controller: _proteinCtrl,
                      icon: LucideIcons.egg,
                      accentColor: AppThemeTokens.brandAccent,
                      isDark: isDark,
                      onChanged: (val) => viewModel.updateMealMacros(
                        carbs: state.pendingCarbs,
                        fiber: state.pendingFiber,
                        proteins: double.tryParse(val),
                        fats: state.pendingFats,
                      ),
                    ),
                    const Divider(height: 1),
                    _MacroInputRow(
                      label: 'Fat',
                      unit: 'g',
                      controller: _fatsCtrl,
                      icon: LucideIcons.droplet,
                      accentColor: const Color(0xFFE63946),
                      isDark: isDark,
                      onChanged: (val) => viewModel.updateMealMacros(
                        carbs: state.pendingCarbs,
                        fiber: state.pendingFiber,
                        proteins: state.pendingProteins,
                        fats: double.tryParse(val),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppThemeTokens.spaceLg),

              // ── Advanced Trackers ─────────────────────────────────
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppThemeTokens.bgSurfaceDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: ExpansionTile(
                    leading: Icon(LucideIcons.settings,
                        color: isDark
                            ? Colors.white54
                            : AppThemeTokens.textSecondary,
                        size: 20),
                    title: Text(
                      'Advanced Prediction Modifiers',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      'Alcohol, caffeine, and food form affect glucose',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    children: [
                      SwitchListTile.adaptive(
                        title: Text(
                          'Contains Alcohol',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppThemeTokens.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Inhibits gluconeogenesis — may increase hypo risk',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : AppThemeTokens.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        value: state.containsAlcohol,
                        onChanged: viewModel.toggleAlcohol,
                        activeThumbColor: AppThemeTokens.warning,
                      ),
                      SwitchListTile.adaptive(
                        title: Text(
                          'High Caffeine (>200 mg)',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppThemeTokens.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Can temporarily spike glucose absorption',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : AppThemeTokens.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        value: state.containsCaffeine,
                        onChanged: viewModel.toggleCaffeine,
                        activeThumbColor: AppThemeTokens.brandAccent,
                      ),
                      const Divider(height: 1),

                      // ── Food Form Factor Chips ──
                      Padding(
                        padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Food Form',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppThemeTokens.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Affects absorption speed — liquid carbs spike faster',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white54
                                    : AppThemeTokens.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: AppThemeTokens.spaceSm),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _FoodFormChip(
                                  label: 'Standard',
                                  icon: LucideIcons.utensils,
                                  isSelected: state.foodFormFactor == 'standard',
                                  isDark: isDark,
                                  onTap: () => viewModel.updateFoodFormFactor('standard'),
                                ),
                                _FoodFormChip(
                                  label: 'Liquid',
                                  icon: LucideIcons.glassWater,
                                  isSelected: state.foodFormFactor == 'liquid',
                                  isDark: isDark,
                                  onTap: () => viewModel.updateFoodFormFactor('liquid'),
                                ),
                                _FoodFormChip(
                                  label: 'Whole Grain',
                                  icon: LucideIcons.wheat,
                                  isSelected: state.foodFormFactor == 'highFiber',
                                  isDark: isDark,
                                  onTap: () => viewModel.updateFoodFormFactor('highFiber'),
                                ),
                                _FoodFormChip(
                                  label: 'Processed',
                                  icon: LucideIcons.cookie,
                                  isSelected: state.foodFormFactor == 'processed',
                                  isDark: isDark,
                                  onTap: () => viewModel.updateFoodFormFactor('processed'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppThemeTokens.spaceXl),

              // ── Error message ─────────────────────────────────────
              if (state.error != null)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppThemeTokens.spaceMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
                    decoration: BoxDecoration(
                      color: AppThemeTokens.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                      border: Border.all(
                        color: AppThemeTokens.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertCircle,
                            color: AppThemeTokens.error, size: 18),
                        const SizedBox(width: AppThemeTokens.spaceSm),
                        Expanded(
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: AppThemeTokens.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Save & Project Button ─────────────────────────────
              AnimatedOpacity(
                opacity: canSave ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: canSave
                      ? () async {
                          final data =
                              await viewModel.saveMealWithProjection(
                            weightKg: _weightKg,
                          );
                          if (data != null && context.mounted) {
                            context.pushReplacement(
                              Routes.logMealProjection,
                              extra: ProjectionRouteArgs(
                                result: data['result'] as ProjectionResult,
                                unit: data['unit'] as String,
                                mealCount: (data['mealCount'] ?? 0) as int,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeTokens.brandSecondary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppThemeTokens.brandSecondary.withValues(alpha: 0.4),
                    disabledForegroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppThemeTokens.spaceLg,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppThemeTokens.radiusLg),
                    ),
                    elevation: canSave ? 4 : 0,
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.trendingUp, size: 20),
                            const SizedBox(width: AppThemeTokens.spaceSm),
                            const Text(
                              'Save & Calculate Glucose Prediction',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Hint if button is disabled
              if (!canSave && !state.isSubmitting)
                Padding(
                  padding: const EdgeInsets.only(top: AppThemeTokens.spaceSm),
                  child: Text(
                    state.preMealGlucose == null
                        ? 'Enter your pre-meal glucose to continue'
                        : 'Enter carbs, protein and fat values to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : AppThemeTokens.textSecondary,
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

// ── Section Header ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final bool isDark;

  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.isDark,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: isDark ? AppThemeTokens.brandAccent : AppThemeTokens.brandSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                letterSpacing: 0.1,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white38 : AppThemeTokens.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Macro Input Row ─────────────────────────────────────────────────────────────

class _MacroInputRow extends StatelessWidget {
  final String label;
  final String unit;
  final TextEditingController controller;
  final Function(String) onChanged;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final bool optional;

  const _MacroInputRow({
    required this.label,
    required this.unit,
    required this.controller,
    required this.onChanged,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppThemeTokens.spaceSm,
        horizontal: AppThemeTokens.spaceSm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: AppThemeTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                  ),
                ),
                if (optional)
                  Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : AppThemeTokens.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            child: TextFormField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,4}\.?\d{0,1}')),
              ],
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
                hintText: '0',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : Colors.grey.shade400,
                  fontWeight: FontWeight.normal,
                ),
                suffixText: unit,
                suffixStyle: TextStyle(
                  color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
                  fontSize: 14,
                ),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip widget for selecting food form factor (standard, liquid, highFiber, processed).
class _FoodFormChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FoodFormChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusFull),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeTokens.brandPrimary.withValues(alpha: 0.15)
              : isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusFull),
          border: Border.all(
            color: isSelected
                ? AppThemeTokens.brandPrimary
                : isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? AppThemeTokens.brandPrimary
                  : isDark
                      ? Colors.white54
                      : AppThemeTokens.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppThemeTokens.brandPrimary
                    : isDark
                        ? Colors.white70
                        : AppThemeTokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
