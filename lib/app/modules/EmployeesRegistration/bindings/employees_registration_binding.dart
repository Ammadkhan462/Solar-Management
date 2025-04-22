import 'package:get/get.dart';

import '../controllers/employees_registration_controller.dart';

class EmployeesRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeesRegistrationController>(
      () => EmployeesRegistrationController(),
    );
  }
}
