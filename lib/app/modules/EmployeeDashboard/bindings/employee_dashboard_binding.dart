import 'package:get/get.dart';

import '../controllers/employee_dashboard_controller.dart';

class EmployeeDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeDashboardController>(
      () => EmployeeDashboardController(),
    );
  }
}
