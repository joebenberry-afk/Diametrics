import 'package:diametrics/core/theme/app_tokens.dart';
import 'package:diametrics/viewmodels/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DemographicsScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DemographicsScreen({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends ConsumerState<DemographicsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _otherGenderController = TextEditingController();

  // Imperial unit controllers
  final _feetCtrl = TextEditingController();
  final _inchesCtrl = TextEditingController();

  bool _useImperial = false;
  String _selectedGender = '';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _otherGenderController.dispose();
    _feetCtrl.dispose();
    _inchesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a gender identity.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }
    if (_selectedGender == 'Other' && _otherGenderController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please describe your gender identity.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }
    if (_formKey.currentState!.validate()) {
      final finalGender = _selectedGender == 'Other'
          ? _otherGenderController.text.trim()
          : _selectedGender;

      double heightCm;
      double weightKg;

      if (_useImperial) {
        final feet = double.tryParse(_feetCtrl.text) ?? 0;
        final inches = double.tryParse(_inchesCtrl.text) ?? 0;
        heightCm = (feet * 12 + inches) * 2.54;
        weightKg = (double.tryParse(_weightController.text) ?? 0) / 2.20462;
      } else {
        heightCm = double.parse(_heightController.text);
        weightKg = double.parse(_weightController.text);
      }

      ref.read(onboardingViewModelProvider.notifier).updateDemographics(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text),
            gender: finalGender,
            heightCm: heightCm,
            weightKg: weightKg,
          );
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Let\'s get to know you.',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'This baseline helps DiaMetrics personalize your experience and calculations.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 32.0),

            // Full Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'e.g., Maria Santos',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            SizedBox(height: 32.0),

            // Age
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                hintText: 'e.g., 65',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your age';
                }
                final age = int.tryParse(value);
                if (age == null || age < 1 || age > 120) {
                  return 'Please enter a valid age';
                }
                return null;
              },
            ),
            SizedBox(height: 32.0),

            // Gender Identity (Buttons for easier tapping than dropdown)
            Text(
              'Gender Identity',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              semanticsLabel: 'Select your Gender Identity',
            ),
            SizedBox(height: 16.0),
            Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              children: [
                _buildGenderButton('Male', colorScheme, textTheme),
                _buildGenderButton('Female', colorScheme, textTheme),
                _buildGenderButton('Other', colorScheme, textTheme),
              ],
            ),
            if (_selectedGender == 'Other') ...[
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _otherGenderController,
                decoration: const InputDecoration(
                  labelText: 'Describe your gender identity',
                  hintText: 'e.g., Non-binary, Gender fluid…',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _selectedGender == 'Other' && (v == null || v.trim().isEmpty)
                    ? 'Please describe your gender identity'
                    : null,
              ),
            ],
            SizedBox(height: 32.0),

            // Unit toggle for height/weight
            Text(
              'Height & Weight Units',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.0),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Metric (cm / kg)'),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Imperial (ft·in / lbs)'),
                ),
              ],
              selected: {_useImperial},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _useImperial = newSelection.first;
                  // Clear fields when switching units to avoid confusion
                  _heightController.clear();
                  _weightController.clear();
                  _feetCtrl.clear();
                  _inchesCtrl.clear();
                });
              },
            ),
            SizedBox(height: 24.0),

            // Height fields
            if (_useImperial) ...[
              Text(
                'Height',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _feetCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ft',
                        hintText: 'e.g., 5',
                        border: OutlineInputBorder(),
                        suffixText: 'ft',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final ft = int.tryParse(value);
                        if (ft == null || ft < 1 || ft > 8) {
                          return '1–8 ft';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _inchesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'in',
                        hintText: 'e.g., 6.5',
                        border: OutlineInputBorder(),
                        suffixText: 'in',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final inches = double.tryParse(value);
                        if (inches == null || inches < 0 || inches >= 12) {
                          return '0–11.9 in';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height',
                  hintText: 'e.g., 170',
                  border: OutlineInputBorder(),
                  suffixText: 'cm',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  final h = double.tryParse(value);
                  if (h == null || h < 50 || h > 300) {
                    return 'Valid height in cm required';
                  }
                  return null;
                },
              ),
            ],
            SizedBox(height: 24.0),

            // Weight field
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight',
                hintText: _useImperial ? 'e.g., 185' : 'e.g., 85.5',
                border: const OutlineInputBorder(),
                suffixText: _useImperial ? 'lbs' : 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your weight';
                }
                final w = double.tryParse(value);
                if (_useImperial) {
                  if (w == null || w < 44 || w > 660) {
                    return 'Valid weight in lbs required';
                  }
                } else {
                  if (w == null || w < 20 || w > 300) {
                    return 'Valid weight in kg required';
                  }
                }
                return null;
              },
            ),

            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                'Continue',
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

  Widget _buildGenderButton(
    String gender,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedGender == gender;

    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: () => setState(() => _selectedGender = gender),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: 2,
            ),
          ),
          child: Text(
            gender,
            style: textTheme.bodyLarge?.copyWith(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
