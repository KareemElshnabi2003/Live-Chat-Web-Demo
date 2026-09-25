import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/settings/presentation/widgets/language_button.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class NightModeView extends StatelessWidget {
  const NightModeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        pref = isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode ? AppColors.blackColor : AppColors.bgColor,
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isRtl ? 4.w : 4.w, vertical: 2.h),
            child: Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          isRtl
                              ? IconsaxPlusLinear.arrow_right_3
                              : IconsaxPlusLinear.arrow_left_1,
                          size: 5.5.w,
                          color: isDarkMode
                              ? AppColors.whiteColor
                              : AppColors.blackTextColor,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      textNormal(
                        S.of(context).nightMode,
                        isDarkMode
                            ? AppColors.whiteColor
                            : AppColors.blackTextColor,
                        4.5.w,
                        FontWeight.w500,
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  textNormal(
                    isDarkMode
                        ? S.of(context).darkModeEnabled
                        : S.of(context).lightMode,
                    isDarkMode
                        ? AppColors.whiteColor
                        : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w400,
                  ),
                  SizedBox(height: 3.h),
                  LanguageButton(
                    language: S.of(context).lightMode,
                    isSelected: !isDarkMode,
                    onTap: () {
                      context.read<ThemeCubit>().setTheme(false);
                      pref = false;
                    },
                  ),
                  LanguageButton(
                    language: S.of(context).darkMode,
                    isSelected: isDarkMode,
                    onTap: () {
                      context.read<ThemeCubit>().setTheme(true);
                      pref = true;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
