//region ChatBubbleWidget
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Data/Model/chat_message_model.dart';
import 'package:live_chat/View/Widget/ChatWidgets/audio_message_widget.dart';
import 'package:live_chat/View/Widget/ChatWidgets/show_reaction_message_bottom_sheet_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final VoidCallback onLongPress;
  final String name;
  final bool pref;
  final String? img; // 🌟 التصحيح عشان الـ null

  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.onLongPress,
    required this.name,
    required this.img, required this.pref,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0.w,
        vertical: isFirstInGroup
            ? 0.w
            : message.reaction.isNotEmpty
            ? 3.w
            : 3.w,
      ),
      child: Row(
        mainAxisAlignment: isRtl
            ? (message.isFromSender
            ? MainAxisAlignment.start
            : MainAxisAlignment.end)
            : (message.isFromSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start),
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          if (isRtl && message.isFromSender) SizedBox(width: 0.w),
          if (isRtl && message.isFromSender)
            _buildAvatar(showAvatar, true, name, img),
          if (!isRtl && !message.isFromSender)
            _buildAvatar(showAvatar, false, name, img),
          if (!isRtl && !message.isFromSender) SizedBox(width: 0.w),
          Flexible(
            child: GestureDetector(
              onLongPress: onLongPress,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 70.w),
                    decoration: BoxDecoration(
                      color: message.isFromSender
                          ? (pref!
                          ? AppColors.darkcolor
                          : AppColors.buttoncolor)
                          : AppColors.whiteColor,
                      borderRadius:
                      _getBorderRadius(isRtl, message.isFromSender),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    child: Column(
                      crossAxisAlignment: isRtl
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (!message.isFromSender && isFirstInGroup)
                          Padding(
                            padding: EdgeInsets.only(bottom: 0.5.h),
                            child: Text(
                              name,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 2.8.w,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        _buildMessageContent(
                          message.isPending,
                          message.messageType,
                          message.message,
                          message.isFromSender,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          message.timestamp.toString(),
                          style: TextStyle(
                            color: message.isFromSender
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                            fontSize: 2.5.w,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (message.reaction.isNotEmpty)
                    Positioned(
                      bottom: -10,
                      right: message.isFromSender ? 8 : null,
                      left: !message.isFromSender ? 8 : null,
                      child: InkWell(
                        onTap: () =>
                            ShowReactionMessageBottomSheet(context, message),
                        child: Row(
                          children: [
                            Container(
                              width: 5.7.w,
                              height: 5.7.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.grey[300]!, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  message.reaction[0].react!,
                                  style: TextStyle(fontSize: 3.5.w),
                                ),
                              ),
                            ),
                            if (message.reaction.length > 1)
                              Text(
                                "+${message.reaction.length - 1}",
                                style: TextStyle(fontSize: 2.5.w),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isRtl && !message.isFromSender)
            _buildAvatar(showAvatar, false, name, img),
          if (isRtl && !message.isFromSender) SizedBox(width: 2.w),
          if (!isRtl && message.isFromSender) SizedBox(width: 2.w),
          if (!isRtl && message.isFromSender)
            _buildAvatar(showAvatar, true, name, img),
        ],
      ),
    );
  }

  Widget _buildMessageContent(
      bool wait, String type, String content, bool isFromSender) {
    switch (type) {
      case 'text':
        return Text(
          content,
          style: TextStyle(
            color:
            isFromSender ? AppColors.whiteColor : AppColors.blackTextColor,
            fontSize: 3.w,
            fontWeight: FontWeight.w400,
          ),
        );
      case 'image':
        Widget imageWidget = content.startsWith('http')
            ? CachedNetworkImage(imageUrl: content)
            : Image.file(File(content));
        return Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: () => _showImageInScreen(imgUrl: content),
              child: imageWidget,
            ),
            if (wait) Icon(Icons.timelapse_rounded, size: 5.w),
          ],
        );
      case 'voice':
        return Stack(
          children: [
            AudioMessageWidget(
              pref: pref,


              url: content.startsWith('http') ? content : '',
              localPath: content.startsWith('http') ? null : content,
            ),
            if (wait) Icon(Icons.timelapse_rounded, size: 5.w),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  void _showImageInScreen({required String imgUrl}) {
    Get.defaultDialog(
      radius: 0,
      backgroundColor: AppColors.blackColor,
      title: S.of(Get.context!).imageViewerTitle,
      content: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20.0),
        minScale: 0.5,
        maxScale: 4.0,
        child: Container(
          color: AppColors.blackColor,
          height: 70.h,
          width: 100.w,
          child: CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool show, bool isSender, String name, String? img) {
    // 🌟 فحص دقيق يمنع كراش الصورة تماماً
    bool hasValidImage = img != null && img.trim().isNotEmpty && img.trim() != "null" && img.trim() != "image";

    return SizedBox(
      width: 10.w,
      height: 8.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.w),
        child: show
            ? CircleAvatar(
          radius: 4.w,
          backgroundColor:
          isSender ? AppColors.buttoncolor : Colors.grey[300],
          backgroundImage: hasValidImage
              ? CachedNetworkImageProvider(img!.trim())
              : null,
          child: !hasValidImage
              ? Text(
            name.isNotEmpty ? name[0].toUpperCase() : '',
            style: TextStyle(
              color: isSender
                  ? AppColors.whiteColor
                  : AppColors.blackTextColor,
              fontSize: 3.w,
              fontWeight: FontWeight.w600,
            ),
          )
              : null,
        )
            : null,
      ),
    );
  }

  BorderRadius _getBorderRadius(bool isRtl, bool isSender) {
    const radius = Radius.circular(18);
    const smallRadius = Radius.circular(4);

    if (isSender) {
      if (isFirstInGroup && isLastInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? radius : smallRadius,
          topRight: isRtl ? smallRadius : radius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      }
      if (isLastInGroup) {
        return const BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomRight: radius,
          bottomLeft: radius,
        );
      } else if (isFirstInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? radius : smallRadius,
          topRight: isRtl ? smallRadius : radius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      } else {
        return BorderRadius.circular(12);
      }
    } else {
      if (isFirstInGroup && isLastInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? smallRadius : radius,
          topRight: isRtl ? radius : smallRadius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      }
      if (isLastInGroup) {
        return const BorderRadius.only(
          topLeft: radius,
          topRight: radius,
          bottomRight: radius,
          bottomLeft: radius,
        );
      } else if (isFirstInGroup) {
        return BorderRadius.only(
          topLeft: isRtl ? smallRadius : radius,
          topRight: isRtl ? radius : smallRadius,
          bottomLeft: radius,
          bottomRight: radius,
        );
      } else {
        return BorderRadius.circular(12);
      }
    }
  }
}
//endregion