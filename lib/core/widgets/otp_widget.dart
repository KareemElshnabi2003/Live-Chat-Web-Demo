import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/main.dart';

Widget otpWidget(String? verifyCode, Function(String)? onSubmit) {
  final isDark = pref;
  return Center(
    child: SizedBox(
      height: kIsWeb ? 70.0 : 12.h,
      width: kIsWeb ? 420.0 : 100.w,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OtpTextField(
          focusedBorderColor: isDark ? AppColors.bgColor : AppColors.blackColor,
          mainAxisAlignment: MainAxisAlignment.center,
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: kIsWeb ? 22.0 : 20.0,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.whiteColor : AppColors.blackTextColor,
          ),
          fieldWidth: kIsWeb ? 52.0 : 12.w,
          fieldHeight: kIsWeb ? 60.0 : 7.h,
          borderColor: isDark ? AppColors.darkcolor : AppColors.whiteColor,
          borderWidth: 2,
          numberOfFields: 6,
          margin: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 6.0 : 1.w,
          ),
          fillColor: isDark ? AppColors.darkcolor : Colors.white,
          filled: true,
          borderRadius: BorderRadius.circular(16),
          showFieldAsBox: true,
          disabledBorderColor: isDark ? AppColors.darkcolor : AppColors.whiteColor,
          enabledBorderColor: isDark ? AppColors.darkcolor : AppColors.whiteColor,
          onSubmit: onSubmit,
        ),
      ),
    ),
  );
}
