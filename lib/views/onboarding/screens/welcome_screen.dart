import 'package:diametrics/viewmodels/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WelcomeScreen extends ConsumerWidget {
  final VoidCallback onNext;

  const WelcomeScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state to see if disclaimer is agreed
    final onboardingState = ref.watch(onboardingViewModelProvider);
    final hasAgreed = onboardingState.hasAgreedToDisclaimer;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(LucideIcons.activity, size: 64, color: colorScheme.primary),
          SizedBox(height: 32.0),
          Text(
            'Welcome to\nDiaMetrics',
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          Text(
            'Your quiet companion for managing diabetes with clarity and confidence.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // Medical Disclaimer Area (Mandatory for PoC Safety)
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  color: Colors.orange, // Warning color
                  size: 24,
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    'Important: DiaMetrics is a logging and tracking tool. It does not replace professional medical advice, diagnosis, or treatment.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.0),

          // Custom Checkbox mapping to State
          InkWell(
            onTap: () {
              ref
                  .read(onboardingViewModelProvider.notifier)
                  .agreeToDisclaimer();
            },
            borderRadius: BorderRadius.circular(8),
            child: Semantics(
              checked: hasAgreed,
              label: 'I acknowledge the medical disclaimer',
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: hasAgreed
                            ? colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: hasAgreed
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: hasAgreed
                          ? Icon(
                              LucideIcons.check,
                              size: 18,
                              color: colorScheme.onPrimary,
                            )
                          : null,
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        'I acknowledge and agree',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 32.0),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: hasAgreed ? onNext : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 16.0),
                Icon(LucideIcons.arrowRight, size: 24),
              ],
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
