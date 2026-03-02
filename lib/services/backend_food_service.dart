// =============================================================================
// SECURITY BOUNDARY — READ BEFORE MODIFYING THIS FILE
// =============================================================================
// This is the ONLY place in Flutter that makes HTTP calls to the backend.
//
// ALLOWED to send to the backend (non-PII food data only):
//   ✅  Food image bytes (base64) — a photo of a plate or food package.
//         Contains NO glucose readings, no personal identifiers.
//   ✅  Food name strings — e.g., "chicken breast", "rice".
//         Generic food names only, no patient context.
//   ✅  Barcode strings — EAN-13 / UPC-A product codes.
//         Not personal.
//
// NEVER send to the backend:
//   ❌  Glucose readings or glucose log records
//   ❌  Medication doses or medication log records
//   ❌  Meal log records (timestamp, carbs logged, etc.)
//   ❌  User profile data (name, age, weight, diabetes type)
//   ❌  Any data from DatabaseHelper, UserRepository, or HealthDataRepository
//   ❌  Hovorka projection inputs/outputs (calculated entirely on-device)
//
// The PII boundary is:  Device SQLite  ←→  [this service]  ←→  Backend
// Nothing from the left side may cross to the right side.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/backend_config.dart';
import '../src/domain/entities/food_analysis_result.dart';
import '../src/domain/entities/food_item.dart';

/// Thrown when the Gemini API rate limit is hit (HTTP 429).
/// Callers should surface this to the user and NOT retry automatically.
class RateLimitException implements Exception {
  final String message;
  const RateLimitException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the backend server cannot be reached (offline or not running).
class BackendUnavailableException implements Exception {
  final String message;
  const BackendUnavailableException(this.message);

  @override
  String toString() => message;
}

/// Single HTTP client for all communication with the DiaMetrics backend.
///
/// All third-party API keys (Gemini, USDA) are stored server-side in .env.
/// This Flutter class never contains or transmits those keys.
class BackendFoodService {
  static const _analyzeTimeout = Duration(seconds: 40);
  static const _searchTimeout = Duration(seconds: 12);

  // ---------------------------------------------------------------------------
  // 1. Food image analysis (Gemini proxy)
  // ---------------------------------------------------------------------------

