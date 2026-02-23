import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../widgets/senior_dropdown.dart';
import '../widgets/onboarding_layout.dart';
import 'dashboard/main_layout.dart';

class MedicalSettingsScreen extends StatefulWidget {
  const MedicalSettingsScreen({super.key});

  @override
  State<MedicalSettingsScreen> createState() => _MedicalSettingsScreenState();
}

class _MedicalSettingsScreenState extends State<MedicalSettingsScreen> {
  String? _selectedMedication;
  String? _selectedInsulin;
  String? _selectedGlucoseUnit;

  final List<String> _medicationOptions = [
    'None',
    'Metformin',
    'Sulfonylureas',
    'GLP-1 agonists',
    'SGLT2 inhibitors',
    'Other',
  ];

  final List<String> _insulinOptions = [
    'No',
    'Yes - Pen',
    'Yes - Pump',
    'Yes - Syringe',
  ];

  final List<String> _glucoseUnitOptions = ['mmol/L', 'mg/dL'];

  final List<String> _glucoseTargetOptions = [
    '3.0',
    '3.5',
    '3.9',
    '4.0',
    '4.5',
    '5.0',
    '5.5',
    '6.0',
    '6.5',
    '7.0',
    '7.5',
    '8.0',
    '8.5',
    '9.0',
    '9.5',
    '10.0',
    '11.0',
    '12.0',
    '13.0',
    '14.0',
  ];

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Setup complete! Welcome to DiaMetrics.',
          style: SeniorTheme.bodyStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: SeniorTheme.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainLayout()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      cardTitle: 'Health Information\n(Continued)',
      onContinue: _finishOnboarding,
      continueLabel: 'Finish',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What medication(s) do you take?',
            style: SeniorTheme.labelStyle,
          ),
          const SizedBox(height: 8),
          SeniorDropdown<String>(
            value: _selectedMedication,
            hint: 'Select',
            items: _medicationOptions
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedMedication = value;
              });
            },
            semanticLabel: 'Select your medications',
          ),
          const SizedBox(height: 24),
          Text('Do you take insulin?', style: SeniorTheme.labelStyle),
          const SizedBox(height: 8),
          SeniorDropdown<String>(
            value: _selectedInsulin,
            hint: 'Select',
            items: _insulinOptions
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedInsulin = value;
              });
            },
            semanticLabel: 'Select insulin usage',
          ),
          const SizedBox(height: 24),
          Text('Preferred glucose units', style: SeniorTheme.labelStyle),
          const SizedBox(height: 8),
          SeniorDropdown<String>(
            value: _selectedGlucoseUnit,
            hint: 'Select',
            items: _glucoseUnitOptions
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGlucoseUnit = value;
              });
            },
            semanticLabel: 'Select preferred glucose units',
          ),
          const SizedBox(height: 24),
          Text('Target glucose levels:', style: SeniorTheme.labelStyle),
          const SizedBox(height: 16),
          // After Meals section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text('After Meals', style: SeniorTheme.labelStyle),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SeniorDropdown<String>(
                  value: null,
                  hint: 'High (select)',
                  items: _glucoseTargetOptions
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (value) {},
                  semanticLabel: 'After meals high target',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SeniorDropdown<String>(
                  value: null,
                  hint: 'Low (select)',
                  items: _glucoseTargetOptions
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (value) {},
                  semanticLabel: 'After meals low target',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Before Meals section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text('Before Meals', style: SeniorTheme.labelStyle),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SeniorDropdown<String>(
                  value: null,
                  hint: 'High (select)',
                  items: _glucoseTargetOptions
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (value) {},
                  semanticLabel: 'Before meals high target',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SeniorDropdown<String>(
                  value: null,
                  hint: 'Low (select)',
                  items: _glucoseTargetOptions
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (value) {},
                  semanticLabel: 'Before meals low target',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
