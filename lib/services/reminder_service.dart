import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initialize the notification plugin and request Android 13+ permission.
  /// Returns `true` if notifications are available, `false` otherwise.
  static Future<bool> initialize() async {
    if (_initialized) return true;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final didInit = await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    if (didInit != true) {
      debugPrint('ReminderService: initialization returned false');
      return false;
    }

    // Android 13+ (API 33) requires POST_NOTIFICATIONS runtime permission.
    if (Platform.isAndroid) {
      final granted = await _requestAndroidNotificationPermission();
      if (!granted) {
        debugPrint('ReminderService: notification permission denied');
        // Still mark as initialized so the user can grant later.
      }
    }

    _initialized = true;
    return true;
  }

  /// Whether the service has been initialized (still usable — permission may
  /// have been denied, but scheduling calls will silently fail on the OS side).
  static bool get isInitialized => _initialized;

  /// Request the Android POST_NOTIFICATIONS permission (API 33+).
  static Future<bool> _requestAndroidNotificationPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return false;
    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
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
    // Ensure initialization before scheduling.
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) {
        debugPrint('ReminderService: cannot schedule — init failed');
        return;
      }
    }

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

  /// Schedule a one-shot notification at a specific time in the future.
  /// Unlike [scheduleDailyReminder], this fires once and does not repeat.
  static Future<void> scheduleOneShot({
    required int id,
    required String title,
    required String body,
    required DateTime fireAt,
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) {
        debugPrint('ReminderService: cannot schedule — init failed');
        return;
      }
    }

    final scheduledDate = tz.TZDateTime.from(fireAt, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'post_meal_reminders',
          'Post-Meal Reminders',
          channelDescription: 'Reminders to log post-meal glucose',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
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
