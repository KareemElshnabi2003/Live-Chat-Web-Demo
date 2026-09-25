// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/Constant/app_images.dart';
import 'package:live_chat/core/di/service_locator.dart';
import 'package:live_chat/core/widgets/text_click_widget.dart';
import 'package:live_chat/core/widgets/text_field_widget.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/chat/presentation/widgets/button.dart';
import 'package:live_chat/features/home/presentation/cubit/pin_chat_cubit.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

void showBottomSheetPinChatWidget({required BuildContext context}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;

  showModalBottomSheet(
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: kIsWeb ? 600 : double.infinity),
    backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
    context: context,
    builder: (ctx) => BlocProvider(
      create: (_) => sl<PinChatCubit>()..loadUserChats(),
      child: _BottomSheetContent(isRtl: isRtl),
    ),
  );
}

class _BottomSheetContent extends StatefulWidget {
  final bool isRtl;

  const _BottomSheetContent({required this.isRtl});

  @override
  State<_BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _titleAdsController = TextEditingController();
  final TextEditingController _descAdsController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _titleAdsController.dispose();
    _descAdsController.dispose();
    super.dispose();
  }

  double _calculateHeight(BuildContext context, PinChatState state) {
    final hasSelectedChat = state.selectedChatId.isNotEmpty;
    final hasTimeSlots = state.availableTimeSlots.isNotEmpty;
    final hasAds = state.addAds;

    if (hasSelectedChat) {
      if (hasAds) {
        return hasTimeSlots ? 110.h : 95.h;
      }
      return hasTimeSlots ? 95.h : 82.h;
    }
    return 65.h;
  }

  int _calculateStars(PinChatState state) {
    int stars = state.selectedTimeSlots.length * 10;
    if (state.addAds) {
      stars += 5;
    }
    return stars;
  }

  Future<void> _pickDate(BuildContext context) async {
    final cubit = context.read<PinChatCubit>();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      final formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _dateController.text = formatted;
      cubit.selectDate(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PinChatCubit, PinChatState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.redColor),
          );
        }
        if (state.successMessage != null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!), backgroundColor: Colors.green),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<PinChatCubit>();

        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _calculateHeight(context, state),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 70,
                    color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                  ),
                  Container(
                    padding: EdgeInsets.all(4.w),
                    width: 100.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header Close
                        Row(
                          mainAxisAlignment: widget.isRtl ? MainAxisAlignment.end : MainAxisAlignment.start,
                          textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            textClick(
                              S.of(context).close,
                              true,
                              () => Navigator.pop(context),
                              pref! ? AppColors.whiteColor : AppColors.blackColor,
                              3.5.w,
                            ),
                          ],
                        ),

                        // Pin Images
                        if (MediaQuery.of(context).viewInsets.bottom == 0)
                          SizedBox(
                            width: 70.w,
                            height: 65.w,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  right: 10.w,
                                  child: Container(
                                    width: 35.w,
                                    height: 65.w,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(image: AssetImage(AppImages.pin1Img)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 18.w,
                                  child: Container(
                                    width: 35.w,
                                    height: 65.w,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(image: AssetImage(AppImages.pin2Img)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 26.w,
                                  child: Container(
                                    width: 35.w,
                                    height: 65.w,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(image: AssetImage(AppImages.pin3Img)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Title
                        textNormal(
                          S.of(context).pinYourChat,
                          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                          4.w,
                          FontWeight.w600,
                        ),
                        const SizedBox(height: 10),

                        // Price Info
                        if (state.selectedChatId.isNotEmpty)
                          Column(
                            children: [
                              SizedBox(height: 2.h),
                              Container(
                                padding: EdgeInsets.all(1.5.h),
                                width: 90.w,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  border: Border.all(color: AppColors.inActiveColor),
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    textNormal(
                                      "${S.of(context).price} :",
                                      AppColors.inActiveColor,
                                      3.w,
                                      FontWeight.w500,
                                    ),
                                    textNormal(
                                      " ${_calculateStars(state)} ${S.of(context).star}",
                                      AppColors.blackColor,
                                      3.w,
                                      FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 1.h),
                            ],
                          ),

                        // Chat Dropdown
                        state.isLoading && state.userChats.isEmpty
                            ? Container(
                                height: 6.h,
                                width: 92.w,
                                decoration: BoxDecoration(
                                  color: pref! ? AppColors.darkcolor : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : state.userChats.isEmpty
                                ? Container(
                                    height: 6.h,
                                    width: 92.w,
                                    decoration: BoxDecoration(
                                      color: pref! ? AppColors.darkcolor : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: textNormal(
                                        S.of(context).noChat,
                                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                                        3.5.w,
                                        FontWeight.w400,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 92.w,
                                    height: 6.h,
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4),
                                    decoration: ShapeDecoration(
                                      color: pref! ? AppColors.darkcolor : Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        dropdownColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
                                        hint: textNormal(S.of(context).chooseChatToPin, AppColors.inActiveColor, 3.5.w, FontWeight.w400),
                                        value: state.selectedChatId.isEmpty ? null : state.selectedChatId,
                                        isExpanded: true,
                                        items: state.userChats.map((chat) {
                                          return DropdownMenuItem<String>(
                                            value: chat.id.toString(),
                                            child: textNormal(
                                              chat.name ?? 'Chat ${chat.id}',
                                              pref! ? AppColors.whiteColor : AppColors.inActiveColor,
                                              3.5.w,
                                              FontWeight.w400,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) cubit.selectChat(val);
                                        },
                                        icon: Icon(IconsaxPlusLinear.arrow_down, size: 4.w, color: AppColors.inActiveColor),
                                      ),
                                    ),
                                  ),
                        const SizedBox(height: 10),

                        // Date Picker
                        if (state.selectedChatId.isNotEmpty) ...[
                          GestureDetector(
                            onTap: () => _pickDate(context),
                            child: Container(
                              height: 6.h,
                              width: 92.w,
                              decoration: ShapeDecoration(
                                color: pref! ? AppColors.darkcolor : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _dateController,
                                  textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                                  style: TextStyle(
                                    color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                                    fontSize: 3.5.w,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: S.of(context).date,
                                    hintStyle: TextStyle(color: AppColors.inActiveColor, fontSize: 3.5.w),
                                    suffixIcon: Icon(IconsaxPlusLinear.calendar_1, color: AppColors.primaryColor, size: 5.w),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                        ],

                        // Time slots
                        if (state.selectedChatId.isNotEmpty && state.availableTimeSlots.isNotEmpty) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: textNormal(
                                  S.of(context).availableTimes,
                                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                                  3.5.w,
                                  FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Container(
                                width: 92.w,
                                constraints: BoxConstraints(maxHeight: 20.h),
                                decoration: BoxDecoration(
                                  color: pref! ? AppColors.darkcolor : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.inActiveColor.withOpacity(0.3)),
                                ),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: Wrap(
                                      spacing: 2.w,
                                      runSpacing: 1.h,
                                      children: state.availableTimeSlots.map((timeSlot) {
                                        final isAvailable = timeSlot['available'] == true;
                                        final time = timeSlot['time']?.toString() ?? '';
                                        final isSelected = state.selectedTimeSlots.contains(time);

                                        return GestureDetector(
                                          onTap: isAvailable ? () => cubit.toggleTimeSlot(time) : null,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primaryColor
                                                  : isAvailable
                                                      ? (pref! ? AppColors.blackColor : AppColors.whiteColor)
                                                      : AppColors.inActiveColor.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primaryColor
                                                    : isAvailable
                                                        ? AppColors.inActiveColor
                                                        : AppColors.inActiveColor.withOpacity(0.5),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isAvailable
                                                      ? (isSelected ? IconsaxPlusBold.tick_square : IconsaxPlusLinear.square)
                                                      : IconsaxPlusLinear.close_square,
                                                  size: 3.5.w,
                                                  color: isSelected
                                                      ? AppColors.whiteColor
                                                      : isAvailable
                                                          ? (pref! ? AppColors.whiteColor : AppColors.blackColor)
                                                          : AppColors.inActiveColor,
                                                ),
                                                SizedBox(width: 1.w),
                                                textNormal(
                                                  time,
                                                  isSelected
                                                      ? AppColors.whiteColor
                                                      : isAvailable
                                                          ? (pref! ? AppColors.whiteColor : AppColors.blackColor)
                                                          : AppColors.inActiveColor,
                                                  3.w,
                                                  FontWeight.w400,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),

                        // Ads option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            textNormal(
                              S.of(context).wantToPinAdd,
                              pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                              3.5.w,
                              FontWeight.w600,
                            ),
                            Row(
                              textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                              children: [
                                Row(
                                  children: [
                                    textNormal(
                                      S.of(context).no,
                                      !state.addAds ? (pref! ? AppColors.whiteColor : AppColors.blackTextColor) : AppColors.inActiveColor,
                                      3.5.w,
                                      FontWeight.w400,
                                    ),
                                    Radio<bool>(
                                      value: false,
                                      groupValue: state.addAds,
                                      onChanged: (val) => cubit.setAddAds(val ?? false),
                                      activeColor: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    textNormal(
                                      S.of(context).yes,
                                      state.addAds ? (pref! ? AppColors.whiteColor : AppColors.blackTextColor) : AppColors.inActiveColor,
                                      3.5.w,
                                      FontWeight.w400,
                                    ),
                                    Radio<bool>(
                                      value: true,
                                      groupValue: state.addAds,
                                      onChanged: (val) => cubit.setAddAds(val ?? true),
                                      activeColor: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Ad Fields
                        if (state.addAds) ...[
                          SizedBox(
                            height: 6.h,
                            child: textFieldWidget(
                              _titleAdsController,
                              S.of(context).title,
                              false,
                              false,
                              null,
                              TextInputType.text,
                              null,
                              null,
                              textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          SizedBox(
                            height: 6.h,
                            child: textFieldWidget(
                              _descAdsController,
                              S.of(context).descriptionLink,
                              false,
                              false,
                              null,
                              TextInputType.text,
                              null,
                              null,
                              textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
                              lines: false,
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          GestureDetector(
                            onTap: () => cubit.pickAdImage(),
                            child: Container(
                              height: state.adImage != null ? 20.h : 6.h,
                              width: 92.w,
                              decoration: BoxDecoration(
                                color: pref! ? AppColors.darkcolor : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.inActiveColor.withOpacity(0.5)),
                              ),
                              child: state.adImage != null
                                  ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: FutureBuilder<Uint8List>(
                                            future: state.adImage!.readAsBytes(),
                                            builder: (ctx, snapshot) {
                                              if (snapshot.hasData) {
                                                return Image.memory(
                                                  snapshot.data!,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                );
                                              }
                                              return const Center(child: CircularProgressIndicator());
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () => cubit.removeAdImage(),
                                            child: Container(
                                              padding: EdgeInsets.all(1.w),
                                              decoration: const BoxDecoration(
                                                color: AppColors.redColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.close, color: AppColors.whiteColor, size: 4.w),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(IconsaxPlusLinear.gallery_add, color: AppColors.inActiveColor, size: 5.w),
                                        SizedBox(width: 2.w),
                                        textNormal("Add Image", AppColors.inActiveColor, 3.5.w, FontWeight.w400),
                                      ],
                                    ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],

                        // Submit Button
                        Button(
                          text: state.isSubmitting ? S.of(context).loading : S.of(context).next,
                          ontap: state.isSubmitting
                              ? null
                              : () async {
                                  if (state.selectedChatId.isEmpty || state.selectedDate.isEmpty || state.selectedTimeSlots.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(S.of(context).please_fill_all_fields),
                                        backgroundColor: AppColors.redColor,
                                      ),
                                    );
                                    return;
                                  }
                                  if (state.addAds && state.adImage == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Please add an image for the ad"),
                                        backgroundColor: AppColors.redColor,
                                      ),
                                    );
                                    return;
                                  }
                                  await cubit.pinChat();
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
      },
    );
  }
}
