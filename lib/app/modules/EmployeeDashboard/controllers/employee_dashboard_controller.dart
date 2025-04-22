// import 'dart:async';

// import 'package:admin/app/modules/EmployeeLoginPage/controllers/employee_login_page_controller.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';

// class EmployeeDashboardController extends GetxController {
//   Rx<List<Map<String, dynamic>>> assignedProjects =
//       Rx<List<Map<String, dynamic>>>([]);
//   StreamSubscription<QuerySnapshot>? _projectsSubscription;

//   void listenToAssignedProjects() {
//     _projectsSubscription = FirebaseFirestore.instance
//         .collection("Projects")
//         .where("siteSupervisorId",
//             isEqualTo: FirebaseAuth.instance.currentUser?.uid)
//         .snapshots() // Listen for real-time updates
//         .listen((snapshot) {
//       // Whenever Firestore updates, refresh the list of assigned projects
//       assignedProjects.value = snapshot.docs
//           .map((doc) => doc.data() as Map<String, dynamic>)
//           .toList();
//       update(); // Ensure the UI is updated with the new data
//     });
//   }

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Rx<List<Map<String, dynamic>>> createdProjects =
//       Rx<List<Map<String, dynamic>>>([]);

//   Rx<Employee> employee = Rx<Employee>(
//     Employee(uid: '', name: '', email: '', password: '', role: ''),
//   );

//   RxBool isLoading = RxBool(false); // Reactive loading state

//   @override
//   void onInit() {
//     super.onInit();
//     fetchAssignedProjects();
//     fetchEmployeeData().then((_) {
//       _setupReactiveListeners();
//     });
//     fetchEmployeeData().then((_) {
//       if (isSiteSupervisor) {
//         fetchSiteSupervisorProjects(); // Fetch projects for Site Supervisor
//       } else if (isEngineer) {
//         fetchAssignedProjects();
//       } else if (isSalesEmployee) {
//         fetchCreatedProjects();
//       }
//     });
//   }

//   void _setupReactiveListeners() {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return;

//     // Cancel any existing subscription
//     _projectsSubscription?.cancel();

//     // Set up new subscription based on user role
//     if (isSiteSupervisor) {
//       _projectsSubscription = FirebaseFirestore.instance
//           .collection("Projects")
//           .where("siteSupervisorId", isEqualTo: userId)
//           .snapshots()
//           .listen(_updateProjects);
//     } else if (isEngineer) {
//       _projectsSubscription = FirebaseFirestore.instance
//           .collection("Projects")
//           .where("assignedEngineerId", isEqualTo: userId)
//           .snapshots()
//           .listen(_updateProjects);
//     } else if (isSalesEmployee) {
//       _projectsSubscription = FirebaseFirestore.instance
//           .collection("Projects")
//           .where("salesEmployeeId", isEqualTo: userId)
//           .snapshots()
//           .listen(_updateProjects);
//     }
//   }

//   void _updateProjects(QuerySnapshot snapshot) {
//     assignedProjects.value = snapshot.docs.map((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       return {
//         ...data,
//         'id': doc.id, // Ensure project ID is included
//       };
//     }).toList();
//   }

//   Future<void> fetchCreatedProjects() async {
//     try {
//       isLoading.value = true;
//       final employee = this.employee.value;

//       // Debug: Print the logged-in employee's ID
//       print("Logged-in Employee ID: ${employee.uid}");

//       // Query Firestore for projects created by the Sales Employee
//       QuerySnapshot querySnapshot = await _firestore
//           .collection("Projects")
//           .where("salesEmployeeId",
//               isEqualTo: employee.uid) // Compare with employee.uid
//           .get();

//       // Debug: Print the number of projects fetched
//       print("Fetched Projects: ${querySnapshot.docs.length}");

//       // Map Firestore documents to a list of maps
//       createdProjects.value = querySnapshot.docs
//           .map((doc) => doc.data() as Map<String, dynamic>)
//           .toList();

//       // Debug: Print the createdProjects list
//       print("Created Projects: ${createdProjects.value}");
//     } catch (e) {
//       Get.snackbar("Error", "Failed to fetch created projects: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> fetchSiteSupervisorProjects() async {
//     try {
//       isLoading.value = true;
//       User? user = _auth.currentUser;
//       if (user != null) {
//         // First approach: Query Projects collection where siteSupervisorId matches
//         QuerySnapshot projectsSnapshot = await _firestore
//             .collection("Projects")
//             .where("siteSupervisorId", isEqualTo: user.uid)
//             .get();

