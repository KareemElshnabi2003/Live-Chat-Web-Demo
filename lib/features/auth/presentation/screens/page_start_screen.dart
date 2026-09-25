import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/Constant/app_images.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/core/widgets/chat_card_widget.dart';
import 'package:live_chat/core/widgets/dialog_img.dart';
import 'package:live_chat/core/widgets/no_data.dart';
import 'package:live_chat/core/widgets/shimmer_skeletons.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/features/home/presentation/cubit/home_cubit.dart';
import 'package:live_chat/features/home/presentation/cubit/home_state.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class PageStart extends StatefulWidget {
  const PageStart({super.key});

  @override
  State<PageStart> createState() => _PageStartState();
}

class _PageStartState extends State<PageStart> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
  }

  bool _isValidImage(String? url) {
    return url != null &&
        url.trim().isNotEmpty &&
        url.trim() != "null" &&
        url.trim() != "image";
  }

  Future<void> _handleChatTap(BuildContext context, UserChatModel chat, {bool isPin = false}) async {
    if (chat.status == "Public" || chat.status == "Private") {
      final joined = await context.read<HomeCubit>().joinToChat(chatId: chat.id);
      if (!joined && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).waitForAccept),
            backgroundColor: Colors.orange.shade600,
          ),
        );
        return;
      }
    }
    if (context.mounted) {
      context.push(
        Routes.chatScreen,
        extra: {
          'userChatModel': chat,
          'isPin': isPin,
          'isGust': true,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final isLoading = state is HomeLoading;
          final loaded = state is HomeLoaded ? state : null;
          final pinnedChat = loaded?.pinnedChat?.conversation;
          final recentChats = loaded?.recentChats ?? [];
          final systemChats = loaded?.systemChats ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<HomeCubit>().refreshHome();
            },
            color: AppColors.secondaryColor,
            backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==============================
                  // 1. حاوية الهيدر وتسجيل الدخول والدردشة المثبتة
                  // ==============================
                  Container(
                    padding: EdgeInsets.only(
                      left: isRtl ? 0 : 4.w,
                      right: isRtl ? 4.w : 0,
                      top: 5.h,
                      bottom: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: pref! ? AppColors.darkcolor : AppColors.whiteColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            context.push(Routes.authScreen);
                          },
                          child: Row(
                            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                            children: [
                              Image.asset(AppImages.iconLoginImg, width: 5.w, height: 5.w),
                              SizedBox(width: 2.w),
                              textNormal(
                                S.of(context).log_in,
                                pref! ? AppColors.whiteColor : AppColors.blackColor,
                                4.w,
                                FontWeight.w400,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 5.w,
                              backgroundColor: pref! ? AppColors.secondaryColor : AppColors.primaryColor,
                              child: const CircleAvatar(
                                backgroundImage: AssetImage("lib/Images/play_store_512.png"),
                                radius: 18,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            textNormal(
                              S.of(context).mayolivechat,
                              pref! ? AppColors.secondaryColor : AppColors.primaryColor,
                              3.5.w,
                              FontWeight.bold,
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        // ==============================
                        // 2. Pinned Chat Section
                        // ==============================
                        if (isLoading)
                          ShimmerSkeletons.chatListSkeleton()
                        else if (pinnedChat != null) ...[
                          Row(
                            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                            children: [
                              textNormal(
                                S.of(context).positive_chat,
                                pref! ? AppColors.whiteColor : AppColors.blackColor,
                                4.w,
                                FontWeight.w400,
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                LucideIcons.pin300,
                                size: 5.w,
                                color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Builder(
                            builder: (context) {
                              final hasValidImage = _isValidImage(pinnedChat.image);
                              return chatCardWidget(
                                needsAcceptance: pinnedChat.accept == "1",
                                power: null,
                                imageUrl: hasValidImage,
                                numOfMessage: 0,
                                onPressImg: () {
                                  dialogImgWidget(
                                    title: pinnedChat.name ?? "",
                                    img: null,
                                    userChatModel: pinnedChat,
                                    onPressChat: () => _handleChatTap(context, pinnedChat, isPin: true),
                                  );
                                },
                                private: pinnedChat.status == "Private",
                                img: hasValidImage
                                    ? CachedNetworkImageProvider(pinnedChat.image!.trim())
                                    : const AssetImage(AppImages.noChatImg) as ImageProvider,
                                body: "${pinnedChat.membersCount ?? 0} ${S.of(context).engaged_people}",
                                ttitle: pinnedChat.name ?? "",
                                action: S.of(context).join_now,
                                onPressJoin: () => _handleChatTap(context, pinnedChat, isPin: true),
                                ontap: () => _handleChatTap(context, pinnedChat, isPin: true),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // ==============================
                  // 3. Latest Chats Section
                  // ==============================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        textNormal(
                          S.of(context).latest_chats,
                          pref! ? AppColors.whiteColor : AppColors.blackColor,
                          4.w,
                          FontWeight.w400,
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          isRtl ? LucideIcons.moveLeft300 : LucideIcons.moveRight300,
                          color: AppColors.secondaryColor,
                          size: kIsWeb ? 28.0 : 7.w,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  if (isLoading)
                    ShimmerSkeletons.chatListSkeleton()
                  else if (recentChats.isEmpty)
                    Center(child: noData(S.of(context).noChat))
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(left: isRtl ? 0 : 4.w, right: isRtl ? 4.w : 0),
                        separatorBuilder: (context, index) => SizedBox(height: 2.h),
                        itemCount: recentChats.length,
                        itemBuilder: (context, index) {
                          final chat = recentChats[index];
                          final hasValidImage = _isValidImage(chat.image);

                          return chatCardWidget(
                            needsAcceptance: chat.accept == "1",
                            power: null,
                            imageUrl: hasValidImage,
                            numOfMessage: 0,
                            onPressImg: () {
                              dialogImgWidget(
                                title: chat.name ?? "",
                                userChatModel: chat,
                                img: null,
                                onPressChat: () => _handleChatTap(context, chat),
                              );
                            },
                            private: chat.status == "Private",
                            img: hasValidImage
                                ? CachedNetworkImageProvider(chat.image!.trim())
                                : const AssetImage(AppImages.noChatImg) as ImageProvider,
                            body: "${chat.membersCount ?? 0} ${S.of(context).engaged_people}",
                            ttitle: chat.name ?? "",
                            action: S.of(context).join_now,
                            onPressJoin: () => _handleChatTap(context, chat),
                            ontap: () => _handleChatTap(context, chat),
                          );
                        },
                      ),
                    ),

                  SizedBox(height: 3.h),

                  // ==============================
                  // 4. Other Chats Section
                  // ==============================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        textNormal(
                          S.of(context).other_chats,
                          pref! ? AppColors.whiteColor : AppColors.blackColor,
                          4.5.w,
                          FontWeight.w400,
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          isRtl ? LucideIcons.moveLeft300 : LucideIcons.moveRight300,
                          color: AppColors.secondaryColor,
                          size: kIsWeb ? 28.0 : 7.w,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  if (isLoading)
                    ShimmerSkeletons.chatListSkeleton()
                  else if (systemChats.isEmpty)
                    Center(child: noData(S.of(context).noChat))
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(left: isRtl ? 0 : 4.w, right: isRtl ? 4.w : 0),
                        separatorBuilder: (context, index) => SizedBox(height: 2.h),
                        itemCount: systemChats.length,
                        itemBuilder: (context, index) {
                          final chat = systemChats[index];
                          final hasValidImage = _isValidImage(chat.image);

                          return chatCardWidget(
                            needsAcceptance: chat.accept == "1",
                            power: null,
                            imageUrl: hasValidImage,
                            numOfMessage: 0,
                            onPressImg: () {
                              dialogImgWidget(
                                title: chat.name ?? "",
                                userChatModel: chat,
                                img: null,
                                onPressChat: () => _handleChatTap(context, chat),
                              );
                            },
                            private: chat.status == "Private",
                            img: hasValidImage
                                ? CachedNetworkImageProvider(chat.image!.trim())
                                : const AssetImage(AppImages.noChatImg) as ImageProvider,
                            body: "${chat.membersCount ?? 0} ${S.of(context).engaged_people}",
                            ttitle: chat.name ?? "",
                            action: S.of(context).join_now,
                            onPressJoin: () => _handleChatTap(context, chat),
                            ontap: () => _handleChatTap(context, chat),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}