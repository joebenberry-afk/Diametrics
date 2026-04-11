# Food Scanner Theme Unification

**Date:** 2026-04-11  
**Status:** Approved

## Goal

Make the Food Scanner UI visually consistent with the rest of the DiaMetrics app by replacing all hardcoded colour literals in `food_scanner_view.dart` and `food_item_edit_sheet.dart` with values from `AppThemeTokens` and `Theme.of(context).colorScheme`. No structural or behavioural changes.

## Scope

| File | Change |
|---|---|
| `lib/views/food_scanner/food_scanner_view.dart` | Replace all hardcoded colours; remove AppBar overrides; update button/sheet styles |
| `lib/views/food_scanner/food_item_edit_sheet.dart` | Replace all hardcoded colours; update button and input decoration styles |

No other files change.

## Colour Mapping

Every `Color(0xFF…)` literal is replaced as follows:

| Hardcoded hex | Role | Replacement |
|---|---|---|
| `0xFF0D0F1A` | Scaffold background | Removed — theme `scaffoldBackgroundColor` applies |
| `0xFF13151f` | Card / surface background | `colorScheme.surface` |
| `0xFF1a1d27` | Input field fill | `isDark ? AppThemeTokens.bgBackgroundDark : AppThemeTokens.bgBackground` |
| `0xFF4a9eff` | Primary accent (buttons, focus, carbs) | `colorScheme.primary` |
| `0xFFc8cfe0` | Primary text | `colorScheme.onSurface` |
| `0xFF8892aa` | Secondary text / muted icons | `colorScheme.onSurface.withValues(alpha: 0.6)` |
| `0xFF2a2d3a` | Border / outline | `isDark ? AppThemeTokens.brandSecondary.withValues(alpha: 0.3) : const Color(0xFFD1D5DB)` |
| `0xFF1e2130` | Subtle border (macro cell dividers) | Same as above |
| `0xFFef5350` | Error icon | `colorScheme.error` |

`isDark` is derived once per `build` method: `final isDark = Theme.of(context).brightness == Brightness.dark;`

## Structural Changes

### AppBar (`food_scanner_view.dart`)
- Remove `backgroundColor`, `foregroundColor`, and the inline `TextStyle` colour on the title — the theme's `appBarTheme` handles all of these.
- Remove inline colour on the "Start Over" `TextButton` child — replace with `colorScheme.onSurface.withValues(alpha: 0.6)`.

### Bottom sheet (`_openEditSheet`)
- `backgroundColor: const Color(0xFF13151f)` → `backgroundColor: Theme.of(context).colorScheme.surface`
- `BorderRadius.vertical(top: Radius.circular(20))` → `BorderRadius.vertical(top: Radius.circular(AppThemeTokens.radiusLg))` (24 px)

### FilledButton (both files)
- Remove `backgroundColor: const Color(0xFF4a9eff)` — `FilledButton` defaults to `colorScheme.primary`.
- `BorderRadius.circular(10)` → `BorderRadius.circular(AppThemeTokens.radiusMd)` (12 px)

### OutlinedButton (`food_scanner_view.dart`)
- Remove `foregroundColor: const Color(0xFFc8cfe0)` — defaults to `colorScheme.onSurface`.
- `side: const BorderSide(color: Color(0xFF2a2d3a))` → `side: BorderSide(color: borderColor)` where `borderColor` is the mapped border value above.
- `BorderRadius.circular(10)` → `BorderRadius.circular(AppThemeTokens.radiusMd)`

### CircularProgressIndicator
- `color: const Color(0xFF4a9eff)` → `color: colorScheme.primary`

### Input decoration (`_buildManualEntryForm` and `_EditField`)
- `fillColor` → mapped input fill value
- `enabledBorder` colour → mapped border value
- `focusedBorder` colour → `colorScheme.primary`
- `labelStyle` colour → `colorScheme.onSurface.withValues(alpha: 0.6)`

### _SourceButton
- `Material` colour → `colorScheme.surface`
- Icon colour → `colorScheme.primary`
- Label colour → `colorScheme.onSurface`
- Chevron colour → `colorScheme.onSurface.withValues(alpha: 0.6)`

### _FoodItemCard
- Container colour → `colorScheme.surface`
- Border colour → mapped border value
- Name text → `colorScheme.onSurface`
- Portion text → `colorScheme.onSurface.withValues(alpha: 0.6)`
- Edit pencil icon → `colorScheme.onSurface.withValues(alpha: 0.6)`

### _MacroInlineCell / _TotalCell / _MacroCell
- Carbs colour → `colorScheme.primary`
- Non-carbs value colour → `colorScheme.onSurface`
- Label colour for carbs → `colorScheme.primary`
- Label colour for others → `colorScheme.onSurface.withValues(alpha: 0.6)`
- Divider border colour → mapped border value

### _SourceBadge
- Background → `isDark ? AppThemeTokens.bgBackgroundDark : AppThemeTokens.bgBackground`
- Border → mapped border value
- Text → `colorScheme.onSurface.withValues(alpha: 0.6)`

### _MacroSummaryRow (`food_item_edit_sheet.dart`)
- Container colour → `colorScheme.surface`
- Pass `isCarbs: true` for the Carbs cell, `false` for all others (see `_MacroCell` change below)

### _MacroCell (`food_item_edit_sheet.dart`)
- Replace `final Color color` parameter with `final bool isCarbs`
- Value colour → `isCarbs ? colorScheme.primary : colorScheme.onSurface`
- Label colour → `isCarbs ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.6)`
- Remove the `color == const Color(0xFF4a9eff)` equality check entirely

## What Does NOT Change

- Widget tree structure
- State machine / viewmodel logic
- Font sizes and weights
- Spacing values
- Lucide icon choices
- `DraggableScrollableSheet` sizes
- Any test files
