import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/textbox.dart';
import 'package:admin/app/modules/LoginPage/views/login_page_view.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_page_controller.dart';

class SignupPageView extends GetView<SignupPageController> {
  SignupPageView({Key? key}) : super(key: key);
  final controller = Get.put(SignupPageController());
  final signupFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupPageController>(
        init: SignupPageController(),
        builder: (_) {
          return Scaffold(
              appBar: AppBar(title: CommonText(text: 'Admin Signup')),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: signupFormKey,
                  child: Column(
                    children: [
                      CommonTextBox(
                        controller: _.name,
                        hintText: 'Name',
                      ),
                      CommonTextBox(
                        controller: _.emailController,
                        hintText: 'Email',
                      ),

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

                      // Confirm Password Field
                      Obx(() => TextField(
                            controller: _.confirmPasswordController,
                            obscureText: _.isConfirmPasswordHidden.value,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(_.isConfirmPasswordHidden.value
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: _.toggleConfirmPasswordVisibility,
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

                      const SizedBox(height: 20),
                      Obx(
                        () => CommonButton(
                          width: 360,
                          height: 50,
                          isLoading:
                              _.isLoading.value, // Observing isLoading state

                          onPressed: _.signupAdmin,
                          text: 'Signup',
                        ),
                      ),

                      SizedBox(height: 20),

                      // Login Button (Text Form)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommonText(text: "Already have an account?"),
                          TextButton(
                            onPressed: () {
                              Get.toNamed(
                                  Routes.LOGIN_PAGE); // Navigate to login page
                            },
                            child: CommonText(
                              text: "Login",
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
              ));
        });
  }
}
