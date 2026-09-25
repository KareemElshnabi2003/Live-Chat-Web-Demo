import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<dynamic>>> getAds() async {
    try {
      final response = await remoteDataSource.getAds();
      if (response != null && response is Map && response['data'] is List) {
        return Right(response['data'] as List<dynamic>);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> getPinnedChat() async {
    try {
      final response = await remoteDataSource.getPinnedChat();
      if (response != null && response is Map && response['data'] is List) {
        final list = response['data'] as List;
        if (list.isNotEmpty) {
          return Right(list.first);
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
  Future<Either<String, List<dynamic>>> getSystemChats({int page = 1, int perPage = 8}) async {
    try {
      final response = await remoteDataSource.getSystemChats(page: page, perPage: perPage);
      if (response != null && response is Map && response['data'] is List) {
        return Right(response['data'] as List<dynamic>);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<dynamic>>> getRecentChats({int page = 1, int perPage = 15}) async {
    try {
      final response = await remoteDataSource.getRecentChats(page: page, perPage: perPage);
      if (response != null && response is Map && response['data'] is List) {
        return Right(response['data'] as List<dynamic>);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<dynamic>>> getUserChats({int page = 1, int perPage = 15}) async {
    try {
      final response = await remoteDataSource.getUserChats(page: page, perPage: perPage);
      if (response != null && response is Map && response['data'] is List) {
        return Right(response['data'] as List<dynamic>);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
