// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// // import 'package:get/get.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';

// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart'
//     show FieldValue, FirebaseFirestore;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   late FlutterLocalNotificationsPlugin _notificationsPlugin;
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Store the current notification settings
//   NotificationSettings? _settings;

//   // Channels
//   static const String _channelId = 'project_assignments';
//   static const String _channelName = 'Project Assignment Notifications';
//   static const String _channelDescription =
//       'Notifications for new project assignments';

//   // Initialize both local and remote notifications
//   Future<void> initialize() async {
//     try {
//       print("Starting notification service initialization");

//       // Initialize local notifications
//       _notificationsPlugin = FlutterLocalNotificationsPlugin();

//       // Configure Android settings
//       const AndroidInitializationSettings initializationSettingsAndroid =
//           AndroidInitializationSettings('@mipmap/ic_launcher');

//       // Configure iOS settings - request all permissions here
//       final DarwinInitializationSettings initializationSettingsIOS =
//           DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//       );

//       // Combined settings
//       final InitializationSettings initializationSettings =
//           InitializationSettings(
//         android: initializationSettingsAndroid,
//         iOS: initializationSettingsIOS,
//       );

//       // Initialize the plugin
//       await _notificationsPlugin.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: (NotificationResponse response) {
//           // Handle notification tap
//           print("Notification tapped with payload: ${response.payload}");
//           _handleNotificationTap(response.payload);
//         },
//       );

//       // Create notification channels for Android
//       if (Platform.isAndroid) {
//         await _createNotificationChannel();
//       }

//       // Enable foreground notifications
//       await _firebaseMessaging.setForegroundNotificationPresentationOptions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );

//       // Initialize FCM for remote notifications
//       await _setupFirebaseMessaging();

//       print("Notification service initialized successfully");
//     } catch (e) {
//       print("Notification initialization error: $e");
//     }
//   }

//   // Create Android notification channel
//   Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       _channelId,
//       _channelName,
//       description: _channelDescription,
//       importance: Importance.max,
//       playSound: true,
//       enableVibration: true,
//       enableLights: true,
//     );

//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);

//     print("Android notification channel created");
//   }

//   // Setup Firebase Cloud Messaging
//   Future<void> _setupFirebaseMessaging() async {
//     try {
//       // Request notification permissions
//       _settings = await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//         criticalAlert: true,
//       );

//       print(
//           'User granted notification permission: ${_settings?.authorizationStatus}');

//       // If permissions denied, try to guide user
//       if (_settings?.authorizationStatus == AuthorizationStatus.denied) {
//         print('User denied notification permissions!');
//         // In a real app, you might want to show a dialog explaining why notifications are important
//         return;
//       }

//       // Get FCM token for this device
//       String? token = await _firebaseMessaging.getToken();
//       if (token != null) {
//         print('FCM Token obtained: $token');
//         await _saveTokenToDatabase(token);
//       } else {
//         print('Failed to get FCM token');
//       }

//       // Listen for token refresh
//       _firebaseMessaging.onTokenRefresh.listen((String token) {
//         print('FCM token refreshed: $token');
//         _saveTokenToDatabase(token);
//       });

//       // Configure foreground notification presentation options
//       await _firebaseMessaging.setForegroundNotificationPresentationOptions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );

//       // Set up background message handler in main.dart with:
//       // @pragma('vm:entry-point')
//       // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//       //   await Firebase.initializeApp();
//       //   print("Handling a background message: ${message.messageId}");
//       //   // You can show a notification here too if needed
//       // }
//       //
//       // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//       // Set up foreground message handler
//       FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

//       // Set up app opened from notification handler
//       FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

//       // Check if the app was opened from a notification
//       final RemoteMessage? initialMessage =
//           await _firebaseMessaging.getInitialMessage();
//       if (initialMessage != null) {
//         print('App opened from terminated state by notification');
//         _handleMessageOpenedApp(initialMessage);
//       }

//       print("Firebase messaging setup complete");
//     } catch (e) {
//       print('Error setting up Firebase messaging: $e');
//     }
//   }

//   // Handle foreground messages
//   void _handleForegroundMessage(RemoteMessage message) {
//     print('Got a message whilst in the foreground!');
//     print('Message data: ${message.data}');

//     // Always show notification in foreground
//     // This is important to make notifications visible when the app is open
//     _showLocalNotificationFromRemote(message);
//   }

