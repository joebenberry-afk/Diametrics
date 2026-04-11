# Food Scanner Theme Unification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all hardcoded `Color(0xFF…)` literals in the Food Scanner UI with `AppThemeTokens` / `colorScheme` values so it looks identical to the rest of the DiaMetrics app.

**Architecture:** Swap-in-place — no new files, no structural changes, no viewmodel changes. Two files are touched: `food_scanner_view.dart` and `food_item_edit_sheet.dart`. Every colour derivation uses `Theme.of(context)` at the widget `build` call site, making both files automatically correct in light mode, dark mode, and any future theme change.

**Tech Stack:** Flutter, Dart, `AppThemeTokens` (`lib/core/theme/app_tokens.dart`), `AppTheme` (`lib/core/theme/app_theme.dart`), `flutter_test`, `mocktail`

---

## File Map

| File | Action |
|---|---|
| `lib/views/food_scanner/food_scanner_view.dart` | Modify — replace all hardcoded colours |
| `lib/views/food_scanner/food_item_edit_sheet.dart` | Modify — replace all hardcoded colours; refactor `_MacroCell` |
| `test/views/food_scanner_view_test.dart` | Modify — add light + dark theme render tests |
| `test/views/food_item_edit_sheet_test.dart` | Modify — add light + dark theme render tests |

---

## Colour Reference (consult throughout)

```dart
// Derive these at the top of every build() that needs them:
final cs = Theme.of(context).colorScheme;
final isDark = cs.brightness == Brightness.dark;

// Shorthands used in every task below:
// cs.surface             → card/sheet backgrounds (replaces 0xFF13151f)
// cs.onSurface           → primary text          (replaces 0xFFc8cfe0)
// cs.onSurface.withValues(alpha: 0.6)  → secondary text / muted icons (replaces 0xFF8892aa)
// cs.primary             → accent / buttons / carbs highlight (replaces 0xFF4a9eff)
// cs.error               → error icon colour      (replaces 0xFFef5350)
// borderColor (compute inline):
//   isDark ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
//          : const Color(0xFFD1D5DB)
// inputFill (compute inline):
//   isDark ? AppThemeTokens.bgBackgroundDark : AppThemeTokens.bgBackground
```

---

## Task 1: Confirm baseline tests pass

**Files:** none modified

- [ ] **Step 1: Run existing food scanner tests**

```bash
cd <project-root>
flutter test test/views/food_scanner_view_test.dart test/views/food_item_edit_sheet_test.dart --reporter compact
```

Expected: all tests pass. If any fail, fix them before continuing — do not proceed with theme changes on a broken baseline.

- [ ] **Step 2: Note current test count**

Record the count printed by the test runner (e.g. "6 tests passed"). You'll verify the same count still passes at the end.

---

## Task 2: Add theme-render tests (TDD — write before making changes)

**Files:**
- Modify: `test/views/food_scanner_view_test.dart`
- Modify: `test/views/food_item_edit_sheet_test.dart`

These tests verify that both widgets render without exceptions under the real `AppTheme.lightTheme` and `AppTheme.darkTheme`. They will **pass even before our colour changes** (the hardcoded colours render fine under any theme), and continue passing after — giving us confidence we haven't broken the render tree.

- [ ] **Step 1: Add imports and helper to `food_scanner_view_test.dart`**

Add to the top of the file (after existing imports):

```dart
import 'package:diametrics/core/theme/app_theme.dart';
```

Add this helper alongside the existing `_wrap` helper:

```dart
Widget _wrapThemed(Widget child, ThemeData theme,
    {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: theme, home: child),
    );
```

- [ ] **Step 2: Add theme render tests to `food_scanner_view_test.dart`**

Append inside `void main()`, after the last existing test:

```dart
group('theme rendering', () {
  testWidgets('renders under AppTheme.lightTheme without error',
      (tester) async {
    await tester.pumpWidget(_wrapThemed(
      const FoodScannerView(),
      AppTheme.lightTheme,
      overrides: [foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo)],
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(FoodScannerView), findsOneWidget);
  });

  testWidgets('renders under AppTheme.darkTheme without error',
      (tester) async {
    await tester.pumpWidget(_wrapThemed(
      const FoodScannerView(),
      AppTheme.darkTheme,
      overrides: [foodAnalyzerRepositoryProvider.overrideWithValue(mockRepo)],
    ));
    expect(tester.takeException(), isNull);
    expect(find.byType(FoodScannerView), findsOneWidget);
  });
});
```

