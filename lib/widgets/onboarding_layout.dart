import 'package:flutter/material.dart';
import '../../theme.dart';
import 'glassy_card.dart';

/// OnboardingLayout - Reusable layout for the new onboarding flow screens.
/// Features a cyan top bar, gradient background, central GlassyCard,
/// and a cyan bottom navigation bar.
class OnboardingLayout extends StatelessWidget {
  final String topTitle;
  final String cardTitle;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String backLabel;
  final String continueLabel;

  const OnboardingLayout({
    super.key,
    this.topTitle = 'Diametrics',
    required this.cardTitle,
    required this.child,
    this.onBack,
    this.onContinue,
    this.backLabel = 'Go Back',
    this.continueLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeniorTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Cyan Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: SeniorTheme.primaryCyan,
              child: Text(
                topTitle,
                style: SeniorTheme.headingStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: SeniorTheme.surfaceBlack,
                ),
              ),
            ),

            // Central Content
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // A strong background burst gradient to match mockup UI
                  Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.purple.withValues(alpha: 0.3),
                          SeniorTheme.primaryCyan.withValues(alpha: 0.2),
                          Colors.yellow.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                      ),
                    ),
                  ),

                  // The Glassy Card Content
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: GlassyCard(
                        width: double.infinity,
                        // Make it slightly darker/more opaque grey to match mockup
                        color: const Color(0xFFB0B0B0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              cardTitle,
                              textAlign: TextAlign.center,
                              style: SeniorTheme.headingStyle.copyWith(
                                color: SeniorTheme.surfaceBlack,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    20, // slightly smaller heading inside card as per mockup
                              ),
                            ),
                            const SizedBox(height: 24),
                            child,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Cyan Navigation Bar (Unified Strip)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: SeniorTheme.primaryCyan,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onBack ?? () => Navigator.of(context).pop(),
                    child: Semantics(
                      label: 'Go Back Button',
                      button: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '←',
                            style: TextStyle(
                              fontSize: 18,
                              color: SeniorTheme.surfaceBlack,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            backLabel,
                            style: SeniorTheme.bodyStyle.copyWith(
                              color: SeniorTheme.surfaceBlack,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (onContinue != null)
                    GestureDetector(
                      onTap: onContinue,
                      child: Semantics(
                        label: 'Continue Button',
                        button: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              continueLabel,
                              style: SeniorTheme.bodyStyle.copyWith(
                                color: SeniorTheme.surfaceBlack,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '→',
                              style: TextStyle(
                                fontSize: 18,
                                color: SeniorTheme.surfaceBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      width: 100,
                    ), // empty space if no continue button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
