import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/constant/app_constant.dart';
import '../../../../core/helper/cache_helper.dart';

abstract class NotificationsRemoteDataSource {
  Future<dynamic> getNotifications();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiConsumer api;

  NotificationsRemoteDataSourceImpl({required this.api});

  String get _deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  @override
  Future<dynamic> getNotifications() async {
    return await api.get(
      "${EndPoints.getNotificationUrl}?device_id=$_deviceId",
    );
  }
}
