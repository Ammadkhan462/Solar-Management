import 'package:flutter/material.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDisabled;
  final bool isLoading;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? color; // Nullable color

  const CommonButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true, // Default to true
    this.isDisabled = false, // Default to false
    this.isLoading = false, // Default to false
    this.width,
    this.height = 50.0,
    this.icon,
    this.color, // Nullable color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If isDisabled is true, button should be gray
    final buttonColor =
        color ?? (isPrimary ? AppColors.primary : AppColors.primaryLight1);

    Widget buttonContent = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: 24),
              if (icon != null) const SizedBox(width: 10),
              Text(
                text,
                style: AppTypography.bold.copyWith(
                  color: isDisabled ? AppColors.lightGray : Colors.white,
                ),
              ),
            ],
          );

    Widget button = ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.lightGray : buttonColor,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: Size(width ?? double.infinity, height),
        elevation: 5, // Added subtle shadow
        shadowColor: buttonColor.withOpacity(0.3),
      ),
      child: Center(child: buttonContent), // ✅ Center aligned content
    );

    return width == null ? Expanded(child: button) : button;
  }
}
