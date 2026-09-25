// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';

class Button extends StatelessWidget {
  final VoidCallback? ontap;
  final String text;
  final double? radius;
  final bool isLoading;

  const Button({
    super.key,
    required this.ontap,
    required this.text,
    this.radius,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = ontap == null || isLoading;

    return GestureDetector(
      onTap: isDisabled ? null : ontap,
      child: Container(
        width: double.infinity,
        height: 6.h,
        decoration: ShapeDecoration(
          color: isDisabled
              ? (pref!
                  ? AppColors.secondaryColor.withOpacity(0.6)
                  : const Color(0xFF243C21).withOpacity(0.6))
              : (pref! ? AppColors.secondaryColor : const Color(0xFF243C21)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 12),
          ),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pref! ? AppColors.blackColor : AppColors.whiteColor,
                    ),
                  ),
                )
              : textNormal(
                  text,
                  pref! ? AppColors.blackColor : AppColors.whiteColor,
                  4.w,
                  FontWeight.w500,
                ),
        ),
      ),
    );
  }
}
