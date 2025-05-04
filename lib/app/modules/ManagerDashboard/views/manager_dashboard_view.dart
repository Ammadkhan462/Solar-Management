import 'package:admin/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import '../controllers/manager_dashboard_controller.dart';

class ManagerDashboardView extends GetView<ManagerDashboardController> {
  const ManagerDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Managers Credentials"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.offAllNamed(Routes.LOGIN_CHOICE),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.managersList.isEmpty) {
          return const Center(child: Text("No managers found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.managersList.length,
          itemBuilder: (context, index) {
            final manager = controller.managersList[index];
            return _buildManagerCard(manager);
          },
        );
      }),
    );
  }

  Widget _buildManagerCard(ManagerModel manager) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              manager.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text("CNIC: ${manager.cnic}"),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text("Email: ${manager.email}")),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: manager.email));
                    Get.snackbar("Copied", "Email copied to clipboard");
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Password: ${manager.password}",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: manager.password));
                    Get.snackbar("Copied", "Password copied to clipboard");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
