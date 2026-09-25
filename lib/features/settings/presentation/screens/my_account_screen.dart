import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/core/Constant/app_color.dart';
import 'package:live_chat/core/Constant/app_images.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/core/widgets/text_normal_widget.dart';
import 'package:live_chat/features/chat/presentation/widgets/button.dart';
import 'package:live_chat/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:live_chat/features/settings/presentation/cubit/settings_state.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/generated/l10n.dart';

class MyAccountView extends StatefulWidget {
  const MyAccountView({super.key});

  @override
  State<MyAccountView> createState() => _MyAccountViewState();
}

class _MyAccountViewState extends State<MyAccountView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String selectedGender = "Male";
  Uint8List? _imageBytes;
  String? _imageName;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController.text = CacheHelper.getString(key: "name") ?? "";
    usernameController.text = CacheHelper.getString(key: "username") ?? "";
    emailController.text = CacheHelper.getString(key: "email") ?? "";
    phoneController.text = CacheHelper.getString(key: "phone") ?? "";
    ageController.text = CacheHelper.getString(key: "age") ?? "";
    bioController.text = CacheHelper.getString(key: "bio") ?? "";
    countryController.text = CacheHelper.getString(key: "country") ?? "";
    selectedGender = CacheHelper.getString(key: "gender") ?? "Male";

    context.read<SettingsCubit>().getProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    emailController.dispose();
    countryController.dispose();
    ageController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
      });
    }
  }

  void _saveUserData() {
    context.read<SettingsCubit>().updateProfile(
          name: nameController.text.trim(),
          bio: bioController.text.trim(),
          username: usernameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          age: ageController.text.trim(),
          gender: selectedGender,
          imageBytes: _imageBytes,
          imageName: _imageName,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          final data = state.userProfile;
          if (data['name'] != null) nameController.text = data['name'].toString();
          if (data['username'] != null) usernameController.text = data['username'].toString();
          if (data['email'] != null) emailController.text = data['email'].toString();
          if (data['phone'] != null) phoneController.text = data['phone'].toString();
          if (data['age'] != null) ageController.text = data['age'].toString();
          if (data['bio'] != null) bioController.text = data['bio'].toString();
          if (data['gender'] != null) {
            setState(() {
              selectedGender = data['gender'].toString();
            });
          }
        } else if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم حفظ التعديلات بنجاح"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SettingsLoading;

        return Scaffold(
          backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 4.w,
                    top: 2.h,
                    right: 4.w),
                child: Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        textDirection:
                            isRtl ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(isRtl ? 1.5.w : 2.w),
                              child: Icon(
                                isRtl
                                    ? IconsaxPlusLinear.arrow_right_3
                                    : IconsaxPlusLinear.arrow_left_1,
                                size: 5.5.w,
                                color: pref!
                                    ? AppColors.whiteColor
                                    : AppColors.blackColor,
                              ),
                            ),
                          ),
                          SizedBox(width: isRtl ? 1.5.w : 2.w),
                          textNormal(
                            S.of(context).myAccount,
                            pref!
                                ? AppColors.whiteColor
                                : AppColors.blackTextColor,
                            4.5.w,
                            FontWeight.w600,
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      textNormal(
                        S.of(context).editInformation,
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                        3.5.w,
                        FontWeight.w500,
                      ),
                      SizedBox(height: 3.h),
                      _buildProfileImage(isRtl),
                      SizedBox(height: 3.h),
                      _buildEditableField(
                        controller: nameController,
                        hintText: S.of(context).enterFullName,
                        icon: IconsaxPlusLinear.profile,
                        isRequired: true,
                        isRtl: isRtl,
                      ),
                      _buildEditableField(
                        controller: usernameController,
                        hintText: S.of(context).enterUsername,
                        icon: IconsaxPlusLinear.profile_tick,
                        isRtl: isRtl,
                      ),
                      _buildEditableField(
                        controller: bioController,
                        hintText: "Bio",
                        icon: IconsaxPlusLinear.profile_tick,
                        isRtl: isRtl,
                      ),
                      _buildEditableField(
                        controller: emailController,
                        hintText: S.of(context).enterEmail,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        isRtl: isRtl,
                      ),
                      _buildEditableField(
                        controller: countryController,
                        hintText: S.of(context).enterCountry,
                        icon: IconsaxPlusLinear.location,
                        isRtl: isRtl,
                      ),
                      _buildEditableField(
                        controller: ageController,
                        hintText: S.of(context).enterAge,
                        icon: IconsaxPlusLinear.calendar,
                        keyboardType: TextInputType.number,
                        isRtl: isRtl,
                      ),
                      _buildGenderSelector(isRtl),
                      _buildEditableField(
                        controller: phoneController,
                        hintText: S.of(context).enterMobileNumber,
                        icon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        isRtl: isRtl,
                      ),
                      SizedBox(height: 2.h),
                      Button(
                        ontap: _saveUserData,
                        text: S.of(context).saveChanges,
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: textNormal(
                      S.of(context).loading,
                      AppColors.whiteColor,
                      4.w,
                      FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(bool isRtl) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 19.h,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(
            side: pref!
                ? const BorderSide(color: AppColors.inActiveColor)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Stack(
          children: [
            _imageBytes != null
                ? Positioned.fill(
                    child: Image.memory(
                      _imageBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Positioned.fill(
                    child: Image(
                      image: AssetImage(AppImages.profileimage),
                      fit: BoxFit.contain,
                    ),
                  ),
            Positioned(
              left: isRtl ? null : 3.w,
              right: isRtl ? 3.w : null,
              bottom: 1.5.h,
              child: Container(
                width: 4.5.h,
                height: 4.h,
                decoration: ShapeDecoration(
                  color: pref! ? AppColors.blackColor : const Color(0xFFF4F2E9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadows: [
                    BoxShadow(
                      color: pref!
                          ? AppColors.whiteColor
                          : Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    IconsaxPlusLinear.camera,
                    size: 5.w,
                    color:
                        pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    required bool isRtl,
  }) {
    return Container(
      width: double.infinity,
      height: 6.h,
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: ShapeDecoration(
        color: pref! ? AppColors.darkcolor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding:
            EdgeInsets.only(left: isRtl ? 2.w : 4.w, right: isRtl ? 4.w : 2.w),
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: TextStyle(
                  fontSize: 4.w,
                  fontWeight: FontWeight.w400,
                  color:
                      pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inActiveColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Icon(
              icon,
              size: 5.5.w,
              color: AppColors.inActiveColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector(bool isRtl) {
    return GestureDetector(
      onTap: _showGenderBottomSheet,
      child: Container(
        width: double.infinity,
        height: 6.h,
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: ShapeDecoration(
          color: pref! ? AppColors.darkcolor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding:
              EdgeInsets.only(left: isRtl ? 2.w : 4.w, right: isRtl ? 4.w : 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              textNormal(
                selectedGender == "Male"
                    ? S.of(context).male
                    : S.of(context).female,
                pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                4.w,
                FontWeight.w400,
              ),
              Icon(
                IconsaxPlusLinear.arrow_down_1,
                size: 5.5.w,
                color: AppColors.inActiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGenderBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: pref! ? AppColors.darkcolor : AppColors.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: textNormal(
                  S.of(context).male,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  4.w,
                  FontWeight.w500,
                ),
                onTap: () {
                  setState(() => selectedGender = "Male");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: textNormal(
                  S.of(context).female,
                  pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                  4.w,
                  FontWeight.w500,
                ),
                onTap: () {
                  setState(() => selectedGender = "Female");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
