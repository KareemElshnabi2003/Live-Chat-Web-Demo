import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import '../../domain/usecases/check_otp_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/resend_otp_use_case.dart';
import '../../domain/usecases/verify_guest_use_case.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final CheckOtpUseCase checkOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final VerifyGuestUseCase verifyGuestUseCase;
  final LogoutUseCase logoutUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.checkOtpUseCase,
    required this.resendOtpUseCase,
    required this.verifyGuestUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial());

  Future<void> initDeviceIdAndToken() async {
    try {
      String? deviceId = CacheHelper.getString(key: AppConstants.deviceIdKey);
      if (deviceId == null || deviceId.isEmpty) {
        const uuid = Uuid();
        deviceId = uuid.v4();
        await CacheHelper.saveData(key: AppConstants.deviceIdKey, value: deviceId);
      }
    } catch (_) {}

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await CacheHelper.saveData(key: "deviceToken", value: fcmToken);
      }
    } catch (_) {
      await CacheHelper.saveData(key: "deviceToken", value: "web_dummy_token");
    }
  }

  Future<void> login({required String email}) async {
    emit(AuthLoading());
    final result = await loginUseCase(email: email);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthCodeSent(email: email, isRegister: false)),
    );
  }

  Future<void> register({
    required String name,
    required String userName,
    required String email,
  }) async {
    emit(AuthLoading());
    final result = await registerUseCase(
      name: name,
      userName: userName,
      email: email,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthCodeSent(email: email, isRegister: true)),
    );
  }

  Future<void> resendOTP({required String email}) async {
    final result = await resendOtpUseCase(email: email);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> checkOTP({
    required String email,
    required String otp,
  }) async {
    emit(AuthLoading());
    final fcmToken = CacheHelper.getString(key: "deviceToken");
    final result = await checkOtpUseCase(
      email: email,
      otp: otp,
      fcmToken: fcmToken,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (response) async {
        final data = response['data'];
        if (data != null && data is Map) {
          final dataMap = data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data);
          await CacheHelper.saveData(key: AppConstants.nameKey, value: dataMap['name'] ?? '');
          await CacheHelper.saveData(key: AppConstants.userIdKey, value: dataMap['id']?.toString() ?? '');
          await CacheHelper.saveData(key: AppConstants.usernameKey, value: dataMap['username'] ?? '');
          await CacheHelper.saveData(key: AppConstants.userImageKey, value: dataMap['image'] ?? '');
          await CacheHelper.saveData(key: AppConstants.tokenKey, value: dataMap['token'] ?? '');
          await CacheHelper.saveData(key: 'bio', value: dataMap['bio'] ?? '');
          await CacheHelper.saveData(key: 'stars', value: dataMap['number_of_stars']?.toString() ?? '0');
          await CacheHelper.saveData(key: AppConstants.pageKey, value: 'Home');

          if (dataMap['user_power'] != null) {
            await CacheHelper.saveData(
              key: 'powermodel',
              value: jsonEncode(dataMap['user_power']),
            );
          }

          // Remove Guest data
          await CacheHelper.removeData(key: 'idGust');
          await CacheHelper.removeData(key: 'usernameGust');

          emit(AuthSuccess(userData: dataMap));
          return;
        }
        emit(AuthError(message: "بيانات التحقق غير صحيحة"));
      },
    );
  }

  Future<void> verifyGuest() async {
    emit(AuthLoading());
    final result = await verifyGuestUseCase();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (response) async {
        final data = response['data'];
        if (data != null && data is Map) {
          final dataMap = data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data);
          await CacheHelper.saveData(key: 'idGust', value: dataMap['id']?.toString() ?? '');
          await CacheHelper.saveData(key: 'usernameGust', value: dataMap['name'] ?? '');
          await CacheHelper.saveData(key: AppConstants.isGuestKey, value: true);
          emit(AuthGuestSuccess(guestData: dataMap));
          return;
        }
        emit(AuthError(message: "فشل التحقق كزائر"));
      },
    );
  }

  Future<void> logOut() async {
    emit(AuthLoading());
    await logoutUseCase();
    await CacheHelper.clearData();
    // Keep deviceId after logout
    await initDeviceIdAndToken();
    emit(AuthLoggedOut());
  }

  Future<void> logout() => logOut();
}
