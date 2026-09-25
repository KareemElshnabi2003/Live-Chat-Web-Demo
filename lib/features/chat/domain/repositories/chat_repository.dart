import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

abstract class ChatRepository {
  Future<Either<String, List<dynamic>>> getMessages({required String chatId, int page = 1});
  Future<Either<String, dynamic>> sendMessage({
    required String chatId,
    required String message,
  });
  Future<Either<String, dynamic>> sendMessageWithFile({
    required String chatId,
    required String messageType,
    MultipartFile? file,
  });
  Future<Either<String, dynamic>> sendReaction({
    required String messageId,
    required String react,
  });
  Future<Either<String, List<dynamic>>> getMembers({required String chatId, int page = 1});
  Future<Either<String, List<dynamic>>> getRadios();
  Future<Either<String, List<dynamic>>> getThemes();
  Future<Either<String, dynamic>> createGeneralChat({
    required Map<String, dynamic> data,
    MultipartFile? imgChat,
    MultipartFile? bgChat,
  });
  Future<Either<String, dynamic>> updateGeneralChat({
    required String chatId,
    required Map<String, dynamic> data,
    MultipartFile? imgChat,
    MultipartFile? bgChat,
  });
  Future<Either<String, dynamic>> deleteChat({required String chatId});
  Future<Either<String, dynamic>> acceptMemberToChat({
    required String chatId,
    required String userId,
  });
  Future<Either<String, dynamic>> blockOrUnBlock({
    required int status,
    required String userId,
  });
  Future<Either<String, dynamic>> createChatFriend({required int friendId});
}
