import 'package:live_chat/features/chat/domain/entities/chat_message_entity.dart';
import 'package:live_chat/features/chat/domain/entities/radio_entity.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessageEntity> messages;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final int currentPage;
  final List<RadioEntity> radios;
  final bool isRadioPlaying;
  final String? currentRadioUrl;
  final ChatMessageEntity? replyingToMessage;

  ChatLoaded({
    this.messages = const [],
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
    this.currentPage = 1,
    this.radios = const [],
    this.isRadioPlaying = false,
    this.currentRadioUrl,
    this.replyingToMessage,
  });

  ChatLoaded copyWith({
    List<ChatMessageEntity>? messages,
    bool? isLoadingMore,
    bool? hasMoreMessages,
    int? currentPage,
    List<RadioEntity>? radios,
    bool? isRadioPlaying,
    String? currentRadioUrl,
    ChatMessageEntity? replyingToMessage,
    bool clearReply = false,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      currentPage: currentPage ?? this.currentPage,
      radios: radios ?? this.radios,
      isRadioPlaying: isRadioPlaying ?? this.isRadioPlaying,
      currentRadioUrl: currentRadioUrl ?? this.currentRadioUrl,
      replyingToMessage: clearReply ? null : (replyingToMessage ?? this.replyingToMessage),
    );
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});
}
