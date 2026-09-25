// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/Constant/app_images.dart';
import 'package:live_chat/core/function/format_last_message.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/core/widgets/chat_card_widget.dart';
import 'package:live_chat/core/widgets/dialog_img.dart';
import 'package:live_chat/core/widgets/loading.dart';
import 'package:live_chat/core/widgets/no_data.dart';
import 'package:live_chat/core/widgets/slider_img.dart';
import 'package:live_chat/core/widgets/storetext.dart';
import 'package:live_chat/core/widgets/sugessted_friends.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/core/widgets/responsive_layout.dart';
import 'package:live_chat/features/home/presentation/cubit/home_cubit.dart';
import 'package:live_chat/features/home/presentation/cubit/home_state.dart';
import 'package:live_chat/features/home/presentation/widgets/nav_bar.dart';
import 'package:live_chat/features/home/presentation/widgets/sidebar_nav.dart';
import 'package:live_chat/features/home/presentation/widgets/show_bottom_sheet_pin_chat_widget.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/features/chat/presentation/screens/chat_screen.dart';
import 'package:live_chat/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:live_chat/features/friends/presentation/cubit/friends_state.dart';
import 'package:live_chat/features/market/data/models/power_model.dart';
import 'package:live_chat/features/market/presentation/screens/market_screen.dart';
import 'package:live_chat/features/settings/presentation/screens/settings_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool get pref => context.isDarkMode;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
    context.read<FriendsCubit>().loadFriends();
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _handleChatTap(BuildContext context, UserChatModel chat, {bool isPin = false}) async {
    final isDesktop = ResponsiveLayout.isDesktop(context);
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

    if (isDesktop) {
      if (mounted) {
        context.read<HomeCubit>().selectChat(chat, isPin: isPin, isGust: false);
      }
    } else {
      if (mounted) {
        context.push(
          Routes.chatScreen,
          extra: {
            'userChatModel': chat,
            'isPin': isPin,
            'isGust': false,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        final selectedIndex = homeState is HomeLoaded ? homeState.selectedNavIndex : 0;
        final selectedChat = homeState is HomeLoaded ? homeState.selectedChat : null;
        final isSelectedChatPin = homeState is HomeLoaded ? homeState.isSelectedChatPin : false;
        final isSelectedChatGust = homeState is HomeLoaded ? homeState.isSelectedChatGust : false;

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (selectedIndex != 0) {
              context.read<HomeCubit>().changeNavIndex(0);
            } else {
              _showExitConfirmation(context);
            }
          },
          child: Scaffold(
            backgroundColor: pref ? AppColors.blackColor : AppColors.bgColor,
            body: ResponsiveLayout(
              mobileBody: _buildBodyForIndex(selectedIndex, homeState),
              desktopBody: Row(
                children: [
                  CustomSidebarNavigation(
                    currentIndex: selectedIndex,
                    onTap: (i) {
                      context.read<HomeCubit>().changeNavIndex(i);
                    },
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: pref ? AppColors.darkcolor : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      child: _buildBodyForIndex(selectedIndex, homeState),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: selectedChat == null
                        ? Center(
                            child: textNormal(
                              S.of(context).noChat,
                              pref ? AppColors.whiteColor : AppColors.blackColor,
                              4.w,
                              FontWeight.w500,
                            ),
                          )
                        : ChatView(
                            userChatModel: selectedChat,
                            isPin: isSelectedChatPin,
                            isGust: isSelectedChatGust,
                          ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: ResponsiveLayout.isMobile(context)
                ? CustomBottomNavigationBar(
                    currentIndex: selectedIndex,
                    onTap: (i) {
                      context.read<HomeCubit>().changeNavIndex(i);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildBodyForIndex(int index, HomeState homeState) {
    switch (index) {
      case 0:
        return _buildHomeContent(homeState);
      case 1:
        return _buildChatPage(homeState);
      case 2:
        return const MarketPage();
      case 3:
        return const SettingView();
      default:
        return _buildHomeContent(homeState);
    }
  }

  Widget _buildHomeContent(HomeState homeState) {
    final loaded = homeState is HomeLoaded ? homeState : null;
    final ads = loaded?.ads ?? [];
    final pinnedChat = loaded?.pinnedChat?.conversation;
    final userChats = loaded?.userChats ?? [];

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HomeCubit>().refreshHome();
        if (mounted) {
          await context.read<FriendsCubit>().loadFriends();
        }
      },
      color: AppColors.secondaryColor,
      backgroundColor: pref ? AppColors.darkcolor : AppColors.whiteColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(bottom: 7.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: 4.w,
                  left: 4.w,
                  top: 5.h,
                  bottom: 2.h,
                ),
                child: Column(
                  children: [
                    _buildAppBar(onPress: () => showBottomSheetPinChatWidget(context: context)),
                    if (ads.isNotEmpty) SizedBox(height: 2.h),
                    if (ads.isNotEmpty) _sliderImg(ads),
                    if (ads.isNotEmpty) SizedBox(height: 2.h),
                    if (pinnedChat != null) _buildPinnedChat(pinnedChat),
                  ],
                ),
              ),
              _buildPrivateChatsSection(userChats),
              _buildFriendsSection(),
              _buildSuggestedFriendsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatPage(HomeState homeState) {
    final loaded = homeState is HomeLoaded ? homeState : null;
    final ads = loaded?.ads ?? [];
    final systemChats = loaded?.systemChats ?? [];

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HomeCubit>().refreshHome();
      },
      color: AppColors.secondaryColor,
      backgroundColor: pref ? AppColors.darkcolor : AppColors.whiteColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(bottom: 7.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 4.w, left: 4.w, top: 5.h, bottom: 2.h),
                child: Column(
                  children: [
                    _buildAppBar(onPress: () => showBottomSheetPinChatWidget(context: context)),
                    if (ads.isNotEmpty) SizedBox(height: 2.h),
                    if (ads.isNotEmpty) _sliderImg(ads),
                    if (ads.isNotEmpty) SizedBox(height: 2.h),
                  ],
                ),
              ),
              _buildOtherConversationSection(systemChats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinnedChat(UserChatModel pinnedChat) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final hasValidImage = pinnedChat.image != null &&
        pinnedChat.image!.trim().isNotEmpty &&
        pinnedChat.image != "null" &&
        pinnedChat.image != "image";

    return Column(
      children: [
        Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            textNormal(
              S.of(context).positive_chat,
              pref ? AppColors.whiteColor : AppColors.blackColor,
              4.w,
              FontWeight.w400,
            ),
            SizedBox(width: 2.w),
            Icon(
              LucideIcons.pin300,
              size: 5.w,
              color: pref ? AppColors.whiteColor : AppColors.blackColor,
            ),
          ],
        ),
        SizedBox(height: 2.h),
        chatCardWidget(
          power: null,
          imageUrl: hasValidImage,
          numOfMessage: 0,
          needsAcceptance: pinnedChat.accept == "1",
          onPressImg: () {
            dialogImgWidget(
              title: pinnedChat.name ?? "",
              userChatModel: pinnedChat,
              img: null,
              onPressChat: () => _handleChatTap(context, pinnedChat, isPin: true),
            );
          },
          private: pinnedChat.status == "Private",
          img: hasValidImage
              ? CachedNetworkImageProvider(pinnedChat.image!.trim())
              : const AssetImage(AppImages.noChatImg) as ImageProvider,
          body: "${pinnedChat.membersCount ?? 0} ${S.of(context).engaged_people}",
          ttitle: pinnedChat.name ?? "",
          onPressJoin: () => _handleChatTap(context, pinnedChat, isPin: true),
          action: S.of(context).joinNow,
          ontap: () => _handleChatTap(context, pinnedChat, isPin: true),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildOtherConversationSection(List<UserChatModel> systemChats) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        _buildSectionHeader(
          title: S.of(context).otherChats,
          horizontalPadding: 4.w,
          onTap: () {
            context.push(
              Routes.sharedChatsScreen,
              extra: {'title': S.of(context).otherChats, 'type': 'system'},
            );
          },
        ),
        SizedBox(height: 2.h),
        if (systemChats.isEmpty)
          Center(child: noData(S.of(context).noChat))
        else
          Padding(
            padding: EdgeInsets.only(left: isRtl ? 0 : 4.w, right: isRtl ? 4.w : 0),
            child: Column(
              children: [
                for (int index = 0; index < systemChats.length; index++) ...[
                  if (index > 0) SizedBox(height: 2.h),
                  Builder(
                    builder: (context) {
                      final chat = systemChats[index];
                      final hasValidImage = chat.image != null &&
                          chat.image!.trim().isNotEmpty &&
                          chat.image != "null" &&
                          chat.image != "image";

                      return chatCardWidget(
                        needsAcceptance: chat.accept == "1",
                        power: null,
                        imageUrl: hasValidImage,
                        numOfMessage: 0,
                        onPressImg: () {
                          dialogImgWidget(
                            title: chat.name ?? '',
                            img: chat.image,
                            onPressChat: () => _handleChatTap(context, chat),
                            userChatModel: chat,
                          );
                        },
                        private: chat.status == "Private",
                        img: hasValidImage
                            ? CachedNetworkImageProvider(chat.image!.trim())
                            : const AssetImage(AppImages.noChatImg) as ImageProvider,
                        body: "${chat.membersCount ?? 0} ${S.of(context).engaged_people}",
                        ttitle: chat.name ?? '',
                        onPressJoin: () => _handleChatTap(context, chat),
                        isFriendsSection: false,
                        action: S.of(context).joinNow,
                        ontap: () => _handleChatTap(context, chat),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPrivateChatsSection(List<UserChatModel> userChats) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h),
        _buildSectionHeader(
          title: S.of(context).yourPrivateChats,
          horizontalPadding: 4.w,
          counterValue: userChats.length,
          showCounter: userChats.isNotEmpty,
          onTap: () {
            context.push(
              Routes.sharedChatsScreen,
              extra: {'title': S.of(context).yourPrivateChats, 'type': 'user'},
            );
          },
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.only(left: isRtl ? 0 : 4.w, right: isRtl ? 4.w : 0),
          child: Column(
            children: [
              for (int index = 0;
                  index < (userChats.isEmpty ? 1 : (userChats.length > 2 ? 3 : userChats.length + 1));
                  index++) ...[
                if (index > 0) SizedBox(height: 2.h),
                if (index == 0)
                  chatCardWidget(
                    needsAcceptance: false,
                    power: null,
                    imageUrl: true,
                    numOfMessage: 0,
                    onPressImg: () {},
                    private: false,
                    img: const AssetImage(AppImages.noChatImg),
                    body: S.of(context).startCreatingNewWorld,
                    ttitle: S.of(context).newChat,
                    onPressJoin: () => context.push(Routes.createChatScreen),
                    isFriendsSection: false,
                    action: S.of(context).createNow,
                    ontap: () => context.push(Routes.createChatScreen),
                  )
                else
                  Builder(
                    builder: (context) {
                      final chat = userChats[index - 1];
                      final hasValidImage = chat.image != null &&
                          chat.image!.trim().isNotEmpty &&
                          chat.image != "null" &&
                          chat.image != "image";

                      return chatCardWidget(
                        needsAcceptance: chat.accept == "1",
                        power: null,
                        imageUrl: hasValidImage,
                        numOfMessage: chat.unreadCount ?? 0,
                        onPressImg: () {
                          dialogImgWidget(
                            title: chat.name ?? '',
                            img: chat.image,
                            onPressChat: () => _handleChatTap(context, chat),
                            userChatModel: chat,
                          );
                        },
                        private: chat.status == "Private",
                        img: hasValidImage
                            ? CachedNetworkImageProvider(chat.image!.trim())
                            : const AssetImage(AppImages.noChatImg) as ImageProvider,
                        body: formatLastMessage(context, chat),
                        ttitle: chat.name ?? '',
                        onPressJoin: () => _handleChatTap(context, chat),
                        isFriendsSection: false,
                        action: S.of(context).joinNow,
                        ontap: () => _handleChatTap(context, chat),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsSection() {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, friendsState) {
        final friends = friendsState is FriendsLoaded ? friendsState.friends : [];
        final receivedCount = friendsState is FriendsLoaded ? friendsState.pendingRequestsCount : 0;
        final isRtl = Directionality.of(context) == TextDirection.rtl;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h),
            _buildSectionHeader(
              title: S.of(context).yourFriends,
              horizontalPadding: 4.w,
              counterValue: friends.length,
              showCounter: friends.isNotEmpty,
              hasNotificationDot: receivedCount > 0,
              onTap: () => context.push(Routes.friendsScreen),
            ),
            SizedBox(height: 2.h),
            if (friendsState is FriendsLoading)
              loading(10.h)
            else if (friends.isEmpty)
              Center(child: noData(S.of(context).noChat))
            else
              Padding(
                padding: EdgeInsets.only(left: isRtl ? 0 : 4.w, right: isRtl ? 4.w : 0),
                child: Column(
                  children: [
                    for (int index = 0; index < (friends.length > 2 ? 2 : friends.length); index++) ...[
                      if (index > 0) SizedBox(height: 2.h),
                      Builder(
                        builder: (context) {
                          final friend = friends[index];
                          final hasValidImage = friend.image != null &&
                              friend.image!.trim().isNotEmpty &&
                              friend.image != "null" &&
                              friend.image != "image";

                          return chatCardWidget(
                            needsAcceptance: false,
                            power: friend.power,
                            imageUrl: hasValidImage,
                            numOfMessage: 0,
                            onPressImg: () {
                              dialogImgWidget(
                                title: friend.name ?? '',
                                img: friend.image,
                                userChatModel: null,
                                onPressChat: () {
                                  if (friend.id != null) {
                                    context.read<FriendsCubit>().createChatFriend(friendId: friend.id!);
                                  }
                                },
                              );
                            },
                            private: false,
                            img: hasValidImage
                                ? CachedNetworkImageProvider(friend.image!.trim())
                                : const AssetImage(AppImages.noChatImg) as ImageProvider,
                            body: friend.requestStatus == "friends"
                                ? S.of(context).friend
                                : S.of(context).requestWaiting,
                            ttitle: friend.username ?? '',
                            onPressJoin: () {
                              if (friend.id != null) {
                                if (friend.requestStatus == "friends") {
                                  context.read<FriendsCubit>().createChatFriend(friendId: friend.id!);
                                } else {
                                  context.read<FriendsCubit>().sendFriendRequest(friendId: friend.id!);
                                }
                              }
                            },
                            isFriendsSection: true,
                            action: friend.requestStatus == "friends"
                                ? S.of(context).correspondent
                                : S.of(context).cancel,
                            ontap: () {
                              if (friend.id != null) {
                                if (friend.requestStatus == "friends") {
                                  context.read<FriendsCubit>().createChatFriend(friendId: friend.id!);
                                } else {
                                  context.read<FriendsCubit>().sendFriendRequest(friendId: friend.id!);
                                }
                              }
                            },
                            isFriend: friend.requestStatus == "friends",
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSuggestedFriendsSection() {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, friendsState) {
        final suggested = friendsState is FriendsLoaded ? friendsState.suggestedFriends : [];
        final isRtl = Directionality.of(context) == TextDirection.rtl;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h),
            _buildSectionHeader(
              title: S.of(context).suggestedFriends,
              horizontalPadding: 4.w,
              onTap: () => context.push(Routes.suggestedFriendsScreen),
            ),
            SizedBox(height: 2.h),
            if (friendsState is FriendsLoading)
              loading(10.h)
            else if (suggested.isEmpty)
              Center(child: noData(S.of(context).noChat))
            else
              Padding(
                padding: EdgeInsets.only(right: isRtl ? 4.w : 0, left: isRtl ? 0 : 4.w, bottom: 2.h),
                child: Column(
                  children: [
                    for (int index = 0; index < suggested.length; index++) ...[
                      if (index > 0) SizedBox(height: 2.h),
                      Builder(
                        builder: (context) {
                          final item = suggested[index];
                          final hasValidImage = item.image != null &&
                              item.image!.trim().isNotEmpty &&
                              item.image != "null" &&
                              item.image != "image";

                          return SuggestedFriends(
                            power: item.power,
                            imgUrl: hasValidImage,
                            onPressImg: () {
                              dialogImgWidget(
                                title: item.name ?? '',
                                img: item.image,
                                userChatModel: null,
                                onPressChat: () {
                                  if (item.id != null) {
                                    context.read<FriendsCubit>().createChatFriend(friendId: item.id!);
                                  }
                                },
                              );
                            },
                            chat: () {
                              if (item.id != null) {
                                context.read<FriendsCubit>().createChatFriend(friendId: item.id!);
                              }
                            },
                            removeRequest: () {
                              if (item.id != null) {
                                context.read<FriendsCubit>().sendFriendRequest(friendId: item.id!);
                              }
                            },
                            requestSend: item.requestStatus != "none",
                            sendRequest: () {
                              if (item.id != null) {
                                context.read<FriendsCubit>().sendFriendRequest(friendId: item.id!);
                              }
                            },
                            img: hasValidImage
                                ? CachedNetworkImageProvider(item.image!.trim())
                                : const AssetImage(AppImages.noChatImg) as ImageProvider,
                            body: item.requestStatus == "none"
                                ? S.of(context).notFriend
                                : S.of(context).requestWaiting,
                            ttitle: item.username ?? "",
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    double horizontalPadding = 0,
    bool showCounter = false,
    int counterValue = 0,
    bool hasNotificationDot = false,
    required VoidCallback onTap,
  }) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            textNormal(
              title,
              pref ? AppColors.whiteColor : AppColors.blackColor,
              4.5.w,
              FontWeight.w400,
            ),
            Row(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (hasNotificationDot) ...[
                  Container(
                    width: 2.5.w,
                    height: 2.5.w,
                    decoration: const BoxDecoration(
                      color: AppColors.redColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 2.w),
                ],
                if (showCounter) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: pref ? AppColors.secondaryColor : AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: textNormal(
                      "$counterValue",
                      pref ? AppColors.blackColor : Colors.white,
                      3.5.w,
                      FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 2.w),
                ],
                Icon(
                  isRtl ? LucideIcons.moveLeft300 : LucideIcons.moveRight300,
                  color: AppColors.secondaryColor,
                  size: 7.w,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar({required VoidCallback onPress}) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _buildUserGreeting(),
        _buildActionButtons(onPress: onPress),
      ],
    );
  }

  Widget _buildUserGreeting() {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    String? userImage = CacheHelper.getString(key: AppConstants.userImageKey);
    String? username = CacheHelper.getString(key: AppConstants.usernameKey);
    String? powerString = CacheHelper.getString(key: "powermodel");

    Widget displayWidget;

    if (powerString != null && powerString.isNotEmpty && powerString != "null") {
      try {
        final power = jsonDecode(powerString) as Map<String, dynamic>;
        final powerModel = PowerModel.fromJson(power);
        displayWidget = PowerTextWidget(
          powerModel: powerModel,
          displyText: username,
        );
      } catch (e) {
        displayWidget = textNormal(
          username ?? "User",
          pref ? AppColors.whiteColor : AppColors.blackColor,
          3.5.w,
          FontWeight.w400,
        );
      }
    } else {
      displayWidget = textNormal(
        username ?? "User",
        pref ? AppColors.whiteColor : AppColors.blackColor,
        3.5.w,
        FontWeight.w400,
      );
    }

    final hasValidImage = userImage != null &&
        userImage.trim().isNotEmpty &&
        userImage != "null" &&
        userImage != "image";

    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        hasValidImage
            ? CircleAvatar(
                radius: 4.w,
                backgroundImage: CachedNetworkImageProvider(userImage.trim()),
              )
            : CircleAvatar(
                radius: 4.w,
                backgroundColor: Colors.grey,
              ),
        SizedBox(width: 3.w),
        displayWidget,
      ],
    );
  }

  Widget _buildActionButtons({required VoidCallback onPress}) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _buildPinChatButton(onPress: onPress),
        IconButton(
          icon: Icon(
            LucideIcons.bell,
            size: 5.w,
            color: pref ? AppColors.inActiveColor : AppColors.blackColor,
          ),
          onPressed: () {
            context.push(Routes.notificationsScreen);
          },
        ),
      ],
    );
  }

  Widget _buildPinChatButton({required VoidCallback onPress}) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: 4.5.h,
        decoration: ShapeDecoration(
          color: pref ? AppColors.secondaryColor : AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                LucideIcons.keyRound,
                color: pref ? AppColors.blackColor : Colors.white,
                size: 4.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sliderImg(List ads) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return autoSliderImage(
      images: List.generate(
        ads.length,
        (index) {
          final ad = ads[index];
          final hasValidImage = ad.image != null &&
              ad.image!.toString().trim().isNotEmpty &&
              ad.image.toString() != "null" &&
              ad.image.toString() != "image";

          return InkWell(
            onTap: () {
              if (ad.link != null) {
                _launchURL(ad.link!);
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                !hasValidImage
                    ? Image.asset(AppImages.noChatImg, fit: BoxFit.cover)
                    : CachedNetworkImage(
                        errorWidget: (context, url, error) => Image.asset(AppImages.errorImg),
                        imageUrl: ad.image!.toString().trim(),
                        fit: BoxFit.cover,
                      ),
                Positioned(
                  top: 1.h,
                  right: isRtl ? 2.w : null,
                  left: isRtl ? null : 2.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.secondaryColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "إعلان",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 3.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: pref ? AppColors.darkcolor : AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: textNormal(
          S.of(context).warning,
          pref ? AppColors.whiteColor : AppColors.blackColor,
          4.5.w,
          FontWeight.w700,
        ),
        content: textNormal(
          S.of(context).exitConfirmation,
          pref ? AppColors.inActiveColor : AppColors.blackColor.withOpacity(0.6),
          3.5.w,
          FontWeight.w600,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: pref ? AppColors.secondaryColor : AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).exit),
          ),
        ],
      ),
    );
  }
}