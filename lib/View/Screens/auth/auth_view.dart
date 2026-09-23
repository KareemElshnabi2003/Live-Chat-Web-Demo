import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/Controller/page_start_controller.dart';
import 'package:live_chat/Core/Constant/app_color.dart';
import 'package:live_chat/Core/Constant/app_images.dart';
import 'package:live_chat/Core/class/status_request.dart';
import 'package:live_chat/View/Widget/PublicWidget/loading.dart';
import 'package:live_chat/View/Widget/PublicWidget/otp_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_click_widget.dart';
import 'package:live_chat/View/Widget/PublicWidget/text_field_widget.dart';
import 'package:live_chat/main.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/Core/utils/responsive_nums.dart';

class AuthView extends StatelessWidget {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PageStartController>()) {
      Get.put(PageStartController());
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: pref! ? AppColors.blackColor : AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: pref! ? AppColors.whiteColor : AppColors.blackColor,
          ),
          onPressed: () {
            final c = Get.find<PageStartController>();
            if (c.sheetName == 'Login' || c.sheetName == 'register2') {
              Get.back(); // Go back to start page
            } else if (c.sheetName == 'register1') {
              c.updateSheet('register2');
            } else if (c.sheetName == 'verifyLogin') {
              c.updateSheet('Login');
            } else if (c.sheetName == 'verifyRegister') {
              c.updateSheet('register1');
            }
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500), // Max width for web
          child: GetBuilder<PageStartController>(
            builder: (c) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: c.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Image
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          key: c.imageKey,
                          width: kIsWeb ? 200 : 70.w,
                          height: kIsWeb ? 200 : 70.w,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: (c.sheetName == 'verifyLogin' || c.sheetName == 'Login')
                                  ? const AssetImage(AppImages.loginImg)
                                  : const AssetImage(AppImages.registerImg),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Title Text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          key: ValueKey(c.sheetName),
                          c.sheetName == 'verifyLogin'
                              ? S.of(context).enter_the_code_sent
                              : c.sheetName == 'Login'
                                  ? S.of(context).enter_your_email_address
                                  : S.of(context).create_account,
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: pref! ? AppColors.whiteColor : AppColors.blackTextColor,
                            fontSize: kIsWeb ? 24 : 6.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle Text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          key: ValueKey('${c.sheetName}_sub'),
                          c.sheetName == 'verifyLogin'
                              ? S.of(context).you_must_verify_email
                              : c.sheetName == 'verifyRegister'
                                  ? S.of(context).fill_in_details_zero_steps
                                  : c.sheetName == 'Login'
                                      ? S.of(context).enter_email_to_complete
                                      : c.sheetName == 'register1'
                                          ? S.of(context).fill_in_information_one_step
                                          : S.of(context).fill_in_details_two_steps,
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: pref! ? AppColors.inActiveColor : AppColors.black2TextColor,
                            fontSize: kIsWeb ? 16 : 4.w,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Input Field or OTP
                      if (c.sheetName == 'verifyLogin' || c.sheetName == 'verifyRegister')
                        c.statuesRequest == StatuesRequest.loading
                            ? loading(50)
                            : otpWidget(c.verifyCode, (val) {
                                c.verifyCode = val;
                                if (c.sheetName == "verifyLogin") {
                                  c.verifyLogin();
                                } else {
                                  c.verifyRegister();
                                }
                              })
                      else
                        textFieldWidget(
                          c.sheetName == 'register1'
                              ? c.emailController
                              : c.sheetName == 'register2'
                                  ? c.nameController
                                  : c.emailController,
                          c.sheetName == 'register1'
                              ? S.of(context).email
                              : c.sheetName == 'register2'
                                  ? S.of(context).full_name
                                  : S.of(context).email,
                          false,
                          false,
                          (val) {
                            if (c.sheetName == 'register1') {
                              return c.validatorEmail(val!);
                            } else if (c.sheetName == 'register2') {
                              return c.validatorName(val!);
                            } else {
                              return c.validatorEmail(val!);
                            }
                          },
                          TextInputType.emailAddress,
                          null,
                          null,
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                        ),

                      if (c.sheetName == 'register2') ...[
                        const SizedBox(height: 15),
                        textFieldWidget(
                          c.userNameController,
                          S.of(context).userName,
                          false,
                          false,
                          (val) {
                            return c.validatorUserName(val!);
                          },
                          TextInputType.name,
                          null,
                          null,
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ],

                      if (c.sheetName == 'verifyLogin' || c.sheetName == 'verifyRegister') ...[
                        const SizedBox(height: 25),
                        textClick(S.of(context).resend, false, () {
                          c.reSendOTP();
                        }, AppColors.blackTextColor, kIsWeb ? 16 : 3.5.w),
                      ],

                      const SizedBox(height: 30),

                      // Next / Action Button
                      if (c.sheetName == 'Login' || c.sheetName == 'register1' || c.sheetName == 'register2')
                        c.statuesRequest == StatuesRequest.loading
                            ? loading(50)
                            : textClick(
                                S.of(context).next,
                                false,
                                () {
                                  if (c.formKey.currentState!.validate()) {
                                    if (c.sheetName == 'Login') {
                                      c.login();
                                    } else if (c.sheetName == 'register2') {
                                      c.updateSheet('register1');
                                    } else if (c.sheetName == 'register1') {
                                      c.register();
                                    }
                                  }
                                },
                                pref! ? AppColors.whiteColor : AppColors.blackColor,
                                kIsWeb ? 18 : 3.7.w,
                              ),
                      
                      const SizedBox(height: 20),

                      // Toggle Login/Register
                      if (c.sheetName == 'Login' || c.sheetName == 'register2')
                        TextButton(
                          onPressed: () {
                            if (c.sheetName == 'Login') {
                              c.emailController.clear();
                              c.updateSheet('register2');
                            } else if (c.sheetName == 'register2') {
                              c.emailController.clear();
                              c.nameController.clear();
                              c.userNameController.clear();
                              c.updateSheet('Login');
                            }
                          },
                          child: Text(
                            c.sheetName == 'Login'
                                ? S.of(context).create_account
                                : S.of(context).log_in,
                            style: GoogleFonts.ibmPlexSansArabic(
                              color: AppColors.secondaryColor,
                              fontSize: kIsWeb ? 16 : 3.5.w,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
