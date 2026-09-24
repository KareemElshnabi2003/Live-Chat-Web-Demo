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
}
