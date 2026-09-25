import 'package:dartz/dartz.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import '../../data/models/ads_model.dart';
import '../../data/models/pin_chat_model.dart';

abstract class HomeRepository {
  Future<Either<String, List<AdsModel>>> getAds();
  Future<Either<String, PinChatModel?>> getPinnedChat();
  Future<Either<String, List<UserChatModel>>> getSystemChats({int page = 1, int perPage = 8});
  Future<Either<String, List<UserChatModel>>> getRecentChats({int page = 1, int perPage = 15});
  Future<Either<String, List<UserChatModel>>> getUserChats({int page = 1, int perPage = 15});
  Future<Either<String, bool>> joinToChat({required dynamic chatId});
}
