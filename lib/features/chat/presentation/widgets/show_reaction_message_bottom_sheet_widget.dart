import 'package:flutter/material.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/features/chat/domain/entities/chat_message_entity.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';

void showReactionMessageBottomSheet(
    BuildContext context, ChatMessage chatMessage) {
  final isDarkMode = context.isDarkMode;
  final currentGuest = CacheHelper.getString(key: 'usernameGust');
  final currentUsername = CacheHelper.getString(key: AppConstants.usernameKey);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkcolor : AppColors.whiteColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            S.of(context).react,
            style: TextStyle(
              color: isDarkMode ? AppColors.whiteColor : AppColors.blackTextColor,
              fontSize: 4.w,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: 100.w,
            child: ListView.separated(
              itemCount: chatMessage.reaction.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(2.w),
              itemBuilder: (context, index) {
                final reactItem = chatMessage.reaction[index];
                final rUsername = reactItem.user?.username ?? '';
                final isMe = rUsername == currentGuest || rUsername == currentUsername;

                return Row(
                  children: [
                    Text(reactItem.react ?? '',
                        style: TextStyle(fontSize: 6.w)),
                    const SizedBox(width: 10),
                    textNormal(
                      isMe ? S.of(context).you : rUsername,
                      isDarkMode ? AppColors.whiteColor : AppColors.blackTextColor,
                      3.5.w,
                      FontWeight.w500,
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    ),
  );
}

// Backwards-compatible alias
// ignore: non_constant_identifier_names
void ShowReactionMessageBottomSheet(
        BuildContext context, ChatMessage chatMessage) =>
    showReactionMessageBottomSheet(context, chatMessage);