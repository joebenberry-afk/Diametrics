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
                  Text('Reminders', style: SeniorTheme.headingStyle),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: _addReminder,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        shape: const CircleBorder(),
                      ),
                      icon: const Icon(
                        Icons.add,
                        size: 24,
                        color: Colors.white,
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
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: Checkbox(
                              value: reminder['done'] as bool,
                              onChanged: (val) {
                                setState(() {
                                  _reminders[index]['done'] = val ?? false;
                                });
                              },
                              activeColor: const Color(0xFF003366),
                              side: const BorderSide(
                                color: Colors.black54,
                                width: 2,
                              ),
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
