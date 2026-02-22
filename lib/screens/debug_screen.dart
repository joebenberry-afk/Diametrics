import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/database.dart';
import '../../theme.dart';
import '../../widgets/big_button.dart';

/// DebugScreen - For testing database functionality during development.
///
/// Features:
/// - Insert test log entries
/// - View all logs
/// - Clear all logs
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final AppDatabase _db = AppDatabase();
  List<Log> _logs = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final logs = await _db.getRecentLogs(const Duration(days: 30));
      setState(() {
        _logs = logs;
        _statusMessage = 'Loaded ${logs.length} logs';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading logs: $e';
      });
    }
  }

  Future<void> _insertTestLog() async {
    try {
      await _db
          .into(_db.logs)
          .insert(
            LogsCompanion.insert(
              timestamp: DateTime.now(),
              bgValue: const drift.Value(5.6), // Normal glucose value in mmol/L
              bgUnit: const drift.Value('mmol/L'),
              contextTags: const drift.Value('Test Entry'),
              foodVolume: const drift.Value('1 cup'),
              finishedMeal: const drift.Value(true),
            ),
          );
      setState(() {
        _statusMessage = 'Test log inserted successfully!';
      });
      await _loadLogs();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error inserting log: $e';
      });
    }
  }

  Future<void> _clearAllLogs() async {
    try {
      await _db.delete(_db.logs).go();
      setState(() {
        _statusMessage = 'All logs cleared';
        _logs = [];
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error clearing logs: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
        backgroundColor: SeniorTheme.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusMessage.isEmpty ? 'Ready' : _statusMessage,
                style: SeniorTheme.bodyStyle,
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            BigButton(
              label: 'Insert Test Log',
              icon: Icons.add,
              onPressed: _insertTestLog,
            ),
            const SizedBox(height: 12),
            BigButton(
              label: 'Refresh Logs',
              icon: Icons.refresh,
              onPressed: _loadLogs,
              isSecondary: true,
            ),
            const SizedBox(height: 12),
            BigButton(
              label: 'Clear All Logs',
              icon: Icons.delete,
              onPressed: _clearAllLogs,
              isSecondary: true,
            ),
            const SizedBox(height: 24),
            // Logs List
            Text(
              'Stored Logs (${_logs.length})',
              style: SeniorTheme.headingStyle,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _logs.isEmpty
                  ? Center(
                      child: Text(
                        'No logs yet. Tap "Insert Test Log" to add one.',
                        style: SeniorTheme.bodyStyle.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              '${log.bgValue?.toStringAsFixed(1) ?? "N/A"} ${log.bgUnit}',
                              style: SeniorTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${log.timestamp.toString().substring(0, 19)}\n${log.contextTags ?? "No tags"}',
                              style: SeniorTheme.bodyStyle.copyWith(
                                fontSize: 14,
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
