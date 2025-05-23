import 'dart:async';
import 'package:admin/Common%20widgets/common_utils.dart';
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
import 'package:url_launcher/url_launcher.dart';
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
import 'package:http/http.dart' as http;

// ... (Previous imports and code remain unchanged)

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;

  ProjectDetailsScreen({super.key, required this.projectId});

  final RxString status = RxString('completed');
  final RxString satisfactionLevel = RxString('');
  final TextEditingController commentsController = TextEditingController();
  final RxBool isCompleted = false.obs;

  // Timer for deadline countdown
  final RxString timeRemaining = RxString('');
  Timer? _timer;

  void _launchMapsUrl(String url) async {
    if (url.isEmpty) {
      Get.snackbar(
        'Error',
        'No location URL available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar(
          'Error',
          'Could not open the map location',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid map URL: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProjectDetailsController controller =
        Get.put(ProjectDetailsController());
    final dashboardController = Get.find<EmployeeDashboardController>();
    final bool isSalesEmployee = dashboardController.isSalesEmployee;
    final bool isProjectManager = dashboardController.isProjectManager;

    controller.listenToProjectChanges(projectId);

    void startDeadlineTimer(ProjectDetailsController controller) {
      // Cancel any existing timer
      _timer?.cancel();

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (controller.project.value.isEmpty) return;

        // Get preferred day and time from project
        final preferredDay = controller.project.value['preferredDay'];
        final preferredTime = controller.project.value['preferredTime'];

        if (preferredDay == null || preferredTime == null) {
          timeRemaining.value = "No deadline set";
          return;
        }

        // Map day names to day of week numbers (1 = Monday, 7 = Sunday)
        final dayMap = {
          'Monday': 1,
          'Tuesday': 2,
          'Wednesday': 3,
          'Thursday': 4,
          'Friday': 5,
          'Saturday': 6,
          'Sunday': 7,
        };

        // Parse the preferred day
        final preferredDayNumber = dayMap[preferredDay];
        if (preferredDayNumber == null) {
          timeRemaining.value = "Invalid day format";
          return;
        }

        // Parse the preferred time (e.g., "Morning (9am-12pm)")
        int preferredHour = 9; // Default to 9am
        if (preferredTime.contains('(')) {
          final timeRegex = RegExp(r'(\d+)(?:am|pm)');
          final match = timeRegex.firstMatch(preferredTime);
          if (match != null) {
            preferredHour = int.parse(match.group(1)!);
            // Adjust for PM
            if (preferredTime.contains('pm') && preferredHour < 12) {
              preferredHour += 12;
            }
          }
        }

        // Get current time
        final now = DateTime.now();

        // Calculate the next occurrence of the preferred day in the current week
        int daysUntilPreferred = preferredDayNumber - now.weekday;

        // Calculate the deadline date for the preferred day/time in the current week
        final deadline = DateTime(
          now.year,
          now.month,
          now.day + daysUntilPreferred,
          preferredHour,
          0, // minutes
          0, // seconds
        );

        // Calculate time difference (can be negative if deadline has passed)
        final difference = deadline.difference(now);

        // Extract time components
        final days = difference.inDays;
        final hours = difference.inHours % 24;
        final minutes = difference.inMinutes % 60;
        final seconds = difference.inSeconds % 60;

        // Format the time remaining (show negative if deadline has passed)
        if (difference.isNegative) {
          timeRemaining.value =
              "${days.abs()} days, ${hours.abs()} hours, ${minutes.abs()} min, ${seconds.abs()} sec overdue";
        } else {
          timeRemaining.value =
              "$days days, $hours hours, $minutes min, $seconds sec";
        }
      });
    }

    Widget buildInfoRow(String label, String value,
        {bool isLink = false, Function()? onPressed}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                "$label:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.deepBlack,
                ),
              ),
            ),
            Expanded(
              child: isLink && onPressed != null
                  ? InkWell(
                      onTap: onPressed,
                      child: Text(
                        value ?? 'Not Specified', // Handle null with default
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  : Text(
                      value ?? 'Not Specified', // Handle null with default
                      style: TextStyle(fontSize: 14, color: AppTheme.deepBlack),
                    ),
            ),
          ],
        ),
      );
    }

    // Start deadline timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startDeadlineTimer(controller);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Details"),
        elevation: 0,
        backgroundColor: AppTheme.buildingBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("Project Information"),
                  content: const Text(
                      "This screen shows the details of your project. If you're an engineer or supervisor, "
                      "you can complete tasks and submit photos as evidence of progress."),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text("OK",
                          style: TextStyle(color: AppTheme.buildingBlue)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.project.value.isEmpty) {
          return Center(
              child: CircularProgressIndicator(color: AppTheme.buildingBlue));
        }
        final project = controller.project.value;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Status Banner
              Container(
                width: double.infinity,
                color: _getStatusColor(status.value),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(status.value),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Status: ${status.value.toUpperCase()}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    if (project['progress'] != null)
                      Text(
                        "Progress: ${project['progress']}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              // Deadline Countdown Timer
              Obx(() => Container(
                    width: double.infinity,
                    color: AppTheme.deepBlack.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          color: AppTheme.accentOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Deadline: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepBlack,
                          ),
                        ),
                        Text(
                          timeRemaining.value.isNotEmpty
                              ? timeRemaining.value
                              : "Loading...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  )),

              // Project Details Card
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Project Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepBlack,
                        ),
                      ),
                      Divider(color: AppTheme.lightGray),
                      const SizedBox(height: 8),
                      buildInfoRow("Project Name",
                          project['projectName'] ?? 'Not Specified'),
                      buildInfoRow("Client Name",
                          project['clientName'] ?? 'Not Specified'),
                      buildInfoRow("Property Type",
                          project['propertyType'] ?? 'Not Specified'),
                      buildInfoRow("Preferred Day",
                          project['preferredDay'] ?? 'Not Specified'),
                      buildInfoRow("Preferred Time",
                          project['preferredTime'] ?? 'Not Specified'),
                      buildInfoRow("Solar Capacity",
                          "${project['solarCapacity'] ?? 'Not Specified'} kW"),
                      buildInfoRow("Solar Type",
                          project['solarType'] ?? 'Not Specified'),
                      buildInfoRow("Structure Type",
                          project['structureType'] ?? 'Not Specified'),
                      // Add Address field to project info
                      buildInfoRow(
                          "Address", project['address'] ?? 'Not Specified'),
                      LocationUrlWidget(
                        url: project['locationPinUrl'] ?? '',
                        displayText: "Open in Google Maps",
                        onLaunch: _launchMapsUrl,
                      ),
                    ],
                  ),
                ),
              ),

              // Task Photos Section - Only visible for non-sales employees
              if (!isSalesEmployee &&
                  !isProjectManager &&
                  (status.value == 'pending' || status.value == 'completed'))
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Task Documentation",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepBlack,
                          ),
                        ),
                        Divider(color: AppTheme.lightGray),
                        const SizedBox(height: 12),

                        // Task Photo Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.0,
                          children: [
                            _buildTaskPhotoItem(
                              "Task 1",
                              project['taskPhotos']?['Task1'] ?? '',
                              project['id'] ?? projectId,
                              'Task1',
                              false, // Not read-only for non-sales employees
                            ),
                            _buildTaskPhotoItem(
                              "Task 2",
                              project['taskPhotos']?['Task2'] ?? '',
                              project['id'] ?? projectId,
                              'Task2',
                              false,
                            ),
                            _buildTaskPhotoItem(
                              "Task 3",
                              project['taskPhotos']?['Task3'] ?? '',
                              project['id'] ?? projectId,
                              'Task3',
                              false,
                            ),
                            _buildTaskPhotoItem(
                              "Task 4",
                              project['taskPhotos']?['Task4'] ?? '',
                              project['id'] ?? projectId,
                              'Task4',
                              false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Only show this section for sales employees if project is completed
              if (isSalesEmployee &&
                      project['taskPhotos'] != null &&
                      project['satisfactionLevel'] != null &&
                      project['comments'] != null &&
                      status.value == 'pending' ||
                  isProjectManager ||
                  (isSalesEmployee && status.value != 'Approved'))
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Installation Photos",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepBlack,
                          ),
                        ),
                        Divider(color: AppTheme.lightGray),
                        const SizedBox(height: 12),

                        // Read-only photo grid for sales employees
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.0,
                          children: [
                            _buildTaskPhotoItem(
                              "Task 1",
                              project['taskPhotos']?['Task1'] ??
                                  '', // Use 'Task1' instead of 'Structure'
                              project['id'] ?? projectId,
                              'Task1',
                              true,
                            ),
                            _buildTaskPhotoItem(
                              "Task 2",
                              project['taskPhotos']?['Task2'] ??
                                  '', // Use 'Task2' instead of 'Panel Installation'
                              project['id'] ?? projectId,
                              'Task2',
                              true,
                            ),
                            _buildTaskPhotoItem(
                              "Task 3",
                              project['taskPhotos']?['Task3'] ?? '',
                              project['id'] ?? projectId,
                              'Task3',
                              true,
                            ),
                            _buildTaskPhotoItem(
                              "Task 4",
                              project['taskPhotos']?['Task4'] ?? '',
                              project['id'] ?? projectId,
                              'Task4',
                              true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              if (isSalesEmployee ||
                  isProjectManager &&
                      project['satisfactionLevel'] != null &&
                      project['comments'] != null)
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Project Evaluation",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepBlack,
                          ),
                        ),
                        Divider(color: AppTheme.lightGray),
                        const SizedBox(height: 12),
                        buildInfoRow(
                            "Satisfaction Level",
                            project['satisfactionLevel']?.toString() ??
                                'Not Specified'),
                        const SizedBox(height: 12),
                        Text("Comments:",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepBlack)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.lightGray),
                          ),
                          child: Text(
                              project['comments']?.toString() ?? 'No Comments'),
                        ),
                      ],
                    ),
                  ),
                ),
              // Project Satisfaction section - Only editable for non-sales employees
              // and only if not already completed
              if (!isSalesEmployee &&
                  status.value == 'pending' &&
                  (project['satisfactionLevel'] == null ||
                      project['comments'] == null))
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Project Evaluation",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepBlack,
                          ),
                        ),
                        Divider(color: AppTheme.lightGray),
                        const SizedBox(height: 12),

                        // Satisfaction level dropdown
                        Text("Project Satisfaction Level (1 to 10)",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepBlack)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.lightGray),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: satisfactionLevel.value.isEmpty
                                  ? null
                                  : satisfactionLevel.value,
                              hint: Text("Select Satisfaction Level",
                                  style: TextStyle(
                                      color:
                                          AppTheme.deepBlack.withOpacity(0.6))),
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
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Comments field
                        Text("Comments about the project:",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepBlack)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: commentsController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppTheme.lightGray),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: AppTheme.primaryGreen, width: 2),
                            ),
                            hintText: "Enter comments...",
                            hintStyle: TextStyle(
                                color: AppTheme.deepBlack.withOpacity(0.6)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Submit button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _saveTaskCompletion(),
                            child: const Text("Submit Project Evaluation"),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              // Read-only Evaluation for non-sales employees after submission
              else if (!isSalesEmployee &&
                  !isProjectManager &&
                  status.value == 'pending' &&
                  project['satisfactionLevel'] != null &&
                  project['comments'] != null)
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Project Evaluation (Submitted)",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepBlack,
                          ),
                        ),
                        Divider(color: AppTheme.lightGray),
                        const SizedBox(height: 12),
                        buildInfoRow(
                            "Satisfaction Level", project['satisfactionLevel']),
                        const SizedBox(height: 12),
                        Text("Comments:",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.deepBlack)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.lightGray),
                          ),
                          child: Text(project['comments']),
                        ),
                      ],
                    ),
                  ),
                ),

              // Approval Button for Project Manager
              if (!isSalesEmployee && status.value == 'completed')
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Approve Project"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection("Projects")
                            .doc(projectId)
                            .update({
                          "status": "approved",
                        });
                        status.value = 'approved';
                        Get.snackbar(
                          "Project Approved",
                          "The project has been successfully approved",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor:
                              AppTheme.primaryGreen.withOpacity(0.2),
                          colorText: AppTheme.deepBlack,
                        );
                      },
                    ),
                  ),
                ),

              // Approval Button for Sales Employee
              if (isSalesEmployee && status.value == 'pending')
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Approve Project"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        // Show confirmation dialog
                        Get.dialog(
                          AlertDialog(
                            title: Text("Confirm Approval",
                                style: TextStyle(color: AppTheme.deepBlack)),
                            content: const Text(
                              "Are you sure you want to approve this project? This action cannot be undone.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text("Cancel",
                                    style:
                                        TextStyle(color: AppTheme.deepBlack)),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Get.back(); // Close dialog

                                  // Get the manager ID from controller
                                  final dashboardController =
                                      Get.find<EmployeeDashboardController>();
                                  final managerId = dashboardController
                                      .employee.value.managerId;

                                  // Update project status in Firestore with manager ID
                                  await FirebaseFirestore.instance
                                      .collection("Projects")
                                      .doc(projectId)
                                      .update({
                                    "status": "approved",
                                    "approvedBy": "sales",
                                    "approvedAt": FieldValue.serverTimestamp(),
                                    "managerId":
                                        managerId, // Add manager ID here
                                  });

                                  status.value = 'approved';

                                  Get.snackbar(
                                    "Project Approved",
                                    "The project has been successfully approved",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor:
                                        AppTheme.primaryGreen.withOpacity(0.2),
                                    colorText: AppTheme.deepBlack,
                                  );
                                },
                                child: Text("Approve",
                                    style: TextStyle(
                                        color: AppTheme.primaryGreen)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.deepBlack,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: AppTheme.deepBlack),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskPhotoItem(String taskName, String photoUrl, String projectId,
      String taskKey, bool readOnly) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: photoUrl.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      Get.to(() => FullScreenImageViewer(imageUrl: photoUrl));
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: AppTheme.buildingBlue,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child:
                                Icon(Icons.error, color: AppTheme.accentOrange),
                          );
                        },
                      ),
                    ),
                  )
                : Container(
                    color: AppTheme.lightGray.withOpacity(0.5),
                    child: Center(
                      child: readOnly
                          ? Text("No Photo",
                              style: TextStyle(
                                  color: AppTheme.deepBlack.withOpacity(0.6)))
                          : Icon(Icons.photo_camera,
                              color: AppTheme.deepBlack.withOpacity(0.4),
                              size: 40),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Column(
              children: [
                Text(
                  taskName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.deepBlack,
                  ),
                ),
                if (!readOnly && photoUrl.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ElevatedButton(
                      onPressed: () => _captureTaskPhoto(projectId, taskKey),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buildingBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(30, 30),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        "Capture",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _captureTaskPhoto(String projectId, String taskKey) {
    // Navigate to photo capture screen
    Get.to(() => PhotoCaptureScreen(
          projectId: projectId,
          taskName: taskKey,
          onPhotoSubmitted: (url) async {
            // Update photo URL in Firestore
            await FirebaseFirestore.instance
                .collection("Projects")
                .doc(projectId)
                .update({
              "taskPhotos.$taskKey": url,
              "lastUpdated": FieldValue.serverTimestamp(),
            });

            // Calculate progress
            final projectDoc = await FirebaseFirestore.instance
                .collection("Projects")
                .doc(projectId)
                .get();

            if (projectDoc.exists) {
              final project = projectDoc.data() as Map<String, dynamic>;
              final taskPhotos =
                  project['taskPhotos'] as Map<String, dynamic>? ?? {};
              final totalTasks = 4; // Fixed number of tasks
              final completedPhotos =
                  taskPhotos.values.where((value) => value.isNotEmpty).length;
              final progress = ((completedPhotos / totalTasks) * 100).round();

              // Update project progress
              await FirebaseFirestore.instance
                  .collection("Projects")
                  .doc(projectId)
                  .update({
                "progress": progress,
                "status": progress >= 100 ? "pending" : "pending",
              });
            }
          },
        ));
  }

  Future<void> _saveTaskCompletion() async {
    final String comments = commentsController.text;
    final String satisfaction = satisfactionLevel.value;

    // Make sure satisfaction and comments are filled
    if (satisfaction.isEmpty || comments.isEmpty) {
      Get.snackbar(
        "Missing Information",
        "Please fill out both satisfaction level and comments",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.accentOrange.withOpacity(0.2),
        colorText: AppTheme.deepBlack,
      );
      return;
    }

    try {
      // Update project status, satisfaction, and comments in Firestore
      await FirebaseFirestore.instance
          .collection("Projects")
          .doc(projectId)
          .update({
        "satisfactionLevel": satisfaction,
        "comments": comments,
      });

      isCompleted.value = true; // Disable further editing after submission

      Get.snackbar(
        "Evaluation Submitted",
        "Your project evaluation has been saved successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
        colorText: AppTheme.deepBlack,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to submit evaluation: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.accentOrange.withOpacity(0.2),
        colorText: AppTheme.deepBlack,
      );
    }
  }

  // Helper methods for UI styling
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.primaryGreen;
      case 'approved':
        return AppTheme.buildingBlue;
      case 'doing':
        return AppTheme.accentOrange;
      case 'pending':
      default:
        return AppTheme.deepBlack.withOpacity(0.7);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'approved':
        return Icons.verified;
      case 'doing':
        return Icons.engineering;
      case 'pending':
      default:
        return Icons.hourglass_empty;
    }
  }
}

// ... (Rest of the classes like PhotoCaptureScreen, ProjectDetailsController, FullScreenImageViewer, and LocationUrlWidget remain unchanged)

// This screen will be needed for photo capture
class PhotoCaptureScreen extends StatefulWidget {
  final String projectId;
  final String taskName;
  final Function(String) onPhotoSubmitted;

  const PhotoCaptureScreen({
    super.key,
    required this.projectId,
    required this.taskName,
    required this.onPhotoSubmitted,
  });

  @override
  _PhotoCaptureScreenState createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  bool _isUploading = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      Get.snackbar("Error", "No camera available");
      return;
    }

    final camera = cameras.first;
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to initialize camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (!_cameraController.value.isInitialized) {
      Get.snackbar("Error", "Camera not initialized");
      return;
    }

    try {
      final image = await _cameraController.takePicture();
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to capture photo: $e");
    }
  }

  Future<void> _uploadPhoto() async {
    if (_capturedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a unique filename
      final fileName =
          '${widget.projectId}_${widget.taskName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref =
          FirebaseStorage.instance.ref().child('project_photos/$fileName');

      // Upload the file
      final file = File(_capturedImage!.path);
      final uploadTask = ref.putFile(file);

      // Get the download URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Call the callback with the URL
      widget.onPhotoSubmitted(downloadUrl);

      // Go back to previous screen
      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to upload photo: $e");
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Capture ${widget.taskName} Photo"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: _capturedImage == null
                ? _isCameraInitialized
                    ? CameraPreview(_cameraController)
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                : Image.file(
                    File(_capturedImage!.path),
                    fit: BoxFit.contain,
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: _capturedImage == null
                ? Center(
                    child: FloatingActionButton(
                      onPressed: _capturePhoto,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.camera_alt, color: Colors.black),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _capturedImage = null;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retake"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadPhoto,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: Text(_isUploading ? "Uploading..." : "Upload"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
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

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
  });

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareImage,
          ),
          // Download button
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download, color: Colors.white),
            onPressed: _isDownloading ? null : _downloadImage,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 3,
          child: Image.network(
            widget.imageUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.red[300], size: 50),
                    const SizedBox(height: 10),
                    const Text(
                      "Failed to load image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _shareImage() async {
    try {
      // Download image temporarily to share it
      final response = await http.get(Uri.parse(widget.imageUrl));
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/shared_image.jpg';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(response.bodyBytes);

      // Share the image file
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Project Image',
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to share image: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    }
  }

  Future<void> _downloadImage() async {
    // Request storage permission
    final status = await Permission.storage.request();

    if (status.isGranted) {
      setState(() {
        _isDownloading = true;
      });

      try {
        // Get the download directory
        final directory = Platform.isAndroid
            ? await getExternalStorageDirectory() // Android-specific
            : await getApplicationDocumentsDirectory(); // iOS-specific

        if (directory == null) {
          throw "Could not access storage directory";
        }

        // Create a unique filename
        final filename =
            'project_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savePath = '${directory.path}/$filename';

        // Download the file
        final response = await http.get(Uri.parse(widget.imageUrl));
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);

        Get.snackbar(
          "Success",
          "Image saved to: $savePath",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to download image: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
      } finally {
        setState(() {
          _isDownloading = false;
        });
      }
    } else {
      Get.snackbar(
        "Permission Denied",
        "Storage permission is required to download images",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
      );
    }
  }
}

