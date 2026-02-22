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
                  // Optional: A background burst using a container with a decoration
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.yellow.withValues(alpha: 0.2),
                          SeniorTheme.primaryCyan.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
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

            // Bottom Cyan Navigation Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: SeniorTheme.primaryCyan,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: SeniorTheme.surfaceBlack,
                      size: 20,
                    ),
                    label: Text(
                      backLabel,
                      style: SeniorTheme.bodyStyle.copyWith(
                        color: SeniorTheme.surfaceBlack,
                      ),
                    ),
                  ),
                  if (onContinue != null)
                    TextButton.icon(
                      onPressed: onContinue,
                      icon: Text(
                        continueLabel,
                        style: SeniorTheme.bodyStyle.copyWith(
                          color: SeniorTheme.surfaceBlack,
                        ),
                      ),
                      label: Icon(
                        Icons.arrow_forward,
                        color: SeniorTheme.surfaceBlack,
                        size: 20,
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
