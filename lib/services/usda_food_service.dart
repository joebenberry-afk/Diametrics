import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Queries the USDA FoodData Central API for full macro data by food name.
///
/// Used as Tier 3 in the RAG enrichment pipeline (after local CSV misses).
/// DEMO_KEY: 30 requests/hour — sufficient for enrichment use.
/// Register free at https://api.nal.usda.gov to get a personal key.
class UsdaFoodService {
  static const _baseUrl = 'https://api.nal.usda.gov/fdc/v1/foods/search';
  static const _timeout = Duration(seconds: 8);

  // Nutrient IDs in the USDA FoodData Central schema
  static const _carbId = 1005;      // Carbohydrate, by difference
  static const _proteinId = 1003;   // Protein
  static const _fatId = 1004;       // Total lipid (fat)
  static const _calorieId = 1008;   // Energy (kcal)

  // USDA API key — override with --dart-define=USDA_API_KEY=your_key
  static const _apiKey = String.fromEnvironment(
    'USDA_API_KEY',
    defaultValue: 'DEMO_KEY',
  );

  /// Searches USDA for [query] and returns per-100g macro values, or null.
  ///
  /// Returns: Map with keys 'carbs', 'protein', 'fat', 'calories' (all per 100g).
  /// Returns null on network failure or no results (graceful degradation).
  static Future<Map<String, double>?> search(String query) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'query': query,
      'api_key': _apiKey,
      'dataType': 'SR Legacy,Survey (FNDDS)',
      'pageSize': '3',
    });

    try {
      final response = await http.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final foods = json['foods'] as List<dynamic>?;
      if (foods == null || foods.isEmpty) return null;

      // Use the first result
      final food = foods.first as Map<String, dynamic>;
      final nutrients = food['foodNutrients'] as List<dynamic>? ?? [];

      double carbs = 0, protein = 0, fat = 0, calories = 0;
      for (final n in nutrients) {
        final nutrient = n as Map<String, dynamic>;
        final id = nutrient['nutrientId'] as int? ?? 0;
        final value = (nutrient['value'] as num?)?.toDouble() ?? 0.0;
        if (id == _carbId) carbs = value;
        if (id == _proteinId) protein = value;
        if (id == _fatId) fat = value;
        if (id == _calorieId) calories = value;
      }

      if (carbs == 0 && protein == 0 && fat == 0) return null;

      debugPrint(
        'USDA: "$query" → ${carbs.toStringAsFixed(1)}g carbs, '
        '${protein.toStringAsFixed(1)}g protein, '
        '${fat.toStringAsFixed(1)}g fat per 100g',
      );

      return {
        'carbs': carbs.clamp(0.0, 100.0),
        'protein': protein.clamp(0.0, 100.0),
        'fat': fat.clamp(0.0, 100.0),
        'calories': calories.clamp(0.0, 900.0),
      };
    } catch (e) {
      // Graceful fail: USDA API is optional enhancement
      debugPrint('USDA API skipped (offline or error): $e');
      return null;
    }
  }
}
