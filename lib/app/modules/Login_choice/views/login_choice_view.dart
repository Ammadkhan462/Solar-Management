import 'package:admin/Common%20widgets/common_utils.dart';
import 'package:admin/app/modules/EmployeeLoginPage/views/employee_login_page_view.dart';
import 'package:admin/app/modules/LoginPage/controllers/login_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/app/routes/app_pages.dart';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class LoginChoiceView extends StatelessWidget {
  const LoginChoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // SafeArea ensures no widget is hidden behind system UI like notch
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  // Logo image
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Image.asset(
                      'assets/icon/translogo.png',
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Buttons with soft corners and icons
                  _buildRoleButton(
                    context,
                    'Login as Admin',
                    Icons.admin_panel_settings,
                    Routes.LOGIN_PAGE,
                    AppTheme.deepBlack,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildRoleButton(
                    context,
                    'Login as Manager',
                    Icons.manage_accounts,
                    Routes.MANAGER_LOGIN,
                    AppTheme.primaryGreen,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildRoleButton(
                    context,
                    'Login as Employee',
                    Icons.person,
                    Routes.EMPLOYEE_LOGIN_PAGE,
                    AppTheme.buildingBlue,
                  ),
                  const Spacer(),
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

  // Reusable function for creating buttons with icons
  Widget _buildRoleButton(
    BuildContext context,
    String text,
    IconData icon,
    String route,
    Color color,
  ) {
    return AppTheme.buildLoginButton(
      text: text,
      onPressed: () => Get.toNamed(route),
      icon: icon,
      color: color,
    );
  }
}
