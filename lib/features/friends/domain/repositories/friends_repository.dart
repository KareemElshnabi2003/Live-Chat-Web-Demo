import 'package:dartz/dartz.dart';
import '../../data/models/friend_suggest_model.dart';

abstract class FriendsRepository {
  Future<Either<String, List<SuggestFreindModel>>> getFriends({int page = 1, int perPage = 15});
  Future<Either<String, List<SuggestFreindModel>>> getSuggestedFriends({int page = 1, int perPage = 15});
  Future<Either<String, dynamic>> sendFriendRequest({required String friendId});
  Future<Either<String, dynamic>> acceptOrRejectFriend({required String friendId, required String status});
  Future<Either<String, dynamic>> removeFriend({required String friendId});
}
