class ChatThemeEntity {
  final int id;
  final String theme;

  const ChatThemeEntity({
    required this.id,
    required this.theme,
  });

  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'theme':
      case 'image':
        return theme;
      default:
        return null;
    }
  }
}

typedef ThemeEntity = ChatThemeEntity;
