import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import '../entities/chat_attachment.dart';
import '../entities/chat_message_entity.dart';
import '../entities/member_entity.dart';
import '../entities/radio_entity.dart';
import '../entities/chat_theme_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages({required String chatId, int page = 1});
  Future<Either<Failure, dynamic>> sendMessage({
    required String chatId,
    required String message,
  });
  Future<Either<Failure, dynamic>> sendMessageWithFile({
    required String chatId,
    required String messageType,
    ChatAttachment? file,
  });
  Future<Either<Failure, dynamic>> sendReaction({
    required String messageId,
    required String react,
  });
  Future<Either<Failure, List<MemberEntity>>> getMembers({required String chatId, int page = 1});
  Future<Either<Failure, List<RadioEntity>>> getRadios();
  Future<Either<Failure, List<ChatThemeEntity>>> getThemes();
  Future<Either<Failure, dynamic>> createGeneralChat({
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  });
  Future<Either<Failure, dynamic>> updateGeneralChat({
    required String chatId,
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  });
  Future<Either<Failure, dynamic>> deleteChat({required String chatId});
  Future<Either<Failure, dynamic>> acceptMemberToChat({
    required String chatId,
    required String userId,
  });
  Future<Either<Failure, dynamic>> blockOrUnBlock({
    required int status,
    required String userId,
  });
  Future<Either<Failure, dynamic>> createChatFriend({required int friendId});
}
