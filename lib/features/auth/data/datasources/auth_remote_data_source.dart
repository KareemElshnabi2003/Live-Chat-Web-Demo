import 'package:live_chat/core/api/api_consumer.dart';
import 'package:live_chat/core/api/end_points.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';

abstract class AuthRemoteDataSource {
  Future<dynamic> login({required String email});
  Future<dynamic> register({
    required String name,
    required String userName,
    required String email,
  });
  Future<dynamic> checkOTP({
    required String otp,
    required String email,
    String? fcmToken,
  });
  Future<dynamic> sendOTP({required String email});
  Future<dynamic> resendOTP({required String email});
  Future<dynamic> verifyGuest();
  Future<dynamic> logOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer api;

  AuthRemoteDataSourceImpl({required this.api});

  String get _deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  String get _mobileTheme =>
      (CacheHelper.getBool(key: AppConstants.isDarkModeKey) ?? false)
          ? "dark"
          : "light";

  @override
  Future<dynamic> login({required String email}) async {
    return await api.post(
      "${EndPoints.loginUrl}?device_id=$_deviceId",
      data: {
        "email": email,
        "remember": 1,
      },
    );
  }

  @override
  Future<dynamic> register({
    required String name,
    required String userName,
    required String email,
  }) async {
    return await api.post(
      "${EndPoints.registerUrl}?device_id=$_deviceId",
      data: {
        "email": email,
        "name": name,
        "username": userName,
      },
    );
  }

  @override
  Future<dynamic> checkOTP({
    required String otp,
    required String email,
    String? fcmToken,
  }) async {
    return await api.post(
      "${EndPoints.checkOTPUrl}?device_id=$_deviceId",
      data: {
        "email": email,
        "token": otp,
        "fcm_token": fcmToken,
        "mobile_theme": _mobileTheme,
      },
    );
  }

  @override
  Future<dynamic> sendOTP({required String email}) async {
    return await api.post(
      "${EndPoints.sendOTPUrl}?device_id=$_deviceId",
      data: {"email": email},
    );
  }

  @override
  Future<dynamic> resendOTP({required String email}) async {
    return await api.post(
      "${EndPoints.resendOTPUrl}?device_id=$_deviceId",
      data: {"email": email},
    );
  }

  @override
  Future<dynamic> verifyGuest() async {
    return await api.post(
      EndPoints.guestUrl,
      data: {"device_id": _deviceId},
    );
  }

  @override
  Future<dynamic> logOut() async {
    return await api.post(
      "${EndPoints.logoutUrl}?device_id=$_deviceId",
      data: {},
    );
  }
}
