class WebSocketMessage {
  final String type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] ?? 'unknown',
      data: json['data'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (data != null) 'data': data,
        'timestamp': timestamp.toIso8601String(),
      };
}

// Specific message types
class ChatMessage extends WebSocketMessage {
  final String content;
  final String? senderId;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.content,
    this.senderId,
    this.metadata,
    DateTime? timestamp,
  }) : super(
          type: 'message',
          data: {
            'content': content,
            if (senderId != null) 'senderId': senderId,
            if (metadata != null) 'metadata': metadata,
          },
          timestamp: timestamp,
        );

  factory ChatMessage.fromWebSocketMessage(WebSocketMessage message) {
    final data = message.data ?? {};
    return ChatMessage(
      content: data['content'] ?? '',
      senderId: data['senderId'],
      metadata: data['metadata'],
      timestamp: message.timestamp,
    );
  }
}

class TypingIndicator extends WebSocketMessage {
  final String userId;
  final bool isTyping;

  TypingIndicator({
    required this.userId,
    required this.isTyping,
    DateTime? timestamp,
  }) : super(
          type: 'typing',
          data: {
            'userId': userId,
            'isTyping': isTyping,
          },
          timestamp: timestamp,
        );

  factory TypingIndicator.fromWebSocketMessage(WebSocketMessage message) {
    final data = message.data ?? {};
    return TypingIndicator(
      userId: data['userId'] ?? '',
      isTyping: data['isTyping'] ?? false,
      timestamp: message.timestamp,
    );
  }
}

class ChatResponse extends WebSocketMessage {
  final String reply;
  final String? senderId;
  final Map<String, dynamic>? metadata;

  ChatResponse({
    required this.reply,
    this.senderId,
    this.metadata,
    DateTime? timestamp,
  }) : super(
          type: 'chat_response',
          data: {
            'reply': reply,
            if (senderId != null) 'senderId': senderId,
            if (metadata != null) 'metadata': metadata,
          },
          timestamp: timestamp,
        );

  factory ChatResponse.fromWebSocketMessage(WebSocketMessage message) {
    final data = message.data ?? {};
    return ChatResponse(
      reply: data['reply'] ?? '',
      senderId: data['senderId'],
      metadata: data['metadata'],
      timestamp: message.timestamp,
    );
  }
}