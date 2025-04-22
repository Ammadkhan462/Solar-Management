import 'package:get/get.dart';

import '../controllers/manager_login_controller.dart';

class ManagerLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagerLoginController>(
      () => ManagerLoginController(),
    );
  }
}
