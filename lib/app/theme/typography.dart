import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Base styles
  static final TextStyle regular =
      GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 14);

  static final TextStyle medium =
      GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14);

  static final TextStyle semiBold =
      GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14);

  static final TextStyle bold =
      GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14);

  // Specialized styles referenced in the manager panel redesign
  static final TextStyle heading =
      GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18);

  static final TextStyle subheading =
      GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16);

  static final TextStyle small =
      GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 12);

  // Helper method to customize existing styles
  static TextStyle customStyle({
    required TextStyle baseStyle,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return baseStyle.copyWith(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
}
