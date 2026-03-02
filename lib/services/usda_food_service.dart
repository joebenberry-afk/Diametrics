import 'package:flutter/foundation.dart';

import 'backend_food_service.dart';

/// Queries USDA FoodData Central for full macro data by food name.
///
/// Used as Tier 3 in the RAG enrichment pipeline (after local CSV misses).
///
/// All actual HTTP communication is handled by [BackendFoodService].
/// The USDA API key is stored in the backend's .env — never in this APK.
class UsdaFoodService {
  // Nutrient IDs in the USDA FoodData Central schema (kept for documentation)
  static const _carbId = 1005;      // Carbohydrate, by difference
  static const _proteinId = 1003;   // Protein
  static const _fatId = 1004;       // Total lipid (fat)
  static const _calorieId = 1008;   // Energy (kcal)

  // Suppress unused-field warnings — kept for schema documentation only
  // ignore: unused_field
  static const _unusedNutrientIds = [_carbId, _proteinId, _fatId, _calorieId];

  /// Searches USDA for [query] and returns per-100g macro values, or null.
  ///
  /// Returns: Map with keys 'carbs', 'protein', 'fat', 'calories' (all per 100g).
  /// Returns null on network failure or no results (graceful degradation).
  static Future<Map<String, double>?> search(String query) async {
    final result = await BackendFoodService.usdaSearch(query);
    if (result != null) {
      debugPrint(
        'USDA (via backend): "$query" → '
        '${result['carbs']!.toStringAsFixed(1)}g carbs, '
        '${result['protein']!.toStringAsFixed(1)}g protein, '
        '${result['fat']!.toStringAsFixed(1)}g fat per 100g',
      );
    } else {
      debugPrint('USDA (via backend): no result for "$query"');
    }
    return result;
  }
}
