import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_tokens.dart';
import '../../services/emergency_service.dart';

class EmergencyContactsView extends StatefulWidget {
  const EmergencyContactsView({super.key});

  @override
  State<EmergencyContactsView> createState() => _EmergencyContactsViewState();
}

class _EmergencyContactsViewState extends State<EmergencyContactsView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _relationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relationCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContact() async {
    final contact = await EmergencyService.getContact();
    if (contact != null) {
      _nameCtrl.text = contact.name;
      _relationCtrl.text = contact.relation;
      _phoneCtrl.text = contact.phoneNumber;
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    final contact = EmergencyContact(
      name: _nameCtrl.text.trim(),
      relation: _relationCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
    );
    
    await EmergencyService.saveContact(contact);
    
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Emergency contact saved successfully.'),
          backgroundColor: AppThemeTokens.brandSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _deleteContact() async {
    setState(() => _isSaving = true);
    await EmergencyService.deleteContact();
    if (mounted) {
      _nameCtrl.clear();
      _relationCtrl.clear();
      _phoneCtrl.clear();
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Emergency contact deleted.'),
          backgroundColor: AppThemeTokens.textSecondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeTokens.bgBackgroundDark : AppThemeTokens.bgBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeTokens.bgSurfaceDark : AppThemeTokens.bgSurface,
        elevation: 0,
        title: Text(
          'Emergency Contact',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
                      decoration: BoxDecoration(
                        color: AppThemeTokens.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                        border: Border.all(
                          color: AppThemeTokens.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppThemeTokens.error.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.phoneCall, color: AppThemeTokens.error, size: 28),
                          ),
                          const SizedBox(width: AppThemeTokens.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SOS Feature',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppThemeTokens.error,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'This contact will be dialed immediately when you activate the SOS button on your dashboard.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white70 : AppThemeTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppThemeTokens.spaceXl),
                    Container(
                      padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
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
                          Text(
                            'Contact Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppThemeTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppThemeTokens.spaceLg),
                          TextFormField(
                            controller: _nameCtrl,
                            style: TextStyle(color: isDark ? Colors.white : AppThemeTokens.textPrimary),
                            decoration: _buildInputDecoration('Full Name', isDark),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: AppThemeTokens.spaceMd),
                          TextFormField(
                            controller: _relationCtrl,
                            style: TextStyle(color: isDark ? Colors.white : AppThemeTokens.textPrimary),
                            decoration: _buildInputDecoration('Relationship (e.g. Spouse, Doctor)', isDark),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          const SizedBox(height: AppThemeTokens.spaceMd),
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-\(\)]')),
                            ],
                            style: TextStyle(color: isDark ? Colors.white : AppThemeTokens.textPrimary),
                            decoration: _buildInputDecoration('Phone Number', isDark),
                            validator: (v) => (v == null || v.trim().length < 5) ? 'Enter a valid number' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppThemeTokens.spaceXl),
                    
                    if (_nameCtrl.text.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: _isSaving ? null : _deleteContact,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppThemeTokens.error,
                          side: BorderSide(color: AppThemeTokens.error.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
                          ),
                        ),
                        icon: const Icon(LucideIcons.trash2, size: 20),
                        label: const Text(
                          'Remove Contact',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppThemeTokens.spaceLg),
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveContact,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeTokens.brandSecondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
              ),
              elevation: 4,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : const Text(
                    'Save Contact',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white54 : AppThemeTokens.textSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.3) : const Color(0xFFD1D5DB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        borderSide: const BorderSide(color: AppThemeTokens.brandAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
