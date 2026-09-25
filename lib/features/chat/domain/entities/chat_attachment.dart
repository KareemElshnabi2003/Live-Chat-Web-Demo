class ChatAttachment {
  final List<int> bytes;
  final String filename;

  const ChatAttachment({
    required this.bytes,
    required this.filename,
  });
}
