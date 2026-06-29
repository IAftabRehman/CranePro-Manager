import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/notifications/presentation/pages/notification_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background processes
  await Firebase.initializeApp();
  log("Handling background message: ${message.messageId}", name: "NotificationService");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'fcm_default_channel',
    'General Alerts',
    description: 'This channel is used for standard system work updates.',
    importance: Importance.max,
    playSound: true,
  );

  /// Initializes notification services: FCM, local notifications, channels, and listeners.
  Future<void> initialize() async {
    // 1. Initialize Local Notifications settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false, // Requested explicitly via requestPermissions
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            _handleNotificationNavigation(data);
          } catch (e) {
            log("Error parsing notification payload: $e", name: "NotificationService");
            _handleNotificationNavigation({});
          }
        } else {
          _handleNotificationNavigation({});
        }
      },
    );

    // 2. Create the notification channel on Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    // 3. Request permissions (Android 13+ and iOS)
    await requestPermissions();

    // 4. Configure FCM foreground presentation options for iOS/macOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Listen for incoming foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Foreground message received: ${message.messageId}", name: "NotificationService");
      
      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;

      if (notification != null && !Platform.isIOS) {
        // iOS displays notifications natively when in foreground because of setForegroundNotificationPresentationOptions.
        // Android requires local notification dispatching.
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 6. Handle notification click when app is in foreground/background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Notification opened app: ${message.messageId}", name: "NotificationService");
      _handleNotificationNavigation(message.data);
    });

    // 7. Handle notification click when app was launched from a terminated state
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      log("App launched from terminated notification: ${initialMessage.messageId}", name: "NotificationService");
      _handleNotificationNavigation(initialMessage.data);
    }

    // 8. Listen to token refresh events
    _fcm.onTokenRefresh.listen((newToken) async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .update({'fcmToken': newToken});
          log("FCM Token refreshed and updated in Firestore: $newToken", name: "NotificationService");
        } catch (e) {
          log("Failed to update refreshed token: $e", name: "NotificationService");
        }
      }
    });
  }

  /// Requests notification permissions for Android 13+ and iOS.
  Future<void> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        // Request Permission for Android 13 (API 33) and above
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      } else if (Platform.isIOS) {
        await _fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      log("Error requesting notification permissions: $e", name: "NotificationService");
    }
  }

  /// Handles routing when a notification is tapped.
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      log("Navigator context not available yet", name: "NotificationService");
      return;
    }

    // Navigate to Work Update Center / NotificationScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
