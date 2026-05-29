import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../src/domain/entities/food_item.dart';

class FoodItemEditSheet extends StatefulWidget {
  final FoodItem item;
  final void Function(FoodItem updated) onSave;

  const FoodItemEditSheet({
    required this.item,
    required this.onSave,
    super.key,
  });

  @override
  State<FoodItemEditSheet> createState() => _FoodItemEditSheetState();
}

class _FoodItemEditSheetState extends State<FoodItemEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _portionCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _carbsCtrl;
  late final TextEditingController _proteinCtrl;
  late final TextEditingController _fatCtrl;
  late final TextEditingController _kcalCtrl;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _nameCtrl = TextEditingController(text: i.name);
    _portionCtrl = TextEditingController(text: i.portion);
    _weightCtrl = TextEditingController(
        text: i.weightG > 0 ? i.weightG.toStringAsFixed(0) : '');
    _carbsCtrl = TextEditingController(text: i.carbsGrams.toStringAsFixed(1));
    _proteinCtrl =
        TextEditingController(text: i.proteinGrams.toStringAsFixed(1));
    _fatCtrl = TextEditingController(text: i.fatGrams.toStringAsFixed(1));
    _kcalCtrl = TextEditingController(text: i.calories.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _portionCtrl.dispose();
    _weightCtrl.dispose();
    _carbsCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _kcalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) => SingleChildScrollView(
        controller: scrollCtrl,
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Read-only macro summary
            _MacroSummaryRow(item: widget.item),
            const SizedBox(height: 20),
            // Editable fields
            _EditField(ctrl: _nameCtrl, label: 'Food Name'),
            const SizedBox(height: 12),
            _EditField(ctrl: _portionCtrl, label: 'Portion'),
            const SizedBox(height: 12),
            _EditField(
              ctrl: _weightCtrl,
              label: 'Weight (g)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _EditField(
                  ctrl: _carbsCtrl,
                  label: 'Carbs (g)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EditField(
                  ctrl: _proteinCtrl,
                  label: 'Protein (g)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _EditField(
                  ctrl: _fatCtrl,
                  label: 'Fat (g)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EditField(
                  ctrl: _kcalCtrl,
                  label: 'kcal',
                  keyboardType: TextInputType.number,
                ),
              ),
            ]),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _onSave,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
                ),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    final i = widget.item;
    final updated = i.copyWith(
      name: _nameCtrl.text.trim().isNotEmpty
          ? _nameCtrl.text.trim()
          : i.name,
      portion: _portionCtrl.text.trim().isNotEmpty
          ? _portionCtrl.text.trim()
          : i.portion,
      weightG: double.tryParse(_weightCtrl.text) ?? i.weightG,
      carbsGrams: double.tryParse(_carbsCtrl.text) ?? i.carbsGrams,
      proteinGrams: double.tryParse(_proteinCtrl.text) ?? i.proteinGrams,
      fatGrams: double.tryParse(_fatCtrl.text) ?? i.fatGrams,
      calories: double.tryParse(_kcalCtrl.text) ?? i.calories,
    );
    widget.onSave(updated);
    Navigator.of(context).pop();
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _MacroSummaryRow extends StatelessWidget {
  final FoodItem item;
  const _MacroSummaryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
      ),
      child: Row(children: [
        _MacroCell(label: 'Carbs', value: item.carbsGrams.toStringAsFixed(1), unit: 'g', isCarbs: true),
        _MacroCell(label: 'Protein', value: item.proteinGrams.toStringAsFixed(1), unit: 'g', isCarbs: false),
        _MacroCell(label: 'Fat', value: item.fatGrams.toStringAsFixed(1), unit: 'g', isCarbs: false),
        _MacroCell(label: 'kcal', value: item.calories.toStringAsFixed(0), unit: '', isCarbs: false),
      ]),
    );
  }
}

class _MacroCell extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool isCarbs;

  const _MacroCell({
    required this.label,
    required this.value,
    required this.unit,
    required this.isCarbs,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final valueColor = isCarbs ? cs.primary : cs.onSurface;
    final labelColor = isCarbs ? cs.primary : cs.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: labelColor, fontSize: 8, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text.rich(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            TextSpan(children: [
              TextSpan(
                text: value,
                style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w800),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: unit,
                  style: TextStyle(color: valueColor, fontSize: 8, fontWeight: FontWeight.w500),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final TextInputType keyboardType;

  const _EditField({
    required this.ctrl,
    required this.label,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final borderColor = isDark
        ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
        : const Color(0xFFD1D5DB);
    final inputFill = isDark ? AppThemeTokens.bgBackgroundDark : AppThemeTokens.bgBackground;

    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: TextStyle(color: cs.onSurface, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12),
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusSm),
          borderSide: BorderSide(color: cs.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
