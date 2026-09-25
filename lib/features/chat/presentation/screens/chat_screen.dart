// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/core/di/service_locator.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/features/chat/domain/entities/user_chat_entity.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_state.dart';
import 'package:live_chat/features/chat/presentation/widgets/chat_app_bar_widget.dart';
import 'package:live_chat/features/chat/presentation/widgets/chat_helpers.dart';
import 'package:live_chat/features/chat/presentation/widgets/chat_input_widget.dart';
import 'package:live_chat/features/chat/presentation/widgets/chat_bubble_widget.dart';
import 'package:live_chat/features/chat/presentation/widgets/pinned_ad_widget.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class ChatView extends StatefulWidget {
  final UserChatEntity? userChatModel;
  final bool isPin;
  final bool isGust;

  const ChatView({super.key, required this.userChatModel, required this.isPin, required this.isGust});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  bool get pref => context.isDarkMode;
  final ScrollController _scrollController = ScrollController();
  bool showScrollToBottom = false;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 200) {
        if (!showScrollToBottom) setState(() => showScrollToBottom = true);
      } else {
        if (showScrollToBottom) setState(() => showScrollToBottom = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final chatId = widget.userChatModel?.id?.toString() ?? '';

    return BlocProvider(
      create: (_) => sl<ChatCubit>()..initChat(chatId: chatId),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          Future.microtask(() {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go(Routes.homeScreen);
            }
          });
        },
        child: Scaffold(
          backgroundColor: pref ? AppColors.blackColor : AppColors.bgColor,
          body: SafeArea(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is ChatLoading) {
                  return Center(
                    child: textNormal(S.of(context).joining, AppColors.primaryColor, 3.5.w, FontWeight.w500),
                  );
                }

                final messages = state is ChatLoaded ? state.messages : [];
                final isRadioPlaying = state is ChatLoaded ? state.isRadioPlaying : false;
                final currentRadioUrl = state is ChatLoaded ? state.currentRadioUrl : null;
                final isLoadingMore = state is ChatLoaded ? state.isLoadingMore : false;

                return Container(
                  decoration: BoxDecoration(
                    image: widget.userChatModel != null
                        ? ChatHelpers.getBackgroundImage(widget.userChatModel!)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2.h, right: 3.w, left: 3.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ChatAppBarWidget(
                              userChatModel: widget.userChatModel!,
                              isGust: widget.isGust,
                              isRtl: isRtl,
                            ),
                            if (widget.isPin && ChatHelpers.hasAd(widget.userChatModel!))
                              PinnedAdWidget(
                                pref: pref,
                                adTitle: widget.userChatModel!.adTitle,
                                adLink: widget.userChatModel!.adLink,
                                adImage: widget.userChatModel!.adImage,
                              ),
                            SizedBox(height: 2.h),
                            ChatHelpers.buildMusicBar(
                              isRadioPlaying: isRadioPlaying,
                              currentRadioUrl: currentRadioUrl,
                              onStopRadio: () => context.read<ChatCubit>().stopRadio(),
                              isRtl: isRtl,
                              context: context,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: Stack(
                            children: [
                              NotificationListener<ScrollNotification>(
                                onNotification: (scrollInfo) {
                                  if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
                                    context.read<ChatCubit>().loadMoreMessages();
                                  }
                                  return false;
                                },
                                child: ListView.separated(
                                  separatorBuilder: (context, index) {
                                    if (index >= messages.length - 1) return const SizedBox(height: 20);
                                    final cur = messages[index];
                                    final nxt = messages[index + 1];
                                    final curName = cur.senderName;
                                    final nxtName = nxt.senderName;
                                    return SizedBox(height: curName != nxtName ? 15 : 0);
                                  },
                                  controller: _scrollController,
                                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 0),
                                  reverse: true,
                                  itemCount: messages.length + (isLoadingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == messages.length && isLoadingMore) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    final message = messages[index];

                                    final isLastInGroup = index == 0 ||
                                        (index > 0 &&
                                            messages[index - 1].senderName != message.senderName);
                                    final isFirstInGroup = index == messages.length - 1 ||
                                        (index < messages.length - 1 &&
                                            messages[index + 1].senderName != message.senderName);

                                    return ChatBubbleWidget(
                                      key: ValueKey(message.messageId.isNotEmpty ? message.messageId : index.toString()),
                                      pref: context.isDarkMode,
                                      name: message.senderName ?? '',
                                      img: message.imageUrl,
                                      message: message,
                                      showAvatar: isFirstInGroup,
                                      isFirstInGroup: isFirstInGroup,
                                      isLastInGroup: isLastInGroup,
                                      onLongPress: () {
                                        ChatHelpers.showReactionBottomSheet(
                                          context: context,
                                          messageId: message.messageId,
                                          onReact: (emoji) {
                                            context.read<ChatCubit>().sendReaction(
                                              messageId: message.messageId,
                                              react: emoji,
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              if (showScrollToBottom)
                                Positioned(
                                  bottom: 10,
                                  left: isRtl ? 4.w : null,
                                  right: isRtl ? null : 4.w,
                                  child: FloatingActionButton(
                                    mini: true,
                                    backgroundColor: AppColors.primaryColor,
                                    onPressed: _scrollToBottom,
                                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 3.w, left: 3.w, bottom: 2.5.h),
                        child: ChatInputWidget(
                          userChatModel: widget.userChatModel!,
                          isRtl: isRtl,
                          onScrollToBottom: _scrollToBottom,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}