import 'package:dartz/dartz.dart';
import '../repositories/friends_repository.dart';

class GetFriendsUseCase {
  final FriendsRepository repository;
  GetFriendsUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call({int page = 1, int perPage = 15}) {
    return repository.getFriends(page: page, perPage: perPage);
  }
}

class GetSuggestedFriendsUseCase {
  final FriendsRepository repository;
  GetSuggestedFriendsUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call({int page = 1, int perPage = 15}) {
    return repository.getSuggestedFriends(page: page, perPage: perPage);
  }
}

class SendFriendRequestUseCase {
  final FriendsRepository repository;
  SendFriendRequestUseCase(this.repository);

  Future<Either<String, dynamic>> call({required String friendId}) {
    return repository.sendFriendRequest(friendId: friendId);
  }
}

class AcceptOrRejectFriendUseCase {
  final FriendsRepository repository;
  AcceptOrRejectFriendUseCase(this.repository);

  Future<Either<String, dynamic>> call({required String friendId, required String status}) {
    return repository.acceptOrRejectFriend(friendId: friendId, status: status);
  }
}

class RemoveFriendUseCase {
  final FriendsRepository repository;
  RemoveFriendUseCase(this.repository);

  Future<Either<String, dynamic>> call({required String friendId}) {
    return repository.removeFriend(friendId: friendId);
  }
}
