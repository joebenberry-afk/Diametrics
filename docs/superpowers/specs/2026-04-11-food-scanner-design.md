# Food Scanner Redesign — Design Spec
**Date:** 2026-04-11  
**Branch:** `claude/compassionate-poincare`  
**Status:** Approved — ready for implementation

---

## Overview

Replace the food scanning flow embedded in `MealWizardView` with a dedicated `FoodScannerView` screen. The current embedded approach mixes camera state, analysis state, barcode routing, and result display into a 1,642-line view. The new design extracts all of that into a focused screen (~400 lines) with a clean push/pop contract, fixes two missing fields in `FoodAnalysisResult`, and delivers a clinical-precision UI appropriate for a diabetic patient self-managing their condition.

---

## Architecture

### Before
`MealWizardView` (1,642 lines) owns: image picker, camera state machine (5 embedded states), `_showSourceSheet()` modal, `_runAnalysis()` inline trigger, `_openBarcodeScanner()` inline nav + result handling, a 72×72 thumbnail, and a compressed non-editable items list.

### After
```
MealWizardView (~1,200 lines)
  └── _buildFoodScanButton()     ← simple CTA only
  └── _openFoodScanner()         ← push FoodScannerView, await FoodScannerResult
        ↓ Navigator.push
FoodScannerView (~400 lines)
  └── State 1: Source picker     ← photo / gallery / barcode
  └── State 2: Analysing         ← enrichment pipeline progress
  └── State 3: Results           ← item list + totals + confirm CTA
  └── FoodItemEditSheet          ← bottom sheet overlay on results state
  └── State 5: Barcode not found ← dual recovery (photo OR manual entry)
        ↓ Navigator.pop(FoodScannerResult)
MealWizardView receives FoodScannerResult, appends items to meal
```

`BarcodeScannerView` is unchanged. `FoodScannerView` pushes it and receives the barcode string back.

---

## Data Model Changes

### `FoodAnalysisResult` — add two missing fields

**File:** `lib/src/domain/entities/food_analysis_result.dart`

Current:
```dart
const factory FoodAnalysisResult({
  required List<FoodItem> items,
  required double totalCarbs,
  required double totalCalories,
  required String summary,
}) = _FoodAnalysisResult;
```

After:
```dart
const factory FoodAnalysisResult({
  required List<FoodItem> items,
  required double totalCarbs,
  required double totalCalories,
  required double totalProtein,   // NEW
  required double totalFat,       // NEW
  required String summary,
  @Default({}) Map<String, double> confidenceScore, // NEW — per macro, 0.0–1.0
}) = _FoodAnalysisResult;
```

Totals are computed as the sum of all items' fields. `confidenceScore` keys: `"carbs"`, `"protein"`, `"fat"`, `"calories"`. Values reflect the highest RAG tier that provided data (Tier 1 = 1.0, Tier 4/AI = 0.4).

### `FoodScannerResult` — new return type

**File:** `lib/src/domain/entities/food_scanner_result.dart` (new file)

```dart
@freezed
class FoodScannerResult with _$FoodScannerResult {
  const factory FoodScannerResult({
    required List<FoodItem> items,
    required double totalCarbs,
    required double totalProtein,
    required double totalFat,
    required double totalCalories,
  }) = _FoodScannerResult;
}
```

This is what `FoodScannerView` pops back to `MealWizardView`. It is a plain value object — no Freezed JSON serialisation needed.

---

## New Files

### `lib/views/food_scanner/food_scanner_view.dart`
The main screen. Manages `FoodScannerState` via a Riverpod `StateNotifier` exposed through `foodScannerProvider`. Handles all 4 navigation states (idle, analysing, results, barcodeNotFound). ~400 lines.

**State machine:**
```
idle → analysing → results
idle → barcodeNotFound (when barcode lookup 404s)
barcodeNotFound → analysing (user picks "Take Photo")
barcodeNotFound → results (user submits manual entry)
results → idle (user taps "Start Over")
```

**Navigation contract:**
- Pushed by `MealWizardView._openFoodScanner()` with no arguments
- Pops `FoodScannerResult` on "Confirm & Add to Meal"
- Pops `null` if user backs out

