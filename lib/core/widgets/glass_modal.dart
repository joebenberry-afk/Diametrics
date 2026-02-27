import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class GlassModal extends StatelessWidget {
  final Widget child;
  final String title;

  const GlassModal({super.key, required this.child, required this.title});

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => GlassModal(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppThemeTokens.glassBlur,
              sigmaY: AppThemeTokens.glassBlur,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.1,
                  ),
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: isDark
                                    ? AppThemeTokens.textPrimaryInverse
                                    : AppThemeTokens.textPrimary,
                              ),
                            ),
                          ),
                          Semantics(
                            label: 'Close modal',
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                              constraints: const BoxConstraints(
                                minWidth: AppThemeTokens.minTapTarget,
                                minHeight: AppThemeTokens.minTapTarget,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppThemeTokens.spaceMd),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
