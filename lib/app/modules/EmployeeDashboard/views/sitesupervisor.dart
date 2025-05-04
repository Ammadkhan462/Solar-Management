import 'dart:io';

import 'package:admin/app/modules/EmployeeDashboard/controllers/employee_dashboard_controller.dart';
import 'package:admin/app/modules/EmployeeDashboard/views/employee_dashboard_view.dart';
import 'package:admin/app/modules/EmployeeDashboard/views/projectdetails.dart'
    show ProjectDetailsScreen;
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class TaskCompletionScreen extends StatelessWidget {
  final String projectId;
  const TaskCompletionScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final tasksController = Get.put(ProjectTasksController(projectId));
    final dashboard = Get.find<EmployeeDashboardController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Task Completion')),
      body: Obx(() {
        if (tasksController.project.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final project = tasksController.project.value;
        final status = project['status'] ?? 'pending';

        return Column(
          children: [
            // Status and progress
            Container(
              padding: const EdgeInsets.all(16),
              color: _getStatusColor(status),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Project Status: ${status.toUpperCase()}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (project['progress'] != null)
                    Text(
                      "Progress: ${project['progress']}%",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            // Task List with Re-upload Button
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: dashboard.getProjectTasks().length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = dashboard.getProjectTasks()[index];
                  final isDone = tasksController.isTaskDone(task);
                  final videoUrl = tasksController.videoFor(task);

                  return Obx(() {
                    final currentIsDone = tasksController.isTaskDone(task);
                    final currentVideoUrl = tasksController.videoFor(task);

                    return ListTile(
                      tileColor: currentIsDone
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      title: Text(task),
                      leading: Icon(
                        currentIsDone
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: currentIsDone ? Colors.green : Colors.grey,
                      ),
                      trailing:
                          currentVideoUrl != null && currentVideoUrl.isNotEmpty
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.replay,
                                          color: Colors.blue),
                                      onPressed: () => Get.to(
                                        () => VideoCaptureScreen(
                                          projectId: projectId,
                                          taskName: task,
                                          onVideoSubmitted: (url) async {
                                            tasksController.optimisticUpdate(
                                                task, url);
                                            await dashboard.markTaskAsCompleted(
                                              projectId,
                                              task,
                                              videoUrl: url,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                      onTap: currentIsDone
                          ? null
                          : () => Get.to(
                                () => VideoCaptureScreen(
                                  projectId: projectId,
                                  taskName: task,
                                  onVideoSubmitted: (url) async {
                                    tasksController.optimisticUpdate(task, url);
                                    await dashboard.markTaskAsCompleted(
                                      projectId,
                                      task,
                                      videoUrl: url,
                                    );
                                  },
                                ),
                              ),
                    );
                  });
                },
              ),
            ),
          ],
        );
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

class VideoCaptureScreen extends StatefulWidget {
  final String projectId;
  final String taskName;
  final Function(String) onVideoSubmitted;

  const VideoCaptureScreen({
    required this.projectId,
    required this.taskName,
    required this.onVideoSubmitted,
    Key? key,
  }) : super(key: key);

  @override
  _VideoCaptureScreenState createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends State<VideoCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;
  String? _videoPath;
  VideoPlayerController? _videoPlayerController;
  bool _isUploading = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize camera asynchronously
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Show loading indicator while initializing
      setState(() {
        _isCameraInitialized = false;
      });

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar("Error", "No cameras found on device");
        return;
      }

      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      _initializeControllerFuture = _controller!.initialize();

      // Wait for controller to initialize before updating UI
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      Get.snackbar("Camera Error", "Failed to initialize camera: $e");
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_isCameraInitialized) {
      Get.snackbar("Error", "Camera not ready");
      return;
    }

    try {
      // Start video recording
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to start recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_isRecording) {
      return;
    }

    try {
      // Stop recording
      final file = await _controller!.stopVideoRecording();

      // Initialize video player for playback
      _videoPlayerController = VideoPlayerController.file(File(file.path))
        ..initialize().then((_) {
          if (mounted) setState(() {});
          _videoPlayerController?.play();
        });

      // Update the video path correctly
      setState(() {
        _isRecording = false;
        _videoPath = file.path;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to stop recording: $e");
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoPath == null || !File(_videoPath!).existsSync()) {
      Get.snackbar("Error", "No video recorded");
      return;
    }

    setState(() => _isUploading = true);

    try {
      final ref = FirebaseStorage.instance.ref().child(
            'project_tasks/${widget.projectId}/${widget.taskName}_${DateTime.now().millisecondsSinceEpoch}.mp4',
          );
      await ref.putFile(File(_videoPath!));
      final downloadUrl = await ref.getDownloadURL();

      widget.onVideoSubmitted(downloadUrl); // Update parent tile

      // After successfully uploading, navigate back to TaskCompletionScreen
      Get.snackbar("Success", "Video uploaded successfully!");

      // Pop the current screen and go back to TaskCompletionScreen
      // Approach 1: Force navigation using Get.off() instead of Get.back()
      // Solution 3: Replace the current route instead of adding a new one
      if (mounted) {
        Navigator.of(context)
            .pop(); // Use standard Flutter navigation instead of GetX
      }
    } on FirebaseException catch (e) {
      Get.snackbar("Upload Error", e.message ?? "Failed to upload video");
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Record ${widget.taskName} Completion"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show loading indicator if camera is not initialized
    if (!_isCameraInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Initializing camera..."),
          ],
        ),
      );
    }

    // Show camera UI if initialized
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Camera or Video player preview
        Expanded(
          child: _videoPath != null && _videoPlayerController != null
              ? AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CameraPreview(_controller!),
                  ),
                ),
        ),
        _buildControls(),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: _isUploading
          ? const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("Uploading video..."),
                ],
              ),
            )
          : Column(
              children: [
                // Recording indicator
                if (_isRecording)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text("RECORDING",
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),

                // Record/Stop button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: _isRecording ? Colors.red : Colors.blue,
                    child: IconButton(
                      icon: Icon(
                        _isRecording ? Icons.stop : Icons.videocam,
                        size: 36,
                        color: Colors.white,
                      ),
                      onPressed:
                          _isRecording ? _stopRecording : _startRecording,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Video submission buttons
                if (_videoPath != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _uploadVideo,
                        icon: const Icon(Icons.upload),
                        label: const Text("Submit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _videoPath = null;
                            _videoPlayerController?.dispose();
                            _videoPlayerController = null;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retake"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}

class ProjectTasksController extends GetxController {
  final String projectId;
  ProjectTasksController(this.projectId);

  /// Live snapshot of the current project document.
  final Rx<Map<String, dynamic>> project = Rx<Map<String, dynamic>>({});

  // Convenience getters ----------------------------------------------------
  Map<String, bool> get _taskStatus =>
      Map<String, bool>.from(project.value['tasks'] ?? {});

  Map<String, String> get _taskVideos =>
      Map<String, String>.from(project.value['taskVideos'] ?? {});

  bool isTaskDone(String task) => _taskStatus[task] == true;

  String? videoFor(String task) => _taskVideos[task];

  /// Subscribe once at init and keep controller alive while UI is mounted.
  @override
  void onInit() {
    super.onInit();
    FirebaseFirestore.instance
        .collection('Projects')
        .doc(projectId)
        .snapshots()
        .listen((snap) => project.value = snap.data() ?? {});
  }

  /// ***Optimistic*** patch so tile changes colour the instant we upload.
  void optimisticUpdate(String task, String videoUrl) {
    final now = DateTime.now();
    project.update((p) {
      p?['tasks'] ??= <String, bool>{};
      p?['taskVideos'] ??= <String, String>{};
      p!['tasks'][task] = true;
      p['taskVideos'][task] = videoUrl;
      p['lastUpdated'] = now;
    });
  }
}

// Add this to your utils or helpers file
class ProjectNavigation {
  static void navigateToProject(
      String projectId, EmployeeDashboardController controller) {
    Map<String, dynamic>? project;

    // Check in assigned projects first
    project = controller.assignedProjects
        .firstWhereOrNull((p) => p['id'] == projectId);

    // If not found, check in created projects
    if (project == null) {
      project = controller.createdProjects
          .firstWhereOrNull((p) => p['id'] == projectId);
    }

    // If project not found at all, show error
    if (project == null) {
      Get.snackbar("Error", "Project not found");
      return;
    }

    final String status = project['status'] ?? 'pending';

    // Navigation logic based on role and status
    if (controller.isSalesEmployee) {
      // Sales employee always sees project details
      Get.to(() => ProjectDetailsScreen(projectId: projectId));
    } else if (controller.isEngineer || controller.isSiteSupervisor) {
      // Engineers and Site Supervisors see TaskCompletion for 'doing' projects
      // and ProjectDetails for 'pending' projects
      if (status == 'doing') {
        Get.to(() => TaskCompletionScreen(projectId: projectId));
      } else {
        Get.to(() => ProjectDetailsScreen(projectId: projectId));
      }
    } else if (controller.isElectrician || controller.isTechnician) {
      // Electricians and Technicians always see TaskCompletion
      Get.to(() => TaskCompletionScreen(projectId: projectId));
    } else if (controller.isProjectManager) {
      // Project managers always see project details
      Get.to(() => ProjectDetailsScreen(projectId: projectId));
    } else {
      // Default fallback to project details
      Get.to(() => ProjectDetailsScreen(projectId: projectId));
    }
  }
}
