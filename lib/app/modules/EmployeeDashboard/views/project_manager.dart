import 'dart:async';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:admin/app/modules/EmployeeDashboard/views/projectdetails.dart'
    as employee_details;
import 'package:admin/app/modules/EmployeeDashboard/views/sitesupervisor.dart';
import 'package:admin/app/modules/ManagerPanel/views/manager_panel_view.dart'
    as manager_panel;
import 'package:admin/app/theme/typography.dart';
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:admin/app/modules/EmployeeDashboard/views/projectdetails.dart';
import 'package:admin/app/modules/EmployeeDashboard/controllers/employee_dashboard_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:admin/app/modules/EmployeeDashboard/views/projectdetails.dart';
import 'package:admin/app/modules/EmployeeDashboard/controllers/employee_dashboard_controller.dart';
import 'package:admin/app/modules/EmployeeDashboard/views/projectdetails.dart';

class ProjectManagerContent extends StatelessWidget {
  final EmployeeDashboardController controller;
  final bool autoLoadedProjects;

  ProjectManagerContent({
    Key? key,
    required this.controller,
    this.autoLoadedProjects = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void autoLoadProjectsData() {
      // Only auto-load once per session
      if (autoLoadedProjects) return;

      final managerId = controller.employee.value.managerId;
      if (managerId != null && managerId.isNotEmpty) {
        // Set flag to prevent multiple auto-loads
        controller.autoLoadedProjects = true;

        // Load the projects data
        controller.isLoading.value = true;
        controller
            .fetchAllProjectsWithSameManager(managerId)
            .catchError((error) {
          print("Error auto-loading projects: $error");
          // Don't show error messages during auto-load to avoid confusing the user
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoLoadProjectsData();
    });

    return LayoutBuilder(builder: (context, constraints) {
      // Determine if we're on a small screen
      final isSmallScreen = constraints.maxWidth < 600;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResponsiveSectionHeader(
            "Team Projects Overview",
            icon: Icons.dashboard,
            isSmallScreen: isSmallScreen,
          ),

          const SizedBox(height: 16),

          // Project status filter tabs - responsive layout
          _buildStatusFilterTabs(isSmallScreen),

          const SizedBox(height: 16),

          // Projects list
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Loading team projects...")
                  ],
                ),
              );
            }

            // Filter projects based on selected tab
            final filteredProjects = controller.getFilteredProjectsForManager();

            if (filteredProjects.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(Icons.folder_open,
                        size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      controller.projectManagerTabIndex.value == 0
                          ? "No team projects found"
                          : "No ${_getTabName(controller.projectManagerTabIndex.value).toLowerCase()} projects found",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProjects.length,
              itemBuilder: (context, index) {
                final project = filteredProjects[index];
                final progress = project['progress'] ?? 0;
                final status = project['status'] ?? 'pending';

                return _buildProjectManagerProjectCard(
                    project, progress, status);
              },
            );
          }),
        ],
      );
    });
  }

  // Responsive section header with adaptive refresh button
  Widget _buildResponsiveSectionHeader(String title,
      {required IconData icon, required bool isSmallScreen}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildRefreshButton(isSmallScreen),
      ],
    );
  }

  // Responsive refresh button
  Widget _buildRefreshButton(bool isSmallScreen) {
    return ElevatedButton.icon(
      onPressed: _handleRefresh,
      icon: const Icon(Icons.refresh),
      label: Text(isSmallScreen ? '' : 'Refresh'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: 8,
        ),
        minimumSize: Size(isSmallScreen ? 40 : 80, 36),
      ),
    );
  }

  // Extract refresh functionality to a separate method
  void _handleRefresh() {
    final managerId = controller.employee.value.managerId;
    if (managerId != null && managerId.isNotEmpty) {
      // Don't show a separate dialog, just use the isLoading value
      controller.isLoading.value = true;

      controller.fetchAllProjectsWithSameManager(managerId).then((_) {
        Get.snackbar(
          "Success",
          "Project data refreshed successfully",
          duration: const Duration(seconds: 3),
        );
      }).catchError((error) {
        Get.snackbar(
          "Error",
          "Failed to refresh project data: $error",
          duration: const Duration(seconds: 3),
        );
      });
    } else {
      Get.snackbar(
        "Error",
        "No manager ID found for this employee",
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Responsive status filter tabs
  Widget _buildStatusFilterTabs(bool isSmallScreen) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(() {
        return Row(
          children: [
            _buildFilterTab("All", 0, isSmallScreen),
            _buildFilterTab("Pending", 1, isSmallScreen),
            _buildFilterTab("In Progress", 2, isSmallScreen),
            _buildFilterTab("Completed", 3, isSmallScreen),
            _buildFilterTab("Not Completed", 4, isSmallScreen),
          ],
        );
      }),
    );
  }

  // Helper method to build individual filter tabs
  Widget _buildFilterTab(String name, int index, bool isSmallScreen) {
    final isSelected = controller.projectManagerTabIndex.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.projectManagerTabIndex.value = index,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.buildingBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize:
                  isSmallScreen ? 10 : 12, // Smaller font on small screens
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  // Helper method to get tab name
  String _getTabName(int index) {
    switch (index) {
      case 1:
        return "Pending";
      case 2:
        return "In Progress";
      case 3:
        return "Completed";
      case 4:
        return "Not Completed";
      default:
        return "All";
    }
  }

  Widget _buildProjectManagerProjectCard(
      Map<String, dynamic> project, int progress, String status) {
    // Get employee names from the project data for the predefined roles
    final salesEmployeeName = project['salesEmployeeName'] ?? 'Not assigned';
    final engineerName = project['assignedEngineerName'] ?? 'Not assigned';
    final siteSupervisorName = project['siteSupervisorName'] ?? 'Not assigned';
    final technicianName = project['technicianName'] ?? 'Not assigned';

    // Check if roles are assigned (ID exists)
    final hasSalesEmployee = project['salesEmployeeId'] != null &&
        project['salesEmployeeId'].toString().isNotEmpty;
    final hasEngineer = project['assignedEngineerId'] != null &&
        project['assignedEngineerId'].toString().isNotEmpty;
    final hasSiteSupervisor = project['siteSupervisorId'] != null &&
        project['siteSupervisorId'].toString().isNotEmpty;
    final hasTechnician = project['technicianId'] != null &&
        project['technicianId'].toString().isNotEmpty;

    // Get actual designations for each role
    final salesDesignation = project['salesEmployeeDesignation'] ?? 'Sales';
    final engineerDesignation =
        project['assignedEngineerDesignation'] ?? 'Engineer';
    final supervisorDesignation =
        project['siteSupervisorDesignation'] ?? 'Site Supervisor';
    final technicianDesignation =
        project['technicianDesignation'] ?? 'Technician';

    // Check if status is "doing" to highlight active team members
    final isDoingStatus = status.toLowerCase() == 'doing';

    // Create a map of assignedStaff IDs to their corresponding names and designations
    Map<String, Map<String, String>> staffDetails = {};

    // Add details for all assigned staff from predefined roles
    if (hasSalesEmployee) {
      staffDetails[project['salesEmployeeId'].toString()] = {
        'name': salesEmployeeName,
        'designation': salesDesignation
      };
    }
    if (hasEngineer) {
      staffDetails[project['assignedEngineerId'].toString()] = {
        'name': engineerName,
        'designation': engineerDesignation
      };
    }
    if (hasSiteSupervisor) {
      staffDetails[project['siteSupervisorId'].toString()] = {
        'name': siteSupervisorName,
        'designation': supervisorDesignation
      };
    }
    if (hasTechnician) {
      staffDetails[project['technicianId'].toString()] = {
        'name': technicianName,
        'designation': technicianDesignation
      };
    }

    // SOLUTION: Add staff details from the assignedStaffDetails array if available
    // This ensures ALL assigned staff have proper names and designations
    if (project['assignedStaffDetails'] != null &&
        project['assignedStaffDetails'] is List &&
        (project['assignedStaffDetails'] as List).isNotEmpty) {
      for (var staffDetail in project['assignedStaffDetails']) {
        if (staffDetail is Map &&
            staffDetail['id'] != null &&
            staffDetail['name'] != null &&
            staffDetail['designation'] != null) {
          staffDetails[staffDetail['id'].toString()] = {
            'name': staffDetail['name'],
            'designation': staffDetail['designation']
          };
        }
      }
    }

    // For backwards compatibility and further enhancement:
    // If assignedStaff exists but assignedStaffDetails doesn't, we can
    // implement a function to fetch employee details from Firestore

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        // Add a subtle border when status is "doing"
        border: isDoingStatus
            ? Border.all(color: Colors.blue.withOpacity(0.5), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (project.containsKey('id')) {
              final projectId = project['id'];
              final projectStatus =
                  project['status']?.toString().toLowerCase() ?? '';

              // Conditional navigation based on project status
              if (projectStatus == 'doing' || projectStatus == 'completed') {
                // For "doing" or "completed" projects, navigate to the ProjectDetailsScreen
                // that takes both project and projectId
                Get.to(() => manager_panel.ProjectDetailsScreen(
                      project: project,
                      projectId: projectId,
                    ));
              } else {
                // For all other statuses, navigate to the alternate ProjectDetailsScreen
                // that only takes projectId
                Get.to(() => employee_details.ProjectDetailsScreen(
                    projectId: projectId));
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project header with title and status - unchanged
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project['projectName'] ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Client: ${project['clientName'] ?? 'Not specified'}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress bar - unchanged
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress: $progress%",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress),
                    ),
                    minHeight: 8,
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Team Assignment Information - Enhanced with actual designations
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        if (!isDoingStatus) ...[
                          Row(
                            children: [
                              Text(
                                "Team Assignment",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.buildingBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Display assignments for each role with actual designations
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildRoleBadge(
                                salesDesignation,
                                salesEmployeeName,
                                hasSalesEmployee,
                                Icons.person,
                                false, // Set to false as we're only showing in non-doing status
                              ),
                              _buildRoleBadge(
                                engineerDesignation,
                                engineerName,
                                hasEngineer,
                                Icons.engineering,
                                false, // Set to false as we're only showing in non-doing status
                              ),
                              _buildRoleBadge(
                                supervisorDesignation,
                                siteSupervisorName,
                                hasSiteSupervisor,
                                Icons.supervisor_account,
                                false, // Set to false as we're only showing in non-doing status
                              ),
                              _buildRoleBadge(
                                technicianDesignation,
                                technicianName,
                                hasTechnician,
                                Icons.build,
                                false, // Set to false as we're only showing in non-doing status
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Display assignments for each role with actual designations

                    // Replace Active Personnel IDs with Active Personnel Names and Designations
                    if (isDoingStatus &&
                        project['assignedStaff'] != null &&
                        project['assignedStaff'] is List &&
                        (project['assignedStaff'] as List).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Text(
                        "Active Personnel Details",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // SOLUTION: Better handling of missing staff details
                      FutureBuilder<Widget>(
                        future:
                            _buildAssignedStaffWidgets(project, staffDetails),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          return snapshot.data ?? const SizedBox.shrink();
                        },
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Additional project details
                if (project['address'] != null) ...[
                  _buildInfoRow(
                    "Location",
                    project['address'],
                    Icons.location_on,
                  ),
                ],
                if (project['lastUpdated'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Last updated: ${_formatDate(project['lastUpdated'])}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SOLUTION: New method to build assigned staff widgets with data fetching if needed
  Future<Widget> _buildAssignedStaffWidgets(Map<String, dynamic> project,
      Map<String, Map<String, String>> staffDetails) async {
    List<Widget> staffWidgets = [];
    final assignedStaff = project['assignedStaff'] as List;

    for (int index = 0; index < assignedStaff.length; index++) {
      final staffId = assignedStaff[index].toString();
      Map<String, String>? staffInfo = staffDetails[staffId];

      // If staff info doesn't exist in the predefined map, fetch it from Firestore
      if (staffInfo == null) {
        staffInfo = await _fetchEmployeeDetails(staffId);
        // Add to staffDetails map for future reference
        if (staffInfo != null) {
          staffDetails[staffId] = staffInfo;
        } else {
          // Use default values if fetching fails
          staffInfo = {'name': 'Unknown', 'designation': 'Staff'};
        }
      }

      staffWidgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getDesignationIcon(staffInfo['designation']!, Icons.person),
                size: 14,
                color: _getDesignationColor(staffInfo['designation']!),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    staffInfo['name']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staffInfo['designation']!,
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: staffWidgets);
  }

  // SOLUTION: New method to fetch employee details from Firestore
  Future<Map<String, String>?> _fetchEmployeeDetails(String employeeId) async {
    try {
      // Get a reference to the employee document
      final employeeDoc = await FirebaseFirestore.instance
          .collection('Employees')
          .doc(employeeId)
          .get();

      if (employeeDoc.exists) {
        final data = employeeDoc.data();
        return {
          'name': data?['name'] ?? 'Unknown',
          'designation': data?['designation'] ?? 'Staff'
        };
      }
      return null;
    } catch (e) {
      print('Error fetching employee details: $e');
      return null;
    }
  }

// Enhanced role badge that displays the actual designation
  Widget _buildRoleBadge(String designation, String name, bool isAssigned,
      IconData icon, bool isActive) {
    // Get appropriate color based on designation type rather than fixed role
    Color roleColor = _getDesignationColor(designation);

    // Enhance elevation and color for active members in "doing" projects
    final elevation = isActive ? 4.0 : 0.0;
    final bgOpacity = isActive ? 0.25 : 0.15;
    final borderWidth = isActive ? 1.5 : 1.0;

    return Material(
      elevation: isAssigned ? elevation : 0,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isAssigned
              ? roleColor.withOpacity(bgOpacity)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isAssigned ? roleColor.withOpacity(0.5) : Colors.grey.shade300,
            width: borderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getDesignationIcon(designation, icon),
              size: 16,
              color: isAssigned ? roleColor : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  designation,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isAssigned ? roleColor : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isAssigned ? FontWeight.w500 : FontWeight.w400,
                    color: isAssigned ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            if (isAssigned) ...[
              const SizedBox(width: 6),
              Icon(
                isActive ? Icons.engineering : Icons.check_circle,
                size: 14,
                color: roleColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper method to get color based on actual designation
  Color _getDesignationColor(String designation) {
    switch (designation.toLowerCase()) {
      case 'sales employee':
      case 'sales':
        return Colors.purple;
      case 'engineer':
        return Colors.blue;
      case 'site supervisor':
        return Colors.orange;
      case 'electrician':
        return Colors.amber;
      case 'technician':
        return Colors.green;
      case 'project manager':
        return Colors.teal;
      default:
        return AppTheme.buildingBlue;
    }
  }

  // Helper method to get appropriate icon based on designation
  IconData _getDesignationIcon(String designation, IconData defaultIcon) {
    switch (designation.toLowerCase()) {
      case 'sales employee':
      case 'sales':
        return Icons.person;
      case 'engineer':
        return Icons.engineering;
      case 'site supervisor':
        return Icons.supervisor_account;
      case 'electrician':
        return Icons.electric_bolt;
      case 'technician':
        return Icons.build;
      case 'project manager':
        return Icons.manage_accounts;
      default:
        return defaultIcon; // Use the provided default if no matching designation
    }
  }

  // Helper method to format dates consistently
  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());
    }
    return 'Date unavailable';
  }

  // Helper widget for showing assignment info with indicator for assignment status
  Widget _buildAssigneeInfo(
      String role, String name, bool isAssigned, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isAssigned ? AppTheme.buildingBlue : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            "$role: ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isAssigned ? Colors.black87 : Colors.grey.shade500,
                fontWeight: isAssigned ? FontWeight.w500 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isAssigned)
            Icon(
              Icons.check_circle,
              size: 16,
              color: AppTheme.primaryGreen,
            ),
        ],
      ),
    );
  }

  // Helper widget for showing general information rows
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'doing':
        return Colors.blue;
      case 'not completed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'doing':
        return Icons.sync;
      case 'not completed':
        return Icons.cancel;
      case 'pending':
        return Icons.pending_actions;
      default:
        return Icons.help;
    }
  }

  // Helper method to get status text
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'doing':
        return 'Doing';
      case 'not completed':
        return 'Not Completed';
      case 'pending':
        return 'Pending';
      default:
        return 'Unknown';
    }
  }

  // Helper method to get progress color
  Color _getProgressColor(int progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }
}
