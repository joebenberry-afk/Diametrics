import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../widgets/senior_text_field.dart';
import '../widgets/senior_dropdown.dart';
import 'package:diametrics/screens/onboarding/dashboard_screen.dart';

/// MedicalSettingsScreen - Collects medical and glucose settings.
///
/// Fields: Medications, Insulin use, Glucose units, Target levels
class MedicalSettingsScreen extends StatefulWidget {
  const MedicalSettingsScreen({super.key});

  @override
  State<MedicalSettingsScreen> createState() => _MedicalSettingsScreenState();
}

class _MedicalSettingsScreenState extends State<MedicalSettingsScreen> {
  final _highTargetController = TextEditingController();
  final _lowTargetController = TextEditingController();
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

  @override
  void dispose() {
    _highTargetController.dispose();
    _lowTargetController.dispose();
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

  // Go to dashboard and remove onboarding/login from back stack
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const DashboardScreen()),
    (route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7BCCC4), // Teal from prototype
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Form Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medications Dropdown
                      Text(
                        'What medication(s) do you take?',
                        style: SeniorTheme.labelStyle.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SeniorDropdown<String>(
                        value: _selectedMedication,
                        hint: 'Select',
                        items: _medicationOptions
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMedication = value;
                          });
                        },
                        semanticLabel: 'Select your medications',
                      ),
                      const SizedBox(height: 24),
                      // Insulin Dropdown
                      Text(
                        'Do you take insulin?',
                        style: SeniorTheme.labelStyle.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SeniorDropdown<String>(
                        value: _selectedInsulin,
                        hint: 'Select',
                        items: _insulinOptions
                            .map(
                              (i) => DropdownMenuItem(value: i, child: Text(i)),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedInsulin = value;
                          });
                        },
                        semanticLabel: 'Select insulin usage',
                      ),
                      const SizedBox(height: 24),
                      // Glucose Units Dropdown
                      Text(
                        'Preferred glucose units',
                        style: SeniorTheme.labelStyle.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SeniorDropdown<String>(
                        value: _selectedGlucoseUnit,
                        hint: 'Select',
                        items: _glucoseUnitOptions
                            .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGlucoseUnit = value;
                          });
                        },
                        semanticLabel: 'Select preferred glucose units',
                      ),
                      const SizedBox(height: 24),
                      // Target Glucose Levels
                      Text(
                        'Target glucose levels:',
                        style: SeniorTheme.labelStyle.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // High Target
                      Text(
                        'High',
                        style: SeniorTheme.labelStyle.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SeniorTextField(
                        controller: _highTargetController,
                        hint: _selectedGlucoseUnit == 'mg/dL'
                            ? '180 mg/dL'
                            : '10.0 mmol/L',
                        keyboardType: TextInputType.number,
                        semanticLabel: 'Enter high glucose target',
                      ),
                      const SizedBox(height: 16),
                      // Low Target
                      Text(
                        'Low',
                        style: SeniorTheme.labelStyle.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SeniorTextField(
                        controller: _lowTargetController,
                        hint: _selectedGlucoseUnit == 'mg/dL'
                            ? '70 mg/dL'
                            : '3.9 mmol/L',
                        keyboardType: TextInputType.number,
                        semanticLabel: 'Enter low glucose target',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Finish Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Next page',
                        style: SeniorTheme.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
