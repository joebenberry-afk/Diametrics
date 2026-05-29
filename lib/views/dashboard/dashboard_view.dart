import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_tokens.dart';
import '../../router/route_names.dart';
import '../../core/widgets/account_card.dart';
import '../../core/widgets/metric_card.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../services/emergency_service.dart';
import '../../viewmodels/health_data_viewmodel.dart';
import '../../viewmodels/activity_viewmodel.dart';
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
    final preferredUnit = profile?.preferredGlucoseUnit ?? 'mg/dL';
    // Convert stored mg/dL targets to preferred unit for display
    final targetDisplayFactor = preferredUnit == 'mmol/L' ? 1 / 18.0182 : 1.0;
    final targetDecimalPlaces = preferredUnit == 'mmol/L' ? 1 : 0;
    final statusText = profile != null && diabetesType.isNotEmpty
        ? '$diabetesType • Target ${(profile.targetGlucoseMin * targetDisplayFactor).toStringAsFixed(targetDecimalPlaces)}–${(profile.targetGlucoseMax * targetDisplayFactor).toStringAsFixed(targetDecimalPlaces)} $preferredUnit'
        : '—';

    // Get latest glucose
    final latestGlucose = ref.watch(latestGlucoseProvider);
    final latestLog = latestGlucose.valueOrNull;
    final glucoseValue = latestLog?.value;
    final glucoseLogUnit = latestLog?.unit ?? preferredUnit;
    // Use 1 decimal for mmol/L, 0 for mg/dL
    final glucoseDisplay = glucoseValue != null
        ? glucoseValue.toStringAsFixed(glucoseLogUnit == 'mmol/L' ? 1 : 0)
        : '--';

    // Get last 6 readings for trendData
    final allGlucoseAsync = ref.watch(glucoseLogsProvider);
    final allGlucose = allGlucoseAsync.valueOrNull ?? [];
    final sortedGlucose = List<GlucoseLog>.from(allGlucose)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    // Take newest 6 readings (end of ascending sort) for the sparkline
    final recentGlucose = sortedGlucose.length > 6
        ? sortedGlucose.sublist(sortedGlucose.length - 6)
        : sortedGlucose;
    final trendData = recentGlucose.map((g) {
      // Normalise each reading to the user's preferred unit for the sparkline.
      if (g.unit == preferredUnit) return g.value;
      return preferredUnit == 'mmol/L' ? g.value / 18.0182 : g.value * 18.0182;
    }).toList();

    // Normalise the latest reading to mg/dL for comparison against
    // targets (which are always stored in mg/dL).
    final glucoseMgdl = glucoseValue != null
        ? (glucoseLogUnit == 'mmol/L' ? glucoseValue * 18.0182 : glucoseValue)
        : null;
    // Color: red if out of range, green if in range, primary if no data
    Color glucoseColor = AppThemeTokens.brandPrimary;
    if (glucoseMgdl != null && profile != null) {
      if (glucoseMgdl < profile.targetGlucoseMin ||
          glucoseMgdl > profile.targetGlucoseMax) {
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

    final stepsAsync = ref.watch(stepCountProvider);
    final stepsDisplay = stepsAsync.when(
      data: (steps) => steps.toString(),
      loading: () => '…',
      error: (e, s) => '--',
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(glucoseLogsProvider);
            ref.invalidate(mealLogsProvider);
            ref.invalidate(medicationLogsProvider);
            // Allow the providers to rebuild before dismissing the spinner.
            await Future.delayed(const Duration(milliseconds: 300));
          },
          color: AppThemeTokens.brandPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header / Account Area ──────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AccountCard(
                        userName: displayName,
                        userStatus: statusText,
                        onTap: () {
                          // Switch to Profile tab in the shell.
                          context.go(Routes.profile);
                        },
                      ),
                    ),
                    const SizedBox(width: AppThemeTokens.spaceSm),
                    const _SOSButton(),
                  ],
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
                      icon: LucideIcons.activity,
                      accentColor: glucoseColor,
                      trendData: trendData,
                      onTap: () {
                        // Switch to Trends tab.
                        context.go(Routes.trends);
                      },
                    ),
                    MetricCard(
                      title: 'Meals',
                      value: caloriesDisplay,
                      unit: 'kcal',
                      icon: LucideIcons.utensils,
                      accentColor: AppThemeTokens.brandSuccess,
                      trendData: const [],
                      onTap: () {
                        context.push(Routes.mealHistory);
                      },
                    ),
                    MetricCard(
                      title: 'Medication',
                      value: dosesDisplay,
                      unit: 'Doses',
                      icon: LucideIcons.pill,
                      accentColor: AppThemeTokens.brandAccent,
                      onTap: () {
                        context.push(Routes.medicationHistory);
                      },
                    ),
                    MetricCard(
                      title: 'Activity',
                      value: stepsDisplay,
                      unit: 'Steps',
                      icon: LucideIcons.footprints,
                      accentColor: AppThemeTokens.brandSecondary,
                      trendData: const [],
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Today: $stepsDisplay steps tracked via pedometer.',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
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
                    borderRadius: BorderRadius.circular(
                      AppThemeTokens.radiusLg,
                    ),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : AppThemeTokens.textPrimary,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${_timeAgo(entry['timestamp'] as DateTime)} • ${entry['subtitle']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white60
                                            : AppThemeTokens.textSecondary,
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
      ),
      // Quick-log entry point lives in the bottom-nav "Log" tab now —
      // FAB removed to keep the dashboard focused on at-a-glance status.
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
            error: (_, _) => const Text('Could not load summary'),
            data: (s) {
              // Convert avg glucose from mg/dL to preferred unit for display
              final summaryProfile = ref.watch(userProfileProvider).valueOrNull;
              final summaryUnit =
                  summaryProfile?.preferredGlucoseUnit ?? 'mg/dL';
              final avgDisplayFactor = summaryUnit == 'mmol/L'
                  ? 1 / 18.0182
                  : 1.0;
              final avgDecimalPlaces = summaryUnit == 'mmol/L' ? 1 : 0;
              final avgDisplay = s.avgGlucose > 0
                  ? (s.avgGlucose * avgDisplayFactor).toStringAsFixed(
                      avgDecimalPlaces,
                    )
                  : '--';

              return s.glucoseReadings == 0 &&
                      s.mealsLogged == 0 &&
                      s.dosesLogged == 0
                  ? const Text(
                      'No data logged today yet.',
                      style: TextStyle(color: AppThemeTokens.textSecondary),
                    )
                  : Column(
                      children: [
                        // Time-in-range donut chart
                        if (s.glucoseReadings > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Time in Range',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppThemeTokens.textSecondary,
                                ),
                              ),
                              Text(
                                '${s.timeInRangePct.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: s.timeInRangePct >= 70
                                      ? AppThemeTokens.brandSuccess
                                      : s.timeInRangePct >= 50
                                      ? AppThemeTokens.warningText
                                      : AppThemeTokens.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppThemeTokens.spaceSm),
                          SizedBox(
                            height: 160,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 45,
                                sections: [
                                  if (s.timeInRangePct > 0)
                                    PieChartSectionData(
                                      value: s.timeInRangePct,
                                      color: AppThemeTokens.brandSuccess,
                                      title: '${s.timeInRangePct.toStringAsFixed(0)}%',
                                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                      radius: 28,
                                    ),
                                  if (s.belowRangePct > 0)
                                    PieChartSectionData(
                                      value: s.belowRangePct,
                                      color: AppThemeTokens.warning,
                                      title: '${s.belowRangePct.toStringAsFixed(0)}%',
                                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                      radius: 28,
                                    ),
                                  if (s.aboveRangePct > 0)
                                    PieChartSectionData(
                                      value: s.aboveRangePct,
                                      color: AppThemeTokens.error,
                                      title: '${s.aboveRangePct.toStringAsFixed(0)}%',
                                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                      radius: 28,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppThemeTokens.spaceSm),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LegendDot(color: AppThemeTokens.brandSuccess, label: 'In Range'),
                              SizedBox(width: 16),
                              _LegendDot(color: AppThemeTokens.warning, label: 'Low'),
                              SizedBox(width: 16),
                              _LegendDot(color: AppThemeTokens.error, label: 'High'),
                            ],
                          ),
                          const SizedBox(height: AppThemeTokens.spaceMd),
                        ],
                        // Stats row
                        Row(
                          children: [
                            _SummaryStatTile(
                              label: 'Avg Glucose',
                              value: avgDisplay,
                              unit: summaryUnit,
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
                    );
            },
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppThemeTokens.textPrimary,
            ),
          ),
          Text(
            unit,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
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
        'Low glucose detected: ${glucoseValue.toStringAsFixed(unit == 'mmol/L' ? 1 : 0)} $unit. Consider fast-acting carbohydrates.',
      ),
      GlucoseAlertLevel.hyperElevated => (
        const Color(0xFFFFE4E4),
        AppThemeTokens.error,
        Icons.arrow_upward_rounded,
        'Glucose above target: ${glucoseValue.toStringAsFixed(unit == 'mmol/L' ? 1 : 0)} $unit. Monitor closely.',
      ),
      GlucoseAlertLevel.hyperHigh => (
        AppThemeTokens.error,
        Colors.white,
        Icons.priority_high_rounded,
        'High glucose: ${glucoseValue.toStringAsFixed(unit == 'mmol/L' ? 1 : 0)} $unit. Contact your care team if persistent.',
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
                  fontSize: 14,
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

class _SOSButton extends StatefulWidget {
  const _SOSButton();

  @override
  State<_SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<_SOSButton> {
  bool _isCalling = false;

  void _handleEmergency() async {
    // Fetch contact name for the confirmation dialog
    final contact = await EmergencyService.getContact();

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Call Emergency Contact?'),
        content: Text(
          contact != null
              ? 'This will call ${contact.name}. Continue?'
              : 'No emergency contact configured. Configure one first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          if (contact != null)
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppThemeTokens.error,
              ),
              child: const Text('Call Now'),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
                context.push(Routes.emergencyContacts);
              },
              child: const Text('Configure'),
            ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCalling = true);

    final bool success = await EmergencyService.callEmergencyContact();

    if (!mounted) return;
    setState(() => _isCalling = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No emergency contact configured, or unable to dial.',
          ),
          backgroundColor: AppThemeTokens.error,
          action: SnackBarAction(
            label: 'Configure',
            textColor: Colors.white,
            onPressed: () {
              context.push(Routes.emergencyContacts);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Emergency SOS Call',
      button: true,
      child: Material(
        color: AppThemeTokens.error,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _isCalling ? null : _handleEmergency,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Container(
            height: 72, // Matches typical AccountCard height roughly
            width: 72,
            alignment: Alignment.center,
            child: _isCalling
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppThemeTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}
