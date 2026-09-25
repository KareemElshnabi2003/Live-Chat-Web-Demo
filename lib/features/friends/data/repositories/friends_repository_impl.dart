import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import '../../domain/repositories/friends_repository.dart';
import '../datasources/friends_remote_data_source.dart';
import '../models/friend_suggest_model.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remoteDataSource;

  FriendsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<SuggestFreindModel>>> getFriends({int page = 1, int perPage = 15}) async {
    try {
      final response = await remoteDataSource.getFriends(page: page, perPage: perPage);
      if (response != null && response is Map && response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => SuggestFreindModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return Right(list);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<SuggestFreindModel>>> getSuggestedFriends({int page = 1, int perPage = 15}) async {
    try {
      final response = await remoteDataSource.getSuggestedFriends(page: page, perPage: perPage);
      if (response != null && response is Map && response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => SuggestFreindModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return Right(list);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> sendFriendRequest({required String friendId}) async {
    try {
      final response = await remoteDataSource.sendFriendRequest(friendId: friendId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> acceptOrRejectFriend({
    required String friendId,
    required String status,
  }) async {
    try {
      final response = await remoteDataSource.acceptOrRejectFriend(
        friendId: friendId,
        status: status,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> removeFriend({required String friendId}) async {
    try {
      final response = await remoteDataSource.removeFriend(friendId: friendId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
