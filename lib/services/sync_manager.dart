import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';

import '../database/db_instance.dart';

/// SyncManager — synchronizes pending offline meal_logs with Cloud AI.
///
/// Uses [WidgetsBindingObserver] to detect when the app returns to the
/// foreground and automatically triggers a sync attempt.
///
/// The Cloud AI enriches offline estimates with:
/// - Revised carbohydrate estimate
/// - Volume eaten
/// - Whether the food was finished (completion percentage)
class SyncManager with WidgetsBindingObserver {
  // ---------------------------------------------------------------------------
  // Singleton
  // ---------------------------------------------------------------------------
  SyncManager._internal();
  static final SyncManager _instance = SyncManager._internal();

  /// Returns the global [SyncManager] instance.
  factory SyncManager() => _instance;

  bool _isInitialized = false;
  bool _isSyncing = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Registers this observer with WidgetsBinding.
  /// Call once in [main] after [WidgetsFlutterBinding.ensureInitialized].
  void initialize() {
    if (_isInitialized) return;
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    debugPrint('SyncManager: Initialized and observing lifecycle events.');
  }

  /// Unregisters the observer. Call when the app is disposed.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    debugPrint('SyncManager: Disposed.');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('SyncManager: App resumed. Triggering sync...');
      syncNow();
    }
  }

  // ---------------------------------------------------------------------------
  // Core Sync Logic
  // ---------------------------------------------------------------------------

  /// Checks connectivity, queries pending meal_logs, and syncs each with the
  /// Cloud AI. Safe to call multiple times; concurrent runs are prevented.
  Future<void> syncNow() async {
    // Guard against concurrent sync runs
    if (_isSyncing) {
      debugPrint('SyncManager: Sync already in progress. Skipping.');
      return;
    }
    _isSyncing = true;

    try {
      // 1. Check connectivity
      final connectivityResults = await Connectivity().checkConnectivity();
      final isConnected = connectivityResults.any(
        (r) => r != ConnectivityResult.none,
      );

      if (!isConnected) {
        debugPrint('SyncManager: No internet connection. Aborting sync.');
        return;
      }
      debugPrint('SyncManager: Internet connection detected.');

      // 2. Query pending meal logs
      final pendingLogs = await db
          .customSelect(
            'SELECT * FROM meal_logs WHERE sync_status = ?',
            variables: [Variable.withString('pending')],
          )
          .get();

      if (pendingLogs.isEmpty) {
        debugPrint('SyncManager: No pending logs to sync.');
        return;
      }
      debugPrint('SyncManager: Found ${pendingLogs.length} pending logs.');

      // 3. Iterate and sync each record
      int successCount = 0;
      for (final row in pendingLogs) {
        final logId = row.read<int>('id');
        final imagePath = row.readNullable<String>('image_path');
        final transcription = row.readNullable<String>('transcription');

        debugPrint(
          'SyncManager: Syncing log ID $logId '
          '(image: ${imagePath != null ? "yes" : "none"}, '
          'text: "${transcription ?? "none"}")...',
        );

        try {
          // 4. Call Cloud AI (simulated)
          final aiResult = await _fetchCloudAIEstimate(
            imagePath ?? '',
            transcription ?? '',
          );

          // 5. Update database with enriched data
          await db.customUpdate(
            'UPDATE meal_logs SET '
            'estimated_carbs = ?, '
            'completion_percentage = ?, '
            'is_offline_estimate = 0, '
            'sync_status = ? '
            'WHERE id = ?',
            variables: [
              Variable.withReal(aiResult['estimated_carbs'] as double),
              Variable.withInt(aiResult['completion_percentage'] as int),
              Variable.withString('synced'),
              Variable.withInt(logId),
            ],
            updates: {db.mealLogs},
          );

          successCount++;
          debugPrint('SyncManager: Successfully synced log ID $logId.');
        } catch (e) {
          // Leave as pending so the queue is not blocked
          debugPrint(
            'SyncManager: Error syncing log ID $logId: $e. '
            'Will retry next sync.',
          );
        }
      }

      debugPrint(
        'SyncManager: Sync complete. '
        '$successCount/${pendingLogs.length} logs synced.',
      );
    } catch (e) {
      debugPrint('SyncManager: Unexpected error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Simulated Cloud AI API
  // ---------------------------------------------------------------------------

  /// Simulates an HTTP POST to a Cloud AI service that analyses meal photos
  /// and transcriptions (e.g.  Gemini Flash).
  ///
  /// In production, replace the [Future.delayed] and mock response with a
  /// real [http.post] call to your API endpoint.
  ///
  /// Returns a map containing:
  /// - `estimated_carbs` (double) — revised carbohydrate estimate
  /// - `volume_eaten` (String) — e.g. "3/4 plate"
  /// - `food_finished` (bool) — whether the meal appears complete
  /// - `completion_percentage` (int) — 0-100
  Future<Map<String, dynamic>> _fetchCloudAIEstimate(
    String imagePath,
    String transcription,
  ) async {
    debugPrint('SyncManager: Sending to Cloud AI...');

    // --- Simulate 2-second network latency ---
    await Future.delayed(const Duration(seconds: 2));

    // --- Mock AI response ---
    // In production, replace with:
    // final response = await http.post(
    //   Uri.parse('https://your-api.example.com/analyze'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'image_path': imagePath,
    //     'transcription': transcription,
    //   }),
    // );
    // return jsonDecode(response.body) as Map<String, dynamic>;

    final mockResponse = jsonEncode({
      'estimated_carbs': 32.5,
      'volume_eaten': '3/4 plate',
      'food_finished': false,
      'completion_percentage': 75,
    });

    debugPrint('SyncManager: Cloud AI responded.');
    return jsonDecode(mockResponse) as Map<String, dynamic>;
  }
}
