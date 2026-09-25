// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/core/theme/app_colors.dart';
import 'package:live_chat/core/theme/theme_cubit.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_state.dart';
import 'package:live_chat/features/home/data/models/radio_model.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

void showBottomSheetChangeMusicWidget({required BuildContext context}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kIsWeb ? 600 : double.infinity),
        child: _BottomSheetContent(context: context, isRtl: isRtl),
      ),
    ),
  );
}

class _BottomSheetContent extends StatelessWidget {
  final BuildContext context;
  final bool isRtl;

  const _BottomSheetContent({required this.context, required this.isRtl});

  @override
  Widget build(BuildContext buildCtx) {
    final isDarkMode = buildCtx.isDarkMode;
    final bool pref = isDarkMode;
    final bgColor = isDarkMode ? AppColors.blackColor : const Color(0xFFEBEBEB);

    return BlocBuilder<ChatCubit, ChatState>(
      bloc: context.read<ChatCubit>(),
      builder: (ctx, state) {
        final cubit = context.read<ChatCubit>();
        List<RadioModel> radios = [];
        bool isRadioPlaying = false;
        String? currentRadioUrl;

        if (state is ChatLoaded) {
          radios = state.radios;
          isRadioPlaying = state.isRadioPlaying;
          currentRadioUrl = state.currentRadioUrl;
        }

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(buildCtx).viewInsets.bottom + 2.h,
            right: 5.w,
            left: 5.w,
            top: 1.5.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Text(
                    S.of(buildCtx).chooseWhatYouWantToPlay,
                    style: TextStyle(
                      color: pref ? Colors.white : Colors.black87,
                      fontSize: 4.5.w,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(buildCtx),
                    child: Container(
                      padding: EdgeInsets.all(1.8.w),
                      decoration: BoxDecoration(
                        color: pref ? Colors.grey.shade800 : const Color(0xFFD6D6D6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.close, color: pref ? Colors.white : Colors.black87, size: 4.5.w),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              Text(
                S.of(buildCtx).radioStations,
                style: TextStyle(
                  color: pref ? Colors.white : Colors.black87,
                  fontSize: 3.8.w,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: isRtl ? TextAlign.right : TextAlign.left,
              ),
              SizedBox(height: 2.h),

              SizedBox(
                height: kIsWeb ? 200.0 : 18.h,
                child: radios.isEmpty
                    ? Center(
                        child: Text(
                          S.of(buildCtx).failedToLoadRadioStations,
                          style: TextStyle(color: pref ? Colors.white70 : Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: radios.length,
                        separatorBuilder: (_, __) => SizedBox(width: 3.w),
                        itemBuilder: (c, index) {
                          final radio = radios[index];
                          final radioName = radio.name;
                          final radioUrl = radio.radioUrl;
                          final isPlaying = isRadioPlaying && currentRadioUrl == radioUrl;

                          return GestureDetector(
                            onTap: () {
                              if (isPlaying) {
                                cubit.stopRadio();
                              } else {
                                cubit.playRadio(radioUrl);
                              }
                            },
                            child: Container(
                              width: kIsWeb ? 130.0 : 28.w,
                              decoration: BoxDecoration(
                                color: isDarkMode ? AppColors.darkcolor : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: isDarkMode ? null : Border.all(color: Colors.grey.shade300, width: 0.8),
                                boxShadow: [
                                  if (!isDarkMode)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: kIsWeb ? 60.0 : 14.w,
                                    height: kIsWeb ? 60.0 : 14.w,
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.grey.shade800 : const Color(0xFFEEEEEE),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                      size: kIsWeb ? 30.0 : 8.w,
                                    ),
                                  ),
                                  SizedBox(height: kIsWeb ? 10.0 : 2.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                                    child: Text(
                                      radioName,
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                        fontSize: 3.3.w,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }
}