import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:admin/app/modules/EmployeesRegistration/views/employees_registration_view.dart';
import 'package:admin/app/modules/ManagerPanel/views/manager_panel_view.dart';
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

class ProjectCreationScreen extends StatefulWidget {
  final Map<String, dynamic>? existingProject;

  const ProjectCreationScreen({Key? key, this.existingProject})
      : super(key: key);

  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  int _currentStep = 0;
  final ScrollController _scrollController = ScrollController();

  // Panel Information
  String pvModule = '';
  String brand = '';
  String size = '';
  String pricePerWatt = '';
  String panelQuantity = '';
  double _totalKw = 0.0;

  // Inverter Information
  String inverterType = '';
  String kwSize = '';
  String inverterBrand = '';
  String inverterPrice = '';
  String inverterQuantity = '';

  // Structure Information
  String structureType = '';
  String structurePrice = '';

  // Wire Information
  String wireSize = '';
  String wireLength = '';
  String wirePricePerMeter = '';

  // Breaker Information
  List<String> selectedBreakers = [];
  Map<String, String> breakerPrices = {};
  Map<String, String> breakerQuantities = {};

  // Earthing Information
  List<String> selectedEarthing = [];
  Map<String, String> earthingPrices = {};
  Map<String, String> earthingQuantities = {};

  // Casing Information
  List<String> selectedCasing = [];
  Map<String, String> casingPrices = {};
  Map<String, String> casingQuantities = {};

  // Battery Information
  bool installBattery = false;
  String batteryType = '';
  String batteryBrand = '';
  String batteryQuantity = '';
  String batteryPrice = '';

  // Project Dates
  String? startDate;
  String? endDate;

  // Project Data
  Map<String, dynamic> projectData = {};

  @override
  void initState() {
    super.initState();
    if (widget.existingProject != null) {
      _loadExistingProjectData();
    }
  }
// Modify the _loadExistingProjectData method in _ProjectCreationScreenState class
// in the ProjectCreationScreen.dart file

  void _loadExistingProjectData() {
    final project = widget.existingProject!;

    // Load Panel Info
    pvModule = project['pvModule'] ?? '';
    brand = project['brand'] ?? '';
    size = project['size'] ?? '';
    pricePerWatt = project['pricePerWatt'] ?? '';
    panelQuantity = project['panelQuantity'] ?? '';

    // Load Inverter Info
    inverterType = project['inverterType'] ?? '';
    kwSize = project['kwSize'] ?? '';
    inverterBrand = project['inverterBrand'] ?? '';
    inverterPrice = project['inverterPrice'] ?? '';
    inverterQuantity = project['inverterQuantity'] ?? '';

    // Load Structure Info
    structureType = project['structureType'] ?? '';
    structurePrice = project['structurePrice'] ?? '';

    // Load Wire Info
    wireSize = project['wireSize'] ?? '';
    wireLength = project['wireLength'] ?? '';
    wirePricePerMeter = project['wirePricePerMeter'] ?? '';

    // Load Breaker Info
    if (project['selectedBreakers'] != null) {
      selectedBreakers = List<String>.from(project['selectedBreakers']);
    }
    if (project['breakerPrices'] != null) {
      breakerPrices = Map<String, String>.from(project['breakerPrices']);
    }
    if (project['breakerQuantities'] != null) {
      breakerQuantities =
          Map<String, String>.from(project['breakerQuantities']);
    }

    // Load Earthing Info
    if (project['selectedEarthing'] != null) {
      selectedEarthing = List<String>.from(project['selectedEarthing']);
    }
    if (project['earthingPrices'] != null) {
      earthingPrices = Map<String, String>.from(project['earthingPrices']);
    }
    if (project['earthingQuantities'] != null) {
      earthingQuantities =
          Map<String, String>.from(project['earthingQuantities']);
    }

    // Load Casing Info
    if (project['selectedCasing'] != null) {
      selectedCasing = List<String>.from(project['selectedCasing']);
    }
    if (project['casingPrices'] != null) {
      casingPrices = Map<String, String>.from(project['casingPrices']);
    }
    if (project['casingQuantities'] != null) {
      casingQuantities = Map<String, String>.from(project['casingQuantities']);
    }

    // Load Battery Info
    installBattery = project['installBattery'] ?? false;
    batteryType = project['batteryType'] ?? '';
    batteryBrand = project['batteryBrand'] ?? '';
    batteryQuantity = project['batteryQuantity'] ?? '';
    batteryPrice = project['batteryPrice'] ?? '';

    // Load Project Dates - Fix for Timestamp issues
    // Properly handle Firestore Timestamp objects for dates
    if (project['startDate'] != null) {
      if (project['startDate'] is Timestamp) {
        Timestamp startTimestamp = project['startDate'] as Timestamp;
        DateTime startDateTime = startTimestamp.toDate();
        startDate = DateFormat('yyyy-MM-dd').format(startDateTime);
      } else if (project['startDate'] is String) {
        startDate = project['startDate'];
      }
    }

    if (project['endDate'] != null) {
      if (project['endDate'] is Timestamp) {
        Timestamp endTimestamp = project['endDate'] as Timestamp;
        DateTime endDateTime = endTimestamp.toDate();
        endDate = DateFormat('yyyy-MM-dd').format(endDateTime);
      } else if (project['endDate'] is String) {
        endDate = project['endDate'];
      }
    }

    // Calculate Total KW
    _calculateTotalKw();
  }

// Also update the method that saves project data to handle dates properly