- [ ] **Step 3: Add theme render tests to `food_item_edit_sheet_test.dart`**

Add import at top:

```dart
import 'package:diametrics/core/theme/app_theme.dart';
```

Append inside `void main()`:

```dart
group('theme rendering', () {
  testWidgets('renders under AppTheme.lightTheme without error',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: FoodItemEditSheet(item: item, onSave: (_) {})),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders under AppTheme.darkTheme without error',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: FoodItemEditSheet(item: item, onSave: (_) {})),
    ));
    expect(tester.takeException(), isNull);
  });
});
```

- [ ] **Step 4: Run new tests to confirm they pass now**

```bash
flutter test test/views/food_scanner_view_test.dart test/views/food_item_edit_sheet_test.dart --reporter compact
```

Expected: all tests pass (theme tests pass even with hardcoded colours).

- [ ] **Step 5: Commit tests**

```bash
git add test/views/food_scanner_view_test.dart test/views/food_item_edit_sheet_test.dart
git commit -m "test: add light/dark theme render tests for food scanner views"
```

---

## Task 3: Retheme `FoodScannerView` — Scaffold, AppBar, bottom sheet

**Files:**
- Modify: `lib/views/food_scanner/food_scanner_view.dart`

- [ ] **Step 1: Add `AppThemeTokens` import**

At the top of `food_scanner_view.dart`, add:

```dart
import '../../core/theme/app_tokens.dart';
```

- [ ] **Step 2: Remove hardcoded `Scaffold` and `AppBar` colours**

Replace the entire `build` method's `Scaffold` block (lines 114–152) with:

```dart
@override
Widget build(BuildContext context) {
  final state = ref.watch(foodScannerProvider);

  return Scaffold(
    appBar: AppBar(
      elevation: 0,
      title: const Text('Food Scanner'),
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        onPressed: () => context.pop(null),
      ),
      actions: [
        if (state.status == FoodScannerStatus.results)
          TextButton(
            onPressed: () =>
                ref.read(foodScannerProvider.notifier).reset(),
            child: Text(
              'Start Over',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                fontSize: 13,
              ),
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
```

Key changes: removed `backgroundColor` on `Scaffold`, removed all hardcoded colours on `AppBar`, removed inline `TextStyle` colour on the title (inherited from `appBarTheme`), "Start Over" text now uses `colorScheme.onSurface.withValues(alpha: 0.6)`.

- [ ] **Step 3: Update bottom sheet background and radius in `_openEditSheet`**

Replace the `showModalBottomSheet` call (lines 68–81):

```dart
void _openEditSheet(int index, FoodItem item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppThemeTokens.radiusLg),
      ),
    ),
    builder: (_) => FoodItemEditSheet(
      item: item,
      onSave: (updated) =>
          ref.read(foodScannerProvider.notifier).updateItem(index, updated),
    ),
  );
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/views/food_scanner_view_test.dart --reporter compact
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/views/food_scanner/food_scanner_view.dart
git commit -m "refactor: retheme FoodScannerView scaffold, appbar, bottom sheet"
```

---

## Task 4: Retheme `_buildSourcePicker` and `_SourceButton`

**Files:**
- Modify: `lib/views/food_scanner/food_scanner_view.dart`

- [ ] **Step 1: Update `_buildSourcePicker` text colours**

Replace the entire `_buildSourcePicker` method:

```dart
Widget _buildSourcePicker() {
  final cs = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Add Food',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how to identify your food',
          style: TextStyle(
            color: cs.onSurface.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 40),
        _SourceButton(icon: LucideIcons.camera, label: 'Take Photo', onTap: _onTakePhoto),
        const SizedBox(height: 12),
        _SourceButton(icon: LucideIcons.image, label: 'Choose from Gallery', onTap: _onGallery),
        const SizedBox(height: 12),
        _SourceButton(icon: LucideIcons.scan, label: 'Scan Barcode', onTap: _onBarcodePressed),
      ],
    ),
  );
}
```

