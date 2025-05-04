// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class NotificationService extends GetxService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static NotificationService get to => Get.find<NotificationService>();

//   Future<NotificationService> init() async {
//     // Request permission for notifications
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     print('User granted permission: ${settings.authorizationStatus}');

//     // Initialize local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     final DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings();

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse:
//           (NotificationResponse notificationResponse) {
//         // Handle notification tap
//         print('Notification tapped: ${notificationResponse.payload}');
//       },
//     );

//     // Listen for FCM tokens
//     _firebaseMessaging.getToken().then((String? token) {
//       if (token != null) {
//         print('FCM Token: $token');
//         // You might want to store this token in user's document
//         _updateUserFCMToken(token);
//       }
//     });

//     // Listen for token refreshes
//     FirebaseMessaging.instance.onTokenRefresh.listen(_updateUserFCMToken);

//     // Handle received messages when app is in foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Got a message whilst in the foreground!');
//       print('Message data: ${message.data}');

//       if (message.notification != null) {
//         print('Message also contained a notification: ${message.notification}');
//         _showLocalNotification(message);
//       }
//     });

//     return this;
//   }

//   // Update the user's FCM token in Firestore
//   Future<void> _updateUserFCMToken(String token) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         // Check where the user exists - Admin, Manager, or Employee
//         final adminDoc =
//             await _firestore.collection("Admin").doc(user.uid).get();
//         final managerDoc =
//             await _firestore.collection("Managers").doc(user.uid).get();
//         final employeeDoc =
//             await _firestore.collection("Employees").doc(user.uid).get();

//         if (adminDoc.exists) {
//           await _firestore.collection("Admin").doc(user.uid).update({
//             'fcmToken': token,
//           });
//         } else if (managerDoc.exists) {
//           await _firestore.collection("Managers").doc(user.uid).update({
//             'fcmToken': token,
//           });
//         } else if (employeeDoc.exists) {
//           await _firestore.collection("Employees").doc(user.uid).update({
//             'fcmToken': token,
//           });
//         }
//       }
//     } catch (e) {
//       print('Error updating FCM token: $e');
//     }
//   }

//   // Show a local notification
//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       channelDescription: 'This channel is used for important notifications.',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: DarwinNotificationDetails(),
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       message.notification.hashCode,
//       message.notification?.title,
//       message.notification?.body,
//       notificationDetails,
//       payload: message.data['projectId'],
//     );
//   }

//   // Send notification to a specific user
//   Future<void> sendNotificationToUser({
//     required String userId,
//     required String title,
//     required String body,
//     Map<String, dynamic>? data,
//   }) async {
//     try {
//       // Get the user's FCM token
//       String? userToken;

//       // Check in all collections
//       final adminDoc = await _firestore.collection("Admin").doc(userId).get();
//       final managerDoc =
//           await _firestore.collection("Managers").doc(userId).get();
//       final employeeDoc =
//           await _firestore.collection("Employees").doc(userId).get();

//       if (adminDoc.exists && adminDoc.data()!.containsKey('fcmToken')) {
//         userToken = adminDoc.data()!['fcmToken'];
//       } else if (managerDoc.exists &&
//           managerDoc.data()!.containsKey('fcmToken')) {
//         userToken = managerDoc.data()!['fcmToken'];
//       } else if (employeeDoc.exists &&
//           employeeDoc.data()!.containsKey('fcmToken')) {
//         userToken = employeeDoc.data()!['fcmToken'];
//       }

//       if (userToken == null) {
//         print('FCM token not found for user: $userId');
//         return;
//       }

//       // Store the notification in Firestore
//       await _firestore.collection("Notifications").add({
//         'userId': userId,
//         'title': title,
//         'body': body,
//         'data': data,
//         'isRead': false,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       // Send notification through FCM
//       // Note: For production, this would be done through a secure backend service or Cloud Functions
//       // This is just for demonstration purposes
//       print('Notification would be sent to token: $userToken');
//     } catch (e) {
//       print('Error sending notification: $e');
//     }
//   }

//   // Send notification for project assignment
//   Future<void> sendProjectAssignmentNotification({
//     required String userId,
//     required String projectId,
//     required String projectName,
//   }) async {
//     await sendNotificationToUser(
//         userId: userId,
//         title: 'New Project Assigned',
//         body: 'You have been assigned to the project: $projectName',
//         data: {'projectId': projectId, 'type': 'project_assignment'});
//   }

//   // Get all notifications for a specific user
//   Stream<QuerySnapshot> getUserNotificationsStream(String userId) {
//     return _firestore
//         .collection("Notifications")
//         .where('userId', isEqualTo: userId)
//         .orderBy('createdAt', descending: true)
//         .snapshots();
//   }

//   // Mark notification as read
//   Future<void> markNotificationAsRead(String notificationId) async {
//     await _firestore.collection("Notifications").doc(notificationId).update({
//       'isRead': true,
//     });
//   }
// }

// class NotificationIndicator extends StatelessWidget {
//   const NotificationIndicator({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final User? currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       return IconButton(
//         icon: Icon(Icons.notifications),
//         onPressed: () {
//           Get.snackbar('Error', 'Please log in to view notifications');
//         },
//       );
//     }

//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('Notifications')
//           .where('userId', isEqualTo: currentUser.uid)
//           .where('isRead', isEqualTo: false)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return IconButton(
//             icon: Icon(Icons.notifications),
//             onPressed: () {
//               Get.toNamed('/notifications');
//             },
//           );
//         }

//         int unreadCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

//         return Stack(
//           alignment: Alignment.center,
//           children: [
//             IconButton(
//               icon: Icon(Icons.notifications),
//               onPressed: () {
//                 Get.toNamed('/notifications');
//               },
//             ),
//             if (unreadCount > 0)
//               Positioned(
//                 top: 8,
//                 right: 8,
//                 child: Container(
//                   padding: EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   constraints: BoxConstraints(
//                     minWidth: 16,
//                     minHeight: 16,
//                   ),
//                   child: Text(
//                     unreadCount > 9 ? '9+' : unreadCount.toString(),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
