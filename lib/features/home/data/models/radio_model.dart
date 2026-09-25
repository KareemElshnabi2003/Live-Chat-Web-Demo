import 'package:live_chat/features/chat/domain/entities/radio_entity.dart';

class RadioModel extends RadioEntity {
  const RadioModel({
    required super.id,
    required super.radioUrl,
    required super.name,
  });

  factory RadioModel.fromJson(Map<String, dynamic> json) {
    return RadioModel(
      name: json['name']?.toString() ?? '',
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      radioUrl: (json['radio_url'] ?? json['url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'radio_url': radioUrl,
      'name': name,
    };
  }

  RadioEntity toEntity() => this;

  @override
  String toString() {
    return 'RadioModel{id: $id, radioUrl: $radioUrl, name: $name}';
  }
}
