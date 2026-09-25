import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/routing/app_router.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';

void dialogImgWidget({
  BuildContext? context,
  required UserChatModel? userChatModel,
  required String title,
  required dynamic img,
  required VoidCallback onPressChat,
}) {
  final ctx = context ?? AppRouter.navigatorKey.currentContext;
  if (ctx == null) return;

  showDialog(
    context: ctx,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: pref ? AppColors.darkcolor : AppColors.whiteColor,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.only(bottom: 10),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        InkWell(
          onTap: () {
            Navigator.pop(dialogCtx);
            onPressChat();
          },
          child: Icon(LucideIcons.phone, size: 6.w, color: AppColors.primaryColor),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(dialogCtx);
            onPressChat();
          },
          child: Icon(LucideIcons.video, size: 6.w, color: AppColors.primaryColor),
        ),
        InkWell(
          onTap: () {
            Navigator.pop(dialogCtx);
            onPressChat();
          },
          child: Icon(LucideIcons.messageCircle300, size: 6.w, color: AppColors.primaryColor),
        ),
      ],
      content: SizedBox(
        width: 70.w,
        height: 30.h,
        child: userChatModel != null
            ? (userChatModel.image == "image" || userChatModel.image.toString() == "null")
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: pref ? AppColors.darkcolor : AppColors.black2TextColor,
                    ),
                    child: textNormal(
                      title.isNotEmpty ? title[0] : "",
                      pref ? AppColors.blackTextColor : AppColors.whiteColor,
                      14.w,
                      FontWeight.bold,
                    ),
                  )
                : CachedNetworkImage(fit: BoxFit.cover, imageUrl: userChatModel.image!)
            : img == null
                ? Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: pref ? AppColors.darkcolor : AppColors.black2TextColor,
                    ),
                    child: textNormal(
                      title.isNotEmpty ? title[0] : "",
                      pref ? AppColors.blackTextColor : AppColors.whiteColor,
                      14.w,
                      FontWeight.bold,
                    ),
                  )
                : CachedNetworkImage(fit: BoxFit.cover, imageUrl: "$img"),
      ),
    ),
  );
}
