import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import '../entities/friend_suggest_entity.dart';

abstract class FriendsRepository {
  Future<Either<Failure, List<FriendSuggestEntity>>> getFriends({int page = 1, int perPage = 15});
  Future<Either<Failure, List<FriendSuggestEntity>>> getSuggestedFriends({int page = 1, int perPage = 15});
  Future<Either<Failure, Unit>> sendFriendRequest({required String friendId});
  Future<Either<Failure, Unit>> acceptOrRejectFriend({required String friendId, required String status});
  Future<Either<Failure, Unit>> removeFriend({required String friendId});
}
