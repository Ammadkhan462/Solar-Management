import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/textbox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonTextBox(
              controller: controller.emailController,
              hintText: 'Enter your email',
            ),
            const SizedBox(height: 20),

            // Send Reset Link Button with Loading State
            Obx(() => CommonButton(
                  text: 'Send Reset Link',
                  onPressed: controller.sendPasswordReset,
                  isLoading: controller.isLoading.value,
                  width: 360,
                )),
          ],
        ),
      ),
    );
  }
}
