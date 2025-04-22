import 'dart:math';

import 'package:admin/app/modules/EmployeesRegistration/controllers/employees_registration_controller.dart';
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

  // List to Store Registered Employees
  var employeesList = <EmployeeModel>[].obs;

  // List to Store Managers (if needed)
  var managersList = <EmployeeModel>[].obs; // New list for managers

  var isLoading = false.obs;

  // Register employee method
  Future<void> registerEmployee(
      String name, String cnic, String designation) async {
    try {
      isLoading.value = true;

      // Generate employee email and password
      String employeeEmail =
          "${name.replaceAll(' ', '').toLowerCase()}@company.com";
      String employeePassword = _generateRandomPassword(8);

      // Create employee in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: employeeEmail,
        password: employeePassword,
      );

      String employeeUID = userCredential.user!.uid;

      // Store employee details in Firestore
      EmployeeModel newEmployee = EmployeeModel(
        uid: employeeUID,
        name: name,
        email: employeeEmail,
        password: employeePassword,
        cnic: cnic,
        designation: designation,
      );

      await _firestore
          .collection("Employees")
          .doc(employeeUID)
          .set(newEmployee.toJson());

      isLoading.value = false;

      // Fetch updated list of employees after registration
      fetchEmployees();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString());
    }
  }

  // Fetch All Registered Employees
  void fetchEmployees() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("Employees").get();
      employeesList.value = querySnapshot.docs
          .map((doc) =>
              EmployeeModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch employees: $e");
    }
  }

  String _generateRandomPassword(int length) {
    const String chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%^&*";

    Random random = Random();

    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
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
