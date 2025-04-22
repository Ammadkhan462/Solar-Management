import 'dart:async';
import 'package:admin/app/modules/EmployeeDashboard/views/sitesupervisor.dart';
import 'package:intl/intl.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import '../controllers/employee_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admin/app/routes/app_pages.dart';
import '../controllers/employee_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_dashboard_controller.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  EmployeeDashboardView({super.key});
  final EmployeeDashboardController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed(Routes.LOGIN_CHOICE); // Navigate to login page
            },
          ),
        ],
      ),
      body: Obx(() {
        // Ensure employee data has been loaded
        if (_controller.employee.value.uid.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Display Welcome message
        return Column(children: [
          Text("Welcome, ${_controller.employee.value.name}!",
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_controller.isSiteSupervisor) ...[
            const Text("Your Assigned Projects",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (_controller.assignedProjects.value.isEmpty) {
                  return const Center(child: Text("No projects assigned yet"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _controller.assignedProjects.value.length,
                  itemBuilder: (context, index) {
                    final project = _controller.assignedProjects.value[index];
                    final status = project['status'] ?? 'pending';

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        color: _getStatusColor(status),
                        child: ListTile(
                          title: Text(project['projectName'] ?? 'No Name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Status: $status"),
                              if (project['lastUpdated'] != null)
                                Text(
                                  "Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format((project['lastUpdated'] as Timestamp).toDate())}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          onTap: () {
                            Get.to(() =>
                                TaskCompletionScreen(projectId: project['id']));
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
          // Sales Employee Section
          // Sales Employee Section
          if (_controller.isSalesEmployee) ...[
            const Text("Your Created Projects",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Get.to(() => SalesEmployeeForm());
              },
              child: const Text('Create New Project'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.createdProjects.value.isEmpty) {
                  return const Center(child: Text("No projects created yet"));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await _controller.fetchCreatedProjects();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _controller.createdProjects.value.length,
                    itemBuilder: (context, index) {
                      final project = _controller.createdProjects.value[index];
                      final status = project['status'] ?? 'No Status';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: ListTile(
                          title: Text(project['projectName'] ?? 'No Name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Status: $status"),
                              if (project['createdAt'] != null)
                                Text(
                                  "Created: ${DateFormat('MMM dd, yyyy').format((project['createdAt'] as Timestamp).toDate())}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (project['assignedEngineer'] != null)
                                Text(
                                  "Engineer: ${project['assignedEngineer']}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          tileColor: status == 'completed'
                              ? Colors.green[100]
                              : Colors.white,
                          onTap: () {
                            Get.to(() =>
                                ProjectDetailsScreen(projectId: project['id']));
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ]);
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green[100]!;
      case 'approved':
        return Colors.blue[100]!;
      case 'doing':
        return Colors.orange[100]!;
      case 'pending':
      default:
        return Colors.grey[100]!;
    }
  }
}

// class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
//   EmployeeDashboardView({super.key});
//   final EmployeeDashboardController _controller = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('Employee Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               Get.offAllNamed(Routes.LOGIN_CHOICE);
//             },
//           ),
//         ],
//       ),
//       body: Obx(() {
//         // Ensure employee data has been loaded
//         if (_controller.employee.value.uid.isEmpty) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // Display Welcome message
//         return Column(
//           children: [
//             Text("Welcome, ${_controller.employee.value.name}!",
//                 style:
//                     const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             if (_controller.isSalesEmployee) ...[
//               ElevatedButton(
//                 onPressed: () {
//                   Get.to(() => SalesEmployeeForm());
//                 },
//                 child: const Text('Create Project'),
//               ),
//               const SizedBox(height: 20),
//               const Text("Your Created Projects",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               Expanded(
//                 child: Obx(() {
//                   if (_controller.isLoading.value) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   if (_controller.createdProjects.value.isEmpty) {
//                     return const Center(child: Text("No projects created yet"));
//                   }

//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16.0),
//                     itemCount: _controller.createdProjects.value.length,
//                     itemBuilder: (context, index) {
//                       final project = _controller.createdProjects.value[index];
//                       final status = project['status'] ?? 'No Status';

//                       return Card(
//                         margin: const EdgeInsets.only(bottom: 16.0),
//                         child: ListTile(
//                           title: Text(project['projectName'] ?? 'No Name'),
//                           subtitle: Text("Status: $status"),
//                           tileColor: status == 'completed'
//                               ? Colors.green[100]
//                               : Colors.white,
//                           onTap: () {
//                             Get.to(() =>
//                                 TaskCompletionScreen(projectId: project['id']));
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//             if (_controller.isSiteSupervisor) ...[
//               const Text("Your Assigned Projects",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: Obx(() {
//                   if (_controller.assignedProjects.value.isEmpty) {
//                     return const Center(
//                         child: Text("No projects assigned yet"));
//                   }

//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16.0),
//                     itemCount: _controller.assignedProjects.value.length,
//                     itemBuilder: (context, index) {
//                       final project = _controller.assignedProjects.value[index];
//                       final status = project['status'] ?? 'pending';

//                       return AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         margin: const EdgeInsets.only(bottom: 16.0),
//                         child: Card(
//                           color: _getStatusColor(status),
//                           child: ListTile(
//                             title: Text(project['projectName'] ?? 'No Name'),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Status: $status"),
//                                 if (project['lastUpdated'] != null)
//                                   Text(
//                                     "Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format((project['lastUpdated'] as Timestamp).toDate())}",
//                                     style: const TextStyle(fontSize: 12),
//                                   ),
//                               ],
//                             ),
//                             onTap: () {
//                               Get.to(() => TaskCompletionScreen(
//                                   projectId: project['id']));
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//             if (_controller.isEngineer) ...[
//               const SizedBox(height: 20),
//               const Text("Assigned Projects",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 20),
//               const Text("Pending Tasks",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               _controller.assignedProjects.value.isEmpty
//                   ? const Center(child: Text("No assigned projects"))
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16.0),
//                       shrinkWrap:
//                           true, // Prevents the ListView from taking up excess space
//                       itemCount: _controller.assignedProjects.value.length,
//                       itemBuilder: (context, index) {
//                         final project =
//                             _controller.assignedProjects.value[index];
//                         if (project['status'] == 'pending') {
//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 16.0),
//                             child: ListTile(
//                               title: Text(project['projectName'] ?? 'No Name'),
//                               subtitle: Text(
//                                   "Client: ${project['clientName'] ?? 'No Client'}"),
//                               tileColor: project['status'] == 'approved'
//                                   ? Colors.green[100]
//                                   : project['status'] == 'completed'
//                                       ? Colors.orange[100]
//                                       : Colors.white,
//                               onTap: () {
//                                 Get.to(() => ProjectDetailsScreen(
//                                     projectId: project['id']));
//                               },
//                             ),
//                           );
//                         }
//                         return const SizedBox(); // Empty container for non-pending tasks
//                       },
//                     ),
//               const SizedBox(height: 20),
//               const Text("Completed Tasks",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               _controller.assignedProjects.value.isEmpty
//                   ? const Center(child: Text("No assigned projects"))
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(16.0),
//                       shrinkWrap: true,
//                       itemCount: _controller.assignedProjects.value.length,
//                       itemBuilder: (context, index) {
//                         final project =
//                             _controller.assignedProjects.value[index];
//                         if (project['status'] == 'completed') {
//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 16.0),
//                             child: ListTile(
//                               title: Text(project['projectName'] ?? 'No Name'),
//                               subtitle: Text(
//                                   "Client: ${project['clientName'] ?? 'No Client'}"),
//                               tileColor: project['status'] == 'approved'
//                                   ? Colors.green[100]
//                                   : project['status'] == 'completed'
//                                       ? Colors.orange[100]
//                                       : Colors.white,
//                               onTap: () {
//                                 Get.to(() => ProjectDetailsScreen(
//                                     projectId: project['id']));
//                               },
//                             ),
//                           );
//                         }
//                         return const SizedBox(); // Empty container for non-completed tasks
//                       },
//                     ),
//             ],
//           ],
//         );
//       }),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'completed':
//         return Colors.green[100]!;
//       case 'approved':
//         return Colors.blue[100]!;
//       case 'doing':
//         return Colors.orange[100]!;
//       case 'pending':
//       default:
//         return Colors.grey[100]!;
//     }
//   }
// }

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;

  ProjectDetailsScreen({required this.projectId});

  final RxString status = RxString('completed'); // To track project status
  final RxString satisfactionLevel = RxString('');
  final TextEditingController commentsController = TextEditingController();
  final RxBool isCompleted = false.obs; // Track if task is completed

  @override
  Widget build(BuildContext context) {
    final ProjectDetailsController controller =
        Get.put(ProjectDetailsController());
    controller.listenToProjectChanges(projectId);

    return Scaffold(
      appBar: AppBar(title: const Text("Project Details")),
      body: Obx(() {
        if (controller.project.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final project = controller.project.value;
        final videoUrl = project['completedTaskVideoUrl'];
        final storedSatisfactionLevel = project['satisfactionLevel'];
        final storedComments = project['comments'];

        // Set the values from Firestore if available
        if (storedSatisfactionLevel != null) {
          satisfactionLevel.value = storedSatisfactionLevel;
        }
        if (storedComments != null) {
          commentsController.text = storedComments;
        }

        // Set the status from Firestore if available
        status.value = project['status'] ?? 'completed';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Project Name: ${project['projectName'] ?? 'No Name'}",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text("Client Name: ${project['clientName'] ?? 'No Client'}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(
                  "Property Type: ${project['propertyType'] ?? 'No Property Type'}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text("Preferred Day: ${project['preferredDay'] ?? 'No Day'}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text("Preferred Time: ${project['preferredTime'] ?? 'No Time'}",
                  style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 10),
              Text(
                  "Solar Capacity: ${project['solarCapacity'] ?? 'No Capacity'} kW",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text("Solar Type: ${project['solarType'] ?? 'No Solar Type'}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(
                  "Structure Type: ${project['structureType'] ?? 'No Structure Type'}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),

              // Task Completion Video Section
              if (videoUrl != null && videoUrl.isNotEmpty) ...[
                const Text("Task Completion Video",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                // Centered Chewie video player
                Center(child: VideoPlayerWidget(videoUrl: videoUrl)),
                const SizedBox(height: 20),
                // Buttons for Download and Share
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _downloadVideo(videoUrl),
                      child: const Text("Download Video"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => _shareVideo(videoUrl),
                      child: const Text("Share Video"),
                    ),
                  ],
                ),
              ] else ...[
                // Display message if video is not available
                const Center(
                  child: Text(
                    "Video not available.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                // Option to capture the video if it's missing
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => VideoCaptureScreen(projectId: projectId));
                  },
                  child: const Text("Capture Video for Task Completion"),
                ),
              ],

              const SizedBox(height: 20),

              // If task is not completed, show the rating and comment input fields
              if (!isCompleted.value) ...[
                const Text("Project Satisfaction Level (1 to 10)",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: satisfactionLevel.value.isEmpty
                      ? null
                      : satisfactionLevel.value,
                  hint: const Text("Select Satisfaction Level"),
                  items: List.generate(10, (index) {
                    final level = (index + 1).toString();
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }),
                  onChanged: (newValue) {
                    satisfactionLevel.value = newValue!;
                  },
                ),
                const SizedBox(height: 20),

                const Text("Comments about the visit:",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextField(
                  controller: commentsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter comments..."),
                ),
                const SizedBox(height: 20),

                // Save/Submit button for comments and satisfaction
                ElevatedButton(
                  onPressed: () => _saveTaskCompletion(),
                  child: const Text("Submit Task Completion"),
                ),
              ] else ...[
                // If task is completed, show the submitted data in a Card
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Satisfaction Level: ${satisfactionLevel.value}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Comments: ${commentsController.text}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Approval Button for Manager
              const SizedBox(height: 20),
              if (status.value == 'completed') ...[
                ElevatedButton(
                  onPressed: () async {
                    // Update status to 'approved' in Firestore
                    await FirebaseFirestore.instance
                        .collection("Projects")
                        .doc(projectId)
                        .update({
                      "status": "approved",
                    });

                    status.value = 'approved'; // Update UI in real-time
                  },
                  child: const Text("Approve Project"),
                ),
              ],

              // Display the approval status on the tile
              const SizedBox(height: 20),
              Row(
                children: [
                  Text("Status: ",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    status.value,
                    style: TextStyle(
                      fontSize: 16,
                      color: status.value == 'approved'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _saveTaskCompletion() async {
    final String comments = commentsController.text;
    final String satisfaction = satisfactionLevel.value;

    // Make sure satisfaction and comments are filled
    if (satisfaction.isEmpty || comments.isEmpty) {
      Get.snackbar("Error", "Please fill out satisfaction level and comments");
      return;
    }

    try {
      // Update project status, satisfaction, and comments in Firestore
      await FirebaseFirestore.instance
          .collection("Projects")
          .doc(projectId)
          .update({
        "status": "completed", // Mark task as completed
        "satisfactionLevel": satisfaction,
        "comments": comments,
      });

      isCompleted.value = true; // Disable further editing after submission

      Get.snackbar("Success", "Task completion updated!");
    } catch (e) {
      Get.snackbar("Error", "Failed to update task completion: $e");
    }
  }

  Future<void> _downloadVideo(String videoUrl) async {
    final permissionStatus = await Permission.storage.request();

    if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
      Get.snackbar("Permission Denied", "Storage permission is required.");
      return;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = videoUrl.split('/').last;
      final filePath = '${appDir.path}/$fileName';

      final taskId = await FlutterDownloader.enqueue(
        url: videoUrl,
        savedDir: appDir.path,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // open file after download completes (for Android)
      );

      if (taskId != null) {
        Get.snackbar("Success", "Video download started.");
      } else {
        Get.snackbar("Error", "Failed to start video download.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to download the video: $e");
    }
  }

  // Share the video
  Future<void> _shareVideo(String videoUrl) async {
    try {
      await Share.share('Check out this video: $videoUrl');
    } catch (e) {
      Get.snackbar("Error", "Failed to share the video: $e");
    }
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({required this.videoUrl, Key? key}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true,
    );

    _controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Chewie(controller: _chewieController),
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }
}

class ProjectDetailsController extends GetxController {
  Rx<Map<String, dynamic>> project = Rx<Map<String, dynamic>>({});

  void listenToProjectChanges(String projectId) {
    FirebaseFirestore.instance
        .collection("Projects")
        .doc(projectId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        project.value = snapshot.data() as Map<String, dynamic> ?? {};
      }
    });
  }
}

// Start/Stop Video Control Buttons
class VideoControlButtons extends StatefulWidget {
  final String videoUrl;

  const VideoControlButtons({required this.videoUrl, Key? key})
      : super(key: key);

  @override
  _VideoControlButtonsState createState() => _VideoControlButtonsState();
}

class _VideoControlButtonsState extends State<VideoControlButtons> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_controller.value.isPlaying) {
          _controller.pause();
        } else {
          _controller.play();
        }
        setState(() {}); // Refresh the widget
      },
      child: Icon(
        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        size: 30,
      ),
    );
  }
}

class SalesEmployeeFormController extends GetxController {
  var fullName = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var address = ''.obs;
  var propertyType = ''.obs;
  var preferredDay = ''.obs;
  var preferredTime = ''.obs;
  var engineerAssigned = ''.obs; // UID of the engineer assigned
  var solarType = ''.obs; // Type of solar system
  var solarCapacity = ''.obs; // kW for solar system
  var structureType = ''.obs; // Elevated or other
  var isSubmitting = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // This will fetch available engineers from the Firestore or API
  Rx<List<Map<String, dynamic>>> availableEngineers =
      Rx<List<Map<String, dynamic>>>([]);

  @override
  void onInit() {
    super.onInit();
    fetchEngineers();
    fetchCreatedProjects(); // Fetch engineers on controller initialization
  }

  var createdProjects =
      RxList<Map<String, dynamic>>([]); // List to store projects
  var isLoading = false.obs;

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
          .where("salesEmployeeId",
              isEqualTo: currentUser.uid) // Filter by salesEmployeeId
          .get();

      // Update the reactive list of created projects
      createdProjects.value = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch projects: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch available engineers
  Future<void> fetchEngineers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("Employees")
          .where("designation",
              isEqualTo:
                  "Engineer") // Filter employees with "Engineer" designation
          .get();

      availableEngineers.value = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch available engineers: $e");
    }
  }

  Future<void> submitForm() async {
    if (fullName.value.isNotEmpty &&
        email.value.isNotEmpty &&
        phone.value.isNotEmpty &&
        address.value.isNotEmpty &&
        propertyType.value.isNotEmpty &&
        preferredDay.value.isNotEmpty &&
        preferredTime.value.isNotEmpty &&
        engineerAssigned.value.isNotEmpty &&
        solarType.value.isNotEmpty &&
        solarCapacity.value.isNotEmpty &&
        structureType.value.isNotEmpty) {
      isSubmitting.value = true;

      try {
        User? user = _auth.currentUser;
        if (user != null) {
          // Create new project in Firestore
          DocumentReference projectRef =
              await _firestore.collection("Projects").add({
            "clientName": fullName.value,
            "projectName": address.value,
            "salesEmployeeId": user.uid,
            "assignedEngineerId": engineerAssigned.value,
            "status": "pending", // Set status to pending initially
            "createdAt": FieldValue.serverTimestamp(),
            "propertyType": propertyType.value,
            "preferredDay": preferredDay.value,
            "preferredTime": preferredTime.value,
            "solarType": solarType.value,
            "solarCapacity": solarCapacity.value,
            "structureType": structureType.value,
          });

          // After adding the project, navigate back to the dashboard
          Get.back(); // This will navigate back to the previous screen (Employee Dashboard)
          Get.snackbar("Success", "Project created successfully!");
        }
      } catch (e) {
        Get.snackbar("Error", "Failed to create project: $e");
      } finally {
        isSubmitting.value = false;
      }
    } else {
      Get.snackbar("Error", "Please fill out all fields.");
    }
  }
}

class SalesEmployeeForm extends StatelessWidget {
  final SalesEmployeeFormController controller =
      Get.put(SalesEmployeeFormController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request a Consultation"),
      ),
      body: SingleChildScrollView(
        // Wrap the entire body in a scroll view
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isSubmitting.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1: Contact Info
              const Text("Step 1: Contact Info",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                onChanged: (value) => controller.fullName.value = value,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),
              TextField(
                onChanged: (value) => controller.email.value = value,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                onChanged: (value) => controller.phone.value = value,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              const SizedBox(height: 20),

              // Step 2: Installation Details
              const Text("Step 2: Installation Details",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                onChanged: (value) => controller.address.value = value,
                decoration:
                    const InputDecoration(labelText: "Address of Installation"),
              ),
              const SizedBox(height: 10),
              const Text("Property Type"),
              DropdownButton<String>(
                value: controller.propertyType.value.isEmpty
                    ? null
                    : controller.propertyType.value,
                hint: const Text("Select Property Type"),
                items: <String>[
                  'Residential',
                  'Commercial',
                  'Industrial',
                  'Agricultural'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    controller.propertyType.value = newValue!,
              ),
              const SizedBox(height: 10),

              // Step 3: Solar System Details
              const Text("Step 3: Solar System Details",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Text("Type of Solar System"),
              DropdownButton<String>(
                value: controller.solarType.value.isEmpty
                    ? null
                    : controller.solarType.value,
                hint: const Text("Select Solar Type"),
                items: <String>['Hybrid', 'On-grid', 'Off-grid']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) => controller.solarType.value = newValue!,
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) => controller.solarCapacity.value = value,
                decoration:
                    const InputDecoration(labelText: "Solar Capacity (kW)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              const Text("Structure Type"),
              DropdownButton<String>(
                value: controller.structureType.value.isEmpty
                    ? null
                    : controller.structureType.value,
                hint: const Text("Select Structure Type"),
                items: <String>['Elevated', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    controller.structureType.value = newValue!,
              ),
              const SizedBox(height: 20),

              // Step 4: Assign Engineer
              const Text("Step 4: Assign Engineer",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: controller.engineerAssigned.value.isEmpty
                    ? null
                    : controller.engineerAssigned.value,
                hint: const Text("Select Engineer"),
                items: controller.availableEngineers.value.map((engineer) {
                  return DropdownMenuItem<String>(
                    value: engineer['uid'],
                    child: Text(engineer['name']),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    controller.engineerAssigned.value = newValue!,
              ),
              const SizedBox(height: 20),

              // Step 5: Schedule Your Consultation
              const Text("Step 5: Schedule Your Consultation",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Text("Preferred Day"),
              DropdownButton<String>(
                value: controller.preferredDay.value.isEmpty
                    ? null
                    : controller.preferredDay.value,
                hint: const Text("Select Preferred Day"),
                items: <String>[
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    controller.preferredDay.value = newValue!,
              ),
              const SizedBox(height: 10),
              const Text("Preferred Time"),
              DropdownButton<String>(
                value: controller.preferredTime.value.isEmpty
                    ? null
                    : controller.preferredTime.value,
                hint: const Text("Select Preferred Time"),
                items: <String>[
                  'Morning (9am-12pm)',
                  'Afternoon (12pm-5pm)',
                  'Evening (5pm-8pm)'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    controller.preferredTime.value = newValue!,
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: controller.submitForm,
                child: const Text("Submit Your Request"),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class VideoCaptureController extends GetxController
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  RxBool isRecording = false.obs;
  RxString? videoPath = RxString('');
  RxInt recordDuration = 0.obs;
  Timer? _timer;
  RxBool isCameraInitialized = false.obs;
  RxString debugMessage = "Initializing camera...".obs;
  RxBool isUploading = false.obs; // Add uploading state
  RxBool isVideoUploaded = false.obs; // New state to track video upload
  RxBool isTaskCompleted = false.obs; // Track task completion

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameraWithPermissions();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _stopTimer();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraWithPermissions();
    }
  }

  Future<void> _initializeCameraWithPermissions() async {
    debugMessage.value = "Requesting camera permission...";

    if (!await _requestCameraPermission()) {
      debugMessage.value = "Camera permission denied.";
      return;
    }

    debugMessage.value = "Fetching available cameras...";

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugMessage.value = "No cameras available on this device.";
        return;
      }

      debugMessage.value = "Selecting back camera...";

      final CameraDescription camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      debugMessage.value = "Initializing camera controller...";

      await _controller!.initialize();
      if (Get.context == null) return;

      debugMessage.value = "Camera initialized successfully.";
      isCameraInitialized.value = true;
    } catch (e) {
      debugMessage.value = "Failed to initialize camera: $e";
      Get.snackbar("Error", "Camera initialization failed: $e");
    }
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      Get.snackbar(
        "Permission Denied",
        "Camera permission is permanently denied. Please enable it in settings.",
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: const Text("Open Settings"),
        ),
      );
    } else {
      Get.snackbar("Error", "Camera permission is required to record video.");
    }
    return false;
  }

  Future<void> startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      Get.snackbar("Error", "Camera not initialized");
      return;
    }

    isRecording.value = true;
    recordDuration.value = 0;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String videoFilePath = '${appDir.path}/video.mp4';

    await _controller!.startVideoRecording();
    videoPath?.value = videoFilePath;

    _startTimer();
  }

  Future<void> stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) {
      return;
    }

    _stopTimer();

    final XFile videoFile = await _controller!.stopVideoRecording();
    isRecording.value = false;
    videoPath?.value = videoFile.path;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordDuration.value++;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> uploadVideo(String projectId) async {
    final path = videoPath?.value;
    if (path == null) {
      Get.snackbar("Error", "No video recorded");
      return;
    }

    isUploading.value = true; // Set uploading state to true

    try {
      // Compress the video before uploading
      File? compressedVideo = await _compressVideo(File(path));

      if (compressedVideo != null) {
        // Upload the compressed video
        await _uploadVideoToStorage(compressedVideo, projectId);
        isVideoUploaded.value = true; // Mark video as uploaded
        Get.snackbar("Success", "Video uploaded successfully!");
      } else {
        Get.snackbar("Error", "Failed to compress the video");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to upload video: $e");
    } finally {
      isUploading.value = false; // Set uploading state to false
    }
  }

  Future<File?> _compressVideo(File videoFile) async {
    final MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      videoFile.path,
      quality: VideoQuality.LowQuality, // Low quality for space efficiency
      deleteOrigin: false, // Don't delete original video
    );

    if (mediaInfo != null) {
      return File(mediaInfo.path!); // Return the compressed video file
    } else {
      print('Video compression failed');
      return null;
    }
  }

  Future<void> _uploadVideoToStorage(
      File compressedVideo, String projectId) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'task_videos/$projectId/${DateTime.now().millisecondsSinceEpoch}.mp4');

      final uploadTask = storageRef.putFile(compressedVideo);

      await uploadTask.whenComplete(() async {
        String videoUrl = await storageRef.getDownloadURL();

        // Store the video URL in Firestore but do not change the status yet
        await FirebaseFirestore.instance
            .collection("Projects")
            .doc(projectId)
            .update({
          "completedTaskVideoUrl": videoUrl,
        });

        // Do not update the status yet
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to upload video: $e");
    }
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<int> _getRotationQuarterTurns() async {
    final nativeOrientation =
        await NativeDeviceOrientationCommunicator().orientation();
    switch (nativeOrientation) {
      case NativeDeviceOrientation.portraitUp:
        return 1; // 90 degrees (rotate landscape to portrait)
      case NativeDeviceOrientation.portraitDown:
        return 3; // 270 degrees (rotate landscape to inverted portrait)
      case NativeDeviceOrientation.landscapeLeft:
        return 2; // 180 degrees (rotate landscape to match landscapeLeft)
      case NativeDeviceOrientation.landscapeRight:
        return 0; // 0 degrees (no rotation for landscapeRight, matches naturally)
      default:
        return 0;
    }
  }

  // After all the required inputs (video, rating, comments) are completed,
  // update the status to 'completed' and save the rating and comments.
  Future<void> submitTaskCompletion(
      String projectId, String rating, String comment) async {
    try {
      await FirebaseFirestore.instance
          .collection("Projects")
          .doc(projectId)
          .update({
        "status": "completed",
        "rating": rating,
        "comment": comment,
      });
      isTaskCompleted.value = true; // Mark the task as completed
      Get.snackbar("Success", "Task completed successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to submit task completion: $e");
    }
  }
}

class VideoCaptureScreen extends StatelessWidget {
  final String projectId;

  const VideoCaptureScreen({required this.projectId, super.key});

  @override
  Widget build(BuildContext context) {
    final VideoCaptureController controller = Get.put(VideoCaptureController());

    return Scaffold(
      appBar: AppBar(title: const Text("Capture Video")),
      body: Obx(() {
        // Show loading state if the video is being uploaded
        if (controller.isUploading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            Expanded(
              child: controller.isCameraInitialized.value &&
                      controller._controller != null &&
                      controller._controller!.value.isInitialized
                  ? FutureBuilder<int>(
                      // Handle device rotation
                      future: controller._getRotationQuarterTurns(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return RotatedBox(
                          quarterTurns: snapshot.data!,
                          child: AspectRatio(
                            aspectRatio:
                                controller._controller!.value.aspectRatio,
                            child: CameraPreview(controller._controller!),
                          ),
                        );
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            if (controller.isRecording.value) ...[
              Text(
                "Recording: ${controller._formatDuration(controller.recordDuration.value)}",
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    controller.isRecording.value ? Icons.stop : Icons.videocam,
                    color:
                        controller.isRecording.value ? Colors.red : Colors.blue,
                    size: 50,
                  ),
                  onPressed: () {
                    if (controller.isRecording.value) {
                      controller.stopRecording();
                    } else {
                      controller.startRecording();
                    }
                  },
                ),
              ],
            ),
            if (!controller.isRecording.value &&
                controller.videoPath?.value != null) ...[
              ElevatedButton(
                onPressed: () {
                  // Show loading spinner while uploading the video
                  controller.uploadVideo(projectId).then((_) {
                    // After video is uploaded, go back to Project Details
                    Get.back(); // Navigate back to previous project details page
                  });
                },
                child: const Text("Submit Video"),
              ),
            ],
          ],
        );
      }),
    );
  }
}
