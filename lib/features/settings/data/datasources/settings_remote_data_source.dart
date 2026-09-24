import 'package:dio/dio.dart';
import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/constant/app_constant.dart';
import '../../../../core/helper/cache_helper.dart';

abstract class SettingsRemoteDataSource {
  Future<dynamic> getProfile();
  Future<dynamic> updateProfile({
    required String name,
    required String bio,
    required String username,
    required String email,
    required String phone,
    required String age,
    required String gender,
    List<int>? imageBytes,
    String? imageName,
  });
  Future<dynamic> deleteAccount();
  Future<dynamic> changeMobileTheme({required String theme});
  Future<dynamic> getPrivacyPolicy();
  Future<dynamic> getTerms();
  Future<dynamic> getAdsWithUs();
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiConsumer api;

  SettingsRemoteDataSourceImpl({required this.api});

  String get _deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  @override
  Future<dynamic> getProfile() async {
    return await api.get(EndPoints.getProfileUrl);
  }

  @override
  Future<dynamic> updateProfile({
    required String name,
    required String bio,
    required String username,
    required String email,
    required String phone,
    required String age,
    required String gender,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    final Map<String, dynamic> dataMap = {
      'name': name,
      'bio': bio,
      'username': username,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'country_id': '1',
      'device_id': _deviceId,
    };

    if (imageBytes != null && imageBytes.isNotEmpty) {
      dataMap['image'] = MultipartFile.fromBytes(
        imageBytes,
        filename: imageName ?? 'profile.jpg',
      );
    }

    final formData = FormData.fromMap(dataMap);
    return await api.post(EndPoints.updateProfileUrl, data: formData);
  }

  @override
  Future<dynamic> deleteAccount() async {
    return await api.post(
      EndPoints.deleteAccUrl,
      data: {"device_id": _deviceId},
    );
  }

  @override
  Future<dynamic> changeMobileTheme({required String theme}) async {
    return await api.post(
      EndPoints.changeThemeUrl,
      data: {
        "theme": theme,
        "device_id": _deviceId,
      },
    );
  }

  @override
  Future<dynamic> getPrivacyPolicy() async {
    return await api.get(EndPoints.privacyPolicy);
  }

  @override
  Future<dynamic> getTerms() async {
    return await api.get(EndPoints.terms);
  }

  @override
  Future<dynamic> getAdsWithUs() async {
    return await api.get(EndPoints.adsWithUs);
  }
}
