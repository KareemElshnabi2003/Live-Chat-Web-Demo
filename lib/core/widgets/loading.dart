import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constant/app_constant.dart';
import '../helper/cache_helper.dart';
import '../utils/responsive_nums.dart';

Widget loading(double height) {
  final bool isDark = CacheHelper.getBool(key: AppConstants.isDarkModeKey) ?? false;
  return SizedBox(
    height: height,
    width: 100.w,
    child: Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Center(
        child: Container(
          height: 4.h,
          width: 4.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    ),
  );
}
