import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../helper/cache_helper.dart';
import '../constant/app_constant.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final bool isDark = CacheHelper.getBool(key: AppConstants.isDarkModeKey) ?? false;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> toggleTheme() async {
    final isCurrentlyDark = state == ThemeMode.dark;
    await CacheHelper.saveData(key: AppConstants.isDarkModeKey, value: !isCurrentlyDark);
    emit(!isCurrentlyDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setTheme(bool isDark) async {
    await CacheHelper.saveData(key: AppConstants.isDarkModeKey, value: isDark);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}