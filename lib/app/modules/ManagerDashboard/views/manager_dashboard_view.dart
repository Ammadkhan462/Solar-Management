import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import '../controllers/manager_dashboard_controller.dart';

class ManagerDashboardView extends GetView<ManagerDashboardController> {
  ManagerDashboardView({Key? key}) : super(key: key);

  final ManagerDashboardController controller =
      Get.put(ManagerDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Managers Credentials"),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.managersList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: controller.managersList.length,
            itemBuilder: (context, index) {
              final manager = controller.managersList[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(manager.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Manager CNIC
                      Text("CNIC: ${manager.cnic}",
                          style: const TextStyle(fontSize: 16)),

                      // Email Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Email: ${manager.email}",
                              style: const TextStyle(fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.blue),
                            onPressed: () {
                              // Copy email to clipboard
                              Clipboard.setData(
                                  ClipboardData(text: manager.email));
                              Get.snackbar("Copied",
                                  "Manager's email copied to clipboard.");
                            },
                          ),
                        ],
                      ),

                      // Password Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Password: ${manager.password}",
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.red)),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.blue),
                            onPressed: () {
                              // Copy password to clipboard
                              Clipboard.setData(
                                  ClipboardData(text: manager.password));
                              Get.snackbar("Copied",
                                  "Manager's password copied to clipboard.");
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
