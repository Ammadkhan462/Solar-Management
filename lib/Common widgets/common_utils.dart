// COMMON UTILS - Put this in a separate file like `lib/utils/theme_utils.dart`
import 'package:admin/Common%20widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class AppTheme {
  // Define theme colors based on Shaheer Enterprises logo
  static const Color primaryGreen = Color(0xFF7BC043);
  static const Color deepBlack = Color(0xFF212121);
  static const Color buildingBlue = Color(0xFF2C5282);
  static const Color accentOrange = Color(0xFFF8A13F);
  static const Color lightGray = Color(0xFFE0E0E0);

  // Wave components
  static Widget buildTopWave(double screenHeight) {
    return Container(
      height: screenHeight * 0.14,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [deepBlack, Color(0xFF333333)],
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
                [primaryGreen, primaryGreen.withOpacity(0.7)],
                [buildingBlue, buildingBlue.withOpacity(0.7)],
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
    );
  }

  static Widget buildBottomWave(double screenHeight) {
    return Container(
      height: screenHeight * 0.1,
      child: WaveWidget(
        config: CustomConfig(
          gradients: [
            [deepBlack, deepBlack.withOpacity(0.7)],
            [primaryGreen, primaryGreen.withOpacity(0.7)],
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
    );
  }

  static Widget buildAccentLine() {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentOrange.withOpacity(0.1),
            accentOrange,
            accentOrange.withOpacity(0.1)
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }

  // Login button style
  static Widget buildLoginButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : CommonButton(
                  text: text,
                  onPressed: onPressed,
                  width: double.infinity,
                  isPrimary: true,
                  isLoading: false,
                  isDisabled: false,
                  height: 55,
                  icon: icon,
                  color: color,
                ),
        ),
      ),
    );
  }
}
