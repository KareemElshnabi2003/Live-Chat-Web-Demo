import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/Constant/app_images.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/features/friends/data/models/friend_suggest_model.dart';
import 'package:live_chat/features/market/data/models/power_model.dart';
import 'package:live_chat/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:live_chat/features/friends/presentation/cubit/friends_state.dart';
import 'package:live_chat/core/widgets/dialog_img.dart';
import 'package:live_chat/core/widgets/shimmer_skeletons.dart';
import 'package:live_chat/core/widgets/no_data.dart';
import 'package:live_chat/core/widgets/storetext.dart';
import 'package:live_chat/core/widgets/text_click_widget.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

Widget friendsChatCard({
  required BuildContext context,
  required ImageProvider img,
  required PowerModel? power,
  required String ttitle,
  required String body,
  required bool imgUrl,
  required VoidCallback onPressJoin,
  required VoidCallback onPressRemove,
  required VoidCallback onPressImg,
  bool isFriendsSection = false,
  bool isFriend = true,
  bool isEditing = false,
}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  return SizedBox(
    height: 19.w,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        InkWell(
          onTap: onPressJoin,
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              _buildProfileImage(img, ttitle, imgUrl, isFriendsSection, onPressImg),
              SizedBox(width: 2.w),
              _buildChatDetails(context, power, ttitle, body, isFriend, onPressJoin),
            ],
          ),
        ),
        _buildActionButton(isEditing, isFriend, onPressRemove, isRtl),
      ],
    ),
  );
}

Widget _buildProfileImage(ImageProvider img, String ttitle, bool imgUrl, bool isFriendsSection, VoidCallback onPressImg) {
  return InkWell(
    onTap: onPressImg,
    child: Container(
      width: 19.w,
      height: 19.w,
      decoration: BoxDecoration(
        color: pref ? AppColors.darkcolor : AppColors.black2TextColor,
        image: imgUrl ? DecorationImage(image: img, fit: BoxFit.fill) : null,
        borderRadius: BorderRadius.circular(isFriendsSection ? 80 : 20),
      ),
      child: imgUrl ? null : Center(child: textNormal(ttitle.isNotEmpty ? ttitle[0] : '', AppColors.whiteColor, 7.w, FontWeight.bold)),
    ),
  );
}

Widget _buildChatDetails(BuildContext context, PowerModel? power, String ttitle, String body, bool isFriend, VoidCallback onPressJoin) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      power != null
          ? PowerTextWidget(powerModel: power, displyText: ttitle)
          : textNormal(ttitle, pref ? AppColors.whiteColor : AppColors.blackTextColor, 3.5.w, FontWeight.w400),
      const Spacer(flex: 1),
      textNormal(body, isFriend ? (pref ? AppColors.inActiveColor : AppColors.black2TextColor) : AppColors.secondaryColor, 3.w, FontWeight.w500),
      const Spacer(flex: 2),
      textClick(isFriend ? S.of(context).correspondent : S.of(context).cancel, false, onPressJoin, isFriend ? (pref ? AppColors.secondaryColor : AppColors.primaryColor) : AppColors.redColor, 3.w),
    ],
  );
}

