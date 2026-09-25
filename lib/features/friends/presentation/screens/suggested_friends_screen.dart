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
import 'package:live_chat/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:live_chat/features/friends/presentation/cubit/friends_state.dart';
import 'package:live_chat/core/widgets/dialog_img.dart';
import 'package:live_chat/core/widgets/shimmer_skeletons.dart';
import 'package:live_chat/core/widgets/no_data.dart';
import 'package:live_chat/core/widgets/sugessted_friends.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class SuggessionChat extends StatefulWidget {
  const SuggessionChat({super.key});

  @override
  State<SuggessionChat> createState() => _SuggessionChatState();
}

class _SuggessionChatState extends State<SuggessionChat> {
  final ScrollController _scrollController = ScrollController();

  bool _isValidImage(String? url) {
    return url != null &&
        url.trim().isNotEmpty &&
        url.trim() != "null" &&
        url.trim() != "image";
  }

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
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(
            left: isRtl ? 0.w : 4.w,
            right: isRtl ? 4.w : 0.w,
            top: 3.h,
            bottom: 2.h),
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
            final suggestions = state is FriendsLoaded
                ? state.suggestedFriends
                : <SuggestFreindModel>[];
            final isLoading = state is FriendsLoading;

            return _buildContent(context, isLoading, suggestions, isRtl);
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            isRtl
                ? IconsaxPlusLinear.arrow_right_3
                : IconsaxPlusLinear.arrow_left_1,
            size: 5.5.w,
            color: pref! ? AppColors.whiteColor : AppColors.blackColor,
          ),
        ),
        SizedBox(width: 2.w),
        textNormal(
          S.of(context).suggestedFriends,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          4.5.w,
          FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildContent(
      BuildContext context, bool isLoading, List<SuggestFreindModel> suggestions, bool isRtl) {
    if (isLoading && suggestions.isEmpty) {
      return Column(
        children: [
          _buildHeader(context),
          Expanded(child: ShimmerSkeletons.chatListSkeleton()),
        ],
      );
    }
    if (suggestions.isEmpty) {
      return Column(
        children: [
          _buildHeader(context),
          SizedBox(height: 6.h),
          Expanded(
            child: Center(child: noData(S.of(context).noChat)),
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<FriendsCubit>().loadFriendsAndSuggestions(),
      color: AppColors.secondaryColor,
      backgroundColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: suggestions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(children: [_buildHeader(context), SizedBox(height: 6.h)]);
          }
          final friendIndex = index - 1;
          final friend = suggestions[friendIndex];
          final hasValidImage = _isValidImage(friend.image);

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

          return Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: SuggestedFriends(
              power: friend.power,
              imgUrl: hasValidImage,
              onPressImg: () {
                dialogImgWidget(
                  title: friend.name ?? friend.username ?? "",
                  img: friend.image,
                  userChatModel: null,
                  onPressChat: openChat,
                );
              },
              chat: openChat,
              removeRequest: () {
                if (friend.id != null) {
                  context.read<FriendsCubit>().sendRequest(friend.id.toString());
                }
              },
              requestSend: friend.requestStatus != "none" && friend.requestStatus != null,
              sendRequest: () {
                if (friend.id != null) {
                  context.read<FriendsCubit>().sendRequest(friend.id.toString());
                }
              },
              img: hasValidImage
                  ? CachedNetworkImageProvider(friend.image!.trim())
                  : const AssetImage(AppImages.noChatImg),
              body: (friend.requestStatus == "none" || friend.requestStatus == null)
                  ? S.of(context).notFriend
                  : S.of(context).requestWaiting,
              ttitle: friend.name ?? friend.username ?? "",
            ),
          );
        },
      ),
    );
  }
}
