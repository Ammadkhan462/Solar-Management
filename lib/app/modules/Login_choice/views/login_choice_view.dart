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
  const LoginChoiceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                  SizedBox(height: screenHeight * 0.2),
                  // Title with modern typography and soft shadow
                  CommonText(
                    text: "Welcome!",
                    style: AppTypography.bold.copyWith(
                      color: AppColors.primary,
                      fontSize: screenHeight * 0.035, // Responsive font size
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  // Buttons with soft corners and icons
                  _buildRoleButton(
                    context,
                    'Login as Admin',
                    Icons.admin_panel_settings,
                    Routes.LOGIN_PAGE,
                    AppColors.primary,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildRoleButton(
                    context,
                    'Login as Manager',
                    Icons.manage_accounts,
                    Routes.MANAGER_LOGIN,
                    AppColors.primary,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildRoleButton(
                    context,
                    'Login as Employee',
                    Icons.person,
                    Routes.EMPLOYEE_LOGIN_PAGE,
                    AppColors.primary,
                  ),
                  const Spacer(), // Push buttons upwards to leave space for the wave
                ],
              ),
            ),
          ),

          // Custom Navigation Bar (Top) with proper wave effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.14, // 20% of screen height
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlue], // Blue gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  WaveWidget(
                    config: CustomConfig(
                      gradients: [
                        [Colors.blue, Colors.blueAccent],
                        [Colors.lightBlue, Colors.lightBlueAccent],
                      ],
                      durations: [5000, 8000],
                      heightPercentages: [0.15, 0.25],
                      gradientBegin: Alignment.bottomLeft,
                      gradientEnd: Alignment.topRight,
                    ),
                    backgroundColor: Colors.transparent,
                    size: Size(double.infinity, screenHeight * 0.05),
                    waveAmplitude: 0,
                  ),
                ],
              ),
            ),
          ),

          // Bottom wave bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.1, // 10% of screen height
              child: WaveWidget(
                config: CustomConfig(
                  gradients: [
                    [Colors.blue, Colors.blueAccent],
                    [Colors.green, Colors.greenAccent],
                  ],
                  durations: [5000, 8000],
                  heightPercentages: [0.15, 0.25],
                  gradientBegin: Alignment.bottomLeft,
                  gradientEnd: Alignment.topRight,
                ),
                backgroundColor: Colors.transparent,
                size: Size(double.infinity, screenHeight * 0.1),
                waveAmplitude: 0,
              ),
            ),
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
    return SizedBox(
      width: double.infinity, // Stretch to full width
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30), // Rounded corners
        child: Container(
          color: color.withOpacity(0.9), // Slight opacity for a soft effect
          child: CommonButton(
            text: text,
            onPressed: () {
              Get.toNamed(route); // Navigate to respective login page
            },
            width: double.infinity, // Stretch to full width
            isPrimary: true,
            isLoading: false,
            isDisabled: false,
            height: 55,
            icon: icon, // Pass the icon to the button
            color: color, // Pass the color to the button
          ),
        ),
      ),
    );
  }
}
