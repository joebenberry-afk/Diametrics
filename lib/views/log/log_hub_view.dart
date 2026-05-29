import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_tokens.dart';
import '../../router/route_names.dart';

/// Landing screen for the Log tab in the bottom-nav shell.
///
/// Replaces the old FAB+ModalBottomSheet pattern with a dedicated screen
/// that follows the "one primary task" UX rule. Each entry is a large,
/// high-contrast button so the action is obvious for users with low vision
/// or motor-control challenges.
class LogHubView extends StatelessWidget {
  const LogHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What do you want to log?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose one — you can log another after.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? Colors.white70
                      : AppThemeTokens.textSecondary,
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceXl),
              _LogTile(
                icon: LucideIcons.activity,
                label: 'Blood Glucose',
                subtitle: 'Log a reading (CGM or fingerprick)',
                color: AppThemeTokens.brandPrimary,
                onTap: () => context.push(Routes.logGlucose),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _LogTile(
                icon: LucideIcons.utensils,
                label: 'Meal',
                subtitle: 'Scan or enter macronutrients',
                color: AppThemeTokens.brandSuccess,
                onTap: () => context.push(Routes.logMeal),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _LogTile(
                icon: LucideIcons.pill,
                label: 'Medication',
                subtitle: 'Record insulin or oral dose',
                color: AppThemeTokens.brandAccent,
                onTap: () => context.push(Routes.logMedication),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _LogTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Log $label',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppThemeTokens.radiusMd),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: AppThemeTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppThemeTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white70
                                : AppThemeTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    color: color,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
