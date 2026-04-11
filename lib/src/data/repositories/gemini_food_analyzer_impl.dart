import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:injectable/injectable.dart';

import '../../../config/backend_config.dart';
import '../../../services/backend_food_service.dart';
import '../../../services/food_rag_service.dart';
import '../../domain/entities/food_analysis_result.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/repositories/food_analyzer_repository.dart';

// Re-export RateLimitException so callers that previously imported it from
// here continue to work without changes.
export '../../../services/backend_food_service.dart' show RateLimitException;

/// Analyses food images via the DiaMetrics backend (which proxies Gemini AI).
///
/// The GEMINI_API_KEY is stored in the backend's .env file only — it is
/// NEVER compiled into this APK.
///
/// Optimisations:
/// - SHA-256 hash-based in-memory cache (avoids re-uploading identical images)
/// - Retry with exponential backoff (handles flaky mobile connections)
/// - Local RAG enrichment after analysis (offline, no network)
@LazySingleton(as: FoodAnalyzerRepository)
class GeminiFoodAnalyzerImpl implements FoodAnalyzerRepository {
  // In-memory cache: SHA-256 hash of image bytes → enriched analysis result
  static final Map<String, FoodAnalysisResult> _cache = {};

  /// Maximum retry attempts for transient backend/network failures.
  static const int _maxRetries = 3;

  /// Analyses a food photo and returns identified items with nutritional data.
  ///
  /// Results are cached by image content hash. Identical images return
  /// instantly from cache without a backend round-trip.
  @override
  Future<FoodAnalysisResult> analyzeImage(String imagePath) async {
    if (!BackendConfig.isConfigured && !BackendConfig.isDirectGeminiEnabled) {
      throw Exception(
        'DiaMetrics backend not configured AND no test key provided.\n'
        'Build with:\n'
        '  flutter run \\\n'
        '    --dart-define=BACKEND_URL=http://10.0.2.2:8000 \\\n'
        '    --dart-define=BACKEND_API_KEY=your_secret\n'
        'OR for local testing without a backend:\n'
        '  flutter run --dart-define=GEMINI_API_KEY=your_gemini_key',
      );
    }

    // Compute SHA-256 hash for cache lookup
    final imageBytes = await BackendFoodService.readFileBytes(imagePath);
    final imageHash = sha256.convert(imageBytes).toString();
    final cached = _cache[imageHash];
    if (cached != null) {
      debugPrint('FoodAnalyzer: Cache hit for $imageHash');
      return cached;
    }

    // Use direct on-device Gemini evaluation if key is provided
    FoodAnalysisResult result;
    if (BackendConfig.isDirectGeminiEnabled) {
      result = await _analyzeImageLocally(imageBytes);
    } else {
      // Call backend (retries on transient failures, not on rate-limit errors)
      result = await _retryWithBackoff(
        () => BackendFoodService.analyzeImage(imagePath),
      );
    }

    // Post-Retrieval RAG Enrichment — runs entirely on-device, no network.
    // Overrides backend AI estimates with verified local database values.
    // Tier order: CustomFoods → USDA CSV → N5K → USDA API → AI fallback
    final enrichedItems = await FoodRagService.enrichWithLocalData(
      result.items,
    );

    double newTotalCarbs = 0;
    double newTotalCalories = 0;
    double newTotalProtein = 0;
    double newTotalFat = 0;
    for (final item in enrichedItems) {
      newTotalCarbs += item.carbsGrams;
      newTotalCalories += item.calories;
      newTotalProtein += item.proteinGrams;
      newTotalFat += item.fatGrams;
    }

    final enrichedResult = FoodAnalysisResult(
      items: enrichedItems,
      totalCarbs: newTotalCarbs,
      totalCalories: newTotalCalories,
      totalProtein: newTotalProtein,
      totalFat: newTotalFat,
      summary: result.summary,
      confidenceScore: _computeConfidence(enrichedItems),
    );

    // Cache the enriched result (limit to last 20 to prevent memory bloat)
    _cache[imageHash] = enrichedResult;
    if (_cache.length > 20) {
      _cache.remove(_cache.keys.first);
    }

    return enrichedResult;
  }



  /// Retries [action] up to [_maxRetries] times with exponential backoff.
  ///
  /// Backoff delays: 1s, 2s, 4s.
  /// Rate limit errors ([RateLimitException]) are never retried.
  Future<T> _retryWithBackoff<T>(Future<T> Function() action) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        return await action();
      } catch (e) {
        if (e is RateLimitException) rethrow;
        if (attempt == _maxRetries - 1) rethrow;
        final delay = Duration(seconds: 1 << attempt); // 1s, 2s, 4s
        debugPrint(
          'FoodAnalyzer: Attempt ${attempt + 1} failed, '
          'retrying in ${delay.inSeconds}s...',
        );
        await Future.delayed(delay);
      }
    }
    throw StateError('Retry loop exited unexpectedly');
  }

  /// Clears the in-memory analysis cache.
  void clearCache() => _cache.clear();

  /// Computes an average confidence score across all items based on their
  /// data source tier. Higher tier = more reliable = higher score (0.0–1.0).
  Map<String, double> _computeConfidence(List<FoodItem> items) {
    if (items.isEmpty) return {};
    const sourceTiers = <String, double>{
      'Custom Food DB': 1.0,
      'USDA+N5K': 0.9,
      'USDA API': 0.9,
      'Open Food Facts': 0.9,
      'N5K': 0.85,
      'Local DB': 0.8,
      'AI Estimate': 0.4,
    };
    double total = 0;
    for (final item in items) {
      total += sourceTiers[item.source] ?? 0.4;
    }
    final avg = (total / items.length).clamp(0.0, 1.0);
    return {'carbs': avg, 'protein': avg, 'fat': avg, 'calories': avg};
  }

  Future<FoodAnalysisResult> _analyzeImageLocally(List<int> imageBytes) async {
    // Load the system prompt from assets (editable without a rebuild)
    final systemPrompt = await rootBundle.loadString(
      'assets/prompts/food_analysis.txt',
    );

    // Build the response schema — enforces valid JSON, no markdown stripping needed
    final schema = Schema.object(
      properties: {
        'items': Schema.array(
          items: Schema.object(
            properties: {
              'name': Schema.string(),
              'weight_g': Schema.number(),
              'carbs_g': Schema.number(),
              'protein_g': Schema.number(),
              'fat_g': Schema.number(),
              'calories': Schema.number(),
            },
            requiredProperties: [
              'name', 'weight_g', 'carbs_g', 'protein_g', 'fat_g', 'calories',
            ],
          ),
        ),
        'totalCarbs': Schema.number(),
        'totalCalories': Schema.number(),
        'summary': Schema.string(),
      },
      requiredProperties: ['items', 'totalCarbs', 'totalCalories', 'summary'],
    );

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: BackendConfig.geminiApiKey,
      systemInstruction: Content.system(systemPrompt),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    final imagePart = DataPart('image/jpeg', Uint8List.fromList(imageBytes));
    final response = await model.generateContent([
      Content.multi([imagePart]),
    ]);

    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    try {
      final decoded = jsonDecode(text) as Map<String, dynamic>;
      return FoodAnalysisResult.fromJson(decoded);
    } catch (e) {
      debugPrint('FoodAnalyzer: JSON parse error — $e\nRaw: $text');
      throw Exception('Failed to parse AI response. Please try again.');
    }
  }
}
