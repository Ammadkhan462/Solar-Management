import 'dart:async';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:admin/app/modules/EmployeeDashboard/views/projectdetails.dart'
    show ProjectDetailsScreen;
import 'package:admin/app/modules/EmployeeDashboard/views/sitesupervisor.dart';
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

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  EmployeeDashboardView({super.key});
  final EmployeeDashboardController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.buildingBlue,
        elevation: 0,
        title: Obx(
          () => Text(
            '${_controller.employee.value.designation} Dashboard',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Get.offAllNamed(Routes.LOGIN_CHOICE);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value ||
            _controller.employee.value.uid.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          fit: StackFit.expand, // This makes the Stack fill its parent

          children: [
            // Background with triangle shape at corner
            // Place this within your Stack widget
            // Replace your current Positioned widget with this:
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height *
                  0.1, // 30% of screen height
              child: CustomPaint(
                painter: BottomWavePainter(),
              ),
            ),

            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section with name and role
                    _buildWelcomeCard(),

                    const SizedBox(height: 24),

                    // Role-specific content
                    if (_controller.isSalesEmployee)
                      _buildSalesEmployeeContent(),
                    if (_controller.isEngineer) _buildEngineerContent(),
                    if (_controller.isSiteSupervisor)
                      _buildSiteSupervisorContent(),
                    if (_controller.isProjectManager)
                      _buildProjectManagerContent(),
                    if (_controller.isElectrician || _controller.isTechnician)
                      _buildTechnicianContent(),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Build Engineer specific dashboard content
  Widget _buildEngineerContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Assigned Projects",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (_controller.assignedProjects.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.engineering,
                      size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "No projects assigned yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.assignedProjects.length,
            itemBuilder: (context, index) {
              final project = _controller.assignedProjects[index];
              final progress = project['progress'] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(project['projectName'] ?? 'No Name'),
                      subtitle: Text(
                          "Client: ${project['clientName'] ?? 'Not specified'}"),
                      trailing: const Icon(Icons.build),
                      onTap: () {
                        final status = project['status'] ?? 'pending';

                        if (status == 'pending') {
                          // If project is pending, show project details screen
                          Get.to(() =>
                              ProjectDetailsScreen(projectId: project['id']));
                        } else if (status == 'doing') {
                          // If project is in progress, show task completion screen
                          Get.to(() =>
                              TaskCompletionScreen(projectId: project['id']));
                        } else {
                          // For other statuses, default to project details
                          Get.to(() =>
                              ProjectDetailsScreen(projectId: project['id']));
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Progress: $progress%"),
                              Text("Status: ${project['status'] ?? 'pending'}"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getProgressColor(progress),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  // Engineer project card
  Widget _buildEngineerProjectCard(
      Map<String, dynamic> project, int progress, String status) {
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
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (status == 'pending') {
              // If project is pending, show project details screen
              Get.to(() => ProjectDetailsScreen(projectId: project['id']));
            } else if (status == 'doing') {
              // If project is in progress, show task completion screen
              Get.to(() => TaskCompletionScreen(projectId: project['id']));
            } else {
              // For other statuses, default to project details
              Get.to(() => ProjectDetailsScreen(projectId: project['id']));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.buildingBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.build,
                        color: AppTheme.buildingBlue,
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
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress: $progress%",
                      style: const TextStyle(fontWeight: FontWeight.w500),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Beautiful welcome card with gradient and shadow
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.buildingBlue,
            AppTheme.buildingBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              _controller.employee.value.name.isNotEmpty
                  ? _controller.employee.value.name[0].toUpperCase()
                  : "?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.buildingBlue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${_controller.employee.value.name}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Role: ${_controller.employee.value.designation}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Build Sales Employee specific dashboard content
  Widget _buildSalesEmployeeContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildSectionHeader(
        "Your Projects",
        icon: Icons.business_center,
        actionButton: ElevatedButton.icon(
          onPressed: () => Get.to(() => SalesEmployeeForm()),
          icon: const Icon(Icons.add),
          label: const Text('New Project'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
        ),
      ),

      const SizedBox(height: 16),

      // Debug info - remove in production
      Obx(() {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final filteredProjects = _controller.createdProjects
            .where((project) => project['salesEmployeeId'] == currentUserId)
            .toList();

        return CommonText(
          text: "Your projects: ${filteredProjects.length}",
          style: AppTypography.small.copyWith(color: Colors.grey),
        );
      }),

      const SizedBox(height: 8),

      // Project list with refresh indicator
      RefreshIndicator(
        onRefresh: () async {
          // Force refresh the data
          _controller.setupSalesProjectsListener();
        },
        child: Obx(
          () {
            // Filter the projects to show only those created by the current sales employee
            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
            final filteredProjects = _controller.createdProjects
                .where((project) => project['salesEmployeeId'] == currentUserId)
                .toList();

            if (filteredProjects.isEmpty) {
              return Container(
                height: 200, // Minimum height for RefreshIndicator to work
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open,
                              size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          CommonText(
                            text: "No projects created yet",
                            style: AppTypography.medium.copyWith(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = filteredProjects[index];
                  final status = project['status'] ?? 'pending';

                  return _buildProjectCard(project, status);
                });
          },
        ),
      )
    ]);
  }

  // Beautiful project card with improved styling
  Widget _buildProjectCard(Map<String, dynamic> project, String status) {
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
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (project.containsKey('id')) {
              Get.to(() => ProjectDetailsScreen(projectId: project['id']));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          CommonText(
                            text: project['projectName'] ?? 'No Name',
                            style: AppTypography.medium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CommonText(
                            text:
                                "Client: ${project['clientName'] ?? 'Not specified'}",
                            style: AppTypography.small.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CommonText(
                        text: _getStatusText(status),
                        style: AppTypography.small.copyWith(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section header with icon
  Widget _buildSectionHeader(String title,
      {IconData? icon, Widget? actionButton}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: AppTheme.deepBlack,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            CommonText(
              text: title,
              style: AppTypography.subheading.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepBlack,
              ),
            ),
          ],
        ),
        if (actionButton != null) actionButton,
      ],
    );
  }

  // Helper method to get status text
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'doing':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'doing':
        return Icons.engineering;
      case 'completed':
        return Icons.task_alt;
      default:
        return Icons.help_outline;
    }
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return AppTheme.primaryGreen;
      case 'doing':
        return AppTheme.buildingBlue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Helper method for progress color
  Color _getProgressColor(int progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return AppTheme.primaryGreen;
  }

  // Build Engineer specific dashboard content

// Update site supervisor content navigation logic
  Widget _buildSiteSupervisorContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Site Projects",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (_controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_controller.assignedProjects.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.location_city,
                      size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "No site projects assigned",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.assignedProjects.length,
            itemBuilder: (context, index) {
              final project = _controller.assignedProjects[index];
              final status = project['status'] ?? 'pending';

              return Card(
                color: _getStatusColor(status),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(project['projectName'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: $status"),
                      if (project['address'] != null)
                        Text("Location: ${project['address']}"),
                      if (project['lastUpdated'] != null)
                        Text(
                          "Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format((project['lastUpdated'] as Timestamp).toDate())}",
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Updated navigation logic
                    if (status == 'doing') {
                      // Only "doing" status goes to task completion
                      Get.to(
                          () => TaskCompletionScreen(projectId: project['id']));
                    } else {
                      // For all other statuses (pending, approved, completed), go to project details
                      Get.to(() => ProjectDetailsScreen(
                            projectId: project['id'],
                          ));
                    }
                  },
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildProjectManagerContent() {
    void _autoLoadProjectsData() {
      // Only auto-load once per session
      if (_controller.autoLoadedProjects) return;

      final managerId = _controller.employee.value.managerId;
      if (managerId != null && managerId.isNotEmpty) {
        // Set flag to prevent multiple auto-loads
        _controller.autoLoadedProjects = true;

        // Load the projects data
        _controller.isLoading.value = true;
        _controller
            .fetchAllProjectsWithSameManager(managerId)
            .catchError((error) {
          print("Error auto-loading projects: $error");
          // Don't show error messages during auto-load to avoid confusing the user
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoLoadProjectsData();
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
            if (_controller.isLoading.value) {
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
            final filteredProjects =
                _controller.getFilteredProjectsForManager();

            if (filteredProjects.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Icon(Icons.folder_open,
                        size: 60, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      _controller.projectManagerTabIndex.value == 0
                          ? "No team projects found"
                          : "No ${_getTabName(_controller.projectManagerTabIndex.value).toLowerCase()} projects found",
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
    final managerId = _controller.employee.value.managerId;
    if (managerId != null && managerId.isNotEmpty) {
      // Don't show a separate dialog, just use the isLoading value
      _controller.isLoading.value = true;

      _controller.fetchAllProjectsWithSameManager(managerId).then((_) {
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
    final isSelected = _controller.projectManagerTabIndex.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.projectManagerTabIndex.value = index,
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

// Modified project card to show actual designations
  Widget _buildProjectManagerProjectCard(
      Map<String, dynamic> project, int progress, String status) {
    // Get employee names from the project data
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
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (project.containsKey('id')) {
              Get.to(() => ProjectDetailsScreen(projectId: project['id']));
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
                    Text(
                      "Team Assignment",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.buildingBlue,
                      ),
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
                        ),
                        _buildRoleBadge(
                          engineerDesignation,
                          engineerName,
                          hasEngineer,
                          Icons.engineering,
                        ),
                        _buildRoleBadge(
                          supervisorDesignation,
                          siteSupervisorName,
                          hasSiteSupervisor,
                          Icons.supervisor_account,
                        ),
                        _buildRoleBadge(
                          technicianDesignation,
                          technicianName,
                          hasTechnician,
                          Icons.build,
                        ),
                      ],
                    ),
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

  // Enhanced role badge that displays the actual designation
  Widget _buildRoleBadge(
      String designation, String name, bool isAssigned, IconData icon) {
    // Get appropriate color based on designation type rather than fixed role
    Color roleColor = _getDesignationColor(designation);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAssigned ? roleColor.withOpacity(0.15) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAssigned ? roleColor.withOpacity(0.5) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getDesignationIcon(
                designation, icon), // Get appropriate icon for the designation
            size: 16,
            color: isAssigned ? roleColor : Colors.grey.shade500,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                designation, // Use the actual designation
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
              Icons.check_circle,
              size: 14,
              color: roleColor,
            ),
          ],
        ],
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

  String _getActualDesignation(String roleField, Map<String, dynamic> project) {
    // Map to store the designation for each role field
    final designationMap = {
      'assignedEngineerId':
          project['assignedEngineerDesignation'] ?? 'Engineer',
      'salesEmployeeId':
          project['salesEmployeeDesignation'] ?? 'Sales Employee',
      'siteSupervisorId':
          project['siteSupervisorDesignation'] ?? 'Site Supervisor',
      'technicianId': project['technicianDesignation'] ?? 'Technician',
    };

    return designationMap[roleField] ?? 'Unknown';
  }

  // Build Technician/Electrician specific dashboard content
  Widget _buildTechnicianContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Tasks",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (_controller.assignedProjects.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.build_circle,
                      size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "No tasks assigned yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.assignedProjects.length,
            itemBuilder: (context, index) {
              final project = _controller.assignedProjects[index];
              final tasks = project['tasks'] as Map<String, dynamic>? ?? {};

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(project['projectName'] ?? 'No Name'),
                      subtitle: Text(
                          "Location: ${project['address'] ?? 'Not specified'}"),
                      trailing: Icon(
                        _controller.isElectrician
                            ? Icons.electrical_services
                            : Icons.handyman,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tasks:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...(_controller
                              .getProjectTasks()
                              .map((task) => CheckboxListTile(
                                    title: Text(task),
                                    value: tasks[task] == true,
                                    dense: true,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    onChanged: (bool? value) {
                                      if (value == true) {
                                        _controller.markTaskAsCompleted(
                                            project['id'], task);
                                      }
                                    },
                                  ))),
                          const SizedBox(height: 8),
                          // ElevatedButton.icon(
                          //   icon: const Icon(Icons.camera_alt),
                          //   label: const Text('Upload Task Verification'),
                          //   onPressed: () => Get.to(() => TaskVideoUploadScreen(projectId: project['id'])),
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.green,
                          //     foregroundColor: Colors.white,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
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
  // Your existing properties
  final fullName = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final address = ''.obs;
  final propertyType = ''.obs;
  final solarType = ''.obs;
  final solarCapacity = ''.obs;
  final structureType = ''.obs;
  final engineerAssigned = ''.obs;
  final preferredDay = ''.obs;
  final preferredTime = ''.obs;
  final isSubmitting = false.obs;
  final availableEngineers = <Map<String, dynamic>>[].obs;
  var locationPinUrl = ''.obs; // Added new property for location pin URL

  // Add current employee data
  final currentEmployee = Rx<Employee?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchCurrentEmployeeData().then((_) => fetchAvailableEngineers());
  }

  Future<void> fetchCurrentEmployeeData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "User not logged in.");
        return;
      }

      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection("Employees")
          .doc(currentUser.uid)
          .get();

      if (employeeDoc.exists) {
        final data = employeeDoc.data() as Map<String, dynamic>;
        currentEmployee.value = Employee(
          uid: employeeDoc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          password: data['password'] ?? '',
          role: data['role'] ?? '',
          designation: data['designation'] ?? '',
          managerId: data['managerId'] ?? '',
        );

        print(
            "Current employee fetched, manager ID: ${currentEmployee.value?.managerId}");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch employee data: $e");
    }
  }

  void fetchAvailableEngineers() async {
    try {
      if (currentEmployee.value == null ||
          currentEmployee.value!.managerId == null ||
          currentEmployee.value!.managerId!.isEmpty) {
        print(
            "Cannot fetch engineers: Current employee or manager ID is null or empty");
        Get.snackbar("Error",
            "Unable to fetch engineers. Manager information not available.");
        return;
      }

      // Get the current sales employee's manager ID
      final String managerIdToMatch = currentEmployee.value!.managerId!;
      print("Fetching employees with manager ID: $managerIdToMatch");

      // Query all employees with the same manager ID
      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection("Employees")
          .where("managerId", isEqualTo: managerIdToMatch)
          .get();

      print("Query returned ${employeeSnapshot.docs.length} total employees");

      // Log all returned employees for debugging
      for (var doc in employeeSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print(
            "Employee: ${doc.id}, name: ${data['name']}, designation: ${data['designation']}");
      }

      // Define roles to exclude
      final List<String> excludedRoles = [
        "Sales",
        "Sales Employee",
        "Project Manager",
        "Technician"
      ];

      // Filter out excluded roles
      List<QueryDocumentSnapshot> filteredEmployees =
          employeeSnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final designation = data['designation'] as String?;

        // Keep employees whose designation is not in the excluded list
        return designation != null && !excludedRoles.contains(designation);
      }).toList();

      print(
          "Found ${filteredEmployees.length} eligible employees after filtering");

      if (filteredEmployees.isEmpty) {
        print(
            "No eligible employees found with matching manager ID: $managerIdToMatch");
        Get.snackbar("Info",
            "No available engineers found for assignment. Please contact your manager.");
      }

      // Map the filtered employees
      availableEngineers.value = filteredEmployees.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'uid': doc.id,
          'name': data['name'] ?? 'Unknown Employee',
          'designation': data['designation'] ?? 'No Role',
        };
      }).toList();

      print(
          "Final availableEngineers list: ${availableEngineers.length} employees");
      print(
          "Available engineers: ${availableEngineers.map((e) => '${e['name']} (${e['designation']})').join(', ')}");
    } catch (e) {
      print("Error fetching employees: $e");
      Get.snackbar("Error", "Failed to fetch employees: $e");
    }
  }

  void submitForm() async {
    if (validateForm()) {
      try {
        isSubmitting.value = true;

        // Get current user (sales employee)
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          Get.snackbar("Error", "User not logged in.");
          return;
        }

        // Create new project in Firestore
        DocumentReference projectRef =
            await FirebaseFirestore.instance.collection("Projects").add({
          'projectName':
              'Solar Installation - ${fullName.value}', // Generate a project name
          'clientName': fullName.value,
          'clientEmail': email.value,
          'clientPhone': phone.value,
          'address': address.value,
          'locationPinUrl':
              locationPinUrl.value, // Include the new pin URL field

          'propertyType': propertyType.value,
          'solarType': solarType.value,
          'solarCapacity': solarCapacity.value,
          'structureType': structureType.value,
          'assignedEngineerId': engineerAssigned.value,
          'preferredDay': preferredDay.value,
          'preferredTime': preferredTime.value,
          'salesEmployeeId': currentUser.uid,
          'managerId': currentEmployee
              .value?.managerId, // Include the manager ID for filtering
          'status': 'pending',
          'progress': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'tasks': {
            'Structure': false,
            'Panel Installation': false,
            'Inverter installation': false,
            'Wiring': false,
            'Completion': false,
          },
          'taskVideos': {},
        });

        // Show success message
        Get.snackbar(
          "Success",
          "Project created successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Force reload the dashboard controller if it exists
        if (Get.isRegistered<EmployeeDashboardController>()) {
          final dashboardController = Get.find<EmployeeDashboardController>();
          dashboardController.setupSalesProjectsListener();
        }

        // Navigate back to the dashboard
        Get.offAllNamed(Routes.EMPLOYEE_DASHBOARD);
      } catch (e) {
        Get.snackbar("Error", "Failed to submit form: $e");
      } finally {
        isSubmitting.value = false;
      }
    }
  }

  bool validateForm() {
    if (fullName.value.isEmpty) {
      Get.snackbar("Error", "Please enter client name");
      return false;
    }
    if (email.value.isEmpty) {
      Get.snackbar("Error", "Please enter email");
      return false;
    }
    if (phone.value.isEmpty) {
      Get.snackbar("Error", "Please enter phone number");
      return false;
    }
    if (address.value.isEmpty) {
      Get.snackbar("Error", "Please enter installation address");
      return false;
    }
    if (propertyType.value.isEmpty) {
      Get.snackbar("Error", "Please select property type");
      return false;
    }
    if (solarType.value.isEmpty) {
      Get.snackbar("Error", "Please select solar system type");
      return false;
    }
    if (engineerAssigned.value.isEmpty) {
      Get.snackbar("Error", "Please assign an engineer");
      return false;
    }
    return true;
  }
}

class SalesEmployeeForm extends StatelessWidget {
  final SalesEmployeeFormController controller =
      Get.put(SalesEmployeeFormController());

  SalesEmployeeForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CommonText(
          text: "New Client Consultation",
          style: AppTypography.bold.copyWith(
            color: AppTheme.buildingBlue,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.deepBlack),
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 100.0),
            child: Obx(() {
              if (controller.isSubmitting.value) {
                return SizedBox(
                  height: screenHeight * 0.8,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.buildingBlue),
                        const SizedBox(height: 16),
                        CommonText(text: "Submitting your request..."),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                      "Step 1: Client Information", Icons.person),
                  _buildTextField(
                    controller: null,
                    onChanged: (value) => controller.fullName.value = value,
                    labelText: "Client Full Name",
                    icon: Icons.person_outline,
                  ),
                  _buildTextField(
                    controller: null,
                    onChanged: (value) => controller.email.value = value,
                    labelText: "Email Address",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: null,
                    onChanged: (value) => controller.phone.value = value,
                    labelText: "Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                      "Step 2: Installation Details", Icons.location_on),
                  _buildTextField(
                    controller: null,
                    onChanged: (value) => controller.address.value = value,
                    labelText: "Installation Address",
                    icon: Icons.home_outlined,
                    maxLines: 2,
                  ),
                  _buildTextField(
                    controller: null,
                    onChanged: (value) =>
                        controller.locationPinUrl.value = value,
                    labelText: "Pin URL Location (Optional)",
                    icon: Icons.location_on,
                    hintText: "Paste map link here",
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    labelText: "Property Type",
                    value: controller.propertyType.value.isEmpty
                        ? null
                        : controller.propertyType.value,
                    items: [
                      'Residential',
                      'Commercial',
                      'Industrial',
                      'Agricultural'
                    ],
                    onChanged: (newValue) =>
                        controller.propertyType.value = newValue!,
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                      "Step 3: Solar System Details", Icons.solar_power),
                  _buildDropdownField(
                    labelText: "System Type",
                    value: controller.solarType.value.isEmpty
                        ? null
                        : controller.solarType.value,
                    items: ['Hybrid', 'On-grid', 'Off-grid'],
                    onChanged: (newValue) =>
                        controller.solarType.value = newValue!,
                    icon: Icons.electrical_services,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: null,
                    onChanged: (value) =>
                        controller.solarCapacity.value = value,
                    labelText: "Solar Capacity (kW)",
                    icon: Icons.bolt,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    labelText: "Structure Type",
                    value: controller.structureType.value.isEmpty
                        ? null
                        : controller.structureType.value,
                    items: [
                      'Elevated',
                      'Ground-mounted',
                      'Roof-mounted',
                      'Other'
                    ],
                    onChanged: (newValue) =>
                        controller.structureType.value = newValue!,
                    icon: Icons.architecture,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                      "Step 4: Engineer Assignment", Icons.engineering),
                  Obx(() => _buildEngineerDropdown(
                        engineers: controller.availableEngineers.value,
                        selectedValue: controller.engineerAssigned.value,
                        onChanged: (newValue) =>
                            controller.engineerAssigned.value = newValue!,
                      )),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                      "Step 5: Schedule Consultation", Icons.calendar_today),
                  _buildDropdownField(
                    labelText: "Preferred Day",
                    value: controller.preferredDay.value.isEmpty
                        ? null
                        : controller.preferredDay.value,
                    items: [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday'
                    ],
                    onChanged: (newValue) =>
                        controller.preferredDay.value = newValue!,
                    icon: Icons.event,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    labelText: "Preferred Time",
                    value: controller.preferredTime.value.isEmpty
                        ? null
                        : controller.preferredTime.value,
                    items: [
                      'Morning (9am-12pm)',
                      'Afternoon (12pm-5pm)',
                      'Evening (5pm-8pm)'
                    ],
                    onChanged: (newValue) =>
                        controller.preferredTime.value = newValue!,
                    icon: Icons.access_time,
                  ),
                  const SizedBox(height: 40),
                ],
              );
            }),
          ),

          // Top wave effect

          // Submit button at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: CommonButton(
                text: "Submit Consultation Request",
                onPressed: controller.submitForm,
                isPrimary: true,
                color: AppTheme.buildingBlue,
                icon: Icons.send,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for UI components
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.buildingBlue, size: 22),
          const SizedBox(width: 8),
          CommonText(
            text: title,
            style: AppTypography.semiBold.copyWith(
              fontSize: 16,
              color: AppTheme.deepBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController? controller,
    required Function(String) onChanged,
    required String labelText,
    required IconData icon,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon, color: AppTheme.buildingBlue.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppTheme.lightGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppTheme.buildingBlue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppTheme.lightGray),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightGray),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.buildingBlue.withOpacity(0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  hint: Text(
                    "Select $labelText",
                    style: AppTypography.regular.copyWith(
                      color: AppTheme.deepBlack.withOpacity(0.5),
                    ),
                  ),
                  isExpanded: true,
                  items: items.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: AppTypography.regular.copyWith(
                          color: AppTheme.deepBlack,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineerDropdown({
    required List<Map<String, dynamic>> engineers,
    required String selectedValue,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightGray),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.engineering,
                color: AppTheme.buildingBlue.withOpacity(0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedValue.isEmpty ? null : selectedValue,
                  hint: Text(
                    "Select Engineer",
                    style: AppTypography.regular.copyWith(
                      color: AppTheme.deepBlack.withOpacity(0.5),
                    ),
                  ),
                  isExpanded: true,
                  items: engineers.map((engineer) {
                    return DropdownMenuItem<String>(
                      value: engineer['uid'],
                      child: Text(
                        engineer['name'],
                        style: AppTypography.regular.copyWith(
                          color: AppTheme.deepBlack,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
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

class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define colors - main blue from AppTheme and an accent green
    final bluePaint = Paint()
      ..color = AppTheme.buildingBlue
      ..style = PaintingStyle.fill;

    final greenPaint = Paint()
      ..color = AppTheme.primaryGreen // Bright green color
      ..style = PaintingStyle.fill;

    // Blue wave path (background wave)
    final bluePath = Path();
    bluePath.moveTo(0, size.height);

    // Start point at consistent height
    bluePath.lineTo(0, size.height * 0.5);

    // Create evenly spaced wave points across the width
    bluePath.cubicTo(
      size.width * 0.25, size.height * 0.3, // First control point
      size.width * 0.5, size.height * 0.6, // Second control point
      size.width * 0.75, size.height * 0.3, // Third control point
    );

    // End point at same height as start point for symmetry
    bluePath.lineTo(size.width, size.height * 0.5);
    bluePath.lineTo(size.width, size.height);
    bluePath.close();

    // Green wave path - precisely offset from blue wave
    final greenPath = Path();
    greenPath.moveTo(0, size.height);

    // Start at consistent offset from blue wave
    greenPath.lineTo(0, size.height * 0.6);

    // Create evenly spaced wave points with consistent offset from blue wave
    greenPath.cubicTo(
      size.width * 0.25, size.height * 0.4, // First control point
      size.width * 0.5, size.height * 0.7, // Second control point
      size.width * 0.75, size.height * 0.4, // Third control point
    );

    // End at consistent offset from blue wave end point
    greenPath.lineTo(size.width, size.height * 0.6);
    greenPath.lineTo(size.width, size.height);
    greenPath.close();

    // Draw paths in order - blue wave first, then green wave on top
    canvas.drawPath(bluePath, bluePaint);
    canvas.drawPath(greenPath, greenPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TeamMember {
  final String designation;
  final String name;
  final bool isAssigned;
  final String id;

  TeamMember({
    required this.designation,
    required this.name,
    required this.isAssigned,
    required this.id,
  });
}
