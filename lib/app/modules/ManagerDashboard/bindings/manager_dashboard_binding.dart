import 'package:get/get.dart';

import '../controllers/manager_dashboard_controller.dart';

class ManagerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagerDashboardController>(
      () => ManagerDashboardController(),
    );
  }
}
