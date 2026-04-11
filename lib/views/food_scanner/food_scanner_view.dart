import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../router/route_names.dart';
import '../../src/domain/entities/food_item.dart';
import '../../src/domain/entities/food_scanner_result.dart';
import '../../viewmodels/food_scanner_viewmodel.dart';
import 'food_item_edit_sheet.dart';

class FoodScannerView extends ConsumerStatefulWidget {
  const FoodScannerView({super.key});

  @override
  ConsumerState<FoodScannerView> createState() => _FoodScannerViewState();
}

class _FoodScannerViewState extends ConsumerState<FoodScannerView> {
  final _picker = ImagePicker();
  final _manualFormKey = GlobalKey<FormState>();
  final _manualNameCtrl = TextEditingController();
  final _manualCarbsCtrl = TextEditingController();
  final _manualProteinCtrl = TextEditingController();
  final _manualFatCtrl = TextEditingController();
  final _manualKcalCtrl = TextEditingController();

  @override
  void dispose() {
    _manualNameCtrl.dispose();
    _manualCarbsCtrl.dispose();
    _manualProteinCtrl.dispose();
    _manualFatCtrl.dispose();
    _manualKcalCtrl.dispose();
    super.dispose();
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────

  Future<void> _onTakePhoto() async {
    final xFile =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (xFile == null || !mounted) return;
    ref.read(foodScannerProvider.notifier).analyseImage(xFile.path);
  }

  Future<void> _onGallery() async {
    final xFile = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (xFile == null || !mounted) return;
    ref.read(foodScannerProvider.notifier).analyseImage(xFile.path);
  }

  Future<void> _onBarcodePressed() async {
    final result = await context.push<FoodItem>(Routes.logMealBarcode);
    if (!mounted) return;
    if (result != null) {
      ref.read(foodScannerProvider.notifier).submitBarcodeResult(result);
    } else {
      ref.read(foodScannerProvider.notifier).handleBarcodeNotFound();
    }
  }

  void _openEditSheet(int index, FoodItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13151f),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FoodItemEditSheet(
        item: item,
        onSave: (updated) =>
            ref.read(foodScannerProvider.notifier).updateItem(index, updated),
      ),
    );
  }

  void _confirm(FoodScannerState state) {
    final result = FoodScannerResult(
      items: state.items,
      totalCarbs: state.totalCarbs,
      totalProtein: state.totalProtein,
      totalFat: state.totalFat,
      totalCalories: state.totalCalories,
    );
    context.pop(result);
  }

  void _submitManualEntry() {
    if (!_manualFormKey.currentState!.validate()) return;
    final item = FoodItem(
      name: _manualNameCtrl.text.trim(),
      portion: '1 serving',
      carbsGrams: double.tryParse(_manualCarbsCtrl.text) ?? 0,
      proteinGrams: double.tryParse(_manualProteinCtrl.text) ?? 0,
      fatGrams: double.tryParse(_manualFatCtrl.text) ?? 0,
      calories: double.tryParse(_manualKcalCtrl.text) ?? 0,
      source: 'Manual Entry',
    );
    ref.read(foodScannerProvider.notifier).submitManualEntry(item);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodScannerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F1A),
        foregroundColor: const Color(0xFFc8cfe0),
        elevation: 0,
        title: const Text(
          'Food Scanner',
          style: TextStyle(
            color: Color(0xFFc8cfe0),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(null),
        ),
        actions: [
          if (state.status == FoodScannerStatus.results)
            TextButton(
              onPressed: () =>
                  ref.read(foodScannerProvider.notifier).reset(),
              child: const Text(
                'Start Over',
                style: TextStyle(color: Color(0xFF8892aa), fontSize: 13),
              ),
            ),
        ],
      ),
      body: switch (state.status) {
        FoodScannerStatus.idle => _buildSourcePicker(),
        FoodScannerStatus.analysing => _buildAnalysing(state),
        FoodScannerStatus.results => _buildResults(state),
        FoodScannerStatus.barcodeNotFound => _buildBarcodeNotFound(),
        FoodScannerStatus.error => _buildError(state),
      },
    );
  }

  // ── State 1: Source Picker ─────────────────────────────────────────────────

  Widget _buildSourcePicker() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Add Food',
            style: TextStyle(
              color: Color(0xFFc8cfe0),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose how to identify your food',
            style: TextStyle(color: Color(0xFF8892aa), fontSize: 14),
          ),
          const SizedBox(height: 40),
          _SourceButton(
            icon: LucideIcons.camera,
            label: 'Take Photo',
            onTap: _onTakePhoto,
          ),
          const SizedBox(height: 12),
          _SourceButton(
            icon: LucideIcons.image,
            label: 'Choose from Gallery',
            onTap: _onGallery,
          ),
          const SizedBox(height: 12),
          _SourceButton(
            icon: LucideIcons.scan,
            label: 'Scan Barcode',
            onTap: _onBarcodePressed,
          ),
        ],
      ),
    );
  }

  // ── State 2: Analysing ─────────────────────────────────────────────────────

  Widget _buildAnalysing(FoodScannerState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF4a9eff),
              strokeWidth: 2,
            ),
            const SizedBox(height: 32),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                state.analysisStatus,
                key: ValueKey(state.analysisStatus),
                style: const TextStyle(
                  color: Color(0xFF8892aa),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── State 3: Results ───────────────────────────────────────────────────────

  Widget _buildResults(FoodScannerState state) {
    return Column(
      children: [
        if (state.imagePath != null)
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Image.file(
              File(state.imagePath!),
              fit: BoxFit.cover,
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _FoodItemCard(
                item: item,
                onTap: () => _openEditSheet(index, item),
              );
            },
          ),
        ),
        _buildTotalsFooter(state),
      ],
    );
  }

  Widget _buildTotalsFooter(FoodScannerState state) {
    return Container(
      color: const Color(0xFF13151f),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Row(children: [
            _TotalCell(
              label: 'Total Carbs',
              value: state.totalCarbs.toStringAsFixed(1),
              unit: 'g',
              isCarbs: true,
            ),
            _TotalCell(
              label: 'Total Protein',
              value: state.totalProtein.toStringAsFixed(1),
              unit: 'g',
              isCarbs: false,
            ),
            _TotalCell(
              label: 'Total Fat',
              value: state.totalFat.toStringAsFixed(1),
              unit: 'g',
              isCarbs: false,
            ),
            _TotalCell(
              label: 'kcal',
              value: state.totalCalories.toStringAsFixed(0),
              unit: '',
              isCarbs: false,
            ),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _confirm(state),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4a9eff),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Confirm & Add to Meal',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── State 5: Barcode Not Found ─────────────────────────────────────────────

  Widget _buildBarcodeNotFound() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Icon(
            LucideIcons.scanLine,
            color: Color(0xFF8892aa),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Product not found',
            style: TextStyle(
              color: Color(0xFFc8cfe0),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'This product isn\'t in our database yet.',
            style: TextStyle(color: Color(0xFF8892aa), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            icon: const Icon(LucideIcons.camera, size: 16),
            label: const Text('Take a Photo Instead'),
            onPressed: _onTakePhoto,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFc8cfe0),
              side: const BorderSide(color: Color(0xFF2a2d3a)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '— or enter manually —',
            style: TextStyle(color: Color(0xFF8892aa), fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildManualEntryForm(),
        ],
      ),
    );
  }

  Widget _buildManualEntryForm() {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1a1d27),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2a2d3a)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2a2d3a)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4a9eff)),
      ),
      labelStyle:
          const TextStyle(color: Color(0xFF8892aa), fontSize: 12),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );

    return Form(
      key: _manualFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _manualNameCtrl,
            style: const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
            decoration:
                inputDecoration.copyWith(labelText: 'Food Name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _manualCarbsCtrl,
                keyboardType: TextInputType.number,
                style:
                    const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
                decoration:
                    inputDecoration.copyWith(labelText: 'Carbs (g)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _manualProteinCtrl,
                keyboardType: TextInputType.number,
                style:
                    const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
                decoration:
                    inputDecoration.copyWith(labelText: 'Protein (g)'),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _manualFatCtrl,
                keyboardType: TextInputType.number,
                style:
                    const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
                decoration: inputDecoration.copyWith(labelText: 'Fat (g)'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _manualKcalCtrl,
                keyboardType: TextInputType.number,
                style:
                    const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
                decoration:
                    inputDecoration.copyWith(labelText: 'kcal'),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitManualEntry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4a9eff),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add to Meal'),
          ),
        ],
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────

  Widget _buildError(FoodScannerState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              color: Color(0xFFef5350),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Something went wrong.',
              style:
                  const TextStyle(color: Color(0xFFc8cfe0), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () =>
                  ref.read(foodScannerProvider.notifier).reset(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFc8cfe0),
                side: const BorderSide(color: Color(0xFF2a2d3a)),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets (file-scoped)
// ---------------------------------------------------------------------------

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF13151f),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(children: [
            Icon(icon, color: const Color(0xFF4a9eff), size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFc8cfe0),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              LucideIcons.chevronRight,
              color: Color(0xFF8892aa),
              size: 16,
            ),
          ]),
        ),
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const _FoodItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF13151f),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1e2130)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name row + source badge + edit icon
            Row(children: [
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: Color(0xFFc8cfe0),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _SourceBadge(source: item.source),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.pencil,
                color: Color(0xFF8892aa),
                size: 14,
              ),
            ]),
            const SizedBox(height: 4),
            // Portion + weight
            Text(
              item.weightG > 0
                  ? '${item.portion} · ${item.weightG.toStringAsFixed(0)}g'
                  : item.portion,
              style: const TextStyle(
                color: Color(0xFF8892aa),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            // Macro inline row (horizontally scrollable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: IntrinsicHeight(
                child: Row(children: [
                  _MacroInlineCell(
                    label: 'Carbs',
                    value: item.carbsGrams.toStringAsFixed(1),
                    unit: 'g',
                    isCarbs: true,
                  ),
                  _MacroInlineCell(
                    label: 'Protein',
                    value: item.proteinGrams.toStringAsFixed(1),
                    unit: 'g',
                    isCarbs: false,
                  ),
                  _MacroInlineCell(
                    label: 'Fat',
                    value: item.fatGrams.toStringAsFixed(1),
                    unit: 'g',
                    isCarbs: false,
                  ),
                  _MacroInlineCell(
                    label: 'kcal',
                    value: item.calories.toStringAsFixed(0),
                    unit: '',
                    isCarbs: false,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroInlineCell extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool isCarbs;

  const _MacroInlineCell({
    required this.label,
    required this.value,
    required this.unit,
    required this.isCarbs,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isCarbs ? const Color(0xFF4a9eff) : const Color(0xFFc8cfe0);
    final labelColor =
        isCarbs ? const Color(0xFF4a9eff) : const Color(0xFF8892aa);

    return Container(
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: const Color(0xFF1e2130),
            width: label == 'Carbs' ? 0 : 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _TotalCell extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool isCarbs;

  const _TotalCell({
    required this.label,
    required this.value,
    required this.unit,
    required this.isCarbs,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isCarbs ? const Color(0xFF4a9eff) : const Color(0xFFc8cfe0);
    final labelColor =
        isCarbs ? const Color(0xFF4a9eff) : const Color(0xFF8892aa);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: color,
                  fontSize: isCarbs ? 22 : 16,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1d27),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF2a2d3a)),
      ),
      child: Text(
        source,
        style: const TextStyle(
          color: Color(0xFF8892aa),
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
