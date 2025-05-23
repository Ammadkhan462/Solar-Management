import 'dart:io';

import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/app/modules/EmployeeDashboard/controllers/employee_dashboard_controller.dart';
import 'package:admin/app/modules/EmployeeDashboard/views/employee_dashboard_view.dart';
import 'package:admin/app/modules/EmployeeDashboard/views/projectdetails.dart'
    show ProjectDetailsScreen;
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TaskCompletionScreen extends StatelessWidget {
  final String projectId;
  const TaskCompletionScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final tasksController = Get.put(ProjectTasksController(projectId));
    final dashboard = Get.find<EmployeeDashboardController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Task Completion'),
      body: Obx(() {
        if (tasksController.project.value.isEmpty) {
          return const LoadingIndicator();
        }

        final project = tasksController.project.value;
        final status = project['status'] ?? 'pending';

        return Container(
          color: Colors.grey[50],
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProjectHeader(project: project, status: status),
                ProjectDetailsCard(project: project),
                if (project['breakerQuantities'] != null ||
                    project['casingQuantities'] != null)
                  ComponentsCard(project: project),
                TasksCard(
                  project: project,
                  tasksController: tasksController,
                  dashboard: dashboard,
                  projectId: projectId,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Reusable Widgets

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.buildingBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
      ),
    );
  }
}

class ProjectHeader extends StatelessWidget {
  final Map project;
  final String status;

  const ProjectHeader({super.key, required this.project, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.buildingBlue,
            AppColors.buildingBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project['projectName']?.isNotEmpty == true
                      ? project['projectName']
                      : 'Unnamed Project',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              if (project['priority'] != null)
                PriorityTag(priority: project['priority']),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.business, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Client: ${project['clientName']?.isNotEmpty == true ? project['clientName'] : 'N/A'}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatusIndicator(status: status),
              ),
              if (project['progress'] != null)
                ProgressIndicator(progress: project['progress']),
            ],
          ),
        ],
      ),
    );
  }
}

class PriorityTag extends StatelessWidget {
  final String priority;

  const PriorityTag({super.key, required this.priority});

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return AppColors.accentOrange;
      case 'low':
        return AppColors.primaryGreen;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPriorityColor(),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _getPriorityColor().withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        priority.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}

class StatusIndicator extends StatelessWidget {
  final String status;

  const StatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    String statusText;
    Color statusColor;

    switch (status) {
      case 'completed':
        iconData = Icons.check_circle;
        statusText = 'COMPLETED';
        statusColor = AppColors.primaryGreen;
        break;
      case 'approved':
        iconData = Icons.thumb_up;
        statusText = 'APPROVED';
        statusColor = Colors.blue;
        break;
      case 'doing':
        iconData = Icons.engineering;
        statusText = 'IN PROGRESS';
        statusColor = AppColors.accentOrange;
        break;
      case 'pending':
      default:
        iconData = Icons.hourglass_empty;
        statusText = 'PENDING';
        statusColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  final dynamic progress;

  const ProgressIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final progressValue = progress is num ? progress.toDouble() / 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "$progress%",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 80,
          height: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }
}

class ProjectDetailsCard extends StatelessWidget {
  final Map project;

  const ProjectDetailsCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      icon: Icons.info_outline,
      title: 'Project Details',
      iconColor: AppColors.buildingBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 3.5,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              DetailItem(
                  label: 'Start Date',
                  value: project['startDate'] ?? 'N/A',
                  icon: Icons.calendar_today),
              DetailItem(
                  label: 'End Date',
                  value: project['endDate'] ?? 'N/A',
                  icon: Icons.event),
              DetailItem(
                  label: 'Email',
                  value: project['clientEmail'] ?? 'N/A',
                  icon: Icons.email),
              DetailItem(
                  label: 'Phone',
                  value: project['clientPhone'] ?? 'N/A',
                  icon: Icons.phone),
              DetailItem(
                  label: 'Total kW',
                  value: project['totalKw']?.toString() ?? 'N/A',
                  icon: Icons.bolt),
              DetailItem(
                  label: 'Panel Qty',
                  value: project['panelQuantity']?.toString() ?? 'N/A',
                  icon: Icons.grid_view),
              DetailItem(
                  label: 'PV Module',
                  value: project['pvModule'] ?? 'N/A',
                  icon: Icons.solar_power),
              DetailItem(
                  label: 'Inverter',
                  value: project['inverterType'] ?? 'N/A',
                  icon: Icons.settings_input_component),
              DetailItem(
                  label: 'Brand',
                  value: project['brand'] ?? 'N/A',
                  icon: Icons.branding_watermark),
              DetailItem(
                  label: 'Size',
                  value: project['size']?.toString() ?? 'N/A',
                  icon: Icons.straighten),
              DetailItem(
                  label: 'Wire Length',
                  value: project['wireLength'] ?? 'N/A',
                  icon: Icons.linear_scale),
            ],
          ),
          if (project['locationPinUrl'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: CommonButton(
                text: 'View Location',
                icon: Icons.location_on,
                onPressed: () async {
                  final url = project['locationPinUrl'] as String?;
                  if (url != null && url.isNotEmpty) {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot launch URL')),
                      );
                    }
                  }
                },
                color: AppColors.buildingBlue,
                width: double.infinity,
                height: 44,
              ),
            ),
        ],
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const DetailItem(
      {super.key,
      required this.label,
      required this.value,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.buildingBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: AppColors.buildingBlue),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ComponentsCard extends StatelessWidget {
  final Map project;

  const ComponentsCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      icon: Icons.category,
      title: 'Components',
      iconColor: AppColors.buildingBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project['breakerQuantities'] != null)
            ComponentSection(
              title: 'Breakers',
              icon: Icons.electrical_services,
              components: (project['breakerQuantities'] as Map)
                  .entries
                  .map((entry) => ComponentRow(
                      label: '${entry.key}', value: entry.value.toString()))
                  .toList(),
            ),
          if (project['casingQuantities'] != null)
            ComponentSection(
              title: 'Casings',
              icon: Icons.cases_outlined,
              components: (project['casingQuantities'] as Map)
                  .entries
                  .map((entry) => ComponentRow(
                      label: '${entry.key}', value: entry.value.toString()))
                  .toList(),
            ),
          ComponentSection(
            title: 'Battery',
            icon: Icons.battery_charging_full,
            components: [
              ComponentRow(
                  label: 'Install Battery',
                  value: project['installBattery'].toString())
            ],
          ),
        ],
      ),
    );
  }
}

class ComponentSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> components;

  const ComponentSection(
      {super.key,
      required this.title,
      required this.icon,
      required this.components});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.buildingBlue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...components,
        const SizedBox(height: 16),
      ],
    );
  }
}

class ComponentRow extends StatelessWidget {
  final String label;
  final String value;

  const ComponentRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '• $label',
            style: const TextStyle(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TasksCard extends StatelessWidget {
  final Map project;
  final ProjectTasksController tasksController;
  final EmployeeDashboardController dashboard;
  final String projectId;

  const TasksCard({
    super.key,
    required this.project,
    required this.tasksController,
    required this.dashboard,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = (project['tasks'] as Map?)?.length ?? 0;

    return CardContainer(
      icon: Icons.task_alt,
      title: 'Tasks',
      iconColor: AppColors.primaryGreen,
      child: tasks > 0
          ? ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final task = (project['tasks'] as Map).keys.toList()[index];
                return TaskItem(
                  task: task,
                  tasksController: tasksController,
                  dashboard: dashboard,
                  projectId: projectId,
                );
              },
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No tasks have been assigned yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final String task;
  final ProjectTasksController tasksController;
  final EmployeeDashboardController dashboard;
  final String projectId;

  const TaskItem({
    super.key,
    required this.task,
    required this.tasksController,
    required this.dashboard,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDone = tasksController.isTaskDone(task);
      final videoUrl = tasksController.videoFor(task);

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color:
              isDone ? AppColors.primaryGreen.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isDone ? AppColors.primaryGreen : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            task,
            style: TextStyle(
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              color: isDone
                  ? AppColors.deepBlack
                  : AppColors.deepBlack.withOpacity(0.8),
              decoration: isDone ? TextDecoration.none : null,
            ),
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? AppColors.primaryGreen : Colors.grey.shade200,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.circle_outlined,
              color: isDone ? Colors.white : Colors.grey,
              size: 20,
            ),
          ),
          trailing: videoUrl != null && videoUrl.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: AppColors.accentOrange,
                      size: 18,
                    ),
                  ),
                  onPressed: () => _navigateToVideoCapture(task),
                )
              : null,
          onTap: isDone ? null : () => _navigateToVideoCapture(task),
        ),
      );
    });
  }

  void _navigateToVideoCapture(String task) {
    Get.to(
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
    );
  }
}

// Common reusable widgets

class CardContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color iconColor;

  const CardContainer({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlack,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class AppColors {
  static const Color primaryGreen = Color(0xFF7BC043);
  static const Color deepBlack = Color(0xFF212121);
  static const Color buildingBlue = Color(0xFF2C5282);
  static const Color accentOrange = Color(0xFFF8A13F);
  static const Color lightGray = Color(0xFFE0E0E0);
}

class VideoCaptureScreen extends StatefulWidget {
  final String projectId;
  final String taskName;
  final Function(String) onVideoSubmitted;

  const VideoCaptureScreen({
    required this.projectId,
    required this.taskName,
    required this.onVideoSubmitted,
    super.key,
  });

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
        // Web-specific settings
        imageFormatGroup:
            kIsWeb ? ImageFormatGroup.jpeg : ImageFormatGroup.yuv420,
      );

      _initializeControllerFuture = _controller!.initialize();

      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      Get.snackbar("Camera Error", "Failed to initialize camera: $e");
      if (kIsWeb) {
        // Retry initialization for web
        await Future.delayed(const Duration(seconds: 1));
        _initializeCamera();
      }
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
      // Add a small delay for web to ensure camera is ready
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Stop recording
      final file = await _controller!.stopVideoRecording();

      // Ensure the file exists before proceeding
      if (!File(file.path).existsSync() && !kIsWeb) {
        throw Exception("Recorded file not found");
      }

      // Initialize video player for playback
      _videoPlayerController?.dispose(); // Dispose previous controller if any
      _videoPlayerController = VideoPlayerController.file(File(file.path));

      await _videoPlayerController!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _videoPlayerController?.play();
          });
        }
      });

      // Update the video path correctly
      if (mounted) {
        setState(() {
          _isRecording = false;
          _videoPath = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
      Get.snackbar("Error", "Failed to stop recording: $e");
      // Attempt to reinitialize camera
      if (kIsWeb) {
        await _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose().then((_) {
      // Additional cleanup for web
      if (kIsWeb) {
        _controller = null;
      }
    });
    _videoPlayerController?.dispose();
    super.dispose();
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
    project ??= controller.createdProjects
        .firstWhereOrNull((p) => p['id'] == projectId);

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
