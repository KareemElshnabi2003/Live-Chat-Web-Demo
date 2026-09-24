import '../../../../core/api/api_consumer.dart';
import '../../../../core/api/end_points.dart';
import '../../../../core/constant/app_constant.dart';
import '../../../../core/helper/cache_helper.dart';

abstract class FriendsRemoteDataSource {
  Future<dynamic> getFriends({int page = 1, int perPage = 15});
  Future<dynamic> getSuggestedFriends({int page = 1, int perPage = 15});
  Future<dynamic> sendFriendRequest({required String friendId});
  Future<dynamic> acceptOrRejectFriend({required String friendId, required String status});
  Future<dynamic> removeFriend({required String friendId});
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final ApiConsumer api;

  FriendsRemoteDataSourceImpl({required this.api});

  String get _deviceId =>
      CacheHelper.getString(key: AppConstants.deviceIdKey) ?? "";

  @override
  Future<dynamic> getFriends({int page = 1, int perPage = 15}) async {
    return await api.get(
      "${EndPoints.getFriendsUrl}?per_page=$perPage&page=$page",
    );
  }

  @override
  Future<dynamic> getSuggestedFriends({int page = 1, int perPage = 15}) async {
    return await api.get(
      "${EndPoints.getSuggestFriendsUrl}?per_page=$perPage&page=$page",
    );
  }

  @override
  Future<dynamic> sendFriendRequest({required String friendId}) async {
    return await api.get(
      "${EndPoints.sendFriendRequestUrl}/$friendId?device_id=$_deviceId",
    );
  }

  @override
  Future<dynamic> acceptOrRejectFriend({
    required String friendId,
    required String status,
  }) async {
    return await api.post(
      EndPoints.acceptOrRejectFriendUrl,
      data: {
        "friend_id": friendId,
        "status": status,
      },
    );
  }

  @override
  Future<dynamic> removeFriend({required String friendId}) async {
    return await api.post(
      "${EndPoints.removeFriendUrl}/$friendId",
      data: {},
    );
  }
}
