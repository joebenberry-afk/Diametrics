import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/glassy_card.dart';

/// Reminders screen - displays a list of reminders with checkboxes.
/// Matches the "Reminders page" mockup from design image 2 (left panel).
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<Map<String, dynamic>> _reminders = [
    {'text': 'Take insulin at 7AM', 'done': true},
    {'text': 'Add a reminder here...', 'done': false},
  ];

  void _addReminder() {
    setState(() {
      _reminders.add({'text': 'New reminder...', 'done': false});
    });
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with + button
              Row(
                children: [
                  Text(
                    'Reminders',
                    style: SeniorTheme.headingStyle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addReminder,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: SeniorTheme.primaryCyan,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Reminders list
              GlassyCard(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: List.generate(_reminders.length, (index) {
                    final reminder = _reminders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                reminder['text'] as String,
                                style: SeniorTheme.bodyStyle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _reminders[index]['done'] =
                                    !(reminder['done'] as bool);
                              });
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black54,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                color: (reminder['done'] as bool)
                                    ? Colors.black87
                                    : Colors.white,
                              ),
                              child: (reminder['done'] as bool)
                                  ? const Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