//   // Handle when app is opened from a notification
//   void _handleMessageOpenedApp(RemoteMessage message) {
//     print('Message opened app: ${message.data}');

//     // Handle the notification tap based on your app's navigation requirements
//     _handleNotificationTap(message.data['projectId']);
//   }

//   // Handle notification tap
//   void _handleNotificationTap(String? payload) {
//     if (payload != null && payload.isNotEmpty) {
//       // Here you should implement navigation to the appropriate screen
//       // Example using GetX:
//       // Get.toNamed('/project-details/$payload');
//       print('Should navigate to project with ID: $payload');
//     }
//   }

//   // Save FCM token to Firestore
//   Future<void> _saveTokenToDatabase(String token) async {
//     try {
//       // Get the current user
//       final User? user = _auth.currentUser;
//       if (user == null) {
//         print('Cannot save token: No user logged in');
//         return;
//       }

//       final String uid = user.uid;
//       print('Saving token for user: $uid');

//       // Check user role and update the appropriate collection
//       bool tokenSaved = false;

//       // Try Employee collection first
//       final employeeRef = _firestore.collection('Employees').doc(uid);
//       final employeeDoc = await employeeRef.get();

//       if (employeeDoc.exists) {
//         await employeeRef.update({
//           'fcmToken': token,
//           'lastTokenUpdate': FieldValue.serverTimestamp(),
//           'deviceInfo': {
//             'platform': Platform.operatingSystem,
//             'version': Platform.operatingSystemVersion,
//             'updatedAt': FieldValue.serverTimestamp(),
//           }
//         });

//         print('FCM token saved for employee: $uid');
//         tokenSaved = true;
//       }

//       // If not found in employees, try managers
//       if (!tokenSaved) {
//         final managerRef = _firestore.collection('Managers').doc(uid);
//         final managerDoc = await managerRef.get();

//         if (managerDoc.exists) {
//           await managerRef.update({
//             'fcmToken': token,
//             'lastTokenUpdate': FieldValue.serverTimestamp(),
//             'deviceInfo': {
//               'platform': Platform.operatingSystem,
//               'version': Platform.operatingSystemVersion,
//               'updatedAt': FieldValue.serverTimestamp(),
//             }
//           });

//           print('FCM token saved for manager: $uid');
//           tokenSaved = true;
//         }
//       }

//       // If not found in managers, try admin
//       if (!tokenSaved) {
//         final adminRef = _firestore.collection('Admin').doc(uid);
//         final adminDoc = await adminRef.get();

//         if (adminDoc.exists) {
//           await adminRef.update({
//             'fcmToken': token,
//             'lastTokenUpdate': FieldValue.serverTimestamp(),
//             'deviceInfo': {
//               'platform': Platform.operatingSystem,
//               'version': Platform.operatingSystemVersion,
//               'updatedAt': FieldValue.serverTimestamp(),
//             }
//           });

//           print('FCM token saved for admin: $uid');
//           tokenSaved = true;
//         }
//       }

//       if (!tokenSaved) {
//         print('User $uid not found in any role collection');
//       }

//       // Also add a direct entry to a dedicated tokens collection for easier querying
//       await _firestore.collection('userTokens').doc(uid).set({
//         'token': token,
//         'updatedAt': FieldValue.serverTimestamp(),
//         'platform': Platform.operatingSystem,
//         'userId': uid,
//         'app': 'solar_app', // Useful if you have multiple apps
//       });

//       print('Token also saved to userTokens collection');
//     } catch (e) {
//       print('Error saving token to database: $e');
//     }
//   }

//   // Display local notification from FCM data
//   void _showLocalNotificationFromRemote(RemoteMessage message) async {
//     try {
//       final notificationTitle =
//           message.notification?.title ?? 'New Notification';
//       final notificationBody = message.notification?.body ?? '';

//       print(
//           'Showing local notification: $notificationTitle - $notificationBody');

//       // Create platform-specific notification details
//       final AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//         _channelId,
//         _channelName,
//         channelDescription: _channelDescription,
//         importance: Importance.max,
//         priority: Priority.high,
//         playSound: true,
//         enableVibration: true,
//         styleInformation: BigTextStyleInformation(
//           notificationBody,
//           htmlFormatBigText: true,
//           contentTitle: notificationTitle,
//           htmlFormatContentTitle: true,
//         ),
//       );

