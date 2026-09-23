import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Data/Model/power_model.dart';
import 'package:live_chat/View/Widget/PublicWidget/storetext.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_normal_widget.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

Widget chatCardWidget({
  required ImageProvider img,
  required PowerModel? power,
  required String ttitle,
  required String body,
  required VoidCallback onPressJoin,
  required VoidCallback onPressImg,
  bool isFriendsSection = false,
  bool isFriend = true,
  required bool private,
  required String action,
  required int numOfMessage,
  required VoidCallback ontap,
  required bool imageUrl,
  bool market = false,
  required bool needsAcceptance,
}) {
  return _HoverableChatCard(
    img: img,
    power: power,
    ttitle: ttitle,
    body: body,
    onPressJoin: onPressJoin,
    onPressImg: onPressImg,
    isFriendsSection: isFriendsSection,
    isFriend: isFriend,
    private: private,
    action: action,
    numOfMessage: numOfMessage,
    ontap: ontap,
    imageUrl: imageUrl,
    market: market,
    needsAcceptance: needsAcceptance,
  );
}

class _HoverableChatCard extends StatefulWidget {
  final ImageProvider img;
  final PowerModel? power;
  final String ttitle;
  final String body;
  final VoidCallback onPressJoin;
  final VoidCallback onPressImg;
  final bool isFriendsSection;
  final bool isFriend;
  final bool private;
  final String action;
  final int numOfMessage;
  final VoidCallback ontap;
  final bool imageUrl;
  final bool market;
  final bool needsAcceptance;

  const _HoverableChatCard({
    required this.img,
    required this.power,
    required this.ttitle,
    required this.body,
    required this.onPressJoin,
    required this.onPressImg,
    this.isFriendsSection = false,
    this.isFriend = true,
    required this.private,
    required this.action,
    required this.numOfMessage,
    required this.ontap,
    required this.imageUrl,
    this.market = false,
    required this.needsAcceptance,
  });

  @override
  State<_HoverableChatCard> createState() => _HoverableChatCardState();
}

class _HoverableChatCardState extends State<_HoverableChatCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
        padding: isHovered ? const EdgeInsets.all(8) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isHovered
              ? (pref! ? Colors.grey.shade900 : Colors.grey.shade200)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Expanded(
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: widget.onPressImg,
                        child: Container(
                          width: kIsWeb ? 75.0 : 19.w,
                          height: kIsWeb ? 75.0 : 19.w,
                          decoration: BoxDecoration(
                            color: pref! ? AppColors.darkcolor : AppColors.black2TextColor,
                            borderRadius: BorderRadius.circular(
                                widget.isFriendsSection ? 80 : 20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          alignment: Alignment.center,
                          child: widget.imageUrl
                              ? Image(
                                  image: widget.img,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return textNormal(
                                      widget.ttitle.isNotEmpty ? widget.ttitle[0] : "",
                                      AppColors.whiteColor,
                                      kIsWeb ? 36.0 : 7.w,
                                      FontWeight.bold,
                                    );
                                  },
                                )
                              : textNormal(
                                  widget.ttitle.isNotEmpty ? widget.ttitle[0] : "",
                                  AppColors.whiteColor,
                                  kIsWeb ? 36.0 : 7.w,
                                  FontWeight.bold,
                                ),
                        ),
                      ),
                      if (widget.private)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.lock,
                            color: AppColors.primaryColor,
                            size: kIsWeb ? 16.0 : 6.w,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 3.w),
                  Flexible(
                    child: InkWell(
                      onTap: widget.onPressJoin,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: widget.power != null &&
                                        widget.isFriendsSection
                                    ? PowerTextWidget(
                                        powerModel: widget.power!,
                                        displyText: widget.ttitle,
                                      )
                                    : textNormal(
                                        widget.ttitle,
                                        pref!
                                            ? AppColors.whiteColor
                                            : AppColors.blackTextColor,
                                        kIsWeb ? 16.0 : 3.5.w,
                                        FontWeight.w400,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                              if (widget.needsAcceptance) ...[
                                SizedBox(width: 1.5.w),
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: kIsWeb ? 14.0 : 4.w,
                                  color: AppColors.inActiveColor,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: textNormal(
                              widget.body,
                              widget.isFriendsSection
                                  ? widget.isFriend
                                      ? AppColors.primaryColor
                                      : AppColors.secondaryColor
                                  : pref!
                                      ? AppColors.inActiveColor
                                      : AppColors.inActiveColor,
                              kIsWeb ? 14.0 : 3.w,
                              FontWeight.w500,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          textClick(
                            widget.action,
                            false,
                            widget.onPressJoin,
                            !widget.isFriend
                                ? AppColors.redColor
                                : pref!
                                    ? AppColors.secondaryColor
                                    : AppColors.primaryColor,
                            kIsWeb ? 14.0 : 3.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: kIsWeb ? 24.0 : 4.w),
              height: kIsWeb ? 75.0 : 19.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: pref! ? AppColors.blackColor : AppColors.bgColor,
                borderRadius: BorderRadius.only(
                  topLeft: isRtl
                      ? const Radius.circular(0)
                      : const Radius.circular(20),
                  bottomLeft: isRtl
                      ? const Radius.circular(0)
                      : const Radius.circular(20),
                  bottomRight: isRtl
                      ? const Radius.circular(20)
                      : const Radius.circular(0),
                  topRight: isRtl
                      ? const Radius.circular(20)
                      : const Radius.circular(0),
                ),
              ),
              child: GestureDetector(
                onTap: widget.ontap,
                child: Icon(
                  widget.isFriend
                      ? (widget.market
                          ? LucideIcons.moveUp300
                          : (isRtl
                              ? LucideIcons.moveLeft300
                              : LucideIcons.moveRight300))
                      : Icons.close,
                  color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                  size: kIsWeb ? 28.0 : 5.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}