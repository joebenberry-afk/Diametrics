import 'package:flutter/foundation.dart';
import '../database/db_instance.dart';
import '../src/domain/entities/food_item.dart';
import 'usda_food_service.dart';

/// Augments the AI food analysis results with verified local and online data.
///
/// Enrichment tier order (highest priority first):
///   1. CustomFoods DB   — user-defined overrides
///   2. LocalFoods CSV   — 7,803 USDA items, carbs only
///   2.5 N5K Ingredients — 555 Google Research items, full per-gram macros (offline)
///   3. USDA API         — live lookup, full macros (internet required, graceful fail)
///   4. AI Estimate      — Gemini original (fallback if all above miss)
///
/// Also applies portion-quantity scaling: if Gemini says "6 doubles",
/// the enriched values are multiplied by 6.
class FoodRagService {
  /// Enriches a list of AI-generated [FoodItem]s with verified nutrition data.
  static Future<List<FoodItem>> enrichWithLocalData(
    List<FoodItem> items,
  ) async {
    final enrichedItems = <FoodItem>[];

    for (final item in items) {
      if (item.name.toLowerCase() == 'unknown') {
        enrichedItems.add(item);
        continue;
      }

      final qty = _extractQuantity(item.portion);
      final searchName = _extractFoodName(item.portion, item.name);

      debugPrint('RAG: enriching "${item.name}" qty=$qty search="$searchName"');

      // Tier 1: Custom Foods (user overrides)
      final customMatch = await db.searchCustomFood(searchName);
      if (customMatch != null) {
        debugPrint('RAG: Tier1 CustomFood -> ${customMatch.userDefinedName}');
        enrichedItems.add(FoodItem(
          name: item.name,
          portion: item.portion,
          carbsGrams: (customMatch.carbsPerServing * qty).clamp(0.0, 500.0),
          proteinGrams: (item.proteinGrams * qty).clamp(0.0, 300.0),
          fatGrams: (item.fatGrams * qty).clamp(0.0, 300.0),
          calories: (item.calories * qty).clamp(0.0, 3000.0),
          source: 'Custom Food DB',
        ));
        continue;
      }

      // Tier 2: Local USDA CSV (carbs) + N5K (full macros if match)
      final localMatch = await db.searchLocalFood(searchName);
      if (localMatch != null) {
        debugPrint('RAG: Tier2 LocalFood -> ${localMatch.name}');
        final n5k = await db.searchN5kIngredient(searchName);
        if (n5k != null && n5k.carbPerG > 0) {
          final servingG = (localMatch.carbsPerServing / n5k.carbPerG).clamp(10.0, 600.0);
          enrichedItems.add(FoodItem(
            name: item.name,
            portion: item.portion,
            carbsGrams: (localMatch.carbsPerServing * qty).clamp(0.0, 500.0),
            proteinGrams: (n5k.proteinPerG * servingG * qty).clamp(0.0, 300.0),
            fatGrams: (n5k.fatPerG * servingG * qty).clamp(0.0, 300.0),
            calories: (n5k.calPerG * servingG * qty).clamp(0.0, 3000.0),
            source: 'USDA+N5K',
          ));
          continue;
        }
        enrichedItems.add(FoodItem(
          name: item.name,
          portion: item.portion,
          carbsGrams: (localMatch.carbsPerServing * qty).clamp(0.0, 500.0),
          proteinGrams: (item.proteinGrams * qty).clamp(0.0, 300.0),
          fatGrams: (item.fatGrams * qty).clamp(0.0, 300.0),
          calories: (item.calories * qty).clamp(0.0, 3000.0),
          source: 'Local DB',
        ));
        continue;
      }

      // Tier 2.5: N5K only (offline, full macros)
      final n5kOnly = await db.searchN5kIngredient(searchName);
      if (n5kOnly != null) {
        debugPrint('RAG: Tier2.5 N5K -> ${n5kOnly.name}');
        final servingG = (item.carbsGrams > 0 && n5kOnly.carbPerG > 0)
            ? (item.carbsGrams / n5kOnly.carbPerG).clamp(10.0, 600.0)
            : 100.0;
        enrichedItems.add(FoodItem(
          name: item.name,
          portion: item.portion,
          carbsGrams: (n5kOnly.carbPerG * servingG * qty).clamp(0.0, 500.0),
          proteinGrams: (n5kOnly.proteinPerG * servingG * qty).clamp(0.0, 300.0),
          fatGrams: (n5kOnly.fatPerG * servingG * qty).clamp(0.0, 300.0),
          calories: (n5kOnly.calPerG * servingG * qty).clamp(0.0, 3000.0),
          source: 'N5K',
        ));
        continue;
      }

      // Tier 3: USDA API (internet, full macros)
      final usdaData = await UsdaFoodService.search(searchName);
      if (usdaData != null) {
        debugPrint('RAG: Tier3 USDA API for "$searchName"');
        final carbs100 = usdaData['carbs']!;
        final scale = (item.carbsGrams > 0 && carbs100 > 0)
            ? (item.carbsGrams / carbs100).clamp(0.1, 6.0)
            : 1.0;
        enrichedItems.add(FoodItem(
          name: item.name,
          portion: item.portion,
          carbsGrams: (carbs100 * scale * qty).clamp(0.0, 500.0),
          proteinGrams: (usdaData['protein']! * scale * qty).clamp(0.0, 300.0),
          fatGrams: (usdaData['fat']! * scale * qty).clamp(0.0, 300.0),
          calories: (usdaData['calories']! * scale * qty).clamp(0.0, 3000.0),
          source: 'USDA API',
        ));
        continue;
      }

      // Tier 4: AI Estimate (quantity-scaled fallback)
      debugPrint('RAG: Tier4 AI fallback for "${item.name}"');
      enrichedItems.add(item.withFullNutrition(
        carbsGrams: (item.carbsGrams * qty).clamp(0.0, 500.0),
        proteinGrams: (item.proteinGrams * qty).clamp(0.0, 300.0),
        fatGrams: (item.fatGrams * qty).clamp(0.0, 300.0),
        calories: (item.calories * qty).clamp(0.0, 3000.0),
        sourceName: item.source,
      ));
    }

    return enrichedItems;
  }

