import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as dev;

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  FirebaseNotificationService() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> initialize() async {
    bool permissionGranted = await _requestNotificationPermissions();
    if (!permissionGranted) {
      dev.log("Notification permissions were not granted.");
      return;
    }

    // Initialize Flutter Local Notifications Plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ); // Changed from 'logo' to '@mipmap/ic_launcher'
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) async {
        dev.log("Notification tapped with payload: $payload");
      },
    );

    // Request permission for iOS
    await _firebaseMessaging.requestPermission();

    // Get and save the device token
    String? token = await _firebaseMessaging.getToken();
    dev.log("Token: $token");
    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      dev.log("New Device Token saved: $newToken");
    });

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      dev.log(
        'Received a message while in the foreground: ${message.notification?.title}',
      );
      _showNotification(message);
    });

    // Create notification channel
    _createNotificationChannel();
  }

  Future<bool> _requestNotificationPermissions() async {
    // Request permissions for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
      providesAppNotificationSettings: true,
    );

    // Check iOS permission status
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      dev.log("iOS Notification permissions granted.");
    } else {
      dev.log("iOS Notification permissions denied.");
      return false;
    }

    // For Android, request permission explicitly if targeting Android 13+ (API 33+)
    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      bool? granted = await androidPlugin?.requestNotificationsPermission();
      if (granted != null && granted) {
        dev.log("Android Notification permissions granted.");
      } else {
        dev.log("Android Notification permissions denied.");
        return false;
      }
    }

    return true;
  }

  Future<String> getDeviceToken() async {
    return await _firebaseMessaging.getToken() ?? '';
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    dev.log("Background message: ${message.notification?.title}");
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
      audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
      autoCancel: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: '',
    );
  }

  void _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // id
      'your_channel_name', // title
      description: 'your_channel_description',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
