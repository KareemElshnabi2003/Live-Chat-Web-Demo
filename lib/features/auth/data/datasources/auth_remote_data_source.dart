import 'package:live_chat/core/api/api_consumer.dart';
import 'package:live_chat/core/api/end_points.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({required String email});
  Future<Map<String, dynamic>> register({
    required String name,
    required String userName,
    required String email,
  });
  Future<Map<String, dynamic>> checkOTP({
    required String otp,
    required String email,
    String? fcmToken,
  });
  Future<Map<String, dynamic>> sendOTP({required String email});
  Future<Map<String, dynamic>> resendOTP({required String email});
  Future<Map<String, dynamic>> verifyGuest();
  Future<Map<String, dynamic>> logOut();
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

  Map<String, dynamic> _toMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> login({required String email}) async {
    final response = await api.post(
      "${EndPoints.loginUrl}?device_id=$_deviceId",
      data: {
        "email": email,
        "remember": 1,
      },
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String userName,
    required String email,
  }) async {
    final response = await api.post(
      "${EndPoints.registerUrl}?device_id=$_deviceId",
      data: {
        "email": email,
        "name": name,
        "username": userName,
      },
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> checkOTP({
    required String otp,
    required String email,
    String? fcmToken,
  }) async {
    final response = await api.post(
      "${EndPoints.checkOTPUrl}?device_id=$_deviceId",
      data: {
        "email": email,
        "token": otp,
        "fcm_token": fcmToken,
        "mobile_theme": _mobileTheme,
      },
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> sendOTP({required String email}) async {
    final response = await api.post(
      "${EndPoints.sendOTPUrl}?device_id=$_deviceId",
      data: {"email": email},
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> resendOTP({required String email}) async {
    final response = await api.post(
      "${EndPoints.resendOTPUrl}?device_id=$_deviceId",
      data: {"email": email},
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> verifyGuest() async {
    final response = await api.post(
      EndPoints.guestUrl,
      data: {"device_id": _deviceId},
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> logOut() async {
    final response = await api.post(
      "${EndPoints.logoutUrl}?device_id=$_deviceId",
      data: {},
    );
    return _toMap(response);
  }
}
