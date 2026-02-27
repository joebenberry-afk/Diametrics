import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../services/food_rag_service.dart';

import 'package:injectable/injectable.dart';

import '../../domain/entities/food_analysis_result.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/repositories/food_analyzer_repository.dart';

/// Exception for API rate limit errors (429). Should not be retried.
class RateLimitException implements Exception {
  final String message;
  const RateLimitException(this.message);

  @override
  String toString() => message;
}

/// Analyzes food images using Google Gemini Flash Lite.
///
/// Optimizations:
/// - Hash-based in-memory cache (avoids re-analyzing identical images)
/// - Retry with exponential backoff (handles flaky mobile connections)
/// - 30-second HTTP timeout
/// - Compressed image input (512px, 70% quality from caller)
@LazySingleton(as: FoodAnalyzerRepository)
class GeminiFoodAnalyzerImpl implements FoodAnalyzerRepository {
  // In-memory cache: SHA-256 hash of image bytes -> analysis result
  static final Map<String, FoodAnalysisResult> _cache = {};

  /// Maximum retry attempts for transient failures.
  static const int _maxRetries = 3;

  /// Analyzes a food photo and returns identified items with nutritional data.
  ///
  /// Results are cached by image content hash. Identical images return
  /// instantly from cache without an API call.
  @override
  Future<FoodAnalysisResult> analyzeImage(String imagePath) async {
    if (!ApiConfig.isConfigured) {
      throw Exception(
        'Gemini API key not configured. '
        'Build with: flutter run --dart-define=GEMINI_API_KEY=your_key',
      );
    }

    final imageBytes = await File(imagePath).readAsBytes();

    // Check cache by image content hash
    final imageHash = sha256.convert(imageBytes).toString();
    final cached = _cache[imageHash];
    if (cached != null) {
      debugPrint('FoodAnalyzer: Cache hit for $imageHash');
      return cached;
    }

    final base64Image = base64Encode(imageBytes);

    // Determine MIME type from extension
    final ext = imagePath.toLowerCase().split('.').last;
    final mimeType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final requestBody = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text':
                  'You are a professional clinical nutritionist AI assisting patients in Trinidad and Tobago. '
                  'Analyze this food image and identify every visible food item, prioritizing local Caribbean dishes '
                  '(e.g., Doubles, Sada Roti, Pelau) if applicable.\n\n'
                  'CRITICAL INSTRUCTION: Analyze the ENTIRE image. '
                  'If there are multiple pieces of the same food, group them into a single item '
                  'and state the TOTAL visible quantity (e.g., "4 chicken breasts").\n\n'
                  'EXAMPLE INPUT: A photo showing 6 doubles on a table.\n'
                  'EXAMPLE OUTPUT:\n'
                  '{\n'
                  '  "thought_process": "I see 6 flatbreads filled with chickpeas. These are 6 portions of Trinidadian Doubles.",\n'
                  '  "items": [\n'
                  '    {\n'
                  '      "name": "Doubles",\n'
                  '      "portion": "6 doubles",\n'
                  '      "carbs_g": 210.0,\n'
                  '      "calories": 1050,\n'
                  '      "protein_g": 30.0,\n'
                  '      "fat_g": 42.0\n'
                  '    }\n'
                  '  ],\n'
                  '  "summary": "6 Trinidadian Doubles"\n'
                  '}\n\n'
                  'Analyze the provided image now.',
            },
            {
              'inline_data': {'mime_type': mimeType, 'data': base64Image},
            },
          ],
        },
      ],
      'systemInstruction': {
        'parts': [
          {
            'text':
                'You must only return valid JSON matching the requested schema. No markdown, no explanations.',
          },
        ],
      },
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens': 2048,
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'OBJECT',
          'properties': {
            'thought_process': {'type': 'STRING'},
            'items': {
              'type': 'ARRAY',
              'items': {
                'type': 'OBJECT',
                'properties': {
                  'name': {'type': 'STRING'},
                  'portion': {'type': 'STRING'},
                  'carbs_g': {'type': 'NUMBER'},
                  'calories': {'type': 'NUMBER'},
                  'protein_g': {'type': 'NUMBER'},
                  'fat_g': {'type': 'NUMBER'},
                },
                'required': [
                  'name',
                  'portion',
                  'carbs_g',
                  'calories',
                  'protein_g',
                  'fat_g',
                ],
              },
            },
            'summary': {'type': 'STRING'},
          },
          'required': ['thought_process', 'items', 'summary'],
        },
      },
    });

    // Retry with exponential backoff (but not on rate limit errors)
    final result = await _retryWithBackoff(() async {
      final response = await http
          .post(
            Uri.parse(ApiConfig.geminiEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 429) {
        // Rate limit - don't retry, throw a user-friendly message
        throw RateLimitException(
          'API rate limit reached. Please wait a minute and try again.',
        );
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again.',
        );
      }

      return _parseResponse(response.body);
    });

    // 2. Post-Retrieval RAG Enrichment
    // Search the local DB for the foods Gemini found and override AI estimates
    // with verified carb data.
    final enrichedItems = await FoodRagService.enrichWithLocalData(
      result.items,
    );

    // Recalculate totals after RAG enrichment
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

    // Cache the enriched result instead of the raw AI result
    _cache[imageHash] = enrichedResult;

    // Limit cache size to prevent memory bloat (keep last 20)
    if (_cache.length > 20) {
      _cache.remove(_cache.keys.first);
    }

    return enrichedResult;
  }

  @override
  Future<FoodAnalysisResult> analyzeText(String userQuery) async {
    // Scaffolded for later text RAG implementation
    throw UnimplementedError(
      'analyzeText not yet supported on Gemini implementation',
    );
  }

  /// Parses the Gemini API JSON response into a [FoodAnalysisResult].
  FoodAnalysisResult _parseResponse(String responseBody) {
    final responseJson = jsonDecode(responseBody) as Map<String, dynamic>;

    final candidates = responseJson['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response from Gemini API');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    var text = parts[0]['text'] as String;

    // Clean any markdown code fences that Gemini might add
    text = text.trim();
    if (text.startsWith('```')) {
      final firstNewline = text.indexOf('\n');
      text = text.substring(firstNewline + 1);
    }
    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3).trim();
    }

    final parsed = jsonDecode(text) as Map<String, dynamic>;

    var items = (parsed['items'] as List<dynamic>)
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();

    // UI Defense: Cap at 10 items to prevent UI thread lockup on massive hallucinations
    if (items.length > 10) {
      items = items.sublist(0, 10);
    }

    // UI Defense: Truncate absurdly long text fields
    items = items.map((item) {
      return FoodItem(
        name: item.name.length > 100
            ? '${item.name.substring(0, 97)}...'
            : item.name,
        portion: item.portion.length > 100
            ? '${item.portion.substring(0, 97)}...'
            : item.portion,
        carbsGrams: item.carbsGrams,
        calories: item.calories,
        proteinGrams: item.proteinGrams,
        fatGrams: item.fatGrams,
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
      summary: parsed['summary'] as String? ?? 'Meal analyzed',
    );
  }

  /// Retries [action] up to [_maxRetries] times with exponential backoff.
  ///
  /// Backoff delays: 1s, 2s, 4s.
  /// Only retries on exceptions (network/timeout failures), not on successful
  /// but empty results.
  Future<T> _retryWithBackoff<T>(Future<T> Function() action) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        return await action();
      } catch (e) {
        // Don't retry rate limit errors - it just wastes more quota
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
    // Unreachable, but satisfies the analyzer
    throw StateError('Retry loop exited unexpectedly');
  }

  /// Clears the in-memory analysis cache.
  void clearCache() {
    _cache.clear();
  }
}
