import '../../domain/entities/chat_theme_entity.dart';

class ChatThemeModel extends ChatThemeEntity {
  const ChatThemeModel({
    required super.id,
    required super.theme,
  });

  factory ChatThemeModel.fromJson(Map<String, dynamic> json) {
    return ChatThemeModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      theme: (json['theme'] ?? json['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theme': theme,
    };
  }

  ChatThemeEntity toEntity() => this;
}
