import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // Create a high-priority channel for Android
    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            'pending_work_high_priority',
            'Urgent Pending Work',
            description: 'Used for midnight alerts and high-priority work reminders.',
            importance: Importance.max,
          ));
    }
  }

  static Future<void> showHighPriorityAlert(String clientName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pending_work_high_priority',
      'Urgent Pending Work',
      channelDescription: 'High priority alerts for operator tasks',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      'Late Night Alert',
      'You still have pending work for $clientName!',
      platformDetails,
    );
  }

  static Future<void> scheduleMidnightCheck(String clientName) async {
    final now = DateTime.now();
    // Schedule for 0:01 AM
    final scheduledTime = DateTime(now.year, now.month, now.day + 1, 0, 1);

    await _notificationsPlugin.zonedSchedule(
      100, // Fixed ID for daily reminder
      'Midnight Work Check',
      'Late Night Alert: You still have pending work for $clientName!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'midnight_channel',
          'Midnight Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
