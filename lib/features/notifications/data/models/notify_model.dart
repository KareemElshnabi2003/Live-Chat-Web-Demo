import '../../domain/entities/notify_entity.dart';

class NotifyModel extends NotifyEntity {
  const NotifyModel({
    super.id,
    super.title,
    super.content,
    super.date,
    super.additionalData,
  });

  factory NotifyModel.fromJson(Map<String, dynamic> json) {
    int? id;
    String? title;
    String? content;
    String? date;
    Map<String, dynamic>? additionalData;

    try {
      id = json['id'];
      title = json['title'];
      content = json['content'];
      date = json['date'];

      if (json['additional_data'] != null && json['additional_data'] is Map) {
        additionalData = Map<String, dynamic>.from(json['additional_data']);
      }
    } catch (_) {
      id = null;
      title = '';
      content = '';
      date = '';
      additionalData = null;
    }

    return NotifyModel(
      id: id,
      title: title,
      content: content,
      date: date,
      additionalData: additionalData,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['date'] = date;
    data['additional_data'] = additionalData;
    return data;
  }
}