### `lib/views/food_scanner/food_item_edit_sheet.dart`
Bottom sheet for per-item editing. Receives a `FoodItem`, presents editable fields (name, portion, carbsGrams, proteinGrams, fatGrams, calories), and calls a callback with the updated item on confirm. ~150 lines.

### `lib/providers/food_scanner_provider.dart`
`FoodScannerNotifier` + `FoodScannerState`. Wraps `FoodAnalyzerRepository.analyzeImage()` and `BackendFoodService` barcode lookup. Exposes:
- `analyseImage(String path)`
- `lookupBarcode(String code)`
- `updateItem(int index, FoodItem updated)` — re-computes totals
- `submitManualEntry(FoodItem item)` — builds single-item result
- `reset()`

---

## UI Design

**Aesthetic:** Clinical precision — dark background (`#0d0f1a`), data-dense, no decorative colour. Matches existing app dark theme.

**Colour rule:**
- Carbohydrates: `#4a9eff` (blue) — primary because carbs drive glucose prediction
- Protein / Fat / kcal: `#c8cfe0` (neutral light) — supporting data
- Labels / secondary text: `#8892aa`
- Dividers / card backgrounds: `#1e2130` / `#13151f`

### State 1 — Source Picker
Three full-width action buttons stacked vertically: "Take Photo", "Choose from Gallery", "Scan Barcode". Each has a Material Icon left-aligned. No camera preview on this screen — camera is handled by `ImagePicker` plugin.

### State 2 — Analysing
Full-height screen with centred progress indicator. Below it, a live status line cycles through enrichment pipeline steps:
1. "Sending to Gemini…"
2. "Checking custom foods…"
3. "Enriching from local database…"
4. "Fetching USDA data…"
5. "Finalising…"

Steps fire as `FoodScannerNotifier` progresses through `FoodRagService.enrichWithLocalData()` tiers.

### State 3 — Results
- **Image thumbnail** (full-width, 160px tall, `BoxFit.cover`) at top
- **Scrollable item list** — each item card contains:
  - Item name (16px, bold) + source badge (e.g. "USDA", "AI Estimate")
  - Portion + weight (e.g. "1 cup · 240g")
  - **Macro inline row**: 4-column flex row, scrollable horizontally if needed. Columns: Carbs (blue) / Protein / Fat / kcal. Full label names, 14px value, 8px unit/label, minimum 8px font throughout.
  - Confidence bars (one thin bar per macro, coloured to match label)
  - Tap anywhere on card → opens `FoodItemEditSheet`
- **Sticky totals footer** — 2×2 grid: Total Carbs (blue, large) / Total Protein / Total Fat / Total kcal
- **"Confirm & Add to Meal"** — full-width primary button, pops `FoodScannerResult`

### FoodItemEditSheet (bottom sheet overlay on State 3)
Bottom sheet (draggable, 90% height). Displays:
- Current macro summary row at top (read-only colour-matched display)
- `TextFormField`s: Food Name, Portion Description, Weight (g), Carbs (g), Protein (g), Fat (g), Calories (kcal)
- "Save Changes" button — calls parent callback, sheet closes

### State 5 — Barcode Not Found
Centred icon + heading "Product not found" + scanned barcode string. Two recovery options as full-width buttons:
- "Take a Photo Instead" → transitions to source picker → photo flow
- Manual entry form: Food Name field + 2×2 macro grid (Carbs / Protein / Fat / kcal) + "Add to Meal" CTA

---

## Data Flow

```
User taps "Scan Food" in MealWizardView
  → MealWizardView._openFoodScanner() pushes FoodScannerView

Photo/Gallery path:
  ImagePicker → path → FoodScannerNotifier.analyseImage(path)
    → FoodAnalyzerRepository.analyzeImage(path)     [with SHA-256 cache + retry]
    → GeminiFoodAnalyzerImpl → Gemini API (via backend proxy)
    → FoodRagService.enrichWithLocalData(items)     [4-tier pipeline]
    → emits FoodScannerState.results(FoodAnalysisResult)

Barcode path:
  BarcodeScannerView pops barcode string
    → FoodScannerNotifier.lookupBarcode(code)
    → BackendFoodService → Open Food Facts (via backend proxy)
    ├── found → wraps as single-item FoodAnalysisResult → results state
    └── 404   → FoodScannerState.barcodeNotFound(code)

Edit item:
  User taps item → FoodItemEditSheet
    → on save: FoodScannerNotifier.updateItem(index, updated)
    → totals recomputed from all items

Confirm:
  "Confirm & Add to Meal"
    → Navigator.pop(FoodScannerResult(items, totals))
    → MealWizardView receives result, appends items
```

