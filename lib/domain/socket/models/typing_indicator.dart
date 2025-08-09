/// Typing indicator model for real-time typing status
class TypingIndicator {
  final String userId;
  final String recipientId;
  final bool isTyping;
  final DateTime timestamp;

  TypingIndicator({
    required this.userId,
    required this.recipientId,
    required this.isTyping,
    required this.timestamp,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      userId: json['userId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      isTyping: json['isTyping'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'recipientId': recipientId,
      'isTyping': isTyping,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}