  // ── Portion parsing helpers ──────────────────────────────────────────────

  /// Extracts a numeric quantity from a portion string.
  /// "6 doubles" -> 6.0,  "2 cups" -> 2.0,  "1/2 cup" -> 0.5
  static double _extractQuantity(String portion) {
    final t = portion.trim();
    final frac = RegExp(r'^(\d+)/(\d+)').firstMatch(t);
    if (frac != null) {
      final n = double.tryParse(frac.group(1)!) ?? 1;
      final d = double.tryParse(frac.group(2)!) ?? 1;
      return d > 0 ? (n / d).clamp(0.25, 20.0) : 1.0;
    }
    final num = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(t);
    if (num != null) {
      return (double.tryParse(num.group(1)!) ?? 1.0).clamp(0.25, 20.0);
    }
    return 1.0;
  }

  /// Strips leading quantity from the portion string and returns the food name.
  /// Falls back to [itemName] if only a unit word remains.
  static String _extractFoodName(String portion, String itemName) {
    final stripped = portion.trim()
        .replaceFirst(RegExp(r'^\d+/\d+\s*'), '')
        .replaceFirst(RegExp(r'^\d+(?:\.\d+)?\s*'), '')
        .trim()
        .toLowerCase();

    const unitWords = {
      'cup', 'cups', 'piece', 'pieces', 'serving', 'servings',
      'slice', 'slices', 'bowl', 'plate', 'portion', 'oz', 'g', 'ml',
    };

    if (stripped.isEmpty ||
        unitWords.contains(stripped.split(' ').first)) {
      return itemName;
    }
    return stripped;
  }
}
