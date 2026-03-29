import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:injectable/injectable.dart';

import '../../../config/backend_config.dart';
import '../../../services/backend_food_service.dart';
import '../../../services/food_rag_service.dart';
import '../../domain/entities/food_analysis_result.dart';
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
    for (final item in enrichedItems) {
      newTotalCarbs += item.carbsGrams;
      newTotalCalories += item.calories;
    }

    final enrichedResult = FoodAnalysisResult(
      items: enrichedItems,
      totalCarbs: newTotalCarbs,
      totalCalories: newTotalCalories,
      summary: result.summary,
    );

    // Cache the enriched result (limit to last 20 to prevent memory bloat)
    _cache[imageHash] = enrichedResult;
    if (_cache.length > 20) {
      _cache.remove(_cache.keys.first);
    }

    return enrichedResult;
  }

  @override
  Future<FoodAnalysisResult> analyzeText(String userQuery) async {
    throw UnimplementedError(
      'analyzeText not yet supported on Gemini implementation',
    );
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

  Future<FoodAnalysisResult> _analyzeImageLocally(List<int> imageBytes) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: BackendConfig.geminiApiKey,
    );
    
    final prompt = TextPart(
      'You are a clinical dietitian AI. Analyze this food image. '
      'Identify all food items on the plate, their approximate portions, and estimate macronutrients. '
      'Reply ONLY with a JSON object. NO markdown delimiters at the start or end, just raw JSON. Schema:\n'
      '{"items": [{"name": "string", "portion": "string", "carbs_g": number, "calories": number, "protein_g": number, "fat_g": number, "source": "AI Estimate"}], '
      '"totalCarbs": number, "totalCalories": number, "summary": "string"}'
    );
    final imagePart = DataPart('image/jpeg', Uint8List.fromList(imageBytes));

    final response = await model.generateContent([
      Content.multi([prompt, imagePart])
    ]);

    final text = response.text;
    if (text == null) {
      throw Exception('Gemini returned an empty response.');
    }

    // Clean JSON (in case Gemini included markdown blocks)
    final cleanJson = text.replaceAll(RegExp(r'^```json\n?', multiLine: true), '').replaceAll(RegExp(r'\n?```$', multiLine: true), '').trim();
    
    try {
      final decoded = jsonDecode(cleanJson) as Map<String, dynamic>;
      return FoodAnalysisResult.fromJson(decoded);
    } catch (e) {
      debugPrint('Error parsing Gemini JSON: $e\nResponse: $text');
      throw Exception('Failed to parse AI JSON response.');
    }
  }
}
