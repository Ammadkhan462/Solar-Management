import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/textbox.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/signup_page_controller.dart';

class SignupPageView extends GetView<SignupPageController> {
  const SignupPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GetBuilder<SignupPageController>(
      init: SignupPageController(),
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Top wave effect
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppTheme.buildTopWave(screenHeight),
              ),

              // Bottom wave bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AppTheme.buildBottomWave(screenHeight),
              ),

              // Accent line with the orange color
              Positioned(
                bottom: screenHeight * 0.1,
                left: 0,
                right: 0,
                child: AppTheme.buildAccentLine(),
              ),

              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.08,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.05),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: AppTheme.deepBlack),
                            onPressed: () => Get.back(),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Title Text
                        Center(
                          child: CommonText(
                            text: 'Admin Signup',
                            style: AppTypography.bold.copyWith(
                              color: AppTheme.buildingBlue,
                              fontSize: 24,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // Signup Form
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Form(
                            key: GlobalKey<FormState>(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Name TextBox
                                CommonTextBox(
                                  controller: _.name,
                                  hintText: 'Name',
                                ),

                                // Email TextBox
                                CommonTextBox(
                                  controller: _.emailController,
                                  hintText: 'Email',
                                ),

                                SizedBox(height: 8),

                                // Password TextField with visibility toggle
                                Obx(() => Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 11.0),
                                      child: TextField(
                                        controller: _.passwordController,
                                        obscureText: _.isPasswordHidden.value,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _.isPasswordHidden.value
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: AppTheme.buildingBlue,
                                            ),
                                            onPressed:
                                                _.togglePasswordVisibility,
                                          ),
                                          hintText: 'Password',
                                          hintStyle: AppTypography.medium
                                              .copyWith(
                                                  color: AppTheme.lightGray),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: AppTheme.lightGray),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: AppTheme.buildingBlue),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                        ),
                                      ),
                                    )),

                                SizedBox(height: 16),

                                // Confirm Password Field
                                Obx(() => Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 11.0),
                                      child: TextField(
                                        controller: _.confirmPasswordController,
                                        obscureText:
                                            _.isConfirmPasswordHidden.value,
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _.isConfirmPasswordHidden.value
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: AppTheme.buildingBlue,
                                            ),
                                            onPressed: _
                                                .toggleConfirmPasswordVisibility,
                                          ),
                                          hintText: 'Confirm Password',
                                          hintStyle: AppTypography.medium
                                              .copyWith(
                                                  color: AppTheme.lightGray),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: AppTheme.lightGray),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: AppTheme.buildingBlue),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                        ),
                                      ),
                                    )),

                                SizedBox(height: screenHeight * 0.03),

                                // Signup Button
                                Obx(
                                  () => AppTheme.buildLoginButton(
                                    text: 'Sign Up',
                                    onPressed: _.signupAdmin,
                                    icon: Icons.person_add,
                                    color: AppTheme.buildingBlue,
                                    isLoading: _.isLoading.value,
                                  ),
                                ),

                                SizedBox(height: 20),

                                // Login Button (Text Form)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CommonText(
                                        text: "Already have an account?"),
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: CommonText(
                                        text: "Login",
                                        style: TextStyle(
                                          color: AppTheme.buildingBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Add extra space at bottom to ensure scrollability
                                SizedBox(height: screenHeight * 0.15),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
