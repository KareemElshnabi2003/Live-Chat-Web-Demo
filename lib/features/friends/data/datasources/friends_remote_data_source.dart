import 'package:live_chat/core/api/api_consumer.dart';
import 'package:live_chat/core/api/end_points.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/helper/cache_helper.dart';

abstract class FriendsRemoteDataSource {
  Future<Map<String, dynamic>> getFriends({int page = 1, int perPage = 15});
  Future<Map<String, dynamic>> getSuggestedFriends({int page = 1, int perPage = 15});
  Future<Map<String, dynamic>> sendFriendRequest({required String friendId});
  Future<Map<String, dynamic>> acceptOrRejectFriend({required String friendId, required String status});
  Future<Map<String, dynamic>> removeFriend({required String friendId});
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final ApiConsumer api;

  FriendsRemoteDataSourceImpl({required this.api});

  String get _deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  Map<String, dynamic> _toMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> getFriends({int page = 1, int perPage = 15}) async {
    final response = await api.get(
      "${EndPoints.getFriendsUrl}?per_page=$perPage&page=$page",
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> getSuggestedFriends({int page = 1, int perPage = 15}) async {
    final response = await api.get(
      "${EndPoints.getSuggestFriendsUrl}?per_page=$perPage&page=$page",
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> sendFriendRequest({required String friendId}) async {
    final response = await api.get(
      "${EndPoints.sendFriendRequestUrl}/$friendId?device_id=$_deviceId",
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> acceptOrRejectFriend({
    required String friendId,
    required String status,
  }) async {
    final response = await api.post(
      EndPoints.acceptOrRejectFriendUrl,
      data: {
        "friend_id": friendId,
        "status": status,
      },
    );
    return _toMap(response);
  }

  @override
  Future<Map<String, dynamic>> removeFriend({required String friendId}) async {
    final response = await api.post(
      "${EndPoints.removeFriendUrl}/$friendId",
      data: {},
    );
    return _toMap(response);
  }
}
