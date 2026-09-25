import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/core/theme/app_colors.dart';
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
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

bool _isValidImage(String? url) {
  return url != null && url.trim().isNotEmpty && url.trim() != "null" && url.trim() != "image";
}

Widget friendsRequestCard({
  required BuildContext context,
  required ImageProvider img,
  required PowerModel? power,
  required VoidCallback onPressImg,
  required VoidCallback onPressChat,
  required bool imgUrl,
  required String ttitle,
  required String body,
  VoidCallback? onPressAccept,
  VoidCallback? onPressReject,
  VoidCallback? onPressCancel,
  bool isSentRequest = false,
}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  return Padding(
    padding: EdgeInsets.only(left: isRtl ? 0.w : 4.w, right: isRtl ? 4.w : 0.w),
    child: SizedBox(
      height: 19.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              imgUrl
                  ? InkWell(
                      onTap: onPressImg,
                      child: Container(
                        width: 19.w,
                        height: 19.w,
                        decoration: BoxDecoration(
                          color: pref ? AppColors.darkcolor : null,
                          image: DecorationImage(image: img, fit: BoxFit.fill),
                          borderRadius: BorderRadius.circular(80),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: onPressImg,
                      child: Container(
                        alignment: Alignment.center,
                        width: 19.w,
                        height: 19.w,
                        decoration: BoxDecoration(
                          color: pref ? AppColors.darkcolor : AppColors.black2TextColor,
                          borderRadius: BorderRadius.circular(80),
                        ),
                        child: textNormal(
                          ttitle.isNotEmpty ? ttitle[0] : '',
                          AppColors.whiteColor,
                          7.w,
                          FontWeight.bold,
                        ),
                      ),
                    ),
              SizedBox(width: 2.w),
              InkWell(
                onTap: onPressChat,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    power != null
                        ? PowerTextWidget(powerModel: power, displyText: ttitle)
                        : textNormal(ttitle, pref ? AppColors.whiteColor : AppColors.blackTextColor, 3.5.w, FontWeight.w400),
                    const Spacer(flex: 1),
                    textNormal(body, pref ? AppColors.inActiveColor : AppColors.black2TextColor, 3.w, FontWeight.w500),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (!isRtl) SizedBox(width: 4.w),
              if (isSentRequest)
                InkWell(
                  onTap: onPressCancel,
                  child: Container(
                    height: 10.w,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.redColor),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(
                          color: AppColors.redColor,
                          fontSize: 3.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              else ...[
                InkWell(
                  onTap: onPressAccept,
                  child: Container(
                    height: 12.w,
                    width: 12.w,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: pref ? AppColors.whiteColor : AppColors.blackColor),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: pref ? AppColors.whiteColor : AppColors.blackColor,
                        size: 6.w,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: onPressReject,
                  child: Container(
                    height: 12.w,
                    width: 12.w,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.redColor),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        color: AppColors.redColor,
                        size: 6.w,
                      ),
                    ),
                  ),
                ),
              ],
              if (isRtl) SizedBox(width: 4.w),
            ],
          ),
        ],
      ),
    ),
  );
}

class Requests extends StatefulWidget {
  const Requests({super.key});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  @override
  void initState() {
    super.initState();
    context.read<FriendsCubit>().loadFriendsAndSuggestions();
  }

  Widget _buildTabBadge(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        if (count > 0) ...[
          SizedBox(width: 2.w),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.redColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$count",
              style: TextStyle(
                color: Colors.white,
                fontSize: 2.8.w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: pref ? AppColors.blackColor : AppColors.bgColor,
        body: Padding(
          padding: EdgeInsets.only(left: isRtl ? 0.w : 4.w, right: isRtl ? 4.w : 0.w, top: 5.h, bottom: 2.h),
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
              final received = state is FriendsLoaded ? state.receivedRequests : <SuggestFreindModel>[];
              final sent = state is FriendsLoaded ? state.sentRequests : <SuggestFreindModel>[];
              final isLoading = state is FriendsLoading;

              return Column(
                children: [
                  _buildHeader(context, isRtl),
                  SizedBox(height: 2.h),
                  TabBar(
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: pref ? AppColors.whiteColor : AppColors.blackTextColor,
                    indicatorColor: AppColors.primaryColor,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(child: _buildTabBadge(isRtl ? 'مستلمة' : 'Received', received.length)),
                      Tab(child: _buildTabBadge(isRtl ? 'مرسلة' : 'Sent', sent.length)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        RefreshIndicator(
                          onRefresh: () => context.read<FriendsCubit>().loadFriendsAndSuggestions(),
                          color: AppColors.secondaryColor,
                          backgroundColor: pref ? AppColors.darkcolor : AppColors.whiteColor,
                          child: _buildChatList(context, isLoading, received, false),
                        ),
                        RefreshIndicator(
                          onRefresh: () => context.read<FriendsCubit>().loadFriendsAndSuggestions(),
                          color: AppColors.secondaryColor,
                          backgroundColor: pref ? AppColors.darkcolor : AppColors.whiteColor,
                          child: _buildChatList(context, isLoading, sent, true),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isRtl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                isRtl ? IconsaxPlusLinear.arrow_right_3 : IconsaxPlusLinear.arrow_left_1,
                size: 5.5.w,
                color: pref ? AppColors.whiteColor : AppColors.blackColor,
              ),
            ),
            SizedBox(width: 2.w),
            textNormal(
              S.of(context).requests,
              pref ? AppColors.whiteColor : AppColors.blackTextColor,
              4.5.w,
              FontWeight.w500,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatList(BuildContext context, bool isLoading, List<SuggestFreindModel> list, bool isSent) {
    if (isLoading && list.isEmpty) {
      return ShimmerSkeletons.chatListSkeleton(isFriendsSection: true);
    }
    if (list.isEmpty) {
      return Center(
        child: SizedBox(
          width: 80.w,
          child: noData(S.of(context).notFriendRequest),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 2.h),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final friend = list[index];
        final hasValidImg = _isValidImage(friend.image);

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

        return friendsRequestCard(
          context: context,
          isSentRequest: isSent,
          onPressCancel: isSent && friend.id != null
              ? () => context.read<FriendsCubit>().replyFriendRequest(friend.id.toString(), 'reject')
              : null,
          onPressChat: openChat,
          power: friend.power,
          imgUrl: hasValidImg,
          onPressImg: () => dialogImgWidget(
            title: friend.username ?? "",
            img: friend.image,
            onPressChat: openChat,
            userChatModel: null,
          ),
          onPressAccept: !isSent && friend.id != null
              ? () => context.read<FriendsCubit>().replyFriendRequest(friend.id.toString(), 'accept')
              : null,
          onPressReject: !isSent && friend.id != null
              ? () => context.read<FriendsCubit>().replyFriendRequest(friend.id.toString(), 'reject')
              : null,
          img: hasValidImg ? CachedNetworkImageProvider(friend.image!.trim()) : const AssetImage(AppImages.noChatImg),
          body: isSent ? S.of(context).youSendRequest : S.of(context).sendToYouRequest,
          ttitle: friend.name ?? friend.username ?? "",
        );
      },
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
    );
  }
}