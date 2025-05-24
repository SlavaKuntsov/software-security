class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  // Проверка, является ли сообщение локально созданным
  bool get isLocalMessage => id.contains('_local');

  // Метод для определения, является ли сообщение фактически тем же самым сообщением
  // что и другое (для предотвращения дублирования)
  bool isSameMessageAs(ChatMessage other) {
    // Если ID полностью совпадают - это точно одно и то же сообщение
    if (id == other.id) return true;
    
    // Если одно из сообщений локальное, а контент и временные метки похожи
    if ((isLocalMessage || other.isLocalMessage) && 
        senderId == other.senderId && 
        receiverId == other.receiverId &&
        content == other.content &&
        (timestamp.difference(other.timestamp).inSeconds.abs() < 10)) {
      return true;
    }
    
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && isSameMessageAs(other);
  }

  @override
  int get hashCode => id.hashCode;
} 