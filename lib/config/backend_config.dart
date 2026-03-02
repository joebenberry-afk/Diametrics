/// DiaMetrics Backend Configuration
///
/// This is the ONLY place in the Flutter app that knows where the backend is.
/// All third-party API keys (Gemini, USDA) live in the backend's .env file —
/// they are NOT present anywhere in this Flutter APK.
///
/// ## How to run
///
/// Android emulator (localhost alias 10.0.2.2):
/// ```
/// flutter run \
///   --dart-define=BACKEND_URL=http://10.0.2.2:8000 \
///   --dart-define=BACKEND_API_KEY=your_shared_secret
/// ```
///
/// Real device on the same Wi-Fi network (replace with your machine's LAN IP):
/// ```
/// flutter run \
///   --dart-define=BACKEND_URL=http://192.168.1.42:8000 \
///   --dart-define=BACKEND_API_KEY=your_shared_secret
/// ```
///
/// Production (replace with your deployed server URL):
/// ```
/// flutter run \
///   --dart-define=BACKEND_URL=https://api.diametrics.app \
///   --dart-define=BACKEND_API_KEY=your_shared_secret
/// ```
class BackendConfig {
  BackendConfig._(); // Non-instantiable

  /// Base URL of the DiaMetrics FastAPI backend server.
  /// Default is the Android emulator alias for localhost.
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Shared secret sent in the Authorization header to authenticate requests.
  /// Must match BACKEND_API_KEY in the backend's .env file.
  static const String backendApiKey = String.fromEnvironment('BACKEND_API_KEY');

  /// Whether the backend has been configured (API key is set).
  static bool get isConfigured => backendApiKey.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Endpoint URLs
  // ---------------------------------------------------------------------------

  /// POST — Gemini food image analysis
  static String get analyzeImageEndpoint => '$backendUrl/api/v1/food/analyze-image';

  /// GET — USDA FoodData Central search
  static String get usdaSearchEndpoint => '$backendUrl/api/v1/food/usda-search';

  /// GET — Open Food Facts barcode lookup
  static String barcodeEndpoint(String barcode) =>
      '$backendUrl/api/v1/food/barcode/$barcode';

  /// GET — Server health check
  static String get healthEndpoint => '$backendUrl/health';

  // ---------------------------------------------------------------------------
  // Auth headers (included in every request)
  // ---------------------------------------------------------------------------

  /// Headers to attach to every backend request.
  static Map<String, String> get authHeaders => {
    'Authorization': 'Bearer $backendApiKey',
    'Content-Type': 'application/json',
  };
}