---

## Error Handling

| Failure | Recovery |
|---|---|
| Gemini API error / timeout | Toast "Analysis failed — try again". Remain on Analysing state, show retry button. |
| Gemini returns 0 items | Toast "Nothing recognised — try a clearer photo". Return to source picker. |
| Barcode lookup 404 | Transition to State 5 (not-found recovery). |
| Barcode lookup network error | Toast "Barcode lookup failed". Offer retry or manual entry. |
| Image picker cancelled | Silent — stay on source picker. |
| USDA / RAG tier timeout | Enrichment degrades gracefully; item keeps Gemini estimate, confidence score reflects lower tier. No crash. |

---

## MealWizardView Changes

The following is removed from `MealWizardView`:
- `_buildCameraArea()` and all embedded camera states
- `_showSourceSheet()` modal
- `_runAnalysis()` inline trigger
- `_openBarcodeScanner()` inline nav + result handling
- The 72×72 thumbnail widget
- The compressed non-editable items list

Replaced with:
```dart
// Simple CTA button
Widget _buildFoodScanButton() { ... }

// Push FoodScannerView and receive result
Future<void> _openFoodScanner() async {
  final result = await Navigator.push<FoodScannerResult>(
    context,
    MaterialPageRoute(builder: (_) => const FoodScannerView()),
  );
  if (result != null) {
    // append result.items to meal
  }
}
```

---

## Changes to Existing Files

| File | Change |
|---|---|
| `lib/src/domain/entities/food_analysis_result.dart` | Add `totalProtein`, `totalFat`, `confidenceScore` fields |
| `lib/src/data/repositories/gemini_food_analyzer_impl.dart` | Populate new fields when building `FoodAnalysisResult` |
| `lib/views/logging/meal_wizard_view.dart` | Remove embedded camera/analysis code; add `_buildFoodScanButton` + `_openFoodScanner` |
| `lib/services/food_rag_service.dart` | Emit progress events during enrichment tiers (for State 2 live status) |

---

## New Files Summary

| File | Purpose |
|---|---|
| `lib/src/domain/entities/food_scanner_result.dart` | Return type from FoodScannerView to MealWizardView |
| `lib/views/food_scanner/food_scanner_view.dart` | Main dedicated scanner screen (~400 lines) |
| `lib/views/food_scanner/food_item_edit_sheet.dart` | Per-item editing bottom sheet (~150 lines) |
| `lib/providers/food_scanner_provider.dart` | State notifier for FoodScannerView |

---

## Testing Strategy

**Unit — `FoodRagService`:** Each enrichment tier tested independently with mocked dependencies. Assert correct tier selected, enrichment applied, confidence score set correctly per tier.

**Unit — `FoodScannerNotifier`:** State transitions tested with mocked `FoodAnalyzerRepository` and `BackendFoodService`. States: idle → analysing → results → error → retry.

**Widget — `FoodScannerView`:** Render each of the 5 states with pumped state. Assert key widgets present (source buttons, progress indicators, item list, totals footer, CTA).

**Widget — `FoodItemEditSheet`:** Assert field values are bound to the passed `FoodItem`; edited values are reflected in callback result.

**Integration — regression test:** Full scan → confirm → `MealWizardView` receives result. Assert item count, totals, and that `weightG` is preserved on all returned `FoodItem`s. This is the specific field that was silently dropped in the previous implementation.

---

## Out of Scope

- Nutrition history charts or trend views
- Multi-meal batch scanning
- Custom food database management UI
- Offline Gemini fallback (existing behaviour unchanged)
