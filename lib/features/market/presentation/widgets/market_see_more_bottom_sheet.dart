// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/features/market/presentation/cubit/market_cubit.dart';
import 'package:live_chat/features/market/presentation/cubit/market_state.dart';
import 'package:live_chat/features/market/presentation/widgets/market_buy_charge_bottom_sheet.dart';
import 'package:live_chat/core/widgets/message_success_payment.dart';
import 'package:live_chat/core/widgets/text_click_widget.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/chat/presentation/widgets/button.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

void showBottomSheetMarketMoreWidget({
  required BuildContext context,
  required String name,
  required String price,
  required Widget afterParhes,
  required bool isBuy,
  required int powerId,
}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  showModalBottomSheet(
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: kIsWeb ? 600 : double.infinity),
    backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
    context: context,
    builder: (ctx) => _MarketSeeMoreSheet(
      parentContext: context,
      name: name,
      price: price,
      afterParhes: afterParhes,
      isBuy: isBuy,
      powerId: powerId,
      isRtl: isRtl,
    ),
  );
}

class _MarketSeeMoreSheet extends StatefulWidget {
  final BuildContext parentContext;
  final String name;
  final String price;
  final Widget afterParhes;
  final bool isBuy;
  final int powerId;
  final bool isRtl;

  const _MarketSeeMoreSheet({
    required this.parentContext,
    required this.name,
    required this.price,
    required this.afterParhes,
    required this.isBuy,
    required this.powerId,
    required this.isRtl,
  });

  @override
  State<_MarketSeeMoreSheet> createState() => _MarketSeeMoreSheetState();
}

class _MarketSeeMoreSheetState extends State<_MarketSeeMoreSheet> {
  String _sheetMarket = "firstPage";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _sheetMarket == "secondPage" ? 20.h : 40.h,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              right: 4.w,
              left: 4.w,
              top: 4.w,
            ),
            width: 100.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 4,
                  width: 70,
                  color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                ),
                Row(
                  mainAxisAlignment: widget.isRtl ? MainAxisAlignment.end : MainAxisAlignment.start,
                  textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    textClick(
                      _sheetMarket != "firstPage" ? S.of(context).back : S.of(context).close,
                      true,
                      () {
                        if (_sheetMarket == "secondPage") {
                          setState(() {
                            _sheetMarket = "firstPage";
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      pref! ? AppColors.whiteColor : AppColors.blackColor,
                      3.5.w,
                    ),
                  ],
                ),
                if (_sheetMarket == "secondPage")
                  textNormal(
                    S.of(context).confirmPurchase,
                    pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                    4.w,
                    FontWeight.w600,
                  ),
                if (_sheetMarket == "secondPage") SizedBox(height: 2.h),
                if (_sheetMarket == "firstPage")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      textNormal(
                        S.of(context).name,
                        AppColors.inActiveColor,
                        3.5.w,
                        FontWeight.w500,
                      ),
                      const SizedBox(width: 5),
                      textNormal(
                        widget.name,
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                        3.5.w,
                        FontWeight.w500,
                      ),
                    ],
                  ),
                if (_sheetMarket == "firstPage") SizedBox(height: 2.h),
                if (_sheetMarket == "firstPage")
                  Row(
                    textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Icon(
                        LucideIcons.circlePoundSterling300,
                        color: pref! ? AppColors.secondaryColor : AppColors.blackColor,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      textNormal(
                        "${S.of(context).price} : ${widget.price}",
                        pref! ? AppColors.inActiveColor : AppColors.blackTextColor,
                        3.5.w,
                        FontWeight.w400,
                      ),
                    ],
                  ),
                if (_sheetMarket == "firstPage") SizedBox(height: 2.h),
                if (_sheetMarket == "firstPage")
                  Row(
                    textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Icon(
                        LucideIcons.clock,
                        color: pref! ? AppColors.secondaryColor : AppColors.blackColor,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      textNormal(
                        "${S.of(context).reminingTime} : 30 ${S.of(context).days}",
                        pref! ? AppColors.inActiveColor : AppColors.blackTextColor,
                        3.5.w,
                        FontWeight.w400,
                      ),
                    ],
                  ),
                if (_sheetMarket == "firstPage") SizedBox(height: 2.h),
                if (_sheetMarket == "firstPage")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Icon(
                        widget.isRtl ? LucideIcons.moveLeft300 : LucideIcons.moveRight300,
                        color: pref! ? AppColors.secondaryColor : AppColors.blackColor,
                        size: 5.w,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 50.w,
                        child: widget.afterParhes,
                      ),
                    ],
                  ),
                if (_sheetMarket == "firstPage") SizedBox(height: 3.h),
                if (_sheetMarket == "firstPage")
                  Button(
                    ontap: () {
                      final double requiredStars = double.tryParse(widget.price.split(' ').first) ?? 0.0;
                      final int requiredStarsInt = requiredStars.toInt();
                      final marketState = widget.parentContext.read<MarketCubit>().state;
                      int currentStars = 0;
                      if (marketState is MarketLoaded) {
                        currentStars = marketState.numOfStars;
                      }
                      if (currentStars >= requiredStarsInt) {
                        setState(() {
                          _sheetMarket = "secondPage";
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${S.of(context).insufficientStars}. ${S.of(context).pleasePurchaseMoreStars}",
                            ),
                            backgroundColor: AppColors.redColor,
                            action: SnackBarAction(
                              label: S.of(context).purchase,
                              textColor: AppColors.whiteColor,
                              onPressed: () {
                                showBottomSheetMarketBuyChargeWidget(context: context);
                              },
                            ),
                          ),
                        );
                      }
                    },
                    text: S.of(context).purchase,
                  ),
                if (_sheetMarket == "secondPage")
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Button(
                            text: widget.isBuy ? S.of(context).isBuy : S.of(context).confirm,
                            ontap: () async {
                              if (widget.isBuy) {
                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  _isLoading = true;
                                });
                                final success = await widget.parentContext.read<MarketCubit>().buyPower(
                                      powerId: widget.powerId,
                                    );
                                setState(() {
                                  _isLoading = false;
                                });
                                if (success) {
                                  Navigator.pop(context);
                                  messageSuccessPayment(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(S.of(context).purchaseFailed),
                                      backgroundColor: AppColors.redColor,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
