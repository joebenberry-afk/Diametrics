import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../config/api_config.dart';
import '../../services/food_analyzer.dart';
import '../../utils/nutrition_label_parser.dart';

import '../../theme.dart';
import '../../widgets/glassy_card.dart';
import '../../database/db_instance.dart';
import '../../database/database.dart';
import 'package:drift/drift.dart' show Value, OrderingTerm, Variable;

/// Food Recording screen with AI-powered input methods.
/// Supports: Camera (ML Kit), Voice, Text, and Barcode scanning.
class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();

  File? _capturedImage;
  String _statusMessage = 'Take a photo, type, or speak to log food.';
  bool _isProcessing = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<MealLog> _recentMeals = [];
  FoodAnalysisResult? _analysisResult;

  @override
  void initState() {
    super.initState();
    _loadRecentMeals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentMeals() async {
    final meals =
        await (db.select(db.mealLogs)
              ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
              ..limit(5))
            .get();
    if (mounted) {
      setState(() {
        _recentMeals = meals;
      });
    }
  }

  // ---- Camera + Gemini Flash AI Food Analysis ----
  Future<void> _captureAndAnalyzePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (photo == null) return;

    setState(() {
      _capturedImage = File(photo.path);
      _analysisResult = null;
      _searchResults = [];
    });

    await _analyzeWithGemini(photo.path);
  }

  // ---- Pick from gallery ----
  Future<void> _pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (photo == null) return;

    setState(() {
      _capturedImage = File(photo.path);
      _analysisResult = null;
      _searchResults = [];
    });

    await _analyzeWithGemini(photo.path);
  }

  // ---- Shared Gemini analysis logic ----
  Future<void> _analyzeWithGemini(String imagePath) async {
    if (!ApiConfig.isConfigured) {
      setState(() {
        _statusMessage =
            'API key missing. Build with: --dart-define=GEMINI_API_KEY=...';
        _isProcessing = false;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Checking internet connection...';
    });

    // Check connectivity first
    final connectivity = await Connectivity().checkConnectivity();
    final isConnected = connectivity.any((r) => r != ConnectivityResult.none);

    if (!isConnected) {
      setState(() {
        _isProcessing = false;
        _statusMessage =
            'No internet connection. Use text search or try again later.';
      });
      return;
    }

    setState(() {
      _statusMessage = 'Analyzing food with AI...';
    });

    try {
      final result = await FoodAnalyzer.analyzeImage(imagePath);

      if (!mounted) return;

      if (result.items.isEmpty) {
        setState(() {
          _statusMessage = 'No food detected. Try typing the name instead.';
          _isProcessing = false;
        });
        return;
      }

      setState(() {
        _analysisResult = result;
        _statusMessage = result.summary;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'AI analysis failed: $e';
        _isProcessing = false;
      });
    }
  }

  // ---- Barcode Scanning (Offline) ----
  Future<void> _scanBarcode() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (photo == null) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Scanning barcode...';
    });

    try {
      final inputImage = InputImage.fromFilePath(photo.path);
      final barcodeScanner = BarcodeScanner();
      final barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();

      if (barcodes.isEmpty) {
        setState(() {
          _statusMessage = 'No barcode found. Try again or type the food name.';
          _isProcessing = false;
        });
        return;
      }

      final barcodeValue = barcodes.first.rawValue ?? '';
      // Check custom_foods table for this barcode
      final results = await (db.select(
        db.customFoods,
      )..where((t) => t.barcode.equals(barcodeValue))).get();

      if (results.isNotEmpty) {
        final food = results.first;
        setState(() {
          _statusMessage =
              'Found: ${food.userDefinedName} (${food.carbsPerServing}g carbs)';
          _isProcessing = false;
        });
        await _logMeal(
          food.userDefinedName,
          food.carbsPerServing,
          isOffline: true,
        );
      } else {
        // Barcode not known - prompt to add custom food
        setState(() {
          _statusMessage =
              'Barcode "$barcodeValue" not found. Add it as a custom food?';
          _isProcessing = false;
        });
        if (mounted) {
          _showAddCustomFoodDialog(barcode: barcodeValue);
        }
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error scanning barcode. Please try again.';
        _isProcessing = false;
      });
    }
  }

  // ---- Text Search (Offline) ----
  Future<void> _searchByText(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final q = '%${query.trim()}%';

    // Search custom_foods first, then local_foods using raw SQL
    final customRows = await db
        .customSelect(
          'SELECT user_defined_name, carbs_per_serving FROM custom_foods WHERE user_defined_name LIKE ? LIMIT 5',
          variables: [Variable.withString(q)],
        )
        .get();

    final localRows = await db
        .customSelect(
          'SELECT name, carbs_per_serving FROM local_foods WHERE name LIKE ? LIMIT 10',
          variables: [Variable.withString(q)],
        )
        .get();

    final combined = <Map<String, dynamic>>[];

    for (final row in customRows) {
      combined.add({
        'name': row.read<String>('user_defined_name'),
        'carbs': row.read<double>('carbs_per_serving'),
        'source': 'Custom',
      });
    }
    for (final row in localRows) {
      combined.add({
        'name': row.read<String>('name'),
        'carbs': row.read<double>('carbs_per_serving'),
        'source': 'USDA',
      });
    }

    setState(() {
      _searchResults = combined;
      _statusMessage = combined.isEmpty
          ? 'No results found for "$query".'
          : 'Found ${combined.length} results.';
    });
  }

  // ---- Log entire AI-analyzed meal ----
  Future<void> _logAnalyzedMeal() async {
    final result = _analysisResult;
    if (result == null || result.items.isEmpty) return;

    final foodNames = result.items.map((i) => i.name).join(', ');
    await _logMeal(foodNames, result.totalCarbs);

    setState(() {
      _analysisResult = null;
    });
  }

  // ---- Log a meal ----
  Future<void> _logMeal(
    String foodName,
    double carbs, {
    bool isOffline = true,
  }) async {
    await db
        .into(db.mealLogs)
        .insert(
          MealLogsCompanion.insert(
            timestamp: DateTime.now(),
            transcription: Value(foodName),
            estimatedCarbs: carbs,
            imagePath: Value(_capturedImage?.path),
            isOfflineEstimate: Value(isOffline),
          ),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged: $foodName (${carbs}g carbs)'),
          backgroundColor: SeniorTheme.successGreen,
        ),
      );
      _loadRecentMeals();
      setState(() {
        _searchResults = [];
        _searchController.clear();
        _capturedImage = null;
        _statusMessage = 'Meal logged successfully!';
      });
    }
  }

  // ---- Add Custom Food Dialog ----
  void _showAddCustomFoodDialog({String? barcode}) {
    final nameController = TextEditingController();
    final carbsController = TextEditingController();
    final servingController = TextEditingController(text: '1 serving');
    String? scanStatus;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Custom Food'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scan Label Button
                OutlinedButton.icon(
                  onPressed: () async {
                    final photo = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1280,
                      maxHeight: 1280,
                      imageQuality: 90,
                    );
                    if (photo == null) return;

                    setDialogState(() {
                      scanStatus = 'Reading label...';
                    });

                    try {
                      final inputImage = InputImage.fromFilePath(photo.path);
                      final textRecognizer = TextRecognizer();
                      final recognized = await textRecognizer.processImage(
                        inputImage,
                      );
                      await textRecognizer.close();

                      final parsed = NutritionLabelParser.parse(
                        recognized.text,
                      );

                      setDialogState(() {
                        if (parsed['servingSize'] != null &&
                            parsed['servingSize']!.isNotEmpty) {
                          servingController.text = parsed['servingSize']!;
                        }
                        if (parsed['totalCarbs'] != null) {
                          carbsController.text = parsed['totalCarbs']!;
                        }
                        scanStatus = parsed.isEmpty
                            ? 'Could not read label. Try again or type manually.'
                            : 'Found: ${parsed.entries.map((e) => "${e.key}: ${e.value}").join(", ")}';
                      });
                    } catch (e) {
                      setDialogState(() {
                        scanStatus = 'Error reading label. Try again.';
                      });
                    }
                  },
                  icon: const Icon(Icons.document_scanner_rounded),
                  label: const Text('Scan Nutrition Label'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
                if (scanStatus != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    scanStatus!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 12),
                if (barcode != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Barcode: $barcode',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    hintText: 'e.g., Kelloggs Corn Flakes',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: servingController,
                  decoration: const InputDecoration(
                    labelText: 'Serving Size',
                    hintText: 'e.g., 1 cup, 30g',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: carbsController,
                  decoration: const InputDecoration(
                    labelText: 'Carbs per Serving (g)',
                    hintText: 'e.g., 24',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final carbs = double.tryParse(carbsController.text.trim());
                if (name.isEmpty || carbs == null) return;

                await db
                    .into(db.customFoods)
                    .insert(
                      CustomFoodsCompanion.insert(
                        userDefinedName: name,
                        barcode: Value(barcode),
                        servingSize: Value(servingController.text.trim()),
                        carbsPerServing: carbs,
                      ),
                    );

                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  setState(() {
                    _statusMessage = 'Saved "$name" to your custom foods!';
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE0F7FA), Color(0xFFF5F5DC), Color(0xFFE0F7FA)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // -- Status Banner --
              GlassyCard(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    if (_isProcessing)
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: SeniorTheme.bodyStyle.copyWith(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // -- Image Preview --
              if (_capturedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _capturedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // -- AI Food Analysis Results --
              if (_analysisResult != null) ...[
                _buildFoodAnalysisResults(_analysisResult!),
                const SizedBox(height: 16),
              ],

              // -- Input Methods Row --
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: const Color(0xFF5CE1E6),
                      onTap: _captureAndAnalyzePhoto,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: const Color(0xFF81C784),
                      onTap: _pickFromGallery,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Barcode',
                      color: const Color(0xFFFFB74D),
                      onTap: _scanBarcode,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Custom',
                      color: const Color(0xFFBA68C8),
                      onTap: () => _showAddCustomFoodDialog(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // -- Text Search Field --
              GlassyCard(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _searchByText,
                        style: SeniorTheme.bodyStyle.copyWith(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Search food by name...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // -- Search Results --
              if (_searchResults.isNotEmpty) ...[
                Text(
                  'Search Results',
                  style: SeniorTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ..._searchResults.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GlassyCard(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: InkWell(
                        onTap: () => _logMeal(
                          item['name'] as String,
                          (item['carbs'] as num).toDouble(),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] as String,
                                    style: SeniorTheme.bodyStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item["carbs"]}g carbs | ${item["source"]}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.add_circle,
                              color: SeniorTheme.successGreen,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // -- Recent Meals --
              if (_recentMeals.isNotEmpty) ...[
                Text(
                  'Recent Meals',
                  style: SeniorTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ..._recentMeals.map(
                  (meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GlassyCard(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            meal.isOfflineEstimate
                                ? Icons.wifi_off_rounded
                                : Icons.cloud_done_rounded,
                            size: 20,
                            color: meal.isOfflineEstimate
                                ? Colors.orange
                                : SeniorTheme.successGreen,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal.transcription ?? 'Unknown meal',
                                  style: SeniorTheme.bodyStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${meal.estimatedCarbs}g carbs',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatTime(meal.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isProcessing ? null : onTap,
      child: GlassyCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- AI Analysis Results Card ----
  Widget _buildFoodAnalysisResults(FoodAnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'AI Food Analysis',
          style: SeniorTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...result.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GlassyCard(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: SeniorTheme.bodyStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SeniorTheme.primaryCyan.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.portion,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildNutrientChip(
                        'Carbs',
                        '${item.carbsGrams.toStringAsFixed(1)}g',
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildNutrientChip(
                        'Cal',
                        item.calories.toStringAsFixed(0),
                        Colors.red.shade400,
                      ),
                      const SizedBox(width: 8),
                      _buildNutrientChip(
                        'Protein',
                        '${item.proteinGrams.toStringAsFixed(1)}g',
                        Colors.blue.shade400,
                      ),
                      const SizedBox(width: 8),
                      _buildNutrientChip(
                        'Fat',
                        '${item.fatGrams.toStringAsFixed(1)}g',
                        Colors.purple.shade300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Meal totals + Log button
        GlassyCard(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTotalStat(
                    'Total Carbs',
                    '${result.totalCarbs.toStringAsFixed(1)}g',
                    Colors.orange,
                  ),
                  _buildTotalStat(
                    'Total Calories',
                    result.totalCalories.toStringAsFixed(0),
                    Colors.red.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _logAnalyzedMeal,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    'Log This Meal',
                    style: SeniorTheme.buttonTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}';
  }
}
