import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/core/constant/app_color.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/main.dart';

Widget otpWidget(String? verifyCode, Function(String)? onSubmit) {
  final isDark = pref;
  return Center(
    child: SizedBox(
      height: 12.h,
      width: 100.w,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OtpTextField(
          focusedBorderColor: isDark ? AppColors.bgColor : AppColors.blackColor,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.whiteColor : AppColors.primaryColor,
          ),
          fieldWidth: kIsWeb ? 45.0 : 12.w,
          fieldHeight: 7.h,
          borderColor: isDark ? AppColors.darkcolor : AppColors.whiteColor,
          borderWidth: 2,
          numberOfFields: 6,
          margin: EdgeInsets.only(
            right: kIsWeb ? 5.0 : 1.w,
            left: kIsWeb ? 5.0 : 1.w,
          ),
          fillColor: isDark ? AppColors.darkcolor : Colors.white,
          filled: true,
          borderRadius: BorderRadius.circular(20),
          showFieldAsBox: true,
          disabledBorderColor: isDark ? AppColors.darkcolor : AppColors.whiteColor,
          enabledBorderColor: isDark ? AppColors.darkcolor : AppColors.whiteColor,
          onSubmit: onSubmit,
        ),
      ),
    ),
  );
}
