class RadioEntity {
  final int id;
  final String radioUrl;
  final String name;

  const RadioEntity({
    required this.id,
    required this.radioUrl,
    required this.name,
  });

  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'radio_url':
      case 'url':
        return radioUrl;
      case 'name':
        return name;
      default:
        return null;
    }
  }
}
