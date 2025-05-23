import 'package:admin/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerLoginController extends GetxController {
  //TODO: Implement ManagerLoginController
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs; // Ensure `isLoading` is an RxBool
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordHidden = true.obs;
  final count = 0.obs;

  Future<void> loginManager() async {
    try {
      isLoading.value = true;

      // Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Get the UID of the logged-in user
      String uid = userCredential.user!.uid;

      // Fetch manager data from Firestore using the UID
      DocumentSnapshot managerDoc =
          await _firestore.collection("Managers").doc(uid).get();

      if (managerDoc.exists) {
        // Persist the user's UID and route
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userUid', uid);
        await prefs.setString('lastRoute', Routes.MANAGER_PANEL);

        // Print debug messages to ensure data is saved
        print('User UID saved: $uid');
        print('Last Route saved: ${Routes.MANAGER_PANEL}');

        Get.offNamed(Routes.MANAGER_PANEL); // Redirect to Manager Dashboard
      } else {
        Get.snackbar("Error", "You are not authorized as a Manager.");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "An error occurred");
    } finally {
      isLoading.value = false;
    }
  }
}
