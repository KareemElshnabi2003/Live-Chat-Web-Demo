import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/core/widgets/text_click_widget.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:live_chat/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:live_chat/features/settings/presentation/widgets/row.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isRtl ? 4.w : 4.w, vertical: 2.h),
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: ListView(
            children: [
              _buildSectionTitle(S.of(context).settings, 4.5.w),
              SizedBox(height: 6.h),
              _buildSectionTitle(S.of(context).general, 3.5.w),
              SizedBox(height: 2.h),
              _buildRowOption(
                context: context,
                icon: LucideIcons.bell300,
                name: S.of(context).notifications,
                onTap: () => context.push(Routes.notificationsScreen),
              ),
              SizedBox(height: 2.h),
              _buildRowOption(
                context: context,
                icon: IconsaxPlusLinear.global,
                name: S.of(context).language,
                onTap: () => context.push(Routes.languageScreen),
              ),
              SizedBox(height: 2.h),
              _buildRowOption(
                context: context,
                icon: LucideIcons.moon300,
                name: S.of(context).nightMode,
                onTap: () => context.push(Routes.nightModeScreen),
              ),
              SizedBox(height: 2.5.h),
              _buildDivider(),
              SizedBox(height: 2.5.h),
              _buildSectionTitle(S.of(context).accountInformation, 3.5.w),
              SizedBox(height: 2.h),
              _buildRowOption(
                context: context,
                icon: IconsaxPlusLinear.profile,
                name: S.of(context).myAccount,
                onTap: () => context.push(Routes.myAccountScreen),
              ),
              SizedBox(height: 2.h),
              _buildRowOption(
                context: context,
                icon: IconsaxPlusLinear.flash,
                name: S.of(context).capabilities,
                onTap: () => context.push(Routes.capabilitiesScreen),
              ),
              SizedBox(height: 2.h),
              _buildRowOption(
                context: context,
                icon: LucideIcons.messageCircle300,
                name: S.of(context).chats,
                onTap: () => context.push(Routes.friendsScreen),
              ),
              SizedBox(height: 2.5.h),
              _buildDivider(),
              SizedBox(height: 2.5.h),
              _buildSectionTitle(S.of(context).help, 3.5.w),
              SizedBox(height: 2.h),
              _buildRowOption(
                context: context,
                icon: LucideIcons.tableOfContents300,
                name: S.of(context).termsAndConditions,
                onTap: () => context.push(Routes.termsScreen),
              ),
              SizedBox(height: 2.h),
              _buildRowOption(
                context: context,
                icon: IconsaxPlusLinear.security,
                name: S.of(context).privacy,
                onTap: () => context.push(Routes.privacyScreen),
              ),
              SizedBox(height: 2.h),
              _buildRowOption(
                context: context,
                icon: IconsaxPlusLinear.volume_high,
                name: "اعلن معنا",
                onTap: () => context.push(Routes.adsWithUsScreen),
              ),
              SizedBox(height: 2.5.h),
              _buildDivider(),
              SizedBox(height: 2.5.h),
              _buildLogOutButton(context),
              SizedBox(height: 2.5.h),
              _buildDeleteAccountButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double fontSize) {
    return textNormal(
      title,
      pref! ? AppColors.whiteColor : AppColors.blackTextColor,
      fontSize,
      FontWeight.w500,
    );
  }

  Widget _buildRowOption({
    required BuildContext context,
    required IconData icon,
    required String name,
    required VoidCallback onTap,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return row_optin(
      icon: Icon(icon,
          size: 5.5.w,
          color: pref! ? AppColors.whiteColor : AppColors.blackColor),
      name: name,
      ontap: onTap,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  Widget _buildDivider() {
    return Divider(color: pref! ? AppColors.darkcolor : AppColors.whiteColor);
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: () => _showDeleteAccountBottomSheet(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Icon(
                Icons.delete_outline,
                size: 5.5.w,
                color: AppColors.redColor,
              ),
              SizedBox(width: 2.w),
              textNormal(
                S.of(context).deleteAccount,
                AppColors.redColor,
                4.w,
                FontWeight.w400,
              ),
            ],
          ),
          Icon(
            isRtl
                ? IconsaxPlusLinear.arrow_right_3
                : IconsaxPlusLinear.arrow_left_1,
            size: 5.5.w,
            color: AppColors.redColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLogOutButton(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: () => _showLogOutBottomSheet(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Icon(
                IconsaxPlusLinear.logout,
                size: 5.5.w,
                color: AppColors.redColor,
              ),
              SizedBox(width: 2.w),
              textNormal(
                S.of(context).logOut,
                AppColors.redColor,
                4.w,
                FontWeight.w400,
              ),
            ],
          ),
          Icon(
            isRtl
                ? IconsaxPlusLinear.arrow_right_3
                : IconsaxPlusLinear.arrow_left_1,
            size: 5.5.w,
            color: AppColors.redColor,
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountBottomSheet(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    showModalBottomSheet(
      backgroundColor: pref! ? AppColors.darkcolor : AppColors.bgColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isRtl ? 2.w : 4.w, vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetHandle(),
              SizedBox(height: 1.h),
              _buildCancelButton(sheetContext),
              SizedBox(height: 3.h),
              _buildDeleteAccountImage(),
              SizedBox(height: 3.h),
              textNormal(
                  S.of(context).deletAccMsg,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  5.w,
                  FontWeight.w400),
              SizedBox(height: 2.h),
              _buildDeleteConfirmButton(context, sheetContext),
            ],
          ),
        );
      },
    );
  }

  void _showLogOutBottomSheet(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    showModalBottomSheet(
      backgroundColor: pref! ? AppColors.darkcolor : AppColors.bgColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isRtl ? 2.w : 4.w, vertical: 2.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetHandle(),
              SizedBox(height: 1.h),
              _buildCancelButton(sheetContext),
              SizedBox(height: 3.h),
              _buildDeleteAccountImage(),
              SizedBox(height: 3.h),
              textNormal(
                  S.of(context).logOut,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  5.w,
                  FontWeight.w400),
              SizedBox(height: 2.h),
              _buildDeleteConfirmationText(context),
              SizedBox(height: 1.h),
              _buildDeleteConsecondmationText(context),
              SizedBox(height: 2.h),
              _buildConfirmLogOutButton(context, sheetContext),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: ShapeDecoration(
          color: const Color(0xFF1A160E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      mainAxisAlignment:
          isRtl ? MainAxisAlignment.end : MainAxisAlignment.start,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        textClick(
          S.of(context).cancel,
          true,
          () => Navigator.pop(context),
          const Color(0xFFB8B633),
          3.5.w,
        ),
      ],
    );
  }

  Widget _buildDeleteAccountImage() {
    return Image.asset(
      'lib/Images/Group 1.png',
      width: 80.w,
      height: 20.h,
    );
  }

  Widget _buildDeleteConfirmationText(BuildContext context) {
    return Center(
      child: textNormal(
        S.of(context).willBeLoggedOut,
        AppColors.redColor,
        4.w,
        FontWeight.w400,
      ),
    );
  }

  Widget _buildDeleteConsecondmationText(BuildContext context) {
    return Center(
      child: textNormal(
        S.of(context).exitConfirmation,
        AppColors.redColor,
        4.w,
        FontWeight.w400,
      ),
    );
  }

  Widget _buildConfirmLogOutButton(BuildContext context, BuildContext sheetContext) {
    return InkWell(
      onTap: () async {
        Navigator.pop(sheetContext);
        await context.read<AuthCubit>().logout();
        if (context.mounted) {
          context.go(Routes.splashScreen);
        }
      },
      child: Container(
        width: double.infinity,
        height: 6.h,
        decoration: ShapeDecoration(
          color: const Color(0xFFC0392B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Center(
          child: textNormal(
            S.of(context).confirm,
            pref! ? AppColors.blackColor : AppColors.whiteColor,
            4.w,
            FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteConfirmButton(BuildContext context, BuildContext sheetContext) {
    return InkWell(
      onTap: () async {
        Navigator.pop(sheetContext);
        await context.read<SettingsCubit>().deleteAccount();
        if (context.mounted) {
          await context.read<AuthCubit>().logout();
          if (context.mounted) {
            context.go(Routes.splashScreen);
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 6.h,
        decoration: ShapeDecoration(
          color: const Color(0xFFC0392B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Center(
          child: textNormal(
            S.of(context).deleteAccount,
            pref! ? AppColors.blackColor : AppColors.whiteColor,
            4.w,
            FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
