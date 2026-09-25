import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/core/Constant/app_images.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/features/home/presentation/widgets/show_bottom_sheet_pin_chat_widget.dart';
import 'package:live_chat/features/market/data/models/power_model.dart';
import 'package:live_chat/features/market/presentation/cubit/market_cubit.dart';
import 'package:live_chat/features/market/presentation/cubit/market_state.dart';
import 'package:live_chat/features/market/presentation/widgets/market_buy_charge_bottom_sheet.dart';
import 'package:live_chat/features/market/presentation/widgets/market_see_more_bottom_sheet.dart';
import 'package:live_chat/core/widgets/chat_card_widget.dart';
import 'package:live_chat/core/widgets/shimmer_skeletons.dart';
import 'package:live_chat/core/widgets/storetext.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  bool get pref => context.isDarkMode;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketCubit>().loadMarketData(isRefresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MarketCubit>().loadMorePowers();
    }
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
      body: BlocConsumer<MarketCubit, MarketState>(
        listener: (context, state) {
          if (state is MarketError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is MarketLoading;
          final numOfStars = state is MarketLoaded ? state.numOfStars : 0;
          final rawPowers = state is MarketLoaded ? state.storePowers : [];
          final hasMore = state is MarketLoaded ? state.hasMore : false;

          final List<PowerModel> storePowers = rawPowers.map((e) {
            if (e is PowerModel) return e;
            return PowerModel.fromJson(Map<String, dynamic>.from(e));
          }).toList();

          if (isLoading && storePowers.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _headerPage(
                    numOfStars: numOfStars,
                    onPress: () => showBottomSheetPinChatWidget(context: context),
                    onTapCharge: () => showBottomSheetMarketBuyChargeWidget(context: context),
                    isRtl: isRtl,
                  ),
                  SizedBox(height: 5.h),
                  Padding(padding: EdgeInsets.all(4.w), child: ShimmerSkeletons.marketGridSkeleton()),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<MarketCubit>().loadMarketData(isRefresh: true);
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _headerPage(
                    numOfStars: numOfStars,
                    onPress: () => showBottomSheetPinChatWidget(context: context),
                    onTapCharge: () => showBottomSheetMarketBuyChargeWidget(context: context),
                    isRtl: isRtl,
                  ),
                  SizedBox(height: 5.h),
                  _buildStore(isRtl),
                  _buildStoreInformation(storePowers, isRtl),
                  if (hasMore)
                    Padding(
                      padding: EdgeInsets.all(4.w),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (storePowers.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(4.w),
                      child: textNormal(
                        isRtl ? "لا يوجد المزيد" : "No more items",
                        pref ? AppColors.inActiveColor : AppColors.blackColor.withOpacity(0.6),
                        3.w,
                        FontWeight.w500,
                        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _headerPage({
    required int numOfStars,
    required VoidCallback onPress,
    required VoidCallback onTapCharge,
    required bool isRtl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: pref ? AppColors.darkcolor : AppColors.whiteColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      padding: EdgeInsets.only(
        left: isRtl ? 0 : 4.w,
        right: isRtl ? 4.w : 0,
        top: 6.h,
        bottom: 2.h,
      ),
      child: Column(
        children: [
          _buildAppBar(onPress: onPress, isRtl: isRtl),
          SizedBox(height: 1.h),
          Row(
            children: [
              CircleAvatar(
                radius: 5.w,
                backgroundColor:
                    pref ? AppColors.secondaryColor : AppColors.primaryColor,
                child: CircleAvatar(
                  backgroundImage:
                      const AssetImage("lib/Images/play_store_512.png"),
                  radius: 4.w,
                ),
              ),
              SizedBox(width: 2.w),
              textNormal(
                S.of(context).mayolivechat,
                pref ? AppColors.secondaryColor : AppColors.primaryColor,
                3.5.w,
                FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          chatCardWidget(
            needsAcceptance: false,
            power: null,
            imageUrl: true,
            numOfMessage: 0,
            onPressImg: () {},
            private: false,
            img: const AssetImage(AppImages.marketImg),
            ttitle: S.of(context).chargeStars,
            body: S.of(context).numberOfStarsCount(numOfStars),
            onPressJoin: onTapCharge,
            action: S.of(context).chargeStarsNow,
            ontap: onTapCharge,
            market: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar({required VoidCallback onPress, required bool isRtl}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _buildUserGreeting(isRtl),
        _buildActionButtons(onPress: onPress, isRtl: isRtl),
      ],
    );
  }

  Widget _buildUserGreeting(bool isRtl) {
    PowerModel? powerModel;
    final powerString = CacheHelper.getString(key: "powermodel");
    if (powerString != null && powerString != "null" && powerString.isNotEmpty) {
      try {
        final power = jsonDecode(powerString) as Map<String, dynamic>;
        powerModel = PowerModel.fromJson(power);
      } catch (_) {}
    }

    final imgUrl = CacheHelper.getString(key: AppConstants.userImageKey);
    final hasImg = imgUrl != null && imgUrl.trim().isNotEmpty && imgUrl != "null";
    final username = CacheHelper.getString(key: AppConstants.usernameKey) ?? "User";

    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        hasImg
            ? CircleAvatar(
                radius: 4.w,
                backgroundImage: CachedNetworkImageProvider(imgUrl),
              )
            : CircleAvatar(
                radius: 4.w,
                backgroundColor: Colors.grey,
              ),
        SizedBox(width: 2.w),
        Row(
          children: [
            powerModel == null
                ? textNormal(
                    username,
                    pref ? AppColors.whiteColor : AppColors.blackColor,
                    3.5.w,
                    FontWeight.w400,
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  )
                : PowerTextWidget(
                    powerModel: powerModel,
                    displyText: username,
                  )
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      {required VoidCallback onPress, required bool isRtl}) {
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        _buildPinChatButton(onPress: onPress, isRtl: isRtl),
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

  Widget _buildPinChatButton(
      {required VoidCallback onPress, required bool isRtl}) {
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
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
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

  Widget _buildStore(bool isRtl) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: textNormal(
                    S.of(context).name,
                    center: true,
                    pref ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: textNormal(
                    S.of(context).price,
                    pref ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: textNormal(
                    S.of(context).procedure,
                    pref ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: AppColors.inActiveColor,
          thickness: 0.2,
        ),
      ],
    );
  }

  Widget _buildStoreInformation(List<PowerModel> storePowers, bool isRtl) {
    final String? name = CacheHelper.getString(key: AppConstants.usernameKey);
    final String displayName =
        (name != null && name.isNotEmpty) ? name : "Guest";

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: storePowers.length,
      itemBuilder: (context, index) {
        final power = storePowers[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
          decoration: BoxDecoration(
            color: pref ? AppColors.darkcolor : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Expanded(
                flex: 7,
                child: Center(
                  child: _buildPowerTextWithFallback(
                    power: power,
                    displayName: displayName,
                    isRtl: isRtl,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: textNormal(
                    "${power.price} ${S.of(context).points}",
                    pref ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.2.w,
                    FontWeight.w500,
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: InkWell(
                    onTap: () {
                      power.isPurches == 1
                          ? null
                          : showBottomSheetMarketMoreWidget(
                              context: context,
                              isBuy: power.isPurches == 0 ? false : true,
                              name: CacheHelper.getString(key: AppConstants.nameKey) ?? "Guest",
                              price: "${power.price} ${S.of(context).points}",
                              afterParhes: SizedBox(
                                width: 30.w,
                                child: _buildPowerTextWithFallback(
                                  power: power,
                                  displayName: displayName,
                                  isRtl: isRtl,
                                ),
                              ),
                              powerId: power.id ?? 0,
                            );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 1.5.w),
                      decoration: BoxDecoration(
                        color: power.isPurches == 1
                            ? AppColors.inActiveColor.withOpacity(0.3)
                            : (pref
                                ? AppColors.secondaryColor
                                : AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: textNormal(
                        power.isPurches == 1
                            ? S.of(context).isBuy
                            : S.of(context).more,
                        power.isPurches == 1
                            ? AppColors.inActiveColor
                            : (pref
                                ? AppColors.blackColor
                                : AppColors.whiteColor),
                        3.2.w,
                        FontWeight.w500,
                        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPowerTextWithFallback({
    required PowerModel power,
    required String displayName,
    required bool isRtl,
  }) {
    try {
      return PowerTextWidget(
        powerModel: power,
        displyText: displayName,
      );
    } catch (_) {
      return textNormal(
        displayName,
        pref ? AppColors.whiteColor : AppColors.blackColor,
        3.5.w,
        FontWeight.w400,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      );
    }
  }
}
