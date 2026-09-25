import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<dynamic>>> getMessages({required String chatId, int page = 1}) async {
    try {
      final response = await remoteDataSource.getMessages(chatId: chatId, page: page);
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
  Future<Either<String, dynamic>> sendMessage({
    required String chatId,
    required String message,
  }) async {
    try {
      final response = await remoteDataSource.sendMessage(chatId: chatId, message: message);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> sendMessageWithFile({
    required String chatId,
    required String messageType,
    MultipartFile? file,
  }) async {
    try {
      final response = await remoteDataSource.sendMessageWithFile(
        chatId: chatId,
        messageType: messageType,
        file: file,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> sendReaction({
    required String messageId,
    required String react,
  }) async {
    try {
      final response = await remoteDataSource.sendReaction(messageId: messageId, react: react);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<dynamic>>> getMembers({required String chatId, int page = 1}) async {
    try {
      final response = await remoteDataSource.getMembers(chatId: chatId, page: page);
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
  Future<Either<String, List<dynamic>>> getRadios() async {
    try {
      final response = await remoteDataSource.getRadios();
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
  Future<Either<String, List<dynamic>>> getThemes() async {
    try {
      final response = await remoteDataSource.getThemes();
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
  Future<Either<String, dynamic>> createGeneralChat({
    required Map<String, dynamic> data,
    MultipartFile? imgChat,
    MultipartFile? bgChat,
  }) async {
    try {
      final response = await remoteDataSource.createGeneralChat(
        data: data,
        imgChat: imgChat,
        bgChat: bgChat,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> updateGeneralChat({
    required String chatId,
    required Map<String, dynamic> data,
    MultipartFile? imgChat,
    MultipartFile? bgChat,
  }) async {
    try {
      final response = await remoteDataSource.updateGeneralChat(
        chatId: chatId,
        data: data,
        imgChat: imgChat,
        bgChat: bgChat,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> deleteChat({required String chatId}) async {
    try {
      final response = await remoteDataSource.deleteChat(chatId: chatId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> acceptMemberToChat({
    required String chatId,
    required String userId,
  }) async {
    try {
      final response = await remoteDataSource.acceptMemberToChat(chatId: chatId, userId: userId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> blockOrUnBlock({
    required int status,
    required String userId,
  }) async {
    try {
      final response = await remoteDataSource.blockOrUnBlock(status: status, userId: userId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, dynamic>> createChatFriend({required int friendId}) async {
    try {
      final response = await remoteDataSource.createChatFriend(friendId: friendId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(e.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
