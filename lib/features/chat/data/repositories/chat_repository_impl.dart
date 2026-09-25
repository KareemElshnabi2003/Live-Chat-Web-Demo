import 'package:dartz/dartz.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/errors/failures.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/features/chat/data/models/chat_message_model.dart';
import 'package:live_chat/features/chat/data/models/member_of_chat_model.dart';
import 'package:live_chat/features/home/data/models/radio_model.dart';
import '../../domain/entities/chat_attachment.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages({required String chatId, int page = 1}) async {
    try {
      final response = await remoteDataSource.getMessages(chatId: chatId, page: page);
      if (response != null && response is Map && response['data'] is List) {
        final currentUserId = CacheHelper.getString(key: AppConstants.userIdKey);
        final list = (response['data'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return ChatMessage.fromJson(item, currentUserId: currentUserId);
          } else if (item is Map) {
            return ChatMessage.fromJson(Map<String, dynamic>.from(item), currentUserId: currentUserId);
          }
          return null;
        }).whereType<ChatMessage>().toList();
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
  Future<Either<Failure, dynamic>> sendMessage({
    required String chatId,
    required String message,
  }) async {
    try {
      final response = await remoteDataSource.sendMessage(chatId: chatId, message: message);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> sendMessageWithFile({
    required String chatId,
    required String messageType,
    ChatAttachment? file,
  }) async {
    try {
      final response = await remoteDataSource.sendMessageWithFile(
        chatId: chatId,
        messageType: messageType,
        file: file,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> sendReaction({
    required String messageId,
    required String react,
  }) async {
    try {
      final response = await remoteDataSource.sendReaction(messageId: messageId, react: react);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemberOfChatModel>>> getMembers({required String chatId, int page = 1}) async {
    try {
      final response = await remoteDataSource.getMembers(chatId: chatId, page: page);
      if (response != null && response is Map && response['data'] is List) {
        final list = (response['data'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return MemberOfChatModel.fromJson(item);
          } else if (item is Map) {
            return MemberOfChatModel.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        }).whereType<MemberOfChatModel>().toList();
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
  Future<Either<Failure, List<RadioModel>>> getRadios() async {
    try {
      final response = await remoteDataSource.getRadios();
      if (response != null && response is Map && response['data'] is List) {
        final list = (response['data'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return RadioModel.fromJson(item);
          } else if (item is Map) {
            return RadioModel.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        }).whereType<RadioModel>().toList();
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
  Future<Either<Failure, List<dynamic>>> getThemes() async {
    try {
      final response = await remoteDataSource.getThemes();
      if (response != null && response is Map && response['data'] is List) {
        return Right(response['data'] as List<dynamic>);
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> createGeneralChat({
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  }) async {
    try {
      final response = await remoteDataSource.createGeneralChat(
        data: data,
        imgChat: imgChat,
        bgChat: bgChat,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> updateGeneralChat({
    required String chatId,
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
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
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> deleteChat({required String chatId}) async {
    try {
      final response = await remoteDataSource.deleteChat(chatId: chatId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> acceptMemberToChat({
    required String chatId,
    required String userId,
  }) async {
    try {
      final response = await remoteDataSource.acceptMemberToChat(chatId: chatId, userId: userId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> blockOrUnBlock({
    required int status,
    required String userId,
  }) async {
    try {
      final response = await remoteDataSource.blockOrUnBlock(status: status, userId: userId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, dynamic>> createChatFriend({required int friendId}) async {
    try {
      final response = await remoteDataSource.createChatFriend(friendId: friendId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
