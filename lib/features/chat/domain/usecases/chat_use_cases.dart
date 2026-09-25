import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;
  GetMessagesUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call({required String chatId, int page = 1}) {
    return repository.getMessages(chatId: chatId, page: page);
  }
}

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<Either<String, dynamic>> call({required String chatId, required String message}) {
    return repository.sendMessage(chatId: chatId, message: message);
  }
}

class SendMessageWithFileUseCase {
  final ChatRepository repository;
  SendMessageWithFileUseCase(this.repository);

  Future<Either<String, dynamic>> call({
    required String chatId,
    required String messageType,
    MultipartFile? file,
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

  Future<Either<String, dynamic>> call({required String messageId, required String react}) {
    return repository.sendReaction(messageId: messageId, react: react);
  }
}

class GetMembersUseCase {
  final ChatRepository repository;
  GetMembersUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call({required String chatId, int page = 1}) {
    return repository.getMembers(chatId: chatId, page: page);
  }
}

class GetRadiosUseCase {
  final ChatRepository repository;
  GetRadiosUseCase(this.repository);

  Future<Either<String, List<dynamic>>> call() {
    return repository.getRadios();
  }
}
