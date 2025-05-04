// import 'package:admin/Common%20widgets/notification_services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final User? currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Notifications')),
//         body: const Center(child: Text('Please log in to view notifications')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream:
//             NotificationService.to.getUserNotificationsStream(currentUser.uid),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text('No notifications yet'));
//           }

//           final notifications = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final notificationData =
//                   notifications[index].data() as Map<String, dynamic>;
//               final notificationId = notifications[index].id;
//               final isRead = notificationData['isRead'] ?? false;
//               final timestamp = notificationData['createdAt'] as Timestamp?;
//               final timeAgo = timestamp != null
//                   ? timeago.format(timestamp.toDate())
//                   : 'Unknown time';

//               return Dismissible(
//                 key: Key(notificationId),
//                 background: Container(
//                   color: Colors.red,
//                   alignment: Alignment.centerRight,
//                   padding: const EdgeInsets.only(right: 20.0),
//                   child: const Icon(Icons.delete, color: Colors.white),
//                 ),
//                 direction: DismissDirection.endToStart,
//                 onDismissed: (direction) {
//                   // Delete the notification
//                   FirebaseFirestore.instance
//                       .collection('Notifications')
//                       .doc(notificationId)
//                       .delete();

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Notification deleted')),
//                   );
//                 },
//                 child: Card(
//                   elevation: isRead ? 1 : 3,
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   color: isRead ? null : Colors.blue.shade50,
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: isRead ? Colors.grey : Colors.blue,
//                       child: Icon(
//                         Icons.notifications,
//                         color: Colors.white,
//                       ),
//                     ),
//                     title: Text(
//                       notificationData['title'] ?? 'Notification',
//                       style: TextStyle(
//                         fontWeight:
//                             isRead ? FontWeight.normal : FontWeight.bold,
//                       ),
//                     ),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(notificationData['body'] ?? ''),
//                         const SizedBox(height: 4),
//                         Text(
//                           timeAgo,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontStyle: FontStyle.italic,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                     onTap: () {
//                       // Mark as read
//                       if (!isRead) {
//                         NotificationService.to
//                             .markNotificationAsRead(notificationId);
//                       }

//                       // Handle notification tap based on type
//                       final data =
//                           notificationData['data'] as Map<String, dynamic>?;
//                       if (data != null && data.containsKey('projectId')) {
//                         final projectId = data['projectId'];
//                         if (data['type'] == 'project_assignment') {
//                           // Navigate to project details
//                           Get.toNamed('/project-details/$projectId');
//                         }
//                       }
//                     },
//                     trailing: !isRead
//                         ? Container(
//                             width: 12,
//                             height: 12,
//                             decoration: BoxDecoration(
//                               color: Colors.blue,
//                               shape: BoxShape.circle,
//                             ),
//                           )
//                         : null,
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
