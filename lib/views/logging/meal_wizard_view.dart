import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Controllers for macro fields so they can be updated programmatically by AI
  final _carbsCtrl = TextEditingController();
  final _fiberCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      setState(() => _weightKg = profile.weightKg);
    }
  }

  // ── Camera Methods ──────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    AppLockConfig.ignoreNextResume = true;
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 768,
      maxHeight: 768,
      imageQuality: 80,
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

      final totalProtein =
          result.items.fold(0.0, (sum, item) => sum + item.proteinGrams);
      final totalFat =
          result.items.fold(0.0, (sum, item) => sum + item.fatGrams);

      // Update the viewmodel state (drives canSave logic)
      ref.read(loggingWizardProvider.notifier).updateMealMacros(
        carbs: result.totalCarbs,
        fiber: null,
        proteins: totalProtein,
        fats: totalFat,
      );

      // Update text controllers so the input fields visually reflect the AI values
      _carbsCtrl.text = result.totalCarbs.toStringAsFixed(1);
      _proteinCtrl.text = totalProtein.toStringAsFixed(1);
      _fatsCtrl.text = totalFat.toStringAsFixed(1);
      _fiberCtrl.clear();

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
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppThemeTokens.radiusLg),
        ),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppThemeTokens.bgSurfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppThemeTokens.radiusLg),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppThemeTokens.spaceSm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppThemeTokens.brandAccent.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppThemeTokens.radiusFull),
                  ),
                ),
                const SizedBox(height: AppThemeTokens.spaceSm),
                Text(
                  'Analyze Food',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: AppThemeTokens.spaceSm),
                ListTile(
                  leading: const Icon(LucideIcons.camera,
                      color: AppThemeTokens.brandAccent),
                  title: Text(
                    'Take Photo',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Point camera at your meal',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.image,
                      color: AppThemeTokens.brandAccent),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Select a food photo you already have',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
                      fontSize: 13,
                    ),
                  ),
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
      },
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
                    '${state.preMealGlucose!.toStringAsFixed(0)} mg/dL',
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
                  GestureDetector(
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
                        fontSize: 13,
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
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d*')),
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
                      suffixText: 'mg/dL',
                      suffixStyle: TextStyle(
                        color: isDark ? Colors.white60 : AppThemeTokens.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        viewModel.setPreMealGlucose(parsed);
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

  // ── Camera / AI Area ────────────────────────────────────────────────

  Widget _buildCameraArea(ThemeData theme, bool isDark) {
    final borderColor = isDark
        ? AppThemeTokens.brandAccent.withValues(alpha: 0.5)
        : AppThemeTokens.brandPrimary.withValues(alpha: 0.3);
    final bgColor = isDark
        ? AppThemeTokens.brandSecondary.withValues(alpha: 0.15)
        : AppThemeTokens.brandPrimary.withValues(alpha: 0.05);

    final base = BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
      border: Border.all(color: borderColor, width: 2),
    );

    // Analyzing
    if (_isAnalyzing) {
      return Container(
        height: 130,
        decoration: base,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppThemeTokens.brandAccent,
              ),
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Text(
              'Analyzing with Gemini AI…',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark ? Colors.white70 : AppThemeTokens.brandSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Identifying foods and estimating nutrition',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white38 : AppThemeTokens.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Error
    if (_analysisError != null) {
      return GestureDetector(
        onTap: _showSourceSheet,
        child: Container(
          padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
          decoration: base.copyWith(
            border: Border.all(
              color: AppThemeTokens.error.withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.alertCircle,
                  color: AppThemeTokens.error, size: 22),
              const SizedBox(width: AppThemeTokens.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis failed',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppThemeTokens.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _analysisError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _showSourceSheet,
                icon: const Icon(LucideIcons.refreshCw, size: 14),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: AppThemeTokens.brandAccent,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // AI result shown
    if (_analysisResult != null && _imageFile != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Result header with image thumbnail
          Container(
            padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
            decoration: base.copyWith(
              border: Border.all(
                color: AppThemeTokens.brandSuccessLight.withValues(alpha: 0.6),
                width: 2,
              ),
              color: isDark
                  ? AppThemeTokens.brandSuccess.withValues(alpha: 0.12)
                  : AppThemeTokens.brandSuccess.withValues(alpha: 0.05),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppThemeTokens.radiusMd),
                  child: Image.file(_imageFile!,
                      width: 72, height: 72, fit: BoxFit.cover),
                ),
                const SizedBox(width: AppThemeTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.checkCircle,
                              color: AppThemeTokens.brandSuccessLight, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'AI Analysis Complete',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppThemeTokens.brandSuccessLight,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _analysisResult!.summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : AppThemeTokens.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Values filled in below — review and adjust if needed',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : AppThemeTokens.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _showSourceSheet,
                  style: TextButton.styleFrom(
                    foregroundColor: AppThemeTokens.brandAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.refreshCw, size: 14),
                      SizedBox(height: 2),
                      Text('Redo', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Food item list
          if (_analysisResult!.items.isNotEmpty) ...[
            const SizedBox(height: AppThemeTokens.spaceSm),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(AppThemeTokens.radiusMd),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppThemeTokens.brandPrimary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: _analysisResult!.items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppThemeTokens.spaceMd,
                          vertical: AppThemeTokens.spaceSm,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppThemeTokens.brandAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppThemeTokens.spaceSm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppThemeTokens.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.portion,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? Colors.white54
                                          : AppThemeTokens.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.carbsGrams.toStringAsFixed(1)}g C',
                                  style: TextStyle(
                                    color: AppThemeTokens.brandAccent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${item.proteinGrams.toStringAsFixed(1)}g P  '
                                  '${item.fatGrams.toStringAsFixed(1)}g F',
                                  style: TextStyle(
                                    color: isDark ? Colors.white38 : AppThemeTokens.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (i < _analysisResult!.items.length - 1)
                        Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.grey.shade200,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      );
    }

    // Default: tap to analyze
    return GestureDetector(
      onTap: _showSourceSheet,
      child: Container(
        height: 130,
        decoration: base,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
              decoration: BoxDecoration(
                color: AppThemeTokens.brandAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.camera,
                  size: 32, color: AppThemeTokens.brandAccent),
            ),
            const SizedBox(height: AppThemeTokens.spaceSm),
            Text(
              'Tap to analyze food with AI',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark ? Colors.white : AppThemeTokens.brandSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Camera or gallery — Gemini identifies nutrients',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white38 : AppThemeTokens.textSecondary,
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
              _buildCameraArea(theme, isDark),
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
                      'Alcohol and caffeine affect glucose absorption',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
                        fontSize: 12,
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
                            fontSize: 12,
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
                            fontSize: 12,
                          ),
                        ),
                        value: state.containsCaffeine,
                        onChanged: viewModel.toggleCaffeine,
                        activeThumbColor: AppThemeTokens.brandAccent,
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
                      fontSize: 12,
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
                  fontSize: 12,
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
                      fontSize: 11,
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
                  fontSize: 12,
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
