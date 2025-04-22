import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin/app/modules/ManagerLogin/controllers/manager_login_controller.dart';
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:admin/Common%20widgets/common_text.dart';
import 'package:admin/Common%20widgets/textbox.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';

class ManagerLoginView extends StatelessWidget {
  ManagerLoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ManagerLoginController(),
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
                          .withOpacity(0.9), // Primary color with opacity
                      AppColors.primary
                          .withOpacity(0.7), // Lighter primary color
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
                          // Manager Login Text
                          CommonText(
                            text: 'Manager Login',
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email TextBox
                CommonTextBox(
                  controller: _.emailController,
                  hintText: 'Email',
                ),

                // Password TextField with visibility toggle
                Obx(
                  () => TextField(
                    controller: _.passwordController,
                    obscureText: _.isPasswordHidden.value,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(_.isPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => _.isPasswordHidden.toggle(),
                      ),
                      hintText: 'Password',
                      hintStyle: AppTypography.medium
                          .copyWith(color: AppColors.lightGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.darkGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ).paddingAll(10),
                ),
                const SizedBox(height: 10),

                // Login Button
                CommonButton(
                  text: 'Login',
                  onPressed: _.loginManager,
                  width: double.infinity, // Stretch to full width
                ).paddingAll(10),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Custom Wave Clipper for creating smooth wave shapes for each section
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start from the top-left corner
    path.lineTo(0, size.height * 0.5); // Move to the starting point of the wave

    // Create a smooth first curve (left side)
    path.quadraticBezierTo(
      size.width * 0.25, // Control point X (smooth start)
      size.height * 0.7, // Control point Y (smooth curve)
      size.width * 0.5, // End point X (center)
      size.height * 0.5, // End point Y (smooth curve)
    );

    // Create a smoother second curve (right side)
    path.quadraticBezierTo(
      size.width * 0.75, // Control point X (smooth right curve)
      size.height * 0.4, // Control point Y (gentle curve)
      size.width, // End point X
      size.height * 0.5, // End point Y
    );

    // Complete the path
    path.lineTo(size.width, 0); // Move to the top-right corner
    path.lineTo(0, 0); // Close the path (top-left corner)

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // No need to reclip
  }
}
