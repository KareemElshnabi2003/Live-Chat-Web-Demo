import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import 'package:live_chat/features/notifications/data/models/notify_model.dart';
import 'package:live_chat/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:live_chat/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:live_chat/core/widgets/shimmer_skeletons.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().getNotifications();
  }

  String _formatDateTime(String? dateStr, bool langAr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      final dt = DateTime.parse(dateStr);
      final formatter = DateFormat(langAr ? "yyyy/MM/dd hh:mm a" : "yyyy-MM-dd hh:mm a", langAr ? "ar" : "en");
      return formatter.format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final selectedLang = CacheHelper.getString(key: "selectedLanguage") ?? 'ar';
    final bool langAr = selectedLang == 'ar';

    return Scaffold(
      backgroundColor: pref ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.only(
            left: 4.w, right: 4.w, top: 5.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Row(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        isRtl
                            ? IconsaxPlusLinear.arrow_right_3
                            : IconsaxPlusLinear.arrow_left_1,
                        color: pref ? AppColors.whiteColor : AppColors.blackColor,
                        size: 5.5.w,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    textNormal(
                      S.of(context).notifications,
                      pref ? AppColors.whiteColor : AppColors.blackTextColor,
                      4.5.w,
                      FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  if (state is NotificationsLoading) {
                    return ShimmerSkeletons.chatListSkeleton();
                  }

                  final notifications = state is NotificationsLoaded
                      ? state.notifications
                      : <NotifyModel>[];

                  if (notifications.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return RefreshIndicator(
                    color: AppColors.secondaryColor,
                    backgroundColor: pref ? AppColors.darkcolor : AppColors.whiteColor,
                    onRefresh: () => context.read<NotificationsCubit>().getNotifications(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationCard(notification, isRtl, langAr);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotifyModel notification, bool isRtl, bool langAr) {
    String title = '';
    String body = '';

    final additionalData = notification.additionalData;

    if (additionalData != null && additionalData['type'] == "friend_request" && additionalData['status'] == "pending") {
      title = langAr ? 'طلب صداقة' : 'Friend Request';
      body = langAr
          ? 'أرسل إليك ${additionalData['username']} طلب صداقة'
          : '${additionalData['username']} send you a friend request';
    } else if (additionalData != null && additionalData['type'] == "friend_request" && additionalData['status'] == "accepted") {
      title = langAr ? 'طلب صداقة' : 'Friend Request';
      body = langAr
          ? 'تم قبول طلب الصداقة الذي أرسلته إلي ${additionalData['username']}'
          : 'The friend request you sent to ${additionalData['username']} has been accepted.';
    } else if (additionalData != null && additionalData['status'] == "want_to_join_chat") {
      title = additionalData['conversation_name']?.toString() ?? '';
      body = langAr
          ? 'انضم ${additionalData['username']} إلي المحادثه : ${additionalData['conversation_name']}'
          : '${additionalData['username']} join to chat : ${additionalData['conversation_name']}';
    } else {
      title = notification.title ?? '';
      body = notification.content ?? '';
    }

    String imageUrl = (additionalData?['image']?.toString().contains("https") ?? false)
        ? additionalData!['image'].toString()
        : "https://api.mayo.live/storage/${additionalData?['image'] ?? ''}";

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: pref ? AppColors.darkcolor.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: pref ? [] : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (additionalData != null && additionalData['type'] == "friend_request" && additionalData['status'] == "pending") {
            context.push(Routes.friendRequestsScreen);
          } else if (additionalData != null && additionalData['type'] == "friend_request" && additionalData['status'] == "accepted") {
            context.push(Routes.friendsScreen);
          } else if (additionalData != null && additionalData['status'] == "want_to_join_chat" && additionalData['conversation'] != null) {
            context.push(Routes.chatScreen, extra: {
              'userChatModel': UserChatModel.fromJson(Map<String, dynamic>.from(additionalData['conversation'])),
              'isPin': false,
              'isGust': false,
            });
          }
        },
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pref ? AppColors.black2TextColor : Colors.grey.shade200,
                image: (additionalData != null && additionalData['image'] != null && additionalData['image'].toString().isNotEmpty)
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (additionalData == null || additionalData['image'] == null || additionalData['image'].toString().isEmpty)
                  ? Icon(LucideIcons.bellRing, color: AppColors.secondaryColor, size: 6.w)
                  : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textNormal(
                    title,
                    pref ? AppColors.whiteColor : AppColors.blackColor,
                    3.8.w,
                    FontWeight.bold,
                  ),
                  SizedBox(height: 0.5.h),
                  textNormal(
                    multi: true,
                    numOfRow: 2,
                    body,
                    pref ? AppColors.inActiveColor : AppColors.black2TextColor,
                    3.3.w,
                    FontWeight.w500,
                  ),
                  SizedBox(height: 1.h),
                  textNormal(
                    _formatDateTime(notification.date, langAr),
                    pref ? AppColors.secondaryColor : AppColors.primaryColor,
                    3.w,
                    FontWeight.w500,
                  ),
                ],
              ),
            ),
            Icon(
              isRtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
              color: pref ? AppColors.inActiveColor : Colors.grey.shade400,
              size: 5.w,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bellOff,
            size: 20.w,
            color: pref ? AppColors.inActiveColor : AppColors.black2TextColor,
          ),
          SizedBox(height: 3.h),
          textNormal(
            S.of(context).noNotifications,
            pref ? AppColors.whiteColor : AppColors.blackTextColor,
            4.5.w,
            FontWeight.bold,
          ),
          SizedBox(height: 1.5.h),
          textNormal(
            center: true,
            S.of(context).noNotificationsDescription,
            pref ? AppColors.inActiveColor : AppColors.black2TextColor,
            3.5.w,
            FontWeight.w400,
          ),
        ],
      ),
    );
  }
}