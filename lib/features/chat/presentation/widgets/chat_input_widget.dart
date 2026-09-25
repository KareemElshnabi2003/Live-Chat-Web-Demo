// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/features/chat/domain/entities/chat_attachment.dart';
import 'package:live_chat/features/chat/data/models/chat_message_model.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_state.dart';
import 'package:live_chat/core/widgets/text_click_widget.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';

class ChatInputWidget extends StatefulWidget {
  final UserChatModel userChatModel;
  final bool isRtl;
  final VoidCallback onScrollToBottom;

  const ChatInputWidget({
    super.key,
    required this.userChatModel,
    required this.isRtl,
    required this.onScrollToBottom,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool get pref => context.isDarkMode;
  final TextEditingController _messageController = TextEditingController();
  bool _isAnswer = false;
  bool _isPickingImage = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final cubit = context.read<ChatCubit>();
    final state = cubit.state;
    String finalMessage = text;

    if (state is ChatLoaded && state.replyingToMessage != null) {
      final rep = state.replyingToMessage;
      if (rep is ChatMessage) {
        String msgContent = rep.message;
        String msgType = rep.messageType;
        if (msgContent.contains('|||REPLY|||')) {
          msgContent = msgContent.split('|||REPLY|||').last;
        }
        final myName = CacheHelper.getString(key: AppConstants.usernameKey) ?? CacheHelper.getString(key: AppConstants.usernameGustKey) ?? "";
        String senderNameForReply = rep.senderName == myName ? S.of(context).you : (rep.senderName ?? "Unknown");

        String tag = 'MSG';
        if (msgType == 'image') tag = 'IMG';
        if (msgType == 'voice' || msgType == 'audio') tag = 'VOICE';
        if (msgType == 'text' && (msgContent.startsWith('|||GROUP_CALL_START|||') || msgContent.startsWith('|||PRIVATE_CALL_START|||'))) tag = 'CALL';

        finalMessage = "$senderNameForReply|||$tag|||$msgContent|||REPLY|||$text";
      }
      cubit.cancelReply();
    }

    cubit.sendMessage(finalMessage);
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), widget.onScrollToBottom);
  }

  Future<void> _sendImageMessage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final attachment = ChatAttachment(bytes: bytes, filename: picked.name);
        if (mounted) {
          await context.read<ChatCubit>().sendMediaMessage(
            messageType: 'image',
            file: attachment,
          );
          Future.delayed(const Duration(milliseconds: 100), widget.onScrollToBottom);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _showMobileOnlyMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).mobileOnlyFeature),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = widget.userChatModel.isBlocked;
    final isNotFriend = widget.userChatModel.status == "Not Friend";
    final hasLastMessage = widget.userChatModel.lastMessage != null;

    if (isNotFriend && !hasLastMessage && isBlocked == "None") {
      return _buildMessageInput(context, isRequestArea: true);
    } else if (isBlocked == "You blocked them" || isBlocked == "They blocked you") {
      if (isBlocked == "You blocked them") {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              textNormal(S.of(context).msgIBlock, AppColors.blackColor, 3.5.w, FontWeight.w400),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                height: 5.h,
                decoration: BoxDecoration(color: AppColors.redColor, borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textClick(S.of(context).unBlock, true, () {
                      final userId = widget.userChatModel.user?.id?.toString() ?? "";
                      context.read<ChatCubit>().blockOrUnBlock(status: 0, userId: userId);
                      setState(() {
                        widget.userChatModel.isBlocked = "None";
                      });
                    }, AppColors.whiteColor, 4.w),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return textNormal(S.of(context).msgBlockUser, AppColors.blackColor, 3.5.w, FontWeight.w400);
      }
    } else if (isNotFriend && hasLastMessage && isBlocked == "None" && !_isAnswer && widget.userChatModel.user?.id.toString() != CacheHelper.getString(key: AppConstants.userIdKey)) {
      return _buildAcceptOrCancelArea(context);
    } else {
      return _buildMessageInput(context);
    }
  }

  Widget _buildMessageInput(BuildContext context, {bool isRequestArea = false}) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final replyingTo = (state is ChatLoaded) ? state.replyingToMessage : null;

        return Container(
          width: double.infinity,
          decoration: ShapeDecoration(
            color: pref ? AppColors.darkcolor : AppColors.whiteColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            shadows: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyingTo != null) _buildReplyPreview(context, replyingTo),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: .5.h),
                child: Row(
                  textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    GestureDetector(
                      onTap: _sendImageMessage,
                      child: Icon(IconsaxPlusLinear.gallery, size: 6.w, color: pref ? AppColors.secondaryColor : AppColors.blackTextColor),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: _showMobileOnlyMessage,
                      child: Icon(IconsaxPlusLinear.microphone, color: pref ? AppColors.secondaryColor : AppColors.blackTextColor, size: 6.w),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: pref ? AppColors.whiteColor : AppColors.blackTextColor, fontSize: 3.5.w, fontWeight: FontWeight.w400),
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: S.of(context).sendYourMessage,
                          hintStyle: TextStyle(color: pref ? AppColors.inActiveColor : AppColors.black2TextColor, fontSize: 3.5.w, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 11.w,
                        height: 5.h,
                        decoration: ShapeDecoration(
                          color: pref ? AppColors.secondaryColor : AppColors.buttoncolor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: Center(
                          child: Icon(IconsaxPlusLinear.send_2, size: 4.w, color: pref ? AppColors.blackColor : AppColors.whiteColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplyPreview(BuildContext context, dynamic replyingTo) {
    final senderName = replyingTo is ChatMessage ? (replyingTo.senderName ?? '') : '';
    final messageType = replyingTo is ChatMessage ? replyingTo.messageType : 'text';
    final message = replyingTo is ChatMessage ? replyingTo.message : '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: pref ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  style: TextStyle(
                    color: pref ? AppColors.secondaryColor : AppColors.buttoncolor,
                    fontWeight: FontWeight.bold,
                    fontSize: 3.w,
                  ),
                ),
                Builder(
                  builder: (context) {
                    if (messageType == 'text') {
                      String msgText = message.contains('|||REPLY|||') ? message.split('|||REPLY|||').last : message;
                      if (msgText.startsWith('|||GROUP_CALL_START|||') || msgText.startsWith('|||PRIVATE_CALL_START|||')) {
                        final callType = msgText.contains('video') ? (widget.isRtl ? "مكالمة فيديو" : "Video Call") : (widget.isRtl ? "مكالمة صوتية" : "Voice Call");
                        return Row(
                          children: [
                            Icon(msgText.contains('video') ? Icons.videocam : Icons.call, size: 4.w, color: pref ? Colors.white70 : Colors.black54),
                            SizedBox(width: 1.w),
                            Text(callType, style: TextStyle(color: pref ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                          ],
                        );
                      }
                      return Text(
                        msgText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: pref ? Colors.white70 : Colors.black54, fontSize: 3.w),
                      );
                    } else if (messageType == 'image') {
                      return Row(
                        children: [
                          Icon(Icons.image, size: 4.w, color: pref ? Colors.white70 : Colors.black54),
                          SizedBox(width: 1.w),
                          Text(widget.isRtl ? "صورة" : "Image", style: TextStyle(color: pref ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                        ],
                      );
                    } else if (messageType == 'voice' || messageType == 'audio') {
                      return Row(
                        children: [
                          Icon(Icons.mic, size: 4.w, color: pref ? Colors.white70 : Colors.black54),
                          SizedBox(width: 1.w),
                          Text(widget.isRtl ? "تسجيل صوتي" : "Voice Message", style: TextStyle(color: pref ? Colors.white70 : Colors.black54, fontSize: 3.w)),
                        ],
                      );
                    }
                    return Text(messageType, style: TextStyle(color: pref ? Colors.white70 : Colors.black54, fontSize: 3.w));
                  },
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.read<ChatCubit>().cancelReply(),
            child: Icon(Icons.close, size: 5.w, color: pref ? Colors.white54 : Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptOrCancelArea(BuildContext context) {
    return Container(
      width: 80.w,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(border: Border.all(color: AppColors.primaryColor), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          textNormal(S.of(context).wantToSendMsg, AppColors.blackTextColor, 3.5.w, FontWeight.w500),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  setState(() => _isAnswer = true);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primaryColor)),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: AppColors.primaryColor, size: 5.w),
                      textNormal("  ${S.of(context).accept}", AppColors.primaryColor, 4.w, FontWeight.w400),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  final userId = widget.userChatModel.user?.id?.toString() ?? "";
                  context.read<ChatCubit>().blockOrUnBlock(status: 1, userId: userId);
                  setState(() {
                    widget.userChatModel.isBlocked = "You blocked them";
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.redColor)),
                  child: textNormal("X ${S.of(context).cancel}", AppColors.redColor, 4.w, FontWeight.w400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
