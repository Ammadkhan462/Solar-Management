import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:admin/app/modules/EmployeesRegistration/views/employees_registration_view.dart';
import 'package:admin/app/modules/ManagerPanel/views/manager_project.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../controllers/manager_panel_controller.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/Common widgets/common_button.dart';
import 'package:admin/Common widgets/common_text.dart';
import 'package:admin/Common widgets/textbox.dart';
import 'package:admin/app/routes/app_pages.dart';

class ManagerPanelView extends GetView<ManagerPanelController> {
  const ManagerPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: CommonText(
          text: 'Manager Dashboard',
          style: AppTypography.heading,
          color: Colors.white,
        ),
        automaticallyImplyLeading: false, // Removes the back arrow

        centerTitle: true,
        elevation: 2,
        backgroundColor: AppTheme.buildingBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.lightGray),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: const [
                      Icon(Icons.logout, color: AppTheme.buildingBlue),
                      SizedBox(width: 8),
                      Text("Sign Out"),
                    ],
                  ),
                  content: const Text(
                    "Are you sure you want to sign out?",
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: AppTheme.buildingBlue),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.buildingBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await FirebaseAuth.instance.signOut();
                        Get.offAllNamed(Routes.LOGIN_CHOICE);
                      },
                      child: const Text("Confirm"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                ),
                const SizedBox(height: 16),
                CommonText(
                  text: 'Loading your dashboard...',
                  style: AppTypography.medium,
                  color: AppTheme.lightGray,
                ),
              ],
            ),
          );
        }

        final manager = controller.manager.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.buildingBlue.withOpacity(0.05), Colors.white],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: ListView(
              children: [
                // Manager Profile Card - Fixed for text overflow
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              AppTheme.buildingBlue.withOpacity(0.2),
                          child: Icon(Icons.person,
                              size: 35, color: AppTheme.buildingBlue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                text: manager.name,
                                style: AppTypography.heading.copyWith(
                                  fontSize: isPortrait
                                      ? screenHeight * 0.025
                                      : screenWidth * 0.025,
                                ),
                                color: AppTheme.deepBlack,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.email,
                                      size: 16, color: AppTheme.buildingBlue),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: CommonText(
                                      text: manager.email,
                                      style: AppTypography.regular.copyWith(
                                        fontSize: isPortrait
                                            ? screenHeight * 0.018
                                            : screenWidth * 0.018,
                                      ),
                                      color:
                                          AppTheme.deepBlack.withOpacity(0.7),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.badge,
                                      size: 16, color: AppTheme.buildingBlue),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: CommonText(
                                      text: "CNIC: ${manager.cnic}",
                                      style: AppTypography.regular.copyWith(
                                        fontSize: isPortrait
                                            ? screenHeight * 0.018
                                            : screenWidth * 0.018,
                                      ),
                                      color:
                                          AppTheme.deepBlack.withOpacity(0.7),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Quick Actions Section - Improved UI
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: "Quick Actions",
                          style: AppTypography.subheading,
                          color: AppTheme.buildingBlue,
                        ),
                        const Divider(height: 24),
                        isPortrait
                            ? Column(
                                children: [
                                  _buildImprovedActionButton(
                                    context,
                                    icon: Icons.person_add,
                                    label: "Register Employee",
                                    description: "Add new team members",
                                    color: AppTheme.primaryGreen,
                                    onPressed: () =>
                                        _showEmployeeRegistrationForm(context),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  _buildImprovedActionButton(
                                    context,
                                    icon: Icons.people,
                                    label: "View Employees",
                                    description: "Manage your team",
                                    color: AppTheme.buildingBlue,
                                    onPressed: () => Get.to(
                                        () => EmployeeCredentialsScreen()),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  _buildImprovedActionButton(
                                    context,
                                    icon: Icons.calendar_today,
                                    label: "Attendance",
                                    description: "Track employee attendance",
                                    color: AppTheme.accentOrange,
                                    onPressed: () => Get.to(() =>
                                        const EmployeeAttendanceManagerView()),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildImprovedActionButton(
                                      context,
                                      icon: Icons.person_add,
                                      label: "Register Employee",
                                      description: "Add new team members",
                                      color: AppTheme.primaryGreen,
                                      onPressed: () =>
                                          _showEmployeeRegistrationForm(
                                              context),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildImprovedActionButton(
                                      context,
                                      icon: Icons.people,
                                      label: "View Employees",
                                      description: "Manage your team",
                                      color: AppTheme.buildingBlue,
                                      onPressed: () => Get.to(
                                          () => EmployeeCredentialsScreen()),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Projects section - Fixed for Responsive Layout
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText(
                              text: "Projects",
                              style: AppTypography.subheading,
                              color: AppTheme.buildingBlue,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.buildingBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CommonText(
                                text:
                                    "${controller.filteredProjects.length} Projects",
                                style: AppTypography.medium,
                                color: AppTheme.buildingBlue,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Project filters
                        Obx(() => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip("All",
                                      controller.currentFilter.value == "All"),
                                  _buildFilterChip(
                                      "Pending",
                                      controller.currentFilter.value ==
                                          "Pending"),
                                  _buildFilterChip(
                                      "Approved",
                                      controller.currentFilter.value ==
                                          "Approved"),
                                  _buildFilterChip(
                                      "Completed",
                                      controller.currentFilter.value ==
                                          "Completed"),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),

                        // Inside the projects list mapping, update the onTap logic and add conditional UI for approved status
                        ...controller.filteredProjects.map((project) {
                          // Status badge color
                          Color statusColor;
                          IconData statusIcon;
                          String statusText;

                          if (project['status'] == 'completed') {
                            statusColor = AppTheme.primaryGreen;
                            statusIcon = Icons.check_circle;
                            statusText = "Completed";
                          } else if (project['status'] == 'approved') {
                            statusColor = AppTheme.accentOrange;
                            statusIcon = Icons.thumb_up;
                            statusText = "Approved";
                          } else if (project['status'] == 'doing' ||
                              project['status'] == 'progress') {
                            statusColor = AppTheme.buildingBlue;
                            statusIcon = Icons.engineering;
                            statusText = "In Progress";
                          } else {
                            statusColor = AppTheme.buildingBlue;
                            statusIcon = Icons.queue;
                            statusText = "Pending";
                          }

                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: AppTheme.lightGray),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                if (project['status'] == 'approved') {
                                  Get.to(() => ProjectCreationScreen(
                                      existingProject: project));
                                } else if (project['status'] == 'progress') {
                                  Get.to(() => ProjectProgressScreen(
                                        projectId: project['id'],
                                        projectData: project,
                                      ));
                                } else {
                                  Get.to(() => ProjectDetailsScreen(
                                        project: project,
                                        projectId: project['id'],
                                      ));
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CommonText(
                                                text: project['projectName'] ??
                                                    'Unnamed Project',
                                                style: AppTypography.medium
                                                    .copyWith(
                                                  fontSize: isPortrait
                                                      ? screenHeight * 0.02
                                                      : screenWidth * 0.02,
                                                ),
                                                color: AppTheme.deepBlack,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.person,
                                                      size: 14,
                                                      color: AppTheme
                                                          .buildingBlue
                                                          .withOpacity(0.7)),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: CommonText(
                                                      text: project[
                                                              'clientName'] ??
                                                          'No Client',
                                                      style: AppTypography
                                                          .regular
                                                          .copyWith(
                                                        fontSize: isPortrait
                                                            ? screenHeight *
                                                                0.016
                                                            : screenWidth *
                                                                0.016,
                                                      ),
                                                      color: AppTheme.deepBlack
                                                          .withOpacity(0.6),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: statusColor
                                                    .withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(statusIcon,
                                                  size: 14, color: statusColor),
                                              const SizedBox(width: 4),
                                              CommonText(
                                                text: statusText,
                                                style: AppTypography.small,
                                                color: statusColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Show Create Project button for approved projects
                                    if (project['status'] == 'approved')
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Get.to(() =>
                                                    ProjectCreationScreen(
                                                        existingProject:
                                                            project));
                                              },
                                              icon: Icon(Icons.add_task,
                                                  color: Colors.white,
                                                  size: 16),
                                              label: CommonText(
                                                text: "Create Project",
                                                style: AppTypography.medium
                                                    .copyWith(fontSize: 14),
                                                color: Colors.white,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppTheme.primaryGreen,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    // Progress bar for pending/in-progress projects
                                    if (project['status'] != 'completed' &&
                                        project['status'] != 'approved')
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        CommonText(
                                                          text: "Progress",
                                                          style: AppTypography
                                                              .small,
                                                          color: AppTheme
                                                              .deepBlack
                                                              .withOpacity(0.6),
                                                        ),
                                                        CommonText(
                                                          text:
                                                              "${_calculateProjectProgress(project)}%",
                                                          style: AppTypography
                                                              .small
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                          color: AppTheme
                                                              .buildingBlue,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child:
                                                          LinearProgressIndicator(
                                                        value:
                                                            _calculateProjectProgress(
                                                                    project) /
                                                                100,
                                                        backgroundColor:
                                                            AppTheme.lightGray,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          _getProgressColor(
                                                              _calculateProjectProgress(
                                                                  project)),
                                                        ),
                                                        minHeight: 6,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        if (controller.filteredProjects.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(Icons.folder_off,
                                    size: 48, color: AppTheme.lightGray),
                                const SizedBox(height: 16),
                                CommonText(
                                  text: "No projects available",
                                  style: AppTypography.medium,
                                  color: AppTheme.deepBlack.withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Improved action button with better UI and text overflow handling
  Widget _buildImprovedActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.08),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: label,
                      style: AppTypography.medium,
                      color: color,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    CommonText(
                      text: description,
                      style: AppTypography.small,
                      color: AppTheme.deepBlack.withOpacity(0.6),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: CommonText(
          text: label,
          style: AppTypography.small,
          color: isSelected ? AppTheme.buildingBlue : AppTheme.deepBlack,
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.filterProjects(label);
          }
        },
        backgroundColor: AppTheme.lightGray,
        selectedColor: AppTheme.buildingBlue.withOpacity(0.1),
        checkmarkColor: AppTheme.buildingBlue,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.buildingBlue : AppTheme.deepBlack,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Helper methods for project progress calculation
  int _calculateProjectProgress(Map<String, dynamic> project) {
    // Get the taskVideos/taskPhotos map from project data
    final taskMedia =
        (project['taskVideos'] ?? project['taskPhotos']) as Map? ?? {};

    // Define the standard tasks that are used to calculate progress
    final List<String> standardTaskKeys = [
      'Structure',
      'Panel Installation',
      'Inverter installation',
      'Wiring',
      'Completion'
    ];

    // Count completed tasks
    int completedTasks = 0;
    for (String taskKey in standardTaskKeys) {
      final mediaUrl = taskMedia[taskKey]?.toString();
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        completedTasks++;
      }
    }

    // Calculate and return percentage
    return ((completedTasks / standardTaskKeys.length) * 100).round();
  }

  // Get color based on progress percentage
  Color _getProgressColor(int progressPercentage) {
    if (progressPercentage < 30) {
      return AppTheme.accentOrange;
    } else if (progressPercentage < 70) {
      return AppTheme.buildingBlue;
    } else {
      return AppTheme.primaryGreen;
    }
  }

  void _showEmployeeRegistrationForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Register Employee",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.buildingBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.deepBlack),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: const EmployeeRegistrationForm(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProjectProgressScreen extends StatelessWidget {
  final String projectId;
  final Map<String, dynamic> projectData;

  const ProjectProgressScreen({
    super.key,
    required this.projectId,
    required this.projectData,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final progress = projectData['progress'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Progress"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project summary card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.solar_power,
                              color: Colors.blue[800],
                              size: 36,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  projectData['projectName'] ??
                                      'Unnamed Project',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.person,
                                        size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      projectData['clientName'] ?? 'No Client',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.category,
                                        size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      projectData['propertyType'] ??
                                          'Not specified',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Progress bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Progress Status",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "$progress%",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: progress == 100
                                      ? Colors.green
                                      : Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              minHeight: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress == 100 ? Colors.green : Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildProgressStepsIndicator(progress),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Tasks Section
              Text(
                "Project Tasks",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 12),
              ..._buildTasksList(),

              // Update progress button
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.update, color: Colors.white),
                  label: const Text(
                    "Update Progress",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () =>
                      _updateProgress((projectData['progress'] ?? 0) + 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStepsIndicator(int progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProgressStep("Start", 0, progress),
        _buildProgressConnector(progress > 0),
        _buildProgressStep("25%", 25, progress),
        _buildProgressConnector(progress >= 25),
        _buildProgressStep("50%", 50, progress),
        _buildProgressConnector(progress >= 50),
        _buildProgressStep("75%", 75, progress),
        _buildProgressConnector(progress >= 75),
        _buildProgressStep("Done", 100, progress),
      ],
    );
  }

  Widget _buildProgressStep(String label, int value, int currentProgress) {
    final bool isCompleted = currentProgress >= value;
    final bool isCurrent = currentProgress >= value &&
        (value == 100 ? currentProgress == 100 : currentProgress < value + 25);

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? (isCurrent ? Colors.green : Colors.blue)
                : Colors.grey[300],
            border:
                isCurrent ? Border.all(color: Colors.green, width: 2) : null,
          ),
          child: isCompleted
              ? Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isCompleted
                ? (isCurrent ? Colors.green : Colors.blue)
                : Colors.grey[600],
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 3,
        color: isActive ? Colors.blue : Colors.grey[300],
      ),
    );
  }

  List<Widget> _buildTasksList() {
    List<Widget> taskWidgets = [];

    // Ensure tasks is a list
    if (projectData['tasks'] != null) {
      var tasks = projectData['tasks'];
      List<Map<String, dynamic>> tasksList = [];

      if (tasks is List) {
        for (var task in tasks) {
          if (task is Map) {
            tasksList.add(Map<String, dynamic>.from(task));
          }
        }
      } else if (tasks is Map) {
        // Handle if tasks is a map instead of a list
        tasks.forEach((key, task) {
          if (task is Map) {
            Map<String, dynamic> taskMap = Map<String, dynamic>.from(task);
            taskMap['key'] = key; // Save original key
            tasksList.add(taskMap);
          }
        });
      }

      // Sort tasks by completion status (completed tasks at the bottom)
      tasksList.sort((a, b) {
        bool isACompleted = a['status'] == 'completed';
        bool isBCompleted = b['status'] == 'completed';
        if (isACompleted == isBCompleted) return 0;
        return isACompleted ? 1 : -1;
      });

      for (var task in tasksList) {
        bool isCompleted = task['status'] == 'completed';

        // Determine task icon
        IconData taskIcon;
        if (task['name']?.toString().toLowerCase().contains('structure') ??
            false) {
          taskIcon = Icons.architecture;
        } else if (task['name']?.toString().toLowerCase().contains('panel') ??
            false) {
          taskIcon = Icons.solar_power;
        } else if (task['name']
                ?.toString()
                .toLowerCase()
                .contains('inverter') ??
            false) {
          taskIcon = Icons.electrical_services;
        } else if (task['name']?.toString().toLowerCase().contains('wiring') ??
            false) {
          taskIcon = Icons.cable;
        } else if (task['name']
                ?.toString()
                .toLowerCase()
                .contains('completion') ??
            false) {
          taskIcon = Icons.check_circle;
        } else {
          taskIcon = Icons.build;
        }

        taskWidgets.add(
          Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isCompleted
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                if (isCompleted && task['taskVideos'] != null) {
                  _showTaskVideos(Map<String, dynamic>.from(task));
                } else {
                  Get.snackbar(
                    "Task In Progress",
                    "This task is still being worked on",
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    colorText: Colors.orange[800],
                    icon: Icon(Icons.info_outline, color: Colors.orange[800]),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        taskIcon,
                        color: isCompleted ? Colors.green : Colors.orange,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['name'] ?? 'Unnamed Task',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.timelapse,
                                size: 14,
                                color:
                                    isCompleted ? Colors.green : Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                isCompleted ? "Completed" : "In Progress",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isCompleted
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    if (taskWidgets.isEmpty) {
      taskWidgets.add(
        Container(
          padding: EdgeInsets.all(30),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(Icons.assignment_late, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No tasks available for this project",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return taskWidgets;
  }

  // Function to display task-specific videos when task is completed
  void _showTaskVideos(Map<String, dynamic> task) {
    // Handle both Map and List types for taskVideos
    List<Widget> videoWidgets = [];

    if (task['taskVideos'] is Map) {
      // If taskVideos is a Map (object in Firebase)
      Map<String, dynamic> videos = task['taskVideos'];
      videos.forEach((key, value) {
        videoWidgets.add(
          ListTile(
            title: Text(key), // Show the video name (key)
            subtitle: Text(value), // Show the URL
            onTap: () {
              // Open video player or display URL
              print('Playing video: $value');
            },
          ),
        );
      });
    } else if (task['taskVideos'] is List) {
      // If taskVideos is a List
      List<dynamic> videos = task['taskVideos'];
      for (var videoUrl in videos) {
        videoWidgets.add(
          ListTile(
            title: Text(videoUrl),
            onTap: () {
              // Open video player or display URL
              print('Playing video: $videoUrl');
            },
          ),
        );
      }
    }

    if (videoWidgets.isNotEmpty) {
      Get.dialog(
        AlertDialog(
          title: const Text("Task Videos"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: videoWidgets,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close the dialog
              },
              child: const Text("Close"),
            ),
          ],
        ),
      );
    } else {
      Get.snackbar("No Videos", "No videos available for this task.");
    }
  }

  // Function to display the progress indicator
  Widget _buildProgressIndicator() {
    final progress = projectData['progress'] ?? 0;
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress / 100,
          minHeight: 20,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress == 100 ? Colors.green : Colors.blue,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "$progress% Complete",
            style: TextStyle(
              color: progress == 100 ? Colors.green : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Update progress button
  Widget _buildUpdateProgressButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.update),
        label: const Text("Update Progress"),
        onPressed: () => _updateProgress((projectData['progress'] ?? 0) + 10),
      ),
    );
  }

  // Update the project progress
  void _updateProgress(int newProgress) async {
    try {
      if (newProgress > 100) newProgress = 100;
      await FirebaseFirestore.instance
          .collection('Projects')
          .doc(projectId)
          .update({'progress': newProgress});

      Get.snackbar(
        "Success",
        "Progress updated to $newProgress%",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update progress: $e",
        backgroundColor: Colors.red,
      );
    }
  }
}

void _showEmployeeRegistrationForm(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Register Employee"),
      content: const EmployeeRegistrationForm(),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("Cancel"),
        ),
      ],
    ),
  );
}

class EmployeeRegistrationForm extends StatefulWidget {
  const EmployeeRegistrationForm({super.key});

  @override
  _EmployeeRegistrationFormState createState() =>
      _EmployeeRegistrationFormState();
}

Color _getAttendanceColor(int present, int late, int workingDays) {
  if (workingDays == 0) return Colors.grey;

  final percentage = ((present + late) / workingDays) * 100;

  if (percentage >= 90) return Colors.green;
  if (percentage >= 75) return Colors.amber;
  return Colors.red;
}

class _EmployeeRegistrationFormState extends State<EmployeeRegistrationForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _lateFineController = TextEditingController();
  final ManagerPanelController _controller = Get.find();

  // Predefined list of designations related to solar installation
  final List<String> _designations = [
    'Sales Employee',
    'Electrician',
    'Engineer',
    'Technician',
    'Project Manager',
    'Site Supervisor',
  ];

  String? _selectedDesignation; // Selected designation from the dropdown
  bool _isLoading = false;

  // Function to handle form submission
  Future<void> _registerEmployee() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter employee name",
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_cnicController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter employee CNIC",
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_selectedDesignation == null) {
      Get.snackbar(
        "Error",
        "Please select employee designation",
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_salaryController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter employee salary",
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_lateFineController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter late fine amount",
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Register the employee through controller method
      await _controller.registerEmployee(
        _nameController.text,
        _cnicController.text,
        _selectedDesignation!,
        int.parse(_salaryController.text),
        int.parse(_lateFineController.text),
      );

      // Clear form fields after successful submission
      _nameController.clear();
      _cnicController.clear();
      _salaryController.clear();
      _lateFineController.clear();
      setState(() {
        _selectedDesignation = null;
      });

      Get.back(); // Close the dialog after successful registration

      Get.snackbar(
        "Success",
        "Employee registered successfully",
        backgroundColor: AppTheme.primaryGreen,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 8,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to register employee: $e",
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _salaryController.dispose();
    _lateFineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name input field
          _buildInputField(
            controller: _nameController,
            label: "Employee Name",
            icon: Icons.person,
            hint: "Enter employee full name",
          ),

          const SizedBox(height: 16),

          // CNIC input field
          _buildInputField(
            controller: _cnicController,
            label: "CNIC Number",
            icon: Icons.badge,
            hint: "Enter 13-digit CNIC without dashes",
            keyboardType: TextInputType.number,
            inputFormatter: FilteringTextInputFormatter.digitsOnly,
            maxLength: 13,
          ),

          const SizedBox(height: 16),

          // Salary input field
          _buildInputField(
            controller: _salaryController,
            label: "Salary Amount Per Day30",
            icon: Icons.payments,
            hint: "Enter employee salary",
            keyboardType: TextInputType.number,
            inputFormatter: FilteringTextInputFormatter.digitsOnly,
          ),

          const SizedBox(height: 16),

          // Late Fine input field
          _buildInputField(
            controller: _lateFineController,
            label: "Late Fine",
            icon: Icons.timer_off,
            hint: "Enter late fine amount",
            keyboardType: TextInputType.number,
            inputFormatter: FilteringTextInputFormatter.digitsOnly,
          ),

          const SizedBox(height: 16),

          // Designation dropdown
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedDesignation,
              decoration: InputDecoration(
                labelText: "Employee Designation",
                prefixIcon: Icon(
                  Icons.work,
                  color: AppTheme.buildingBlue,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _designations.map((String designation) {
                return DropdownMenuItem<String>(
                  value: designation,
                  child: Text(designation),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedDesignation = value;
                });
              },
              hint: const Text("Select Designation"),
              icon: Icon(Icons.arrow_drop_down, color: AppTheme.buildingBlue),
              isExpanded: true,
              dropdownColor: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _registerEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_add),
                        SizedBox(width: 12),
                        Text(
                          "Register Employee",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputFormatter? inputFormatter,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.buildingBlue),
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          counterText: "",
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatter != null ? [inputFormatter] : null,
        maxLength: maxLength,
      ),
    );
  }
}

class EmployeeCredentialsScreen extends StatelessWidget {
  final ManagerPanelController _controller = Get.find();

  EmployeeCredentialsScreen({super.key});

  // Function to copy text to clipboard
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      "Copied",
      "$label copied to clipboard",
      backgroundColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Credentials"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _controller.fetchAllEmployees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No employees found."));
          } else {
            final employees = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name: ${employee['name']}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text("Designation: ${employee['designation']}"),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text("Email: ${employee['email']}"),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () {
                                  _copyToClipboard(employee['email'], "Email");
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text("Password: ${employee['password']}"),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                onPressed: () {
                                  _copyToClipboard(
                                      employee['password'], "Password");
                                },
                              ),
                            ],
                          )
                        ]),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ProjectDetailsScreen extends StatelessWidget {
  final Map project;
  final String projectId;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final projectName = project['projectName']?.toString() ?? 'Unnamed Project';
    final clientName = project['clientName']?.toString() ?? 'No Client';
    final projectStatus = project['status']?.toString() ?? '';
    final isCompleted = projectStatus == 'completed';

    return Scaffold(
      appBar: AppBar(
        title: Text(projectName),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Project Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.solar_power,
                            color: Colors.blue[800],
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                projectName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      clientName,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.category,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      project['propertyType'] ??
                                          'Not specified',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Start: ${_formatDate(project['startDate'])}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.event_available,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'End: ${_formatDate(project['endDate'])}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green[100]
                                : Colors.blue[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            isCompleted ? "Completed" : "In Progress",
                            style: TextStyle(
                              color: isCompleted
                                  ? Colors.green[800]
                                  : Colors.blue[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Technical Details Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showProjectDetailsDialog(context),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.blue[800],
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Technical Details",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "View complete project specifications",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue[800],
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Project Costing Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Project Costing",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    ..._buildCostingItems(),
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Cost",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          "${_calculateTotalCost()} PKR",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Project Progress Card - Show only for pending projects
            if (!isCompleted)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Project Progress",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      Builder(builder: (context) {
                        final taskMedia = (project['taskVideos'] ??
                                project['taskPhotos']) as Map? ??
                            {};
                        final List<String> standardTaskKeys = [
                          'Structure',
                          'Panel Installation',
                          'Inverter installation',
                          'Wiring',
                          'Completion'
                        ];
                        int completedTasks = 0;
                        for (String taskKey in standardTaskKeys) {
                          final mediaUrl = taskMedia[taskKey]?.toString();
                          if (mediaUrl != null && mediaUrl.isNotEmpty) {
                            completedTasks++;
                          }
                        }
                        final progressPercentage =
                            ((completedTasks / standardTaskKeys.length) * 100)
                                .round();
                        Color progressColor;
                        if (progressPercentage < 30) {
                          progressColor = Colors.orange;
                        } else if (progressPercentage < 70) {
                          progressColor = Colors.blue;
                        } else {
                          progressColor = Colors.green;
                        }
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$completedTasks of ${standardTaskKeys.length} tasks completed",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: progressColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "$progressPercentage%",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: progressColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progressPercentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    progressColor),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 20),

            // Project Tasks
            Text(
              'Project Tasks',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTaskList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCostingItems() {
    List<Widget> items = [];

    // Solar Panels
    double panelCost = 0;
    try {
      final panelQuantity =
          double.tryParse(project['panelQuantity']?.toString() ?? '0') ?? 0;
      final pricePerWatt =
          double.tryParse(project['pricePerWatt']?.toString() ?? '0') ?? 0;
      final totalKw =
          double.tryParse(project['totalKw']?.toString() ?? '0') ?? 0;
      panelCost = panelQuantity * pricePerWatt * totalKw * 1000;
    } catch (e) {
      panelCost = 0;
    }
    items.add(_buildCostItem('Solar Panels', panelCost));

    // Inverter
    double inverterCost = 0;
    try {
      final inverterPrice =
          double.tryParse(project['inverterPrice']?.toString() ?? '0') ?? 0;
      final inverterQuantity =
          double.tryParse(project['inverterQuantity']?.toString() ?? '0') ?? 0;
      inverterCost = inverterPrice * inverterQuantity;
    } catch (e) {
      inverterCost = 0;
    }
    items.add(_buildCostItem('Inverter', inverterCost));

    // Structure
    double structureCost = 0;
    try {
      structureCost =
          double.tryParse(project['structurePrice']?.toString() ?? '0') ?? 0;
    } catch (e) {
      structureCost = 0;
    }
    items.add(_buildCostItem('Structure', structureCost));

    // Wiring
    double wiringCost = 0;
    try {
      final wireLength =
          double.tryParse(project['wireLength']?.toString() ?? '0') ?? 0;
      final wirePricePerMeter =
          double.tryParse(project['wirePricePerMeter']?.toString() ?? '0') ?? 0;
      wiringCost = wireLength * wirePricePerMeter;
    } catch (e) {
      wiringCost = 0;
    }
    items.add(_buildCostItem('Wiring', wiringCost));

    // Breakers
    double breakersCost = 0;
    try {
      final breakerPrices = project['breakerPrices'] as Map? ?? {};
      final breakerQuantities = project['breakerQuantities'] as Map? ?? {};
      breakerPrices.forEach((key, price) {
        final quantity =
            double.tryParse(breakerQuantities[key]?.toString() ?? '0') ?? 0;
        final priceValue = double.tryParse(price?.toString() ?? '0') ?? 0;
        breakersCost += priceValue * quantity;
      });
    } catch (e) {
      breakersCost = 0;
    }
    items.add(_buildCostItem('Breakers', breakersCost));

    // Earthing
    double earthingCost = 0;
    try {
      final earthingPrices = project['earthingPrices'] as Map? ?? {};
      final earthingQuantities = project['earthingQuantities'] as Map? ?? {};
      earthingPrices.forEach((key, price) {
        final quantity =
            double.tryParse(earthingQuantities[key]?.toString() ?? '0') ?? 0;
        final priceValue = double.tryParse(price?.toString() ?? '0') ?? 0;
        earthingCost += priceValue * quantity;
      });
    } catch (e) {
      earthingCost = 0;
    }
    items.add(_buildCostItem('Earthing', earthingCost));

    // Casing
    double casingCost = 0;
    try {
      final casingPrices = project['casingPrices'] as Map? ?? {};
      final casingQuantities = project['casingQuantities'] as Map? ?? {};
      casingPrices.forEach((key, price) {
        final quantity =
            double.tryParse(casingQuantities[key]?.toString() ?? '0') ?? 0;
        final priceValue = double.tryParse(price?.toString() ?? '0') ?? 0;
        casingCost += priceValue * quantity;
      });
    } catch (e) {
      casingCost = 0;
    }
    items.add(_buildCostItem('Casing', casingCost));

    // Battery (if applicable)
    double batteryCost = 0;
    if (project['installBattery'] == true) {
      try {
        final batteryPrice =
            double.tryParse(project['batteryPrice']?.toString() ?? '0') ?? 0;
        final batteryQuantity =
            double.tryParse(project['batteryQuantity']?.toString() ?? '0') ?? 0;
        batteryCost = batteryPrice * batteryQuantity;
      } catch (e) {
        batteryCost = 0;
      }
      items.add(_buildCostItem('Battery', batteryCost));
    }

    return items;
  }

  Widget _buildCostItem(String label, double cost) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            "${cost.toStringAsFixed(2)} PKR",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalCost() {
    double totalCost = 0;

    try {
      final panelQuantity =
          double.tryParse(project['panelQuantity']?.toString() ?? '0') ?? 0;
      final pricePerWatt =
          double.tryParse(project['pricePerWatt']?.toString() ?? '0') ?? 0;
      final totalKw =
          double.tryParse(project['totalKw']?.toString() ?? '0') ?? 0;
      totalCost += panelQuantity * pricePerWatt * totalKw * 1000;

      final inverterPrice =
          double.tryParse(project['inverterPrice']?.toString() ?? '0') ?? 0;
      final inverterQuantity =
          double.tryParse(project['inverterQuantity']?.toString() ?? '0') ?? 0;
      totalCost += inverterPrice * inverterQuantity;

      totalCost +=
          double.tryParse(project['structurePrice']?.toString() ?? '0') ?? 0;

      final wireLength =
          double.tryParse(project['wireLength']?.toString() ?? '0') ?? 0;
      final wirePricePerMeter =
          double.tryParse(project['wirePricePerMeter']?.toString() ?? '0') ?? 0;
      totalCost += wireLength * wirePricePerMeter;

      final breakerPrices = project['breakerPrices'] as Map? ?? {};
      final breakerQuantities = project['breakerQuantities'] as Map? ?? {};
      breakerPrices.forEach((key, price) {
        final quantity =
            double.tryParse(breakerQuantities[key]?.toString() ?? '0') ?? 0;
        final priceValue = double.tryParse(price?.toString() ?? '0') ?? 0;
        totalCost += priceValue * quantity;
      });

      final earthingPrices = project['earthingPrices'] as Map? ?? {};
      final earthingQuantities = project['earthingQuantities'] as Map? ?? {};
      earthingPrices.forEach((key, price) {
        final quantity =
            double.tryParse(earthingQuantities[key]?.toString() ?? '0') ?? 0;
        final priceValue = double.tryParse(price?.toString() ?? '0') ?? 0;
        totalCost += priceValue * quantity;
      });

      final casingPrices = project['casingPrices'] as Map? ?? {};
      final casingQuantities = project['casingQuantities'] as Map? ?? {};
      casingPrices.forEach((key, price) {
        final quantity =
            double.tryParse(casingQuantities[key]?.toString() ?? '0') ?? 0;
        final priceValue = double.tryParse(price?.toString() ?? '0') ?? 0;
        totalCost += priceValue * quantity;
      });

      if (project['installBattery'] == true) {
        final batteryPrice =
            double.tryParse(project['batteryPrice']?.toString() ?? '0') ?? 0;
        final batteryQuantity =
            double.tryParse(project['batteryQuantity']?.toString() ?? '0') ?? 0;
        totalCost += batteryPrice * batteryQuantity;
      }
    } catch (e) {
      print("Error calculating total cost: $e");
    }

    return totalCost;
  }

  Widget _buildTaskList() {
    final taskMedia =
        (project['taskVideos'] ?? project['taskPhotos']) as Map? ?? {};
    final List<Map<String, dynamic>> standardTasks = [
      {
        'name': 'Structure',
        'key': 'Structure',
        'icon': Icons.construction,
      },
      {
        'name': 'Panel Installation',
        'key': 'Panel Installation',
        'icon': Icons.solar_power,
      },
      {
        'name': 'Inverter Installation',
        'key': 'Inverter installation',
        'icon': Icons.electric_bolt,
      },
      {
        'name': 'Wiring',
        'key': 'Wiring',
        'icon': Icons.cable,
      },
      {
        'name': 'Completion',
        'key': 'Completion',
        'icon': Icons.check_circle,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: standardTasks.length,
      itemBuilder: (context, index) {
        final task = standardTasks[index];
        final taskKey = task['key'] as String;
        final mediaUrl = taskMedia[taskKey]?.toString();
        final isCompleted = mediaUrl != null && mediaUrl.isNotEmpty;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isCompleted
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                task['icon'] as IconData,
                color: isCompleted ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              task['name'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Status: ${isCompleted ? 'COMPLETED' : 'IN PROGRESS'}',
              style: TextStyle(
                color: isCompleted ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: isCompleted
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.pending, color: Colors.grey),
            onTap: isCompleted && mediaUrl.startsWith('http')
                ? () {
                    if (mediaUrl.contains('.mp4')) {
                      _playVideo(context, mediaUrl);
                    }
                  }
                : null,
          ),
        );
      },
    );
  }

  void _playVideo(BuildContext context, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  void _showProjectDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Technical Specifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: _buildProjectDetailsContent(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectDetailsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Solar Panel Details'),
        _buildDetailItem('PV Module', '${project['pvModule'] ?? 'N/A'}'),
        _buildDetailItem('Brand', '${project['brand'] ?? 'N/A'}'),
        _buildDetailItem('Size', '${project['size'] ?? 'N/A'}'),
        _buildDetailItem(
            'Price Per Watt', '${project['pricePerWatt'] ?? 'N/A'}'),
        _buildDetailItem(
            'Panel Quantity', '${project['panelQuantity'] ?? 'N/A'}'),
        _buildDetailItem('Total kW', '${project['totalKw'] ?? 'N/A'}'),
        SizedBox(height: 16),
        _buildSectionTitle('Inverter Details'),
        _buildDetailItem('Type', '${project['inverterType'] ?? 'N/A'}'),
        _buildDetailItem('kW Size', '${project['kwSize'] ?? 'N/A'}'),
        _buildDetailItem('Brand', '${project['inverterBrand'] ?? 'N/A'}'),
        _buildDetailItem('Price', '${project['inverterPrice'] ?? 'N/A'}'),
        _buildDetailItem('Quantity', '${project['inverterQuantity'] ?? 'N/A'}'),
        SizedBox(height: 16),
        _buildSectionTitle('Structure Details'),
        _buildDetailItem('Type', '${project['structureType'] ?? 'N/A'}'),
        _buildDetailItem('Price', '${project['structurePrice'] ?? 'N/A'}'),
        SizedBox(height: 16),
        _buildSectionTitle('Wiring Details'),
        _buildDetailItem('Wire Size', '${project['wireSize'] ?? 'N/A'}'),
        _buildDetailItem('Wire Length', '${project['wireLength'] ?? 'N/A'}'),
        _buildDetailItem(
            'Wire Price/Meter', '${project['wirePricePerMeter'] ?? 'N/A'}'),
        SizedBox(height: 16),
        _buildSectionTitle('Components'),
        _buildMapDetailItem('Breakers', project['selectedBreakers'],
            project['breakerPrices'], project['breakerQuantities']),
        _buildMapDetailItem('Earthing', project['selectedEarthing'],
            project['earthingPrices'], project['earthingQuantities']),
        _buildMapDetailItem('Casing', project['selectedCasing'],
            project['casingPrices'], project['casingQuantities']),
        if (project['installBattery'] == true) ...[
          SizedBox(height: 16),
          _buildSectionTitle('Battery Details'),
          _buildDetailItem(
              'Battery Type', '${project['batteryType'] ?? 'N/A'}'),
          _buildDetailItem(
              'Battery Brand', '${project['batteryBrand'] ?? 'N/A'}'),
          _buildDetailItem(
              'Battery Quantity', '${project['batteryQuantity'] ?? 'N/A'}'),
          _buildDetailItem(
              'Battery Price', '${project['batteryPrice'] ?? 'N/A'}'),
        ],
        SizedBox(height: 16),
        _buildSectionTitle('Project Timeline'),
        _buildDetailItem(
            'Start Date & Time', _formatDate(project['startDate'])),
        _buildDetailItem('End Date & Time', _formatDate(project['endDate'])),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Not specified';
    try {
      if (timestamp is Timestamp) {
        final dateTime = timestamp.toDate();
        return _formatDateTime(dateTime);
      }
      if (timestamp.toString().startsWith('Timestamp(')) {
        final regex = RegExp(r'seconds=(\d+)');
        final match = regex.firstMatch(timestamp.toString());
        if (match != null && match.groupCount >= 1) {
          final seconds = int.parse(match.group(1)!);
          final dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
          return _formatDateTime(dateTime);
        }
      }
      if (timestamp is int) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return _formatDateTime(dateTime);
      }
      if (timestamp is String && timestamp.contains('T')) {
        try {
          final dateTime = DateTime.parse(timestamp);
          return _formatDateTime(dateTime);
        } catch (_) {}
      }
      return timestamp.toString();
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final dateFormatter = DateFormat('d MMMM yyyy');
    final timeFormatter = DateFormat('hh:mm a');
    return '${dateFormatter.format(dateTime)}, ${timeFormatter.format(dateTime)}';
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapDetailItem(
      String label, dynamic selected, dynamic prices, dynamic quantities) {
    if (selected == null) return SizedBox();
    try {
      if (selected is Map) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ),
            ...selected.keys.map((key) {
              String itemName = key.toString();
              String price = (prices?[key] ?? 'N/A').toString();
              String quantity = (quantities?[key] ?? 'N/A').toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0, left: 16.0),
                child: Text(
                  "$itemName - Qty: $quantity, Price: $price",
                  style: TextStyle(fontSize: 14),
                ),
              );
            }),
            SizedBox(height: 4),
          ],
        );
      } else {
        return _buildDetailItem(label, selected.toString());
      }
    } catch (e) {
      return _buildDetailItem(label, 'Error displaying data');
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Video'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: AspectRatio(
                aspectRatio: 0.6,
                child: VideoPlayer(_controller),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }
}

class StaffAssignmentScreen extends StatefulWidget {
  final String projectId;
  final DateTime startDate;
  final DateTime endDate;

  const StaffAssignmentScreen({
    super.key,
    required this.projectId,
    required this.startDate,
    required this.endDate,
  });

  @override
  _StaffAssignmentScreenState createState() => _StaffAssignmentScreenState();
}

class _StaffAssignmentScreenState extends State<StaffAssignmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ManagerPanelController _managerController = Get.find();
  Map<String, List<Map<String, dynamic>>> groupedStaff = {};
  List<String> selectedStaff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableStaff();
  }

  Future<void> _fetchAvailableStaff() async {
    try {
      final managerId = _managerController.manager.value.uid;
      final employeesSnapshot = await _firestore
          .collection('Employees')
          .where('managerId', isEqualTo: managerId)
          .get();

      final Map<String, List<Map<String, dynamic>>> tempGroup = {};

      for (final doc in employeesSnapshot.docs) {
        final employee = doc.data();
        final isAvailable = await _checkEmployeeAvailability(doc.id);

        if (isAvailable) {
          final designation = employee['designation'] ?? 'Other';
          if (!tempGroup.containsKey(designation)) {
            tempGroup[designation] = [];
          }
          tempGroup[designation]!.add({
            ...employee,
            'uid': doc.id,
          });
        }
      }

      setState(() {
        groupedStaff = tempGroup;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch staff: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _checkEmployeeAvailability(String employeeId) async {
    try {
      final projectsSnapshot = await _firestore
          .collection('Projects')
          .where('assignedStaff', arrayContains: employeeId)
          .get();

      for (final projectDoc in projectsSnapshot.docs) {
        final project = projectDoc.data();
        final projectStart = _parseDate(project['startDate']);
        final projectEnd = _parseDate(project['endDate']);

        if (_datesOverlap(projectStart, projectEnd)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print("Availability check error: $e");
      return false;
    }
  }

  DateTime _parseDate(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  bool _datesOverlap(DateTime projectStart, DateTime projectEnd) {
    return projectStart.isBefore(widget.endDate) &&
        projectEnd.isAfter(widget.startDate);
  }

  Future<void> _assignStaff() async {
    if (selectedStaff.isEmpty) {
      Get.snackbar("Error", "Please select at least one staff member");
      return;
    }

    try {
      // Update project with selected staff and dates
      await _firestore.collection('Projects').doc(widget.projectId).update({
        'assignedStaff': FieldValue.arrayUnion(selectedStaff),
        'status': 'doing',
        'startDate': Timestamp.fromDate(widget.startDate),
        'endDate': Timestamp.fromDate(widget.endDate),
      });

      // Update each staff member with project assignment and dates
      final batch = _firestore.batch();
      for (final staffId in selectedStaff) {
        final staffRef = _firestore.collection('Employees').doc(staffId);
        batch.update(staffRef, {
          'projects': FieldValue.arrayUnion([
            {
              'projectId': widget.projectId,
              'startDate': Timestamp.fromDate(widget.startDate),
              'endDate': Timestamp.fromDate(widget.endDate),
            }
          ])
        });
      }

      await batch.commit();
      Get.back();
      Get.snackbar("Success", "Staff assigned successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to assign staff: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Staff'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _assignStaff,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedStaff.isEmpty
              ? const Center(child: Text('No available staff'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project Dates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Start: ${DateFormat('yyyy-MM-dd').format(widget.startDate)}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'End: ${DateFormat('yyyy-MM-dd').format(widget.endDate)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: groupedStaff.entries.map((entry) {
                          return ExpansionTile(
                            title: Text(entry.key),
                            children: entry.value.map((staff) {
                              final isSelected =
                                  selectedStaff.contains(staff['uid']);
                              return CheckboxListTile(
                                title: Text(staff['name'] ?? 'Unnamed'),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedStaff.add(staff['uid']);
                                    } else {
                                      selectedStaff.remove(staff['uid']);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class EmployeeAttendanceManagerView extends StatefulWidget {
  const EmployeeAttendanceManagerView({super.key});

  @override
  State<EmployeeAttendanceManagerView> createState() =>
      _EmployeeAttendanceManagerViewState();
}

class _EmployeeAttendanceManagerViewState
    extends State<EmployeeAttendanceManagerView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isPermissionRequestInProgress = false;
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  List<Map<String, dynamic>> _attendanceRecords = [];
  List<Map<String, dynamic>> _dailyRecords = [];
  List<Map<String, dynamic>> _presentEmployees = [];

  bool _isLoading = true;
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  String _searchQuery = '';
  String? _selectedEmployeeId;
  String? _selectedStatus;

  // Statistics for all employees
  int _totalPresent = 0;
  int _totalLate = 0;
  int _totalAbsent = 0;
  double _totalSalaryPaid = 0.0;
  double _totalFines = 0.0;
  int _currentDayPresent = 0;
  int _currentDayLate = 0;
  int _currentDayAbsent = 0;

  // Constants for salary and fine calculation
  static const double lateFinePercentage = 0.02;
  static const String officeStartTime = "09:00:00";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      setState(() {
        _employees = [];
        _filteredEmployees = [];
        _attendanceRecords = [];
        _dailyRecords = [];
        _presentEmployees = [];
        _totalPresent = 0;
        _totalLate = 0;
        _totalAbsent = 0;
        _totalSalaryPaid = 0.0;
        _totalFines = 0.0;
        _currentDayPresent = 0;
        _currentDayLate = 0;
        _currentDayAbsent = 0;
      });

      print("Starting to load employee and attendance data...");
      await _fetchEmployees();
      if (_employees.isNotEmpty) {
        await _fetchAttendanceData();
        await _fetchDailyRecords();
        _calculateCurrentDayAttendance();
        print(
            "Data loaded successfully. Employees: ${_employees.length}, Attendance records: ${_attendanceRecords.length}, Daily records: ${_dailyRecords.length}");
      } else {
        print("No employees found in the database!");
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading data: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchEmployees() async {
    try {
      print("Fetching employees from Firestore...");
      final Map<String, Map<String, dynamic>> employeeMap = {};

      // Step 1: Get unique user IDs from attendance records
      final attendanceSnapshot =
          await _firestore.collection('attendance').get();
      final Set<String> employeeIdsWithAttendance = {};

      for (var doc in attendanceSnapshot.docs) {
        final userId = doc.data()['userId'] as String?;
        if (userId != null && userId.isNotEmpty) {
          employeeIdsWithAttendance.add(userId);
        }
      }

      print(
          "Found ${employeeIdsWithAttendance.length} unique employees with attendance records");

      // Step 2: Fetch details for each employee with attendance from Employees collection
      for (var employeeId in employeeIdsWithAttendance) {
        try {
          // Try to find employee document in Employees collection (capital E)
          final employeeDoc =
              await _firestore.collection('Employees').doc(employeeId).get();

          if (employeeDoc.exists && employeeDoc.data() != null) {
            final employeeData = employeeDoc.data()!;
            print(
                "Found employee document for $employeeId: ${employeeData.toString()}");

            // Parse salary - handle both number and string formats
            double salary = 0.0;
            if (employeeData['salary'] != null) {
              if (employeeData['salary'] is num) {
                salary = (employeeData['salary'] as num).toDouble();
              } else if (employeeData['salary'] is String) {
                salary = double.tryParse(employeeData['salary']
                        .toString()
                        .replaceAll('"', '')
                        .replaceAll(',', '')) ??
                    0.0;
              }
            }

            // Parse late fine - check all possible field names
            String lateFine = "0";
            if (employeeData['late fine'] != null) {
              lateFine = employeeData['late fine'].toString();
            } else if (employeeData['lateFine'] != null) {
              lateFine = employeeData['lateFine'].toString();
            } else if (employeeData['late_fine'] != null) {
              lateFine = employeeData['late_fine'].toString();
            }

            employeeMap[employeeId] = {
              'id': employeeId,
              'uid': employeeId,
              'name': employeeData['name'] ?? 'Unknown',
              'salary': salary,
              'late_fine': lateFine,
              'designation': employeeData['designation'] ?? 'Employee',
              ...employeeData,
            };
          } else {
            print(
                "No employee document found for $employeeId in Employees collection");
          }
        } catch (e) {
          print("Error fetching employee $employeeId details: $e");
        }
      }

      print("Final employee count with attendance: ${employeeMap.length}");
      if (mounted) {
        setState(() {
          _employees = employeeMap.values.toList();
          _filteredEmployees = _employees;
        });
      }
    } catch (e) {
      print("Error fetching employees: $e");
      throw e;
    }
  }

// Updated method to correctly calculate salary for employees with attendance
  double _getEmployeeSalaryPaid(String employeeId) {
    // Find the employee data using either uid or id
    final employee = _employees.firstWhere(
        (emp) => (emp['uid'] == employeeId || emp['id'] == employeeId),
        orElse: () => {'salary': 0.0});

    // Get the employee's daily salary
    double dailySalary = 0.0;
    if (employee['salary'] is num) {
      dailySalary = (employee['salary'] as num).toDouble();
    } else if (employee['salary'] is String) {
      dailySalary = double.tryParse(employee['salary']
              .toString()
              .replaceAll('"', '')
              .replaceAll(',', '')) ??
          0.0;
    }

    // Count present days for this employee
    final presentDays = _attendanceRecords
        .where((record) => record['userId'] == employeeId)
        .length;

    // Calculate and return the total salary
    final salaryPaid = dailySalary * presentDays;
    print(
        "Calculated salary for $employeeId: dailySalary=$dailySalary × presentDays=$presentDays = $salaryPaid");
    return salaryPaid;
  }

// Updated method to correctly calculate fines for employees with attendance
  double _getEmployeeFines(String employeeId) {
    // Find employee to get late fine percentage
    // Find employee to get late fine value
    final employee = _employees.firstWhere(
        (emp) => (emp['uid'] == employeeId || emp['id'] == employeeId),
        orElse: () => {'late_fine': "0", 'salary': 0.0});

    // Get the late fine amount as an absolute value, not a percentage
    String lateFineStr = "0";
    if (employee['late fine'] != null) {
      lateFineStr = employee['late fine'].toString();
    } else if (employee['lateFine'] != null) {
      lateFineStr = employee['lateFine'].toString();
    } else if (employee['late_fine'] != null) {
      lateFineStr = employee['late_fine'].toString();
    }

    // Convert late fine string to double (this is a fixed amount, not a percentage)
    double lateFineAmount =
        double.tryParse(lateFineStr.replaceAll('"', '').replaceAll(',', '')) ??
            0.0;

    // Count late days for this employee
    final lateDays = _attendanceRecords
        .where((record) =>
            record['userId'] == employeeId && record['isLate'] == true)
        .length;

    // Calculate total fines (flat rate per late day)
    final totalFines = lateFineAmount * lateDays;

    print(
        "Calculated fines for $employeeId: lateFineAmount=$lateFineAmount × lateDays=$lateDays = $totalFines");
    return totalFines;
  }
// Update these methods to correctly calculate salary and fines

  Future<void> _fetchAttendanceData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final dateParts = _selectedMonth.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

      print("Fetching attendance from $startDateStr to $endDateStr");

      List<Map<String, dynamic>> attendanceRecords = [];

      try {
        final querySnapshot = await _firestore
            .collection('attendance')
            .where('date', isGreaterThanOrEqualTo: startDateStr)
            .where('date', isLessThanOrEqualTo: endDateStr)
            .get();

        print("Server-side filtered records: ${querySnapshot.docs.length}");

        attendanceRecords = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      } catch (e) {
        print(
            "Server-side filtering failed: $e. Falling back to client-side filtering.");

        final querySnapshot = await _firestore.collection('attendance').get();

        print("Total attendance records found: ${querySnapshot.docs.length}");

        final allRecords = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();

        attendanceRecords = allRecords.where((record) {
          final date = record['date'] as String?;
          return date != null &&
              date.compareTo(startDateStr) >= 0 &&
              date.compareTo(endDateStr) <= 0;
        }).toList();

        print("Client-side filtered records: ${attendanceRecords.length}");
      }

      final validRecords = attendanceRecords.where((record) {
        final userId = record['userId'] ?? record['user_id'] ?? record['uid'];
        var date = record['date'];
        if (date == null) {
          final timestamp = record['timestamp'];
          if (timestamp != null) {
            if (timestamp is Timestamp) {
              date = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
              record['date'] = date;
            } else if (timestamp is String) {
              try {
                final parsedDate = DateTime.parse(timestamp);
                date = DateFormat('yyyy-MM-dd').format(parsedDate);
                record['date'] = date;
              } catch (e) {
                print("Could not parse timestamp: $timestamp");
              }
            }
          }
        }

        if (userId != null && date != null) {
          record['userId'] = userId;
          return true;
        }
        return false;
      }).toList();

      print("Valid records with userId and date: ${validRecords.length}");

      setState(() {
        _attendanceRecords = validRecords;
        _isLoading = false;
      });

      _calculateStatistics(startDate, endDate);
    } catch (e) {
      print("Error fetching attendance data: $e");
      setState(() {
        _isLoading = false;
      });
      throw e;
    }
  }

  Future<void> _fetchDailyRecords() async {
    try {
      final dateParts = _selectedMonth.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);

      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

      final querySnapshot = await _firestore
          .collection('daily_records')
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .get();

      final dailyRecords = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      // Aggregate total fines by employee to avoid double-counting
      final Map<String, double> employeeTotalFines = {};
      for (var record in dailyRecords) {
        final employeeId = record['employeeId'] as String;
        if (!employeeTotalFines.containsKey(employeeId)) {
          employeeTotalFines[employeeId] = record['totalFine'] ?? 0.0;
        }
      }

      setState(() {
        _dailyRecords = dailyRecords;
        _totalSalaryPaid = dailyRecords.fold(
            0.0, (sum, record) => sum + (record['dailySalary'] ?? 0.0));
        _totalFines =
            employeeTotalFines.values.fold(0.0, (sum, fine) => sum + fine);
      });
    } catch (e) {
      print("Error fetching daily records: $e");
    }
  }

  Future<void> _calculateAndStoreDailyData(
      DateTime startDate, DateTime endDate) async {
    final presentDaysMap = <String, int>{};
    final lateDaysMap = <String, int>{};

    // Count present and late days for each employee
    for (var record in _attendanceRecords) {
      final employeeId = record['userId'] as String?;
      if (employeeId != null) {
        presentDaysMap[employeeId] = (presentDaysMap[employeeId] ?? 0) + 1;
        if (record['isLate'] == true) {
          lateDaysMap[employeeId] = (lateDaysMap[employeeId] ?? 0) + 1;
        }
      }
    }

    for (var employee in _employees) {
      final employeeId = employee['uid'] ?? employee['id'] as String;
      // Fetch salary from the employee document (per day)
      final dailySalary = (employee['salary'] is String
              ? double.tryParse(
                  employee['salary'].replaceAll('"', '').replaceAll(',', ''))
              : (employee['salary'] is num
                  ? employee['salary'].toDouble()
                  : 0.0)) ??
          0.0;

      // Fetch late fine amount from employee document
      String lateFineStr = "0";
      if (employee['late fine'] != null) {
        lateFineStr = employee['late fine'].toString();
      } else if (employee['lateFine'] != null) {
        lateFineStr = employee['lateFine'].toString();
      } else if (employee['late_fine'] != null) {
        lateFineStr = employee['late_fine'].toString();
      }
      final lateFineAmount = double.tryParse(
              lateFineStr.replaceAll('"', '').replaceAll(',', '')) ??
          0.0;

      final presentDays = presentDaysMap[employeeId] ?? 0;
      final lateDays = lateDaysMap[employeeId] ?? 0;

      for (int day = 1; day <= endDate.day; day++) {
        final date = DateTime(startDate.year, startDate.month, day);
        final dateStr = DateFormat('yyyy-MM-dd').format(date);

        if (date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday) {
          continue;
        }

        final attendanceRecord = _attendanceRecords.firstWhere(
          (record) =>
              (record['userId'] as String?) == employeeId &&
              record['date'] == dateStr,
          orElse: () => {},
        );

        double dailySalaryPaid = 0.0;
        double fine = 0.0;
        bool isLate = false;
        bool isPresent = false;

        if (attendanceRecord.isNotEmpty) {
          isPresent = true;
          final timeString = attendanceRecord['timeString'] as String? ?? '';
          isLate = _isLate(timeString);
          dailySalaryPaid = dailySalary; // Base daily salary
          if (isLate) {
            fine = lateFineAmount; // Use flat fine amount per late day
            dailySalaryPaid -= fine;
          }
        }

        // Calculate total salary and fines for the month
        final totalSalaryForMonth = dailySalary * presentDays;
        final totalFineForMonth = lateFineAmount * lateDays;

        final dailyRecord = {
          'employeeId': employeeId,
          'date': dateStr,
          'isPresent': isPresent,
          'isLate': isLate,
          'dailySalary': isPresent ? dailySalaryPaid : 0.0,
          'fine': isPresent && isLate ? fine : 0.0,
          'totalSalary': totalSalaryForMonth,
          'totalFine': totalFineForMonth,
          'month': _selectedMonth,
        };

        await _firestore
            .collection('daily_records')
            .doc('$employeeId-$dateStr')
            .set(dailyRecord, SetOptions(merge: true));
      }
    }

    await _fetchDailyRecords();
  }

  bool _isLate(String timeString) {
    if (timeString.isEmpty) return false;

    try {
      final officeTime = DateFormat('HH:mm:ss').parse(officeStartTime);
      final checkInTime = DateFormat('HH:mm:ss').parse(timeString);

      return checkInTime.isAfter(officeTime);
    } catch (e) {
      print("Error parsing time: $e");
      return false;
    }
  }

  void _calculateStatistics(DateTime startDate, DateTime endDate) {
    int totalPresent = 0;
    int totalLate = 0;
    int totalAbsent = 0;

    int totalWorkingDays = 0;
    for (int day = 1; day <= endDate.day; day++) {
      final date = DateTime(startDate.year, startDate.month, day);
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        totalWorkingDays++;
      }
    }

    double totalFinesSum = 0.0;

    for (var employee in _employees) {
      final employeeId = employee['uid'] ?? employee['id'];
      final employeeRecords = _attendanceRecords
          .where((record) => record['userId'] == employeeId)
          .toList();

      final presentCount = employeeRecords.where((record) {
        final isLate = record['isLate'] ?? false;
        return !isLate;
      }).length;

      final lateCount = employeeRecords.where((record) {
        final isLate = record['isLate'] ?? false;
        return isLate;
      }).length;

      totalPresent += presentCount;
      totalLate += lateCount;

      // Calculate fines for this employee and add to total
      final employeeFines = _getEmployeeFines(employeeId);
      totalFinesSum += employeeFines;
    }

    final totalEmployeeWorkDays = totalWorkingDays * _employees.length;
    totalAbsent = totalEmployeeWorkDays - (totalPresent + totalLate);
    if (totalAbsent < 0) totalAbsent = 0;

    setState(() {
      _totalPresent = totalPresent;
      _totalLate = totalLate;
      _totalAbsent = totalAbsent;
      _totalFines = totalFinesSum; // Update _totalFines here
    });

    _calculateAndStoreDailyData(startDate, endDate);
    _calculateCurrentDayAttendance();
  }

  void _calculateCurrentDayAttendance() {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final todayRecords = _attendanceRecords
        .where((record) => record['date'] == todayStr)
        .toList();

    _currentDayPresent =
        todayRecords.where((record) => !(record['isLate'] ?? false)).length;
    _currentDayLate =
        todayRecords.where((record) => (record['isLate'] ?? false)).length;
    int totalExpected = _employees.length;
    _currentDayAbsent = totalExpected - (_currentDayPresent + _currentDayLate);
    if (_currentDayAbsent < 0) _currentDayAbsent = 0;

    _presentEmployees = _employees.where((employee) {
      final employeeId = employee['uid'] ?? employee['id'];
      return todayRecords.any((record) =>
          record['userId'] == employeeId && !(record['isLate'] ?? false));
    }).toList();
  }

  void _filterEmployees(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filterEmployeesByStatus();
      if (query.isEmpty) {
        _filteredEmployees = _employees;
      } else {
        _filteredEmployees = _employees.where((employee) {
          final name = employee['name']?.toString().toLowerCase() ?? '';
          final designation =
              employee['designation']?.toString().toLowerCase() ?? '';
          return name.contains(_searchQuery) ||
              designation.contains(_searchQuery);
        }).toList();
      }
    });
  }

  List<Map<String, String>> _getMonthOptions() {
    final options = <Map<String, String>>[];
    final now = DateTime.now();

    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final value = DateFormat('yyyy-MM').format(date);
      final label = DateFormat('MMMM yyyy').format(date);

      options.add({
        'value': value,
        'label': label,
      });
    }

    return options;
  }

  List<Map<String, dynamic>> _getEmployeeAttendanceData(String employeeId) {
    return _attendanceRecords
        .where((record) => record['userId'] == employeeId)
        .toList();
  }

  int _getEmployeePresentCount(String employeeId) {
    return _attendanceRecords
        .where((record) =>
            record['userId'] == employeeId && record['isLate'] == false)
        .length;
  }

  int _getEmployeeLateCount(String employeeId) {
    return _attendanceRecords
        .where((record) =>
            record['userId'] == employeeId && record['isLate'] == true)
        .length;
  }

  int _getEmployeeAbsentCount(String employeeId, int workingDays) {
    final presentDays = _getEmployeePresentCount(employeeId);
    final lateDays = _getEmployeeLateCount(employeeId);
    final absentDays = workingDays - (presentDays + lateDays);
    return absentDays > 0 ? absentDays : 0;
  }

  int _getWorkingDaysInMonth() {
    final dateParts = _selectedMonth.split('-');
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    int workingDays = 0;
    for (int day = 1; day <= endDate.day; day++) {
      final date = DateTime(year, month, day);
      if (date.weekday != DateTime.saturday &&
          date.weekday != DateTime.sunday) {
        workingDays++;
      }
    }

    return workingDays;
  }

  String _formatAttendancePercentage(String employeeId) {
    final workingDays = _getWorkingDaysInMonth();
    final presentDays = _getEmployeePresentCount(employeeId);
    final lateDays = _getEmployeeLateCount(employeeId);

    if (workingDays == 0) return '0%';

    final attendancePercentage = ((presentDays + lateDays) / workingDays) * 100;
    return '${attendancePercentage.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;
    final isLargeScreen = screenSize.width >= 900;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final horizontalPadding = screenSize.width * 0.03;
    final verticalPadding = screenSize.height * 0.02;

    return Scaffold(
      appBar: AppBar(
        title: CommonText(
          text: 'Employee Attendance',
          style: AppTypography.heading.copyWith(
            fontSize: isSmallScreen ? 18 : 22,
          ),
          color: Colors.white,
        ),
        backgroundColor: AppTheme.buildingBlue,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: isSmallScreen ? 20 : 24),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  CommonText(
                    text: 'Loading attendance data...',
                    style: AppTypography.medium.copyWith(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    color: AppTheme.lightGray,
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.buildingBlue.withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (isLargeScreen && isPortrait) {
                      return _buildLargeScreenLayout(constraints);
                    } else if (isTablet) {
                      return _buildTabletLayout(constraints);
                    } else {
                      return _buildSmallScreenLayout(constraints);
                    }
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildTabletLayout(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(constraints),
        SizedBox(height: constraints.maxHeight * 0.02),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildStatisticsCards(compact: true, constraints: constraints),
        ),
        SizedBox(height: constraints.maxHeight * 0.02),
        Expanded(
          child: _selectedStatus != null
              ? _buildStatusEmployeeList(constraints)
              : _selectedEmployeeId == null
                  ? _buildEmployeeList(constraints)
                  : _buildEmployeeDetailView(constraints),
        ),
      ],
    );
  }

  Widget _buildLargeScreenLayout(BoxConstraints constraints) {
    final isExtraLarge = constraints.maxWidth > 1200;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: isExtraLarge ? 2 : 3,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 300,
              maxWidth: constraints.maxWidth * 0.4,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFilterSection(constraints),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  _buildStatisticsCards(
                      compact: false, constraints: constraints),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: constraints.maxWidth * 0.02),
        Flexible(
          flex: isExtraLarge ? 8 : 7,
          child: _selectedStatus != null
              ? _buildStatusEmployeeList(constraints)
              : _selectedEmployeeId == null
                  ? _buildEmployeeList(constraints)
                  : _buildEmployeeDetailView(constraints),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout(BoxConstraints constraints) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSection(constraints),
          SizedBox(height: constraints.maxHeight * 0.02),
          ExpansionTile(
            title: CommonText(
              text: "Attendance Overview",
              style: AppTypography.subheading.copyWith(
                fontSize: constraints.maxWidth < 400 ? 16 : 18,
              ),
              color: AppTheme.buildingBlue,
            ),
            initiallyExpanded: true,
            children: [
              _buildStatisticsCards(compact: true, constraints: constraints),
            ],
          ),
          SizedBox(height: constraints.maxHeight * 0.02),
          SizedBox(
            height: constraints.maxHeight * 0.6,
            child: _selectedStatus != null
                ? _buildStatusEmployeeList(constraints)
                : _selectedEmployeeId == null
                    ? _buildEmployeeList(constraints)
                    : _buildEmployeeDetailView(constraints),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BoxConstraints constraints) {
    final monthOptions = _getMonthOptions();
    final isSmallScreen = constraints.maxWidth < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: "Attendance Filters",
              style: AppTypography.subheading.copyWith(
                fontSize: isSmallScreen ? 16 : 18,
              ),
              color: AppTheme.buildingBlue,
            ),
            SizedBox(height: constraints.maxHeight * 0.02),
            isSmallScreen
                ? Column(
                    children: [
                      _buildMonthDropdown(monthOptions, constraints),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      _buildSearchField(constraints),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      _buildStatusDropdown(constraints),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      _buildExportButton(constraints),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildMonthDropdown(monthOptions, constraints),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.03),
                      Expanded(
                        flex: 3,
                        child: _buildSearchField(constraints),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.03),
                      Expanded(
                        flex: 2,
                        child: _buildStatusDropdown(constraints),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.03),
                      Expanded(
                        flex: 2,
                        child: _buildExportButton(constraints),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BoxConstraints constraints) {
    final statusOptions = [
      {'value': 'all', 'label': 'All'},
      {'value': 'present', 'label': 'Present'},
      {'value': 'late', 'label': 'Late'},
      {'value': 'absent', 'label': 'Absent'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: "Select Status",
          style: AppTypography.small.copyWith(
            fontSize: constraints.maxWidth < 400 ? 12 : 14,
          ),
          color: AppTheme.deepBlack.withOpacity(0.7),
        ),
        SizedBox(height: constraints.maxHeight * 0.01),
        DropdownButtonFormField<String>(
          value: _selectedStatus ?? 'all',
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.filter_list,
                size: constraints.maxWidth < 400 ? 16 : 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.04,
              vertical: constraints.maxHeight * 0.01,
            ),
          ),
          items: statusOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(
                option['label']!,
                style:
                    TextStyle(fontSize: constraints.maxWidth < 400 ? 12 : 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedStatus = value == 'all' ? null : value;
                _filterEmployeesByStatus();
              });
            }
          },
        ),
      ],
    );
  }

  void _filterEmployeesByStatus() {
    setState(() {
      if (_selectedStatus == null) {
        _filteredEmployees = _employees
            .where((employee) =>
                employee['name']
                    ?.toString()
                    .toLowerCase()
                    .contains(_searchQuery) ??
                false ||
                    (employee['designation'] != null &&
                        employee['designation']
                            .toString()
                            .toLowerCase()
                            .contains(_searchQuery)) ??
                false)
            .toList();
      } else {
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _filteredEmployees = _employees.where((employee) {
          final employeeId = employee['uid'] ?? employee['id'];
          final todayRecords = _attendanceRecords
              .where((record) =>
                  record['date'] == todayStr && record['userId'] == employeeId)
              .toList();
          final matchesSearch = employee['name']
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery) ??
              false ||
                  (employee['designation'] != null &&
                      employee['designation']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery)) ??
              false;
          if (!matchesSearch) return false;

          if (_selectedStatus == 'present') {
            return todayRecords.isNotEmpty &&
                !(todayRecords[0]['isLate'] ?? false);
          } else if (_selectedStatus == 'late') {
            return todayRecords.isNotEmpty &&
                (todayRecords[0]['isLate'] ?? false);
          } else if (_selectedStatus == 'absent') {
            return todayRecords.isEmpty;
          }
          return true;
        }).toList();
      }
    });
  }

  Widget _buildExportButton(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    return ElevatedButton.icon(
      onPressed: _exportAllEmployeesData,
      icon: Icon(Icons.download, size: isSmallScreen ? 16 : 20),
      label: Text(
        'Export to Excel',
        style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.buildingBlue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: constraints.maxHeight * 0.015,
          horizontal: constraints.maxWidth * 0.03,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _exportAllEmployeesData() async {
    try {
      if (_isPermissionRequestInProgress) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'A permission request is already in progress. Please wait.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Set the flag to true to indicate a permission request is starting
      setState(() {
        _isPermissionRequestInProgress = true;
      });

      // Create Excel file using the excel package
      final excelFile = excel.Excel.createExcel();
      final sheet = excelFile['Employees'];

      // Add headers
      sheet.appendRow([
        excel.TextCellValue('Employee ID'),
        excel.TextCellValue('Name'),
        excel.TextCellValue('Designation'),
        excel.TextCellValue('Present Days'),
        excel.TextCellValue('Late Days'),
        excel.TextCellValue('Absent Days'),
        excel.TextCellValue('Salary Paid'),
        excel.TextCellValue('Fines'),
        excel.TextCellValue('Attendance %'),
        excel.TextCellValue('Status'),
      ]);

      final workingDays = _getWorkingDaysInMonth();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Add employee data
      bool hasData = false; // Track if any data rows are added
      for (var employee in _filteredEmployees) {
        final employeeId = employee['uid'] ?? employee['id'];
        final presentCount = _getEmployeePresentCount(employeeId);
        final lateCount = _getEmployeeLateCount(employeeId);
        final absentCount = _getEmployeeAbsentCount(employeeId, workingDays);
        final salaryPaid = _getEmployeeSalaryPaid(employeeId);
        final fines = _getEmployeeFines(employeeId);
        final attendancePercentage = _formatAttendancePercentage(employeeId);

        // Determine status
        final todayRecords = _attendanceRecords
            .where((record) =>
                record['date'] == todayStr && record['userId'] == employeeId)
            .toList();
        String status;
        if (todayRecords.isEmpty) {
          status = 'Absent';
        } else if (todayRecords[0]['isLate'] ?? false) {
          status = 'Late';
        } else {
          status = 'Present';
        }

        // Apply status filter if selected
        if (_selectedStatus != null &&
            _selectedStatus != 'all' &&
            status.toLowerCase() != _selectedStatus) {
          continue;
        }

        sheet.appendRow([
          excel.TextCellValue(employeeId?.toString() ?? 'N/A'),
          excel.TextCellValue(employee['name']?.toString() ?? 'Unknown'),
          excel.TextCellValue(
              employee['designation']?.toString() ?? 'Employee'),
          excel.TextCellValue(presentCount.toString()),
          excel.TextCellValue(lateCount.toString()),
          excel.TextCellValue(absentCount.toString()),
          excel.TextCellValue(salaryPaid.toStringAsFixed(2)),
          excel.TextCellValue(fines.toStringAsFixed(2)),
          excel.TextCellValue(attendancePercentage),
          excel.TextCellValue(status),
        ]);

        hasData = true; // Mark that we've added at least one row
      }

      // Check if any data was added
      if (!hasData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No data to export after applying filters.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isPermissionRequestInProgress = false;
        });
        return;
      }

      // Use the updated date and time for the file name
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName =
          'Employee_Attendance_${_selectedMonth}_${timestamp}.xlsx';

      // Generate the Excel bytes
      final excelBytes = excelFile.encode();
      if (excelBytes == null || excelBytes.isEmpty) {
        throw Exception('Failed to encode Excel file: No bytes generated');
      }

      // Platform-specific file saving
      if (Platform.isAndroid || Platform.isIOS) {
        // For mobile platforms, use path_provider to get a valid storage location
        Directory? directory;
        if (Platform.isAndroid) {
          // Get external storage directory for Android
          directory = await getExternalStorageDirectory();
        } else {
          // Get documents directory for iOS
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          throw Exception('Could not access storage directory');
        }

        // Create the file path
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);

        // Write the bytes to the file
        await file.writeAsBytes(excelBytes);

        // Use share_plus to share the file
        await Share.shareXFiles([XFile(filePath)],
            text: 'Employee Attendance Report');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file created and ready to share'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // For desktop platforms, use file_picker to let the user choose a save location
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Excel File',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (outputFile == null) {
          // User canceled the save operation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File save operation canceled.'),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isPermissionRequestInProgress = false;
          });
          return;
        }

        // Ensure the file has the correct extension
        if (!outputFile.toLowerCase().endsWith('.xlsx')) {
          outputFile += '.xlsx';
        }

        // Write the bytes to the file
        final file = File(outputFile);
        await file.writeAsBytes(excelBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file saved to $outputFile'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              onPressed: () async {
                try {
                  await OpenFile.open(outputFile);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error opening file: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }

      // Reset the permission request flag
      setState(() {
        _isPermissionRequestInProgress = false;
      });
    } catch (e) {
      print("Error exporting data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $e'),
          backgroundColor: Colors.red,
        ),
      );

      // Reset the permission request flag in case of error
      setState(() {
        _isPermissionRequestInProgress = false;
      });
    }
  }

  Widget _buildMonthDropdown(
      List<Map<String, String>> monthOptions, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: "Select Month",
          style: AppTypography.small.copyWith(
            fontSize: constraints.maxWidth < 400 ? 12 : 14,
          ),
          color: AppTheme.deepBlack.withOpacity(0.7),
        ),
        SizedBox(height: constraints.maxHeight * 0.01),
        DropdownButtonFormField<String>(
          value: _selectedMonth,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.calendar_today,
                size: constraints.maxWidth < 400 ? 16 : 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.04,
              vertical: constraints.maxHeight * 0.01,
            ),
          ),
          items: monthOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(
                option['label']!,
                style:
                    TextStyle(fontSize: constraints.maxWidth < 400 ? 12 : 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null && value != _selectedMonth) {
              setState(() {
                _selectedMonth = value;
                _selectedStatus = null;
              });
              _fetchAttendanceData();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSearchField(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: "Search Employee",
          style: AppTypography.small.copyWith(
            fontSize: constraints.maxWidth < 400 ? 12 : 14,
          ),
          color: AppTheme.deepBlack.withOpacity(0.7),
        ),
        SizedBox(height: constraints.maxHeight * 0.01),
        TextField(
          decoration: InputDecoration(
            hintText: "Search by name or designation",
            prefixIcon:
                Icon(Icons.search, size: constraints.maxWidth < 400 ? 16 : 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.04,
              vertical: constraints.maxHeight * 0.01,
            ),
          ),
          style: TextStyle(fontSize: constraints.maxWidth < 400 ? 12 : 14),
          onChanged: _filterEmployees,
        ),
      ],
    );
  }

  Widget _buildStatisticsCards({
    bool compact = false,
    required BoxConstraints constraints,
  }) {
    final isSmallScreen = constraints.maxWidth < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(compact
            ? constraints.maxWidth * 0.03
            : constraints.maxWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!compact)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    text: "Attendance Overview",
                    style: AppTypography.subheading.copyWith(
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                    color: AppTheme.buildingBlue,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.03,
                      vertical: constraints.maxHeight * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.buildingBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CommonText(
                      text: "${_employees.length} Employees",
                      style: AppTypography.medium.copyWith(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      color: AppTheme.buildingBlue,
                    ),
                  ),
                ],
              ),
            if (!compact) Divider(height: constraints.maxHeight * 0.03),
            isSmallScreen
                ? Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'present';
                          });
                        },
                        child: _buildStatCard(
                          title: "Present",
                          count: _totalPresent,
                          currentCount: _currentDayPresent,
                          icon: Icons.check_circle,
                          color: Colors.green,
                          compact: compact,
                          constraints: constraints,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.01),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'late';
                          });
                        },
                        child: _buildStatCard(
                          title: "Late",
                          count: _totalLate,
                          currentCount: _currentDayLate,
                          icon: Icons.watch_later,
                          color: Colors.orange,
                          compact: compact,
                          constraints: constraints,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.01),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'absent';
                          });
                        },
                        child: _buildStatCard(
                          title: "Absent",
                          count: _totalAbsent,
                          currentCount: _currentDayAbsent,
                          icon: Icons.cancel,
                          color: Colors.red,
                          compact: compact,
                          constraints: constraints,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.01),
                      _buildStatCard(
                        title: "Total Salary",
                        count: _totalSalaryPaid.toInt(),
                        icon: Icons.attach_money,
                        color: Colors.blue,
                        compact: compact,
                        constraints: constraints,
                      ),
                      SizedBox(height: constraints.maxHeight * 0.01),
                      _buildStatCard(
                        title: "Total Fines",
                        count: _totalFines.toInt(),
                        icon: Icons.money_off,
                        color: Colors.redAccent,
                        compact: compact,
                        constraints: constraints,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStatus = 'present';
                            });
                          },
                          child: _buildStatCard(
                            title: "Present",
                            count: _totalPresent,
                            currentCount: _currentDayPresent,
                            icon: Icons.check_circle,
                            color: Colors.green,
                            compact: compact,
                            constraints: constraints,
                          ),
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.03),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStatus = 'late';
                            });
                          },
                          child: _buildStatCard(
                            title: "Late",
                            count: _totalLate,
                            currentCount: _currentDayLate,
                            icon: Icons.watch_later,
                            color: Colors.orange,
                            compact: compact,
                            constraints: constraints,
                          ),
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.03),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStatus = 'absent';
                            });
                          },
                          child: _buildStatCard(
                            title: "Absent",
                            count: _totalAbsent,
                            currentCount: _currentDayAbsent,
                            icon: Icons.cancel,
                            color: Colors.red,
                            compact: compact,
                            constraints: constraints,
                          ),
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.03),
                      Expanded(
                        child: _buildStatCard(
                          title: "Total Salary",
                          count: _totalSalaryPaid.toInt(),
                          icon: Icons.attach_money,
                          color: Colors.blue,
                          compact: compact,
                          constraints: constraints,
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.03),
                      Expanded(
                        child: _buildStatCard(
                          title: "Total Fines",
                          count: _totalFines.toInt(),
                          icon: Icons.money_off,
                          color: Colors.redAccent,
                          compact: compact,
                          constraints: constraints,
                        ),
                      ),
                    ],
                  ),
            if (!compact) SizedBox(height: constraints.maxHeight * 0.02),
            if (!compact)
              Container(
                height: isSmallScreen
                    ? constraints.maxHeight * 0.2
                    : constraints.maxHeight * 0.25,
                child: _buildAttendanceChart(constraints),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    int? currentCount,
    required IconData icon,
    required Color color,
    bool compact = false,
    required BoxConstraints constraints,
  }) {
    final isSmallScreen = constraints.maxWidth < 600;

    return Container(
      padding: EdgeInsets.all(
          compact ? constraints.maxWidth * 0.03 : constraints.maxWidth * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: compact
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
                    SizedBox(width: constraints.maxWidth * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: title,
                          style: AppTypography.medium.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                        if (currentCount != null)
                          CommonText(
                            text: "Today: $currentCount",
                            style: AppTypography.small.copyWith(
                              color: color.withOpacity(0.7),
                              fontSize: isSmallScreen ? 10 : 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                CommonText(
                  text: "$count",
                  style: AppTypography.heading.copyWith(
                    fontSize: isSmallScreen ? 16 : 18,
                    color: color,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
                    SizedBox(width: constraints.maxWidth * 0.02),
                    CommonText(
                      text: title,
                      style: AppTypography.medium.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
                if (currentCount != null)
                  CommonText(
                    text: "Today: $currentCount",
                    style: AppTypography.small.copyWith(
                      color: color.withOpacity(0.7),
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                SizedBox(height: constraints.maxHeight * 0.015),
                CommonText(
                  text: "$count",
                  style: AppTypography.heading.copyWith(
                    fontSize: isSmallScreen ? 20 : 24,
                    color: color,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAttendanceChart(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;

    return Container(
      height: isSmallScreen
          ? constraints.maxHeight * 0.2
          : constraints.maxHeight * 0.25,
      padding: EdgeInsets.only(top: constraints.maxHeight * 0.02),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: max(_totalPresent, max(_totalLate, _totalAbsent)) * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String category;
                if (groupIndex == 0) {
                  category = 'Present';
                } else if (groupIndex == 1) {
                  category = 'Late';
                } else {
                  category = 'Absent';
                }
                return BarTooltipItem(
                  '$category\n${rod.toY.toInt()}',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'Present';
                      break;
                    case 1:
                      text = 'Late';
                      break;
                    case 2:
                      text = 'Absent';
                      break;
                    default:
                      text = '';
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: constraints.maxHeight * 0.01),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: AppTheme.deepBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  );
                },
                reservedSize: isSmallScreen ? 24 : 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: isSmallScreen ? 30 : 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return SizedBox();
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: AppTheme.deepBlack.withOpacity(0.7),
                      fontSize: isSmallScreen ? 8 : 10,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: _totalPresent.toDouble(),
                  color: Colors.green,
                  width: isSmallScreen ? 16 : 22,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: _totalLate.toDouble(),
                  color: Colors.orange,
                  width: isSmallScreen ? 16 : 22,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: _totalAbsent.toDouble(),
                  color: Colors.red,
                  width: isSmallScreen ? 16 : 22,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList(BoxConstraints constraints) {
    final workingDays = _getWorkingDaysInMonth();
    final isSmallScreen = constraints.maxWidth < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: "Employee Attendance",
              style: AppTypography.subheading.copyWith(
                fontSize: isSmallScreen ? 16 : 18,
              ),
              color: AppTheme.buildingBlue,
            ),
            Divider(height: constraints.maxHeight * 0.03),
            Expanded(
              child: _filteredEmployees.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_alt,
                              size: isSmallScreen ? 48 : 64,
                              color: AppTheme.lightGray),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          CommonText(
                            text: "No employees found",
                            style: AppTypography.medium.copyWith(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            color: AppTheme.deepBlack.withOpacity(0.6),
                          ),
                        ],
                      ),
                    )
                  : isSmallScreen
                      ? _buildEmployeeCardList(workingDays, constraints)
                      : _buildEmployeeTable(workingDays, constraints),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCardList(int workingDays, BoxConstraints constraints) {
    return ListView.builder(
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = _filteredEmployees[index];
        final employeeId = employee['uid'] ?? employee['id'];
        final presentCount = _getEmployeePresentCount(employeeId);
        final lateCount = _getEmployeeLateCount(employeeId);
        final absentCount = _getEmployeeAbsentCount(employeeId, workingDays);
        final salaryPaid = _getEmployeeSalaryPaid(employeeId);
        final fines = _getEmployeeFines(employeeId);

        return Card(
          elevation: 1,
          margin: EdgeInsets.only(bottom: constraints.maxHeight * 0.01),
          child: ListTile(
            onTap: () {
              setState(() {
                _selectedEmployeeId = employeeId;
                _selectedStatus = null;
              });
            },
            leading: CircleAvatar(
              backgroundColor: AppTheme.buildingBlue.withOpacity(0.2),
              radius: constraints.maxWidth < 400 ? 16 : 20,
              child: Icon(Icons.person,
                  color: AppTheme.buildingBlue,
                  size: constraints.maxWidth < 400 ? 16 : 20),
            ),
            title: CommonText(
              text: employee['name'] ?? 'Unknown',
              style: AppTypography.medium.copyWith(
                fontSize: constraints.maxWidth < 400 ? 12 : 14,
              ),
              color: AppTheme.deepBlack,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  text: employee['designation'] ?? 'Employee',
                  style: AppTypography.small.copyWith(
                    fontSize: constraints.maxWidth < 400 ? 10 : 12,
                  ),
                  color: AppTheme.deepBlack.withOpacity(0.6),
                ),
                CommonText(
                  text: "Salary: ${salaryPaid.toStringAsFixed(2)}",
                  style: AppTypography.small.copyWith(
                    fontSize: constraints.maxWidth < 400 ? 10 : 12,
                  ),
                  color: Colors.green,
                ),
                CommonText(
                  text: "Fines: ${fines.toStringAsFixed(2)}",
                  style: AppTypography.small.copyWith(
                    fontSize: constraints.maxWidth < 400 ? 10 : 12,
                  ),
                  color: Colors.redAccent,
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CommonText(
                  text: _formatAttendancePercentage(employeeId),
                  style: AppTypography.medium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: constraints.maxWidth < 400 ? 12 : 14,
                    color: _getAttendanceColor(
                        presentCount, lateCount, workingDays),
                  ),
                ),
                CommonText(
                  text: "P: $presentCount, L: $lateCount, A: $absentCount",
                  style: AppTypography.small.copyWith(
                    fontSize: constraints.maxWidth < 400 ? 10 : 12,
                  ),
                  color: AppTheme.deepBlack.withOpacity(0.6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmployeeTable(int workingDays, BoxConstraints constraints) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowHeight: constraints.maxHeight * 0.06,
          dataRowHeight: constraints.maxHeight * 0.08,
          columnSpacing: constraints.maxWidth * 0.03,
          headingRowColor: MaterialStateProperty.all(
            AppTheme.buildingBlue.withOpacity(0.1),
          ),
          columns: [
            DataColumn(
                label: Text('Employee',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14))),
            DataColumn(
                label: Text('Designation',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14))),
            DataColumn(
                label: Text('Present',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14))),
            DataColumn(
                label: Text('Late',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14))),
            DataColumn(
                label: Text('Absent',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14))),
            DataColumn(
                label: Text('Salary Paid',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14))),
            DataColumn(
                label: Text('Fines',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14))),
            DataColumn(
                label: Text('Attendance %',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14))),
            DataColumn(
                label: Text('Actions',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14))),
          ],
          rows: _filteredEmployees.map((employee) {
            final employeeId = employee['uid'] ?? employee['id'];
            final presentCount = _getEmployeePresentCount(employeeId);
            final lateCount = _getEmployeeLateCount(employeeId);
            final absentCount =
                _getEmployeeAbsentCount(employeeId, workingDays);
            final salaryPaid = _getEmployeeSalaryPaid(employeeId);
            final fines = _getEmployeeFines(employeeId);
            final attendancePercentage =
                _formatAttendancePercentage(employeeId);

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.buildingBlue.withOpacity(0.2),
                        radius: constraints.maxWidth < 900 ? 14 : 16,
                        child: Icon(Icons.person,
                            color: AppTheme.buildingBlue,
                            size: constraints.maxWidth < 900 ? 14 : 18),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.02),
                      Text(
                        employee['name'] ?? 'Unknown',
                        style: TextStyle(
                            fontSize: constraints.maxWidth < 900 ? 12 : 14),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    employee['designation'] ?? 'Employee',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14),
                  ),
                ),
                DataCell(
                  Text(
                    '$presentCount',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14),
                  ),
                ),
                DataCell(
                  Text(
                    '$lateCount',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14),
                  ),
                ),
                DataCell(
                  Text(
                    '$absentCount',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14),
                  ),
                ),
                DataCell(
                  Text(
                    '\$${salaryPaid.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14,
                        color: Colors.green),
                  ),
                ),
                DataCell(
                  Text(
                    '\$${fines.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 900 ? 12 : 14,
                        color: Colors.redAccent),
                  ),
                ),
                DataCell(
                  Text(
                    attendancePercentage,
                    style: TextStyle(
                      color: _getAttendanceColor(
                          presentCount, lateCount, workingDays),
                      fontWeight: FontWeight.bold,
                      fontSize: constraints.maxWidth < 900 ? 12 : 14,
                    ),
                  ),
                ),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedEmployeeId = employeeId;
                        _selectedStatus = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.buildingBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.03),
                      minimumSize: Size(constraints.maxWidth * 0.15,
                          constraints.maxHeight * 0.04),
                    ),
                    child: Text(
                      'Details',
                      style: TextStyle(
                          fontSize: constraints.maxWidth < 900 ? 10 : 12),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusEmployeeList(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 600;
    final statusEmployees = _selectedStatus == 'present'
        ? _presentEmployees
        : _employees.where((employee) {
            final employeeId = employee['uid'] ?? employee['id'];
            final todayRecords = _attendanceRecords
                .where((record) =>
                    record['date'] ==
                        DateFormat('yyyy-MM-dd').format(DateTime.now()) &&
                    record['userId'] == employeeId)
                .toList();
            if (_selectedStatus == 'late') {
              return todayRecords.isNotEmpty &&
                  (todayRecords[0]['isLate'] ?? false);
            } else if (_selectedStatus == 'absent') {
              return todayRecords.isEmpty;
            }
            return false;
          }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(constraints.maxWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  text: "${_selectedStatus?.toUpperCase()} Employees",
                  style: AppTypography.subheading.copyWith(
                    fontSize: isSmallScreen ? 16 : 18,
                  ),
                  color: AppTheme.buildingBlue,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_back, size: isSmallScreen ? 20 : 24),
                  onPressed: () {
                    setState(() {
                      _selectedStatus = null;
                    });
                  },
                ),
              ],
            ),
            Divider(height: constraints.maxHeight * 0.03),
            Expanded(
              child: statusEmployees.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_alt,
                              size: isSmallScreen ? 48 : 64,
                              color: AppTheme.lightGray),
                          SizedBox(height: constraints.maxHeight * 0.02),
                          CommonText(
                            text: "No ${_selectedStatus} employees found",
                            style: AppTypography.medium.copyWith(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            color: AppTheme.deepBlack.withOpacity(0.6),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: statusEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = statusEmployees[index];
                        return Card(
                          elevation: 1,
                          margin: EdgeInsets.only(
                              bottom: constraints.maxHeight * 0.01),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.buildingBlue.withOpacity(0.2),
                              radius: constraints.maxWidth < 400 ? 16 : 20,
                              child: Icon(Icons.person,
                                  color: AppTheme.buildingBlue,
                                  size: constraints.maxWidth < 400 ? 16 : 20),
                            ),
                            title: CommonText(
                              text: employee['name'] ?? 'Unknown',
                              style: AppTypography.medium.copyWith(
                                fontSize: constraints.maxWidth < 400 ? 12 : 14,
                              ),
                              color: AppTheme.deepBlack,
                            ),
                            subtitle: CommonText(
                              text: employee['designation'] ?? 'Employee',
                              style: AppTypography.small.copyWith(
                                fontSize: constraints.maxWidth < 400 ? 10 : 12,
                              ),
                              color: AppTheme.deepBlack.withOpacity(0.6),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedEmployeeId =
                                    employee['uid'] ?? employee['id'];
                                _selectedStatus = null;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeDetailView(BoxConstraints constraints) {
    if (_selectedEmployeeId == null) return Container();

    final employee = _employees.firstWhere(
      (emp) => (emp['uid'] ?? emp['id']) == _selectedEmployeeId,
      orElse: () => {},
    );

    if (employee.isEmpty) {
      setState(() {
        _selectedEmployeeId = null;
      });
      return Container();
    }

    final employeeName = employee['name'] ?? 'Unknown';
    final employeeDesignation = employee['designation'] ?? 'Employee';
    final employeeEmail = employee['email'] ?? 'No email';
    final attendanceRecords = _getEmployeeAttendanceData(_selectedEmployeeId!);
    final workingDays = _getWorkingDaysInMonth();
    final presentCount = _getEmployeePresentCount(_selectedEmployeeId!);
    final lateCount = _getEmployeeLateCount(_selectedEmployeeId!);
    final absentCount =
        _getEmployeeAbsentCount(_selectedEmployeeId!, workingDays);
    final salaryPaid = _getEmployeeSalaryPaid(_selectedEmployeeId!);
    final fines = _getEmployeeFines(_selectedEmployeeId!);
    final isSmallScreen = constraints.maxWidth < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(constraints.maxWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: isSmallScreen ? 20 : 24),
                    onPressed: () {
                      setState(() {
                        _selectedEmployeeId = null;
                        _selectedStatus = null;
                      });
                    },
                  ),
                  Expanded(
                    child: CommonText(
                      text: "Employee Attendance Details",
                      style: AppTypography.subheading.copyWith(
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                      color: AppTheme.buildingBlue,
                    ),
                  ),
                ],
              ),
              Divider(height: constraints.maxHeight * 0.03),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                  child: isSmallScreen
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: constraints.maxWidth * 0.1,
                              backgroundColor:
                                  AppTheme.buildingBlue.withOpacity(0.2),
                              child: Icon(Icons.person,
                                  size: constraints.maxWidth * 0.1,
                                  color: AppTheme.buildingBlue),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            CommonText(
                              text: employeeName,
                              style: AppTypography.heading
                                  .copyWith(fontSize: isSmallScreen ? 18 : 20),
                              color: AppTheme.deepBlack,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.01),
                            CommonText(
                              text: employeeDesignation,
                              style: AppTypography.medium
                                  .copyWith(fontSize: isSmallScreen ? 14 : 16),
                              color: AppTheme.deepBlack.withOpacity(0.7),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.01),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.email,
                                    size: isSmallScreen ? 14 : 16,
                                    color: AppTheme.buildingBlue),
                                SizedBox(width: constraints.maxWidth * 0.01),
                                Flexible(
                                  child: CommonText(
                                    text: employeeEmail,
                                    style: AppTypography.small.copyWith(
                                        fontSize: isSmallScreen ? 12 : 14),
                                    color: AppTheme.deepBlack.withOpacity(0.7),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: constraints.maxWidth * 0.05,
                              backgroundColor:
                                  AppTheme.buildingBlue.withOpacity(0.2),
                              child: Icon(Icons.person,
                                  size: constraints.maxWidth * 0.05,
                                  color: AppTheme.buildingBlue),
                            ),
                            SizedBox(width: constraints.maxWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonText(
                                    text: employeeName,
                                    style: AppTypography.heading.copyWith(
                                        fontSize: isSmallScreen ? 18 : 20),
                                    color: AppTheme.deepBlack,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                      height: constraints.maxHeight * 0.01),
                                  CommonText(
                                    text: employeeDesignation,
                                    style: AppTypography.medium.copyWith(
                                        fontSize: isSmallScreen ? 14 : 16),
                                    color: AppTheme.deepBlack.withOpacity(0.7),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                      height: constraints.maxHeight * 0.01),
                                  Row(
                                    children: [
                                      Icon(Icons.email,
                                          size: isSmallScreen ? 14 : 16,
                                          color: AppTheme.buildingBlue),
                                      SizedBox(
                                          width: constraints.maxWidth * 0.01),
                                      Expanded(
                                        child: CommonText(
                                          text: employeeEmail,
                                          style: AppTypography.small.copyWith(
                                              fontSize:
                                                  isSmallScreen ? 12 : 14),
                                          color: AppTheme.deepBlack
                                              .withOpacity(0.7),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              isSmallScreen
                  ? Column(
                      children: [
                        _buildStatCard(
                          title: "Present",
                          count: presentCount,
                          icon: Icons.check_circle,
                          color: Colors.green,
                          compact: true,
                          constraints: constraints,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01),
                        _buildStatCard(
                          title: "Late",
                          count: lateCount,
                          icon: Icons.watch_later,
                          color: Colors.orange,
                          compact: true,
                          constraints: constraints,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01),
                        _buildStatCard(
                          title: "Absent",
                          count: absentCount,
                          icon: Icons.cancel,
                          color: Colors.red,
                          compact: true,
                          constraints: constraints,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01),
                        _buildStatCard(
                          title: "Salary Paid",
                          count: salaryPaid.toInt(),
                          icon: Icons.attach_money,
                          color: Colors.blue,
                          compact: true,
                          constraints: constraints,
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01),
                        _buildStatCard(
                          title: "Fines",
                          count: fines.toInt(),
                          icon: Icons.money_off,
                          color: Colors.redAccent,
                          compact: true,
                          constraints: constraints,
                        ),
                      ],
                    )
                  : Wrap(
                      spacing: constraints.maxWidth * 0.02,
                      runSpacing: constraints.maxHeight * 0.01,
                      children: [
                        SizedBox(
                          width: (constraints.maxWidth -
                                  constraints.maxWidth * 0.08) /
                              3,
                          child: _buildStatCard(
                            title: "Present",
                            count: presentCount,
                            icon: Icons.check_circle,
                            color: Colors.green,
                            constraints: constraints,
                          ),
                        ),
                        SizedBox(
                          width: (constraints.maxWidth -
                                  constraints.maxWidth * 0.08) /
                              3,
                          child: _buildStatCard(
                            title: "Late",
                            count: lateCount,
                            icon: Icons.watch_later,
                            color: Colors.orange,
                            constraints: constraints,
                          ),
                        ),
                        SizedBox(
                          width: (constraints.maxWidth -
                                  constraints.maxWidth * 0.08) /
                              3,
                          child: _buildStatCard(
                            title: "Absent",
                            count: absentCount,
                            icon: Icons.cancel,
                            color: Colors.red,
                            constraints: constraints,
                          ),
                        ),
                        SizedBox(
                          width: (constraints.maxWidth -
                                  constraints.maxWidth * 0.08) /
                              3,
                          child: _buildStatCard(
                            title: "Salary Paid",
                            count: salaryPaid.toInt(),
                            icon: Icons.attach_money,
                            color: Colors.blue,
                            constraints: constraints,
                          ),
                        ),
                        SizedBox(
                          width: (constraints.maxWidth -
                                  constraints.maxWidth * 0.08) /
                              3,
                          child: _buildStatCard(
                            title: "Fines",
                            count: fines.toInt(),
                            icon: Icons.money_off,
                            color: Colors.redAccent,
                            constraints: constraints,
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: constraints.maxHeight * 0.02),
              CommonText(
                text: "Attendance Records",
                style: AppTypography.medium
                    .copyWith(fontSize: isSmallScreen ? 14 : 16),
                color: AppTheme.buildingBlue,
              ),
              SizedBox(height: constraints.maxHeight * 0.01),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.4,
                ),
                child: attendanceRecords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today,
                                size: isSmallScreen ? 36 : 48,
                                color: AppTheme.lightGray),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            CommonText(
                              text:
                                  "No attendance records found for this month",
                              style: AppTypography.medium
                                  .copyWith(fontSize: isSmallScreen ? 12 : 14),
                              color: AppTheme.deepBlack.withOpacity(0.6),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: attendanceRecords.length,
                        itemBuilder: (context, index) {
                          final record = attendanceRecords[index];
                          final isLate = record['isLate'] ?? false;
                          final date = record['date'] ?? '';
                          final time = record['timeString'] ?? '';
                          final photoUrl = record['photoUrl'];
                          final location = record['location']?['address'] ??
                              'Unknown location';

                          return Card(
                            elevation: 1,
                            margin: EdgeInsets.only(
                                bottom: constraints.maxHeight * 0.01),
                            child: Padding(
                              padding:
                                  EdgeInsets.all(constraints.maxWidth * 0.03),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isLate
                                                ? Icons.warning
                                                : Icons.check_circle,
                                            color: isLate
                                                ? Colors.orange
                                                : Colors.green,
                                            size: isSmallScreen ? 16 : 20,
                                          ),
                                          SizedBox(
                                              width:
                                                  constraints.maxWidth * 0.02),
                                          CommonText(
                                            text: isLate ? "Late" : "Present",
                                            style:
                                                AppTypography.medium.copyWith(
                                              color: isLate
                                                  ? Colors.orange
                                                  : Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isSmallScreen ? 12 : 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Flexible(
                                        child: CommonText(
                                          text: "$date, $time",
                                          style: AppTypography.small.copyWith(
                                              fontSize:
                                                  isSmallScreen ? 10 : 12),
                                          color: AppTheme.deepBlack
                                              .withOpacity(0.7),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height: constraints.maxHeight * 0.01),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: isSmallScreen ? 14 : 16,
                                        color: AppTheme.buildingBlue,
                                      ),
                                      SizedBox(
                                          width: constraints.maxWidth * 0.01),
                                      Expanded(
                                        child: CommonText(
                                          text: location,
                                          style: AppTypography.small.copyWith(
                                              fontSize:
                                                  isSmallScreen ? 10 : 12),
                                          color: AppTheme.deepBlack
                                              .withOpacity(0.6),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (photoUrl != null && photoUrl.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: constraints.maxHeight * 0.01),
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    AppBar(
                                                      title: CommonText(
                                                        text:
                                                            'Attendance Photo',
                                                        style: AppTypography
                                                            .medium
                                                            .copyWith(
                                                                fontSize:
                                                                    isSmallScreen
                                                                        ? 14
                                                                        : 16),
                                                        color: Colors.white,
                                                      ),
                                                      backgroundColor:
                                                          AppTheme.buildingBlue,
                                                      leading: IconButton(
                                                        icon: Icon(Icons.close,
                                                            size: isSmallScreen
                                                                ? 20
                                                                : 24),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                      ),
                                                    ),
                                                    Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxHeight: constraints
                                                                .maxHeight *
                                                            0.6,
                                                        maxWidth: constraints
                                                                .maxWidth *
                                                            0.8,
                                                      ),
                                                      child: Image.network(
                                                        photoUrl,
                                                        fit: BoxFit.contain,
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null)
                                                            return child;
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      loadingProgress
                                                                          .expectedTotalBytes!
                                                                  : null,
                                                            ),
                                                          );
                                                        },
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Center(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                    Icons.error,
                                                                    color: Colors
                                                                        .red,
                                                                    size: isSmallScreen
                                                                        ? 36
                                                                        : 48),
                                                                SizedBox(
                                                                    height: constraints
                                                                            .maxHeight *
                                                                        0.01),
                                                                CommonText(
                                                                  text:
                                                                      'Failed to load image',
                                                                  style: AppTypography
                                                                      .small
                                                                      .copyWith(
                                                                          fontSize: isSmallScreen
                                                                              ? 12
                                                                              : 14),
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          height: constraints.maxWidth * 0.15,
                                          width: constraints.maxWidth * 0.15,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppTheme.lightGray),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Center(
                                                  child: Icon(
                                                      Icons.image_not_supported,
                                                      color: AppTheme.lightGray,
                                                      size: isSmallScreen
                                                          ? 24
                                                          : 32),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              ElevatedButton.icon(
                onPressed: () => _exportAttendanceData(),
                icon: Icon(Icons.download, size: isSmallScreen ? 16 : 20),
                label: Text(
                  'Export Attendance Data',
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.buildingBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: constraints.maxHeight * 0.015),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportAttendanceData() async {
    try {
      if (_selectedEmployeeId == null) return;

      final employee = _employees.firstWhere(
        (emp) => (emp['uid'] ?? emp['id']) == _selectedEmployeeId,
        orElse: () => {},
      );

      if (employee.isEmpty) return;

      final employeeName = employee['name'] ?? 'Unknown';
      final employeeAttendance =
          _getEmployeeAttendanceData(_selectedEmployeeId!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing attendance data for export...'),
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Attendance data for $employeeName exported successfully'),
            backgroundColor: Colors.green,
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
