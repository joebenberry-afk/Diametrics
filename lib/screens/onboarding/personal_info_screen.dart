import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/senior_text_field.dart';
import '../../widgets/senior_dropdown.dart';
import 'health_info_screen.dart';

/// PersonalInfoScreen - Collects basic user information.
///
/// Fields: Name, Date of Birth, Gender
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String? _selectedGender;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1960),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: SeniorTheme.lightTheme.copyWith(
            textTheme: SeniorTheme.lightTheme.textTheme.copyWith(
              headlineMedium: SeniorTheme.headingStyle,
              bodyLarge: SeniorTheme.bodyStyle,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  void _navigateToNext() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HealthInfoScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8D4F0), // Light purple from prototype
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Personal Information',
                  style: SeniorTheme.headingStyle.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
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
                    color: const Color(0xFFD4B8E0), // Slightly darker purple
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Field
                        SeniorTextField(
                          controller: _nameController,
                          label: 'Name',
                          hint: 'Your name',
                          semanticLabel: 'Enter your full name',
                        ),
                        const SizedBox(height: 24),
                        // Date of Birth Field
                        SeniorTextField(
                          controller: _dobController,
                          label: 'Date of Birth',
                          hint: 'DD/MM/YYYY',
                          readOnly: true,
                          onTap: _selectDate,
                          semanticLabel: 'Select your date of birth',
                        ),
                        const SizedBox(height: 24),
                        // Gender Dropdown
                        Text('Gender', style: SeniorTheme.labelStyle),
                        const SizedBox(height: 8),
                        SeniorDropdown<String>(
                          value: _selectedGender,
                          hint: 'Select',
                          items: _genderOptions
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          semanticLabel: 'Select your gender',
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
