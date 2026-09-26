import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:live_chat/core/constant/app_constant.dart';
import 'package:live_chat/core/errors/failures.dart';
import 'package:live_chat/core/errors/server_exceptions.dart';
import 'package:live_chat/core/helper/cache_helper.dart';
import 'package:live_chat/features/chat/data/models/chat_message_model.dart';
import 'package:live_chat/features/chat/data/models/chat_theme_model.dart';
import 'package:live_chat/features/chat/data/models/member_of_chat_model.dart';
import 'package:live_chat/features/home/data/models/radio_model.dart';
import '../../domain/entities/chat_attachment.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/entities/radio_entity.dart';
import '../../domain/entities/chat_theme_entity.dart';
import '../../domain/entities/user_chat_entity.dart';
import '../models/user_chat_model.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  String? get _currentUserId {
    final uid = CacheHelper.getString(key: AppConstants.userIdKey);
    if (uid != null && uid.isNotEmpty && uid != 'null') return uid;
    final gid = CacheHelper.getString(key: 'idGust') ?? CacheHelper.getData(key: 'idGust')?.toString();
    if (gid != null && gid.isNotEmpty && gid != 'null') return gid;
    return null;
  }

  String? get _currentUserName {
    final name = CacheHelper.getString(key: AppConstants.nameKey);
    if (name != null && name.isNotEmpty && name != 'null') return name;
    final uname = CacheHelper.getString(key: AppConstants.usernameKey);
    if (uname != null && uname.isNotEmpty && uname != 'null') return uname;
    final gname = CacheHelper.getString(key: 'usernameGust') ?? CacheHelper.getData(key: 'usernameGust')?.toString();
    if (gname != null && gname.isNotEmpty && gname != 'null') return gname;
    return null;
  }

  void _autoSaveGuestCredentials(Map<String, dynamic> response) {
    if (response['data'] is Map) {
      final data = response['data'] as Map;
      final senderId = data['sender_id']?.toString();
      final senderName = data['sender_name']?.toString() ?? data['username']?.toString();
      final currentUid = CacheHelper.getString(key: AppConstants.userIdKey);
      if (currentUid == null || currentUid.isEmpty || currentUid == 'null') {
        if (senderId != null && senderId.isNotEmpty && senderId != 'null') {
          CacheHelper.saveData(key: 'idGust', value: senderId);
        }
        if (senderName != null && senderName.isNotEmpty && senderName != 'null') {
          CacheHelper.saveData(key: 'usernameGust', value: senderName);
        }
        CacheHelper.saveData(key: AppConstants.isGuestKey, value: true);
      }
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages({required String chatId, int page = 1}) async {
    try {
      final response = await remoteDataSource.getMessages(chatId: chatId, page: page);
      if (response['data'] is List) {
        final currentUserId = _currentUserId;
        final currentUserName = _currentUserName;
        final list = (response['data'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return ChatMessageModel.fromJson(item, currentUserId: currentUserId, currentUserName: currentUserName);
          } else if (item is Map) {
            return ChatMessageModel.fromJson(Map<String, dynamic>.from(item), currentUserId: currentUserId, currentUserName: currentUserName);
          }
          return null;
        }).whereType<ChatMessageEntity>().toList();
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
  Future<Either<Failure, Unit>> sendMessage({
    required String chatId,
    required String message,
  }) async {
    try {
      final response = await remoteDataSource.sendMessage(chatId: chatId, message: message);
      _autoSaveGuestCredentials(response);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendMessageWithFile({
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
      _autoSaveGuestCredentials(response);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendReaction({
    required String messageId,
    required String react,
  }) async {
    try {
      await remoteDataSource.sendReaction(messageId: messageId, react: react);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemberEntity>>> getMembers({required String chatId, int page = 1}) async {
    try {
      final response = await remoteDataSource.getMembers(chatId: chatId, page: page);
      if (response['data'] is List) {
        final list = (response['data'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return MemberOfChatModel.fromJson(item);
          } else if (item is Map) {
            return MemberOfChatModel.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        }).whereType<MemberEntity>().toList();
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
  Future<Either<Failure, List<RadioEntity>>> getRadios() async {
    try {
      final response = await remoteDataSource.getRadios();
      if (response['data'] is List) {
        final list = (response['data'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return RadioModel.fromJson(item);
          } else if (item is Map) {
            return RadioModel.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        }).whereType<RadioEntity>().toList();
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
  Future<Either<Failure, List<ChatThemeEntity>>> getThemes() async {
    try {
      final response = await remoteDataSource.getThemes();
      if (response['data'] is List) {
        final list = (response['data'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return ChatThemeModel.fromJson(item);
          } else if (item is Map) {
            return ChatThemeModel.fromJson(Map<String, dynamic>.from(item));
          }
          return null;
        }).whereType<ChatThemeEntity>().toList();
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
  Future<Either<Failure, Unit>> createGeneralChat({
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  }) async {
    try {
      await remoteDataSource.createGeneralChat(
        data: data,
        imgChat: imgChat,
        bgChat: bgChat,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateGeneralChat({
    required String chatId,
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  }) async {
    try {
      await remoteDataSource.updateGeneralChat(
        chatId: chatId,
        data: data,
        imgChat: imgChat,
        bgChat: bgChat,
      );
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteChat({required String chatId}) async {
    try {
      await remoteDataSource.deleteChat(chatId: chatId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptMemberToChat({
    required String chatId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.acceptMemberToChat(chatId: chatId, userId: userId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> blockOrUnBlock({
    required int status,
    required String userId,
  }) async {
    try {
      await remoteDataSource.blockOrUnBlock(status: status, userId: userId);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserChatEntity>> createChatFriend({required int friendId}) async {
    try {
      final response = await remoteDataSource.createChatFriend(friendId: friendId);
      if (response['data'] != null) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : Map<String, dynamic>.from(response['data'] as Map);
        return Right(UserChatModel.fromJson(data));
      }
      return const Left(ServerFailure('Failed to create friend chat: empty response'));
    } on ServerException catch (e) {
      return Left(ServerFailure.fromServerException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ChatMessageEntity? parsePusherMessage(dynamic rawData) {
    try {
      final dynamic raw = rawData is String ? jsonDecode(rawData) : rawData;
      if (raw is Map) {
        final currentUserId = _currentUserId;
        final currentUserName = _currentUserName;
        final map = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw);
        final messageMap = (map['message'] is Map)
            ? (map['message'] is Map<String, dynamic>
                ? map['message'] as Map<String, dynamic>
                : Map<String, dynamic>.from(map['message'] as Map))
            : map;
        return ChatMessageModel.fromJson(messageMap, currentUserId: currentUserId, currentUserName: currentUserName);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }
}