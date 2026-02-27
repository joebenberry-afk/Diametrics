import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/welcome_screen.dart';
import 'screens/demographics_screen.dart';
import 'screens/diabetes_info_screen.dart';
import 'screens/medication_info_screen.dart';
import 'screens/targets_screen.dart';
import '../dashboard/dashboard_view.dart';

class OnboardingWrapper extends ConsumerStatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  ConsumerState<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends ConsumerState<OnboardingWrapper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: colorScheme.onSurface,
                ),
                onPressed: _previousPage,
                tooltip: 'Go back to previous step', // Accessibility hint
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Accessible Progress Indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Semantics(
                label:
                    'Onboarding progress, Step ${_currentPage + 1} of $_totalPages',
                child: Row(
                  children: List.generate(_totalPages, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8,
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 32.0),

            // Step Content via PageView for Progressive Disclosure
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Force using the big buttons
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  WelcomeScreen(onNext: _nextPage),
                  DemographicsScreen(onNext: _nextPage),
                  DiabetesInfoScreen(onNext: _nextPage, onBack: _previousPage),
                  MedicationInfoScreen(
                    onNext: _nextPage,
                    onBack: _previousPage,
                  ),
                  TargetsScreen(
                    onComplete: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const DashboardView(),
                        ),
                      );
                    },
                    onBack: _previousPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
