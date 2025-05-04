// UNIFIED LOGIN VIEW - Put this in a separate file like `lib/common_widgets/login_page_template.dart`
import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:admin/app/modules/EmployeeLoginPage/controllers/employee_login_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/textbox.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';

class LoginPageTemplate extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final IconData loginIcon;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final RxBool isPasswordHidden;
  final Function() togglePasswordVisibility;
  final Function() onLoginPressed;
  final RxBool isLoading;
  final bool showSignUp;
  final String? signUpRoute;
  final bool showForgotPassword;
  final String? forgotPasswordRoute;
  final bool showRememberMe;
  final RxBool? rememberMe;
  final Function()? toggleRememberMe;

  const LoginPageTemplate({
    Key? key,
    required this.title,
    required this.primaryColor,
    required this.loginIcon,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordHidden,
    required this.togglePasswordVisibility,
    required this.onLoginPressed,
    required this.isLoading,
    this.showSignUp = false,
    this.signUpRoute,
    this.showForgotPassword = false,
    this.forgotPasswordRoute,
    this.showRememberMe = false,
    this.rememberMe,
    this.toggleRememberMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.12),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: AppTheme.deepBlack),
                      onPressed: () => Get.back(),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.05),

                  // Title Text
                  Center(
                    child: CommonText(
                      text: title,
                      style: AppTypography.bold.copyWith(
                        color: primaryColor,
                        fontSize: 24,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.08),

                  // Login Form
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Email TextBox
                        CommonTextBox(
                          controller: emailController,
                          hintText: 'Email',
                        ),

                        SizedBox(height: 16),

                        // Password TextField with visibility toggle
                        Obx(
                          () => Container(
                            padding: EdgeInsets.symmetric(horizontal: 11.0),
                            child: TextField(
                              controller: passwordController,
                              obscureText: isPasswordHidden.value,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordHidden.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: primaryColor,
                                  ),
                                  onPressed: togglePasswordVisibility,
                                ),
                                hintText: 'Password',
                                hintStyle: AppTypography.medium
                                    .copyWith(color: AppTheme.lightGray),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppTheme.lightGray),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Remember Me & Forgot Password
                        if (showRememberMe || showForgotPassword)
                          Obx(() => Row(
                                children: [
                                  if (showRememberMe &&
                                      rememberMe != null &&
                                      toggleRememberMe != null) ...[
                                    Checkbox(
                                      value: rememberMe!.value,
                                      onChanged: (_) => toggleRememberMe!(),
                                      activeColor: primaryColor,
                                    ),
                                    CommonText(text: "Remember Me"),
                                  ],
                                  const Spacer(),
                                  if (showForgotPassword &&
                                      forgotPasswordRoute != null)
                                    TextButton(
                                      onPressed: () =>
                                          Get.toNamed(forgotPasswordRoute!),
                                      child: CommonText(
                                        text: "Forgot Password?",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              )),

                        SizedBox(height: screenHeight * 0.04),

                        // Login Button
                        Obx(
                          () => AppTheme.buildLoginButton(
                            text: 'Login',
                            onPressed: onLoginPressed,
                            icon: loginIcon,
                            color: primaryColor,
                            isLoading: isLoading.value,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Sign Up Button
                        if (showSignUp && signUpRoute != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CommonText(text: "Don't have an account?"),
                              TextButton(
                                onPressed: () => Get.toNamed(signUpRoute!),
                                child: CommonText(
                                  text: "Sign Up",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

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
        ],
      ),
    );
  }
}

class EmployeeLoginPageView extends GetView<EmployeeLoginPageController> {
  const EmployeeLoginPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoginPageTemplate(
      title: 'Employee Login',
      primaryColor: AppTheme.buildingBlue,
      loginIcon: Icons.person,
      emailController: controller.emailController,
      passwordController: controller.passwordController,
      isPasswordHidden: controller.isPasswordHidden,
      togglePasswordVisibility: controller.togglePasswordVisibility,
      onLoginPressed: controller.loginEmployee,
      isLoading: controller.isLoading,
      showSignUp: true,
      signUpRoute: '/signup-page',
    );
  }
}
