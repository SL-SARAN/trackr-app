import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database and set local timezone
    tzdata.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Request notification permission (required for Android 13+ / API 33+).
  /// Returns `true` if permission is granted.
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check whether notification permission is currently granted.
  Future<bool> hasPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Check whether the user has permanently denied notifications.
  Future<bool> isPermanentlyDenied() async {
    final status = await Permission.notification.status;
    return status.isPermanentlyDenied;
  }

  /// Open the app's system notification settings.
  Future<void> openNotificationSettings() => openAppSettings();

  /// Show an immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trackr_general',
          'General',
          channelDescription: 'General notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Schedule a notification at a specific time. Returns the notification ID.
  Future<int> scheduleTask({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trackr_tasks',
          'Task Reminders',
          channelDescription: 'Reminders for scheduled tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return id;
  }

  /// Cancel a previously scheduled notification.
  Future<void> cancel(int id) => _plugin.cancel(id);

  /// Cancel all notifications.
  Future<void> cancelAll() => _plugin.cancelAll();
}