  Future<void> _saveProjectData() async {
    try {
      // Get reference to the Firebase project
      final projectRef = FirebaseFirestore.instance
          .collection('projects')
          .doc(widget.existingProject!['id']);

      // Prepare the data to update
      Map<String, dynamic> projectData = {
        'pvModule': pvModule,
        'brand': brand,
        'size': size,
        'pricePerWatt': pricePerWatt,
        'panelQuantity': panelQuantity,
        'totalKw': _totalKw,

        'inverterType': inverterType,
        'kwSize': kwSize,
        'inverterBrand': inverterBrand,
        'inverterPrice': inverterPrice,
        'inverterQuantity': inverterQuantity,

        'structureType': structureType,
        'structurePrice': structurePrice,

        'wireSize': wireSize,
        'wireLength': wireLength,
        'wirePricePerMeter': wirePricePerMeter,

        'selectedBreakers': selectedBreakers,
        'breakerPrices': breakerPrices,
        'breakerQuantities': breakerQuantities,

        'selectedEarthing': selectedEarthing,
        'earthingPrices': earthingPrices,
        'earthingQuantities': earthingQuantities,

        'selectedCasing': selectedCasing,
        'casingPrices': casingPrices,
        'casingQuantities': casingQuantities,

        'installBattery': installBattery,
        'batteryType': batteryType,
        'batteryBrand': batteryBrand,
        'batteryQuantity': batteryQuantity,
        'batteryPrice': batteryPrice,

        // Store dates properly as Firestore Timestamps
        'startDate': startDate != null
            ? Timestamp.fromDate(DateTime.parse(startDate!))
            : null,
        'endDate': endDate != null
            ? Timestamp.fromDate(DateTime.parse(endDate!))
            : null,

        'status': 'progress',
        'updatedAt': Timestamp.now(),
      };

      // Update the document
      await projectRef.update(projectData);

      // Show success message
      Get.snackbar(
        'Success',
        'Project details saved successfully',
        backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
        colorText: AppColors.primaryGreen,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate back to manager panel
      Get.offAll(() => const ManagerPanelView());
    } catch (e) {
      print('Error saving project data: $e');
      Get.snackbar(
        'Error',
        'Failed to save project details: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _calculateTotalKw() {
    if (size.isNotEmpty && panelQuantity.isNotEmpty) {
      try {
        double panelSizeWatts = double.parse(size);
        int quantity = int.parse(panelQuantity);
        _totalKw = (panelSizeWatts * quantity) / 1000;
        setState(() {});
      } catch (e) {
        _totalKw = 0.0;
      }
    } else {
      _totalKw = 0.0;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.deepBlack,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        if (isStartDate) {
          startDate = picked.toLocal().toString().split(' ')[0];
        } else {
          endDate = picked.toLocal().toString().split(' ')[0];
        }
      });
    }
  }

  List<Step> _buildSteps() {
    return [
      // Step 1: PV Module Type
      Step(
        title: CommonText(
          text: 'Solar Panel Type',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildPVModuleStep(),
        isActive: _currentStep >= 0,
        state: _currentStep == 0 ? StepState.editing : StepState.complete,
      ),

      // Step 2: Panel Brand & Size
      Step(
        title: CommonText(
          text: 'Panel Details',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildPanelDetailsStep(),
        isActive: _currentStep >= 1,
        state: _currentStep == 1 ? StepState.editing : StepState.complete,
      ),

      // Step 3: Panel Pricing & Quantity
      Step(
        title: CommonText(
          text: 'Panel Pricing',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildPanelPricingStep(),
        isActive: _currentStep >= 2,
        state: _currentStep == 2 ? StepState.editing : StepState.complete,
      ),

      // Step 4: Inverter Details
      Step(
        title: CommonText(
          text: 'Inverter Details',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildInverterDetailsStep(),
        isActive: _currentStep >= 3,
        state: _currentStep == 3 ? StepState.editing : StepState.complete,
      ),

      // Step 5: Structure Type
      Step(
        title: CommonText(
          text: 'Structure Type',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildStructureTypeStep(),
        isActive: _currentStep >= 4,
        state: _currentStep == 4 ? StepState.editing : StepState.complete,
      ),

      // Step 6: Wiring Details
      Step(
        title: CommonText(
          text: 'Wiring Details',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildWiringDetailsStep(),
        isActive: _currentStep >= 5,
        state: _currentStep == 5 ? StepState.editing : StepState.complete,
      ),

      // Step 7: Breaker Selection
      Step(
        title: CommonText(
          text: 'Breaker Selection',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildBreakerSelectionStep(),
        isActive: _currentStep >= 6,
        state: _currentStep == 6 ? StepState.editing : StepState.complete,
      ),

      // Step 8: Earthing Selection
      Step(
        title: CommonText(
          text: 'Earthing Selection',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildEarthingSelectionStep(),
        isActive: _currentStep >= 7,
        state: _currentStep == 7 ? StepState.editing : StepState.complete,
      ),

      // Step 9: Casing Selection
      Step(
        title: CommonText(
          text: 'Casing Selection',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildCasingSelectionStep(),
        isActive: _currentStep >= 8,
        state: _currentStep == 8 ? StepState.editing : StepState.complete,
      ),

      // Step 10: Battery Installation
      Step(
        title: CommonText(
          text: 'Battery Installation',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildBatteryInstallationStep(),
        isActive: _currentStep >= 9,
        state: _currentStep == 9 ? StepState.editing : StepState.complete,
      ),

      // Step 11: Project Dates
      Step(
        title: CommonText(
          text: 'Project Timeline',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildProjectDatesStep(),
        isActive: _currentStep >= 10,
        state: _currentStep == 10 ? StepState.editing : StepState.complete,
      ),

      // Step 12: Confirmation
      Step(
        title: CommonText(
          text: 'Confirmation',
          style: AppTypography.bold,
          color: AppColors.deepBlack,
        ),
        content: _buildConfirmationStep(),
        isActive: _currentStep >= 11,
        state: _currentStep == 11 ? StepState.editing : StepState.complete,
      ),
    ];
  }

  // Step content builders
  Widget _buildPVModuleStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: 'Select Solar Panel Type',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 16),
            _buildRadioOption('Mono', 'Mono', pvModule, (value) {
              setState(() => pvModule = value!);
            }),
            _buildRadioOption('Bi-Facial', 'Bi-Facial', pvModule, (value) {
              setState(() => pvModule = value!);
            }),
            _buildRadioOption('Poly', 'Poly', pvModule, (value) {
              setState(() => pvModule = value!);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelDetailsStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: 'Panel Brand',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 16),
            _buildRadioOption('Longi', 'Longi', brand, (value) {
              setState(() => brand = value!);
            }),
            _buildRadioOption('Jinko', 'Jinko', brand, (value) {
              setState(() => brand = value!);
            }),
            _buildRadioOption('JA Solar', 'JA Solar', brand, (value) {
              setState(() => brand = value!);
            }),
            _buildRadioOption('Trina', 'Trina', brand, (value) {
              setState(() => brand = value!);
            }),
            const SizedBox(height: 24),
            CommonText(
              text: 'Panel Size (Watts)',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 16),
            _buildRadioOption('580W', '580', size, (value) {
              setState(() {
                size = value!;
                _calculateTotalKw();
              });
            }),
            _buildRadioOption('585W', '585', size, (value) {
              setState(() {
                size = value!;
                _calculateTotalKw();
              });
            }),
            _buildRadioOption('610W', '610', size, (value) {
              setState(() {
                size = value!;
                _calculateTotalKw();
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelPricingStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: 'Panel Details Summary',
                        style: AppTypography.semiBold,
                        color: AppColors.buildingBlue,
                      ),
                      const SizedBox(height: 8),
                      if (brand.isNotEmpty && size.isNotEmpty)
                        CommonText(
                          text: '$brand $size W $pvModule',
                          style: AppTypography.medium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CommonText(
              text: 'Price per Watt (PKR)',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              initialValue: pricePerWatt,
              labelText: 'Price per Watt',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() => pricePerWatt = value);
              },
            ),
            const SizedBox(height: 16),
            CommonText(
              text: 'Number of Panels',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              initialValue: panelQuantity,
              labelText: 'Quantity',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  panelQuantity = value;
                  _calculateTotalKw();
                });
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: 'System Capacity',
                    style: AppTypography.semiBold,
                    color: AppColors.buildingBlue,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CommonText(
                        text: _totalKw.toStringAsFixed(2),
                        style: AppTypography.bold.copyWith(fontSize: 24),
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      CommonText(
                        text: 'kW',
                        style: AppTypography.medium,
                      ),
                    ],
                  ),
                  if (size.isNotEmpty && panelQuantity.isNotEmpty)
                    CommonText(
                      text: '($panelQuantity panels × $size W)',
                      style: AppTypography.regular,
                      color: AppColors.deepBlack.withOpacity(0.7),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInverterDetailsStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: 'Inverter Type',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 16),
            _buildRadioOption('On-grid', 'On-grid', inverterType, (value) {
              setState(() => inverterType = value!);
            }),
            _buildRadioOption('Hybrid', 'Hybrid', inverterType, (value) {
              setState(() => inverterType = value!);
            }),
            const SizedBox(height: 24),
            CommonText(
              text: 'Inverter KW Size',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              initialValue: kwSize,
              labelText: 'KW Size',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() => kwSize = value);
              },
            ),
            const SizedBox(height: 16),
            CommonText(
              text: 'Inverter Brand',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              initialValue: inverterBrand,
              labelText: 'Brand Name',
              onChanged: (value) {
                setState(() => inverterBrand = value);
              },
            ),
            const SizedBox(height: 16),
            CommonText(
              text: 'Inverter Price (PKR)',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              initialValue: inverterPrice,
              labelText: 'Price per Inverter',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() => inverterPrice = value);
              },
            ),
            const SizedBox(height: 16),
            CommonText(
              text: 'Number of Inverters',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              initialValue: inverterQuantity,
              labelText: 'Quantity',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() => inverterQuantity = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructureTypeStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: 'Structure Type',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 16),
            _buildRadioOption('Grounded', 'Grounded', structureType, (value) {
              setState(() => structureType = value!);
            }),
            _buildRadioOption('Elevated', 'Elevated', structureType, (value) {
              setState(() => structureType = value!);
            }),
            const SizedBox(height: 24),
            CommonText(
              text: 'Structure Price (PKR)',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              initialValue: structurePrice,
              labelText: 'Price',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() => structurePrice = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWiringDetailsStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: 'Wire Size',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 16),
            _buildRadioOption('4mm', '4mm', wireSize, (value) {
              setState(() => wireSize = value!);
            }),
            _buildRadioOption('6mm', '6mm', wireSize, (value) {
              setState(() => wireSize = value!);
            }),
            _buildRadioOption('2.5mm', '2.5mm', wireSize, (value) {
              setState(() => wireSize = value!);
            }),
            const SizedBox(height: 24),
            CommonText(
              text: 'Wire Length (meters)',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              initialValue: wireLength,
              labelText: 'Length in Meters',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() => wireLength = value);
              },
            ),
            const SizedBox(height: 16),
            CommonText(
              text: 'Price per Meter (PKR)',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              initialValue: wirePricePerMeter,
              labelText: 'Price per Meter',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() => wirePricePerMeter = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakerSelectionStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: 'Select Required Breakers',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 16),
            _buildCheckboxOption('DC 2-Pole', selectedBreakers, (value) {
              setState(() {
                if (value == true) {
                  selectedBreakers.add('DC 2-Pole');
                } else {
                  selectedBreakers.remove('DC 2-Pole');
                }
              });
            }),
            _buildCheckboxOption('AC 4-Pole', selectedBreakers, (value) {
              setState(() {
                if (value == true) {
                  selectedBreakers.add('AC 4-Pole');
                } else {
                  selectedBreakers.remove('AC 4-Pole');
                }
              });
            }),
            _buildCheckboxOption('AC 2-Pole', selectedBreakers, (value) {
              setState(() {
                if (value == true) {
                  selectedBreakers.add('AC 2-Pole');
                } else {
                  selectedBreakers.remove('AC 2-Pole');
                }
              });
            }),
            _buildCheckboxOption('SPD 4-Pole', selectedBreakers, (value) {
              setState(() {
                if (value == true) {
                  selectedBreakers.add('SPD 4-Pole');
                } else {
                  selectedBreakers.remove('SPD 4-Pole');
                }
              });
            }),
            _buildCheckboxOption('SPD 2-Pole', selectedBreakers, (value) {
              setState(() {
                if (value == true) {
                  selectedBreakers.add('SPD 2-Pole');
                } else {
                  selectedBreakers.remove('SPD 2-Pole');
                }
              });
            }),
            const SizedBox(height: 16),
            if (selectedBreakers.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              CommonText(
                text: 'Breaker Details',
                style: AppTypography.semiBold,
                color: AppColors.buildingBlue,
              ),
              const SizedBox(height: 16),
              ...selectedBreakers.map((breaker) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: breaker,
                        style: AppTypography.medium,
                        color: AppColors.deepBlack,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              initialValue: breakerQuantities[breaker] ?? '',
                              labelText: 'Quantity',
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  breakerQuantities[breaker] = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              initialValue: breakerPrices[breaker] ?? '',
                              labelText: 'Price (PKR)',
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  breakerPrices[breaker] = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEarthingSelectionStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: 'Select Earthing Components',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 16),
            _buildCheckboxOption('Copper Rod', selectedEarthing, (value) {
              setState(() {
                if (value == true) {
                  selectedEarthing.add('Copper Rod');
                } else {
                  selectedEarthing.remove('Copper Rod');
                }
              });
            }),
            _buildCheckboxOption('Earthing Cable', selectedEarthing, (value) {
              setState(() {
                if (value == true) {
                  selectedEarthing.add('Earthing Cable');
                } else {
                  selectedEarthing.remove('Earthing Cable');
                }
              });
            }),
            _buildCheckboxOption('Earthing Pit', selectedEarthing, (value) {
              setState(() {
                if (value == true) {
                  selectedEarthing.add('Earthing Pit');
                } else {
                  selectedEarthing.remove('Earthing Pit');
                }
              });
            }),
            const SizedBox(height: 16),
            if (selectedEarthing.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              CommonText(
                text: 'Earthing Details',
                style: AppTypography.semiBold,
                color: AppColors.buildingBlue,
              ),
              const SizedBox(height: 16),
              ...selectedEarthing.map((earthing) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: earthing,
                        style: AppTypography.medium,
                        color: AppColors.deepBlack,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              initialValue: earthingQuantities[earthing] ?? '',
                              labelText: 'Quantity',
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  earthingQuantities[earthing] = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              initialValue: earthingPrices[earthing] ?? '',
                              labelText: 'Price (PKR)',
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  earthingPrices[earthing] = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCasingSelectionStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: 'Select Casing Components',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 16),
            _buildCheckboxOption('DC and AC Power Fuse Glands', selectedCasing,
                (value) {
              setState(() {
                if (value == true) {
                  selectedCasing.add('DC and AC Power Fuse Glands');
                } else {
                  selectedCasing.remove('DC and AC Power Fuse Glands');
                }
              });
            }),
            _buildCheckboxOption('PVC Pipes and Connectors', selectedCasing,
                (value) {
              setState(() {
                if (value == true) {
                  selectedCasing.add('PVC Pipes and Connectors');
                } else {
                  selectedCasing.remove('PVC Pipes and Connectors');
                }
              });
            }),
            const SizedBox(height: 16),
            if (selectedCasing.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              CommonText(
                text: 'Casing Details',
                style: AppTypography.semiBold,
                color: AppColors.buildingBlue,
              ),
              const SizedBox(height: 16),
              ...selectedCasing.map((casing) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: casing,
                        style: AppTypography.medium,
                        color: AppColors.deepBlack,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              initialValue: casingQuantities[casing] ?? '',
                              labelText: 'Quantity',
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  casingQuantities[casing] = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              initialValue: casingPrices[casing] ?? '',
                              labelText: 'Price (PKR)',
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  casingPrices[casing] = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryInstallationStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          // Add SingleChildScrollView to handle overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                text: 'Battery Installation',
                style: AppTypography.semiBold,
                color: AppColors.buildingBlue,
              ),
              const SizedBox(height: 16),
              _buildRadioOption('Yes, install battery', true, installBattery,
                  (value) {
                setState(() => installBattery = value! as bool);
              }),
              _buildRadioOption('No, skip battery', false, installBattery,
                  (value) {
                setState(() => installBattery = value! as bool);
              }),
              if (installBattery) ...[
                const SizedBox(height: 24),
                CommonText(
                  text: 'Battery Type',
                  style: AppTypography.semiBold,
                  color: AppColors.buildingBlue,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  initialValue: batteryType,
                  labelText: 'Battery Type',
                  onChanged: (value) {
                    setState(() => batteryType = value);
                  },
                ),
                const SizedBox(height: 16),
                CommonText(
                  text: 'Battery Brand',
                  style: AppTypography.semiBold,
                  color: AppColors.buildingBlue,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  initialValue: batteryBrand,
                  labelText: 'Battery Brand',
                  onChanged: (value) {
                    setState(() => batteryBrand = value);
                  },
                ),
                const SizedBox(height: 16),
                CommonText(
                  text: 'Number of Batteries',
                  style: AppTypography.semiBold,
                  color: AppColors.buildingBlue,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  initialValue: batteryQuantity,
                  labelText: 'Quantity',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() => batteryQuantity = value);
                  },
                ),
                const SizedBox(height: 16),
                CommonText(
                  text: 'Battery Price (PKR per unit)',
                  style: AppTypography.semiBold,
                  color: AppColors.buildingBlue,
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  initialValue: batteryPrice,
                  labelText: 'Price per Battery',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() => batteryPrice = value);
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectDatesStep() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: 'Project Timeline',
              style: AppTypography.semiBold,
              color: AppColors.buildingBlue,
            ),
            const SizedBox(height: 16),
            CommonText(
              text: 'Project Start Date',
              style: AppTypography.medium,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(
                      text: startDate ?? 'Select Start Date',
                      color:
                          startDate == null ? Colors.grey : AppColors.deepBlack,
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CommonText(
              text: 'Project End Date',
              style: AppTypography.medium,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(
                      text: endDate ?? 'Select End Date',
                      color:
                          endDate == null ? Colors.grey : AppColors.deepBlack,
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationStep() {
    // Calculate total price
    double totalPrice = 0;

    // Panel cost calculation (based on per-watt pricing)
    if (pricePerWatt.isNotEmpty &&
        size.isNotEmpty &&
        panelQuantity.isNotEmpty) {
      try {
        double pricePerW = double.parse(pricePerWatt);
        double panelSizeW = double.parse(size);
        int quantity = int.parse(panelQuantity);

        totalPrice += pricePerW * panelSizeW * quantity;
      } catch (e) {
        // Error parsing values
        print("Error calculating panel cost: $e");
      }
    }

    // Inverter cost
    if (inverterPrice.isNotEmpty && inverterQuantity.isNotEmpty) {
      try {
        double price = double.parse(inverterPrice);
        int quantity = int.parse(inverterQuantity);

        totalPrice += price * quantity;
      } catch (e) {
        // Error parsing values
        print("Error calculating inverter cost: $e");
      }
    }

    // Structure cost
    if (structurePrice.isNotEmpty) {
      try {
        totalPrice += double.parse(structurePrice);
      } catch (e) {
        // Error parsing values
        print("Error calculating structure cost: $e");
      }
    }

    // Wire cost
    if (wireLength.isNotEmpty && wirePricePerMeter.isNotEmpty) {
      try {
        double length = double.parse(wireLength);
        double pricePerMeter = double.parse(wirePricePerMeter);

        totalPrice += length * pricePerMeter;
      } catch (e) {
        // Error parsing values
        print("Error calculating wire cost: $e");
      }
    }

    // Breaker costs
    for (String breaker in selectedBreakers) {
      if (breakerPrices.containsKey(breaker) &&
          breakerQuantities.containsKey(breaker)) {
        try {
          double price = double.parse(breakerPrices[breaker]!);
          int quantity = int.parse(breakerQuantities[breaker]!);

          totalPrice += price * quantity;
        } catch (e) {
          // Error parsing values
          print("Error calculating breaker cost for $breaker: $e");
        }
      }
    }

    // Earthing costs
    for (String earth in selectedEarthing) {
      if (earthingPrices.containsKey(earth) &&
          earthingQuantities.containsKey(earth)) {
        try {
          double price = double.parse(earthingPrices[earth]!);
          int quantity = int.parse(earthingQuantities[earth]!);

          totalPrice += price * quantity;
        } catch (e) {
          // Error parsing values
          print("Error calculating earthing cost for $earth: $e");
        }
      }
    }

    // Casing costs
    for (String casing in selectedCasing) {
      if (casingPrices.containsKey(casing) &&
          casingQuantities.containsKey(casing)) {
        try {
          double price = double.parse(casingPrices[casing]!);
          int quantity = int.parse(casingQuantities[casing]!);

          totalPrice += price * quantity;
        } catch (e) {
          // Error parsing values
          print("Error calculating casing cost for $casing: $e");
        }
      }
    }

    // Battery costs
    if (installBattery &&
        batteryPrice.isNotEmpty &&
        batteryQuantity.isNotEmpty) {
      try {
        double price = double.parse(batteryPrice);
        int quantity = int.parse(batteryQuantity);

        totalPrice += price * quantity;
      } catch (e) {
        // Error parsing values
        print("Error calculating battery cost: $e");
      }
    }

    final NumberFormat formatter = NumberFormat("#,##0", "en_US");

    return SingleChildScrollView(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                text: 'Project Summary',
                style: AppTypography.bold.copyWith(fontSize: 20),
                color: AppColors.buildingBlue,
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGreen),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          text: 'System Capacity:',
                          style: AppTypography.medium,
                        ),
                        CommonText(
                          text: '${_totalKw.toStringAsFixed(2)} kW',
                          style: AppTypography.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          text: 'Total Estimate:',
                          style: AppTypography.medium,
                        ),
                        CommonText(
                          text: 'PKR ${formatter.format(totalPrice.round())}',
                          style: AppTypography.bold,
                          color: AppColors.accentOrange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Solar Panel Details
              _buildSummarySection(
                'Solar Panel Details',
                [
                  if (pvModule.isNotEmpty) 'Type: $pvModule',
                  if (brand.isNotEmpty) 'Brand: $brand',
                  if (size.isNotEmpty) 'Size: $size W',
                  if (panelQuantity.isNotEmpty) 'Quantity: $panelQuantity',
                  if (pricePerWatt.isNotEmpty)
                    'Price per Watt: PKR $pricePerWatt',
                ],
              ),

              // Inverter Details
              _buildSummarySection(
                'Inverter Details',
                [
                  if (inverterType.isNotEmpty) 'Type: $inverterType',
                  if (kwSize.isNotEmpty) 'Size: $kwSize kW',
                  if (inverterBrand.isNotEmpty) 'Brand: $inverterBrand',
                  if (inverterPrice.isNotEmpty && inverterQuantity.isNotEmpty)
                    'Inverter(s): $inverterQuantity × PKR ${formatter.format(double.tryParse(inverterPrice) ?? 0)}',
                ],
              ),

              // Structure Details
              _buildSummarySection(
                'Structure Details',
                [
                  if (structureType.isNotEmpty) 'Type: $structureType',
                  if (structurePrice.isNotEmpty)
                    'Price: PKR ${formatter.format(double.tryParse(structurePrice) ?? 0)}',
                ],
              ),

              // Wiring Details
              _buildSummarySection(
                'Wiring Details',
                [
                  if (wireSize.isNotEmpty) 'Size: $wireSize',
                  if (wireLength.isNotEmpty) 'Length: $wireLength meters',
                  if (wirePricePerMeter.isNotEmpty)
                    'Price/meter: PKR $wirePricePerMeter',
                ],
              ),

              // Breakers Details
              if (selectedBreakers.isNotEmpty)
                _buildSummarySection(
                  'Breakers',
                  selectedBreakers.map((breaker) {
                    final quantity = breakerQuantities[breaker] ?? '0';
                    final price = breakerPrices[breaker] ?? '0';
                    return '$breaker: $quantity × PKR ${formatter.format(double.tryParse(price) ?? 0)}';
                  }).toList(),
                ),

              // Earthing Details
              if (selectedEarthing.isNotEmpty)
                _buildSummarySection(
                  'Earthing Components',
                  selectedEarthing.map((item) {
                    final quantity = earthingQuantities[item] ?? '0';
                    final price = earthingPrices[item] ?? '0';
                    return '$item: $quantity × PKR ${formatter.format(double.tryParse(price) ?? 0)}';
                  }).toList(),
                ),

              // Casing Details
              if (selectedCasing.isNotEmpty)
                _buildSummarySection(
                  'Casing Components',
                  selectedCasing.map((item) {
                    final quantity = casingQuantities[item] ?? '0';
                    final price = casingPrices[item] ?? '0';
                    return '$item: $quantity × PKR ${formatter.format(double.tryParse(price) ?? 0)}';
                  }).toList(),
                ),

              // Battery Details (if applicable)
              if (installBattery)
                _buildSummarySection(
                  'Battery Details',
                  [
                    if (batteryType.isNotEmpty) 'Type: $batteryType',
                    if (batteryBrand.isNotEmpty) 'Brand: $batteryBrand',
                    if (batteryQuantity.isNotEmpty && batteryPrice.isNotEmpty)
                      'Battery(s): $batteryQuantity × PKR ${formatter.format(double.tryParse(batteryPrice) ?? 0)}',
                  ],
                ),

              // Project Timeline
              _buildSummarySection(
                'Project Timeline',
                [
                  if (startDate != null) 'Start Date: $startDate',
                  if (endDate != null) 'End Date: $endDate',
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: CommonButton(
                  text: 'Submit Project',
                  onPressed: _submitProject,
                  color: AppColors.primaryGreen,
                  icon: Icons.check_circle,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        CommonText(
          text: title,
          style: AppTypography.semiBold,
          color: AppColors.buildingBlue,
        ),
        const SizedBox(height: 8),
        ...items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: CommonText(text: item),
                ))
            .toList(),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  // Helper widgets
  Widget _buildTextField({
    required String initialValue,
    required String labelText,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    bool obscureText = false,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: keyboardType ?? TextInputType.text,
      obscureText: obscureText,
      onChanged: onChanged,
    );
  }

  Widget _buildRadioOption(
    String label,
    dynamic value,
    dynamic groupValue,
    Function(dynamic) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: value == groupValue
                ? AppColors.primaryGreen
                : AppColors.lightGray,
            width: value == groupValue ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: value == groupValue
              ? AppColors.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: value == groupValue
                      ? AppColors.primaryGreen
                      : AppColors.deepBlack.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: value == groupValue
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            CommonText(
              text: label,
              style: value == groupValue
                  ? AppTypography.medium
                  : AppTypography.regular,
              color: value == groupValue
                  ? AppColors.deepBlack
                  : AppColors.deepBlack.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(
    String label,
    List<String> selectedItems,
    Function(bool?) onChanged,
  ) {
    bool isSelected = selectedItems.contains(label);

    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGray,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColors.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.deepBlack.withOpacity(0.5),
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            CommonText(
              text: label,
              style: isSelected ? AppTypography.medium : AppTypography.regular,
              color: isSelected
                  ? AppColors.deepBlack
                  : AppColors.deepBlack.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingProject != null
            ? 'Edit Project'
            : 'Create New Project'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                physics: ClampingScrollPhysics(),
                controller: _scrollController,
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < steps.length - 1) {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  }
                },
                onStepTapped: (step) {
                  setState(() {
                    _currentStep = step;
                  });
                },
                steps: steps,
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: CommonButton(
                              text: 'Back',
                              onPressed: details.onStepCancel!,
                              color: Colors.grey,
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 12),
                        Expanded(
                          child: CommonButton(
                            text: _currentStep < steps.length - 1
                                ? 'Next'
                                : 'Submit',
                            onPressed: () {
                              if (_currentStep < steps.length - 1) {
                                // If not on the last step, continue as normal
                                details.onStepContinue!();
                              } else {
                                // On the last step, handle project creation and navigate to dashboard
                                // First perform any final validations or submissions
                                _submitProject(); // Assuming you have a method to handle the submission

                                // Show success message
                                Get.snackbar(
                                  "Success",
                                  "Project created successfully!",
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );

                                // Navigate to manager panel
                                Get.offAllNamed(Routes.MANAGER_PANEL);
                              }
                            },
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
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

  Future<void> _submitProject() async {
    // Prepare project data
    Map<String, dynamic> projectData = {
      'pvModule': pvModule,
      'brand': brand,
      'size': size,
      'pricePerWatt': pricePerWatt,
      'panelQuantity': panelQuantity,
      'totalKw': _totalKw,
      'inverterType': inverterType,
      'kwSize': kwSize,
      'inverterBrand': inverterBrand,
      'inverterPrice': inverterPrice,
      'inverterQuantity': inverterQuantity,
      'structureType': structureType,
      'structurePrice': structurePrice,
      'wireSize': wireSize,
      'wireLength': wireLength,
      'wirePricePerMeter': wirePricePerMeter,
      'selectedBreakers': selectedBreakers,
      'breakerPrices': breakerPrices,
      'breakerQuantities': breakerQuantities,
      'selectedEarthing': selectedEarthing,
      'earthingPrices': earthingPrices,
      'earthingQuantities': earthingQuantities,
      'selectedCasing': selectedCasing,
      'casingPrices': casingPrices,
      'casingQuantities': casingQuantities,
      'installBattery': installBattery,
      'batteryType': batteryType,
      'batteryBrand': batteryBrand,
      'batteryQuantity': batteryQuantity,
      'batteryPrice': batteryPrice,
      'startDate': startDate,
      'endDate': endDate,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'status': 'doing', // Add status to track project state
    };

    // Add project ID if editing
    String projectId;
    if (widget.existingProject != null &&
        widget.existingProject!.containsKey('id')) {
      projectId = widget.existingProject!['id'];
      projectData['id'] = projectId;
    } else {
      // Generate new ID for new project
      final docRef = FirebaseFirestore.instance.collection('Projects').doc();
      projectId = docRef.id;
      projectData['id'] = projectId;
    }

    try {
      // Save project to Firestore
      await FirebaseFirestore.instance
          .collection('Projects')
          .doc(projectId)
          .set(projectData, SetOptions(merge: true));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Project ${widget.existingProject != null ? 'updated' : 'created'} successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      // Convert string dates to DateTime objects
      DateTime projectStartDate = DateTime.now();
      DateTime projectEndDate =
          DateTime.now().add(Duration(days: 30)); // Default fallback

      try {
        if (startDate != null) {
          projectStartDate = DateTime.parse(startDate!);
        }
        if (endDate != null) {
          projectEndDate = DateTime.parse(endDate!);
        }
      } catch (e) {
        print("Error parsing dates: $e");
        // Continue with default dates if parsing fails
      }

      // Navigate to StaffAssignmentScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffAssignmentScreen(
            projectId: projectId,
            startDate: projectStartDate,
            endDate: projectEndDate,
          ),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving project: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
