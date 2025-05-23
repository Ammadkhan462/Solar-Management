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

// This is an improved text input widget that works around the crash issue
class SafeTextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function()? onToggleVisibility;
  final bool isPassword;
  final bool isObscured;
  final String? Function(String?)? validator;

  const SafeTextInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onToggleVisibility,
    this.isPassword = false,
    this.isObscured = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && isObscured,
        keyboardType: keyboardType,
        validator: validator,
        // Add these settings to work around the crash
        enableIMEPersonalizedLearning: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.deepBlack,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}

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
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

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

          // Bottom wave and accent line
          if (!keyboardVisible) ...[
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppTheme.buildBottomWave(screenHeight),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppTheme.buildAccentLine(),
            ),
          ],

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                height: screenHeight - MediaQuery.of(context).padding.top,
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
                          SafeTextInputField(
                            controller: emailController,
                            hintText: "Enter your email",
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16),

                          // Password TextField with visibility toggle
                          Obx(() => SafeTextInputField(
                                controller: passwordController,
                                hintText: "Enter your password",
                                isPassword: true,
                                isObscured: isPasswordHidden.value,
                                onToggleVisibility: togglePasswordVisibility,
                              )),
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
          ),
        ],
      ),
    );
  }
}

class EmployeeLoginPageView extends GetView<EmployeeLoginPageController> {
  const EmployeeLoginPageView({super.key});

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
