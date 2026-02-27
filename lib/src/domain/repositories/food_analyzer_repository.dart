import '../entities/food_analysis_result.dart';

/// Abstract repository defining the contract for AI/Network food analysis.
/// This allows us to swap out Gemini for another API without modifying UI logic.
abstract class FoodAnalyzerRepository {
  /// Analyzes a food photo and returns identified items with nutritional data.
  Future<FoodAnalysisResult> analyzeImage(String imagePath);

  /// Performs unstructured text RAG analysis via the AI.
  Future<FoodAnalysisResult> analyzeText(String userQuery);
}
