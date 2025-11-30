class ChatItem {
  int? id;
  String? message;
  int? isUser; // 1 for user, 0 for bot
  String? timestamp;
  String? userId;

  ChatItem({
    this.id,
    this.message,
    this.isUser,
    this.timestamp,
    this.userId,
  });

  Map<String, dynamic> toDb() {
    return {
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp,
      'userId': userId,
    };
  }

  factory ChatItem.fromDb(Map<String, dynamic> map) {
    return ChatItem(
      id: map['id'],
      message: map['message'],
      isUser: map['isUser'],
      timestamp: map['timestamp'],
      userId: map['userId'],
    );
  }
}