//         // Second approach: If no results, get projects from employee's projects array
//         if (projectsSnapshot.docs.isEmpty) {
//           DocumentSnapshot employeeDoc =
//               await _firestore.collection("Employees").doc(user.uid).get();

//           if (employeeDoc.exists) {
//             List<dynamic> employeeProjects = employeeDoc['projects'] ?? [];
//             List<Future<DocumentSnapshot>> projectFutures = employeeProjects
//                 .map((proj) => _firestore
//                     .collection("Projects")
//                     .doc(proj['projectId'])
//                     .get())
//                 .toList();
//             List<DocumentSnapshot> projectDocs =
//                 await Future.wait(projectFutures);
//             assignedProjects.value =
//                 projectDocs.where((doc) => doc.exists).map((doc) {
//               final data = doc.data() as Map<String, dynamic>;
//               return {
//                 ...data,
//                 'id': doc.id,
//               };
//             }).toList();
//           }
//         } else {
//           assignedProjects.value = projectsSnapshot.docs.map((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             return {
//               ...data,
//               'id': doc.id,
//             };
//           }).toList();
//         }
//       }
//     } catch (e) {
//       Get.snackbar("Error", "Failed to fetch projects: $e");
//       print("Error fetching projects: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   List<String> getProjectTasks() {
//     return [
//       "Structure",
//       "Panel Installation",
//       "Inverter installation",
//       "Wiring",
//       "Completion",
//     ];
//   }

//   Future<void> markTaskAsCompleted(
//     String projectId,
//     String task, {
//     String? videoUrl,
//   }) async {
//     try {
//       final Map<String, dynamic> updates = {
//         'tasks.$task': true,
//         'lastUpdated': FieldValue.serverTimestamp(),
//       };

//       if (videoUrl != null) {
//         updates['taskVideos.$task'] = videoUrl;
//       }

//       // Update the task completion
//       await FirebaseFirestore.instance
//           .collection("Projects")
//           .doc(projectId)
//           .update(updates);

//       // Then calculate new progress
//       final projectDoc = await FirebaseFirestore.instance
//           .collection("Projects")
//           .doc(projectId)
//           .get();
//       final project = projectDoc.data() as Map<String, dynamic>;

//       final totalTasks = 4; // Fixed number of tasks
//       final completedVideos = project['taskVideos']?.length ?? 0;
//       final progress = ((completedVideos / totalTasks) * 100).round();

//       // Determine new status
//       String newStatus = 'doing';
//       if (progress >= 100) {
//         newStatus = 'completed';
//       } else if (progress > 0) {
//         newStatus = 'doing';
//       } else {
//         newStatus = project['status'] ??
//             'pending'; // Maintain current status if no progress
//       }

//       // Update progress and status
//       await FirebaseFirestore.instance
//           .collection("Projects")
//           .doc(projectId)
//           .update({
//         'progress': progress,
//         'status': newStatus, // The key here is updating the 'status' field
//       });

//       Get.snackbar(
//           "Success", "$task completed successfully! Progress: $progress%");
//     } catch (e) {
//       Get.snackbar("Error", "Failed to complete task: $e");
//     }
//   }

//   // Reactive method to fetch assigned projects
//   Future<void> fetchAssignedProjects() async {
//     try {
//       isLoading.value = true;

//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//             .collection("Projects")
//             .where("assignedEngineerId", isEqualTo: user.uid)
//             .get();

//         assignedProjects.value = querySnapshot.docs
//             .map((doc) => doc.data() as Map<String, dynamic>)
//             .toList();
//       }
//     } catch (e) {
//       Get.snackbar("Error", "Failed to fetch assigned projects: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> fetchEmployeeData() async {
//     try {
//       User? user = _auth.currentUser;
//       if (user != null) {
//         DocumentSnapshot doc =
//             await _firestore.collection("Employees").doc(user.uid).get();

//         if (doc.exists) {
//           employee.value = Employee.fromFirestore(doc);

//           // Debug: Print the employee data
//           print("Employee Data: ${employee.value.toJson()}");
//         }
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to fetch employee data: $e');
//     }
//   }

//   bool get isEngineer {
//     return employee.value.designation == 'Engineer';
//   }

//   // Check if the employee is a Sales Employee
//   bool get isSalesEmployee {
//     return employee.value.designation == 'Sales Employee';
//   }

//   bool get isSiteSupervisor {
//     return employee.value.designation == 'Site Supervisor';
//   }

