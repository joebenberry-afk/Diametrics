import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// A single food item identified by the AI with its nutritional data.
class FoodItem {
  final String name;
  final String portion;
  final double carbsGrams;
  final double calories;
  final double proteinGrams;
  final double fatGrams;

  const FoodItem({
    required this.name,
    required this.portion,
    required this.carbsGrams,
    required this.calories,
    required this.proteinGrams,
    required this.fatGrams,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String? ?? 'Unknown',
      portion: json['portion'] as String? ?? '1 serving',
      carbsGrams: (json['carbs_g'] as num?)?.toDouble() ?? 0.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinGrams: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// The full result of analyzing a food image.
class FoodAnalysisResult {
  final List<FoodItem> items;
  final double totalCarbs;
  final double totalCalories;
  final String summary;

  const FoodAnalysisResult({
    required this.items,
    required this.totalCarbs,
    required this.totalCalories,
    required this.summary,
  });
}

/// Analyzes food images using Google Gemini Flash.
class FoodAnalyzer {
  /// Analyzes a food photo and returns identified items with nutritional data.
  ///
  /// Sends the image to Gemini Flash with a structured prompt requesting
  /// JSON output containing food items and their nutritional breakdown.
  static Future<FoodAnalysisResult> analyzeImage(String imagePath) async {
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
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
          'parts': [
            {
              'text':
                  'You are a professional nutritionist AI. Analyze this food image and identify '
                  'every food item visible. For each item, estimate the portion size and provide '
                  'nutritional data per portion.\n\n'
                  'Return ONLY valid JSON (no markdown, no code fences) in this exact format:\n'
                  '{\n'
                  '  "items": [\n'
                  '    {\n'
                  '      "name": "White Bread",\n'
                  '      "portion": "2 slices",\n'
                  '      "carbs_g": 26.0,\n'
                  '      "calories": 140,\n'
                  '      "protein_g": 4.0,\n'
                  '      "fat_g": 1.5\n'
                  '    }\n'
                  '  ],\n'
                  '  "summary": "Brief one-line meal description"\n'
                  '}\n\n'
                  'If no food is visible, return: {"items": [], "summary": "No food detected"}\n'
                  'Be specific about food names (e.g., "whole wheat bread" not just "bread").',
            },
            {
              'inline_data': {'mime_type': mimeType, 'data': base64Image},
            },
          ],
        },
      ],
      'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 1024},
    });

    final response = await http
        .post(
          Uri.parse(ApiConfig.geminiEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error (${response.statusCode}): ${response.body}',
      );
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

    // Extract text from the Gemini response
    final candidates = responseJson['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('No response from Gemini API');
    }

    final content = candidates[0]['content'] as Map<String, dynamic>;
    final parts = content['parts'] as List<dynamic>;
    var text = parts[0]['text'] as String;

    // Clean any markdown code fences that Gemini might add despite instructions
    text = text.trim();
    if (text.startsWith('```')) {
      final firstNewline = text.indexOf('\n');
      text = text.substring(firstNewline + 1);
    }
    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3).trim();
    }

    final parsed = jsonDecode(text) as Map<String, dynamic>;

    final items = (parsed['items'] as List<dynamic>)
        .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();

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
}
