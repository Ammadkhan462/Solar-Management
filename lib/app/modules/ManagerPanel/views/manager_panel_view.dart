import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/app/modules/EmployeesRegistration/views/employees_registration_view.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../controllers/manager_panel_controller.dart';
import 'package:intl/intl.dart'; // For date formatting

class ManagerPanelView extends GetView<ManagerPanelController> {
  const ManagerPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Panel'),
        centerTitle: true,
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
        // Wait for data to load
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final manager = controller.manager.value;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          child: ListView(
            children: [
              // Display Manager Info
              Text(
                "Name: ${manager.name}",
                style: TextStyle(
                  fontSize:
                      isPortrait ? screenHeight * 0.025 : screenWidth * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "Email: ${manager.email}",
                style: TextStyle(
                  fontSize:
                      isPortrait ? screenHeight * 0.02 : screenWidth * 0.02,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "CNIC: ${manager.cnic}",
                style: TextStyle(
                  fontSize:
                      isPortrait ? screenHeight * 0.02 : screenWidth * 0.02,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Responsive button row
              isPortrait
                  ? Column(
                      children: [
                        _buildResponsiveButton(
                          context,
                          icon: Icons.person_add,
                          label: "Register Employee",
                          onPressed: () =>
                              _showEmployeeRegistrationForm(context),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        _buildResponsiveButton(
                          context,
                          icon: Icons.people,
                          label: "View Employees",
                          onPressed: () =>
                              Get.to(() => EmployeeCredentialsScreen()),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildResponsiveButton(
                          context,
                          icon: Icons.person_add,
                          label: "Register Employee",
                          onPressed: () =>
                              _showEmployeeRegistrationForm(context),
                        ),
                        _buildResponsiveButton(
                          context,
                          icon: Icons.people,
                          label: "View Employees",
                          onPressed: () =>
                              Get.to(() => EmployeeCredentialsScreen()),
                        ),
                      ],
                    ),
              SizedBox(height: screenHeight * 0.02),

              // Display Pending Projects (Including Approved, Doing, and Completed)
              Text(
                "Pending / Approved / Doing / Completed Projects",
                style: TextStyle(
                  fontSize:
                      isPortrait ? screenHeight * 0.025 : screenWidth * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              // Projects list
              ...controller.projects.map((project) {
                var tasksList = <dynamic>[];
                if (project['tasks'] is List) {
                  tasksList = project['tasks'] as List;
                } else if (project['tasks'] is Map) {
                  // Convert map to list if needed
                  tasksList = (project['tasks'] as Map).values.toList();
                }
                return Card(
                  margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                  child: ListTile(
                    title: Text(
                      project['projectName'] ?? 'No Name',
                      style: TextStyle(
                        fontSize: isPortrait
                            ? screenHeight * 0.02
                            : screenWidth * 0.02,
                      ),
                    ),
                    subtitle: Text(
                      project['clientName'] ?? 'No Client',
                      style: TextStyle(
                        fontSize: isPortrait
                            ? screenHeight * 0.018
                            : screenWidth * 0.018,
                      ),
                    ),
                    trailing: SizedBox(
                      width: screenWidth * 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (project['status'] == 'doing' ||
                              project['status'] == 'progress')
                            Column(
                              children: [
                                Text(
                                  '${project['progress'] ?? 0}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isPortrait
                                        ? screenHeight * 0.018
                                        : screenWidth * 0.018,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                LinearProgressIndicator(
                                  value: (project['progress'] ?? 0) / 100,
                                  color: Colors.green,
                                  backgroundColor: Colors.grey[300],
                                ),
                              ],
                            )
                          else if (project['status'] == 'completed')
                            Text(
                              "Completed",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isPortrait
                                    ? screenHeight * 0.018
                                    : screenWidth * 0.018,
                                color: Colors.blue,
                              ),
                            )
                          else
                            Text(
                              "Ready to create",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isPortrait
                                    ? screenHeight * 0.018
                                    : screenWidth * 0.018,
                                color: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Updated onTap for handling completed projects
                    // Inside the ManagerPanelView onTap method
                    onTap: () {
                      if (project['status'] == 'approved') {
                        Get.to(() =>
                            ProjectCreationScreen(existingProject: project));
                      } else if (project['status'] == 'progress') {
                        Get.to(() => ProjectProgressScreen(
                              projectId: project['id'],
                              projectData: project,
                            ));
                      } else if (project['status'] == 'completed' ||
                          project['status'] == 'doing') {
                        // Ensure you pass both project and projectId
                        Get.to(() => ProjectDetailsScreen(
                              project: project,
                              projectId: project[
                                  'id'], // Make sure to pass the projectId here
                            ));
                      }
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildResponsiveButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return SizedBox(
      width: isPortrait ? double.infinity : null,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: screenHeight * 0.025),
        label: Padding(
          padding: EdgeInsets.all(screenHeight * 0.01),
          child: Text(
            label,
            style: TextStyle(fontSize: screenHeight * 0.018),
          ),
        ),
        onPressed: onPressed,
      ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Progress"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Basic Information"),
            _buildDetailRow("Project Name", projectData['projectName']),
            _buildDetailRow("Client Name", projectData['clientName']),
            _buildDetailRow("Property Type", projectData['propertyType']),

            // Display Tasks
            _buildSectionTitle("Tasks"),
            ..._buildTasksList(),

            // Display Progress Indicator for Completed or Progress Tasks
            _buildSectionTitle("Progress"),
            _buildProgressIndicator(),
            _buildUpdateProgressButton(),
          ],
        ),
      ),
    );
  }

  // Function to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  // Function to build a row for displaying task details
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not specified',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTasksList() {
    List<Widget> taskWidgets = [];

    // Ensure tasks is a list
    if (projectData['tasks'] != null) {
      var tasks = projectData['tasks'];

      if (tasks is List) {
        for (var task in tasks) {
          bool isCompleted = task['status'] == 'completed';
          taskWidgets.add(
            ListTile(
              title: Text(task['name'] ?? 'Unnamed Task'),
              subtitle: isCompleted
                  ? Text("Completed", style: TextStyle(color: Colors.green))
                  : Text("In Progress", style: TextStyle(color: Colors.orange)),
              onTap: () {
                // Show task details
                if (isCompleted && task['taskVideos'] != null) {
                  _showTaskVideos(Map<String, dynamic>.from(task));
                } else {
                  Get.snackbar("Task In Progress", "Task is still in progress");
                }
              },
            ),
          );
        }
      } else if (tasks is Map) {
        // Handle if tasks is a map instead of a list
        tasks.forEach((key, task) {
          if (task is Map) {
            bool isCompleted = task['status'] == 'completed';
            taskWidgets.add(
              ListTile(
                title: Text(task['name'] ?? key ?? 'Unnamed Task'),
                subtitle: isCompleted
                    ? Text("Completed", style: TextStyle(color: Colors.green))
                    : Text("In Progress",
                        style: TextStyle(color: Colors.orange)),
                onTap: () {
                  // Show task details
                  if (isCompleted && task['taskVideos'] != null) {
                    _showTaskVideos(Map<String, dynamic>.from(task));
                  } else {
                    Get.snackbar(
                        "Task In Progress", "Task is still in progress");
                  }
                },
              ),
            );
          }
        });
      }
    }

    if (taskWidgets.isEmpty) {
      taskWidgets.add(ListTile(
        title: Text("No tasks available"),
      ));
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
    if (_nameController.text.isEmpty ||
        _cnicController.text.isEmpty ||
        _selectedDesignation == null) {
      Get.snackbar("Error", "Name, CNIC, and designation are required",
          backgroundColor: Colors.red);
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
    } catch (e) {
      Get.snackbar("Error", "Failed to register employee: $e",
          backgroundColor: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: "Employee Name",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _cnicController,
          decoration: const InputDecoration(
            labelText: "CNIC",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedDesignation,
          decoration: const InputDecoration(
            labelText: "Employee Designation",
            border: OutlineInputBorder(),
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
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _registerEmployee,
                child: const Text("Register Employee"),
              ),
      ],
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
  final Map<String, dynamic> project;
  final String projectId;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final projectName = project['projectName']?.toString() ?? 'Unnamed Project';

    return Scaffold(
      appBar: AppBar(
        title: Text(projectName),
      ),
      body: _buildTaskStructure(context),
    );
  }

  Widget _buildTaskStructure(BuildContext context) {
    // Get the taskVideos map from project data
    final taskVideos = (project['taskVideos'] as Map<String, dynamic>?) ?? {};

    final List<Map<String, dynamic>> standardTasks = [
      {
        'name': 'Panel Installation',
        'key': 'Panel Installation',
        'icon': Icons.solar_power,
      },
      {
        'name': 'Inverter Installation',
        'key':
            'Inverter installation', // Note: matches your Firestore key exactly
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

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Project Tasks',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...standardTasks.map((task) {
          final taskKey = task['key'] as String;
          final videoUrl = taskVideos[taskKey]?.toString();
          final hasVideo = videoUrl != null && videoUrl.isNotEmpty;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(task['icon'] as IconData),
              title: Text(task['name'] as String),
              subtitle: Text('Status: ${hasVideo ? 'COMPLETED' : 'PENDING'}'),
              trailing: hasVideo
                  ? const Icon(Icons.videocam, color: Colors.green)
                  : const Icon(Icons.videocam_off, color: Colors.grey),
              onTap: hasVideo
                  ? () {
                      // Pass context explicitly
                      _playVideo(context, videoUrl!);
                    }
                  : null,
            ),
          );
        }).toList(),
      ],
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
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

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
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

class ProjectCreationScreen extends StatefulWidget {
  final Map<String, dynamic>? existingProject;

  const ProjectCreationScreen({Key? key, this.existingProject})
      : super(key: key);

  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  int _currentStep = 0;
  String panelQuantity = '';
  String inverterQuantity = '';
  List<String> selectedBreakers = []; // List to hold selected breakers
  Map<String, String> breakerPrices = {}; // Map to hold breaker prices
  Map<String, String> breakerQuantities = {}; // Map to hold breaker quantities
  // Data to be collected for each step
  String pvModule = ''; // Step 1: PV Module Name
  String brand = ''; // Step 2: Brand selection
  List<String> selectedCasing = []; // List to hold selected casing types
  Map<String, String> casingPrices = {}; // Map to hold casing prices
  Map<String, String> casingQuantities = {}; // Map to hold casing quantities

  List<String> selectedEarthing = []; // List to hold selected earthing types
  Map<String, String> earthingPrices = {}; // Map to hold earthing prices
  Map<String, String> earthingQuantities =
      {}; // Map to hold earthing quantities

  String size = ''; // Step 3: Size selection
  String panelPrice = ''; // Step 4: Panel price
  String inverterType = ''; // Step 5: Inverter selection (On-grid, Hybrid)
  String kwSize = ''; // Step 6: KW Size (e.g., 5 KW, 10 KW)
  String inverterBrand = ''; // Step 7: Inverter Brand (e.g., SMA, ABB)
  String inverterPrice = ''; // Step 8: Inverter Price
  String structureType = ''; // Step 9: Structure type (Grounded, Elevated)
  String structurePrice = ''; // Step 9: Structure price
  String batteryType = ''; // Step 10: Battery type (Lithium, Tubular)
  String batteryBrand = ''; // Step 11: Battery brand
  String batteryQuantity = ''; // Step 12: Battery quantity
  String batteryPrice = ''; // Step 13: Battery price
  String wireSize = ''; // Step 14: Wire Size (4mm, 6mm, 2.5mm)
  String wireLength = ''; // Step 14: Wire length (meters)
  String wirePricePerMeter = ''; // Step 14: Wire price per meter
  String breakerType = ''; // Step 15: Breaker type (AC or DC)
  String acBreakerType = ''; // Step 15: AC breaker selection (2-pole or 4-pole)
  String dcBreakerType = ''; // Step 15: DC breaker selection (2-pole)
  String spdBreakerType = ''; // Step 15: SPD breaker type (2-pole or 4-pole)
  String earthingType = ''; // Step 13: Earthing type
  String earthingQuantity = ''; // Step 13: Earthing quantity
  String earthingPrice = ''; // Step 13: Earthing price
  String casingType = ''; // Step 14: Casing type
  bool installBattery = false;
  String? startDate;
  String? endDate;
  Map<String, dynamic> projectData = {};

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        if (isStartDate) {
          startDate =
              picked.toLocal().toString().split(' ')[0]; // Format as yyyy-mm-dd
        } else {
          endDate =
              picked.toLocal().toString().split(' ')[0]; // Format as yyyy-mm-dd
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingProject != null) {
      breakerType = widget.existingProject!['breakerType'] ?? '';
      breakerType = widget.existingProject!['breakerType'] ?? '';
      earthingType = widget.existingProject!['earthingType'] ?? '';
      casingType = widget.existingProject!['casingType'] ?? '';
      // Pre-fill data if editing an existing project
      pvModule = widget.existingProject!['pvModule'] ?? '';
      brand = widget.existingProject!['brand'] ?? '';
      size = widget.existingProject!['size'] ?? '';
      panelPrice = widget.existingProject!['panelPrice'] ?? '';
      inverterType = widget.existingProject!['inverterType'] ?? '';
      kwSize = widget.existingProject!['kwSize'] ?? '';
      inverterBrand = widget.existingProject!['inverterBrand'] ?? '';
      inverterPrice = widget.existingProject!['inverterPrice'] ?? '';
      structureType = widget.existingProject!['structureType'] ?? '';
      structurePrice = widget.existingProject!['structurePrice'] ?? '';
      batteryType = widget.existingProject!['batteryType'] ?? '';
      batteryBrand = widget.existingProject!['batteryBrand'] ?? '';
      batteryQuantity = widget.existingProject!['batteryQuantity'] ?? '';
      batteryPrice = widget.existingProject!['batteryPrice'] ?? '';
      wireSize = widget.existingProject!['wireSize'] ?? '';
      wireLength = widget.existingProject!['wireLength'] ?? '';
      wirePricePerMeter = widget.existingProject!['wirePricePerMeter'] ?? '';
      breakerType = widget.existingProject!['breakerType'] ?? '';
      acBreakerType = widget.existingProject!['acBreakerType'] ?? '';
      dcBreakerType = widget.existingProject!['dcBreakerType'] ?? '';
      spdBreakerType = widget.existingProject!['spdBreakerType'] ?? '';
    }
  }

  List<Step> _steps() {
    return [
      // Step 1: PV Module Type
      Step(
        title: const Text('Step 1: PV Module'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose PV Module Type:'),
            ListTile(
              title: const Text('Mono'),
              leading: Radio<String>(
                value: 'Mono',
                groupValue: pvModule,
                onChanged: (String? value) {
                  setState(() {
                    pvModule = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Bi-Facial'),
              leading: Radio<String>(
                value: 'Bi-Facial',
                groupValue: pvModule,
                onChanged: (String? value) {
                  setState(() {
                    pvModule = value!;
                  });
                },
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep == 0 ? StepState.editing : StepState.complete,
      ),
      // Step 2: Select Brand
      Step(
        title: const Text('Step 2: Select Brand'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose the brand of PV module:'),
            ListTile(
              title: const Text('Longi'),
              leading: Radio<String>(
                value: 'Longi',
                groupValue: brand,
                onChanged: (String? value) {
                  setState(() {
                    brand = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Jinko'),
              leading: Radio<String>(
                value: 'Jinko',
                groupValue: brand,
                onChanged: (String? value) {
                  setState(() {
                    brand = value!;
                  });
                },
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep == 1 ? StepState.editing : StepState.complete,
      ),
      // Step 3: Select Size
      Step(
        title: const Text('Step 3: Select Size'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose the size of the PV module:'),
            ListTile(
              title: const Text('580W'),
              leading: Radio<String>(
                value: '580',
                groupValue: size,
                onChanged: (String? value) {
                  setState(() {
                    size = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('585W'),
              leading: Radio<String>(
                value: '585',
                groupValue: size,
                onChanged: (String? value) {
                  setState(() {
                    size = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('610W'),
              leading: Radio<String>(
                value: '610',
                groupValue: size,
                onChanged: (String? value) {
                  setState(() {
                    size = value!;
                  });
                },
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep == 2 ? StepState.editing : StepState.complete,
      ),
      // Step 4: Enter Panel Price
      Step(
        title: const Text('Step 4: Panel Price & Quantity'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter the price of $brand $size:'),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => panelPrice = value),
              decoration: const InputDecoration(
                labelText: 'Price per panel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => panelQuantity = value),
              decoration: const InputDecoration(
                labelText: 'Number of panels',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 3,
        state: _currentStep == 3 ? StepState.editing : StepState.complete,
      ),
      // Step 5: Inverter Type
      Step(
        title: const Text('Step 5: Inverter Type'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose the Inverter Type:'),
            ListTile(
              title: const Text('On-grid'),
              leading: Radio<String>(
                value: 'On-grid',
                groupValue: inverterType,
                onChanged: (String? value) {
                  setState(() {
                    inverterType = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Hybrid'),
              leading: Radio<String>(
                value: 'Hybrid',
                groupValue: inverterType,
                onChanged: (String? value) {
                  setState(() {
                    inverterType = value!;
                  });
                },
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 4,
        state: _currentStep == 4 ? StepState.editing : StepState.complete,
      ),
      // Step 6: Enter KW Size
      Step(
        title: const Text('Step 6: Enter KW Size'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter KW size:'),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  kwSize = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'KW',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 5,
        state: _currentStep == 5 ? StepState.editing : StepState.complete,
      ),
      // Step 7: Select Inverter Brand
      Step(
        title: const Text('Step 7: Select Inverter Brand'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter or Choose Inverter Brand:'),
            TextField(
              onChanged: (value) {
                setState(() {
                  inverterBrand = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Inverter Brand',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 6,
        state: _currentStep == 6 ? StepState.editing : StepState.complete,
      ),
      // Step 8: Inverter Price
      Step(
        title: const Text('Step 8: Inverter Price & Quantity'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter the price for $inverterBrand $inverterType inverter:'),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => inverterPrice = value),
              decoration: const InputDecoration(
                labelText: 'Price per inverter',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => inverterQuantity = value),
              decoration: const InputDecoration(
                labelText: 'Number of inverters',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 7,
        state: _currentStep == 7 ? StepState.editing : StepState.complete,
      ),
      // Step 9: Select Structure Type
      Step(
        title: const Text('Step 9: Structure Type'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Structure Type (Grounded/Elevated):'),
            ListTile(
              title: const Text('Grounded'),
              leading: Radio<String>(
                value: 'Grounded',
                groupValue: structureType,
                onChanged: (String? value) {
                  setState(() {
                    structureType = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Elevated'),
              leading: Radio<String>(
                value: 'Elevated',
                groupValue: structureType,
                onChanged: (String? value) {
                  setState(() {
                    structureType = value!;
                  });
                },
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 8,
        state: _currentStep == 8 ? StepState.editing : StepState.complete,
      ),
      // Step 10: Wire Selection
      Step(
        title: const Text('Step 10: Wire Selection'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select wire size:'),
            ListTile(
              title: const Text('4mm'),
              leading: Radio<String>(
                value: '4mm',
                groupValue: wireSize,
                onChanged: (String? value) {
                  setState(() {
                    wireSize = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('6mm'),
              leading: Radio<String>(
                value: '6mm',
                groupValue: wireSize,
                onChanged: (String? value) {
                  setState(() {
                    wireSize = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('2.5mm'),
              leading: Radio<String>(
                value: '2.5mm',
                groupValue: wireSize,
                onChanged: (String? value) {
                  setState(() {
                    wireSize = value!;
                  });
                },
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  wireLength = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Wire length (meters)',
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  wirePricePerMeter = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Price per meter',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 9,
        state: _currentStep == 9 ? StepState.editing : StepState.complete,
      ),
      // Step 11: Breaker Type Selection
      Step(
        title: const Text('Step 11: Breaker Selection'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Breaker Type:'),
            ListTile(
              title: const Text('DC 2-Pole'),
              leading: Checkbox(
                value: selectedBreakers.contains('DC 2-Pole'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedBreakers.add('DC 2-Pole');
                    } else {
                      selectedBreakers.remove('DC 2-Pole');
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('AC 4-Pole'),
              leading: Checkbox(
                value: selectedBreakers.contains('AC 4-Pole'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedBreakers.add('AC 4-Pole');
                    } else {
                      selectedBreakers.remove('AC 4-Pole');
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('AC 2-Pole'),
              leading: Checkbox(
                value: selectedBreakers.contains('AC 2-Pole'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedBreakers.add('AC 2-Pole');
                    } else {
                      selectedBreakers.remove('AC 2-Pole');
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('SPD 4-Pole'),
              leading: Checkbox(
                value: selectedBreakers.contains('SPD 4-Pole'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedBreakers.add('SPD 4-Pole');
                    } else {
                      selectedBreakers.remove('SPD 4-Pole');
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('SPD 2-Pole'),
              leading: Checkbox(
                value: selectedBreakers.contains('SPD 2-Pole'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedBreakers.add('SPD 2-Pole');
                    } else {
                      selectedBreakers.remove('SPD 2-Pole');
                    }
                  });
                },
              ),
            ),
            // Display the text fields to enter prices and quantities for each selected breaker
            ...selectedBreakers.map((breaker) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter quantity for $breaker:'),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          breakerQuantities[breaker] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '$breaker Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Text('Enter price for $breaker:'),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          breakerPrices[breaker] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '$breaker Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
        isActive: _currentStep >= 10,
        state: _currentStep == 10 ? StepState.editing : StepState.complete,
      ),
      // Step 13: Earthing
      Step(
        title: const Text('Step 12: Earthing Selection'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Earthing Type:'),
            ListTile(
              title: const Text('AC Earthing'),
              leading: Checkbox(
                value: selectedEarthing.contains('AC Earthing'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedEarthing.add('AC Earthing');
                    } else {
                      selectedEarthing.remove('AC Earthing');
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('DC Earthing'),
              leading: Checkbox(
                value: selectedEarthing.contains('DC Earthing'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedEarthing.add('DC Earthing');
                    } else {
                      selectedEarthing.remove('DC Earthing');
                    }
                  });
                },
              ),
            ),
            // Add other earthing types similarly...

            // Display text fields to enter prices and quantities for each selected earthing
            ...selectedEarthing.map((earthing) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter quantity for $earthing:'),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          earthingQuantities[earthing] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '$earthing Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Text('Enter price for $earthing:'),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          earthingPrices[earthing] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '$earthing Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
        isActive: _currentStep >= 11,
        state: _currentStep == 11 ? StepState.editing : StepState.complete,
      ),
// Step 14: Casing
      Step(
        title: const Text('Step 13: Casing Selection'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Casing Type:'),
            ListTile(
              title: const Text('DC and AC Power Fuse Glands'),
              leading: Checkbox(
                value: selectedCasing.contains('DC and AC Power Fuse Glands'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedCasing.add('DC and AC Power Fuse Glands');
                    } else {
                      selectedCasing.remove('DC and AC Power Fuse Glands');
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('PVC Pipes and Connectors'),
              leading: Checkbox(
                value: selectedCasing.contains('PVC Pipes and Connectors'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedCasing.add('PVC Pipes and Connectors');
                    } else {
                      selectedCasing.remove('PVC Pipes and Connectors');
                    }
                  });
                },
              ),
            ),
            // Add other casing types similarly...

            // Display text fields to enter prices and quantities for each selected casing
            ...selectedCasing.map((casing) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enter quantity for $casing:'),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          casingQuantities[casing] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '$casing Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Text('Enter price for $casing:'),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          casingPrices[casing] = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '$casing Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
        isActive: _currentStep >= 12,
        state: _currentStep == 12 ? StepState.editing : StepState.complete,
      ),
      Step(
        title: const Text('Step 14: Battery Installation'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Do you want to install a battery?'),
            RadioListTile<bool>(
              title: const Text('Yes'),
              value: true,
              groupValue: installBattery,
              onChanged: (bool? value) {
                setState(() => installBattery = value ?? false);
              },
            ),
            RadioListTile<bool>(
              title: const Text('No'),
              value: false,
              groupValue: installBattery,
              onChanged: (bool? value) {
                setState(() => installBattery = value ?? false);
              },
            ),
            if (installBattery) ...[
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Battery Type',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => batteryType = value,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Battery Brand',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => batteryBrand = value,
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Battery Quantity',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => batteryQuantity = value,
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Battery Price',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => batteryPrice = value,
              ),
            ],
          ],
        ),
        isActive: _currentStep >= 13,
        state: _currentStep == 13 ? StepState.editing : StepState.complete,
      ),
      Step(
        title: const Text('Step 15: Set Project Dates'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start Date:'),
            GestureDetector(
              onTap: () => _selectDate(context, true),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: startDate ?? 'Select Start Date',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('End Date:'),
            GestureDetector(
              onTap: () => _selectDate(context, false),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: endDate ?? 'Select End Date',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 14,
        state: _currentStep == 14 ? StepState.editing : StepState.complete,
      ),

      Step(
        title: const Text('Step 16: Confirmation'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please confirm the information:'),
            Text('PV Module: $pvModule'),
            Text('Brand: $brand'),
            Text('Size: $size'),
            Text('Panel Price: $panelPrice'),
            Text('Inverter Type: $inverterType'),
            Text('KW Size: $kwSize'),
            Text('Inverter Brand: $inverterBrand'),
            Text('Inverter Price: $inverterPrice'),
            Text('Structure Type: $structureType'),
            Text('Structure Price: $structurePrice'),
            Text('Battery Type: $batteryType'),
            Text('Battery Brand: $batteryBrand'),
            Text('Battery Quantity: $batteryQuantity'),
            Text('Battery Price: $batteryPrice'),
            Text('Wire Size: $wireSize'),
            Text('Wire Length: $wireLength'),
            Text('Wire Price per Meter: $wirePricePerMeter'),
            Text('Breaker Type: $breakerType'),
            ElevatedButton(
              onPressed: _submitProject,
              child: const Text('Submit Project'),
            ),
          ],
        ),
        isActive: _currentStep >= 15,
        state: _currentStep == 15 ? StepState.editing : StepState.complete,
      ),
    ];
  }

  void _onStepContinue() {
    if (_currentStep < _steps().length - 1) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      _submitProject();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

// Update _submitProject() validation:
  void _submitProject() async {
    // Create list of mandatory fields
    List<bool> mandatoryFields = [
      pvModule.isEmpty,
      brand.isEmpty,
      size.isEmpty,
      panelPrice.isEmpty,
      inverterType.isEmpty,
      kwSize.isEmpty,
      inverterBrand.isEmpty,
      inverterPrice.isEmpty,
      structureType.isEmpty,
      wireSize.isEmpty,
      wireLength.isEmpty,
      wirePricePerMeter.isEmpty,
      selectedBreakers.isEmpty,
      breakerPrices.isEmpty,
    ];

    // Add battery validation only if installing battery
    if (installBattery) {
      mandatoryFields.addAll([
        batteryType.isEmpty,
        batteryBrand.isEmpty,
        batteryQuantity.isEmpty,
        batteryPrice.isEmpty,
      ]);
    }

    if (mandatoryFields.any((element) => element == true)) {
      Get.snackbar('Error', 'Please complete all required steps.');
      return;
    }
    try {
      projectData['selectedBreakers'] = selectedBreakers;
      projectData['breakerPrices'] = breakerPrices;
      projectData['breakerQuantities'] = breakerQuantities;

      projectData['pvModule'] = pvModule;
      projectData['brand'] = brand;
      projectData['size'] = size;
      projectData['panelPrice'] = panelPrice;
      projectData['inverterType'] = inverterType;
      projectData['kwSize'] = kwSize;
      projectData['inverterBrand'] = inverterBrand;
      projectData['inverterPrice'] = inverterPrice;
      projectData['structureType'] = structureType;
      projectData['structurePrice'] = structurePrice;
      projectData['batteryType'] = batteryType;
      projectData['batteryBrand'] = batteryBrand;
      projectData['batteryQuantity'] = batteryQuantity;
      projectData['batteryPrice'] = batteryPrice;
      projectData['wireSize'] = wireSize;
      projectData['wireLength'] = wireLength;
      projectData['wirePricePerMeter'] = wirePricePerMeter;
      projectData['breakerType'] = breakerType;
      projectData['acBreakerType'] = acBreakerType;
      projectData['dcBreakerType'] = dcBreakerType;
      projectData['spdBreakerType'] = spdBreakerType;
      projectData['earthingType'] = earthingType;
      projectData['earthingQuantity'] = earthingQuantity;
      projectData['earthingPrice'] = earthingPrice;
      projectData['casingType'] = casingType;
      projectData['startDate'] = startDate;
      projectData['endDate'] = endDate;
      if (widget.existingProject != null) {
        // Update the existing project
        await FirebaseFirestore.instance
            .collection('Projects')
            .doc(widget.existingProject!['id'])
            .update({
          ...projectData,
          'status': 'progress', // Update status to 'progress'
        });
      } else {
        // Create a new project
        await FirebaseFirestore.instance.collection('Projects').add({
          ...projectData,
          'status': 'progress', // Set status to 'progress'
        });
      }

// Example from ProjectCreationScreen's _submitProject method:
      Get.to(() => StaffAssignmentScreen(
            projectId: widget.existingProject?['id'] ??
                '', // Use existing project ID or empty string
            startDate: DateTime.parse(
                startDate!), // Convert your startDate string to DateTime
            endDate: DateTime.parse(
                endDate!), // Convert your endDate string to DateTime
          ));

      Get.snackbar('Success', 'Project has been created/updated.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit project: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
      ),
      body: Stepper(
        steps: _steps(),
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: [
              if (_currentStep != 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(
                    _currentStep == _steps().length - 1 ? 'Submit' : 'Next'),
              ),
            ],
          );
        },
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
        'status': 'assigned',
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
