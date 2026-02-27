import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class AccountCard extends StatelessWidget {
  final String userName;
  final String userStatus;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.userName,
    required this.userStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'User Account Card for $userName',
      hint: 'Tap to view profile settings',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
          decoration: BoxDecoration(
            color: isDark ? AppThemeTokens.bgSurfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
            border: Border.all(
              color: isDark
                  ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
                  : const Color(0xFFD1D5DB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppThemeTokens.brandSecondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppThemeTokens.brandSecondary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 32,
                    color: isDark
                        ? AppThemeTokens.brandAccent
                        : AppThemeTokens.brandPrimary,
                    semanticLabel: 'Profile Icon',
                  ),
                ),
              ),
              const SizedBox(width: AppThemeTokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userStatus,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppThemeTokens.brandSuccess,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppThemeTokens.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
