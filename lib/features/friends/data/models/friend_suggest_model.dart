import 'package:live_chat/features/market/data/models/power_model.dart';
import '../../domain/entities/friend_suggest_entity.dart';

class SuggestFreindModel extends FriendSuggestEntity {
  const SuggestFreindModel({
    super.id,
    super.name,
    super.username,
    super.image,
    super.requestStatus,
    super.power,
  });

  factory SuggestFreindModel.fromJson(Map<String, dynamic> json) {
    return SuggestFreindModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      image: json['image'],
      requestStatus: json['request_status'],
      power: json['power'] != null ? PowerModel.fromJson(json['power']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['username'] = username;
    data['image'] = image;
    data['request_status'] = requestStatus;
    if (power != null && power is PowerModel) {
      data['power'] = (power as PowerModel).toJson();
    }
    return data;
  }
}
