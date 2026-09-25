import 'package:live_chat/features/chat/domain/entities/chat_message_entity.dart';
import 'package:live_chat/features/chat/domain/entities/user_chat_entity.dart';

class UserChatModel extends UserChatEntity {
  @override
  User? get user => super.user as User?;

  @override
  List<ChatAdmins>? get chatAdmins => super.chatAdmins?.cast<ChatAdmins>();

  @override
  ThemeId? get themeId => super.themeId as ThemeId?;

  @override
  LastMessage? get lastMessage => super.lastMessage as LastMessage?;

  UserChatModel({
    super.id,
    super.isBlocked,
    super.name,
    super.image,
    super.lastMessage,
    super.unreadCount,
    super.slug,
    super.status,
    super.accept,
    super.chatLink,
    super.user,
    super.chatAdmins,
    super.themeId,
    super.userTheme,
    super.membersCount,
    super.messagesCount,
    super.createdAt,
    super.adLink,
    super.adTitle,
    super.adImage,
    super.updatedAt,
    super.messages,
  });

  UserChatModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'],
          isBlocked: json['is_blocked'],
          adLink: json['ad_link'],
          adTitle: json['ad_title'],
          adImage: json['ad_image'],
          name: json['name'],
          image: json['image'],
          slug: json['slug'],
          status: json['status']?.toString(),
          accept: json['accept']?.toString(),
          lastMessage: json['last_message'] != null
              ? LastMessage.fromJson(json['last_message'])
              : null,
          unreadCount: json['unread_count'],
          chatLink: json['chat_link'],
          user: json['user'] != null ? User.fromJson(json['user']) : null,
          chatAdmins: json['chat_admins'] != null
              ? (json['chat_admins'] as List)
                  .map((v) => ChatAdmins.fromJson(v))
                  .toList()
              : null,
          themeId: json['theme'] != null ? ThemeId.fromJson(json['theme']) : null,
          userTheme: json['user_theme'],
          membersCount: json['members_count'],
          messagesCount: json['messages_count'],
          createdAt: json['created_at'],
          updatedAt: json['updated_at'],
        );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['slug'] = slug;
    data['status'] = status;
    data['accept'] = accept;
    data['is_blocked'] = isBlocked;
    data['chat_link'] = chatLink;
    if (lastMessage != null) {
      data['last_message'] = lastMessage!.toJson();
    }
    data['unread_count'] = unreadCount;
    data['ad_link'] = adLink;
    data['ad_title'] = adTitle;
    data['ad_image'] = adImage;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (chatAdmins != null) {
      data['chat_admins'] = chatAdmins!.map((v) => v.toJson()).toList();
    }
    if (themeId != null) {
      data['theme'] = themeId!.toJson();
    }
    data['user_theme'] = userTheme;
    data['members_count'] = membersCount;
    data['messages_count'] = messagesCount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class User extends MessageReactionUserEntity {
  String? email;
  String? phone;
  String? gender;
  String? age;
  int? countryId;
  String? countryName;
  int? numberOfStars;

  User({
    super.id,
    super.name,
    super.username,
    this.email,
    this.phone,
    super.image,
    this.gender,
    this.age,
    this.countryId,
    this.countryName,
    this.numberOfStars,
  });

  User.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        phone = json['phone'],
        gender = json['gender'],
        age = json['age'],
        countryId = json['country_id'],
        countryName = json['country_name'],
        numberOfStars = json['number_of_stars'],
        super(
          id: json['id'],
          name: json['name'],
          username: json['username'],
          image: json['image'],
        );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['email'] = email;
    data['phone'] = phone;
    data['image'] = image;
    data['gender'] = gender;
    data['age'] = age;
    data['country_id'] = countryId;
    data['country_name'] = countryName;
    data['number_of_stars'] = numberOfStars;
    return data;
  }
}

class ChatAdmins {
  String? chatAdminId;

  ChatAdmins({this.chatAdminId});

  ChatAdmins.fromJson(Map<String, dynamic> json) {
    chatAdminId = json['chat_admin_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['chat_admin_id'] = chatAdminId;
    return data;
  }
}

class ThemeId {
  int? id;
  String? theme;

  ThemeId({this.id, this.theme});

  ThemeId.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    theme = json['theme'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['theme'] = theme;
    return data;
  }
}

class LastMessage {
  int? id;
  int? conversationId;
  int? senderId;
  String? senderName;
  String? senderImage;
  String? message;
  String? messageType;
  String? createdAt;

  LastMessage({
    this.id,
    this.conversationId,
    this.senderId,
    this.senderName,
    this.senderImage,
    this.message,
    this.messageType,
    this.createdAt,
  });

  LastMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderId = json['sender_id'];
    senderName = json['sender_name'];
    senderImage = json['sender_image'];
    message = json['message'];
    messageType = json['message_type'];
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
    data['created_at'] = createdAt;
    return data;
  }
}