  /// Sends a food image to the backend for Gemini AI analysis.
  ///
  /// [imagePath] — path to a local JPEG/PNG file (meal photo).
  ///   Only the image bytes are sent — no patient health data.
  ///
  /// Returns a [FoodAnalysisResult] on success.
  /// Throws [RateLimitException] on HTTP 429.
  /// Throws [BackendUnavailableException] on network failure.
  static Future<FoodAnalysisResult> analyzeImage(String imagePath) async {
    if (!BackendConfig.isConfigured) {
      throw BackendUnavailableException(
        'Backend not configured. '
        'Build with: flutter run '
        '--dart-define=BACKEND_URL=http://10.0.2.2:8000 '
        '--dart-define=BACKEND_API_KEY=your_secret',
      );
    }

    final imageBytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final ext = imagePath.toLowerCase().split('.').last;
    final mimeType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final requestBody = jsonEncode({
      'image_base64': base64Image,
      'mime_type': mimeType,
    });

    try {
      final response = await http
          .post(
            Uri.parse(BackendConfig.analyzeImageEndpoint),
            headers: BackendConfig.authHeaders,
            body: requestBody,
          )
          .timeout(_analyzeTimeout);

      if (response.statusCode == 429) {
        throw RateLimitException(
          'API rate limit reached. Please wait a minute and try again.',
        );
      }

      if (response.statusCode == 401) {
        throw BackendUnavailableException(
          'Backend API key is incorrect. Check your --dart-define=BACKEND_API_KEY value.',
        );
      }

      if (response.statusCode != 200) {
        throw BackendUnavailableException(
          'Backend error (${response.statusCode}). Please try again.',
        );
      }

      return _parseFoodAnalysisResponse(response.body);
    } on RateLimitException {
      rethrow;
    } on BackendUnavailableException {
      rethrow;
    } on Exception catch (e) {
      debugPrint('BackendFoodService.analyzeImage error: $e');
      throw BackendUnavailableException(
        'Unable to reach the food analysis service. Check your connection.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 2. USDA food search (Tier 3 RAG enrichment)
  // ---------------------------------------------------------------------------

  /// Searches USDA FoodData Central via the backend for per-100g macros.
  ///
  /// [foodName] — generic food name (e.g., "chicken breast").
  ///   Never include patient context in this string.
  ///
  /// Returns a map with keys 'carbs', 'protein', 'fat', 'calories' (per 100g),
  /// or null on miss or network failure (graceful degradation).
  static Future<Map<String, double>?> usdaSearch(String foodName) async {
    if (!BackendConfig.isConfigured) return null;

    final uri = Uri.parse(BackendConfig.usdaSearchEndpoint)
        .replace(queryParameters: {'query': foodName});

    try {
      final response = await http
          .get(uri, headers: BackendConfig.authHeaders)
          .timeout(_searchTimeout);

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['found'] != true) return null;

      return {
        'carbs': (json['carbs'] as num).toDouble(),
        'protein': (json['protein'] as num).toDouble(),
        'fat': (json['fat'] as num).toDouble(),
        'calories': (json['calories'] as num).toDouble(),
      };
    } catch (e) {
      // Graceful fail — USDA is optional Tier 3 enrichment
      debugPrint('BackendFoodService.usdaSearch skipped: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Barcode lookup (Open Food Facts proxy)
  // ---------------------------------------------------------------------------

  /// Looks up a food product by barcode via the backend (proxied to Open Food Facts).
  ///
  /// [barcode] — EAN-13 or UPC-A barcode string.
  ///   Not personally identifiable.
  ///
  /// Returns a [FoodItem] on success, null if not found.
  /// Throws [BackendUnavailableException] on network errors.
  static Future<FoodItem?> barcodeLookup(String barcode) async {
    if (!BackendConfig.isConfigured) {
      throw BackendUnavailableException(
        'Backend not configured. '
        'Build with: flutter run '
        '--dart-define=BACKEND_URL=... '
        '--dart-define=BACKEND_API_KEY=...',
      );
    }

    final uri = Uri.parse(BackendConfig.barcodeEndpoint(barcode));

    try {
      final response = await http
          .get(uri, headers: BackendConfig.authHeaders)
          .timeout(_searchTimeout);

      if (response.statusCode == 404) return null;

      if (response.statusCode == 401) {
        throw BackendUnavailableException(
          'Backend API key is incorrect. Check your --dart-define=BACKEND_API_KEY value.',
        );
      }

      if (response.statusCode != 200) {
        throw BackendUnavailableException(
          'Backend error (${response.statusCode}). Please try again.',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['found'] != true) return null;

      // The backend returns snake_case keys matching FoodItem's @JsonKey annotations
      return FoodItem.fromJson({
        'name': json['name'],
        'portion': json['portion'] ?? '1 serving',
        'carbs_g': json['carbs_g'] ?? 0.0,
        'calories': json['calories'] ?? 0.0,
        'protein_g': json['protein_g'] ?? 0.0,
        'fat_g': json['fat_g'] ?? 0.0,
        'source': json['source'] ?? 'Open Food Facts',
      });
    } on BackendUnavailableException {
      rethrow;
    } on Exception catch (e) {
      debugPrint('BackendFoodService.barcodeLookup error: $e');
      throw BackendUnavailableException(
        'Unable to reach Open Food Facts — check your connection.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // File utility (used by GeminiFoodAnalyzerImpl for cache hash)
  // ---------------------------------------------------------------------------

  /// Reads raw bytes from a local file path.
  /// Exposed so [GeminiFoodAnalyzerImpl] can compute a SHA-256 cache key
  /// without reading the file a second time independently.
  static Future<List<int>> readFileBytes(String path) async {
    return File(path).readAsBytes();
  }

  // ---------------------------------------------------------------------------
  // Internal response parsers
  // ---------------------------------------------------------------------------

  /// Parses the backend's food analysis JSON into a [FoodAnalysisResult].
  ///
  /// The UI defences (item cap, string truncation, numeric clamping) are
  /// intentionally kept here so they apply regardless of what the backend
  /// returns.
  static FoodAnalysisResult _parseFoodAnalysisResponse(String responseBody) {
    final json = jsonDecode(responseBody) as Map<String, dynamic>;

    var rawItems = (json['items'] as List<dynamic>? ?? [])
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();

    // UI defence: cap at 10 items (mirrors backend cap for double-safety)
    if (rawItems.length > 10) rawItems = rawItems.sublist(0, 10);

    // UI defence: truncate excessively long text fields
    final items = rawItems.map((item) {
      return FoodItem(
        name: item.name.length > 100 ? '${item.name.substring(0, 97)}...' : item.name,
        portion:
            item.portion.length > 100
                ? '${item.portion.substring(0, 97)}...'
                : item.portion,
        carbsGrams: item.carbsGrams.clamp(0.0, 500.0),
        calories: item.calories.clamp(0.0, 3000.0),
        proteinGrams: item.proteinGrams.clamp(0.0, 300.0),
        fatGrams: item.fatGrams.clamp(0.0, 300.0),
        source: item.source,
      );
    }).toList();

    double totalCarbs = 0;
    double totalCalories = 0;
    for (final item in items) {
      totalCarbs += item.carbsGrams;
      totalCalories += item.calories;
    }

    return FoodAnalysisResult(
      items: items,
      totalCarbs: totalCarbs,
      totalCalories: totalCalories,
      summary: (json['summary'] as String? ?? 'Meal analyzed').substring(
        0,
        (json['summary'] as String? ?? 'Meal analyzed').length.clamp(0, 200),
      ),
    );
  }
}
