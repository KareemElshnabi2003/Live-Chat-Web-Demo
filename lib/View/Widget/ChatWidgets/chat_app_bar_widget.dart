import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/Controller/chat_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Data/Model/user_chat_model.dart';
import 'package:live_chat/View/Screens/Home/home_view.dart';
import 'package:live_chat/View/Screens/create%20chat/settings.dart';
import 'package:live_chat/View/Screens/Chat%20Botton%20Sheet/show_bottom_change_music.dart';
import 'package:live_chat/View/Screens/Chat%20Botton%20Sheet/show_bottom_sheet_persons_chat.dart';
import 'package:live_chat/View/Widget/PublicWidget/message_error.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class ChatAppBarWidget extends StatelessWidget {
  final ChatController controller;
  final UserChatModel userChatModel;
  final bool isGust;
  final bool isRtl;

  const ChatAppBarWidget({
    super.key,
    required this.controller,
    required this.userChatModel,
    required this.isGust,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
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
                  isGust ? Get.back() : Get.offAll(() => const HomeView());
                },
                child: Icon(
                  isRtl ? IconsaxPlusLinear.arrow_right_3 : IconsaxPlusLinear.arrow_left_1,
                  size: 5.w,
                  color: pref! ? AppColors.blackColor : AppColors.blackTextColor,
                ),
              ),
              SizedBox(width: 2.w),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: userChatModel.image != null && userChatModel.image != "null"
                    ? CachedNetworkImageProvider("${userChatModel.image}")
                    : null,
                child: (userChatModel.image == null || userChatModel.image == "null")
                    ? Text(
                  userChatModel.name!.isNotEmpty ? userChatModel.name![0].toUpperCase() : '',
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                )
                    : null,
              ),
              SizedBox(width: 2.w),
              SizedBox(
                width: 35.w,
                child: Text(
                  userChatModel.name!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: pref! ? AppColors.blackColor : AppColors.blackTextColor,
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
    final isCurrentUser = (userChatModel.user != null)
        ? userChatModel.user!.id.toString() == sharedPreferences!.getString("id")
        : false;

    final isGroup = userChatModel.status != "Friends" && userChatModel.status != "Not Friend";

    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        if (isGroup) ...[
          _buildMusicIcon(context),
          const SizedBox(width: 16),
          _buildProfileIcon(context),
          if (isCurrentUser) ...[
            const SizedBox(width: 16),
            _buildSettingsIcon(),
          ],
          const SizedBox(width: 16),
          _buildCallMenu(context),
        ] else ...[
          _buildAudioCallIcon(),
          const SizedBox(width: 16),
          _buildVideoCallIcon(),
          const SizedBox(width: 16),
          _buildBlockIcon(context),
        ],
      ],
    );
  }
  Widget _buildMusicIcon(BuildContext context) => GestureDetector(
    onTap: () => showBottomSheetChangeMusicWidget(context: context),
    child: Icon(IconsaxPlusLinear.music, color: pref! ? AppColors.blackColor : AppColors.blackColor, size: 5.5.w),
  );

  Widget _buildProfileIcon(BuildContext context) => GestureDetector(
    onTap: () {
      if (isGust) {
        messageErrorWithButton(S.of(context).alert, S.of(context).pleaseLoginToAccess, () {
          Get.back();
          Get.back();
        }, S.of(context).login);
      } else {
        controller.getMembers();
        showBottomSheetControlPersonWidget(
          idAdmins: userChatModel.chatAdmins!,
          isNeedAccept: userChatModel.accept == "1",
          idOwner: userChatModel.user!.id.toString(),
          context: context,
        );
      }
    },
    child: Icon(IconsaxPlusLinear.profile, size: 5.5.w, color: pref! ? AppColors.blackColor : AppColors.blackColor),
  );

  Widget _buildSettingsIcon() => GestureDetector(
    onTap: () {
      Get.to(
            () => const Settings(),
        arguments: {"chatModel": userChatModel},
        transition: Transition.leftToRight,
        duration: const Duration(milliseconds: 400),
      );
    },
    child: Icon(IconsaxPlusLinear.setting, size: 5.5.w, color: pref! ? AppColors.blackColor : AppColors.blackColor),
  );

  Widget _buildCallMenu(BuildContext context) => PopupMenuButton<String>(
    color: pref! ? AppColors.blackColor : Colors.white,
    borderRadius: BorderRadius.circular(10),
    onSelected: (String value) async {
      final isGroup = userChatModel.status == "Public" || userChatModel.status == "Private";
      controller.audio = (value == 'audio_call');
      await controller.getTokenCall(
          isGroub: isGroup,
          groubUsersNames: isGroup
              ? {int.parse(sharedPreferences!.getString("id")!): sharedPreferences!.getString("name")!}
              : {},
          usernameFriend: isGroup ? "" : userChatModel.name);
    },
    itemBuilder: (BuildContext context) => [
      PopupMenuItem(value: 'video_call', child: _menuItem(S.of(context).videocall, IconsaxPlusLinear.video)),
      PopupMenuItem(value: 'audio_call', child: _menuItem(S.of(context).audiocall, IconsaxPlusLinear.call)),
    ],
    child: Icon(Icons.more_vert, size: 5.5.w, color: pref! ? AppColors.blackColor : AppColors.blackColor),
  );

  Widget _menuItem(String title, IconData icon) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      textNormal(title, pref! ? AppColors.whiteColor : AppColors.blackColor, 3.5.w, FontWeight.w500),
      SizedBox(width: 2.w),
      Icon(icon, size: 5.w, color: pref! ? AppColors.whiteColor : AppColors.blackColor)
    ],
  );

  Widget _buildAudioCallIcon() => GestureDetector(
    onTap: () => _initCall(true),
    child: Icon(IconsaxPlusLinear.call_calling, size: 5.5.w, color: pref! ? AppColors.blackColor : AppColors.blackColor),
  );

  Widget _buildVideoCallIcon() => GestureDetector(
    onTap: () => _initCall(false),
    child: Icon(IconsaxPlusLinear.video, size: 5.5.w, color: pref! ? AppColors.blackColor : AppColors.blackColor),
  );

  void _initCall(bool isAudio) async {
    final isGroup = userChatModel.status == "Public" || userChatModel.status == "Private";
    controller.audio = isAudio;
    await controller.getTokenCall(
        isGroub: isGroup,
        groubUsersNames: isGroup ? {int.parse(sharedPreferences!.getString("id")!): sharedPreferences!.getString("name")!} : {},
        usernameFriend: isGroup ? "" : userChatModel.name);
  }

  Widget _buildBlockIcon(BuildContext context) => GestureDetector(
    onTap: () async {
      await controller.getMemberToBlock();
      messageErrorWithButton(S.of(context).warning, S.of(context).sureToBlock, () {
        controller.blockOrUnBlock(friendID: controller.memberIdToBlock[0].id.toString(), status: true);
        userChatModel.isBlocked = "You blocked them";
        Get.back();
      }, S.of(context).block);
    },
    child: Icon(Icons.block, size: 5.5.w, color: AppColors.redColor),
  );
}