//       final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//         badgeNumber: 1,
//       );

//       final NotificationDetails platformDetails = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       // Extract notification ID from data or use hashCode
//       final int notificationId =
//           int.tryParse(message.data['notificationId'] ?? '') ??
//               message.hashCode;

//       await _notificationsPlugin.show(
//         notificationId,
//         notificationTitle,
//         notificationBody,
//         platformDetails,
//         payload: message.data['projectId'] ?? '',
//       );

//       print('Local notification displayed from remote message');
//     } catch (e) {
//       print('Error showing local notification: $e');
//     }
//   }

//   // Show a local notification (only appears on current device)
//   Future<void> showNotification({
//     required String title,
//     required String body,
//     int id = 0,
//     String? payload,
//   }) async {
//     try {
//       // Create platform-specific notification details
//       final AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//         _channelId,
//         _channelName,
//         channelDescription: _channelDescription,
//         importance: Importance.high,
//         priority: Priority.high,
//         ticker: 'ticker',
//       );

//       final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );

//       final NotificationDetails platformDetails = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       await _notificationsPlugin.show(
//         id,
//         title,
//         body,
//         platformDetails,
//         payload: payload,
//       );

//       print('Local notification displayed: $title');
//     } catch (e) {
//       print("Error showing notification: $e");
//     }
//   }

//   // Send notification to specific employee (by uid)
//   Future<void> sendNotificationToEmployee({
//     required String employeeId,
//     required String title,
//     required String body,
//     Map<String, dynamic>? data,
//   }) async {
//     try {
//       print('Preparing to send notification to employee: $employeeId');

//       // Get the employee's FCM token
//       String? fcmToken;

//       // First try to get token from the dedicated tokens collection (faster)
//       final tokenDoc =
//           await _firestore.collection('userTokens').doc(employeeId).get();
//       if (tokenDoc.exists) {
//         fcmToken = tokenDoc.data()?['token'];
//         print('Found token in userTokens collection');
//       }

//       // If token not found in dedicated collection, try employee collection
//       if (fcmToken == null || fcmToken.isEmpty) {
//         final employeeDoc =
//             await _firestore.collection('Employees').doc(employeeId).get();
//         if (employeeDoc.exists) {
//           fcmToken = employeeDoc.data()?['fcmToken'];
//           print('Found token in Employees collection');
//         } else {
//           print('Employee not found: $employeeId');
//         }
//       }

//       // Also check Managers collection
//       if (fcmToken == null || fcmToken.isEmpty) {
//         final managerDoc =
//             await _firestore.collection('Managers').doc(employeeId).get();
//         if (managerDoc.exists) {
//           fcmToken = managerDoc.data()?['fcmToken'];
//           print('Found token in Managers collection');
//         }
//       }

//       // Also check Admin collection
//       if (fcmToken == null || fcmToken.isEmpty) {
//         final adminDoc =
//             await _firestore.collection('Admin').doc(employeeId).get();
//         if (adminDoc.exists) {
//           fcmToken = adminDoc.data()?['fcmToken'];
//           print('Found token in Admin collection');
//         }
//       }

//       if (fcmToken == null || fcmToken.isEmpty) {
//         print('⚠️ No FCM token found for employee: $employeeId');

//         // Create notification entry anyway, but mark as undeliverable
//         await _firestore.collection('notifications').add({
//           'title': title,
//           'body': body,
//           'data': data ?? {},
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': 'undeliverable',
//           'recipientId': employeeId,
//           'error': 'No FCM token available',
//         });

//         return;
//       }

//       print('Found FCM token: $fcmToken');

//       // Add any additional data needed for routing
//       final Map<String, dynamic> notificationData = {
//         'token': fcmToken,
//         'title': title,
//         'body': body,
//         'data': {
//           ...data ?? {},
//           'sentAt': DateTime.now().millisecondsSinceEpoch.toString(),
//           'senderId': _auth.currentUser?.uid ?? 'system',
//           'click_action': 'FLUTTER_NOTIFICATION_CLICK', // Important for Flutter
//         },
//         'timestamp': FieldValue.serverTimestamp(),
//         'status': 'pending',
//         'recipientId': employeeId,
//         'senderInfo': {
//           'userId': _auth.currentUser?.uid,
//           'email': _auth.currentUser?.email,
//         }
//       };

