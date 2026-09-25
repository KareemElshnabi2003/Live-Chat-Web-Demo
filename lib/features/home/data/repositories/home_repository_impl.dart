import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import '../../data/models/ads_model.dart';
import '../../data/models/pin_chat_model.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<AdsModel>>> getAds() async {
    try {
      final response = await remoteDataSource.getAds();
      if (response != null && response is Map && response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => AdsModel.fromJson(e as Map<String, dynamic>))
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
  Future<Either<String, PinChatModel?>> getPinnedChat() async {
    try {
      final response = await remoteDataSource.getPinnedChat();
      if (response != null && response is Map && response['data'] != null) {
        if (response['data'] is List) {
          final list = response['data'] as List;
          if (list.isNotEmpty) {
            return Right(PinChatModel.fromJson(list.first as Map<String, dynamic>));
          }
        } else if (response['data'] is Map) {
          return Right(PinChatModel.fromJson(response['data'] as Map<String, dynamic>));
        }
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<UserChatModel>>> getSystemChats({int page = 1, int perPage = 8}) async {
    try {
      final response = await remoteDataSource.getSystemChats(page: page, perPage: perPage);
      if (response != null && response is Map && response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => UserChatModel.fromJson(e as Map<String, dynamic>))
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
  Future<Either<String, List<UserChatModel>>> getRecentChats({int page = 1, int perPage = 15}) async {
    try {
      final response = await remoteDataSource.getRecentChats(page: page, perPage: perPage);
      if (response != null && response is Map && response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => UserChatModel.fromJson(e as Map<String, dynamic>))
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
  Future<Either<String, List<UserChatModel>>> getUserChats({int page = 1, int perPage = 15}) async {
    try {
      final response = await remoteDataSource.getUserChats(page: page, perPage: perPage);
      if (response != null && response is Map && response['data'] is List) {
        final list = (response['data'] as List)
            .map((e) => UserChatModel.fromJson(e as Map<String, dynamic>))
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
  Future<Either<String, bool>> joinToChat({required dynamic chatId}) async {
    try {
      final response = await remoteDataSource.joinToChat(chatId: chatId);
      if (response != null && response is Map && response['status'] == 'forbiddenException') {
        return const Left('forbiddenException');
      }
      return const Right(true);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
