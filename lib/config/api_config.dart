/// Gemini API configuration.
///
/// To override at build time, use:
/// ```
/// flutter run --dart-define=GEMINI_API_KEY=your_key_here
/// ```
class ApiConfig {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyBB1OvrfJCby6gRgFdy_Jb7khVw_1PUjzk',
  );

  static const String geminiModel = 'gemini-2.0-flash';

  static String get geminiEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey';
}
