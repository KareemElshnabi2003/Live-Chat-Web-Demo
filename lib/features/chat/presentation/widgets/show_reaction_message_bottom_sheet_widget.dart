import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/features/chat/domain/entities/chat_message_entity.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';

void showReactionMessageBottomSheet(
    BuildContext context, ChatMessage chatMessage) {
  final isDarkMode = context.isDarkMode;
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  final currentGuest = CacheHelper.getString(key: 'usernameGust');
  final currentUsername = CacheHelper.getString(key: AppConstants.usernameKey);
  final currentName = CacheHelper.getString(key: AppConstants.nameKey);
  final currentUserId = CacheHelper.getString(key: AppConstants.userIdKey);
  final currentGuestId = CacheHelper.getString(key: 'idGust');

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
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.all(2.w),
              itemBuilder: (context, index) {
                final reactItem = chatMessage.reaction[index];
                final rUserId = reactItem.user?.id?.toString();
                final rUsername = reactItem.user?.username ?? '';
                final rName = reactItem.user?.name ?? '';
                final rImage = reactItem.user?.image;

                final displayName = rUsername.trim().isNotEmpty
                    ? rUsername.trim()
                    : (rName.trim().isNotEmpty ? rName.trim() : '');

                final isMe = (currentUserId != null && currentUserId.isNotEmpty && rUserId == currentUserId) ||
                    (currentGuestId != null && currentGuestId.isNotEmpty && rUserId == currentGuestId) ||
                    (currentGuest != null && currentGuest.isNotEmpty && displayName.toLowerCase() == currentGuest.toLowerCase()) ||
                    (currentUsername != null && currentUsername.isNotEmpty && displayName.toLowerCase() == currentUsername.toLowerCase()) ||
                    (currentName != null && currentName.isNotEmpty && displayName.toLowerCase() == currentName.toLowerCase());

                final fallbackGuest = isRtl ? "Ø²Ø§Ø¦Ø±" : "Guest";
                final shownText = isMe
                    ? S.of(context).you
                    : (displayName.isNotEmpty ? displayName : fallbackGuest);

                final initial = shownText.trim().isNotEmpty
                    ? shownText.trim()[0].toUpperCase()
                    : 'G';

                final hasValidImage = rImage != null &&
                    rImage.trim().isNotEmpty &&
                    rImage.trim() != 'null' &&
                    rImage.trim() != 'image';

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.5.h),
                  child: Row(
                    children: [
                      // Emoji
                      Text(
                        reactItem.react ?? '',
                        style: TextStyle(fontSize: 6.w),
                      ),
                      const SizedBox(width: 14),
                      // Avatar
                      CircleAvatar(
                        radius: 3.8.w,
                        backgroundColor: isMe ? AppColors.buttoncolor : Colors.grey[400],
                        backgroundImage: hasValidImage
                            ? CachedNetworkImageProvider(rImage.trim())
                            : null,
                        child: !hasValidImage
                            ? Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Name
                      Expanded(
                        child: Text(
                          shownText,
                          style: TextStyle(
                            color: isDarkMode ? AppColors.whiteColor : AppColors.blackTextColor,
                            fontSize: 3.6.w,
                            fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
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