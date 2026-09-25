import 'package:live_chat/features/chat/domain/entities/member_entity.dart';
import 'package:live_chat/features/market/data/models/power_model.dart';

class MemberOfChatModel extends MemberEntity {
  final PowerModel? power;

  const MemberOfChatModel({
    super.id,
    super.username,
    super.name,
    super.image,
    super.isGuest,
    super.memberStatus,
    super.requestStatus,
    super.isAdmin,
    this.power,
  });

  factory MemberOfChatModel.fromJson(Map<String, dynamic> json) {
    return MemberOfChatModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '')),
      username: json['username']?.toString(),
      name: json['name']?.toString() ?? json['username']?.toString(),
      image: json['image']?.toString(),
      isGuest: json['is_guest'] == true || json['is_guest'] == 1,
      memberStatus: json['member_status']?.toString(),
      requestStatus: json['request_status']?.toString(),
      isAdmin: json['is_admin'] is int ? json['is_admin'] : (int.tryParse(json['is_admin']?.toString() ?? '')),
      power: json['power'] != null
          ? PowerModel.fromJson(json['power'] is Map<String, dynamic>
              ? json['power']
              : Map<String, dynamic>.from(json['power']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['name'] = name;
    data['image'] = image;
    data['is_guest'] = isGuest;
    data['member_status'] = memberStatus;
    data['request_status'] = requestStatus;
    data['is_admin'] = isAdmin;
    if (power != null) {
      data['power'] = power!.toJson();
    }
    return data;
  }

  MemberEntity toEntity() => this;
}
