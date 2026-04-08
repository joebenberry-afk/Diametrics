import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_tokens.dart';
import '../../services/reminder_service.dart';
import '../../viewmodels/profile_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'emergency_contacts_view.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final _formKey = GlobalKey<FormState>();

  // Personal info controllers
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  // Diabetes controllers
  final _diagnosisYearCtrl = TextEditingController();

  // Glucose target controllers
  final _glucoseMinCtrl = TextEditingController();
  final _glucoseMaxCtrl = TextEditingController();

  // "Other" free-text controllers for gender and diabetes type
  final _otherGenderCtrl = TextEditingController();
  final _otherDiabetesTypeCtrl = TextEditingController();

  // State fields mirrored from profile
  String _gender = '';
  String _diabetesType = '';
  String _glucoseUnit = 'mg/dL';
  bool _usesInsulin = false;
  bool _usesPills = false;
  bool _usesCgm = false;
  String _insulinCategory = 'standard_rapid';

  // ML Adaptive Model Parameters — mirrored from profile
  double _metabolicClearanceRate = 0.010;
  double _insulinSensitivityFactor = 50.0;
  double _absorptionDelayBase = 40.0;

  bool _isDirty = false;
  bool _isSaving = false;
  bool _hasPopulated = false;

  bool _reminderEnabled = false;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
  }

  static const _genderPresets = ['Male', 'Female', 'Other'];
  static const _diabetesPresets = [
    'Type 1', 'Type 2', 'Gestational', 'LADA', 'Pre-diabetes', 'Other'
  ];

  void _populateFromProfile(dynamic profile) {
    _nameCtrl.text = profile.name;
    _ageCtrl.text = profile.age.toString();
    _heightCtrl.text = profile.heightCm.toStringAsFixed(1);
    _weightCtrl.text = profile.weightKg.toStringAsFixed(1);
    // Only populate year if it's a plausible value
    if (profile.diagnosisYear > 1900) {
      _diagnosisYearCtrl.text = profile.diagnosisYear.toString();
    }
    _glucoseMinCtrl.text = profile.targetGlucoseMin.toStringAsFixed(0);
    _glucoseMaxCtrl.text = profile.targetGlucoseMax.toStringAsFixed(0);

    // Detect "custom Other" values saved from a previous session
    final storedGender = profile.gender as String;
    final storedDiabetes = profile.diabetesType as String;
    final genderIsPreset = _genderPresets.contains(storedGender);
    final diabetesIsPreset = _diabetesPresets.contains(storedDiabetes);

    setState(() {
      _gender = genderIsPreset ? storedGender : 'Other';
      if (!genderIsPreset) _otherGenderCtrl.text = storedGender;

      _diabetesType = diabetesIsPreset ? storedDiabetes : 'Other';
      if (!diabetesIsPreset) _otherDiabetesTypeCtrl.text = storedDiabetes;

      _glucoseUnit = profile.preferredGlucoseUnit;
      _usesInsulin = profile.usesInsulin;
      _usesPills = profile.usesPills;
      _usesCgm = profile.usesCgm;
      _insulinCategory = profile.insulinCategory ?? 'standard_rapid';

      // Populate ML parameters from profile
      _metabolicClearanceRate = profile.metabolicClearanceRate;
      _insulinSensitivityFactor = profile.insulinSensitivityFactor;
      _absorptionDelayBase = profile.absorptionDelayBase;
    });

    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('medication_reminder_enabled') ?? false;
    final hour = prefs.getInt('medication_reminder_hour') ?? 8;
    final minute = prefs.getInt('medication_reminder_minute') ?? 0;
    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _diagnosisYearCtrl.dispose();
    _glucoseMinCtrl.dispose();
    _glucoseMaxCtrl.dispose();
    _otherGenderCtrl.dispose();
    _otherDiabetesTypeCtrl.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final minTarget = double.tryParse(_glucoseMinCtrl.text) ?? 70.0;
    final maxTarget = double.tryParse(_glucoseMaxCtrl.text) ?? 180.0;

    if (minTarget >= maxTarget) {
      _showError('Low target must be less than high target.');
      return;
    }

    if (_gender.isEmpty) {
      _showError('Please select a gender identity.');
      return;
    }
    if (_gender == 'Other' && _otherGenderCtrl.text.trim().isEmpty) {
      _showError('Please describe your gender identity.');
      return;
    }

    if (_diabetesType.isEmpty) {
      _showError('Please select a diabetes type.');
      return;
    }
    if (_diabetesType == 'Other' && _otherDiabetesTypeCtrl.text.trim().isEmpty) {
      _showError('Please describe your diabetes type.');
      return;
    }

    // Resolve final values — use custom text when "Other" was chosen
    final finalGender = _gender == 'Other'
        ? _otherGenderCtrl.text.trim()
        : _gender;
    final finalDiabetesType = _diabetesType == 'Other'
        ? _otherDiabetesTypeCtrl.text.trim()
        : _diabetesType;

    final current = ref.read(userProfileProvider).valueOrNull;
    if (current == null) return;

    double dia = 240.0;
    switch (_insulinCategory) {
      case 'ultra_fast':
        dia = 180.0;
        break;
      case 'regular':
        dia = 360.0;
        break;
      case 'basal_only':
      case 'none':
        dia = 0.0;
        break;
      default:
        dia = 240.0; // standard_rapid
    }

    setState(() => _isSaving = true);
    try {
      final updated = current.copyWith(
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text),
        gender: finalGender,
        heightCm: double.parse(_heightCtrl.text),
        weightKg: double.parse(_weightCtrl.text),
        diabetesType: finalDiabetesType,
        diagnosisYear: int.parse(_diagnosisYearCtrl.text),
        preferredGlucoseUnit: _glucoseUnit,
        usesInsulin: _usesInsulin,
        usesPills: _usesPills,
        usesCgm: _usesCgm,
        insulinCategory: _usesInsulin ? _insulinCategory : 'none',
        insulinDiaMinutes: _usesInsulin ? dia : 0.0,
        targetGlucoseMin: minTarget,
        targetGlucoseMax: maxTarget,
        // Persist the ML parameters (user-modified or tuned)
        metabolicClearanceRate: _metabolicClearanceRate,
        insulinSensitivityFactor: _insulinSensitivityFactor,
        absorptionDelayBase: _absorptionDelayBase,
        updatedAt: DateTime.now(),
      );

      await ref.read(userProfileProvider.notifier).updateProfile(updated);

      if (mounted) {
        setState(() {
          _isDirty = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Settings saved successfully.'),
            backgroundColor: AppThemeTokens.brandSuccess,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Handle Reminders
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('medication_reminder_enabled', _reminderEnabled);
      if (_reminderTime != null) {
        await prefs.setInt('medication_reminder_hour', _reminderTime!.hour);
        await prefs.setInt('medication_reminder_minute', _reminderTime!.minute);
      }

      if (_reminderEnabled && _reminderTime != null) {
        await ReminderService.scheduleDailyReminder(
          id: 1, // Single medication reminder
          title: 'Medication Reminder',
          body: 'It is time to take your scheduled medication.',
          hour: _reminderTime!.hour,
          minute: _reminderTime!.minute,
        );
      } else {
        await ReminderService.cancelReminder(1);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('Failed to save settings. Please try again.');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppThemeTokens.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppThemeTokens.bgBackgroundDark
          : AppThemeTokens.bgBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppThemeTokens.bgSurfaceDark
            : AppThemeTokens.bgSurface,
        elevation: 0,
        title: Text(
          'Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: isDark ? Colors.white : AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppThemeTokens.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isDirty)
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: Text(
                'Save',
                style: TextStyle(
                  color: isDark ? AppThemeTokens.brandAccent : AppThemeTokens.brandSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not load profile: $e',
            style: const TextStyle(color: AppThemeTokens.error),
          ),
        ),
        data: (profile) {
          if (profile != null && !_hasPopulated) {
            _hasPopulated = true;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) { if (mounted) _populateFromProfile(profile); },
            );
          }
          return _buildForm(isDark, theme);
        },
      ),
      bottomNavigationBar: _isDirty
          ? _SaveBar(isSaving: _isSaving, onSave: _save)
          : null,
    );
  }

  Widget _buildSettingsInsulinDropdown(bool isDark, ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          'Primary Mealtime Insulin Type',
          style: TextStyle(
            color: isDark ? Colors.white : AppThemeTokens.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      subtitle: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: isDark ? Colors.black26 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE5E7EB),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _insulinCategory,
            isExpanded: true,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppThemeTokens.brandPrimary,
            ),
            dropdownColor: isDark
                ? AppThemeTokens.bgSurfaceDark
                : AppThemeTokens.bgSurface,
            style: TextStyle(
              color: isDark ? Colors.white : AppThemeTokens.textPrimary,
              fontSize: 14,
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _insulinCategory = newValue);
                _markDirty();
              }
            },
            items: const [
              DropdownMenuItem(
                value: 'ultra_fast',
                child: Text('Ultra-Rapid (Fiasp, Lyumjev)'),
              ),
              DropdownMenuItem(
                value: 'standard_rapid',
                child: Text('Standard Rapid (Humalog, Novolog)'),
              ),
              DropdownMenuItem(
                value: 'regular',
                child: Text('Regular (Humulin R, Novolin R)'),
              ),
              DropdownMenuItem(
                value: 'basal_only',
                child: Text('Basal / Long-Acting Only'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark, ThemeData theme) {
    return Form(
      key: _formKey,
      onChanged: _markDirty,
      child: ListView(
        padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
        children: [
          _ProfileHeader(nameCtrl: _nameCtrl, gender: _gender),
          const SizedBox(height: AppThemeTokens.spaceLg),

          // ── Personal Information ───────────────────────────────────────
          _SectionCard(
            title: 'Personal Information',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            children: [
              _SettingsTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                hint: 'e.g., Maria Santos',
                inputType: TextInputType.name,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                onChanged: (_) => _markDirty(),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _SettingsTextField(
                controller: _ageCtrl,
                label: 'Age',
                hint: 'e.g., 65',
                inputType: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1 || n > 120) {
                    return 'Enter a valid age (1–120)';
                  }
                  return null;
                },
                onChanged: (_) => _markDirty(),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _GenderSelector(
                selected: _gender,
                otherCtrl: _otherGenderCtrl,
                onChanged: (g) {
                  setState(() => _gender = g);
                  _markDirty();
                },
                onOtherChanged: (_) => _markDirty(),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _SettingsTextField(
                controller: _heightCtrl,
                label: 'Height (cm)',
                hint: 'e.g., 165.0',
                inputType: const TextInputType.numberWithOptions(decimal: true),
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n < 50 || n > 300) {
                    return 'Enter a valid height in cm';
                  }
                  return null;
                },
                onChanged: (_) => _markDirty(),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _SettingsTextField(
                controller: _weightCtrl,
                label: 'Weight (kg)',
                hint: 'e.g., 72.5',
                inputType: const TextInputType.numberWithOptions(decimal: true),
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n < 20 || n > 300) {
                    return 'Enter a valid weight in kg';
                  }
                  return null;
                },
                onChanged: (_) => _markDirty(),
              ),
            ],
          ),

          const SizedBox(height: AppThemeTokens.spaceMd),

          // ── Diabetes Profile ───────────────────────────────────────────
          _SectionCard(
            title: 'Diabetes Profile',
            icon: Icons.medical_information_outlined,
            isDark: isDark,
            children: [
              _DiabetesTypeSelector(
                selected: _diabetesType,
                otherCtrl: _otherDiabetesTypeCtrl,
                onChanged: (t) {
                  setState(() => _diabetesType = t);
                  _markDirty();
                },
                onOtherChanged: (_) => _markDirty(),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _SettingsTextField(
                controller: _diagnosisYearCtrl,
                label: 'Year of Diagnosis',
                hint: 'e.g., 2010',
                inputType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  final now = DateTime.now().year;
                  if (n == null || n < 1900 || n > now) {
                    return 'Enter a valid year (1900–$now)';
                  }
                  return null;
                },
                onChanged: (_) => _markDirty(),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _GlucoseUnitToggle(
                selected: _glucoseUnit,
                onChanged: (u) {
                  setState(() => _glucoseUnit = u);
                  _markDirty();
                },
              ),
            ],
          ),

          const SizedBox(height: AppThemeTokens.spaceMd),

          // ── Treatment ─────────────────────────────────────────────────
          _SectionCard(
            title: 'Treatment',
            icon: Icons.medication_outlined,
            isDark: isDark,
            children: [
              _SettingsSwitch(
                label: 'Uses Insulin',
                subtitle: 'Rapid or long-acting insulin injections',
                value: _usesInsulin,
                onChanged: (v) {
                  setState(() => _usesInsulin = v);
                  _markDirty();
                },
              ),
              if (_usesInsulin) ...[
                const Divider(height: 1),
                _buildSettingsInsulinDropdown(isDark, theme),
              ],
              const Divider(height: 1),
              _SettingsSwitch(
                label: 'Uses Oral Medication',
                subtitle: 'Metformin, Glipizide, or similar pills',
                value: _usesPills,
                onChanged: (v) {
                  setState(() => _usesPills = v);
                  _markDirty();
                },
              ),
              const Divider(height: 1),
              _SettingsSwitch(
                label: 'Uses CGM',
                subtitle:
                    'Continuous Glucose Monitor (Dexcom, FreeStyle, etc.)',
                value: _usesCgm,
                onChanged: (v) {
                  setState(() => _usesCgm = v);
                  _markDirty();
                },
              ),
            ],
          ),

          const SizedBox(height: AppThemeTokens.spaceMd),

          // ── Glucose Targets ────────────────────────────────────────────
          _SectionCard(
            title: 'Glucose Targets',
            icon: Icons.track_changes_rounded,
            isDark: isDark,
            children: [
              Container(
                padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
                decoration: BoxDecoration(
                  color: AppThemeTokens.brandPrimary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppThemeTokens.brandPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: AppThemeTokens.spaceSm),
                    Expanded(
                      child: Text(
                        'Readings outside your target range will be flagged. '
                        'Consult your doctor before changing these values.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppThemeTokens.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: _SettingsTextField(
                      controller: _glucoseMinCtrl,
                      label: 'Low Target ($_glucoseUnit)',
                      hint: '70',
                      inputType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      formatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Required';
                        return null;
                      },
                      onChanged: (_) => _markDirty(),
                    ),
                  ),
                  const SizedBox(width: AppThemeTokens.spaceMd),
                  Expanded(
                    child: _SettingsTextField(
                      controller: _glucoseMaxCtrl,
                      label: 'High Target ($_glucoseUnit)',
                      hint: '180',
                      inputType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      formatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Required';
                        return null;
                      },
                      onChanged: (_) => _markDirty(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppThemeTokens.spaceMd),
              _GlucoseTargetVisual(
                minCtrl: _glucoseMinCtrl,
                maxCtrl: _glucoseMaxCtrl,
                unit: _glucoseUnit,
              ),
            ],
          ),

          const SizedBox(height: AppThemeTokens.spaceMd),

          // ── Medication Reminders ───────────────────────────────────────
          _SectionCard(
            title: 'Medication Reminders',
            icon: Icons.alarm_rounded,
            isDark: isDark,
            children: [
              _SettingsSwitch(
                label: 'Enable Daily Reminder',
                subtitle: 'Get a notification to log your medication',
                value: _reminderEnabled,
                onChanged: (v) {
                  setState(() => _reminderEnabled = v);
                  if (v && _reminderTime == null) {
                    _reminderTime = const TimeOfDay(hour: 8, minute: 0);
                  }
                  _markDirty();
                },
              ),
              if (_reminderEnabled && _reminderTime != null) ...[
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Reminder Time',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    _reminderTime!.format(context),
                    style: TextStyle(
                      color: isDark
                          ? Colors.white60
                          : AppThemeTokens.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.edit_calendar_rounded,
                    color: AppThemeTokens.brandPrimary,
                    size: 20,
                  ),
                  onTap: () async {
                    final newTime = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime!,
                    );
                    if (newTime != null) {
                      setState(() => _reminderTime = newTime);
                      _markDirty();
                    }
                  },
                ),
              ],
            ],
          ),

          const SizedBox(height: AppThemeTokens.spaceMd),

          // ── Advanced Model Parameters ──────────────────────────────────
          _MetabolicParamsSection(
            isDark: isDark,
            theme: theme,
            clearanceRate: _metabolicClearanceRate,
            isf: _insulinSensitivityFactor,
            tMax: _absorptionDelayBase,
            onClearanceChanged: (v) { setState(() => _metabolicClearanceRate = v); _markDirty(); },
            onIsfChanged: (v) { setState(() => _insulinSensitivityFactor = v); _markDirty(); },
            onTMaxChanged: (v) { setState(() => _absorptionDelayBase = v); _markDirty(); },
            onReset: () {
              setState(() {
                _metabolicClearanceRate = 0.010;
                _insulinSensitivityFactor = 50.0;
                _absorptionDelayBase = 40.0;
              });
              _markDirty();
            },
          ),

          const SizedBox(height: AppThemeTokens.spaceMd),

          _SectionCard(
            title: 'Safety',
            icon: Icons.health_and_safety_outlined,
            isDark: isDark,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(LucideIcons.phoneCall, color: AppThemeTokens.error),
                title: Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Manage who to call in an emergency',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : AppThemeTokens.textSecondary,
                    fontSize: 13,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppThemeTokens.textSecondary),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmergencyContactsView(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppThemeTokens.spaceXl),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final TextEditingController nameCtrl;
  final String gender;

  const _ProfileHeader({required this.nameCtrl, required this.gender});

  @override
  Widget build(BuildContext context) {
    final displayName = nameCtrl.text.trim().isNotEmpty
        ? nameCtrl.text.trim()
        : 'Patient';
    final initials = displayName.trim().isNotEmpty
        ? displayName.trim().split(' ').map((w) => w[0]).take(2).join()
        : 'P';

    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
      decoration: BoxDecoration(
        color: AppThemeTokens.brandPrimary,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppThemeTokens.brandAccent,
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppThemeTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a field below to edit your profile',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeTokens.bgSurfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color: isDark
              ? AppThemeTokens.brandSecondary.withValues(alpha: 0.25)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppThemeTokens.spaceLg,
              AppThemeTokens.spaceMd,
              AppThemeTokens.spaceLg,
              AppThemeTokens.spaceSm,
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppThemeTokens.brandPrimary),
                const SizedBox(width: AppThemeTokens.spaceSm),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType inputType;
  final List<TextInputFormatter>? formatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _SettingsTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.inputType,
    this.formatters,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppThemeTokens.textPrimary;
    final hintColor = isDark ? Colors.white54 : AppThemeTokens.textSecondary;
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: formatters,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(color: textColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: hintColor),
        labelStyle: TextStyle(color: hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : const Color(0xFFD1D5DB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          borderSide: const BorderSide(
            color: AppThemeTokens.brandAccent,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selected;
  final TextEditingController otherCtrl;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onOtherChanged;

  const _GenderSelector({
    required this.selected,
    required this.otherCtrl,
    required this.onChanged,
    this.onOtherChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveText = isDark ? Colors.white : AppThemeTokens.textPrimary;
    const options = ['Male', 'Female', 'Other'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender Identity',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : AppThemeTokens.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceSm),
        Row(
          children: options.map((g) {
            final isSelected = selected == g;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: g != options.last ? 8 : 0),
                child: GestureDetector(
                  onTap: () => onChanged(g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppThemeTokens.brandSecondary
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : AppThemeTokens.brandPrimary.withValues(alpha: 0.06)),
                      borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppThemeTokens.brandSecondary
                            : AppThemeTokens.brandAccent.withValues(alpha: 0.5),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        g,
                        style: TextStyle(
                          color: isSelected ? Colors.white : inactiveText,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // ── "Other" free-text field ───────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: selected == 'Other'
              ? Padding(
                  key: const ValueKey('gender_other_field'),
                  padding: const EdgeInsets.only(top: AppThemeTokens.spaceSm),
                  child: TextFormField(
                    controller: otherCtrl,
                    onChanged: onOtherChanged,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Describe your gender identity…',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : AppThemeTokens.textSecondary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : const Color(0xFFD1D5DB),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                        borderSide: const BorderSide(
                          color: AppThemeTokens.brandAccent,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    validator: (v) => selected == 'Other' && (v == null || v.trim().isEmpty)
                        ? 'Please describe your gender identity'
                        : null,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('gender_other_hidden')),
        ),
      ],
    );
  }
}

class _DiabetesTypeSelector extends StatelessWidget {
  final String selected;
  final TextEditingController otherCtrl;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onOtherChanged;

  const _DiabetesTypeSelector({
    required this.selected,
    required this.otherCtrl,
    required this.onChanged,
    this.onOtherChanged,
  });

  static const _types = [
    'Type 1',
    'Type 2',
    'Gestational',
    'LADA',
    'Pre-diabetes',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveText = isDark ? Colors.white : AppThemeTokens.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Diabetes Type',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : AppThemeTokens.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceSm),
        // ── Fixed 3-column grid — no layout shifts when selection changes ──
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _types.map((t) {
            final isSelected = selected == t;
            return GestureDetector(
              onTap: () => onChanged(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppThemeTokens.brandSecondary
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : AppThemeTokens.brandPrimary.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppThemeTokens.brandSecondary
                        : AppThemeTokens.brandAccent.withValues(alpha: 0.5),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    t,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : inactiveText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // ── "Other" free-text field ───────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: selected == 'Other'
              ? Padding(
                  key: const ValueKey('diabetes_other_field'),
                  padding: const EdgeInsets.only(top: AppThemeTokens.spaceSm),
                  child: TextFormField(
                    controller: otherCtrl,
                    onChanged: onOtherChanged,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Specify your diabetes type…',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : AppThemeTokens.textSecondary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.3)
                              : const Color(0xFFD1D5DB),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                        borderSide: const BorderSide(
                          color: AppThemeTokens.brandAccent,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    validator: (v) => selected == 'Other' && (v == null || v.trim().isEmpty)
                        ? 'Please specify your diabetes type'
                        : null,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('diabetes_other_hidden')),
        ),
      ],
    );
  }
}

class _GlucoseUnitToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GlucoseUnitToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveText = isDark ? Colors.white70 : AppThemeTokens.textPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Glucose Unit',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : AppThemeTokens.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppThemeTokens.spaceSm),
        Row(
          children: ['mg/dL', 'mmol/L'].map((unit) {
            final isSelected = selected == unit;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: unit == 'mg/dL' ? 8 : 0),
                child: GestureDetector(
                  onTap: () => onChanged(unit),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppThemeTokens.brandSecondary
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppThemeTokens.brandPrimary.withValues(alpha: 0.06)),
                      borderRadius: BorderRadius.circular(
                        AppThemeTokens.radiusMd,
                      ),
                      border: Border.all(
                        color: isSelected
                            ? AppThemeTokens.brandSecondary
                            : AppThemeTokens.brandAccent.withValues(alpha: 0.4),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unit,
                        style: TextStyle(
                          color: isSelected ? Colors.white : inactiveText,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : AppThemeTokens.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.white60 : AppThemeTokens.textSecondary,
          fontSize: 13,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppThemeTokens.brandAccent,
      activeTrackColor: AppThemeTokens.brandAccent.withValues(alpha: 0.4),
    );
  }
}

/// Visual bar showing the target glucose range at a glance.
class _GlucoseTargetVisual extends StatelessWidget {
  final TextEditingController minCtrl;
  final TextEditingController maxCtrl;
  final String unit;

  const _GlucoseTargetVisual({
    required this.minCtrl,
    required this.maxCtrl,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final min = double.tryParse(minCtrl.text) ?? 70.0;
    final max = double.tryParse(maxCtrl.text) ?? 180.0;
    final isValid = min < max;

    return Container(
      padding: const EdgeInsets.all(AppThemeTokens.spaceMd),
      decoration: BoxDecoration(
        color: AppThemeTokens.brandPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        border: Border.all(
          color: AppThemeTokens.brandPrimary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Range Preview',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppThemeTokens.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isValid)
                Text(
                  '${min.toStringAsFixed(0)}–${max.toStringAsFixed(0)} $unit',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppThemeTokens.brandPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppThemeTokens.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Background full bar (danger zone)
                Container(
                  height: 16,
                  color: AppThemeTokens.error.withValues(alpha: 0.25),
                ),
                // Green target zone
                if (isValid)
                  FractionallySizedBox(
                    widthFactor: ((max - min) / 400.0).clamp(0.05, 1.0),
                    child: Container(
                      height: 16,
                      margin: EdgeInsets.only(
                        left:
                            MediaQuery.of(context).size.width *
                            (min / 400.0).clamp(0.0, 1.0) *
                            0.6,
                      ),
                      color: AppThemeTokens.brandSuccess.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '0',
                style: TextStyle(
                  fontSize: 11,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
              Text(
                '400',
                style: TextStyle(
                  fontSize: 11,
                  color: AppThemeTokens.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const _SaveBar({required this.isSaving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppThemeTokens.spaceLg,
          AppThemeTokens.spaceSm,
          AppThemeTokens.spaceLg,
          AppThemeTokens.spaceMd,
        ),
        child: SizedBox(
          height: AppThemeTokens.minTapTarget,
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeTokens.brandPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Advanced Model Parameters Section
// Allows expert users to view & override the ML-tuned metabolic constants with
// strict gating, clinical warnings, and a one-tap "Reset to Defaults" option.
// ─────────────────────────────────────────────────────────────────────────────

class _MetabolicParamsSection extends StatefulWidget {
  final bool isDark;
  final ThemeData theme;
  final double clearanceRate;
  final double isf;
  final double tMax;
  final ValueChanged<double> onClearanceChanged;
  final ValueChanged<double> onIsfChanged;
  final ValueChanged<double> onTMaxChanged;
  final VoidCallback onReset;

  const _MetabolicParamsSection({
    required this.isDark,
    required this.theme,
    required this.clearanceRate,
    required this.isf,
    required this.tMax,
    required this.onClearanceChanged,
    required this.onIsfChanged,
    required this.onTMaxChanged,
    required this.onReset,
  });

  @override
  State<_MetabolicParamsSection> createState() =>
      _MetabolicParamsSectionState();
}

class _MetabolicParamsSectionState extends State<_MetabolicParamsSection> {
  bool _unlocked = false;

  static const double _p1Default = 0.010;
  static const double _isfDefault = 50.0;
  static const double _tMaxDefault = 40.0;

  bool get _isAtDefault =>
      (widget.clearanceRate - _p1Default).abs() < 1e-5 &&
      (widget.isf - _isfDefault).abs() < 0.01 &&
      (widget.tMax - _tMaxDefault).abs() < 0.01;

  Future<void> _requestUnlock() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFD97706),
          size: 36,
        ),
        title: const Text(
          'Clinical Parameter Warning',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'These parameters control how your glucose projections are '
          'calculated. They are automatically tuned by the app as you '
          'log meals and glucose readings.\n\n'
          'Changing them manually can cause inaccurate predictions and '
          'may affect clinical decisions. Only proceed if directed by a '
          'healthcare professional.\n\n'
          'Use "Reset to Defaults" at any time to restore population-level '
          'averages and re-allow automatic learning.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Locked'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('I Understand — Unlock'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _unlocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final textPrimary =
        isDark ? Colors.white : AppThemeTokens.textPrimary;
    final textSecondary =
        isDark ? Colors.white60 : AppThemeTokens.textSecondary;
    final cardColor = isDark
        ? AppThemeTokens.bgSurfaceDark
        : AppThemeTokens.bgSurface;
    const amber = Color(0xFFD97706);
    const amberLight = Color(0xFFFEF3C7);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
        border: Border.all(
          color: amber.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppThemeTokens.spaceLg,
              AppThemeTokens.spaceLg,
              AppThemeTokens.spaceLg,
              AppThemeTokens.spaceMd,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: amber.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppThemeTokens.radiusMd),
                  ),
                  child: const Icon(
                    LucideIcons.brainCircuit,
                    color: amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppThemeTokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advanced Model Parameters',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Auto-tuned by AI · Expert use only',
                        style: TextStyle(
                          color: amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lock / Unlock toggle chip
                GestureDetector(
                  onTap: _unlocked
                      ? () => setState(() => _unlocked = false)
                      : _requestUnlock,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _unlocked
                          ? const Color(0xFFD1FAE5)
                          : amberLight,
                      borderRadius:
                          BorderRadius.circular(AppThemeTokens.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _unlocked
                              ? Icons.lock_open_rounded
                              : LucideIcons.lock,
                          size: 12,
                          color: _unlocked
                              ? const Color(0xFF059669)
                              : amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _unlocked ? 'Unlocked' : 'Locked',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _unlocked
                                ? const Color(0xFF059669)
                                : amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Warning Banner ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppThemeTokens.spaceLg),
            child: Container(
              padding: const EdgeInsets.all(AppThemeTokens.spaceSm),
              decoration: BoxDecoration(
                color: amber.withValues(alpha: 0.08),
                borderRadius:
                    BorderRadius.circular(AppThemeTokens.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _unlocked
                          ? 'You are editing clinical parameters. Changes affect glucose predictions.'
                          : 'These values are automatically learned from your logs. No action needed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.amber.shade200 : amber,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppThemeTokens.spaceMd),

          // ── Sliders ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppThemeTokens.spaceLg),
            child: AbsorbPointer(
              absorbing: !_unlocked,
              child: Opacity(
                opacity: _unlocked ? 1.0 : 0.55,
                child: Column(
                  children: [
                    _ParamSlider(
                      label: 'Metabolic Clearance Rate',
                      description:
                          'How quickly excess glucose is cleared from blood.'
                          ' Lower = slower clearance, higher post-meal spikes.',
                      unit: 'min⁻¹',
                      value: widget.clearanceRate,
                      min: 0.002,
                      max: 0.020,
                      divisions: 18,
                      displayDecimals: 3,
                      defaultValue: _p1Default,
                      isDark: isDark,
                      textSecondary: textSecondary,
                      onChanged: widget.onClearanceChanged,
                    ),
                    const SizedBox(height: AppThemeTokens.spaceMd),
                    _ParamSlider(
                      label: 'Insulin Sensitivity Factor',
                      description:
                          'How many mg/dL blood glucose drops per unit of '
                          'rapid-acting insulin. Higher = more sensitive.',
                      unit: 'mg/dL·U',
                      value: widget.isf,
                      min: 20.0,
                      max: 150.0,
                      divisions: 26,
                      displayDecimals: 0,
                      defaultValue: _isfDefault,
                      isDark: isDark,
                      textSecondary: textSecondary,
                      onChanged: widget.onIsfChanged,
                    ),
                    const SizedBox(height: AppThemeTokens.spaceMd),
                    _ParamSlider(
                      label: 'Digestion Delay',
                      description:
                          'Time until peak gut glucose absorption. '
                          'Longer = slower digestion, flatter but prolonged spike.',
                      unit: 'minutes',
                      value: widget.tMax,
                      min: 20.0,
                      max: 90.0,
                      divisions: 14,
                      displayDecimals: 0,
                      defaultValue: _tMaxDefault,
                      isDark: isDark,
                      textSecondary: textSecondary,
                      onChanged: widget.onTMaxChanged,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppThemeTokens.spaceMd),

          // ── Reset to Defaults button ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppThemeTokens.spaceLg,
              0,
              AppThemeTokens.spaceLg,
              AppThemeTokens.spaceLg,
            ),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isAtDefault
                    ? null
                    : () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title:
                                const Text('Reset to Clinical Defaults?'),
                            content: const Text(
                              'This will restore population-level averages:\n\n'
                              '• Clearance Rate: 0.010 min⁻¹\n'
                              '• Insulin Sensitivity: 50 mg/dL·U\n'
                              '• Digestion Delay: 40 minutes\n\n'
                              'The AI will begin re-learning your personal '
                              'parameters on your next meal logs.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && mounted) {
                          widget.onReset();
                          setState(() => _unlocked = false);
                        }
                      },
                icon: Icon(
                  Icons.restart_alt_rounded,
                  size: 16,
                  color: _isAtDefault ? textSecondary : AppThemeTokens.brandPrimary,
                ),
                label: Text(
                  _isAtDefault
                      ? 'Already at Default Values'
                      : 'Reset to Clinical Defaults',
                  style: TextStyle(
                    color: _isAtDefault
                        ? textSecondary
                        : AppThemeTokens.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isAtDefault
                        ? Colors.grey.shade300
                        : AppThemeTokens.brandPrimary.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppThemeTokens.radiusMd),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual parameter slider row with label, description, current value,
/// and a subtle "default" marker line.
class _ParamSlider extends StatelessWidget {
  final String label;
  final String description;
  final String unit;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final int displayDecimals;
  final double defaultValue;
  final bool isDark;
  final Color textSecondary;
  final ValueChanged<double> onChanged;

  const _ParamSlider({
    required this.label,
    required this.description,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayDecimals,
    required this.defaultValue,
    required this.isDark,
    required this.textSecondary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final atDefault = (value - defaultValue).abs() < 1e-5;
    final accent = const Color(0xFFD97706);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: atDefault
                    ? const Color(0xFFD1FAE5)
                    : accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusFull),
              ),
              child: Text(
                '${value.toStringAsFixed(displayDecimals)} $unit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: atDefault ? const Color(0xFF059669) : accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: textSecondary,
            height: 1.4,
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: accent,
            thumbColor: accent,
            inactiveTrackColor: accent.withValues(alpha: 0.2),
            overlayColor: accent.withValues(alpha: 0.1),
            trackHeight: 3,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toStringAsFixed(displayDecimals),
              style: TextStyle(fontSize: 10, color: textSecondary),
            ),
            Row(
              children: [
                Icon(Icons.arrow_drop_up_rounded,
                    size: 14, color: textSecondary),
                Text(
                  'Default: ${defaultValue.toStringAsFixed(displayDecimals)}',
                  style: TextStyle(fontSize: 10, color: textSecondary),
                ),
              ],
            ),
            Text(
              max.toStringAsFixed(displayDecimals),
              style: TextStyle(fontSize: 10, color: textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
