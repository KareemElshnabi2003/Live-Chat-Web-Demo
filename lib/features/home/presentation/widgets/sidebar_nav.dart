import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/main.dart';

class CustomSidebarNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomSidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: pref ? AppColors.blackColor : AppColors.bgColor,
      selectedIconTheme: IconThemeData(
        size: 28,
        color: pref ? AppColors.whiteColor : AppColors.blackTextColor,
      ),
      unselectedIconTheme: const IconThemeData(
        size: 24,
        color: AppColors.black2TextColor,
      ),
      labelType: NavigationRailLabelType.none,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(IconsaxPlusLinear.home_1),
          selectedIcon: Icon(IconsaxPlusBold.home_1),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(IconsaxPlusLinear.message),
          selectedIcon: Icon(IconsaxPlusBold.message),
          label: Text('Chats'),
        ),
        NavigationRailDestination(
          icon: Icon(IconsaxPlusLinear.shop),
          selectedIcon: Icon(IconsaxPlusBold.shop),
          label: Text('Market'),
        ),
        NavigationRailDestination(
          icon: Icon(IconsaxPlusLinear.setting),
          selectedIcon: Icon(IconsaxPlusBold.setting),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
