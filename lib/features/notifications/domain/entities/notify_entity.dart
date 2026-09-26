class NotifyEntity {
  final int? id;
  final String? title;
  final String? content;
  final String? date;
  final Map<String, dynamic>? additionalData;

  const NotifyEntity({
    this.id,
    this.title,
    this.content,
    this.date,
    this.additionalData,
  });
}
