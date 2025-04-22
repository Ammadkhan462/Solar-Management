import 'package:get/get.dart';

import '../controllers/manager_panel_controller.dart';

class ManagerPanelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagerPanelController>(
      () => ManagerPanelController(),
    );
  }
}
