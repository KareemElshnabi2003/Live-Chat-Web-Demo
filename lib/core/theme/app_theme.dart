import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgColor,
      primaryColor: AppColors.primaryColor,
      cardColor: AppColors.whiteColor,
      dividerColor: AppColors.inActiveColor.withOpacity(0.3),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        surface: AppColors.whiteColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.blackTextColor),
        titleTextStyle: TextStyle(
          color: AppColors.blackTextColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.blackTextColor),
        bodyMedium: TextStyle(color: AppColors.black2TextColor),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkcolor,
      primaryColor: AppColors.primaryColor,
      cardColor: AppColors.cardDarkColor,
      dividerColor: AppColors.inActiveColor.withOpacity(0.2),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        surface: AppColors.cardDarkColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.whiteColor),
        titleTextStyle: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.whiteColor),
        bodyMedium: TextStyle(color: AppColors.inActiveColor),
      ),
    );
  }
}