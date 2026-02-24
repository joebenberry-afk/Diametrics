/// Gemini API configuration.
///
/// The API key MUST be provided at build time via:
/// ```
/// flutter run --dart-define=GEMINI_API_KEY=your_key_here
/// ```
///
/// Never hardcode the API key in source code.
class ApiConfig {
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Gemini Flash model — has a generous free tier (15 RPM, 1500 RPD).
  static const String geminiModel = 'gemini-2.0-flash';

  static String get geminiEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey';

  /// Whether the API key has been configured.
  static bool get isConfigured => geminiApiKey.isNotEmpty;
}
