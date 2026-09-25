import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/features/chat/domain/entities/user_chat_entity.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:live_chat/features/chat/presentation/screens/chat_settings_screen.dart';
import 'package:live_chat/features/chat/presentation/widgets/show_bottom_change_music.dart';
import 'package:live_chat/features/chat/presentation/widgets/show_bottom_sheet_persons_chat.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';

class ChatAppBarWidget extends StatelessWidget {
  final UserChatEntity userChatModel;
  final bool isGust;
  final bool isRtl;

  const ChatAppBarWidget({
    super.key,
    required this.userChatModel,
    required this.isGust,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final bool pref = context.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    context.go(Routes.homeScreen);
                  }
                },
                child: Icon(
                  isRtl ? IconsaxPlusLinear.arrow_right_3 : IconsaxPlusLinear.arrow_left_1,
                  size: 5.w,
                  color: pref ? AppColors.blackColor : AppColors.blackTextColor,
                ),
              ),
              SizedBox(width: 2.w),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    userChatModel.image != null && userChatModel.image!.trim() != "null" && userChatModel.image!.trim().isNotEmpty && userChatModel.image!.trim() != "image"
                        ? CachedNetworkImageProvider(userChatModel.image!.trim())
                        : null,
                child: (userChatModel.image == null ||
                        userChatModel.image!.trim() == "null" || userChatModel.image!.trim().isEmpty || userChatModel.image!.trim() == "image")
                    ? Text(
                        (userChatModel.name != null && userChatModel.name!.isNotEmpty)
                            ? userChatModel.name![0].toUpperCase()
                            : '',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              SizedBox(width: 2.w),
              SizedBox(
                width: 35.w,
                child: Text(
                  userChatModel.name ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: pref ? AppColors.blackColor : AppColors.blackTextColor,
                    fontSize: 4.5.w,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          _buildAppBarActions(context),
        ],
      ),
    );
  }

  Widget _buildAppBarActions(BuildContext context) {
    final currentUserId = CacheHelper.getString(key: AppConstants.userIdKey) ?? '';
    final isCurrentUser = (userChatModel.user != null)
        ? userChatModel.user!.id.toString() == currentUserId
        : false;

    final isGroup = userChatModel.status != "Friends" &&
        userChatModel.status != "Not Friend";

    final isPublic = userChatModel.status?.toLowerCase() == "public";
    final canShareGroup = isGroup && (isPublic || isCurrentUser);
    final canMusic = isGroup && userChatModel.themeId != null;
    final hasMoreMenu = canShareGroup || canMusic || (isGroup && isCurrentUser) || !isGroup;

    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAudioCallIcon(context),
        const SizedBox(width: 12),
        _buildVideoCallIcon(context),
        if (hasMoreMenu) ...[
          const SizedBox(width: 12),
          _buildMoreMenu(context, isGroup, canShareGroup, canMusic, isCurrentUser),
        ],
      ],
    );
  }

  Widget _buildMoreMenu(BuildContext context, bool isGroup, bool canShareGroup, bool canMusic, bool isCurrentUser) {
    final bool pref = context.isDarkMode;
    return PopupMenuButton<String>(
      color: pref ? AppColors.blackColor : Colors.white,
      borderRadius: BorderRadius.circular(10),
      onSelected: (String value) async {
        if (value == 'share') {
          final link = userChatModel.chatLink ?? '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Chat Link: $link")),
          );
        } else if (value == 'music') {
          showBottomSheetChangeMusicWidget(context: context);
        } else if (value == 'profile') {
          showBottomSheetControlPersonWidget(
            context: context,
            idAdmins: userChatModel.chatAdmins?.cast<ChatAdmins>() ?? [],
            isNeedAccept: userChatModel.accept == "1",
            idOwner: userChatModel.user?.id.toString() ?? '',
            chatId: userChatModel.id?.toString(),
          );
        } else if (value == 'settings') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Settings(userChatModel: userChatModel),
            ),
          );
        } else if (value == 'block') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(S.of(context).warning),
              content: Text(S.of(context).sureToBlock),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(S.of(context).cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(S.of(context).block, style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            final targetUserId = userChatModel.user?.id.toString() ?? '';
            await context.read<ChatCubit>().blockOrUnBlock(status: 1, userId: targetUserId);
            userChatModel.isBlocked = "You blocked them";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).success)),
            );
          }
        }
      },
      itemBuilder: (BuildContext context) => [
        if (canShareGroup)
          PopupMenuItem(
              value: 'share',
              child: _menuItem(context, S.of(context).share, IconsaxPlusLinear.share)),
        if (canMusic)
          PopupMenuItem(
              value: 'music',
              child: _menuItem(context, S.of(context).music, IconsaxPlusLinear.music)),
        if (isGroup && isCurrentUser)
          PopupMenuItem(
              value: 'profile',
              child: _menuItem(context, S.of(context).profile, IconsaxPlusLinear.profile)),
        if (isGroup && isCurrentUser)
          PopupMenuItem(
              value: 'settings',
              child: _menuItem(context, S.of(context).settings, IconsaxPlusLinear.setting)),
        if (!isGroup)
          PopupMenuItem(
              value: 'block',
              child: _menuItem(context, S.of(context).block, Icons.block)),
      ],
      child: Icon(Icons.more_vert,
          size: 5.5.w,
          color: context.isDarkMode ? AppColors.whiteColor : AppColors.blackColor),
    );
  }

  Widget _menuItem(BuildContext context, String title, IconData icon) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon,
              size: 5.w,
              color: context.isDarkMode ? AppColors.whiteColor : AppColors.blackColor),
          SizedBox(width: 3.w),
          textNormal(title, context.isDarkMode ? AppColors.whiteColor : AppColors.blackColor,
              3.5.w, FontWeight.w500),
        ],
      );

  Widget _buildAudioCallIcon(BuildContext context) => GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).mobileOnlyFeature)),
          );
        },
        child: Icon(IconsaxPlusLinear.call_calling,
            size: 5.5.w,
            color: context.isDarkMode ? AppColors.whiteColor : AppColors.blackColor),
      );

  Widget _buildVideoCallIcon(BuildContext context) => GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).mobileOnlyFeature)),
          );
        },
        child: Icon(IconsaxPlusLinear.video,
            size: 5.5.w,
            color: context.isDarkMode ? AppColors.whiteColor : AppColors.blackColor),
      );
}