// Now, let's modify the _buildTaskPhotoItem and _buildReadOnlyPhotoItem methods
// to open the full screen viewer when an image is tapped

Widget _buildTaskPhotoItem(String taskName, String photoUrl, String projectId,
    String taskKey, bool readOnly) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: photoUrl.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    Get.to(() => FullScreenImageViewer(imageUrl: photoUrl));
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.error, color: Colors.red[300]),
                        );
                      },
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.photo_camera,
                        color: Colors.grey[400], size: 40),
                  ),
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: [
              Text(
                taskName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (!readOnly && photoUrl.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ElevatedButton(
                    onPressed: () => _captureTaskPhoto(projectId, taskKey),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(30, 30),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      "Capture",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _captureTaskPhoto(String projectId, String taskKey) {
  // Navigate to photo capture screen
  Get.to(() => PhotoCaptureScreen(
        projectId: projectId,
        taskName: taskKey,
        onPhotoSubmitted: (url) async {
          // Update photo URL in Firestore
          await FirebaseFirestore.instance
              .collection("Projects")
              .doc(projectId)
              .update({
            "taskPhotos.$taskKey": url,
            "lastUpdated": FieldValue.serverTimestamp(),
          });

          // Calculate progress
          final projectDoc = await FirebaseFirestore.instance
              .collection("Projects")
              .doc(projectId)
              .get();

          if (projectDoc.exists) {
            final project = projectDoc.data() as Map<String, dynamic>;
            final taskPhotos =
                project['taskPhotos'] as Map<String, dynamic>? ?? {};
            final totalTasks = 4; // Fixed number of tasks
            final completedPhotos =
                taskPhotos.values.where((value) => value.isNotEmpty).length;
            final progress = ((completedPhotos / totalTasks) * 100).round();

            // Update project progress
            await FirebaseFirestore.instance
                .collection("Projects")
                .doc(projectId)
                .update({
              "progress": progress,
              "status": progress >= 100 ? "pending" : "pending",
            });
          }
        },
      ));
}

class LocationUrlWidget extends StatelessWidget {
  final String url;
  final String displayText;
  final Function(String) onLaunch;

  const LocationUrlWidget({
    super.key,
    required this.url,
    required this.displayText,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "Location Map:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.deepBlack,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                InkWell(
                  onTap: () => onLaunch(url),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.map, size: 16, color: AppTheme.buildingBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
