import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat/core/constant/app_color.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final page = CacheHelper.getString(key: AppConstants.pageKey);
      if (page == 'Home') {
        context.go(Routes.homeScreen);
      } else {
        context.go(Routes.startPageScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SizedBox(
        height: 100.h,
        width: 100.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            textNormal(
              S.of(context).splashText,
              AppColors.blackTextColor,
              3.5.w,
              FontWeight.w400,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
