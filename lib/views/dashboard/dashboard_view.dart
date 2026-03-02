import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/account_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../logging/glucose_wizard_view.dart';
import '../logging/meal_wizard_view.dart';
import '../logging/medication_wizard_view.dart';
import '../settings/settings_view.dart';
import '../history/glucose_trend_view.dart';
import '../history/meal_history_view.dart';
import '../history/medication_history_view.dart';
import '../../viewmodels/health_data_viewmodel.dart';
import '../../models/glucose_log.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final profileAsync = ref.watch(userProfileProvider);

    // Derive display values from the loaded profile (or use safe defaults)
    final profile = profileAsync.valueOrNull;
    final displayName = (profile?.name.trim().isNotEmpty == true)
        ? profile!.name.trim()
        : (profile != null)
        ? '${profile.age}y ${profile.gender}'
        : 'Patient';

    final diabetesType = profile?.diabetesType ?? '';
    final statusText = profile != null && diabetesType.isNotEmpty
        ? '$diabetesType • Target ${profile.targetGlucoseMin.toStringAsFixed(0)}–${profile.targetGlucoseMax.toStringAsFixed(0)} ${profile.preferredGlucoseUnit}'
        : 'Loading profile…';

    // Get latest glucose
    final latestGlucose = ref.watch(latestGlucoseProvider);
    final glucoseValue = latestGlucose.valueOrNull?.value;
    final glucoseDisplay = glucoseValue != null
        ? glucoseValue.toStringAsFixed(0)
        : '--';

    // Get last 6 readings for trendData
    final allGlucoseAsync = ref.watch(glucoseLogsProvider);
    final allGlucose = allGlucoseAsync.valueOrNull ?? [];
    final sortedGlucose = List<GlucoseLog>.from(allGlucose)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final trendData = sortedGlucose.take(6).map((g) => g.value).toList();

    // Color: red if out of range, green if in range, primary if no data
    Color glucoseColor = AppThemeTokens.brandPrimary;
    if (glucoseValue != null && profile != null) {
      if (glucoseValue < profile.targetGlucoseMin ||
          glucoseValue > profile.targetGlucoseMax) {
        glucoseColor = AppThemeTokens.error;
      } else {
        glucoseColor = AppThemeTokens.brandSuccess;
      }
    }

    // Calories logic
    final calories = ref.watch(todayCaloriesProvider).valueOrNull ?? 0.0;
    final caloriesDisplay = calories > 0 ? calories.toStringAsFixed(0) : '0';

    // Medication logic
    final doseCount = ref.watch(todayDoseCountProvider).valueOrNull ?? 0;
    final dosesDisplay = doseCount.toString();

    final activityAsync = ref.watch(recentActivityProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header / Account Area ──────────────────────────────────
              AccountCard(
                userName: displayName,
                userStatus: statusText,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsView()),
                  );
                },
              ),
              const SizedBox(height: AppThemeTokens.spaceSm),

              // ── Alert Banner ───────────────────────────────────────────
              Builder(
                builder: (context) {
                  final alertLevel = ref.watch(glucoseAlertProvider);
                  final latestGlucose = ref
                      .watch(latestGlucoseProvider)
                      .valueOrNull;
                  if (alertLevel == GlucoseAlertLevel.none ||
                      latestGlucose == null) {
                    return const SizedBox.shrink();
                  }
                  return _AlertBanner(
                    level: alertLevel,
                    glucoseValue: latestGlucose.value,
                    unit: latestGlucose.unit,
                  );
                },
              ),

              const SizedBox(height: AppThemeTokens.spaceMd),

              // ── Title Section ──────────────────────────────────────────
              Text('Health Overview', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppThemeTokens.spaceSm),
              Text(
                'Your vitals and activity for today',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppThemeTokens.spaceLg),

              // ── Metrics Grid ───────────────────────────────────────────
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppThemeTokens.spaceMd,
                mainAxisSpacing: AppThemeTokens.spaceMd,
                childAspectRatio: 0.9,
                children: [
                  MetricCard(
                    title: 'Glucose',
                    value: glucoseDisplay,
                    unit: profile?.preferredGlucoseUnit ?? 'mg/dL',
                    icon: Icons.bloodtype_outlined,
                    accentColor: glucoseColor,
                    trendData: trendData,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GlucoseTrendView(),
                        ),
                      );
                    },
                  ),
                  MetricCard(
                    title: 'Meals',
                    value: caloriesDisplay,
                    unit: 'kcal',
                    icon: Icons.restaurant_outlined,
                    accentColor: AppThemeTokens.brandSuccess,
                    trendData: const [],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MealHistoryView(),
                        ),
                      );
                    },
                  ),
                  MetricCard(
                    title: 'Medication',
                    value: dosesDisplay,
                    unit: 'Doses',
                    icon: Icons.medication_outlined,
                    accentColor: AppThemeTokens.brandAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MedicationHistoryView(),
                        ),
                      );
                    },
                  ),
                  MetricCard(
                    title: 'Activity',
                    value: '6,420',
                    unit: 'Steps',
                    icon: Icons.directions_walk,
                    accentColor: AppThemeTokens.brandSecondary,
                    trendData: const [2000, 4000, 3500, 6420],
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: AppThemeTokens.spaceLg),
              const _DailySummaryCard(),
              const SizedBox(height: AppThemeTokens.spaceLg),

              // ── Recent Activity Section ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeTokens.bgSurfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                  border: Border.all(
                    color: isDark
                        ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: AppThemeTokens.spaceMd),
                    activityAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          const Center(child: Text('Error loading activity')),
                      data: (entries) {
                        if (entries.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppThemeTokens.spaceLg,
                            ),
                            child: Center(
                              child: Text(
                                'No activity yet. Start logging!',
                                style: TextStyle(
                                  color: AppThemeTokens.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: entries.map((entry) {
                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: (entry['color'] as Color)
                                        .withValues(alpha: 0.1),
                                    child: Icon(
                                      entry['icon'] as IconData,
                                      size: 20,
                                      color: entry['color'] as Color,
                                    ),
                                  ),
                                  title: Text(
                                    entry['label'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${_timeAgo(entry['timestamp'] as DateTime)} • ${entry['subtitle']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppThemeTokens.textSecondary,
                                    ),
                                  ),
                                ),
                                if (entry != entries.last) const Divider(),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Quick Log FAB ──────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickLogSheet(context),
        label: const Text('Add Entry'),
        icon: const Icon(Icons.add),
        backgroundColor: AppThemeTokens.brandPrimary,
        foregroundColor: AppThemeTokens.textPrimaryInverse,
      ),
    );
  }

  void _showQuickLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _QuickLogSheet(),
    );
  }
}

