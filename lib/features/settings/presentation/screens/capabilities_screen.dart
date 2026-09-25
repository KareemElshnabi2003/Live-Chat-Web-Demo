import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/core/widgets/shimmer_skeletons.dart';
import 'package:live_chat/core/widgets/storetext.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/market/data/models/power_model.dart';
import 'package:live_chat/features/market/presentation/cubit/market_cubit.dart';
import 'package:live_chat/features/market/presentation/cubit/market_state.dart';
import 'package:live_chat/features/market/presentation/widgets/more_settings.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class Capabilities extends StatefulWidget {
  const Capabilities({super.key});

  @override
  State<Capabilities> createState() => _CapabilitiesState();
}

class _CapabilitiesState extends State<Capabilities> {
  @override
  void initState() {
    super.initState();
    context.read<MarketCubit>().loadUserPowers();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
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
                      size: 5.5.w,
                      color:
                          pref! ? AppColors.whiteColor : AppColors.blackColor,
                    ),
                  ),
                  SizedBox(width: isRtl ? 1.5.w : 2.w),
                  textNormal(
                    S.of(context).capabilities,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    4.5.w,
                    FontWeight.w500,
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              _buildStore(context),
              SizedBox(height: 3.h),
              Expanded(
                child: BlocBuilder<MarketCubit, MarketState>(
                  builder: (context, state) {
                    if (state is MarketLoading) {
                      return ShimmerSkeletons.pageSkeleton();
                    }
                    if (state is MarketLoaded) {
                      final rawPowers = state.userPowers;
                      final List<PowerModel> powers = rawPowers.map((e) {
                        if (e is PowerModel) return e;
                        return PowerModel.fromJson(Map<String, dynamic>.from(e));
                      }).toList();

                      if (powers.isEmpty) {
                        return Center(
                          child: textNormal(
                            S.of(context).noPowersAvailable,
                            pref!
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                            4.w,
                            FontWeight.w500,
                          ),
                        );
                      }
                      return ListView(
                        children: [
                          _buildStoreInformation(context, powers),
                        ],
                      );
                    }
                    return Center(
                      child: textNormal(
                        S.of(context).noPowersAvailable,
                        pref!
                            ? AppColors.whiteColor
                            : AppColors.blackTextColor,
                        4.w,
                        FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStore(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 3.w, left: 3.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              SizedBox(
                width: 60.w,
                child: textNormal(
                  S.of(context).name,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.5.w,
                  FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 13.w,
                child: textNormal(
                  S.of(context).price,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.5.w,
                  FontWeight.w500,
                ),
              ),
              SizedBox(
                width: 13.w,
                child: textNormal(
                  S.of(context).procedure,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.5.w,
                  FontWeight.w500,
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

  Widget _buildStoreInformation(BuildContext context, List<PowerModel> powers) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final powerName =
        sharedPreferences!.getString("username") ?? "Unknown Power";

    return Column(
      children: powers.map((power) {
        bool isExpired(String expireDate) {
          try {
            DateTime expireDateTime = DateTime.parse(expireDate);
            DateTime now = DateTime.now();
            return now.isAfter(expireDateTime);
          } catch (_) {
            return false;
          }
        }

        String expireAt = power.expireAt ?? "";
        bool expire = expireAt.isNotEmpty && isExpired(expireAt);

        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              SizedBox(
                width: 60.w,
                child: PowerTextWidget(
                  powerModel: power,
                  displyText: powerName,
                ),
              ),
              SizedBox(
                width: 15.w,
                child: textNormal(
                  "${power.price ?? 0} ${S.of(context).points}",
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  3.w,
                  FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () async {
                  if (expire) {
                    Navigator.pop(context);
                    context.push(Routes.marketScreen);
                  } else {
                    showBottomSheetmore(
                      active: power.active ?? "Active",
                      powerId: (power.id ?? 0).toString(),
                      daysRemaining: _getRemainingTime(power.expireAt, context),
                      afterParhes: PowerTextWidget(
                        powerModel: power,
                        displyText: powerName,
                      ),
                      context: context,
                      name: powerName,
                      price: "${power.price ?? 0} ${S.of(context).points}",
                    );
                  }
                },
                child: SizedBox(
                  width: 13.w,
                  child: textNormal(
                    expire ? S.of(context).renewal : S.of(context).more,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    3.5.w,
                    FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getRemainingTime(String? expireAt, BuildContext context) {
    if (expireAt == null || expireAt.isEmpty) return "N/A";
    try {
      final expireDate = DateTime.parse(expireAt);
      final now = DateTime.now();
      final difference = expireDate.difference(now);
      if (difference.isNegative) return "Expired";
      return "${difference.inDays} ${S.of(context).days}";
    } catch (_) {
      return "N/A";
    }
  }
}
