import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import '../entities/chat_attachment.dart';
import '../entities/chat_message_entity.dart';
import '../entities/member_entity.dart';
import '../entities/radio_entity.dart';
import '../entities/chat_theme_entity.dart';
import '../entities/user_chat_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages({required String chatId, int page = 1});
  Future<Either<Failure, Unit>> sendMessage({
    required String chatId,
    required String message,
  });
  Future<Either<Failure, Unit>> sendMessageWithFile({
    required String chatId,
    required String messageType,
    ChatAttachment? file,
  });
  Future<Either<Failure, Unit>> sendReaction({
    required String messageId,
    required String react,
  });
  Future<Either<Failure, List<MemberEntity>>> getMembers({required String chatId, int page = 1});
  Future<Either<Failure, List<RadioEntity>>> getRadios();
  Future<Either<Failure, List<ChatThemeEntity>>> getThemes();
  Future<Either<Failure, Unit>> createGeneralChat({
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  });
  Future<Either<Failure, Unit>> updateGeneralChat({
    required String chatId,
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  });
  Future<Either<Failure, Unit>> deleteChat({required String chatId});
  Future<Either<Failure, Unit>> acceptMemberToChat({
    required String chatId,
    required String userId,
  });
  Future<Either<Failure, Unit>> blockOrUnBlock({
    required int status,
    required String userId,
  });
  Future<Either<Failure, UserChatEntity>> createChatFriend({required int friendId});
}
