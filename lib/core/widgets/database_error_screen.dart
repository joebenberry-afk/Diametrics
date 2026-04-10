import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class DatabaseErrorScreen extends StatelessWidget {
  final Object error;
  const DatabaseErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppThemeTokens.bgBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppThemeTokens.error),
                const SizedBox(height: AppThemeTokens.spaceLg),
                const Text(
                  'Unable to Open Database',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppThemeTokens.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppThemeTokens.spaceMd),
                const Text(
                  'DiaMetrics could not open its secure database. '
                  'Please restart the app. If the problem persists, '
                  'reinstalling the app may be required.',
                  style: TextStyle(color: AppThemeTokens.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
