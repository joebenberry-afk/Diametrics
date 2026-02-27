import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../config/app_lock_config.dart';
import '../../core/theme/app_tokens.dart';
import '../../repositories/user_repository.dart';
import '../../src/core/di/injection.dart';
import '../../src/domain/entities/food_analysis_result.dart';
import '../../src/domain/repositories/food_analyzer_repository.dart';
import '../../viewmodels/logging_wizard_viewmodel.dart';
import '../projection/projection_result_view.dart';

class MealWizardView extends ConsumerStatefulWidget {
  const MealWizardView({super.key});

  @override
  ConsumerState<MealWizardView> createState() => _MealWizardViewState();
}

class _MealWizardViewState extends ConsumerState<MealWizardView> {
  // Camera / AI state
  File? _imageFile;
  bool _isAnalyzing = false;
  String? _analysisError;
  FoodAnalysisResult? _analysisResult;
  final _picker = ImagePicker();

  // User profile weight for projection
  double _weightKg = 70.0;

  @override
  void initState() {
    super.initState();
    // Check for a recent pre-meal glucose reading and load user weight
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loggingWizardProvider.notifier).checkRecentPreMealGlucose();
      _loadUserWeight();
    });
  }

  Future<void> _loadUserWeight() async {
    final profile = await UserRepository().getProfile();
    if (profile != null && mounted) {
      setState(() => _weightKg = profile.weightKg);
    }
  }

  // ── Camera Methods ──────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    AppLockConfig.ignoreNextResume = true;
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _isAnalyzing = true;
      _analysisError = null;
      _analysisResult = null;
    });

    try {
      final result =
          await getIt<FoodAnalyzerRepository>().analyzeImage(picked.path);
      final vm = ref.read(loggingWizardProvider.notifier);
      final totalProtein =
          result.items.fold(0.0, (sum, item) => sum + item.proteinGrams);
      final totalFat =
          result.items.fold(0.0, (sum, item) => sum + item.fatGrams);
      vm.updateMealMacros(
        carbs: result.totalCarbs,
        fiber: null,
        proteins: totalProtein,
        fats: totalFat,
      );
      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      final msg =
          e.toString().split('\n').first.replaceFirst('Exception: ', '');
      setState(() {
        _analysisError = msg;
        _isAnalyzing = false;
      });
    }
  }

  void _showSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppThemeTokens.radiusLg),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppThemeTokens.spaceSm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppThemeTokens.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusFull),
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
            ListTile(
              leading: const Icon(LucideIcons.camera,
                  color: AppThemeTokens.brandPrimary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image,
                  color: AppThemeTokens.brandPrimary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: AppThemeTokens.spaceMd),
          ],
        ),
      ),
    );
  }

  // ── Pre-meal Glucose Section ────────────────────────────────────────

  Widget _buildPreMealGlucoseSection(
    ThemeData theme,
    LoggingWizardState state,
    LoggingWizardViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      decoration: BoxDecoration(
        color: AppThemeTokens.brandPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color: state.preMealGlucose != null
              ? AppThemeTokens.brandSuccess.withValues(alpha: 0.5)
              : AppThemeTokens.brandPrimary.withValues(alpha: 0.3),
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
                color: AppThemeTokens.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: AppThemeTokens.spaceSm),
              Text(
                'Pre-Meal Blood Glucose',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppThemeTokens.textPrimary,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt,
                      color: AppThemeTokens.brandAccent, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    'Required',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppThemeTokens.brandAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),

          // Auto-detected value
          if (state.hasAutoDetectedGlucose && state.preMealGlucose != null)
            Row(
              children: [
                const Icon(LucideIcons.checkCircle,
                    color: AppThemeTokens.brandSuccess, size: 16),
                const SizedBox(width: AppThemeTokens.spaceSm),
                Text(
                  '${state.preMealGlucose!.toStringAsFixed(0)} mg/dL',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppThemeTokens.brandPrimary,
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceSm),
                Text(
                  '(recent reading detected)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppThemeTokens.textSecondary,
                  ),
                ),
              ],
            )
          else
            // Manual entry field
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppThemeTokens.brandPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '---',
                      hintStyle: TextStyle(
                        color: AppThemeTokens.textSecondary,
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) {
                        viewModel.setPreMealGlucose(parsed);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceSm),
                Text(
                  'mg/dL',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppThemeTokens.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Camera Area ─────────────────────────────────────────────────────

  Widget _buildCameraArea(ThemeData theme) {
    final base = BoxDecoration(
      color: AppThemeTokens.brandPrimary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
      border: Border.all(
        color: AppThemeTokens.brandPrimary.withValues(alpha: 0.3),
        width: 2,
      ),
    );

    if (_isAnalyzing) {
      return Container(
        height: 120,
        decoration: base,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppThemeTokens.brandPrimary,
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Text(
              'Analyzing with AI…',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppThemeTokens.brandPrimary,
              ),
            ),
          ],
        ),
      );
    }

    if (_analysisError != null) {
      return GestureDetector(
        onTap: _showSourceSheet,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemeTokens.spaceMd,
            vertical: AppThemeTokens.spaceMd,
          ),
          decoration: base.copyWith(
            border: Border.all(
              color: AppThemeTokens.error.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.alertCircle,
                  color: AppThemeTokens.error),
              const SizedBox(width: AppThemeTokens.spaceSm),
              Expanded(
                child: Text(
                  _analysisError!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppThemeTokens.error,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: _showSourceSheet,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_analysisResult != null && _imageFile != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
            decoration: base.copyWith(
              border: Border.all(
                color: AppThemeTokens.brandSuccess.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppThemeTokens.radiusMd),
                  child: Image.file(_imageFile!,
                      width: 64, height: 64, fit: BoxFit.cover),
                ),
                const SizedBox(width: AppThemeTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.checkCircle,
                              color: AppThemeTokens.brandSuccess, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'AI Analysis Complete',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppThemeTokens.brandSuccess,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _analysisResult!.summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppThemeTokens.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _showSourceSheet,
                  child: const Text('Re-analyze'),
                ),
              ],
            ),
          ),
          if (_analysisResult!.items.isNotEmpty) ...[
            const SizedBox(height: AppThemeTokens.spaceSm),
            Container(
              decoration: BoxDecoration(
                color: AppThemeTokens.bgSurface,
                borderRadius:
                    BorderRadius.circular(AppThemeTokens.radiusMd),
                border: Border.all(
                  color:
                      AppThemeTokens.brandPrimary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: _analysisResult!.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppThemeTokens.spaceMd,
                      vertical: AppThemeTokens.spaceSm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style:
                                    theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppThemeTokens.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.portion,
                                style:
                                    theme.textTheme.bodySmall?.copyWith(
                                  color: AppThemeTokens.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.carbsGrams.toStringAsFixed(1)}g carbs',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppThemeTokens.brandPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      );
    }

    return GestureDetector(
      onTap: _showSourceSheet,
      child: Container(
        height: 120,
        decoration: base,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.camera,
                size: 40, color: AppThemeTokens.brandPrimary),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Text(
              'Tap to analyze food with AI',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppThemeTokens.brandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loggingWizardProvider);
    final viewModel = ref.read(loggingWizardProvider.notifier);
    final theme = Theme.of(context);

    final canSave = !state.isSubmitting &&
        state.preMealGlucose != null &&
        state.pendingCarbs != null &&
        state.pendingProteins != null &&
        state.pendingFats != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Pre-Meal Glucose Gate ──
              _buildPreMealGlucoseSection(theme, state, viewModel),
              const SizedBox(height: AppThemeTokens.spaceLg),

              // ── Camera / AI ──
              _buildCameraArea(theme),
              const SizedBox(height: AppThemeTokens.spaceXl),

              // ── Macros ──
              Text('Core Macronutrients',
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppThemeTokens.spaceMd),

              _MacroInputRow(
                label: 'Carbohydrates (g)',
                value: state.pendingCarbs,
                onChanged: (val) => viewModel.updateMealMacros(
                  carbs: double.tryParse(val),
                  fiber: state.pendingFiber,
                  proteins: state.pendingProteins,
                  fats: state.pendingFats,
                ),
                isAIRequired: true,
              ),
              _MacroInputRow(
                label: 'Dietary Fiber (g) [Optional]',
                value: state.pendingFiber,
                onChanged: (val) => viewModel.updateMealMacros(
                  carbs: state.pendingCarbs,
                  fiber: double.tryParse(val),
                  proteins: state.pendingProteins,
                  fats: state.pendingFats,
                ),
                isAIRequired: false,
              ),
              _MacroInputRow(
                label: 'Proteins (g)',
                value: state.pendingProteins,
                onChanged: (val) => viewModel.updateMealMacros(
                  carbs: state.pendingCarbs,
                  fiber: state.pendingFiber,
                  proteins: double.tryParse(val),
                  fats: state.pendingFats,
                ),
                isAIRequired: true,
              ),
              _MacroInputRow(
                label: 'Fats (g)',
                value: state.pendingFats,
                onChanged: (val) => viewModel.updateMealMacros(
                  carbs: state.pendingCarbs,
                  fiber: state.pendingFiber,
                  proteins: state.pendingProteins,
                  fats: double.tryParse(val),
                ),
                isAIRequired: true,
              ),

              const SizedBox(height: AppThemeTokens.spaceXl),

              // ── Advanced Trackers ──
              ExpansionTile(
                title: Text('Advanced Prediction Trackers',
                    style: theme.textTheme.titleMedium),
                subtitle: const Text('Required for deep AI calibration'),
                childrenPadding:
                    const EdgeInsets.only(bottom: AppThemeTokens.spaceMd),
                children: [
                  SwitchListTile(
                    title: const Text('Contains Alcohol'),
                    subtitle:
                        const Text('Inhibits gluconeogenesis (Hypo risk)'),
                    value: state.containsAlcohol,
                    onChanged: viewModel.toggleAlcohol,
                    activeThumbColor: AppThemeTokens.warning,
                  ),
                  SwitchListTile(
                    title: const Text('High Caffeine (>200mg)'),
                    subtitle:
                        const Text('Can temporarily spike glucose'),
                    value: state.containsCaffeine,
                    onChanged: viewModel.toggleCaffeine,
                    activeThumbColor: AppThemeTokens.brandAccent,
                  ),
                ],
              ),

              const SizedBox(height: AppThemeTokens.spaceXl),

              if (state.error != null)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppThemeTokens.spaceMd),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: AppThemeTokens.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              // ── Save + Project Button ──
              ElevatedButton(
                onPressed: canSave
                    ? () async {
                        final result =
                            await viewModel.saveMealWithProjection(
                          weightKg: _weightKg,
                        );
                        if (result != null && context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProjectionResultView(result: result),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeTokens.brandPrimary,
                  foregroundColor: AppThemeTokens.textPrimaryInverse,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppThemeTokens.spaceLg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppThemeTokens.radiusLg),
                  ),
                ),
                child: state.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save & Calculate Prediction',
                        style: TextStyle(
                          fontSize: 16,
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

class _MacroInputRow extends StatelessWidget {
  final String label;
  final double? value;
  final Function(String) onChanged;
  final bool isAIRequired;

  const _MacroInputRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isAIRequired,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemeTokens.spaceMd),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyLarge),
                if (isAIRequired)
                  Row(
                    children: [
                      Icon(Icons.bolt,
                          color: AppThemeTokens.brandAccent, size: 14),
                      Text(
                        ' AI Required',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppThemeTokens.brandAccent,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: value?.toString() ?? '',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: '0.0',
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
