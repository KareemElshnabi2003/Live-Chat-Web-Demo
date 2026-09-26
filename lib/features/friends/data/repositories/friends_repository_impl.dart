import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import '../../domain/entities/friend_suggest_entity.dart';
import '../../domain/repositories/friends_repository.dart';
import '../datasources/friends_remote_data_source.dart';
import '../models/friend_suggest_model.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remoteDataSource;

  FriendsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FriendSuggestEntity>>> getFriends({int page = 1, int perPage = 15}) async {
    try {
      final response = await remoteDataSource.getFriends(page: page, perPage: perPage);
      if (response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => SuggestFreindModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return Right(list);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendSuggestEntity>>> getSuggestedFriends({int page = 1, int perPage = 15}) async {
    try {
      final response = await remoteDataSource.getSuggestedFriends(page: page, perPage: perPage);
      if (response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => SuggestFreindModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return Right(list);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendFriendRequest({required String friendId}) async {
    try {
      await remoteDataSource.sendFriendRequest(friendId: friendId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptOrRejectFriend({
    required String friendId,
    required String status,
  }) async {
    try {
      await remoteDataSource.acceptOrRejectFriend(
        friendId: friendId,
        status: status,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeFriend({required String friendId}) async {
    try {
      await remoteDataSource.removeFriend(friendId: friendId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