//       // Create the cloud function call to send the notification
//       final docRef =
//           await _firestore.collection('notifications').add(notificationData);

//       print('✅ Notification request queued with ID: ${docRef.id}');

//       // For debugging: Listen to the notification document for status updates
//       docRef.snapshots().listen((snapshot) {
//         if (snapshot.exists) {
//           final status = snapshot.data()?['status'];
//           print('Notification ${docRef.id} status updated to: $status');

//           if (status == 'failed') {
//             final error = snapshot.data()?['error'];
//             print('❌ Notification failed: $error');
//           }
//         }
//       });
//     } catch (e) {
//       print('Error sending notification to employee: $e');
//     }
//   }
// }

// class FCMTokenManager {
//   static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   static final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Call this when the app starts and when a user logs in
//   static Future<void> initialize() async {
//     // Request notification permissions
//     await _requestPermissions();

//     // Set up token refresh listener
//     _messaging.onTokenRefresh.listen(_updateTokenInFirestore);

//     // Update token on app start
//     await updateToken();
//   }

//   // Request notification permissions
//   static Future<void> _requestPermissions() async {
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//     );

//     print(
//         'User granted notification permission: ${settings.authorizationStatus}');
//   }

//   // Update the token
//   static Future<void> updateToken() async {
//     if (_auth.currentUser == null) {
//       print('Cannot update FCM token: No user logged in');
//       return;
//     }

//     String? token = await _messaging.getToken();
//     if (token != null) {
//       await _updateTokenInFirestore(token);
//     }
//   }

//   // Update token in Firestore
//   static Future<void> _updateTokenInFirestore(String token) async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user == null) return;

//       final String uid = user.uid;

//       // Check user role - first check if employee
//       final employeeDoc =
//           await _firestore.collection('Employees').doc(uid).get();
//       if (employeeDoc.exists) {
//         await _firestore.collection('Employees').doc(uid).update({
//           'fcmToken': token,
//           'lastTokenUpdate': FieldValue.serverTimestamp(),
//           'deviceInfo': {
//             'platform': await _getPlatformInfo(),
//             'updatedAt': FieldValue.serverTimestamp(),
//           }
//         });
//         print('FCM token updated for employee: $uid');
//         return;
//       }

//       // Check if manager
//       final managerDoc = await _firestore.collection('Managers').doc(uid).get();
//       if (managerDoc.exists) {
//         await _firestore.collection('Managers').doc(uid).update({
//           'fcmToken': token,
//           'lastTokenUpdate': FieldValue.serverTimestamp(),
//         });
//         print('FCM token updated for manager: $uid');
//         return;
//       }

//       // Check if admin
//       final adminDoc = await _firestore.collection('Admin').doc(uid).get();
//       if (adminDoc.exists) {
//         await _firestore.collection('Admin').doc(uid).update({
//           'fcmToken': token,
//           'lastTokenUpdate': FieldValue.serverTimestamp(),
//         });
//         print('FCM token updated for admin: $uid');
//         return;
//       }

//       print('User $uid not found in any role collection');
//     } catch (e) {
//       print('Error updating FCM token: $e');
//     }
//   }

//   // Get platform info (basic example)
//   static Future<String> _getPlatformInfo() async {
//     // In a real app, you'd use a package like 'device_info_plus'
//     // to get more detailed information
//     try {
//       return 'Android'; // This is simplified
//     } catch (e) {
//       return 'Unknown';
//     }
//   }

//   // Call this when user logs out
//   static Future<void> deleteToken() async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user == null) return;

//       final String uid = user.uid;

//       // Try to update token to empty in all possible collections
//       try {
//         await _firestore.collection('Employees').doc(uid).update({
//           'fcmToken': '',
//           'lastTokenUpdate': FieldValue.serverTimestamp(),
//         });
//       } catch (_) {}

//       try {
//         await _firestore.collection('Managers').doc(uid).update({
//           'fcmToken': '',
//           'lastTokenUpdate': FieldValue.serverTimestamp(),
//         });
//       } catch (_) {}

//       try {
//         await _firestore.collection('Admin').doc(uid).update({
//           'fcmToken': '',
//           'lastTokenUpdate': FieldValue.serverTimestamp(),
//         });
//       } catch (_) {}

//       // Delete the token from FCM
//       await _messaging.deleteToken();

//       print('FCM token deleted for user: $uid');
//     } catch (e) {
//       print('Error deleting FCM token: $e');
//     }
//   }
// }

