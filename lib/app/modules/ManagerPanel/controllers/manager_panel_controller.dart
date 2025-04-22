import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerPanelController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var projects = <Map<String, dynamic>>[].obs;

  var manager = ManagerModel(uid: '', name: '', email: '', cnic: '').obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchManagerData();
    fetchAllEmployees();
    ever(manager, (_) {
      // Only fetch projects after the manager data is available
      if (manager.value.uid.isNotEmpty) {
        fetchPendingProjects(); // Fetch pending projects
      }
    });
    print("Fetching projects for manager ID: ${manager.value.uid}");
  }

  Future<void> fetchPendingProjects() async {
    isLoading.value = true;
    try {
      FirebaseFirestore.instance
          .collection("Projects")
          .where("managerId", isEqualTo: manager.value.uid)
          .where("status", whereIn: [
            'pending',
            'approved',
            'progress',
            'assigned',
            'completed',
            'doing'
          ])
          .snapshots()
          .listen((querySnapshot) {
            // Here, projects is a list of maps
            // In fetchPendingProjects() method
            projects.value = querySnapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;

              // Calculate progress for 'doing' and 'completed' projects
              if (data['taskVideos'] != null) {
                // Check if taskVideos is a Map or List and handle accordingly
                int completedVideos = 0;
                if (data['taskVideos'] is Map) {
                  // If it's a Map, count the entries
                  completedVideos = (data['taskVideos'] as Map).length;
                } else if (data['taskVideos'] is List) {
                  // If it's a List, count the items
                  completedVideos = (data['taskVideos'] as List).length;
                }

                // Get total tasks count
                int totalTasks = 1; // Default to 1 to avoid division by zero
                if (data['tasks'] is List) {
                  totalTasks = (data['tasks'] as List).length;
                } else if (data['tasks'] is Map) {
                  totalTasks = (data['tasks'] as Map).length;
                }

                data['progress'] =
                    ((completedVideos / totalTasks) * 100).round();
              } else {
                data['progress'] = 0;
              }

              return data;
            }).toList();
          });
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch projects: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignEngineerToProject(
      String projectId, String engineerId) async {
    try {
      // Update the project in Firestore with the assigned engineer
      await _firestore.collection("Projects").doc(projectId).update({
        "assignedEngineerId": engineerId,
        "status": "doing", // Update the status to 'assigned'
      });

      Get.snackbar("Success", "Engineer has been assigned to the project");
    } catch (e) {
      Get.snackbar("Error", "Failed to assign engineer: $e");
    }
  }

  Future<void> assignEngineerDialog(
      BuildContext context, String projectId) async {
    // Fetch all engineers for the current manager
    List<Map<String, dynamic>> engineers = await fetchAllEngineers();

    if (engineers.isEmpty) {
      Get.snackbar("No Engineers", "No engineers available for assignment");
      return;
    }

    String? selectedEngineer;

    // Show the dialog to pick an engineer
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Assign Engineer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...engineers.map((engineer) {
                // Ensure engineer data is valid
                final engineerName = engineer['name'] ?? 'Unknown';
                final engineerStatus = engineer['status'] ?? 'Unknown';
                final engineerUid = engineer['uid'];

                if (engineerUid == null) {
                  return const SizedBox(); // Skip invalid engineers
                }

                return ListTile(
                  title: Text(engineerName),
                  subtitle: Text("Status: $engineerStatus"),
                  onTap: () {
                    selectedEngineer = engineerUid; // Select the engineer
                    Navigator.of(context).pop(); // Close the dialog
                    assignEngineerToProject(projectId,
                        selectedEngineer!); // Assign engineer to project
                  },
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog if no engineer is selected
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllEngineers() async {
    try {
      String managerId = manager.value.uid; // Get the current manager's UID

      // Fetch engineers where managerId matches and the role is 'Engineer'
      QuerySnapshot querySnapshot = await _firestore
          .collection("Employees")
          .where("managerId", isEqualTo: managerId)
          .where("designation", isEqualTo: "Engineer") // Only fetch Engineers
          .get();

      List<Map<String, dynamic>> engineers = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print("Engineer Data: $data"); // Debug print
        engineers.add(data);
      }

      return engineers;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch engineers: $e");
      return [];
    }
  }

  // Method to generate employee credentials
  Future<Map<String, String>> generateEmployeeCredentials(String name) async {
    try {
      // Extract the domain from the manager's email (e.g., "manager@company.com" -> "company.com")
      String managerEmail = manager.value.email;
      String domain = managerEmail.split('@')[1]; // Debug the domain value
      print("Domain extracted: $domain");

      // Generate employee email (e.g., "john.doe@company.com")
      String employeeEmail =
          "${name.replaceAll(' ', '.').toLowerCase()}@$domain";

      // Generate a random password
      String employeePassword = _generateRandomPassword(8);

      return {
        'email': employeeEmail,
        'password': employeePassword,
      };
    } catch (e) {
      throw Exception("Failed to generate employee credentials: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllEmployees() async {
    try {
      String managerId = manager.value.uid; // Get the current manager's UID

      // Fetch all employees where managerId matches the logged-in manager's UID
      QuerySnapshot querySnapshot = await _firestore
          .collection("Employees")
          .where("managerId", isEqualTo: managerId)
          .get();

      List<Map<String, dynamic>> employees = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print("Employee Data: $data"); // Debug print
        employees.add(data);
      }

      return employees;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch employees: $e");
      return [];
    }
  }

  // Helper method to generate a random password
  String _generateRandomPassword(int length) {
    const String chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%^&*";
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> fetchManagerData() async {
    isLoading.value = true;
    try {
      User? user = _auth.currentUser; // Get the current logged-in user
      if (user != null) {
        String uid = user.uid; // Get the UID of the current user

        // Fetch manager data from Firestore
        DocumentSnapshot doc =
            await _firestore.collection("Managers").doc(uid).get();

        if (doc.exists) {
          manager.value =
              ManagerModel.fromJson(doc.data() as Map<String, dynamic>);
          print("Manager data fetched: UID = ${manager.value.uid}");
        } else {
          print("No manager data found for UID: $uid");
        }
      } else {
        print("No user is currently logged in.");
      }
    } catch (e) {
      print("Error fetching manager data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerEmployee(
      String name, String cnic, String designation) async {
    if (name.isEmpty || cnic.isEmpty || designation == null) {
      Get.snackbar("Error", "Name, CNIC, and designation are required",
          backgroundColor: Colors.red);

      return;
    }

    try {
      isLoading.value = true;

      // Generate employee credentials
      Map<String, String> credentials = await generateEmployeeCredentials(name);
      String employeeEmail = credentials['email']!;
      String employeePassword = credentials['password']!;

      // Create employee in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: employeeEmail,
        password: employeePassword,
      );

      String employeeUID = userCredential.user!.uid;

      // Create employee data
      Map<String, dynamic> employeeData = {
        "uid": employeeUID,
        "name": name,
        "email": employeeEmail,
        "password": employeePassword,
        "designation": designation,
        "cnic": cnic,
        "managerId": manager.value.uid, // Associate with the manager
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Save employee to Firestore under the "Employees" collection
      await _firestore
          .collection("Employees")
          .doc(employeeUID)
          .set(employeeData);

      isLoading.value = false;

      // Show success message with credentials
      Get.snackbar(
        "Success",
        "Employee registered successfully\nEmail: $employeeEmail\nPassword: $employeePassword",
        backgroundColor: Colors.green,
      );
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to create user: ${e.message}",
          backgroundColor: Colors.red);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to register employee: $e",
          backgroundColor: Colors.red);
    }
  }

  final List<String> _designations = [
    'Developer',
    'Designer',
    'Manager',
    'QA Engineer',
    'Product Owner',
    'Scrum Master',
  ];
}

class ManagerModel {
  String uid;
  String name;
  String email;
  String cnic;
  String? adminUid; // Optional
  String? password; // Optional

  ManagerModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.cnic,
    this.adminUid, // Optional
    this.password, // Optional
  });

  // Convert Firestore document to ManagerModel
  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      cnic: json['cnic'] ?? '',
      adminUid: json['adminUid'], // Optional
      password: json['password'], // Optional
    );
  }

  // Convert ManagerModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "cnic": cnic,
      "adminUid": adminUid, // Optional
      "password": password, // Optional
    };
  }
}