// ── Quick Log Bottom Sheet ─────────────────────────────────────────────────────

class _QuickLogSheet extends StatelessWidget {
  const _QuickLogSheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeTokens.bgSurfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppThemeTokens.radiusLg),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppThemeTokens.spaceLg,
        AppThemeTokens.spaceMd,
        AppThemeTokens.spaceLg,
        AppThemeTokens.spaceXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppThemeTokens.brandAccent.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          Text(
            'Quick Log',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppThemeTokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppThemeTokens.spaceLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickLogButton(
                icon: Icons.bloodtype,
                label: 'Glucose',
                color: AppThemeTokens.brandPrimary,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GlucoseWizardView(),
                    ),
                  );
                },
              ),
              _QuickLogButton(
                icon: Icons.restaurant,
                label: 'Meal',
                color: AppThemeTokens.brandSuccess,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MealWizardView()),
                  );
                },
              ),
              _QuickLogButton(
                icon: Icons.medication,
                label: 'Medication',
                color: AppThemeTokens.brandAccent,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MedicationWizardView(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Log Button ───────────────────────────────────────────────────────────

class _QuickLogButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLogButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Log $label',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

class _DailySummaryCard extends ConsumerWidget {
  const _DailySummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
      decoration: BoxDecoration(
        color: isDark ? AppThemeTokens.bgSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color: isDark
              ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
              : const Color(0xFFD1D5DB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.today_outlined,
                size: 18,
                color: AppThemeTokens.brandPrimary,
              ),
              const SizedBox(width: AppThemeTokens.spaceSm),
              Text(
                "Today's Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceMd),
          summaryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Could not load summary'),
            data: (s) =>
                s.glucoseReadings == 0 &&
                    s.mealsLogged == 0 &&
                    s.dosesLogged == 0
                ? const Text(
                    'No data logged today yet.',
                    style: TextStyle(color: AppThemeTokens.textSecondary),
                  )
                : Column(
                    children: [
                      // Time-in-range progress bar
                      if (s.glucoseReadings > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Time in Range',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppThemeTokens.textSecondary,
                              ),
                            ),
                            Text(
                              '${s.timeInRangePct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: s.timeInRangePct >= 70
                                    ? AppThemeTokens.brandSuccess
                                    : s.timeInRangePct >= 50
                                    ? AppThemeTokens.warning
                                    : AppThemeTokens.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (s.timeInRangePct / 100).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppThemeTokens.error.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              s.timeInRangePct >= 70
                                  ? AppThemeTokens.brandSuccess
                                  : s.timeInRangePct >= 50
                                  ? AppThemeTokens.warning
                                  : AppThemeTokens.error,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppThemeTokens.spaceMd),
                      ],
                      // Stats row
                      Row(
                        children: [
                          _SummaryStatTile(
                            label: 'Avg Glucose',
                            value: s.avgGlucose > 0
                                ? s.avgGlucose.toStringAsFixed(0)
                                : '--',
                            unit: 'mg/dL',
                          ),
                          _SummaryStatTile(
                            label: 'Carbs',
                            value: s.totalCarbs.toStringAsFixed(0),
                            unit: 'g',
                          ),
                          _SummaryStatTile(
                            label: 'Calories',
                            value: s.totalCalories > 0
                                ? s.totalCalories.toStringAsFixed(0)
                                : '--',
                            unit: 'kcal',
                          ),
                          _SummaryStatTile(
                            label: 'Readings',
                            value: '${s.glucoseReadings}',
                            unit: 'today',
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _SummaryStatTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppThemeTokens.textPrimary,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final GlucoseAlertLevel level;
  final double glucoseValue;
  final String unit;

  const _AlertBanner({
    required this.level,
    required this.glucoseValue,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    if (level == GlucoseAlertLevel.none) return const SizedBox.shrink();

    final (
      Color bg,
      Color text,
      IconData icon,
      String message,
    ) = switch (level) {
      GlucoseAlertLevel.hypo => (
        const Color(0xFFFFF3CD),
        const Color(0xFF856404),
        Icons.warning_amber_rounded,
        'Low glucose detected: ${glucoseValue.toStringAsFixed(0)} $unit. Consider fast-acting carbohydrates.',
      ),
      GlucoseAlertLevel.hyperElevated => (
        const Color(0xFFFFE4E4),
        AppThemeTokens.error,
        Icons.arrow_upward_rounded,
        'Glucose above target: ${glucoseValue.toStringAsFixed(0)} $unit. Monitor closely.',
      ),
      GlucoseAlertLevel.hyperHigh => (
        AppThemeTokens.error,
        Colors.white,
        Icons.priority_high_rounded,
        'High glucose: ${glucoseValue.toStringAsFixed(0)} $unit. Contact your care team if persistent.',
      ),
      _ => (Colors.transparent, Colors.transparent, Icons.info, ''),
    };

    return Semantics(
      liveRegion: true,
      label: 'Alert: $message',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppThemeTokens.spaceMd),
        padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          border: Border.all(color: text.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: text, size: 22),
            const SizedBox(width: AppThemeTokens.spaceSm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
