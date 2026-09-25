import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_chat/core/constant/app_color.dart';
import 'package:live_chat/core/constant/app_images.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/core/utils/responsive_nums.dart';
import 'package:live_chat/core/widgets/loading.dart';
import 'package:live_chat/core/widgets/otp_widget.dart';
import 'package:live_chat/core/widgets/text_click_widget.dart';
import 'package:live_chat/core/widgets/text_field_widget.dart';
import 'package:live_chat/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:live_chat/features/auth/presentation/cubit/auth_state.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:live_chat/main.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();

  String _sheetName = 'Login'; // 'Login', 'register2', 'register1', 'verifyLogin', 'verifyRegister'
  String _verifyCode = '';

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void _onBack() {
    if (_sheetName == 'Login' || _sheetName == 'register2') {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(Routes.startPageScreen);
      }
    } else if (_sheetName == 'register1') {
      setState(() => _sheetName = 'register2');
    } else if (_sheetName == 'verifyLogin') {
      setState(() => _sheetName = 'Login');
    } else if (_sheetName == 'verifyRegister') {
      setState(() => _sheetName = 'register1');
    }
  }

  String? _validatorEmail(String? val) {
    if (val == null || val.trim().isEmpty) {
      return S.of(context).please_enter_your_email;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
      return S.of(context).please_enter_valid_email;
    }
    return null;
  }

  String? _validatorName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return S.of(context).please_enter_your_name;
    }
    if (val.trim().length < 3) {
      return S.of(context).please_enter_your_name;
    }
    return null;
  }

  String? _validatorUserName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return S.of(context).userName;
    }
    if (val.trim().length < 3) {
      return S.of(context).userName;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = pref;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthCodeSent) {
          setState(() {
            _sheetName = state.isRegister ? 'verifyRegister' : 'verifyLogin';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context).enter_the_code_sent,
                style: GoogleFonts.ibmPlexSansArabic(),
              ),
              backgroundColor: AppColors.primaryColor,
            ),
          );
        } else if (state is AuthSuccess || state is AuthGuestSuccess) {
          context.go(Routes.homeScreen);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.ibmPlexSansArabic(),
              ),
              backgroundColor: AppColors.redColor,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: isDark ? AppColors.blackColor : AppColors.bgColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDark ? AppColors.whiteColor : AppColors.blackColor,
              ),
              onPressed: _onBack,
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Image
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          key: ValueKey(_sheetName),
                          width: kIsWeb ? 200 : 70.w,
                          height: kIsWeb ? 200 : 70.w,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: (_sheetName == 'verifyLogin' || _sheetName == 'Login')
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
                          key: ValueKey(_sheetName),
                          _sheetName == 'verifyLogin' || _sheetName == 'verifyRegister'
                              ? S.of(context).enter_the_code_sent
                              : _sheetName == 'Login'
                                  ? S.of(context).enter_your_email_address
                                  : S.of(context).create_account,
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: isDark ? AppColors.whiteColor : AppColors.blackTextColor,
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
                          key: ValueKey('${_sheetName}_sub'),
                          _sheetName == 'verifyLogin'
                              ? S.of(context).you_must_verify_email
                              : _sheetName == 'verifyRegister'
                                  ? S.of(context).fill_in_details_zero_steps
                                  : _sheetName == 'Login'
                                      ? S.of(context).enter_email_to_complete
                                      : _sheetName == 'register1'
                                          ? S.of(context).fill_in_information_one_step
                                          : S.of(context).fill_in_details_two_steps,
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: isDark ? AppColors.inActiveColor : AppColors.black2TextColor,
                            fontSize: kIsWeb ? 16 : 4.w,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Input Field or OTP
                      if (_sheetName == 'verifyLogin' || _sheetName == 'verifyRegister')
                        isLoading
                            ? loading(50)
                            : otpWidget(_verifyCode, (val) {
                                _verifyCode = val;
                                context.read<AuthCubit>().checkOTP(
                                  email: _emailController.text.trim(),
                                  otp: val,
                                );
                              })
                      else
                        textFieldWidget(
                          _sheetName == 'register2' ? _nameController : _emailController,
                          _sheetName == 'register2'
                              ? S.of(context).full_name
                              : S.of(context).email,
                          false,
                          false,
                          (val) {
                            if (_sheetName == 'register2') {
                              return _validatorName(val);
                            }
                            return _validatorEmail(val);
                          },
                          _sheetName == 'register2' ? TextInputType.name : TextInputType.emailAddress,
                          null,
                          null,
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                        ),

                      if (_sheetName == 'register2') ...[
                        const SizedBox(height: 15),
                        textFieldWidget(
                          _userNameController,
                          S.of(context).userName,
                          false,
                          false,
                          (val) => _validatorUserName(val),
                          TextInputType.name,
                          null,
                          null,
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ],

                      if (_sheetName == 'verifyLogin' || _sheetName == 'verifyRegister') ...[
                        const SizedBox(height: 25),
                        textClick(
                          S.of(context).resend,
                          false,
                          () {
                            context.read<AuthCubit>().resendOTP(
                              email: _emailController.text.trim(),
                            );
                          },
                          AppColors.blackTextColor,
                          kIsWeb ? 16 : 3.5.w,
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Next / Action Button
                      if (_sheetName == 'Login' || _sheetName == 'register1' || _sheetName == 'register2')
                        isLoading
                            ? loading(50)
                            : textClick(
                                S.of(context).next,
                                false,
                                () {
                                  if (_formKey.currentState!.validate()) {
                                    if (_sheetName == 'Login') {
                                      context.read<AuthCubit>().login(
                                        email: _emailController.text.trim(),
                                      );
                                    } else if (_sheetName == 'register2') {
                                      setState(() => _sheetName = 'register1');
                                    } else if (_sheetName == 'register1') {
                                      context.read<AuthCubit>().register(
                                        name: _nameController.text.trim(),
                                        userName: _userNameController.text.trim(),
                                        email: _emailController.text.trim(),
                                      );
                                    }
                                  }
                                },
                                isDark ? AppColors.whiteColor : AppColors.blackColor,
                                kIsWeb ? 18 : 3.7.w,
                              ),

                      const SizedBox(height: 20),

                      // Toggle Login/Register
                      if (_sheetName == 'Login' || _sheetName == 'register2')
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (_sheetName == 'Login') {
                                _emailController.clear();
                                _sheetName = 'register2';
                              } else {
                                _emailController.clear();
                                _nameController.clear();
                                _userNameController.clear();
                                _sheetName = 'Login';
                              }
                            });
                          },
                          child: Text(
                            _sheetName == 'Login'
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
              ),
            ),
          ),
        );
      },
    );
  }
}
