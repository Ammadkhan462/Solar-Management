import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/manager_panel_controller.dart';

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

  // Categories of staff
  final List<String> staffCategories = [
    'Engineer',
    'Technician',
    'Site Supervisor',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _fetchAvailableStaff();
  }

  Future<void> _fetchAvailableStaff() async {
    try {
      setState(() => _isLoading = true);
      final managerId = _managerController.manager.value.uid;
      final employeesSnapshot = await _firestore
          .collection('Employees')
          .where('managerId', isEqualTo: managerId)
          .get();

      final Map<String, List<Map<String, dynamic>>> tempGroup = {};

      // Initialize all categories even if they don't have members
      for (final category in staffCategories) {
        tempGroup[category] = [];
      }

      for (final doc in employeesSnapshot.docs) {
        final employee = doc.data();
        final isAvailable = await _checkEmployeeAvailability(doc.id);

        if (isAvailable) {
          // Default to 'Other' if designation isn't one of our categories
          String designation = employee['designation'] ?? 'Other';
          if (!staffCategories.contains(designation)) {
            designation = 'Other';
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
      Get.snackbar("Error", "Please select at least one team member");
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Update project with selected staff and dates
      await _firestore.collection('Projects').doc(widget.projectId).update({
        'assignedStaff': FieldValue.arrayUnion(selectedStaff),
        'status':
            'doing', // Change project status to "doing" after staff assignment
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

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Success message
      Get.snackbar(
        "Success",
        "Team members assigned successfully! Project updated to 'doing'.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to Manager Panel using GetX navigation
      // This is the fixed part - using GetX navigation pattern to match the rest of the app
      Get.offAllNamed(Routes.MANAGER_PANEL);
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Get.snackbar(
        "Error",
        "Failed to assign team members: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CommonText(
          text: 'Assign Team Members',
          style: AppTypography.semiBold,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedStaff.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      CommonText(
                        text: 'No available team members',
                        style: AppTypography.regular,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.grey[100],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            text: 'Project Timeline',
                            style: AppTypography.semiBold,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        text: 'Start Date',
                                        style: AppTypography.regular,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 4),
                                      CommonText(
                                        text: DateFormat('dd MMM, yyyy')
                                            .format(widget.startDate),
                                        style: AppTypography.regular,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CommonText(
                                        text: 'End Date',
                                        style: AppTypography.regular,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 4),
                                      CommonText(
                                        text: DateFormat('dd MMM, yyyy')
                                            .format(widget.endDate),
                                        style: AppTypography.regular,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: staffCategories.length,
                        itemBuilder: (context, index) {
                          final category = staffCategories[index];
                          final staffInCategory = groupedStaff[category] ?? [];

                          if (staffInCategory.isEmpty) {
                            return Container(); // Skip empty categories
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ExpansionTile(
                              title: Row(
                                children: [
                                  _getCategoryIcon(category),
                                  const SizedBox(width: 12),
                                  CommonText(
                                    text: category,
                                    style: AppTypography.medium,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: CommonText(
                                      text: '${staffInCategory.length}',
                                      style: AppTypography.small,
                                    ),
                                  ),
                                ],
                              ),
                              children: staffInCategory.map((staff) {
                                final isSelected =
                                    selectedStaff.contains(staff['uid']);
                                return CheckboxListTile(
                                  title: CommonText(
                                    text: staff['name'] ?? 'Unnamed',
                                    style: AppTypography.regular,
                                  ),
                                  subtitle: staff['email'] != null
                                      ? CommonText(
                                          text: staff['email'],
                                          style: AppTypography.small,
                                          color: Colors.grey[600],
                                        )
                                      : null,
                                  value: isSelected,
                                  activeColor: AppColors.primary,
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
                            ),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CommonButton(
                          text: 'Assign Team Members',
                          onPressed: _assignStaff,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'Engineer':
        return Icon(Icons.engineering, color: AppColors.primary);
      case 'Technician':
        return Icon(Icons.build, color: AppColors.primary);
      case 'Site Supervisor':
        return Icon(Icons.visibility, color: AppColors.primary);
      default:
        return Icon(Icons.person, color: AppColors.primary);
    }
  }
}
