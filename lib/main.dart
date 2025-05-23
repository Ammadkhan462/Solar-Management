import 'package:admin/Common%20widgets/notification_services.dart';
import 'package:admin/firebase_options.dart';
import 'package:admin/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

// Define the top-level handler for background messages
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Need to ensure Firebase is initialized for background handlers
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print("Handling a background message: ${message.messageId}");
//   print("Message data: ${message.data}");
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Loads platform-specific Firebase config
  );
  // Initialize notifications
  // final notificationService = FirebaseNotificationService();
  // await notificationService.initialize();

  // Initialize FCM token manager

  final AppController appController = Get.put(AppController());
  await appController._loadUserState();

  runApp(
    GetMaterialApp(
      title: "Admin & Manager App",
      initialRoute: appController.initialRoute,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}

class AppController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);
  String initialRoute = Routes.LOGIN_CHOICE; //  Default route
  @override
  void onInit() {
    super.onInit();
    _loadUserState(); // Load user state on app startup
    _auth
        .authStateChanges()
        .listen(_authStateChanged); // Listen for auth changes
  }

  Future<void> _loadUserState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userUid = prefs.getString('userUid');
    String? lastRoute = prefs.getString('lastRoute');

    if (userUid != null) {
      final adminDoc = await _firestore.collection("Admin").doc(userUid).get();
      final managerDoc =
          await _firestore.collection("Managers").doc(userUid).get();
      final employeeDoc =
          await _firestore.collection("Employees").doc(userUid).get();

      if (adminDoc.exists) {
        user.value = _auth.currentUser;
        initialRoute = lastRoute ?? Routes.DASH_BOARD;
      } else if (managerDoc.exists) {
        user.value = _auth.currentUser;
        initialRoute = lastRoute ?? Routes.MANAGER_PANEL;
      } else if (employeeDoc.exists) {
        user.value = _auth.currentUser;
        initialRoute = lastRoute ?? Routes.EMPLOYEE_DASHBOARD;
      } else {
        initialRoute = Routes.LOGIN_CHOICE;
      }
    } else {
      initialRoute = Routes.LOGIN_CHOICE;
    }

    // Update the UI once the session is loaded
    update();
  }

  // Check authentication state and update route accordingly
  void _authStateChanged(User? currentUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (currentUser != null) {
      user.value = currentUser;
      await prefs.setString(
          'userUid', currentUser.uid); // Persist the user's UID

      // Check if the user is an Admin, Manager, or Employee
      final adminDoc =
          await _firestore.collection("Admin").doc(currentUser.uid).get();
      final managerDoc =
          await _firestore.collection("Managers").doc(currentUser.uid).get();
      final employeeDoc =
          await _firestore.collection("Employees").doc(currentUser.uid).get();

      if (adminDoc.exists) {
        initialRoute = Routes.DASH_BOARD;
      } else if (managerDoc.exists) {
        initialRoute = Routes.MANAGER_PANEL;
      } else if (employeeDoc.exists) {
        initialRoute = Routes.EMPLOYEE_DASHBOARD;
      } else {
        initialRoute = Routes.LOGIN_CHOICE;
      }

      // Update the FCM token when the user logs in

      // Persist the last route
      await prefs.setString('lastRoute', initialRoute);
    } else {
      // Clear the FCM token when the user logs out

      await prefs.remove('userUid'); // Clear persisted data
      await prefs.remove('lastRoute'); // Clear last route
      initialRoute = Routes.LOGIN_CHOICE;
    }

    // Update UIs
    update();
  }
}
