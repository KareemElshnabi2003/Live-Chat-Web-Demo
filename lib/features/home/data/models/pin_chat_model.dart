import 'dart:convert';
import 'package:live_chat/features/chat/data/models/user_chat_model.dart';
import '../../domain/entities/pin_chat_entity.dart';

class PinChatModel extends PinChatEntity {
  List<PinHour>? pinHours;

  @override
  UserChatModel? get conversation => super.conversation as UserChatModel?;

  PinChatModel({
    super.id,
    super.conversationId,
    super.numberOfStars,
    super.hasAd,
    super.adTitle,
    super.adLink,
    super.adImage,
    super.status,
    super.pinDate,
    this.pinHours,
    super.conversation,
  });

  PinChatModel.fromJson(Map<String, dynamic> json)
      : pinHours = _parsePinHours(json['pin_hours']),
        super(
          id: json['id'],
          conversationId: json['conversation_id'],
          numberOfStars: json['number_of_stars'],
          hasAd: json['has_ad'],
          adTitle: json['ad_title'],
          adLink: json['ad_link'],
          adImage: json['ad_image'],
          status: json['status'],
          pinDate: json['pin_date'],
          conversation: json['conversation'] != null
              ? UserChatModel.fromJson(json['conversation'])
              : null,
        );

  static List<PinHour>? _parsePinHours(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) {
      return raw.map((v) => PinHour.fromJson(v)).toList();
    } else if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((v) => PinHour.fromJson(v)).toList();
        }
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['number_of_stars'] = numberOfStars;
    data['has_ad'] = hasAd;
    data['ad_title'] = adTitle;
    data['ad_link'] = adLink;
    data['ad_image'] = adImage;
    data['status'] = status;
    data['pin_date'] = pinDate;
    if (pinHours != null) {
      data['pin_hours'] = pinHours!.map((v) => v.toJson()).toList();
    }
    if (conversation != null) {
      data['conversation'] = conversation!.toJson();
    }
    return data;
  }
}

// 🌟 كلاس جديد مخصص لساعات التثبيت عشان الكود يبقى Clean ويسهل استخدامه
class PinHour {
  int? hour;
  String? period;

  PinHour({this.hour, this.period});

  PinHour.fromJson(Map<String, dynamic> json) {
    hour = json['hour'];
    period = json['period'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hour'] = hour;
    data['period'] = period;
    return data;
  }
}