import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../src/domain/entities/food_item.dart';

/// Looks up packaged food nutrition by barcode using the Open Food Facts API.
/// No API key required — completely free and open source.
class OpenFoodFactsService {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';
  static const _timeout = Duration(seconds: 10);

  /// Returns a [FoodItem] from the Open Food Facts database for the given
  /// [barcode] (EAN-13, UPC-A, etc.).
  ///
  /// Returns `null` if the product is not found or parsing fails.
  /// Throws a descriptive [Exception] on network errors.
  static Future<FoodItem?> lookup(String barcode) async {
    final uri = Uri.parse('$_baseUrl/$barcode.json');

    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final status = json['status'];
        if (status == 0 || json['product'] == null) {
          debugPrint('OpenFoodFacts: product $barcode not found');
          return null;
        }
        return _parse(json['product'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Open Food Facts error ${response.statusCode}');
      }
    } on Exception catch (e) {
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException')) {
        throw Exception(
          'Unable to reach Open Food Facts — check your connection.',
        );
      }
      rethrow;
    }
  }

  static FoodItem? _parse(Map<String, dynamic> product) {
    final name = (product['product_name'] as String?)?.trim() ?? '';
    if (name.isEmpty) return null;

    final servingSize = (product['serving_size'] as String?) ?? '1 serving';
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    // Prefer per-serving values; fall back to per-100g
    double carbs = _nutrimentValue(nutriments, 'carbohydrates');
    double protein = _nutrimentValue(nutriments, 'proteins');
    double fat = _nutrimentValue(nutriments, 'fat');
    double calories = _nutrimentValue(nutriments, 'energy-kcal');

    // If per-serving values are zero, try 100g values and scale by serving size
    if (carbs == 0 && protein == 0 && fat == 0) {
      final carbs100 = _nutrimentValue(nutriments, 'carbohydrates_100g');
      final protein100 = _nutrimentValue(nutriments, 'proteins_100g');
      final fat100 = _nutrimentValue(nutriments, 'fat_100g');
      final cal100 = _nutrimentValue(nutriments, 'energy-kcal_100g');
      final grams = _parseServingGrams(servingSize);
      final scale = grams / 100.0;
      if (scale > 0) {
        carbs = carbs100 * scale;
        protein = protein100 * scale;
        fat = fat100 * scale;
        calories = cal100 * scale;
      } else {
        carbs = carbs100;
        protein = protein100;
        fat = fat100;
        calories = cal100;
      }
    }

    // Safety clamp (UI defense)
    return FoodItem(
      name: name,
      portion: servingSize,
      carbsGrams: carbs.clamp(0.0, 500.0),
      proteinGrams: protein.clamp(0.0, 300.0),
      fatGrams: fat.clamp(0.0, 300.0),
      calories: calories.clamp(0.0, 3000.0),
      source: 'Open Food Facts',
    );
  }

  static double _nutrimentValue(Map<String, dynamic> n, String key) {
    final v = n[key] ?? n['${key}_serving'] ?? 0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  /// Tries to extract grams from a serving size string like "28g" or "1 oz (28g)".
  static double _parseServingGrams(String serving) {
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*g').firstMatch(serving);
    if (match != null) return double.tryParse(match.group(1)!) ?? 0.0;
    return 0.0;
  }
}
