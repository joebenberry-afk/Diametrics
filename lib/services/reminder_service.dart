import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const int _postMealReminder30Id = 100;
  static const int _postMealReminder120Id = 101;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  /// Schedule a daily medication reminder at [hour]:[minute].
  /// [id] must be unique per reminder (use a stable integer).
  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Medication Reminders',
          channelDescription: 'Daily reminders to take medication',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedules one-shot post-meal glucose check reminders at +30 min and
  /// +120 min from [mealTime]. Cancels any previously scheduled post-meal
  /// reminders first so back-to-back meals don't stack up notifications.
  ///
  /// Fully silent — never throws or blocks the UI.
  static Future<void> schedulePostMealReminders(DateTime mealTime) async {
    try {
      await _plugin.cancel(id: _postMealReminder30Id);
      await _plugin.cancel(id: _postMealReminder120Id);

      final now = tz.TZDateTime.now(tz.local);
      final time30 = tz.TZDateTime.from(
        mealTime.add(const Duration(minutes: 30)),
        tz.local,
      );
      final time120 = tz.TZDateTime.from(
        mealTime.add(const Duration(minutes: 120)),
        tz.local,
      );

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'post_meal_reminders',
          'Post-Meal Reminders',
          channelDescription: 'Reminders to log glucose after meals for better predictions',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      );

      if (!time30.isBefore(now)) {
        await _plugin.zonedSchedule(
          id: _postMealReminder30Id,
          title: 'Time to check glucose',
          body: 'Log your glucose level 30 minutes after your last meal to improve predictions.',
          scheduledDate: time30,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }

      if (!time120.isBefore(now)) {
        await _plugin.zonedSchedule(
          id: _postMealReminder120Id,
          title: '2-hour glucose check',
          body: 'Log your glucose level for your 2-hour post-meal reading.',
          scheduledDate: time120,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    } catch (_) {
      // Silent failure — reminders are best-effort, never block the app
    }
  }

  static Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id: id);
  }

  static Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
