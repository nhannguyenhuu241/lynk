/// Socket event types enum
enum SocketEventType {
  // Connection events
  connect,
  disconnect,
  connecting,
  connectError,
  connectTimeout,
  reconnect,
  reconnectAttempt,
  reconnectError,
  reconnectFailed,
  
  // Message events
  newMessage,
  messageDelivered,
  messageRead,
  messageDeleted,
  messageEdited,
  
  // Typing events
  userTyping,
  userStoppedTyping,
  
  // Online status events
  userOnline,
  userOffline,
  userStatusChanged,
  
  // Room events
  joinRoom,
  leaveRoom,
  roomCreated,
  roomDeleted,
  
  // Error events
  error,
  authError,
}

/// Socket event class for handling different event types
class SocketEvent {
  final SocketEventType type;
  final dynamic data;
  final DateTime timestamp;
  final String? error;

  SocketEvent({
    required this.type,
    this.data,
    DateTime? timestamp,
    this.error,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SocketEvent.fromJson(Map<String, dynamic> json) {
    return SocketEvent(
      type: _parseEventType(json['type']),
      data: json['data'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
    };
  }

  static SocketEventType _parseEventType(String? type) {
    if (type == null) return SocketEventType.error;
    
    try {
      return SocketEventType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
        orElse: () => SocketEventType.error,
      );
    } catch (_) {
      return SocketEventType.error;
    }
  }
}