import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/textbox.dart';
import 'package:admin/app/modules/ManagerLogin/views/manager_login_view.dart';
import 'package:admin/app/modules/SignupPage/views/signup_page_view.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_page_controller.dart';

class LoginPageView extends GetView<LoginPageController> {
  LoginPageView({Key? key}) : super(key: key);
  final controller = Get.put(LoginPageController());
  final GlobalKey<FormState> _loginformkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginPageController>(
      init: LoginPageController(),
      builder: (_) {
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
                      AppColors.primary
                          .withOpacity(0.6), // Lighter primary color
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
                              width:
                                  16), // Spacing between back button and text
                          // Login Title
                          CommonText(
                            text: 'Admin Login',
                            style: AppTypography.bold
                                .copyWith(color: Colors.white),
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
            child: Form(
              key: _loginformkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Email TextBox
                  CommonTextBox(
                    controller: _.emailController,
                    hintText: 'Email',
                  ),

                  // Password TextField with visibility toggle
                  Obx(() => TextField(
                        controller: _.passwordController,
                        obscureText: _.isPasswordHidden.value,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(_.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: _.togglePasswordVisibility,
                          ),
                          hintText: 'Password',
                          hintStyle: AppTypography.medium
                              .copyWith(color: AppColors.lightGray),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppColors.darkGray),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ).paddingAll(10)),

                  // Remember Me Checkbox
                  Obx(() => Row(
                        children: [
                          Checkbox(
                            value: _.rememberMe.value,
                            onChanged: (value) => _.toggleRememberMe(),
                          ),
                          CommonText(text: "Remember Me"),
                          const Spacer(),
                          TextButton(
                            onPressed: () =>
                                Get.toNamed(Routes.FORGOT_PASSWORD),
                            child: CommonText(
                              text: "Forgot Password?",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )),

                  const SizedBox(height: 20),

                  // Login Button with Loading State
                  Obx(() => CommonButton(
                        text: 'Login',
                        onPressed: _.loginAdmin,
                        isLoading: _.isLoading.value,
                        width: 360,
                      ).paddingAll(10)),

                  const SizedBox(height: 20),

                  // Signup Button (Text Form)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CommonText(text: "Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Get.offAll(
                              SignupPageView()); // Navigate to Signup Page
                        },
                        child: CommonText(
                          text: "Sign Up",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
