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
  String _insulinCategory = 'standard_rapid';

  void _submit() {
    double dia = 240.0;
    switch (_insulinCategory) {
      case 'ultra_fast':
        dia = 180.0;
        break;
      case 'regular':
        dia = 360.0;
        break;
      case 'basal_only':
      case 'none':
        dia = 0.0;
        break;
      default:
        dia = 240.0; // standard_rapid
    }

    ref
        .read(onboardingViewModelProvider.notifier)
        .updateMedicationFlags(
          usesInsulin: _usesInsulin,
          usesPills: _usesPills,
          usesCgm: _usesCgm,
          insulinCategory: _usesInsulin ? _insulinCategory : 'none',
          insulinDiaMinutes: _usesInsulin ? dia : 0.0,
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
          if (_usesInsulin) ...[
            const SizedBox(height: 12),
            _buildInsulinDropdown(colorScheme, textTheme),
          ],
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

  Widget _buildInsulinDropdown(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Mealtime Insulin Type',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _insulinCategory,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                dropdownColor: colorScheme.surfaceContainer,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _insulinCategory = newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: 'ultra_fast',
                    child: Text('Ultra-Rapid (Fiasp, Lyumjev)'),
                  ),
                  DropdownMenuItem(
                    value: 'standard_rapid',
                    child: Text('Standard Rapid (Humalog, Novolog)'),
                  ),
                  DropdownMenuItem(
                    value: 'regular',
                    child: Text('Regular (Humulin R, Novolin R)'),
                  ),
                  DropdownMenuItem(
                    value: 'basal_only',
                    child: Text('Basal / Long-Acting Only'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
