import 'package:admin/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPageController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController name = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  RxBool isLoading = false.obs; // Ensure state management works

  RxBool isPasswordHidden = true.obs;
  RxBool isConfirmPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> registerAdmin(String name, String email, String password) async {
    try {
      // Create admin in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add admin details to Firestore
      await _firestore.collection("Admin").doc(userCredential.user?.uid).set({
        "name": name,
        "email": email,
        "createdBy": "system", // Or the UID of the user who created this admin
      });

      Get.snackbar("Success", "Admin registered successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> signupAdmin() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }
    isLoading.value = true;
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _firestore.collection("Admin").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "name": name.text.trim(),
        "email": emailController.text.trim(),
        "role": "Admin",
      });

      Get.snackbar("Success", "Signup Successful!");
      Get.offAllNamed(Routes.DASH_BOARD);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
    isLoading.value = false;
  }
}

class AdminModel {
  String name;
  String uid;
  String email;
  String role;

  AdminModel({
    required this.name,
    required this.uid,
    required this.email,
    this.role = "Admin",
  });

  // Convert AdminModel to JSON (for Firebase storage)
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "role": role,
    };
  }

  // Convert JSON to AdminModel
  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? "Admin",
    );
  }
}
