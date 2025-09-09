class MessageItem {
  final String name;
  final String message;
  final String time;
  final String? avatar;
  final int? unreadCount;

  MessageItem({
    required this.name,
    required this.message,
    required this.time,
    this.avatar,
    this.unreadCount,
  });
}