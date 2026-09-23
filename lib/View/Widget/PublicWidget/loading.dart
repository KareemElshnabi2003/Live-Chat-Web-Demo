import 'package:flutter/material.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/Core/utils/responsive_nums.dart';
import 'package:shimmer/shimmer.dart';

Widget loading(height) {
  return SizedBox(
    height: height,
    width: 100.w,
    child: Shimmer.fromColors(
      baseColor: pref! ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: pref! ? Colors.grey[700]! : Colors.grey[100]!,
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
