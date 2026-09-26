import 'package:live_chat/features/chat/domain/entities/chat_message_entity.dart';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';

class MessageModel {
  int? id;
  int? conversationId;
  int? senderId;
  String? senderName;
  String? senderImage;
  String? message;
  String? messageType;
  List<MessageReactions>? messageReactions;
  String? createdAt;

  MessageModel({
    this.id,
    this.conversationId,
    this.senderId,
    this.senderName,
    this.senderImage,
    this.message,
    this.messageType,
    this.messageReactions,
    this.createdAt,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderId = json['sender_id'];
    senderName = json['sender_name'];
    senderImage = json['sender_image'];
    message = json['message'];
    messageType = json['message_type'] ?? 'text';
    if (json['message_reactions'] != null) {
      messageReactions = <MessageReactions>[];
      json['message_reactions'].forEach((v) {
        messageReactions!.add(MessageReactions.fromJson(v));
      });
    }
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['sender_id'] = senderId;
    data['sender_name'] = senderName;
    data['sender_image'] = senderImage;
    data['message'] = message;
    data['message_type'] = messageType;
    if (messageReactions != null) {
      data['message_reactions'] =
          messageReactions!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    return data;
  }
}

class MessageReactions extends MessageReactionEntity {
  @override
  User? get user => super.user is User ? super.user as User : null;

  MessageReactions({super.id, super.react, super.user});

  MessageReactions.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'],
          react: json['react'],
          user: json['user'] != null
              ? (json['user'] is Map
                  ? User.fromJson(json['user'] is Map<String, dynamic>
                      ? json['user'] as Map<String, dynamic>
                      : Map<String, dynamic>.from(json['user'] as Map))
                  : null)
              : (json['sender_name'] != null || json['username'] != null || json['name'] != null
                  ? MessageReactionUserEntity(
                      id: json['user_id'] != null ? int.tryParse(json['user_id'].toString()) : null,
                      name: json['name']?.toString() ?? json['sender_name']?.toString() ?? json['username']?.toString(),
                      username: json['username']?.toString() ?? json['sender_name']?.toString() ?? json['name']?.toString(),
                      image: json['image']?.toString() ?? json['sender_image']?.toString(),
                    )
                  : null),
        );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['react'] = react;
    if (user != null) {
      if (user is User) {
        data['user'] = (user as User).toJson();
      } else {
        data['user'] = {
          'id': user!.id,
          'name': user!.name,
          'username': user!.username,
          'image': user!.image,
        };
      }
    }
    return data;
  }
}