//   // Send project info to Manager
//   Future<void> sendProjectInfoToManager({
//     required String clientName,
//     required String projectName,
//   }) async {
//     try {
//       String managerId = employee
//           .value.managerId!; // Now works with the updated Employee class
//       await _firestore.collection("Projects").add({
//         "clientName": clientName,
//         "projectName": projectName,
//         "salesEmployeeId": employee.value.uid,
//         "managerId": managerId,
//         "status": "pending",
//         "assignedEngineerId": "", // Initially empty
//         "createdAt": FieldValue.serverTimestamp(),
//       });

//       Get.snackbar("Success", "Project information sent to Manager");
//     } catch (e) {
//       Get.snackbar("Error", "Failed to send project information: $e");
//     }
//   }
// }

// Future<void> requestPermissions() async {
//   if (await Permission.camera.request().isGranted) {
//   } else {}
//   if (await Permission.storage.request().isGranted) {
//   } else {}
// }
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class EmployeeDashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var employee =
      Employee(uid: '', name: '', email: '', password: '', role: '').obs;
  var assignedProjects = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  List<String> getProjectTasks() {
    return [
      "Structure",
      "Panel Installation",
      "Inverter installation",
      "Wiring",
      "Completion",
    ];
  }

  @override
  void onInit() {
    super.onInit();
    fetchEmployeeData();
  }

  Future<void> markTaskAsCompleted(
    String projectId,
    String task, {
    String? videoUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'tasks.$task': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (videoUrl != null) {
        updates['taskVideos.$task'] = videoUrl;
      }

      // Update the task completion
      await FirebaseFirestore.instance
          .collection("Projects")
          .doc(projectId)
          .update(updates);

      // Then calculate new progress
      final projectDoc = await FirebaseFirestore.instance
          .collection("Projects")
          .doc(projectId)
          .get();
      final project = projectDoc.data() as Map<String, dynamic>;

      final totalTasks = 4; // Fixed number of tasks
      final completedVideos = project['taskVideos']?.length ?? 0;
      final progress = ((completedVideos / totalTasks) * 100).round();

      // Determine new status
      String newStatus = 'doing';
      if (progress >= 100) {
        newStatus = 'completed';
      } else if (progress > 0) {
        newStatus = 'doing';
      } else {
        newStatus = project['status'] ??
            'pending'; // Maintain current status if no progress
      }

      // Update progress and status
      await FirebaseFirestore.instance
          .collection("Projects")
          .doc(projectId)
          .update({
        'progress': progress,
        'status': newStatus, // The key here is updating the 'status' field
      });

      Get.snackbar(
          "Success", "$task completed successfully! Progress: $progress%");
    } catch (e) {
      Get.snackbar("Error", "Failed to complete task: $e");
    }
  }

  Future<void> fetchEmployeeData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        print("Logged in employee UID: $uid"); // Debugging log

        // Fetch employee data from Firestore
        DocumentSnapshot employeeDoc =
            await _firestore.collection("Employees").doc(uid).get();
        if (employeeDoc.exists) {
          employee.value = Employee.fromFirestore(employeeDoc);
          fetchAssignedProjects(uid); // Ensure we're passing the correct UID
        }
      } else {
        Get.snackbar("Error", "No employee data found.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch employee data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAssignedProjects(String employeeUid) async {
    try {
      print("Fetching projects for employee: $employeeUid");

      // Listen for real-time updates on assigned projects
      FirebaseFirestore.instance
          .collection("Projects")
          .where("assignedEngineerId", isEqualTo: employeeUid)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          print("No projects found for employee: $employeeUid");
          assignedProjects.clear();
        } else {
          print("Projects found for employee: $employeeUid");
          assignedProjects.value = querySnapshot.docs.map((doc) {
            print(
                "Project Data: ${doc.data()}"); // Debugging log to see the project data
            return doc.data() as Map<String, dynamic>;
          }).toList();
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch projects: $e");
    }
  }

  StreamSubscription<QuerySnapshot>? _projectsSubscription;

  void listenToAssignedProjects() {
    _projectsSubscription = FirebaseFirestore.instance
        .collection("Projects")
        .where("siteSupervisorId",
            isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots() // Listen for real-time updates
        .listen((snapshot) {
      // Whenever Firestore updates, refresh the list of assigned projects
      assignedProjects.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      update(); // Ensure the UI is updated with the new data
    });
  }

  Rx<List<Map<String, dynamic>>> createdProjects =
      Rx<List<Map<String, dynamic>>>([]);

  void _setupReactiveListeners() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Cancel any existing subscription
    _projectsSubscription?.cancel();

    // Set up new subscription based on user role
    if (isSiteSupervisor) {
      _projectsSubscription = FirebaseFirestore.instance
          .collection("Projects")
          .where("siteSupervisorId", isEqualTo: userId)
          .snapshots()
          .listen(_updateProjects);
    } else if (isEngineer) {
      _projectsSubscription = FirebaseFirestore.instance
          .collection("Projects")
          .where("assignedEngineerId", isEqualTo: userId)
          .snapshots()
          .listen(_updateProjects);
    } else if (isSalesEmployee) {
      _projectsSubscription = FirebaseFirestore.instance
          .collection("Projects")
          .where("salesEmployeeId", isEqualTo: userId)
          .snapshots()
          .listen(_updateProjects);
    }
  }

  void _updateProjects(QuerySnapshot snapshot) {
    assignedProjects.value = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        ...data,
        'id': doc.id, // Ensure project ID is included
      };
    }).toList();
  }

  Future<void> fetchCreatedProjects() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in.");
        return;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Projects")
          .where("salesEmployeeId", isEqualTo: currentUser.uid)
          .get();

      // Debug: Print the fetched data
      print(querySnapshot.docs.map((doc) => doc.data()).toList());

      createdProjects.value = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch projects: $e");
    }
  }

  Future<void> fetchSiteSupervisorProjects() async {
    try {
      isLoading.value = true;
      User? user = _auth.currentUser;
      if (user != null) {
        // First approach: Query Projects collection where siteSupervisorId matches
        QuerySnapshot projectsSnapshot = await _firestore
            .collection("Projects")
            .where("siteSupervisorId", isEqualTo: user.uid)
            .get();

        // Second approach: If no results, get projects from employee's projects array
        if (projectsSnapshot.docs.isEmpty) {
          DocumentSnapshot employeeDoc =
              await _firestore.collection("Employees").doc(user.uid).get();

          if (employeeDoc.exists) {
            List<dynamic> employeeProjects = employeeDoc['projects'] ?? [];
            List<Future<DocumentSnapshot>> projectFutures = employeeProjects
                .map((proj) => _firestore
                    .collection("Projects")
                    .doc(proj['projectId'])
                    .get())
                .toList();
            List<DocumentSnapshot> projectDocs =
                await Future.wait(projectFutures);
            assignedProjects.value =
                projectDocs.where((doc) => doc.exists).map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                ...data,
                'id': doc.id,
              };
            }).toList();
          }
        } else {
          assignedProjects.value = projectsSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              ...data,
              'id': doc.id,
            };
          }).toList();
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch projects: $e");
      print("Error fetching projects: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // List<String> getProjectTasks() {
  //   return [
  //     "Structure",
  //     "Panel Installation",
  //     "Inverter installation",
  //     "Wiring",
  //     "Completion",
  //   ];
  // }

  bool get isEngineer {
    return employee.value.designation == 'Engineer';
  }

  // Check if the employee is a Sales Employee
  bool get isSalesEmployee {
    return employee.value.designation == 'Sales Employee';
  }

  bool get isSiteSupervisor {
    return employee.value.designation == 'Site Supervisor';
  }

  // // Send project info to Manager
  // Future<void> sendProjectInfoToManager({
  //   required String clientName,
  //   required String projectName,
  // }) async {
  //   try {
  //     String managerId = employee
  //         .value.managerId!; // Now works with the updated Employee class
  //     await _firestore.collection("Projects").add({
  //       "clientName": clientName,
  //       "projectName": projectName,
  //       "salesEmployeeId": employee.value.uid,
  //       "managerId": managerId,
  //       "status": "pending",
  //       "assignedEngineerId": "", // Initially empty
  //       "createdAt": FieldValue.serverTimestamp(),
  //     });

  //     Get.snackbar("Success", "Project information sent to Manager");
  //   } catch (e) {
  //     Get.snackbar("Error", "Failed to send project information: $e");
  //   }
  // }
}

Future<void> requestPermissions() async {
  if (await Permission.camera.request().isGranted) {
  } else {}
  if (await Permission.storage.request().isGranted) {
  } else {}
}

class Employee {
  String uid;
  String name;
  String email;
  String password;
  String role;
  String? designation;

  Employee({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.designation,
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Employee(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      role: data['role'] ?? '',
      designation: data['designation'], // Optional
    );
  }
}
