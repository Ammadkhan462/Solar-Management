import 'package:admin/app/modules/EmployeeLoginPage/views/employee_login_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:admin/Common%20widgets/textbox.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';
import '../controllers/login_page_controller.dart';

// EXAMPLE IMPLEMENTATION - ADMIN LOGIN PAGE
class LoginPageView extends GetView<LoginPageController> {
  LoginPageView({Key? key}) : super(key: key);

  // Initialize controller in the constructor or using lazy initialization
  final controller = Get.put(LoginPageController());

  @override
  Widget build(BuildContext context) {
    return LoginPageTemplate(
      title: 'Admin Login',
      primaryColor: AppTheme.deepBlack,
      loginIcon: Icons.admin_panel_settings,
      emailController: controller.emailController,
      passwordController: controller.passwordController,
      isPasswordHidden: controller.isPasswordHidden,
      togglePasswordVisibility: controller.togglePasswordVisibility,
      onLoginPressed: controller.loginAdmin,
      isLoading: controller.isLoading,
      showSignUp: true,
      signUpRoute: Routes.SIGNUP_PAGE,
      showForgotPassword: true,
      forgotPasswordRoute: Routes.FORGOT_PASSWORD,
      showRememberMe: true,
      rememberMe: controller.rememberMe,
      toggleRememberMe: controller.toggleRememberMe,
    );
  }
}
