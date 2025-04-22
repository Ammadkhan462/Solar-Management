import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/app/routes/app_pages.dart';

class LoginPageController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool isPasswordHidden = true.obs;
  RxBool rememberMe = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> loginAdmin() async {
    try {
      isLoading.value = true;

      // Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Get the UID of the logged-in user
      String uid = userCredential.user!.uid;

      // Fetch admin data from Firestore using the UID
      DocumentSnapshot adminDoc =
          await _firestore.collection("Admin").doc(uid).get();

      if (adminDoc.exists) {
        // Persist the user's UID and route
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userUid', uid);
        await prefs.setString('lastRoute', Routes.DASH_BOARD);

        Get.offNamed(Routes.DASH_BOARD); // Redirect to Admin Dashboard
      } else {
        await _auth.signOut(); // Log out if the user is not an admin
        Get.snackbar("Error", "You are not authorized as an Admin.");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "An error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe.value) {
      await prefs.setString('saved_email', emailController.text);
      await prefs.setString('saved_password', passwordController.text);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('saved_email') ?? "";
    passwordController.text = prefs.getString('saved_password') ?? "";
    rememberMe.value = emailController.text.isNotEmpty;
  }
}
