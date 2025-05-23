import 'package:flutter/material.dart';
import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';

// In common_button.dart
class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Change to nullable
  final bool isPrimary;
  final bool isDisabled;
  final bool isLoading;
  final double? width;
  final double height;
  final IconData? icon;
  final Color? color;
  final double? textsize;

  const CommonButton({
    super.key,
    required this.text,
    this.onPressed, // Nullable
    this.isPrimary = true,
    this.isDisabled = false,
    this.isLoading = false,
    this.width,
    this.height = 50.0,
    this.icon,
    this.color,
    this.textsize, // Remove default here
  });

  @override
  Widget build(BuildContext context) {
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
              if (icon != null) const SizedBox(width: 4),
              Text(
                text,
                style: AppTypography.bold.copyWith(
                  color: isDisabled ? AppColors.lightGray : Colors.white,
                  fontSize: textsize ?? 16.0, // Use input textsize if provided
                ),
              ),
            ],
          );

    Widget button = ElevatedButton(
      onPressed:
          isDisabled || isLoading || onPressed == null ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.lightGray : buttonColor,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: Size(width ?? double.infinity, height),
        elevation: 5,
        shadowColor: buttonColor.withOpacity(0.3),
      ),
      child: Center(child: buttonContent),
    );

    return width == null ? Expanded(child: button) : button;
  }
}
