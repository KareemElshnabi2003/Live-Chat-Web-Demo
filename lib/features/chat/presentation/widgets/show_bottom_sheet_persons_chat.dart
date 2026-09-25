// ignore_for_file: camel_case_types, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/features/chat/domain/entities/member_entity.dart';
import 'package:live_chat/features/chat/data/models/member_of_chat_model.dart';
import 'package:live_chat/features/market/data/models/power_model.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/core/widgets/loading.dart';
import 'package:live_chat/core/widgets/storetext.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:live_chat/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';

void showBottomSheetControlPersonWidget({
  required BuildContext context,
  required String idOwner,
  required bool isNeedAccept,
  required List<ChatAdmins> idAdmins,
  String? chatId,
}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: context.isDarkMode ? AppColors.blackColor : AppColors.bgColor,
    context: context,
    builder: (ctx) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: kIsWeb ? 600 : double.infinity),
      child: _ControlPersonBottomSheetContent(
        parentContext: context,
        isRtl: isRtl,
        idOwner: idOwner,
        idAdmins: idAdmins,
        isNeedAccept: isNeedAccept,
        chatId: chatId,
      ),
    ),
  );
}

class _ControlPersonBottomSheetContent extends StatefulWidget {
  final BuildContext parentContext;
  final bool isRtl;
  final String idOwner;
  final List<ChatAdmins> idAdmins;
  final bool isNeedAccept;
  final String? chatId;

  const _ControlPersonBottomSheetContent({
    required this.parentContext,
    required this.isRtl,
    required this.idOwner,
    required this.idAdmins,
    required this.isNeedAccept,
    this.chatId,
  });

  @override
  State<_ControlPersonBottomSheetContent> createState() =>
      _ControlPersonBottomSheetContentState();
}

class _ControlPersonBottomSheetContentState
    extends State<_ControlPersonBottomSheetContent> {
  bool get pref => widget.parentContext.isDarkMode;
  final ScrollController _scrollController = ScrollController();
  List<MemberEntity> _members = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMembers() async {
    final chatId = widget.chatId;
    if (chatId == null) return;

    setState(() => _isLoading = true);
    final raw = await widget.parentContext.read<ChatCubit>().getMembers(chatId: chatId);
    if (mounted) {
      setState(() {
        _members = raw;
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptMember(int memberId) async {
    final chatId = widget.chatId;
    if (chatId == null) return;
    final success = await widget.parentContext.read<ChatCubit>().acceptMemberToChat(
      chatId: chatId,
      userId: memberId.toString(),
    );
    if (success) {
      setState(() {
        _members.removeWhere((m) => m.id == memberId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).success), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _chatWithMember(int memberId) async {
    final chat = await widget.parentContext.read<FriendsCubit>().createChatFriend(friendId: memberId);
    if (chat != null && mounted) {
      Navigator.pop(context);
      context.pushNamed(Routes.chatScreen, extra: {
        'chatId': chat.id.toString(),
        'userChatModel': chat,
      });
    }
  }

  Future<void> _sendFriendRequest(int memberId) async {
    await widget.parentContext.read<FriendsCubit>().sendFriendRequest(friendId: memberId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).youSendRequest), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 65.h,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              Container(
                height: 4,
                width: 70,
                color: pref ? AppColors.whiteColor : AppColors.blackColor,
              ),
              Container(
                padding: EdgeInsets.only(right: 4.w, left: 4.w, top: 4.w),
                width: 100.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: widget.isRtl
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      textDirection:
                          widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        textNormal(
                          S.of(context).members,
                          pref ? AppColors.whiteColor : AppColors.blackTextColor,
                          4.w,
                          FontWeight.w600,
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    _isLoading
                        ? loading(8.h)
                        : _members.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: textNormal(
                                  S.of(context).noMembers,
                                  AppColors.inActiveColor,
                                  3.5.w,
                                  FontWeight.w400,
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _members.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final member = _members[index];
                                  final isOwner = member.id.toString() == widget.idOwner;
                                  final isAdmin = widget.idAdmins.any(
                                    (element) => element.chatAdminId == member.id.toString(),
                                  );

                                  return _CardPersonItem(
                                    ttitle: member.username ?? '',
                                    idPerson: member.id.toString(),
                                    isGust: member.isGuest ?? false,
                                    isFriend: member.requestStatus ?? 'none',
                                    isAdmin: isAdmin,
                                    isOwner: isOwner,
                                    isNeedAccept: widget.isNeedAccept,
                                    power: member is MemberOfChatModel ? member.power : null,
                                    onPressChat: () => _chatWithMember(member.id!),
                                    onPressAdd: () => _sendFriendRequest(member.id!),
                                    onPressAccept: () => _acceptMember(member.id!),
                                  );
                                },
                              ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPersonItem extends StatelessWidget {
  final String ttitle;
  final VoidCallback onPressChat;
  final VoidCallback onPressAdd;
  final VoidCallback onPressAccept;
  final bool isNeedAccept;
  final bool isAdmin;
  final bool isOwner;
  final String isFriend;
  final bool isGust;
  final String idPerson;
  final PowerModel? power;

  const _CardPersonItem({
    required this.ttitle,
    required this.onPressChat,
    required this.onPressAdd,
    required this.isNeedAccept,
    required this.isAdmin,
    required this.isOwner,
    required this.isFriend,
    required this.onPressAccept,
    required this.isGust,
    required this.idPerson,
    required this.power,
  });

  @override
  Widget build(BuildContext context) {
    final bool pref = context.isDarkMode;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final currentUserId = CacheHelper.getString(key: AppConstants.userIdKey) ?? '';
    final shouldShowActionButtons = !isOwner && !isNeedAccept && !isGust && currentUserId != idPerson;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 55.w,
              child: power != null
                  ? PowerTextWidget(powerModel: power!, displyText: ttitle)
                  : textNormal(
                      ttitle,
                      pref ? AppColors.whiteColor : AppColors.blackTextColor,
                      3.5.w,
                      FontWeight.w400,
                    ),
            ),
            if (!isNeedAccept)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: textNormal(
                  isAdmin
                      ? S.of(context).admin
                      : isOwner
                          ? S.of(context).owner
                          : S.of(context).member,
                  AppColors.inActiveColor,
                  3.w,
                  FontWeight.w400,
                ),
              ),
          ],
        ),
        if (isNeedAccept)
          InkWell(
            onTap: onPressAccept,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
          ),
        if (shouldShowActionButtons)
          Row(
            children: [
              if (isFriend == "none")
                IconButton(
                  icon: const Icon(Icons.person_add_alt, size: 20),
                  color: AppColors.primaryColor,
                  onPressed: onPressAdd,
                ),
              IconButton(
                icon: const Icon(LucideIcons.messageCircle, size: 20),
                color: pref ? AppColors.secondaryColor : AppColors.blackColor,
                onPressed: onPressChat,
              ),
            ],
          ),
      ],
    );
  }
}
