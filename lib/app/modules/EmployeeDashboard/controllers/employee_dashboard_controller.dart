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
  bool autoLoadedProjects = false;

  var assignedProjects = <Map<String, dynamic>>[].obs;
  var createdProjects = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  StreamSubscription<QuerySnapshot>? _projectsSubscription;

  var employee = Rx<Employee>(Employee(
    uid: '',
    name: '',
    email: '',
    password: '',
    role: '',
    designation: '',
  ));
  var locationPinUrl = ''.obs; // Added new property for location pin URL

  bool get isSalesEmployee => employee.value.designation == 'Sales Employee';
  bool get isElectrician => employee.value.designation == 'Electrician';
  bool get isEngineer => employee.value.designation == 'Engineer';
  bool get isTechnician => employee.value.designation == 'Technician';
  bool get isProjectManager => employee.value.designation == 'Project Manager';
  bool get isSiteSupervisor => employee.value.designation == 'Site Supervisor';

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
    loadDashboardData();
    loadDashboardData();

    // Set up an event listener for hot reload
    ever(employee, (_) {
      if (employee.value.designation == 'Project Manager' &&
          employee.value.uid.isNotEmpty) {
        setupProjectManagerListener();
      }
    });
    fetchEmployeeData().then((_) {
      // After employee data is fetched, set up the appropriate listeners
      setupRoleBasedListeners();
    });
  }

  @override
  void onClose() {
    // Make sure to clean up subscription when controller is closed
    _projectsSubscription?.cancel();
    print(
        "EmployeeDashboardController: onClose called - subscription canceled");
    super.onClose();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      await fetchEmployeeData();
      setupRoleBasedListeners();
    } catch (e) {
      print("Error loading dashboard data: $e");
      Get.snackbar("Error", "Failed to load dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Setup appropriate listeners based on employee role
  void setupRoleBasedListeners() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Cancel any existing subscription
    _projectsSubscription?.cancel();

    if (isSalesEmployee) {
      setupSalesProjectsListener();
    } else if (isEngineer || isSiteSupervisor) {
      fetchAssignedProjects(currentUser.uid);
    } else if (isProjectManager) {
      // Immediately set up the project manager listener
      setupProjectManagerListener();
    } else if (isElectrician || isTechnician) {
      setupTechnicianListener();
    }
  }

  // Listener for Sales Employee projects - REAL-TIME UPDATES
  void setupSalesProjectsListener() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _projectsSubscription = FirebaseFirestore.instance
        .collection("Projects")
        .where("salesEmployeeId", isEqualTo: currentUser.uid)
        .snapshots() // This provides real-time updates
        .listen((querySnapshot) {
      createdProjects.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
      print(
          "Real-time update: ${createdProjects.length} sales projects fetched");
    });
  }
  // In EmployeeDashboardController class
  // In EmployeeDashboardController class
  // In EmployeeDashboardController class

  void setupProjectManagerListener() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    isLoading.value = true;

    // Cancel any existing subscription
    _projectsSubscription?.cancel();

    // Listen to projects where the current user is directly the manager
    _projectsSubscription = FirebaseFirestore.instance
        .collection("Projects")
        .where("managerId", isEqualTo: currentUser.uid)
        .snapshots()
        .listen((querySnapshot) async {
      try {
        // Get all unique employee IDs from projects
        Map<String, String> employeeIdsWithRoles = {};

        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          if (data['assignedEngineerId'] != null &&
              data['assignedEngineerId'].isNotEmpty) {
            employeeIdsWithRoles[data['assignedEngineerId']] =
                'assignedEngineerId';
          }
          if (data['salesEmployeeId'] != null &&
              data['salesEmployeeId'].isNotEmpty) {
            employeeIdsWithRoles[data['salesEmployeeId']] = 'salesEmployeeId';
          }
          if (data['siteSupervisorId'] != null &&
              data['siteSupervisorId'].isNotEmpty) {
            employeeIdsWithRoles[data['siteSupervisorId']] = 'siteSupervisorId';
          }
          if (data['technicianId'] != null && data['technicianId'].isNotEmpty) {
            employeeIdsWithRoles[data['technicianId']] = 'technicianId';
          }
        }

        // Fetch employee data for these IDs
        Map<String, Map<String, String>> employeeDetails = {};
        if (employeeIdsWithRoles.isNotEmpty) {
          // Process in batched queries if many IDs (Firestore 'in' limitation)
          final employeeIds = employeeIdsWithRoles.keys.toList();
          for (int i = 0; i < employeeIds.length; i += 10) {
            final batch = employeeIds.sublist(
                i, i + 10 > employeeIds.length ? employeeIds.length : i + 10);

            final empSnapshot = await FirebaseFirestore.instance
                .collection("Employees")
                .where(FieldPath.documentId, whereIn: batch)
                .get();

            for (var empDoc in empSnapshot.docs) {
              final data = empDoc.data();
              employeeDetails[empDoc.id] = {
                'name': data['name'] ?? 'Unknown',
                'designation': data['designation'] ?? 'Unknown'
              };
            }
          }
        }

        // Now build project list with employee names and designations
        final projects = querySnapshot.docs.map((doc) {
          final data = doc.data();
          Map<String, dynamic> projectData = {
            ...data,
            'id': doc.id,
          };

          // Add employee names and designations if available
          if (data['assignedEngineerId'] != null &&
              employeeDetails.containsKey(data['assignedEngineerId'])) {
            projectData['assignedEngineerName'] =
                employeeDetails[data['assignedEngineerId']]!['name'];
            projectData['assignedEngineerDesignation'] =
                employeeDetails[data['assignedEngineerId']]!['designation'];
          } else {
            projectData['assignedEngineerName'] = 'Not assigned';
          }

          if (data['salesEmployeeId'] != null &&
              employeeDetails.containsKey(data['salesEmployeeId'])) {
            projectData['salesEmployeeName'] =
                employeeDetails[data['salesEmployeeId']]!['name'];
            projectData['salesEmployeeDesignation'] =
                employeeDetails[data['salesEmployeeId']]!['designation'];
          } else {
            projectData['salesEmployeeName'] = 'Not assigned';
          }

          if (data['siteSupervisorId'] != null &&
              employeeDetails.containsKey(data['siteSupervisorId'])) {
            projectData['siteSupervisorName'] =
                employeeDetails[data['siteSupervisorId']]!['name'];
            projectData['siteSupervisorDesignation'] =
                employeeDetails[data['siteSupervisorId']]!['designation'];
          } else {
            projectData['siteSupervisorName'] = 'Not assigned';
          }

          if (data['technicianId'] != null &&
              employeeDetails.containsKey(data['technicianId'])) {
            projectData['technicianName'] =
                employeeDetails[data['technicianId']]!['name'];
            projectData['technicianDesignation'] =
                employeeDetails[data['technicianId']]!['designation'];
          } else {
            projectData['technicianName'] = 'Not assigned';
          }

          return projectData;
        }).toList();

        // Update the assignedProjects list with these projects
        assignedProjects.value = projects;
        print("Projects fetched with employee details: ${projects.length}");
      } catch (e) {
        print("Error processing project data: $e");
      } finally {
        isLoading.value = false;
      }
    });
  }