// // class NotificationService extends GetxService {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
// //   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
// //       FlutterLocalNotificationsPlugin();

// //   static NotificationService get to => Get.find<NotificationService>();

// //   Future<NotificationService> init() async {
// //     // Request permission for notifications
// //     NotificationSettings settings = await _firebaseMessaging.requestPermission(
// //       alert: true,
// //       announcement: false,
// //       badge: true,
// //       carPlay: false,
// //       criticalAlert: false,
// //       provisional: false,
// //       sound: true,
// //     );

// //     print('User granted permission: ${settings.authorizationStatus}');

// //     // Initialize local notifications
// //     const AndroidInitializationSettings initializationSettingsAndroid =
// //         AndroidInitializationSettings('@mipmap/ic_launcher');
// //     final DarwinInitializationSettings initializationSettingsIOS =
// //         DarwinInitializationSettings();

// //     final InitializationSettings initializationSettings =
// //         InitializationSettings(
// //       android: initializationSettingsAndroid,
// //       iOS: initializationSettingsIOS,
// //     );

// //     await _flutterLocalNotificationsPlugin.initialize(
// //       initializationSettings,
// //       onDidReceiveNotificationResponse:
// //           (NotificationResponse notificationResponse) {
// //         // Handle notification tap
// //         print('Notification tapped: ${notificationResponse.payload}');
// //       },
// //     );

// //     // Listen for FCM tokens
// //     _firebaseMessaging.getToken().then((String? token) {
// //       if (token != null) {
// //         print('FCM Token: $token');
// //         // You might want to store this token in user's document
// //         _updateUserFCMToken(token);
// //       }
// //     });

// //     // Listen for token refreshes
// //     FirebaseMessaging.instance.onTokenRefresh.listen(_updateUserFCMToken);

// //     // Handle received messages when app is in foreground
// //     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
// //       print('Got a message whilst in the foreground!');
// //       print('Message data: ${message.data}');

// //       if (message.notification != null) {
// //         print('Message also contained a notification: ${message.notification}');
// //         _showLocalNotification(message);
// //       }
// //     });

// //     return this;
// //   }

// //   // Update the user's FCM token in Firestore
// //   Future<void> _updateUserFCMToken(String token) async {
// //     try {
// //       final user = FirebaseAuth.instance.currentUser;
// //       if (user != null) {
// //         // Check where the user exists - Admin, Manager, or Employee
// //         final adminDoc =
// //             await _firestore.collection("Admin").doc(user.uid).get();
// //         final managerDoc =
// //             await _firestore.collection("Managers").doc(user.uid).get();
// //         final employeeDoc =
// //             await _firestore.collection("Employees").doc(user.uid).get();

// //         if (adminDoc.exists) {
// //           await _firestore.collection("Admin").doc(user.uid).update({
// //             'fcmToken': token,
// //           });
// //         } else if (managerDoc.exists) {
// //           await _firestore.collection("Managers").doc(user.uid).update({
// //             'fcmToken': token,
// //           });
// //         } else if (employeeDoc.exists) {
// //           await _firestore.collection("Employees").doc(user.uid).update({
// //             'fcmToken': token,
// //           });
// //         }
// //       }
// //     } catch (e) {
// //       print('Error updating FCM token: $e');
// //     }
// //   }

// //   // Show a local notification
// //   Future<void> _showLocalNotification(RemoteMessage message) async {
// //     const AndroidNotificationDetails androidNotificationDetails =
// //         AndroidNotificationDetails(
// //       'high_importance_channel',
// //       'High Importance Notifications',
// //       channelDescription: 'This channel is used for important notifications.',
// //       importance: Importance.max,
// //       priority: Priority.high,
// //     );
// //     const NotificationDetails notificationDetails = NotificationDetails(
// //       android: androidNotificationDetails,
// //       iOS: DarwinNotificationDetails(),
// //     );

// //     await _flutterLocalNotificationsPlugin.show(
// //       message.notification.hashCode,
// //       message.notification?.title,
// //       message.notification?.body,
// //       notificationDetails,
// //       payload: message.data['projectId'],
// //     );
// //   }

// //   // Send notification to a specific user
// //   Future<void> sendNotificationToUser({
// //     required String userId,
// //     required String title,
// //     required String body,
// //     Map<String, dynamic>? data,
// //   }) async {
// //     try {
// //       // Get the user's FCM token
// //       String? userToken;

