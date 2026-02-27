import 'package:diametrics/viewmodels/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TargetsScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const TargetsScreen({
    super.key,
    required this.onBack,
    required this.onComplete,
  });

  @override
  ConsumerState<TargetsScreen> createState() => _TargetsScreenState();
}

class _TargetsScreenState extends ConsumerState<TargetsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _minTargetController = TextEditingController(text: '70');
  final _maxTargetController = TextEditingController(text: '180');

  @override
  void dispose() {
    _minTargetController.dispose();
    _maxTargetController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final minVal = double.parse(_minTargetController.text);
      final maxVal = double.parse(_maxTargetController.text);

      if (minVal >= maxVal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Minimum target must be less than maximum target.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      await ref
          .read(onboardingViewModelProvider.notifier)
          .updateTargetsAndFinish(minTarget: minVal, maxTarget: maxVal);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the unit from state if available, otherwise display a placeholder.
    final state = ref.watch(onboardingViewModelProvider);
    final unitString = state.preferredGlucoseUnit;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Safe Glucose Targets',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Set your ideal range. Readings outside this range will be flagged.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 32.0),

            // Target High
            TextFormField(
              controller: _maxTargetController,
              decoration: InputDecoration(
                labelText: 'High Target ($unitString)',
                hintText: 'e.g., 180',
                border: const OutlineInputBorder(),
                helperText: 'Typical safe maximum (varies by doctor)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter high target';
                }
                final h = double.tryParse(value);
                if (h == null || h <= 0) {
                  return 'Valid target required';
                }
                return null;
              },
            ),
            SizedBox(height: 32.0),

            // Target Low
            TextFormField(
              controller: _minTargetController,
              decoration: InputDecoration(
                labelText: 'Low Target ($unitString)',
                hintText: 'e.g., 70',
                border: const OutlineInputBorder(),
                helperText: 'Typical safe minimum (varies by doctor)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter low target';
                }
                final l = double.tryParse(value);
                if (l == null || l <= 0) {
                  return 'Valid target required';
                }
                return null;
              },
            ),

            SizedBox(height: 48.0),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                'Complete Setup',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: widget.onBack,
              child: Text(
                'Back',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
            SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}
