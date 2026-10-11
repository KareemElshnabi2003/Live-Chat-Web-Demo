import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/features/market/data/models/power_model.dart';
import 'package:live_chat/core/widgets/storetext.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';

// ignore: non_constant_identifier_names
Widget SuggestedFriends({
  required ImageProvider img,
  required PowerModel? power,
  required String ttitle,
  required bool imgUrl,
  required String body,
  required VoidCallback sendRequest,
  required VoidCallback removeRequest,
  required VoidCallback chat,
  required VoidCallback onPressImg,
  required bool requestSend,
  bool isRtl = true,
}) {
  final double avatarSize = kIsWeb ? 52.0 : 14.w;

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
    child: Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        // Avatar
        InkWell(
          onTap: onPressImg,
          borderRadius: BorderRadius.circular(80),
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: pref ? AppColors.darkcolor : AppColors.black2TextColor,
              image: imgUrl
                  ? DecorationImage(
                      image: img,
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: BorderRadius.circular(80),
            ),
            alignment: Alignment.center,
            child: !imgUrl
                ? textNormal(
                    ttitle.isNotEmpty ? ttitle[0] : '',
                    AppColors.whiteColor,
                    kIsWeb ? 22.0 : 6.w,
                    FontWeight.bold,
                  )
                : null,
          ),
        ),
        SizedBox(width: kIsWeb ? 12 : 3.w),
        // Friend Info
        Expanded(
          child: InkWell(
            onTap: requestSend ? removeRequest : sendRequest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                power.toString() == "null" || power == null
                    ? textNormal(
                        ttitle,
                        pref ? AppColors.whiteColor : AppColors.blackTextColor,
                        kIsWeb ? 15.0 : 3.5.w,
                        FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : PowerTextWidget(
                        powerModel: power,
                        displyText: ttitle,
                      ),
                const SizedBox(height: 4),
                textNormal(
                  body,
                  requestSend
                      ? AppColors.secondaryColor
                      : (pref
                          ? AppColors.inActiveColor
                          : AppColors.black2TextColor),
                  kIsWeb ? 13.0 : 3.w,
                  FontWeight.w500,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Action Buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: pref ? AppColors.darkcolor : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              GestureDetector(
                onTap: requestSend ? sendRequest : removeRequest,
                child: Container(
                  height: kIsWeb ? 34.0 : 9.w,
                  width: kIsWeb ? 34.0 : 9.w,
                  decoration: ShapeDecoration(
                    color: pref ? AppColors.blackColor : AppColors.bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      requestSend ? Icons.close : LucideIcons.plus,
                      size: kIsWeb ? 18.0 : 4.w,
                      color: pref
                          ? AppColors.secondaryColor
                          : AppColors.blackColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: chat,
                child: Container(
                  height: kIsWeb ? 34.0 : 9.w,
                  width: kIsWeb ? 34.0 : 9.w,
                  decoration: ShapeDecoration(
                    color: pref ? AppColors.blackColor : AppColors.bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      LucideIcons.messageCircle300,
                      size: kIsWeb ? 18.0 : 4.w,
                      color: pref
                          ? AppColors.secondaryColor
                          : AppColors.blackColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
