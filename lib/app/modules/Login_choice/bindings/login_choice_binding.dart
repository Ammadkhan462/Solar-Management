import 'package:get/get.dart';

import '../controllers/login_choice_controller.dart';

class LoginChoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginChoiceController>(
      () => LoginChoiceController(),
    );
  }
}
