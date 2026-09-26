import 'package:dartz/dartz.dart';
import 'package:live_chat/core/errors/failures.dart';
import '../entities/chat_attachment.dart';
import '../entities/chat_message_entity.dart';
import '../entities/member_entity.dart';
import '../entities/radio_entity.dart';
import '../entities/chat_theme_entity.dart';
import '../entities/user_chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;
  GetMessagesUseCase(this.repository);

  Future<Either<Failure, List<ChatMessageEntity>>> call({required String chatId, int page = 1}) {
    return repository.getMessages(chatId: chatId, page: page);
  }
}

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required String chatId, required String message}) {
    return repository.sendMessage(chatId: chatId, message: message);
  }
}

class SendMessageWithFileUseCase {
  final ChatRepository repository;
  SendMessageWithFileUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String chatId,
    required String messageType,
    ChatAttachment? file,
  }) {
    return repository.sendMessageWithFile(
      chatId: chatId,
      messageType: messageType,
      file: file,
    );
  }
}

class SendReactionUseCase {
  final ChatRepository repository;
  SendReactionUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required String messageId, required String react}) {
    return repository.sendReaction(messageId: messageId, react: react);
  }
}

class GetMembersUseCase {
  final ChatRepository repository;
  GetMembersUseCase(this.repository);

  Future<Either<Failure, List<MemberEntity>>> call({required String chatId, int page = 1}) {
    return repository.getMembers(chatId: chatId, page: page);
  }
}

class GetRadiosUseCase {
  final ChatRepository repository;
  GetRadiosUseCase(this.repository);

  Future<Either<Failure, List<RadioEntity>>> call() {
    return repository.getRadios();
  }
}

class GetThemesUseCase {
  final ChatRepository repository;
  GetThemesUseCase(this.repository);

  Future<Either<Failure, List<ChatThemeEntity>>> call() {
    return repository.getThemes();
  }
}

class CreateGeneralChatUseCase {
  final ChatRepository repository;
  CreateGeneralChatUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  }) {
    return repository.createGeneralChat(data: data, imgChat: imgChat, bgChat: bgChat);
  }
}

class UpdateGeneralChatUseCase {
  final ChatRepository repository;
  UpdateGeneralChatUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String chatId,
    required Map<String, dynamic> data,
    ChatAttachment? imgChat,
    ChatAttachment? bgChat,
  }) {
    return repository.updateGeneralChat(
      chatId: chatId,
      data: data,
      imgChat: imgChat,
      bgChat: bgChat,
    );
  }
}

class DeleteChatUseCase {
  final ChatRepository repository;
  DeleteChatUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required String chatId}) {
    return repository.deleteChat(chatId: chatId);
  }
}

class AcceptMemberToChatUseCase {
  final ChatRepository repository;
  AcceptMemberToChatUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String chatId,
    required String userId,
  }) {
    return repository.acceptMemberToChat(chatId: chatId, userId: userId);
  }
}

class BlockOrUnBlockUseCase {
  final ChatRepository repository;
  BlockOrUnBlockUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required int status,
    required String userId,
  }) {
    return repository.blockOrUnBlock(status: status, userId: userId);
  }
}

class CreateChatFriendUseCase {
  final ChatRepository repository;
  CreateChatFriendUseCase(this.repository);

  Future<Either<Failure, UserChatEntity>> call({required int friendId}) {
    return repository.createChatFriend(friendId: friendId);
  }
}

class ParsePusherMessageUseCase {
  final ChatRepository repository;
  ParsePusherMessageUseCase(this.repository);

  ChatMessageEntity? call(dynamic rawData) {
    return repository.parsePusherMessage(rawData);
  }
}
