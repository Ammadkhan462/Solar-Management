import 'dart:io';

import 'package:admin/app/modules/EmployeeDashboard/controllers/employee_dashboard_controller.dart';
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
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  String? _videoPath;
  VideoPlayerController? _videoPlayerController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      _initializeControllerFuture = _controller.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      Get.snackbar("Error", "Failed to initialize camera: $e");
    }
  }

  Future<void> _startRecording() async {
    try {
      await _initializeControllerFuture;

      // Get the temporary directory for saving video
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Start video recording
      await _controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _videoPath = path;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to start recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      // Stop recording
      final file = await _controller.stopVideoRecording();

      // After stopping, set the video path and initialize the video player
      setState(() => _isRecording = false);

      // Initialize video player for playback
      _videoPlayerController = VideoPlayerController.file(File(file.path))
        ..initialize().then((_) {
          if (mounted) setState(() {});
          _videoPlayerController?.play();
        });

      // Update the video path correctly
      setState(() {
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

      widget.onVideoSubmitted(downloadUrl); // update parent tile
      Get.snackbar("Success", "Video uploaded successfully!");

      // pop this screen immediately
      if (mounted) Navigator.of(context).pop(); // or Get.back();
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
    _controller.dispose();
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
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

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
                    : CameraPreview(_controller),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Record/Stop recording button
                          IconButton(
                            icon: Icon(
                              _isRecording ? Icons.stop : Icons.videocam,
                            ),
                            color: _isRecording ? Colors.red : Colors.blue,
                            iconSize: 60,
                            onPressed:
                                _isRecording ? _stopRecording : _startRecording,
                          ),
                          const SizedBox(width: 20),
                          // Video submission buttons
                          if (_videoPath != null) ...[
                            ElevatedButton(
                              onPressed: _uploadVideo,
                              child: const Text("Submit Video"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _videoPath = null;
                                  _videoPlayerController?.dispose();
                                  _videoPlayerController = null;
                                });
                              },
                              child: const Text("Retake Video"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                                textStyle: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
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
