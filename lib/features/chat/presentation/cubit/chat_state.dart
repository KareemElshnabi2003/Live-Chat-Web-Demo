import 'package:live_chat/features/chat/data/models/chat_message_model.dart';
import 'package:live_chat/features/home/data/models/radio_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final int currentPage;
  final List<RadioModel> radios;
  final bool isRadioPlaying;
  final String? currentRadioUrl;
  final ChatMessage? replyingToMessage;

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
    List<ChatMessage>? messages,
    bool? isLoadingMore,
    bool? hasMoreMessages,
    int? currentPage,
    List<RadioModel>? radios,
    bool? isRadioPlaying,
    String? currentRadioUrl,
    ChatMessage? replyingToMessage,
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