// //       // Check in all collections
// //       final adminDoc = await _firestore.collection("Admin").doc(userId).get();
// //       final managerDoc =
// //           await _firestore.collection("Managers").doc(userId).get();
// //       final employeeDoc =
// //           await _firestore.collection("Employees").doc(userId).get();

// //       if (adminDoc.exists && adminDoc.data()!.containsKey('fcmToken')) {
// //         userToken = adminDoc.data()!['fcmToken'];
// //       } else if (managerDoc.exists &&
// //           managerDoc.data()!.containsKey('fcmToken')) {
// //         userToken = managerDoc.data()!['fcmToken'];
// //       } else if (employeeDoc.exists &&
// //           employeeDoc.data()!.containsKey('fcmToken')) {
// //         userToken = employeeDoc.data()!['fcmToken'];
// //       }

// //       if (userToken == null) {
// //         print('FCM token not found for user: $userId');
// //         return;
// //       }

// //       // Store the notification in Firestore
// //       await _firestore.collection("Notifications").add({
// //         'userId': userId,
// //         'title': title,
// //         'body': body,
// //         'data': data,
// //         'isRead': false,
// //         'createdAt': FieldValue.serverTimestamp(),
// //       });

// //       // Send notification through FCM
// //       // Note: For production, this would be done through a secure backend service or Cloud Functions
// //       // This is just for demonstration purposes
// //       print('Notification would be sent to token: $userToken');
// //     } catch (e) {
// //       print('Error sending notification: $e');
// //     }
// //   }

// //   // Send notification for project assignment
// //   Future<void> sendProjectAssignmentNotification({
// //     required String userId,
// //     required String projectId,
// //     required String projectName,
// //   }) async {
// //     await sendNotificationToUser(
// //         userId: userId,
// //         title: 'New Project Assigned',
// //         body: 'You have been assigned to the project: $projectName',
// //         data: {'projectId': projectId, 'type': 'project_assignment'});
// //   }

// //   // Get all notifications for a specific user
// //   Stream<QuerySnapshot> getUserNotificationsStream(String userId) {
// //     return _firestore
// //         .collection("Notifications")
// //         .where('userId', isEqualTo: userId)
// //         .orderBy('createdAt', descending: true)
// //         .snapshots();
// //   }

// //   // Mark notification as read
// //   Future<void> markNotificationAsRead(String notificationId) async {
// //     await _firestore.collection("Notifications").doc(notificationId).update({
// //       'isRead': true,
// //     });
// //   }
// // }

// // class NotificationIndicator extends StatelessWidget {
// //   const NotificationIndicator({Key? key}) : super(key: key);

// //   @override
// //   Widget build(BuildContext context) {
// //     final User? currentUser = FirebaseAuth.instance.currentUser;

// //     if (currentUser == null) {
// //       return IconButton(
// //         icon: Icon(Icons.notifications),
// //         onPressed: () {
// //           Get.snackbar('Error', 'Please log in to view notifications');
// //         },
// //       );
// //     }

// //     return StreamBuilder<QuerySnapshot>(
// //       stream: FirebaseFirestore.instance
// //           .collection('Notifications')
// //           .where('userId', isEqualTo: currentUser.uid)
// //           .where('isRead', isEqualTo: false)
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         if (snapshot.hasError) {
// //           return IconButton(
// //             icon: Icon(Icons.notifications),
// //             onPressed: () {
// //               Get.toNamed('/notifications');
// //             },
// //           );
// //         }

// //         int unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

// //         return Stack(
// //           alignment: Alignment.center,
// //           children: [
// //             IconButton(
// //               icon: Icon(Icons.notifications),
// //               onPressed: () {
// //                 Get.toNamed('/notifications');
// //               },
// //             ),
// //             if (unreadCount > 0)
// //               Positioned(
// //                 top: 8,
// //                 right: 8,
// //                 child: Container(
// //                   padding: EdgeInsets.all(2),
// //                   decoration: BoxDecoration(
// //                     color: Colors.red,
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   constraints: BoxConstraints(
// //                     minWidth: 16,
// //                     minHeight: 16,
// //                   ),
// //                   child: Text(
// //                     unreadCount > 9 ? '9+' : unreadCount.toString(),
// //                     style: TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 10,
// //                     ),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// // }
