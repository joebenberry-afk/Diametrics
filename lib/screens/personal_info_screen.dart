import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/senior_text_field.dart';
import '../widgets/senior_dropdown.dart';
import '../widgets/onboarding_layout.dart';
import 'health_info_screen.dart';

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
    return OnboardingLayout(
      cardTitle: 'Personal Information',
      onContinue: _navigateToNext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name', style: SeniorTheme.labelStyle),
          const SizedBox(height: 8),
          SeniorTextField(
            controller: _nameController,
            hint: 'Your Name',
            semanticLabel: 'Enter your full name',
          ),
          const SizedBox(height: 24),
          Text('Date of Birth', style: SeniorTheme.labelStyle),
          const SizedBox(height: 8),
          SeniorTextField(
            controller: _dobController,
            hint: 'DD/MM/YYYY',
            readOnly: true,
            onTap: _selectDate,
            semanticLabel: 'Select your date of birth',
          ),
          const SizedBox(height: 24),
          Text('Gender', style: SeniorTheme.labelStyle),
          const SizedBox(height: 8),
          SeniorDropdown<String>(
            value: _selectedGender,
            hint: 'Select',
            items: _genderOptions
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
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
    );
  }
}
