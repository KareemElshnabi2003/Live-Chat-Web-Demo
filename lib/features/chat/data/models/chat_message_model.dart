import 'package:live_chat/features/chat/data/models/message_model.dart';

class ChatMessage {
  final String message;
  final bool isFromSender;
  final String timestamp;
  final String? imageUrl;
  final String? senderName;
  final String messageId;
  final List<MessageReactions> reaction;
  final String messageType;
  final bool isPending;

  ChatMessage({
    required this.senderName,
    required this.message,
    required this.isFromSender,
    required this.timestamp,
    required this.imageUrl,
    required this.reaction,
    required this.messageId,
    required this.messageType,
    required this.isPending,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final senderId = json['sender_id']?.toString() ?? json['senderId']?.toString() ?? '';
    final isMe = currentUserId != null && currentUserId.isNotEmpty && senderId == currentUserId;

    List<MessageReactions> reactions = [];
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

    return ChatMessage(
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

  factory ChatMessage.fromModel(MessageModel model, {String? currentUserId}) {
    final senderId = model.senderId?.toString() ?? '';
    final isMe = currentUserId != null && currentUserId.isNotEmpty && senderId == currentUserId;

    return ChatMessage(
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

  ChatMessage copyWith({
    String? message,
    bool? isFromSender,
    String? timestamp,
    String? imageUrl,
    String? senderName,
    String? messageId,
    List<MessageReactions>? reaction,
    String? messageType,
    bool? isPending,
  }) {
    return ChatMessage(
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

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isFromSender': isFromSender,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'senderName': senderName,
      'messageId': messageId,
      'reaction': reaction.map((r) => r.toJson()).toList(),
      'messageType': messageType,
      'isPending': isPending,
    };
  }
}