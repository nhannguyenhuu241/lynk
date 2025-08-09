class ChatResponse {
  final String? reply;
  final String? status;
  final String? sessionId;
  final String? error;

  ChatResponse({
    this.reply,
    this.status,
    this.sessionId,
    this.error,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
        reply: json['reply'],
        status: json['status'],
        sessionId: json['session_id'],
        error: json['error'],
      );

  bool get isSuccess => reply != null && reply!.isNotEmpty;
  
  bool get isFriendly => status == 'friendly';
  bool get isNeutral => status == 'neutral';
  bool get isHelpful => status == 'helpful';
  
  Map<String, dynamic> toJson() {
    return {
      if (reply != null) 'reply': reply,
      if (status != null) 'status': status,
      if (sessionId != null) 'session_id': sessionId,
      if (error != null) 'error': error,
    };
  }
}