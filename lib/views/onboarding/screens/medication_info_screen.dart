import 'package:diametrics/viewmodels/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicationInfoScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const MedicationInfoScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<MedicationInfoScreen> createState() =>
      _MedicationInfoScreenState();
}

class _MedicationInfoScreenState extends ConsumerState<MedicationInfoScreen> {
  bool _usesInsulin = false;
  bool _usesPills = false;
  bool _usesCgm = false;

  void _submit() {
    ref
        .read(onboardingViewModelProvider.notifier)
        .updateMedicationFlags(
          usesInsulin: _usesInsulin,
          usesPills: _usesPills,
          usesCgm: _usesCgm,
        );
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCheckboxTile(
            title: "Insulin",
            subtitle: "I take insulin injections or use a pump",
            value: _usesInsulin,
            onChanged: (val) => setState(() => _usesInsulin = val ?? false),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          _buildCheckboxTile(
            title: "Pills / Oral Medication",
            subtitle: "I take Metformin or other oral meds",
            value: _usesPills,
            onChanged: (val) => setState(() => _usesPills = val ?? false),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          _buildCheckboxTile(
            title: "CGM User",
            subtitle: "I use a Continuous Glucose Monitor",
            value: _usesCgm,
            onChanged: (val) => setState(() => _usesCgm = val ?? false),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Continue',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? colorScheme.primary : colorScheme.outline,
          width: 2,
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: value
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: value
                ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                : colorScheme.onSurfaceVariant,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
        checkColor: colorScheme.onPrimary,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
