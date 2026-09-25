import 'package:live_chat/core/api/api_consumer.dart';
import 'package:live_chat/core/api/end_points.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';

abstract class HomeRemoteDataSource {
  Future<dynamic> getAds();
  Future<dynamic> getPinnedChat();
  Future<dynamic> getSystemChats({int page = 1, int perPage = 8});
  Future<dynamic> getRecentChats({int page = 1, int perPage = 15});
  Future<dynamic> getUserChats({int page = 1, int perPage = 15});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiConsumer api;

  HomeRemoteDataSourceImpl({required this.api});

  String get _deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  @override
  Future<dynamic> getAds() async {
    return await api.get(
      "${EndPoints.getAds}?device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> getPinnedChat() async {
    return await api.get(
      "${EndPoints.pinChat}?device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> getSystemChats({int page = 1, int perPage = 8}) async {
    return await api.get(
      "${EndPoints.getSystemChatUrl}?per_page=$perPage&page=$page&device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> getRecentChats({int page = 1, int perPage = 15}) async {
    return await api.get(
      "${EndPoints.getRecentChatsUrl}?device_id=$_deviceId&per_page=$perPage&page=$page",
    );
  }

  @override
  Future<dynamic> getUserChats({int page = 1, int perPage = 15}) async {
    return await api.get(
      "${EndPoints.getUsersChatUrl}?per_page=$perPage&page=$page",
    );
  }
}
