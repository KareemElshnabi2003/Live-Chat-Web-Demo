import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/settings/presentation/widgets/language_button.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class LanguageView extends StatefulWidget {
  const LanguageView({super.key});

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = CacheHelper.getString(key: "selectedLanguage") ?? 'ar';
  }

  Future<void> _changeLanguage(String lang) async {
    setState(() {
      _selectedLanguage = lang;
    });
    await CacheHelper.saveData(key: "selectedLanguage", value: lang);
    await S.load(Locale(lang));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = _selectedLanguage == 'ar';

    return Scaffold(
      backgroundColor: pref ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h, bottom: 2.h),
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      isRtl
                          ? IconsaxPlusLinear.arrow_right_3
                          : IconsaxPlusLinear.arrow_left_1,
                      size: 5.5.w,
                      color:
                          pref ? AppColors.whiteColor : AppColors.blackColor,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  textNormal(
                    S.of(context).language,
                    pref ? AppColors.whiteColor : AppColors.blackTextColor,
                    4.5.w,
                    FontWeight.w500,
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              textNormal(
                _selectedLanguage == 'ar'
                    ? S.of(context).arabic
                    : S.of(context).english,
                pref ? AppColors.whiteColor : AppColors.blackTextColor,
                3.5.w,
                FontWeight.w400,
              ),
              SizedBox(height: 3.h),
              LanguageButton(
                language: S.of(context).arabic,
                isSelected: _selectedLanguage == 'ar',
                onTap: () => _changeLanguage('ar'),
              ),
              LanguageButton(
                language: S.of(context).english,
                isSelected: _selectedLanguage == 'en',
                onTap: () => _changeLanguage('en'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
