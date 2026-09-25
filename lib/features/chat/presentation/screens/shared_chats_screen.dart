import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/Constant/app_images.dart';
import 'package:live_chat/core/di/service_locator.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/core/widgets/chat_card_widget.dart';
import 'package:live_chat/core/widgets/dialog_img.dart';
import 'package:live_chat/core/widgets/no_data.dart';
import 'package:live_chat/core/widgets/shimmer_skeletons.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/features/home/domain/repositories/home_repository.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/core/function/format_last_message.dart';

class SharedChatsScreen extends StatefulWidget {
  final String title;
  final String chatType; // 'recent', 'system', 'user'

  const SharedChatsScreen({
    super.key,
    required this.title,
    this.chatType = 'recent',
  });

  @override
  State<SharedChatsScreen> createState() => _SharedChatsScreenState();
}

class _SharedChatsScreenState extends State<SharedChatsScreen> {
  final HomeRepository _homeRepository = sl<HomeRepository>();
  final ScrollController _scrollController = ScrollController();

  List<UserChatModel> _chatsList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _perPage = 15;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData &&
        !_isLoading) {
      _loadMoreChats();
    }
  }

  Future<void> _loadChats({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
    } else {
      setState(() => _isLoading = true);
    }

    final result = widget.chatType == 'system'
        ? await _homeRepository.getSystemChats(page: 1, perPage: _perPage)
        : widget.chatType == 'user'
            ? await _homeRepository.getUserChats(page: 1, perPage: _perPage)
            : await _homeRepository.getRecentChats(page: 1, perPage: _perPage);

    result.fold(
      (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      (chats) {
        if (mounted) {
          setState(() {
            _chatsList = chats;
            _isLoading = false;
            _hasMoreData = chats.length >= _perPage;
          });
        }
      },
    );
  }

  Future<void> _loadMoreChats() async {
    if (_isLoadingMore || !_hasMoreData) return;
    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final result = widget.chatType == 'system'
        ? await _homeRepository.getSystemChats(page: nextPage, perPage: _perPage)
        : widget.chatType == 'user'
            ? await _homeRepository.getUserChats(page: nextPage, perPage: _perPage)
            : await _homeRepository.getRecentChats(page: nextPage, perPage: _perPage);

    result.fold(
      (error) {
        if (mounted) setState(() => _isLoadingMore = false);
      },
      (newChats) {
        if (mounted) {
          setState(() {
            _currentPage = nextPage;
            _chatsList.addAll(newChats);
            _isLoadingMore = false;
            _hasMoreData = newChats.length >= _perPage;
          });
        }
      },
    );
  }

  bool _isValidImage(String? url) {
    return url != null && url.trim().isNotEmpty && url.trim() != "null" && url.trim() != "image";
  }

  Future<void> _onChatTap(UserChatModel chat) async {
    if (chat.status == "Public" || chat.status == "Private") {
      final joined = await _homeRepository.joinToChat(chatId: chat.id);
      final canEnter = joined.fold((l) => false, (r) => r);
      if (!canEnter && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).waitForAccept),
            backgroundColor: Colors.orange.shade600,
          ),
        );
        return;
      }
    }
    if (mounted) {
      context.push(
        Routes.chatScreen,
        extra: {
          'userChatModel': chat,
          'isPin': false,
          'isGust': false,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: pref ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(left: isRtl ? 2.w : 4.w, right: isRtl ? 4.w : 2.w, top: 5.h, bottom: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isRtl),
            SizedBox(height: 4.h),
            Expanded(
              child: _isLoading
                  ? ShimmerSkeletons.chatListSkeleton()
                  : _chatsList.isEmpty
                      ? Center(child: noData(S.of(context).noChat))
                      : RefreshIndicator(
                          onRefresh: () async {
                            await _loadChats(isRefresh: true);
                          },
                          color: AppColors.secondaryColor,
                          backgroundColor: pref ? AppColors.darkcolor : AppColors.whiteColor,
                          child: _buildChatList(isRtl, context),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isRtl) {
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            isRtl ? IconsaxPlusLinear.arrow_right_3 : IconsaxPlusLinear.arrow_left_1,
            size: kIsWeb ? 24.0 : 5.5.w,
            color: pref ? AppColors.whiteColor : AppColors.blackTextColor,
          ),
        ),
        SizedBox(width: 2.w),
        textNormal(widget.title, pref ? AppColors.whiteColor : AppColors.blackTextColor, 4.5.w, FontWeight.w500),
      ],
    );
  }

  Widget _buildChatList(bool isRtl, BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: EdgeInsets.only(right: isRtl ? 0.w : 2.w, left: isRtl ? 2.w : 0.w),
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemCount: _chatsList.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _chatsList.length) {
            final chat = _chatsList[index];
            final hasValidImg = _isValidImage(chat.image);

            return chatCardWidget(
              needsAcceptance: chat.accept == "1",
              power: null,
              imageUrl: hasValidImg,
              numOfMessage: 0,
              onPressImg: () {
                dialogImgWidget(
                  title: chat.name ?? '',
                  img: null,
                  userChatModel: chat,
                  onPressChat: () => _onChatTap(chat),
                );
              },
              private: chat.status == "Private",
              img: hasValidImg
                  ? CachedNetworkImageProvider(chat.image!.trim())
                  : const AssetImage(AppImages.noChatImg) as ImageProvider,
              body: formatLastMessage(context, chat),
              ttitle: chat.name ?? '',
              action: S.of(context).joinNow,
              onPressJoin: () => _onChatTap(chat),
              ontap: () => _onChatTap(chat),
            );
          } else {
            return _buildLoadingMoreIndicator();
          }
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      alignment: Alignment.center,
      child: SizedBox(
        height: 6.w,
        width: 6.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(pref ? AppColors.whiteColor : AppColors.blackTextColor),
        ),
      ),
    );
  }
}