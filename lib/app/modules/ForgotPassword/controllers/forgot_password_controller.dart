import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> sendPasswordReset() async {
    if (emailController.text.isEmpty) {
      Get.snackbar("Error", "Please enter your email");
      return;
    }

    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());

      Get.snackbar("Success", "Password reset link sent! Check your email.");
      Get.back();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
    isLoading.value = false;
  }
}
