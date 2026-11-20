import 'package:flutter/material.dart';

/// App colors.
class AppColors {
  AppColors._();

  static const white = Color(0xFFFFFFFF);

  // Brand — monochrome
  static const primary = Color(0xFF000000);
  static const primaryDark = Color(0xFF000000);
  static const primaryTint = Color(0xFFF5F5F5);
  static const primaryLight = Color(0xFFE5E5E5);
  static const primaryBorder = Color(0xFFD4D4D4);

  // Surfaces and lines
  static const background = Color(0xFFFAFAFA);
  static const inputFill = Color(0xFFF5F5F5);
  static const border = Color(0xFFE5E5E5);
  static const disabled = Color(0xFFD4D4D4);

  // Text
  static const textPrimary = Color(0xFF000000);
  static const textStrong = Color(0xFF171717);
  static const textSecondary = Color(0xFF404040);
  static const textMuted = Color(0xFF737373);
  static const textHint = Color(0xFFA3A3A3);

  // Status — monochrome
  static const danger = Color(0xFF000000);
  static const dangerSoft = Color(0xFFF5F5F5);
}

/// Spacing scale (logical pixels).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Corner radii.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Shadows.
class AppShadows {
  AppShadows._();

  static const soft = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static const medium = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}

/// Text styles (color is set where used).
class AppText {
  AppText._();

  static const caption = TextStyle(fontSize: 12, height: 1.33);
  static const bodySmall = TextStyle(fontSize: 14, height: 1.43);
  static const body = TextStyle(fontSize: 16, height: 1.5);
  static const heading = TextStyle(fontSize: 24, height: 1.33);
  static const display = TextStyle(fontSize: 30, height: 1.2);
}