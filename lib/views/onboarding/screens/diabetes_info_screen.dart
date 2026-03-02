import 'package:diametrics/viewmodels/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiabetesInfoScreen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DiabetesInfoScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<DiabetesInfoScreen> createState() => _DiabetesInfoScreenState();
}

class _DiabetesInfoScreenState extends ConsumerState<DiabetesInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  final _otherTypeController = TextEditingController();

  String _selectedType = '';
  String _selectedUnit = 'mg/dL'; // Default to mg/dL

  @override
  void dispose() {
    _yearController.dispose();
    _otherTypeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select your diabetes type.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }
    if (_selectedType == 'Other/Not Sure' && _otherTypeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please describe your diabetes type.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      return;
    }
    if (_formKey.currentState!.validate()) {
      final finalType = _selectedType == 'Other/Not Sure'
          ? _otherTypeController.text.trim()
          : _selectedType;
      ref.read(onboardingViewModelProvider.notifier).updateDiabetesContext(
            diabetesType: finalType,
            diagnosisYear: int.parse(_yearController.text),
            unit: _selectedUnit,
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
              'Your Diabetes Profile',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Knowing your specific context helps tailor insights and alerts safely.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 32.0),

            // Diabetes Type
            Text(
              'Diabetes Type',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              semanticsLabel: 'Select your Diabetes Type',
            ),
            SizedBox(height: 16.0),
            Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              children: [
                _buildTypeButton('Type 1', colorScheme, textTheme),
                _buildTypeButton('Type 2', colorScheme, textTheme),
                _buildTypeButton('Gestational', colorScheme, textTheme),
                _buildTypeButton('LADA', colorScheme, textTheme),
                _buildTypeButton('Other/Not Sure', colorScheme, textTheme),
              ],
            ),
            if (_selectedType == 'Other/Not Sure') ...[
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _otherTypeController,
                decoration: const InputDecoration(
                  labelText: 'Describe your diabetes type',
                  hintText: 'e.g., Type 3c, MODY, Pre-diabetes…',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _selectedType == 'Other/Not Sure' && (v == null || v.trim().isEmpty)
                    ? 'Please describe your diabetes type'
                    : null,
              ),
            ],
            SizedBox(height: 32.0),

            // Diagnosis Year
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year of Diagnosis',
                hintText: 'e.g., 2015',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter diagnosis year';
                }
                final year = int.tryParse(value);
                final currentYear = DateTime.now().year;
                if (year == null || year < 1900 || year > currentYear) {
                  return 'Enter a valid year between 1900 and $currentYear';
                }
                return null;
              },
            ),
            SizedBox(height: 32.0),

            // Preferred Unit
            Text(
              'Preferred Measurement Unit',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              semanticsLabel: 'Select your preferred glucose measurement unit',
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _buildUnitButton('mg/dL', colorScheme, textTheme),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: _buildUnitButton('mmol/L', colorScheme, textTheme),
                ),
              ],
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

  Widget _buildTypeButton(
    String type,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Semantics(
        button: true,
        selected: isSelected,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainer,
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            type,
            style: textTheme.bodyLarge?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitButton(
    String unit,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedUnit == unit;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUnit = unit;
        });
      },
      child: Semantics(
        button: true,
        selected: isSelected,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainer,
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            unit,
            style: textTheme.titleMedium?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
