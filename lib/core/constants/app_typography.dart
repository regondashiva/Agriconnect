import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Be Vietnam Pro headline styles
  static TextStyle headlineLarge = GoogleFonts.beVietnamPro(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textNavy,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static TextStyle headlineMedium = GoogleFonts.beVietnamPro(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textNavy,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle headlineSmall = GoogleFonts.beVietnamPro(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textNavy,
  );

  // Body styles (accessible 18px / 16px)
  static TextStyle bodyLarge = GoogleFonts.beVietnamPro(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.45,
  );

  static TextStyle bodyMedium = GoogleFonts.beVietnamPro(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.beVietnamPro(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.35,
  );

  // Labels & Chips
  static TextStyle labelLarge = GoogleFonts.beVietnamPro(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textNavy,
    letterSpacing: 0.2,
  );

  static TextStyle labelSmall = GoogleFonts.beVietnamPro(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle buttonText = GoogleFonts.beVietnamPro(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
