import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/senior_text_field.dart';
import '../widgets/senior_dropdown.dart';
import '../widgets/onboarding_layout.dart';
import 'medical_settings_screen.dart';

class HealthInfoScreen extends StatefulWidget {
  const HealthInfoScreen({super.key});

  @override
  State<HealthInfoScreen> createState() => _HealthInfoScreenState();
}

class _HealthInfoScreenState extends State<HealthInfoScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _selectedDiabetesType;
  String _selectedWeightUnit = 'kg';
  String _selectedHeightUnit = 'cm';

  final List<String> _diabetesTypes = [
    'Type 1',
    'Type 2',
    'Gestational',
    'Pre-diabetes',
    'Not diabetic',
  ];

  final List<String> _weightUnits = ['kg', 'lbs'];
  final List<String> _heightUnits = ['cm', 'ft/in'];

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MedicalSettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      cardTitle: 'Health Information',
      onContinue: _navigateToNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weight', style: SeniorTheme.labelStyle),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SeniorTextField(
                  controller: _weightController,
                  hint: _selectedWeightUnit == 'kg' ? 'e.g. 70' : 'e.g. 154',
                  keyboardType: TextInputType.number,
                  semanticLabel: 'Enter your weight in $_selectedWeightUnit',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SeniorDropdown<String>(
                  value: _selectedWeightUnit,
                  hint: 'Unit',
                  items: _weightUnits
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedWeightUnit = value;
                      });
                    }
                  },
                  semanticLabel: 'Select weight unit',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Height', style: SeniorTheme.labelStyle),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SeniorTextField(
                  controller: _heightController,
                  hint: _selectedHeightUnit == 'cm' ? 'e.g. 170' : "e.g. 5'7\"",
                  keyboardType: _selectedHeightUnit == 'cm'
                      ? TextInputType.number
                      : TextInputType.text,
                  semanticLabel: 'Enter your height in $_selectedHeightUnit',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SeniorDropdown<String>(
                  value: _selectedHeightUnit,
                  hint: 'Unit',
                  items: _heightUnits
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedHeightUnit = value;
                      });
                    }
                  },
                  semanticLabel: 'Select height unit',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Type of Diabetes', style: SeniorTheme.labelStyle),
          const SizedBox(height: 8),
          SeniorDropdown<String>(
            value: _selectedDiabetesType,
            hint: 'Select',
            items: _diabetesTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDiabetesType = value;
              });
            },
            semanticLabel: 'Select your type of diabetes',
          ),
        ],
      ),
    );
  }
}
