import 'package:flutter/material.dart';
import 'package:diametrics/services/log_service.dart';

class GlucoseLogScreen extends StatefulWidget {
  const GlucoseLogScreen({super.key});

  @override
  State<GlucoseLogScreen> createState() => _GlucoseLogScreenState();
}

class _GlucoseLogScreenState extends State<GlucoseLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();
  final _service = LogService();

  String _unit = 'mmol/L';
  bool _saving = false;

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  String? _validateGlucose(String? v) {
    final text = (v ?? '').trim();
    if (text.isEmpty) return 'Please enter a value.';

    final value = double.tryParse(text);
    if (value == null) return 'Enter a valid number.';

    // Simple safe ranges (not medical advice; just input sanity)
    if (_unit == 'mmol/L' && (value < 1.0 || value > 33.3)) {
      return 'Value looks unusual. Check units.';
    }
    if (_unit == 'mg/dL' && (value < 18 || value > 600)) {
      return 'Value looks unusual. Check units.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final value = double.parse(_glucoseController.text.trim());
      await _service.addGlucose(value, unit: _unit);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved: ${value.toStringAsFixed(1)} $_unit')),
      );

      _glucoseController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Blood Glucose')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _glucoseController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Blood glucose',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 18),
                      validator: _validateGlucose,
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _unit,
                    items: const [
                      DropdownMenuItem(value: 'mmol/L', child: Text('mmol/L')),
                      DropdownMenuItem(value: 'mg/dL', child: Text('mg/dL')),
                    ],
                    onChanged: _saving
                        ? null
                        : (v) {
                            if (v == null) return;
                            setState(() => _unit = v);
                          },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: Text(
                    _saving ? 'Saving...' : 'Save',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}