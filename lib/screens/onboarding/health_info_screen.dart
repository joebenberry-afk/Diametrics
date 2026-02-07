import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/senior_text_field.dart';
import '../../widgets/senior_dropdown.dart';
import 'medical_settings_screen.dart';

/// HealthInfoScreen - Collects health-related information.
///
/// Fields: Weight, Height, Type of Diabetes
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
    return Scaffold(
      backgroundColor: const Color(0xFFB8D4E8), // Light blue from prototype
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Header Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Health Information',
                  style: SeniorTheme.headingStyle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Form Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9CC4D8), // Slightly darker blue
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Weight Field
                        SeniorTextField(
                          controller: _weightController,
                          label: 'Weight',
                          hint: 'kg/lbs',
                          keyboardType: TextInputType.number,
                          semanticLabel: 'Enter your weight',
                        ),
                        const SizedBox(height: 24),
                        // Height Field
                        SeniorTextField(
                          controller: _heightController,
                          label: 'Height',
                          hint: 'ft/cm',
                          keyboardType: TextInputType.number,
                          semanticLabel: 'Enter your height',
                        ),
                        const SizedBox(height: 24),
                        // Diabetes Type Dropdown
                        Text('Type of Diabetes', style: SeniorTheme.labelStyle),
                        const SizedBox(height: 8),
                        SeniorDropdown<String>(
                          value: _selectedDiabetesType,
                          hint: 'Select',
                          items: _diabetesTypes
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
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
                  ),
                ),
              ),
            ),
            // Next Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _navigateToNext,
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