// Update the fetchAllProjectsWithSameManager method similarly
  Future<void> fetchAllProjectsWithSameManager(String targetManagerId) async {
    try {
      isLoading.value = true;

      QuerySnapshot projectsSnapshot = await FirebaseFirestore.instance
          .collection("Projects")
          .where("managerId", isEqualTo: targetManagerId)
          .get();

      // Get all unique employee IDs from projects
      Map<String, String> employeeIdsWithRoles = {};

      for (var doc in projectsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['assignedEngineerId'] != null &&
            data['assignedEngineerId'].isNotEmpty) {
          employeeIdsWithRoles[data['assignedEngineerId']] =
              'assignedEngineerId';
        }
        if (data['salesEmployeeId'] != null &&
            data['salesEmployeeId'].isNotEmpty) {
          employeeIdsWithRoles[data['salesEmployeeId']] = 'salesEmployeeId';
        }
        if (data['siteSupervisorId'] != null &&
            data['siteSupervisorId'].isNotEmpty) {
          employeeIdsWithRoles[data['siteSupervisorId']] = 'siteSupervisorId';
        }
        if (data['technicianId'] != null && data['technicianId'].isNotEmpty) {
          employeeIdsWithRoles[data['technicianId']] = 'technicianId';
        }
      }

      // Fetch employee data for these IDs
      Map<String, Map<String, String>> employeeDetails = {};
      if (employeeIdsWithRoles.isNotEmpty) {
        // Process in batched queries if many IDs
        final employeeIds = employeeIdsWithRoles.keys.toList();
        for (int i = 0; i < employeeIds.length; i += 10) {
          final batch = employeeIds.sublist(
              i, i + 10 > employeeIds.length ? employeeIds.length : i + 10);

          final empSnapshot = await FirebaseFirestore.instance
              .collection("Employees")
              .where(FieldPath.documentId, whereIn: batch)
              .get();

          for (var empDoc in empSnapshot.docs) {
            final data = empDoc.data();
            employeeDetails[empDoc.id] = {
              'name': data['name'] ?? 'Unknown',
              'designation': data['designation'] ?? 'Unknown'
            };
          }
        }
      }

      // Now build project list with employee names and designations
      final projects = projectsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> projectData = {
          ...data,
          'id': doc.id,
        };

        // Add employee names and designations if available
        if (data['assignedEngineerId'] != null &&
            employeeDetails.containsKey(data['assignedEngineerId'])) {
          projectData['assignedEngineerName'] =
              employeeDetails[data['assignedEngineerId']]!['name'];
          projectData['assignedEngineerDesignation'] =
              employeeDetails[data['assignedEngineerId']]!['designation'];
        } else {
          projectData['assignedEngineerName'] = 'Not assigned';
        }

        if (data['salesEmployeeId'] != null &&
            employeeDetails.containsKey(data['salesEmployeeId'])) {
          projectData['salesEmployeeName'] =
              employeeDetails[data['salesEmployeeId']]!['name'];
          projectData['salesEmployeeDesignation'] =
              employeeDetails[data['salesEmployeeId']]!['designation'];
        } else {
          projectData['salesEmployeeName'] = 'Not assigned';
        }

        if (data['siteSupervisorId'] != null &&
            employeeDetails.containsKey(data['siteSupervisorId'])) {
          projectData['siteSupervisorName'] =
              employeeDetails[data['siteSupervisorId']]!['name'];
          projectData['siteSupervisorDesignation'] =
              employeeDetails[data['siteSupervisorId']]!['designation'];
        } else {
          projectData['siteSupervisorName'] = 'Not assigned';
        }

        if (data['technicianId'] != null &&
            employeeDetails.containsKey(data['technicianId'])) {
          projectData['technicianName'] =
              employeeDetails[data['technicianId']]!['name'];
          projectData['technicianDesignation'] =
              employeeDetails[data['technicianId']]!['designation'];
        } else {
          projectData['technicianName'] = 'Not assigned';
        }

        return projectData;
      }).toList();

      // Replace the current list with these projects
      assignedProjects.value = projects;
      print(
          "All projects with manager ID $targetManagerId and employee details: ${projects.length}");
    } catch (e) {
      print("Error fetching projects with manager ID $targetManagerId: $e");
      throw e; // Re-throw the error so it can be caught by the calling function
    } finally {
      // Always set isLoading to false, regardless of success or failure
      isLoading.value = false;
    }
  }

  // Add this method to allow project managers to view projects of a specific manager
  void viewProjectsByManager(String managerId) {
    // First clear current projects
    assignedProjects.clear();

    // Then fetch projects for the specified manager
    fetchAllProjectsWithSameManager(managerId);
  }

  // Add this to your existing code to detect managers with the same ID
  Future<List<Map<String, dynamic>>> findManagersWithSameId(
      String targetId) async {
    try {
      // Query the Employees collection for employees with the same managerId
      QuerySnapshot managersSnapshot = await FirebaseFirestore.instance
          .collection("Employees")
          .where("managerId", isEqualTo: targetId)
          .get();

      return managersSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      print("Error finding managers with same ID: $e");
      return [];
    }
  }

  // New method to fetch projects for a specific employee role with real-time updates
  void _fetchRoleProjects(String roleField, List<String> employeeIds,
      Map<String, Map<String, String>> employeeData) {
    // Process employee IDs in batches of 10 (Firestore limitation for 'in' queries)
    for (int i = 0; i < employeeIds.length; i += 10) {
      // Create a batch of at most 10 IDs
      final batchIds = employeeIds.sublist(
          i, i + 10 > employeeIds.length ? employeeIds.length : i + 10);

      // Create a real-time listener for this batch
      _firestore
          .collection("Projects")
          .where(roleField, whereIn: batchIds)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          // Convert to project maps and add employee info from our reference map
          final batchProjects = querySnapshot.docs.map((doc) {
            final data = doc.data();
            final projectId = doc.id;
            final employeeId = data[roleField] as String?;

            // Add employee details if we have them
            Map<String, dynamic> projectData = {
              ...data,
              'id': projectId,
            };

            // Add employee details if available
            if (employeeId != null && employeeData.containsKey(employeeId)) {
              final role = _getRoleFromField(roleField);
              projectData['${role}Name'] = employeeData[employeeId]?['name'];
              projectData['${role}Designation'] =
                  employeeData[employeeId]?['designation'];
            }

            return projectData;
          }).toList();

          // Add these projects to the list, avoiding duplicates
          for (var project in batchProjects) {
            final projectId = project['id'];
            // Check if project already exists in the list
            final existingIndex =
                assignedProjects.indexWhere((p) => p['id'] == projectId);

            if (existingIndex >= 0) {
              // Update existing project with any new information
              assignedProjects[existingIndex] = {
                ...assignedProjects[existingIndex],
                ...project,
              };
            } else {
              // Add new project to the list
              assignedProjects.add(project);
            }
          }

          print(
              "Added/updated ${batchProjects.length} projects for role $roleField");
        }

        isLoading.value = false;
      }, onError: (e) {
        print("Error fetching $roleField projects: $e");
        isLoading.value = false;
      });
    }
  }

  // Helper method to get role name from field name
  String _getRoleFromField(String fieldName) {
    switch (fieldName) {
      case 'assignedEngineerId':
        return 'engineer';
      case 'salesEmployeeId':
        return 'sales';
      case 'siteSupervisorId':
        return 'siteSupervisor';
      case 'technicianId':
        return 'technician';
      default:
        return 'employee';
    }
  }

  // This method is now redundant and can be removed since we're handling everything in setupProjectManagerListener
  // Future<void> fetchProjectsFromManagedEmployees(String managerId) async {
  //   // Remove this method as it's been replaced by the new implementation
  // }

  // Method to fetch projects for a specific employee role
  // Future<void> fetchEmployeeProjects(String roleField, List<String> employeeIds) async {
  //   // Remove this method as it's been replaced by the new implementation
  // }
  // Improved method to fetch projects assigned to employees managed by this Project Manager
  Future<void> fetchProjectsFromManagedEmployees(String managerId) async {
    try {
      // First get all employees managed by this Project Manager
      QuerySnapshot employeesSnapshot = await _firestore
          .collection("Employees")
          .where("managerId", isEqualTo: managerId)
          .get();

      if (employeesSnapshot.docs.isEmpty) {
        print("No employees found for manager: $managerId");
        isLoading.value = false;
        return;
      }

      print(
          "Found ${employeesSnapshot.docs.length} employees managed by this Project Manager");

      // Get a list of employee IDs and create a map for employee data
      List<String> employeeIds =
          employeesSnapshot.docs.map((doc) => doc.id).toList();
      Map<String, Map<String, dynamic>> employeeData = {};

      // Store employee data for later use
      for (var doc in employeesSnapshot.docs) {
        final data =
            doc.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
        employeeData[doc.id] = {
          'name': data['name'] ?? 'Unknown',
          'designation': data['designation'] ?? 'Unknown',
        };
      }

      // Get all projects where these employees are assigned to any role
      List<Future<QuerySnapshot>> queries = [
        fetchEmployeeProjectsQuery("assignedEngineerId", employeeIds),
        fetchEmployeeProjectsQuery("salesEmployeeId", employeeIds),
        fetchEmployeeProjectsQuery("siteSupervisorId", employeeIds),
        fetchEmployeeProjectsQuery("technicianId", employeeIds),
      ];

      // Wait for all queries to complete
      List<QuerySnapshot> results = await Future.wait(queries);

      // Process all query results
      for (var querySnapshot in results) {
        if (querySnapshot.docs.isNotEmpty) {
          // Convert to project maps
          final projects = querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Enhance project data with employee names
            Map<String, dynamic> enhancedData = {...data, 'id': doc.id};

            // Add employee names to project data where applicable
            for (String role in [
              'assignedEngineerId',
              'salesEmployeeId',
              'siteSupervisorId',
              'technicianId'
            ]) {
              if (data[role] != null && employeeData.containsKey(data[role])) {
                String employeeId = data[role];
                String nameKey = role.replaceAll('Id', 'Name');
                enhancedData[nameKey] = employeeData[employeeId]!['name'];
                enhancedData[role.replaceAll('Id', 'Role')] =
                    employeeData[employeeId]!['designation'];
              }
            }

            return enhancedData;
          }).toList();

          // Add projects to the list, avoiding duplicates
          for (var project in projects) {
            if (!assignedProjects.any((p) => p['id'] == project['id'])) {
              assignedProjects.add(project);
            }
          }
        }
      }

      print("Total projects fetched: ${assignedProjects.length}");
      isLoading.value = false;
    } catch (e) {
      print("Error fetching managed employees' projects: $e");
      Get.snackbar("Error", "Failed to fetch team projects: $e");
      isLoading.value = false;
    }
  }

  // Helper method to create a query for employee projects
  Future<QuerySnapshot> fetchEmployeeProjectsQuery(
      String roleField, List<String> employeeIds) async {
    // We need to handle querying with "in" operator for multiple employee IDs
    // Firestore limits "in" queries to 10 values, so we use the first 10 to avoid complexity
    final batchIds = employeeIds.sublist(
        0, employeeIds.length > 10 ? 10 : employeeIds.length);

    // Query projects where this batch of employees is assigned the specific role
    return await _firestore
        .collection("Projects")
        .where(roleField, whereIn: batchIds)
        .get();
  }

  // Imp
  //
  //
  //roved filter method to get specific projects based on tab selection
  List<Map<String, dynamic>> getFilteredProjectsForManager() {
    final statusFilter = projectManagerTabIndex.value;

    return assignedProjects.where((project) {
      final status = project['status']?.toString() ?? 'pending';

      // Filter logic based on selected tab
      switch (statusFilter) {
        case 1: // Pending
          return status == 'pending';
        case 2: // In Progress (includes 'approved' and 'doing')
          return status == 'approved' || status == 'doing';
        case 3: // Completed
          return status == 'completed';
        case 4: // Not Completed (new option)
          return status != 'completed';
        default: // All
          return true;
      }
    }).toList();
  }

  // New method to fetch projects assigned to employees managed by this Project Manager

  // Method to fetch projects for a specific employee role
  Future<void> fetchEmployeeProjects(
      String roleField, List<String> employeeIds) async {
    try {
      // We need to handle querying with "in" operator for multiple employee IDs
      // Firestore limits "in" queries to 10 values, so we may need to split into batches
      for (int i = 0; i < employeeIds.length; i += 10) {
        // Create a batch of at most 10 IDs
        final batchIds = employeeIds.sublist(
            i, i + 10 > employeeIds.length ? employeeIds.length : i + 10);

        // Query projects where this batch of employees is assigned the specific role
        QuerySnapshot projectsSnapshot = await _firestore
            .collection("Projects")
            .where(roleField, whereIn: batchIds)
            .get();

        if (projectsSnapshot.docs.isNotEmpty) {
          // Convert to project maps and add to assignedProjects if not already there
          final newProjects = projectsSnapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  ...data,
                  'id': doc.id,
                };
              })
              .where((project) =>
                  // Only add if not already in the list (avoid duplicates)
                  !assignedProjects.any((p) => p['id'] == project['id']))
              .toList();

          // Add these new projects to the list
          if (newProjects.isNotEmpty) {
            assignedProjects.addAll(newProjects);
            print("Added ${newProjects.length} projects for role $roleField");
          }
        }
      }
    } catch (e) {
      print("Error fetching $roleField projects: $e");
    }
  }

  // Listener for Electrician/Technician tasks
  void setupTechnicianListener() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _projectsSubscription = FirebaseFirestore.instance
        .collection("Projects")
        .where("technicianId", isEqualTo: currentUser.uid)
        .snapshots()
        .listen((querySnapshot) {
      assignedProjects.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();
      print(
          "Real-time update: ${assignedProjects.length} technician tasks fetched");
    });
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

      // Update the task completion in Firestore
      await FirebaseFirestore.instance
          .collection("Projects")
          .doc(projectId)
          .update(updates);

      // Fetch the updated project document
      final projectDoc = await FirebaseFirestore.instance
          .collection("Projects")
          .doc(projectId)
          .get();
      final project = projectDoc.data() as Map<String, dynamic>;

      // Calculate the total number of tasks
      final totalTasks =
          5; // Fixed number of tasks (Structure, Panel Installation, Inverter Installation, Wiring, Completion)

      // Count the number of completed tasks (those with video URLs)
      final completedTasks = project['taskVideos']
              ?.values
              .where((video) => video != null && video.toString().isNotEmpty)
              .length ??
          0;

      // Calculate progress as percentage (each task is worth 20%)
      final progress = ((completedTasks / totalTasks) * 100).round();

      // Update progress and status in Firestore
      String newStatus = 'doing';
      if (progress >= 100) {
        newStatus = 'completed';
      } else if (progress > 0) {
        newStatus = 'doing';
      } else {
        newStatus = project['status'] ?? 'pending';
      }

      await FirebaseFirestore.instance
          .collection("Projects")
          .doc(projectId)
          .update({
        'progress': progress,
        'status': newStatus,
      });

      // Show success message
      Get.snackbar(
          "Success", "$task completed successfully! Progress: $progress%");
    } catch (e) {
      Get.snackbar("Error", "Failed to complete task: $e");
    }
  }

  Future<void> fetchEmployeeData() async {
    try {
      isLoading.value = true;
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;
        print("Logged in employee UID: $uid");

        // Fetch employee data from Firestore
        DocumentSnapshot employeeDoc =
            await _firestore.collection("Employees").doc(uid).get();
        if (employeeDoc.exists) {
          employee.value = Employee.fromFirestore(employeeDoc);
        } else {
          Get.snackbar("Error", "No employee data found.");
        }
      } else {
        Get.snackbar("Error", "User not logged in.");
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
      _projectsSubscription = FirebaseFirestore.instance
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
            final data = doc.data() as Map<String, dynamic>;
            return {
              ...data,
              'id': doc.id,
            };
          }).toList();
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch projects: $e");
    }
  }

  // This method is now redundant as we're using setupRoleBasedListeners
  // Keeping it for backward compatibility
  Future<void> fetchCreatedProjects() async {
    try {
      isLoading.value = true;
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in.");
        return;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Projects")
          .where("salesEmployeeId", isEqualTo: currentUser.uid)
          .get();

      createdProjects.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
        };
      }).toList();

      print("Fetched ${createdProjects.length} projects for sales employee");
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch projects: $e");
      print("Error fetching projects: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // In EmployeeDashboardController
  final projectManagerTabIndex =
      0.obs; // 0=All, 1=Pending, 2=In Progress, 3=Completed

  // In EmployeeDashboardController
  Future<void> setupManagerProjectsListener() async {
    try {
      isLoading.value = true;

      // Get the current manager's ID
      final managerId = employee.value.uid;

      // Listen to projects where managerId matches
      FirebaseFirestore.instance
          .collection('Projects')
          .where('managerId', isEqualTo: managerId)
          .snapshots()
          .listen((snapshot) {
        assignedProjects.assignAll(snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {'id': doc.id, ...data};
        }).toList());
        isLoading.value = false;
      });

      // Also listen to projects created by sales employees under this manager
      FirebaseFirestore.instance
          .collection('Projects')
          .where('salesEmployee.managerId', isEqualTo: managerId)
          .snapshots()
          .listen((snapshot) {
        final salesProjects = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {'id': doc.id, ...data};
        }).toList();

        // Merge with existing projects, avoiding duplicates
        assignedProjects.assignAll([
          ...assignedProjects,
          ...salesProjects
              .where((p) => !assignedProjects.any((ap) => ap['id'] == p['id']))
        ]);
        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to load projects: $e");
    }
  }

  void refreshProjects() {
    (); // Or whatever method you use to refresh projects
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
  String designation;
  String? managerId; // Add this field

  Employee({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.designation,
    this.managerId, // Add this parameter
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Employee(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      role: data['role'] ?? '',
      designation: data['designation'] ?? '',
      managerId: data['managerId'], // Get managerId from Firestore
    );
  }
}
