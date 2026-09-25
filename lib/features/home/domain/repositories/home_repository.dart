import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import 'package:live_chat/features/chat/domain/entities/user_chat_entity.dart';
import '../entities/ad_entity.dart';
import '../entities/pin_chat_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<AdEntity>>> getAds();
  Future<Either<Failure, PinChatEntity?>> getPinnedChat();
  Future<Either<Failure, List<UserChatEntity>>> getSystemChats({int page = 1, int perPage = 8});
  Future<Either<Failure, List<UserChatEntity>>> getRecentChats({int page = 1, int perPage = 15});
  Future<Either<Failure, List<UserChatEntity>>> getUserChats({int page = 1, int perPage = 15});
  Future<Either<Failure, bool>> joinToChat({required String chatId});
}

