import 'dart:math';
import 'package:admin/app/modules/EmployeesRegistration/views/employeedetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EmployeesRegistrationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;

  // Create Employee with generated credentials
  Future<void> registerEmployee(
      String name, String cnic, String position) async {
    try {
      isLoading.value = true;

      // Generate employee email
      String employeeEmail =
          "${name.replaceAll(' ', '').toLowerCase()}@company.com";

      // Generate random password
      String employeePassword = _generateRandomPassword(8);

      // Create the employee in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: employeeEmail,
        password: employeePassword,
      );

      String employeeUID = userCredential.user!.uid;

      // Create employee data model
      EmployeeModel newEmployee = EmployeeModel(
        uid: employeeUID,
        name: name,
        email: employeeEmail,
        password: employeePassword,
        cnic: cnic,
        position: position,
        createdBy: _auth.currentUser!
            .uid, // You can also store the manager or admin UID here
      );

      // Save employee data to Firestore
      await _firestore
          .collection("Employees")
          .doc(employeeUID)
          .set(newEmployee.toJson());

      // After successful creation, navigate to the employee details screen
      isLoading.value = false;
      Get.to(() => EmployeeDetailsView(
          employeeUID:
              employeeUID)); // Pass the employee UID to the next screen
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString());
    }
  }

  // Generate a random password for the employee
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
  String position;
  String createdBy;

  EmployeeModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.cnic,
    required this.position,
    required this.createdBy, // This could be the UID of the admin/manager who created the employee
  });

  // Convert EmployeeModel to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'password': password,
      'cnic': cnic,
      'position': position,
      'createdBy': createdBy, // Who created this employee (admin/manager UID)
    };
  }

  // Convert Firestore document to EmployeeModel
  factory EmployeeModel.fromFirestore(Map<String, dynamic> firestoreData) {
    return EmployeeModel(
      uid: firestoreData['uid'],
      name: firestoreData['name'],
      email: firestoreData['email'],
      password: firestoreData['password'],
      cnic: firestoreData['cnic'],
      position: firestoreData['position'],
      createdBy: firestoreData['createdBy'],
    );
  }
}
