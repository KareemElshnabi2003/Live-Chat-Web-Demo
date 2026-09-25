import 'package:live_chat/features/chat/domain/entities/user_chat_entity.dart';

class PinChatEntity {
  final int? id;
  final int? conversationId;
  final int? numberOfStars;
  final int? hasAd;
  final String? adTitle;
  final String? adLink;
  final String? adImage;
  final int? status;
  final String? pinDate;
  final UserChatEntity? conversation;

  const PinChatEntity({
    this.id,
    this.conversationId,
    this.numberOfStars,
    this.hasAd,
    this.adTitle,
    this.adLink,
    this.adImage,
    this.status,
    this.pinDate,
    this.conversation,
  });
}
