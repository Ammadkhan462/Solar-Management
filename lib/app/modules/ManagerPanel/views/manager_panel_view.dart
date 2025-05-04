import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:admin/app/modules/EmployeesRegistration/views/employees_registration_view.dart';
import 'package:admin/app/modules/ManagerPanel/views/manager_project.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/manager_panel_controller.dart';
import 'package:intl/intl.dart'; // For date formatting

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
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppTheme.buildingBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed(Routes.LOGIN_CHOICE);
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
                        }).toList(),

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

class _EmployeeRegistrationFormState extends State<EmployeeRegistrationForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Register the employee through controller method
      await _controller.registerEmployee(
        _nameController.text,
        _cnicController.text,
        _selectedDesignation!,
      );

      // Clear form fields after successful submission
      _nameController.clear();
      _cnicController.clear();
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

            // Technical Details Card - New card to display all project data
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

                      // Calculate project progress
                      Builder(builder: (context) {
                        // Get the taskVideos/taskPhotos map from project data
                        final taskMedia = (project['taskVideos'] ??
                                project['taskPhotos']) as Map? ??
                            {};

                        // Define the standard tasks
                        final List<String> standardTaskKeys = [
                          'Structure',
                          'Panel Installation',
                          'Inverter installation', // Note lowercase 'i'
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

                        // Calculate percentage
                        final progressPercentage =
                            ((completedTasks / standardTaskKeys.length) * 100)
                                .round();

                        // Determine color based on progress
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

            // Task list with improved UI
            _buildTaskList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    // Get the taskVideos/taskPhotos map from project data
    final taskMedia =
        (project['taskVideos'] ?? project['taskPhotos']) as Map? ?? {};

    // Standard tasks list - matches exactly what employees see
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
        'key': 'Inverter installation', // Note lowercase 'i' to match Firestore
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
            onTap:
                isCompleted && mediaUrl != null && mediaUrl.startsWith('http')
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

  // Method to show project details dialog
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

  // Build the content for the project details dialog
  Widget _buildProjectDetailsContent() {
    // Define sections for better organization
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Solar Panel Details'),
        _buildDetailItem('PV Module', '${project['pvModule']}'),
        _buildDetailItem('Brand', '${project['brand']}'),
        _buildDetailItem('Size', '${project['size']}'),
        _buildDetailItem('Price Per Watt', '${project['pricePerWatt']}'),
        _buildDetailItem('Panel Quantity', '${project['panelQuantity']}'),
        _buildDetailItem('Total kW', '${project['totalKw']}'),
        SizedBox(height: 16),
        _buildSectionTitle('Inverter Details'),
        _buildDetailItem('Type', '${project['inverterType']}'),
        _buildDetailItem('kW Size', '${project['kwSize']}'),
        _buildDetailItem('Brand', '${project['inverterBrand']}'),
        _buildDetailItem('Price', '${project['inverterPrice']}'),
        _buildDetailItem('Quantity', '${project['inverterQuantity']}'),
        SizedBox(height: 16),
        _buildSectionTitle('Structure Details'),
        _buildDetailItem('Type', '${project['structureType']}'),
        _buildDetailItem('Price', '${project['structurePrice']}'),
        SizedBox(height: 16),
        _buildSectionTitle('Wiring Details'),
        _buildDetailItem('Wire Size', '${project['wireSize']}'),
        _buildDetailItem('Wire Length', '${project['wireLength']}'),
        _buildDetailItem('Wire Price/Meter', '${project['wirePricePerMeter']}'),
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
          _buildDetailItem('Battery Type', '${project['batteryType']}'),
          _buildDetailItem('Battery Brand', '${project['batteryBrand']}'),
          _buildDetailItem('Battery Quantity', '${project['batteryQuantity']}'),
          _buildDetailItem('Battery Price', '${project['batteryPrice']}'),
        ],
        SizedBox(height: 16),
        _buildSectionTitle('Project Timeline'),
        _buildDetailItem('Start Date', _formatDate(project['startDate'])),
        _buildDetailItem('End Date', _formatDate(project['endDate'])),
      ],
    );
  }

  // Format timestamp to readable date
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Not specified';

    try {
      // For handling Firestore Timestamp objects
      if (timestamp.toString().startsWith('Timestamp(')) {
        // Extract seconds from the Timestamp string format
        final regex = RegExp(r'seconds=(\d+)');
        final match = regex.firstMatch(timestamp.toString());
        if (match != null && match.groupCount >= 1) {
          final seconds = int.parse(match.group(1)!);
          final dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
          return _formatDateTime(dateTime);
        }
      }

      // For milliseconds timestamp as int
      if (timestamp is int) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return _formatDateTime(dateTime);
      }

      // For ISO format date strings
      if (timestamp is String && timestamp.contains('T')) {
        try {
          final dateTime = DateTime.parse(timestamp);
          return _formatDateTime(dateTime);
        } catch (_) {}
      }

      // Fall back to simple string
      return timestamp.toString();
    } catch (e) {
      return 'Invalid date';
    }
  }

  // Helper to format DateTime objects into readable strings
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

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  // Helper method to build section titles
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

  // Helper method to build detail items
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

  // Helper method to build map-based details (for components with quantities and prices)
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
            }).toList(),
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
                aspectRatio: _controller.value.aspectRatio,
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