Widget _buildActionButton(bool isEditing, bool isFriend, VoidCallback onPressRemove, bool isRtl) {
  return InkWell(
    onTap: onPressRemove,
    child: Container(
      padding: EdgeInsets.only(right: isRtl ? 2.w : 6.w, left: isRtl ? 6.w : 2.w),
      height: 14.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isEditing ? (pref ? AppColors.darkcolor : AppColors.bgColor) : (pref ? AppColors.blackColor : AppColors.whiteColor),
        borderRadius: BorderRadius.only(
          topLeft: isRtl ? Radius.zero : const Radius.circular(20),
          bottomLeft: isRtl ? Radius.zero : const Radius.circular(20),
          topRight: isRtl ? const Radius.circular(20) : Radius.zero,
          bottomRight: isRtl ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      child: Container(
        height: 12.w,
        width: 12.w,
        decoration: ShapeDecoration(color: pref ? AppColors.blackColor : AppColors.bgColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: Center(
          child: Icon(
            isEditing ? (isFriend ? IconsaxPlusLinear.profile_delete : Icons.close) : (isFriend ? (isRtl ? IconsaxPlusLinear.arrow_left : IconsaxPlusLinear.arrow_right) : Icons.close),
            color: isEditing ? Colors.red : (pref ? AppColors.whiteColor : AppColors.blackColor),
            size: 6.w,
          ),
        ),
      ),
    ),
  );
}

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<FriendsCubit>().loadFriendsAndSuggestions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: pref ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(left: isRtl ? 0 : 4.w, right: isRtl ? 4.w : 0, top: 5.h, bottom: 2.h),
        child: BlocConsumer<FriendsCubit, FriendsState>(
          listener: (context, state) {
            if (state is FriendsActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is FriendsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final isEditing = state is FriendsLoaded ? state.isEditing : false;
            final pendingCount = state is FriendsLoaded ? state.pendingRequestsCount : 0;
            final friendsList = state is FriendsLoaded ? state.friends : <SuggestFreindModel>[];
            final isLoading = state is FriendsLoading;

            return RefreshIndicator(
              onRefresh: () => context.read<FriendsCubit>().loadFriendsAndSuggestions(),
              color: AppColors.secondaryColor,
              backgroundColor: pref ? AppColors.darkcolor : AppColors.whiteColor,
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(context, isRtl, isEditing, pendingCount),
                  SizedBox(height: 5.h),
                  _buildChatList(context, isLoading, friendsList, isEditing, isRtl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isRtl, bool isEditing, int pendingCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(isRtl ? IconsaxPlusLinear.arrow_right_3 : IconsaxPlusLinear.arrow_left_1, size: 5.5.w, color: pref ? AppColors.whiteColor : AppColors.blackColor),
            ),
            SizedBox(width: 2.w),
            textNormal(S.of(context).yourFriends, pref ? AppColors.whiteColor : AppColors.blackTextColor, 4.5.w, FontWeight.w500),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Row(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  textClick(S.of(context).requests, true, () => context.push(Routes.friendRequestsScreen), pref ? AppColors.whiteColor : AppColors.blackTextColor, 3.5.w),
                  SizedBox(width: 1.5.w),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: pendingCount > 0
                          ? AppColors.redColor
                          : (pref ? AppColors.secondaryColor : AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$pendingCount",
                      style: TextStyle(
                        color: pendingCount > 0 ? Colors.white : (pref ? AppColors.blackColor : Colors.white),
                        fontSize: 3.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: textClick(
                isEditing ? S.of(context).cancel : S.of(context).edit,
                true,
                () => context.read<FriendsCubit>().toggleEditing(),
                pref ? AppColors.whiteColor : AppColors.blackTextColor,
                3.5.w,
              ),
            ),
            SizedBox(width: 2.w)
          ],
        ),
      ],
    );
  }

  Widget _buildChatList(BuildContext context, bool isLoading, List<SuggestFreindModel> friends, bool isEditing, bool isRtl) {
    if (isLoading && friends.isEmpty) {
      return ShimmerSkeletons.chatListSkeleton(isFriendsSection: true);
    }
    if (friends.isEmpty) {
      return Center(child: noData(S.of(context).noChat));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: friends.length,
      itemBuilder: (context, index) => _buildFriendItem(context, friends[index], isEditing),
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
    );
  }

  Widget _buildFriendItem(BuildContext context, SuggestFreindModel friend, bool isEditing) {
    bool isValidImage(String? url) {
      return url != null && url.trim().isNotEmpty && url.trim() != "null" && url.trim() != "image";
    }

    final hasValidImg = isValidImage(friend.image);

    void openChat() {
      final userChat = UserChatModel(
        id: friend.id,
        name: friend.name ?? friend.username,
        image: friend.image,
      );
      context.push(Routes.chatScreen, extra: {
        'userChatModel': userChat,
        'isPin': false,
        'isGust': false,
      });
    }

    return friendsChatCard(
      context: context,
      onPressImg: () => dialogImgWidget(
        title: friend.username ?? "",
        img: friend.image,
        onPressChat: () {
          if (friend.requestStatus == "friends") openChat();
        },
        userChatModel: null,
      ),
      imgUrl: hasValidImg,
      power: friend.power,
      isFriend: friend.requestStatus == "friends",
      isFriendsSection: true,
      isEditing: isEditing,
      onPressRemove: () {
        if (isEditing) {
          if (friend.id != null) {
            context.read<FriendsCubit>().deleteFriend(friend.id.toString());
          }
        } else {
          openChat();
        }
      },
      img: hasValidImg ? CachedNetworkImageProvider(friend.image!.trim()) : const AssetImage(AppImages.noChatImg),
      body: friend.requestStatus == "friends" ? S.of(context).friend : S.of(context).requestWaiting,
      ttitle: friend.name ?? friend.username ?? "",
      onPressJoin: () {
        if (friend.requestStatus == "friends") openChat();
      },
    );
  }
}