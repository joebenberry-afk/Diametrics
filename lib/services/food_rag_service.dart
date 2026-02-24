import 'package:flutter/foundation.dart';
import '../database/db_instance.dart';
import 'food_analyzer.dart';

/// Augments the AI food analysis results with verified local database data.
/// This acts as a post-retrieval RAG (Retrieval-Augmented Generation) layer
/// without needing extra API calls.
class FoodRagService {
  /// Enriches a list of AI-generated FoodItems with verified local data.
  static Future<List<FoodItem>> enrichWithLocalData(
    List<FoodItem> items,
  ) async {
    final enrichedItems = <FoodItem>[];

    for (final item in items) {
      if (item.name.toLowerCase() == 'unknown') {
        enrichedItems.add(item);
        continue;
      }

      // Try custom foods first (user preferences override defaults)
      var customMatch = await db.searchCustomFood(item.name);
      if (customMatch != null) {
        debugPrint(
          'RAG: Found CustomFood match for "${item.name}" -> ${customMatch.userDefinedName}',
        );
        enrichedItems.add(
          _createEnrichedItem(
            item,
            customMatch.userDefinedName,
            customMatch.carbsPerServing,
            'Custom Food DB',
          ),
        );
        continue;
      }

      // Fallback to the massive local foods CSV database
      var localMatch = await db.searchLocalFood(item.name);
      if (localMatch != null) {
        debugPrint(
          'RAG: Found LocalFood match for "${item.name}" -> ${localMatch.name}',
        );
        enrichedItems.add(
          _createEnrichedItem(
            item,
            localMatch.name,
            localMatch.carbsPerServing,
            'Local DB',
          ),
        );
        continue;
      }

      // No match found, keep AI estimate
      enrichedItems.add(item);
    }

    return enrichedItems;
  }

  /// Helper to merge AI portion/calorie estimates with verified DB carb data.
  ///
  /// Note: Our DB only stores raw carbs per 100g or per serving.
  /// A true production system would also cross-reference portion scaling,
  /// but for this implementation we assume the DB value overrides the AI carb estimate.
  static FoodItem _createEnrichedItem(
    FoodItem originalAIItem,
    String dbName,
    double dbCarbs,
    String newSource,
  ) {
    // We keep the AI's portion string, calories, protein and fat,
    // but override the carbs with the verified DB value.
    return FoodItem(
      name: originalAIItem.name, // Keep the original name for UI consistency
      portion: originalAIItem.portion,
      carbsGrams: dbCarbs,
      calories: originalAIItem.calories,
      proteinGrams: originalAIItem.proteinGrams,
      fatGrams: originalAIItem.fatGrams,
      source: newSource,
    );
  }
}
