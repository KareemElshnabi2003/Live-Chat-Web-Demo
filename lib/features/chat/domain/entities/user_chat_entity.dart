import 'chat_message_entity.dart';

class UserChatEntity {
  final int? id;
  final String? name;
  final String? image;
  final String? slug;
  final String? status;
  final String? accept;
  final String? chatLink;
  final MessageReactionUserEntity? user;
  final List<dynamic>? chatAdmins;
  final dynamic themeId;
  final String? userTheme;
  final int? membersCount;
  final int? messagesCount;
  final String? createdAt;
  final String? updatedAt;
  final String? adLink;
  final String? adTitle;
  final String? adImage;
  final List<ChatMessageEntity>? messages;
  final dynamic lastMessage;
  final int? unreadCount;
  String? isBlocked;

  UserChatEntity({
    this.id,
    this.name,
    this.image,
    this.slug,
    this.status,
    this.accept,
    this.chatLink,
    this.user,
    this.chatAdmins,
    this.themeId,
    this.userTheme,
    this.membersCount,
    this.messagesCount,
    this.createdAt,
    this.updatedAt,
    this.adLink,
    this.adTitle,
    this.adImage,
    this.messages,
    this.lastMessage,
    this.unreadCount,
    this.isBlocked,
  });
}
