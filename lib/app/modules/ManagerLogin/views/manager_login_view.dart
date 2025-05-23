import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:admin/app/modules/EmployeeLoginPage/controllers/employee_login_page_controller.dart';
import 'package:admin/app/modules/EmployeeLoginPage/views/employee_login_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/app/modules/ManagerLogin/controllers/manager_login_controller.dart';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/textbox.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';

class ManagerLoginView extends GetView<ManagerLoginController> {
  const ManagerLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // This prevents resizing when keyboard appears
      body: LoginPageTemplate(
        title: 'Manager Login',
        primaryColor: AppTheme.primaryGreen,
        loginIcon: Icons.manage_accounts,
        emailController: controller.emailController,
        passwordController: controller.passwordController,
        isPasswordHidden: controller.isPasswordHidden,
        togglePasswordVisibility: () => controller.isPasswordHidden.toggle(),
        onLoginPressed: controller.loginManager,
        isLoading: controller.isLoading,
        showSignUp: false,
        showForgotPassword: false,
      ),
    );
  }
}
