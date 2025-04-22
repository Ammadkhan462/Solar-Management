import 'package:admin/app/modules/ManagerLogin/views/manager_login_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employee_login_page_controller.dart';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/textbox.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';

class EmployeeLoginPageView extends GetView<EmployeeLoginPageController> {
  const EmployeeLoginPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(120), // Increased height for more space
        child: ClipPath(
          clipper: WaveClipper(), // Custom wave clipper
          child: Container(
            height: 260, // Height of the wave container
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary
                      .withOpacity(0.8), // Primary color with opacity
                  AppColors.primary.withOpacity(0.6), // Lighter primary color
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // AppBar Content
                Container(
                  height: 120, // Height of the AppBar content
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () =>
                            Get.back(), // Go back to the previous screen
                      ),
                      const SizedBox(
                          width: 16), // Spacing between back button and text
                      // Employee Login Text
                      CommonText(
                        text: 'Employee Login',
                        style: AppTypography.bold.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email TextBox
            CommonTextBox(
              controller: controller.emailController,
              hintText: 'Email',
            ),

            // Password TextField with visibility toggle
            Obx(
              () => TextField(
                controller: controller.passwordController,
                obscureText: controller.isPasswordHidden.value,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(controller.isPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  hintText: 'Password',
                  hintStyle:
                      AppTypography.medium.copyWith(color: AppColors.lightGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.darkGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ).paddingAll(10),
            ),
            const SizedBox(height: 10),

            // Login Button or Loading Indicator
            Obx(
              () => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : CommonButton(
                      text: 'Login',
                      onPressed: controller.loginEmployee,
                      width: double.infinity, // Stretch to full width
                    ).paddingAll(10),
            ),

            // Sign Up Button
            TextButton(
              onPressed: () {
                // Navigate to sign-up or forgot password screen
                Get.toNamed('/signup-page');
              },
              child: const Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
