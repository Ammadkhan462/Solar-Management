import 'dart:math';

import 'package:admin/app/modules/ManagerDashboard/controllers/manager_dashboard_controller.dart';
import 'package:admin/app/modules/ManagerPanel/controllers/manager_panel_controller.dart'
    as panel;
import 'package:admin/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ManagerDashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var managersList = <ManagerModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchManagers(); // Fetch managers when controller initializes
  }

  // Fetch All Registered Managers
  void fetchManagers() async {
    try {
      isLoading.value = true;
      QuerySnapshot querySnapshot =
          await _firestore.collection("Managers").get();

      managersList.value = querySnapshot.docs
          .map((doc) =>
              ManagerModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to fetch managers: $e");
    }
  }
}

class ManagerModel {
  String uid;
  String name;
  String email;
  String password;
  String cnic;
  String adminUid;

  ManagerModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.cnic,
    required this.adminUid,
  });

  // Convert Manager object to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'cnic': cnic,
      'adminUid': adminUid,
    };
  }

  // Convert JSON to Manager object
  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      cnic: json['cnic'] ?? '',
      adminUid: json['adminUid'] ?? '',
    );
  }
}

class EmployeeModel {
  String uid;
  String name;
  String email;
  String password;
  String cnic;
  String designation;

  EmployeeModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.cnic,
    required this.designation,
  });

  // Convert Employee object to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'cnic': cnic,
      'designation': designation,
    };
  }

  // Convert JSON to Employee object
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      cnic: json['cnic'],
      designation: json['designation'],
    );
  }
}
