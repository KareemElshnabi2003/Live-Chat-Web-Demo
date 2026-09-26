import 'package:live_chat/core/api/api_consumer.dart';
import 'package:live_chat/core/api/end_points.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';

abstract class NotificationsRemoteDataSource {
  Future<Map<String, dynamic>> getNotifications();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiConsumer api;

  NotificationsRemoteDataSourceImpl({required this.api});

  String get _deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  Map<String, dynamic> _toMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> getNotifications() async {
    final response = await api.get(
      "${EndPoints.getNotificationUrl}?device_id=$_deviceId",
    );
    return _toMap(response);
  }
}
