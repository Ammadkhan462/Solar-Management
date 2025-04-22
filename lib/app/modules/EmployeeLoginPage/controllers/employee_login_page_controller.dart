import 'package:admin/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Employee {
  String uid;
  String name;
  String email;
  String password;
  String role;
  String? designation; // Add this field
  String? managerId; // Add this field

  Employee({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.designation,
    this.managerId,
  });

  // Convert Firestore data to Employee object
  factory Employee.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Employee(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      role: data['role'] ?? '',
      designation: data['designation'] ?? '', // Add this field
      managerId: data['managerId'] ?? '', // Add this field
    );
  }
  // Convert Employee object to a Map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}

class EmployeeLoginPageController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordHidden = true.obs;
  final RxBool isLoading = false.obs;
  Future<void> loginEmployee() async {
    try {
      isLoading.value = true;

      // Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Get the UID of the logged-in user
      String uid = userCredential.user!.uid;

      // Fetch employee data from Firestore using the UID
      DocumentSnapshot employeeDoc =
          await _firestore.collection("Employees").doc(uid).get();

      if (employeeDoc.exists) {
        // Persist the user's UID and route
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userUid', uid);
        await prefs.setString('lastRoute', Routes.EMPLOYEE_DASHBOARD);

        Get.offNamed(
            Routes.EMPLOYEE_DASHBOARD); // Redirect to Employee Dashboard
      } else {
        await _auth.signOut(); // Log out if the user is not an employee
        Get.snackbar("Error", "You are not authorized as an Employee.");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "An error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.toggle();
  }
}
