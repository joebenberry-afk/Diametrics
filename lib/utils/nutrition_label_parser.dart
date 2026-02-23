/// Parses raw OCR text from a Nutrition Facts label and extracts key values.
///
/// Handles common US-style Nutrition Facts labels by searching for known
/// keywords and extracting the numeric values that follow them.
class NutritionLabelParser {
  /// Parses OCR text and returns a map of extracted nutrition info.
  ///
  /// Keys: 'servingSize', 'calories', 'totalCarbs', 'totalFat', 'protein',
  ///        'sugars', 'fiber', 'sodium'
  /// Values are strings (e.g., "22g", "110", "3 pretzels (28g)").
  static Map<String, String> parse(String ocrText) {
    final result = <String, String>{};
    final lines = ocrText.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final lower = line.toLowerCase();

      // Serving Size
      if (lower.contains('serving size')) {
        result['servingSize'] = _extractAfterKeyword(line, 'serving size');
      }

      // Calories (look for the big number)
      if (lower.contains('calories') && !lower.contains('%')) {
        final cal = _extractNumber(line);
        if (cal != null) {
          result['calories'] = cal;
        }
      }

      // Total Carbohydrate / Total Carb.
      if (lower.contains('total carb')) {
        final val = _extractGrams(line);
        if (val != null) {
          result['totalCarbs'] = val;
        }
      }

      // Total Fat
      if (lower.contains('total fat')) {
        final val = _extractGrams(line);
        if (val != null) {
          result['totalFat'] = val;
        }
      }

      // Protein
      if (lower.contains('protein')) {
        final val = _extractGrams(line);
        if (val != null) {
          result['protein'] = val;
        }
      }

      // Sugars (Total Sugars or Sugars)
      if (lower.contains('sugars') && !lower.contains('added')) {
        final val = _extractGrams(line);
        if (val != null) {
          result['sugars'] = val;
        }
      }

      // Dietary Fiber
      if (lower.contains('fiber')) {
        final val = _extractGrams(line);
        if (val != null) {
          result['fiber'] = val;
        }
      }

      // Sodium
      if (lower.contains('sodium')) {
        final val = _extractMg(line);
        if (val != null) {
          result['sodium'] = val;
        }
      }
    }

    return result;
  }

  /// Extracts text after a keyword (e.g., "Serving Size 3 pretzels (28g)")
  static String _extractAfterKeyword(String line, String keyword) {
    final idx = line.toLowerCase().indexOf(keyword.toLowerCase());
    if (idx == -1) return '';
    return line.substring(idx + keyword.length).trim();
  }

  /// Extracts the first number found in the line (for calories).
  static String? _extractNumber(String line) {
    final match = RegExp(r'(\d+)').firstMatch(line);
    return match?.group(1);
  }

  /// Extracts a gram value like "22g" or "22 g" from a line.
  static String? _extractGrams(String line) {
    final match = RegExp(
      r'(\d+\.?\d*)\s*g\b',
      caseSensitive: false,
    ).firstMatch(line);
    return match?.group(1);
  }

  /// Extracts a milligram value like "410mg" from a line.
  static String? _extractMg(String line) {
    final match = RegExp(
      r'(\d+\.?\d*)\s*mg\b',
      caseSensitive: false,
    ).firstMatch(line);
    if (match != null) return '${match.group(1)}mg';
    return null;
  }
}
