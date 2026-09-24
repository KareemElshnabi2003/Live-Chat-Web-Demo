import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  Future<Either<String, List<dynamic>>> getAds();
  Future<Either<String, dynamic>> getPinnedChat();
  Future<Either<String, List<dynamic>>> getSystemChats({int page = 1, int perPage = 8});
  Future<Either<String, List<dynamic>>> getRecentChats({int page = 1, int perPage = 15});
  Future<Either<String, List<dynamic>>> getUserChats({int page = 1, int perPage = 15});
}
