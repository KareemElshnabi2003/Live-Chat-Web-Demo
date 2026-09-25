// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/widgets/loading.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:live_chat/features/chat/presentation/widgets/button.dart';
import 'package:live_chat/main.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class CreateChat extends StatefulWidget {
  const CreateChat({super.key});

  @override
  State<CreateChat> createState() => _CreateChatState();
}

class _CreateChatState extends State<CreateChat> {
  final TextEditingController _nameController = TextEditingController();
  XFile? _chatImageFile;
  Uint8List? _chatImageBytes;

  XFile? _customThemeFile;
  Uint8List? _customThemeBytes;

  String _selectedPrivacy = "";
  String _selectedCanChat = "";
  String? _selectedThemeId;

  List<dynamic> _themes = [];
  bool _isLoadingThemes = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadThemes() async {
    setState(() => _isLoadingThemes = true);
    final themes = await context.read<ChatCubit>().getThemes();
    if (mounted) {
      setState(() {
        _themes = themes;
        _isLoadingThemes = false;
        if (_themes.isNotEmpty && _selectedThemeId == null) {
          _selectedThemeId = _themes.first['id']?.toString();
        }
      });
    }
  }

  Future<void> _pickChatImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _chatImageFile = image;
          _chatImageBytes = bytes;
        });
      }
    } catch (e) {
      log("Error picking chat image: $e");
    }
  }

  Future<void> _pickCustomTheme() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _customThemeFile = image;
          _customThemeBytes = bytes;
          _selectedThemeId = null; // deselect server theme when custom is picked
        });
      }
    } catch (e) {
      log("Error picking custom theme: $e");
    }
  }

  Future<void> _createChat() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).fillAllFields), backgroundColor: AppColors.redColor),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      MultipartFile? imgChat;
      if (_chatImageBytes != null && _chatImageFile != null) {
        imgChat = MultipartFile.fromBytes(
          _chatImageBytes!,
          filename: _chatImageFile!.name,
        );
      }

      MultipartFile? bgChat;
      if (_customThemeBytes != null && _customThemeFile != null) {
        bgChat = MultipartFile.fromBytes(
          _customThemeBytes!,
          filename: _customThemeFile!.name,
        );
      }

      final data = {
        'name': _nameController.text.trim(),
        'status': _selectedPrivacy == S.of(context).public ? 1 : 0,
        'accept': _selectedCanChat == S.of(context).yes ? 1 : 0,
        if (_selectedThemeId != null) 'theme_id': int.tryParse(_selectedThemeId!) ?? _selectedThemeId,
      };

      final success = await context.read<ChatCubit>().createGeneralChat(
        data: data,
        imgChat: imgChat,
        bgChat: bgChat,
      );

      setState(() => _isSubmitting = false);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).createNewChat), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).somethingWentWrong), backgroundColor: AppColors.redColor),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.redColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final privacyOptions = [S.of(context).public, S.of(context).private];
    final canChatOptions = [S.of(context).yes, S.of(context).no];

    if (_selectedPrivacy.isEmpty) _selectedPrivacy = privacyOptions.first;
    if (_selectedCanChat.isEmpty) _selectedCanChat = canChatOptions.first;

    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: ListView(
          children: [
            _buildHeader(isRtl),
            SizedBox(height: 4.h),
            _buildImagePicker(),
            SizedBox(height: 2.h),
            _buildNameField(),
            SizedBox(height: 2.h),
            _buildDropdown(
              hint: S.of(context).selectPrivateOrPublic,
              selectedValue: _selectedPrivacy,
              options: privacyOptions,
              onChanged: (val) {
                if (val != null) setState(() => _selectedPrivacy = val);
              },
            ),
            SizedBox(height: 2.h),
            _buildDropdown(
              hint: S.of(context).selectCan,
              selectedValue: _selectedCanChat,
              options: canChatOptions,
              onChanged: (val) {
                if (val != null) setState(() => _selectedCanChat = val);
              },
            ),
            SizedBox(height: 2.h),
            _buildFormatImageSelector(isRtl),
            SizedBox(height: 4.h),
            _isSubmitting
                ? loading(6.h)
                : Button(
                    ontap: _createChat,
                    text: S.of(context).create,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRtl) {
    return Row(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            isRtl ? IconsaxPlusLinear.arrow_right_3 : IconsaxPlusLinear.arrow_left_1,
            size: 5.5.w,
            color: pref! ? AppColors.whiteColor : AppColors.blackColor,
          ),
        ),
        SizedBox(width: 2.w),
        textNormal(
          S.of(context).createNewChat,
          pref! ? AppColors.whiteColor : AppColors.blackTextColor,
          4.5.w,
          FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickChatImage,
      child: Container(
        height: 12.h,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 0.5, color: AppColors.inActiveColor),
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: pref!
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x192D4F46),
                    blurRadius: 50,
                    offset: Offset(10, 10),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: _chatImageBytes == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.cloudUpload,
                      size: 6.w,
                      color: pref! ? AppColors.whiteColor : AppColors.blackColor,
                    ),
                    SizedBox(height: 1.h),
                    textNormal(
                      S.of(context).roomImage,
                      pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                      3.5.w,
                      FontWeight.w500,
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    _chatImageBytes!,
                    height: 12.h,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Container(
      height: 6.h,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: TextField(
        controller: _nameController,
        style: TextStyle(
          color: pref! ? AppColors.whiteColor : AppColors.inActiveColor,
          fontSize: 3.5.w,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: S.of(context).name,
          hintStyle: TextStyle(
            color: AppColors.inActiveColor,
            fontSize: 3.5.w,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: isRtl ? 12 : 16, vertical: 4),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: DropdownButtonHideUnderline(
        child: Theme(
          data: ThemeData(
            canvasColor: pref! ? AppColors.darkcolor : AppColors.whiteColor,
          ),
          child: DropdownButton<String>(
            hint: textNormal(hint, AppColors.inActiveColor, 3.5.w, FontWeight.w400),
            value: selectedValue.isEmpty ? null : selectedValue,
            isExpanded: true,
            items: options
                .map((value) => DropdownMenuItem<String>(
                      value: value,
                      child: textNormal(
                        value,
                        pref! ? AppColors.whiteColor : AppColors.inActiveColor,
                        3.5.w,
                        FontWeight.w400,
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            icon: Icon(
              IconsaxPlusLinear.arrow_down,
              size: 4.w,
              color: AppColors.inActiveColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormatImageSelector(bool isRtl) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isRtl ? 2.w : 4.w, vertical: 2.h),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: isRtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textNormal(
                S.of(context).chooseChatFormat,
                AppColors.inActiveColor,
                3.5.w,
                FontWeight.w500,
              ),
              GestureDetector(
                onTap: _pickCustomTheme,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: pref! ? AppColors.secondaryColor : AppColors.buttoncolor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 3.5.w, color: pref! ? AppColors.blackColor : AppColors.whiteColor),
                      SizedBox(width: 1.w),
                      textNormal(
                        S.of(context).addCustom,
                        pref! ? AppColors.blackColor : AppColors.whiteColor,
                        2.8.w,
                        FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _isLoadingThemes
              ? loading(6.h)
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      if (_customThemeBytes != null)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedThemeId = null);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedThemeId == null ? AppColors.primaryColor : AppColors.inActiveColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _customThemeBytes!,
                                  width: 20.w,
                                  height: 10.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ..._themes.map((theme) {
                        final themeIdStr = theme['id']?.toString() ?? '';
                        final isSelected = _selectedThemeId == themeIdStr;
                        final themeUrl = theme['theme']?.toString() ?? '';

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedThemeId = themeIdStr;
                                _customThemeBytes = null;
                                _customThemeFile = null;
                              });
                            },
                            child: Container(
                              padding: isSelected ? const EdgeInsets.all(2) : null,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryColor : AppColors.inActiveColor,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: themeUrl,
                                  width: 20.w,
                                  height: 10.h,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: 20.w,
                                    height: 10.h,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