- [ ] **Step 2: Update `_SourceButton` widget**

Replace the entire `_SourceButton` class (lines 544–587):

```dart
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
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(children: [
            Icon(icon, color: cs.primary, size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              LucideIcons.chevronRight,
              color: cs.onSurface.withValues(alpha: 0.6),
              size: 16,
            ),
          ]),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Run tests**

```bash
flutter test test/views/food_scanner_view_test.dart --reporter compact
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/views/food_scanner/food_scanner_view.dart
git commit -m "refactor: retheme FoodScannerView source picker and _SourceButton"
```

---

## Task 5: Retheme analysing, results, and totals footer

**Files:**
- Modify: `lib/views/food_scanner/food_scanner_view.dart`

- [ ] **Step 1: Update `_buildAnalysing`**

Replace the entire `_buildAnalysing` method:

```dart
Widget _buildAnalysing(FoodScannerState state) {
  final cs = Theme.of(context).colorScheme;
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: cs.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              state.analysisStatus,
              key: ValueKey(state.analysisStatus),
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
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
```

- [ ] **Step 2: Update `_buildTotalsFooter`**

Replace the entire `_buildTotalsFooter` method:

```dart
Widget _buildTotalsFooter(FoodScannerState state) {
  final cs = Theme.of(context).colorScheme;
  return Container(
    color: cs.surface,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Column(
      children: [
        Row(children: [
          _TotalCell(label: 'Total Carbs', value: state.totalCarbs.toStringAsFixed(1), unit: 'g', isCarbs: true),
          _TotalCell(label: 'Total Protein', value: state.totalProtein.toStringAsFixed(1), unit: 'g', isCarbs: false),
          _TotalCell(label: 'Total Fat', value: state.totalFat.toStringAsFixed(1), unit: 'g', isCarbs: false),
          _TotalCell(label: 'kcal', value: state.totalCalories.toStringAsFixed(0), unit: '', isCarbs: false),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _confirm(state),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
              ),
            ),
            child: const Text(
              'Confirm & Add to Meal',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
```

Key changes: removed `backgroundColor` on `FilledButton` (defaults to `cs.primary`), updated radius to `AppThemeTokens.radiusMd`, container colour → `cs.surface`.

- [ ] **Step 3: Run tests**

```bash
flutter test test/views/food_scanner_view_test.dart --reporter compact
```

Expected: all tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/views/food_scanner/food_scanner_view.dart
git commit -m "refactor: retheme FoodScannerView analysing state and totals footer"
```

---

## Task 6: Retheme barcode-not-found, manual entry form, and error state

**Files:**
- Modify: `lib/views/food_scanner/food_scanner_view.dart`

- [ ] **Step 1: Update `_buildBarcodeNotFound`**

Replace the entire `_buildBarcodeNotFound` method:

```dart
Widget _buildBarcodeNotFound() {
  final cs = Theme.of(context).colorScheme;
  final isDark = cs.brightness == Brightness.dark;
  final borderColor = isDark
      ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
      : const Color(0xFFD1D5DB);

  return SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Icon(LucideIcons.scanLine, color: cs.onSurface.withValues(alpha: 0.6), size: 48),
        const SizedBox(height: 16),
        Text(
          'Product not found',
          style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'This product isn\'t in our database yet.',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          icon: const Icon(LucideIcons.camera, size: 16),
          label: const Text('Take a Photo Instead'),
          onPressed: _onTakePhoto,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: borderColor),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '— or enter manually —',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 11),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _buildManualEntryForm(),
      ],
    ),
  );
}
```

- [ ] **Step 2: Update `_buildManualEntryForm`**

Replace the entire `_buildManualEntryForm` method:

```dart
Widget _buildManualEntryForm() {
  final cs = Theme.of(context).colorScheme;
  final isDark = cs.brightness == Brightness.dark;
  final borderColor = isDark
      ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
      : const Color(0xFFD1D5DB);
  final inputFill = isDark ? AppThemeTokens.bgBackgroundDark : AppThemeTokens.bgBackground;

  final inputDecoration = InputDecoration(
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
    labelStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  return Form(
    key: _manualFormKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _manualNameCtrl,
          style: TextStyle(color: cs.onSurface, fontSize: 14),
          decoration: inputDecoration.copyWith(labelText: 'Food Name'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _manualCarbsCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: inputDecoration.copyWith(labelText: 'Carbs (g)'),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Enter a number';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _manualProteinCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: inputDecoration.copyWith(labelText: 'Protein (g)'),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Enter a number';
                return null;
              },
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _manualFatCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: inputDecoration.copyWith(labelText: 'Fat (g)'),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Enter a number';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _manualKcalCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: cs.onSurface, fontSize: 14),
              decoration: inputDecoration.copyWith(labelText: 'kcal'),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Enter a number';
                return null;
              },
            ),
          ),
        ]),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _submitManualEntry,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
            ),
          ),
          child: const Text('Add to Meal'),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 3: Update `_buildError`**

Replace the entire `_buildError` method:

```dart
Widget _buildError(FoodScannerState state) {
  final cs = Theme.of(context).colorScheme;
  final isDark = cs.brightness == Brightness.dark;
  final borderColor = isDark
      ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
      : const Color(0xFFD1D5DB);

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, color: cs.error, size: 48),
          const SizedBox(height: 16),
          Text(
            state.errorMessage ?? 'Something went wrong.',
            style: TextStyle(color: cs.onSurface, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ref.read(foodScannerProvider.notifier).reset(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: borderColor),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 4: Run tests**

```bash
flutter test test/views/food_scanner_view_test.dart --reporter compact
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/views/food_scanner/food_scanner_view.dart
git commit -m "refactor: retheme FoodScannerView barcode-not-found, manual form, error states"
```

---

## Task 7: Retheme private sub-widgets in `food_scanner_view.dart`

**Files:**
- Modify: `lib/views/food_scanner/food_scanner_view.dart`

- [ ] **Step 1: Replace `_FoodItemCard`**

Replace the entire `_FoodItemCard` class (lines 589–680):

```dart
class _FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const _FoodItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final borderColor = isDark
        ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
        : const Color(0xFFD1D5DB);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _SourceBadge(source: item.source),
              const SizedBox(width: 8),
              Icon(LucideIcons.pencil, color: cs.onSurface.withValues(alpha: 0.6), size: 14),
            ]),
            const SizedBox(height: 4),
            Text(
              item.weightG > 0
                  ? '${item.portion} · ${item.weightG.toStringAsFixed(0)}g'
                  : item.portion,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 11),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: IntrinsicHeight(
                child: Row(children: [
                  _MacroInlineCell(label: 'Carbs', value: item.carbsGrams.toStringAsFixed(1), unit: 'g', isCarbs: true),
                  _MacroInlineCell(label: 'Protein', value: item.proteinGrams.toStringAsFixed(1), unit: 'g', isCarbs: false),
                  _MacroInlineCell(label: 'Fat', value: item.fatGrams.toStringAsFixed(1), unit: 'g', isCarbs: false),
                  _MacroInlineCell(label: 'kcal', value: item.calories.toStringAsFixed(0), unit: '', isCarbs: false),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Replace `_MacroInlineCell`**

Replace the entire `_MacroInlineCell` class (lines 682–750):

```dart
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
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final borderColor = isDark
        ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
        : const Color(0xFFD1D5DB);
    final valueColor = isCarbs ? cs.primary : cs.onSurface;
    final labelColor = isCarbs ? cs.primary : cs.onSurface.withValues(alpha: 0.6);

    return Container(
      constraints: const BoxConstraints(minWidth: 64),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: label == 'Carbs' ? Colors.transparent : borderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: labelColor, fontSize: 8, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text.rich(TextSpan(children: [
            TextSpan(
              text: value,
              style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w800, height: 1),
            ),
            if (unit.isNotEmpty)
              TextSpan(
                text: unit,
                style: TextStyle(color: valueColor, fontSize: 8, fontWeight: FontWeight.w500),
              ),
          ])),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Replace `_TotalCell`**

Replace the entire `_TotalCell` class (lines 752–812):

```dart
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
    final cs = Theme.of(context).colorScheme;
    final valueColor = isCarbs ? cs.primary : cs.onSurface;
    final labelColor = isCarbs ? cs.primary : cs.onSurface.withValues(alpha: 0.6);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(color: labelColor, fontSize: 8, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text.rich(TextSpan(children: [
            TextSpan(
              text: value,
              style: TextStyle(
                color: valueColor,
                fontSize: isCarbs ? 22 : 16,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            if (unit.isNotEmpty)
              TextSpan(
                text: unit,
                style: TextStyle(color: valueColor, fontSize: 9, fontWeight: FontWeight.w500),
              ),
          ])),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Replace `_SourceBadge`**

Replace the entire `_SourceBadge` class (lines 814–837):

```dart
class _SourceBadge extends StatelessWidget {
  final String source;
  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final bgColor = isDark ? AppThemeTokens.bgBackgroundDark : AppThemeTokens.bgBackground;
    final borderColor = isDark
        ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3)
        : const Color(0xFFD1D5DB);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        source,
        style: TextStyle(
          color: cs.onSurface.withValues(alpha: 0.6),
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run tests**

```bash
flutter test test/views/food_scanner_view_test.dart --reporter compact
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/views/food_scanner/food_scanner_view.dart
git commit -m "refactor: retheme FoodScannerView private sub-widgets"
```

---

## Task 8: Retheme `food_item_edit_sheet.dart`

**Files:**
- Modify: `lib/views/food_scanner/food_item_edit_sheet.dart`

- [ ] **Step 1: Add `AppThemeTokens` import**

At the top of `food_item_edit_sheet.dart`, add:

```dart
import '../../core/theme/app_tokens.dart';
```

- [ ] **Step 2: Update drag handle and `FilledButton` in main `build` method**

In `_FoodItemEditSheetState.build`, replace the drag handle `Center` block (lines 74–84):

```dart
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
```

Replace the `FilledButton` (lines 135–143):

```dart
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
```

- [ ] **Step 3: Replace `_MacroSummaryRow`**

Replace the entire `_MacroSummaryRow` class (lines 173–212):

```dart
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
```

- [ ] **Step 4: Replace `_MacroCell` (signature change + theme colours)**

Replace the entire `_MacroCell` class (lines 214–269):

```dart
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
            style: TextStyle(color: labelColor, fontSize: 8, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text.rich(TextSpan(children: [
            TextSpan(
              text: value,
              style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w800),
            ),
            if (unit.isNotEmpty)
              TextSpan(
                text: unit,
                style: TextStyle(color: valueColor, fontSize: 8, fontWeight: FontWeight.w500),
              ),
          ])),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 5: Replace `_EditField`**

Replace the entire `_EditField` class (lines 271–310):

```dart
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
```

- [ ] **Step 6: Run tests**

```bash
flutter test test/views/food_item_edit_sheet_test.dart --reporter compact
```

Expected: all tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/views/food_scanner/food_item_edit_sheet.dart
git commit -m "refactor: retheme FoodItemEditSheet — all hardcoded colours replaced"
```

---

## Task 9: Final verification and grep check

**Files:** none modified

- [ ] **Step 1: Verify no hardcoded colour literals remain in the two files**

```bash
grep -n "Color(0xFF" lib/views/food_scanner/food_scanner_view.dart lib/views/food_scanner/food_item_edit_sheet.dart
```

Expected: only `0xFFD1D5DB` (the light-mode border colour that has no `AppThemeTokens` equivalent) should appear. Any other hit is a missed replacement — fix it before continuing.

- [ ] **Step 2: Run the full food scanner test suite**

```bash
flutter test test/views/food_scanner_view_test.dart test/views/food_item_edit_sheet_test.dart test/viewmodels/food_scanner_viewmodel_test.dart test/integration/food_scanner_weight_regression_test.dart --reporter compact
```

Expected: all tests pass (same count as Task 1 Step 2 plus the 4 new theme-render tests added in Task 2).

- [ ] **Step 3: Confirm app compiles**

```bash
flutter build apk --debug 2>&1 | tail -5
```

Expected: `Built build/app/outputs/flutter-apk/app-debug.apk` (or similar success line). No compile errors.

- [ ] **Step 4: Final commit**

```bash
git add .
git commit -m "refactor: food scanner UI now uses AppThemeTokens throughout"
```
