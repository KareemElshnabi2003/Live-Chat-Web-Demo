import 'package:live_chat/features/chat/domain/entities/chat_message_entity.dart';
import 'package:live_chat/features/chat/data/models/message_model.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.message,
    required super.isFromSender,
    required super.timestamp,
    super.imageUrl,
    super.senderName,
    required super.messageId,
    super.reaction,
    super.messageType = 'text',
    super.isPending = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderId = json['sender_id']?.toString() ?? json['senderId']?.toString() ?? '';
    final isMe = currentUserId != null && currentUserId.isNotEmpty && senderId == currentUserId;

    List<MessageReactionEntity> reactions = [];
    if (json['message_reactions'] != null && json['message_reactions'] is List) {
      reactions = (json['message_reactions'] as List)
          .map((v) => MessageReactions.fromJson(
              v is Map<String, dynamic> ? v : Map<String, dynamic>.from(v as Map)))
          .toList();
    } else if (json['reaction'] != null && json['reaction'] is List) {
      reactions = (json['reaction'] as List)
          .map((v) => MessageReactions.fromJson(
              v is Map<String, dynamic> ? v : Map<String, dynamic>.from(v as Map)))
          .toList();
    }

    return ChatMessageModel(
      senderName: json['sender_name']?.toString() ?? json['senderName']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isFromSender: isMe,
      timestamp: json['created_at']?.toString() ?? json['timestamp']?.toString() ?? '',
      imageUrl: json['sender_image']?.toString() ?? json['imageUrl']?.toString(),
      reaction: reactions,
      messageId: json['id']?.toString() ?? json['messageId']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? json['messageType']?.toString() ?? 'text',
      isPending: json['isPending'] == true,
    );
  }

  factory ChatMessageModel.fromModel(MessageModel model, {String? currentUserId}) {
    final senderId = model.senderId?.toString() ?? '';
    final isMe = currentUserId != null && currentUserId.isNotEmpty && senderId == currentUserId;

    return ChatMessageModel(
      senderName: model.senderName ?? '',
      message: model.message ?? '',
      isFromSender: isMe,
      timestamp: model.createdAt ?? '',
      imageUrl: model.senderImage,
      reaction: model.messageReactions ?? [],
      messageId: model.id?.toString() ?? '',
      messageType: model.messageType ?? 'text',
      isPending: false,
    );
  }

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      message: entity.message,
      isFromSender: entity.isFromSender,
      timestamp: entity.timestamp,
      imageUrl: entity.imageUrl,
      senderName: entity.senderName,
      messageId: entity.messageId,
      reaction: entity.reaction,
      messageType: entity.messageType,
      isPending: entity.isPending,
    );
  }

  ChatMessageEntity toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isFromSender': isFromSender,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'senderName': senderName,
      'messageId': messageId,
      'reaction': reaction.map((r) => {
        'id': r.id,
        'react': r.react,
        if (r.user != null)
          'user': {
            'id': r.user!.id,
            'name': r.user!.name,
            'username': r.user!.username,
            'image': r.user!.image,
          },
      }).toList(),
      'messageType': messageType,
      'isPending': isPending,
    };
  }
}
