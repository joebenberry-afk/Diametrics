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

  final List<String> _diabetesTypes = [
    'Type 1',
    'Type 2',
    'Gestational',
    'Pre-diabetes',
    'Not diabetic',
  ];

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
          SeniorTextField(
            controller: _weightController,
            hint: 'kg/lbs',
            keyboardType: TextInputType.number,
            semanticLabel: 'Enter your weight',
          ),
          const SizedBox(height: 24),
          Text('Height', style: SeniorTheme.labelStyle),
          const SizedBox(height: 8),
          SeniorTextField(
            controller: _heightController,
            hint: 'ft/cm',
            keyboardType: TextInputType.number,
            semanticLabel: 'Enter your height',
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
