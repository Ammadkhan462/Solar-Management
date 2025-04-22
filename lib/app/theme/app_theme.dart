import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    textTheme: TextTheme(
      bodyLarge: AppTypography.regular, // Previously bodyText1
      bodyMedium: AppTypography.medium, // Previously bodyText2
      titleLarge: AppTypography.semiBold, // Previously headline6
      headlineSmall: AppTypography.bold, // Previously headline5
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      titleTextStyle: AppTypography.bold.copyWith(color: Colors.white),
    ),
  );
}
