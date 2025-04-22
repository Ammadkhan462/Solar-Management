import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dash_board_controller.dart';

class DashBoardView extends GetView<DashBoardController> {
  DashBoardView({Key? key}) : super(key: key);

  final DashBoardController controller = Get.put(DashBoardController());
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: DashBoardController(),
      builder: (_) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize:
                const Size.fromHeight(120), // Increased height for more space
            child: ClipPath(
              clipper: WaveClipper(), // Custom wave clipper
              child: Container(
                height: 260, // Height of the wave container
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary
                          .withOpacity(0.8), // Primary color with opacity
                      AppColors.primary
                          .withOpacity(0.6), // Lighter primary color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // AppBar Content
                    Container(
                      height: 120, // Height of the AppBar content
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Back Button
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () =>
                                Get.back(), // Go back to the previous screen
                          ),
                          const SizedBox(
                              width:
                                  16), // Spacing between back button and text
                          // Dashboard Title
                          CommonText(
                            text: 'Admin Dashboard',
                            style: AppTypography.bold
                                .copyWith(color: Colors.white),
                          ),
                          const Spacer(), // Add space between title and logout button
                          // Logout Button
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: _.logout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(() {
                  return Column(
                    children: [
                      Text(
                        "Welcome, ${_.admin.value.name}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Email: ${_.admin.value.email}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 20),

                // ✅ Register Manager Form
                const Text("Register Manager",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Manager Name"),
                ),
                TextField(
                  controller: cnicController,
                  decoration: const InputDecoration(labelText: "Manager CNIC"),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  return _.isLoading.value
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            controller.registerManager(
                              nameController.text,
                              cnicController.text,
                            );
                            nameController.clear();
                            cnicController.clear();
                          },
                          child: const Text("Register Manager"),
                        );
                }),

                const SizedBox(height: 30),

                // ✅ Show List of Managers
                Center(
                  child: ElevatedButton(
                    onPressed: _.navigateToManagerDashboard,
                    child: const Text("Show Managers"),
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

// Custom Wave Clipper for creating smooth wave shapes for each section
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start from the top-left corner
    path.lineTo(0, size.height * 0.5); // Move to the starting point of the wave

    // Create a smooth first curve (left side)
    path.quadraticBezierTo(
      size.width * 0.25, // Control point X (smooth start)
      size.height * 0.7, // Control point Y (smooth curve)
      size.width * 0.5, // End point X (center)
      size.height * 0.5, // End point Y (smooth curve)
    );

    // Create a smoother second curve (right side)
    path.quadraticBezierTo(
      size.width * 0.75, // Control point X (smooth right curve)
      size.height * 0.4, // Control point Y (gentle curve)
      size.width, // End point X
      size.height * 0.5, // End point Y
    );

    // Complete the path
    path.lineTo(size.width, 0); // Move to the top-right corner
    path.lineTo(0, 0); // Close the path (top-left corner)

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // No need to reclip
  }
}
