import 'package:get/get.dart';

import '../controllers/employee_login_page_controller.dart';

class EmployeeLoginPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeLoginPageController>(
      () => EmployeeLoginPageController(),
    );
  }
}
