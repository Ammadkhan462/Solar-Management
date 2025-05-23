import 'package:admin/app/theme/app_colors.dart';
import 'package:admin/app/theme/typography.dart';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSearch;

  const SearchBox({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTypography.regular,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.medium.copyWith(color: AppColors.lightGray),
        prefixIcon: Icon(Icons.search, color: AppColors.mediumGray),
        suffixIcon: IconButton(
          icon: const Icon(Icons.close, color: AppColors.mediumGray),
          onPressed: () {
            controller.clear();
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      onSubmitted: (value) => onSearch(),
    );
  }
}
