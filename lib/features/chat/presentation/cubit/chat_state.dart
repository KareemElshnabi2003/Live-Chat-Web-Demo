abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<dynamic> messages;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final int currentPage;
  final List<dynamic> radios;
  final bool isRadioPlaying;
  final String? currentRadioUrl;

  ChatLoaded({
    this.messages = const [],
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
    this.currentPage = 1,
    this.radios = const [],
    this.isRadioPlaying = false,
    this.currentRadioUrl,
  });

  ChatLoaded copyWith({
    List<dynamic>? messages,
    bool? isLoadingMore,
    bool? hasMoreMessages,
    int? currentPage,
    List<dynamic>? radios,
    bool? isRadioPlaying,
    String? currentRadioUrl,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      currentPage: currentPage ?? this.currentPage,
      radios: radios ?? this.radios,
      isRadioPlaying: isRadioPlaying ?? this.isRadioPlaying,
      currentRadioUrl: currentRadioUrl ?? this.currentRadioUrl,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  ChatError({required this.message});
}
