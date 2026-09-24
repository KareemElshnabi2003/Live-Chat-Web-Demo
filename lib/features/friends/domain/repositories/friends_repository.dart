import 'package:dartz/dartz.dart';

abstract class FriendsRepository {
  Future<Either<String, List<dynamic>>> getFriends({int page = 1, int perPage = 15});
  Future<Either<String, List<dynamic>>> getSuggestedFriends({int page = 1, int perPage = 15});
  Future<Either<String, dynamic>> sendFriendRequest({required String friendId});
  Future<Either<String, dynamic>> acceptOrRejectFriend({required String friendId, required String status});
  Future<Either<String, dynamic>> removeFriend({required String friendId});
}
