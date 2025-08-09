class ChatRequest {
  final String message;
  final String? conversationId;
  final Map<String, dynamic>? metadata;

  ChatRequest({
    required this.message,
    this.conversationId,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
        if (metadata != null) 'metadata': metadata,
      };
}