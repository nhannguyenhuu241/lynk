class OpenaiChatResponseModel {
  final String content;
  final int totalTokens;
  final bool isSuccess;
  final String? error;
  final DateTime timestamp;

  OpenaiChatResponseModel({
    required this.content,
    this.totalTokens = 0,
    this.isSuccess = true,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory OpenaiChatResponseModel.error(String message) {
    return OpenaiChatResponseModel(
      content: '',
      isSuccess: false,
      error: message,
    );
  }

  factory OpenaiChatResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final choice = json['choices'][0];
      final usage = json['usage'];

      return OpenaiChatResponseModel(
        content: choice['message']['content'].toString().trim(),
        totalTokens: usage?['total_tokens'] ?? 0,
      );
    } catch (e) {
      return OpenaiChatResponseModel.error('Failed to parse response: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'totalTokens': totalTokens,
      'isSuccess': isSuccess,
      'error': error,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}