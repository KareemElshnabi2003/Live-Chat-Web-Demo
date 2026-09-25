class MessageReactionUserEntity {
  final int? id;
  final String? username;
  final String? name;
  final String? image;

  const MessageReactionUserEntity({
    this.id,
    this.username,
    this.name,
    this.image,
  });
}

class MessageReactionEntity {
  final int? id;
  final String? react;
  final MessageReactionUserEntity? user;

  const MessageReactionEntity({
    this.id,
    this.react,
    this.user,
  });
}

class ChatMessageEntity {
  final String message;
  final bool isFromSender;
  final String timestamp;
  final String? imageUrl;
  final String? senderName;
  final String messageId;
  final List<MessageReactionEntity> reaction;
  final String messageType;
  final bool isPending;

  const ChatMessageEntity({
    required this.message,
    required this.isFromSender,
    required this.timestamp,
    this.imageUrl,
    this.senderName,
    required this.messageId,
    this.reaction = const [],
    this.messageType = 'text',
    this.isPending = false,
  });

  ChatMessageEntity copyWith({
    String? message,
    bool? isFromSender,
    String? timestamp,
    String? imageUrl,
    String? senderName,
    String? messageId,
    List<MessageReactionEntity>? reaction,
    String? messageType,
    bool? isPending,
  }) {
    return ChatMessageEntity(
      message: message ?? this.message,
      isFromSender: isFromSender ?? this.isFromSender,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      senderName: senderName ?? this.senderName,
      messageId: messageId ?? this.messageId,
      reaction: reaction ?? this.reaction,
      messageType: messageType ?? this.messageType,
      isPending: isPending ?? this.isPending,
    );
  }
}

typedef MessageEntity = ChatMessageEntity;
typedef ChatMessage = ChatMessageEntity;
