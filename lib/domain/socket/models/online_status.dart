/// Online status model for real-time user presence
class OnlineStatus {
  final String userId;
  final bool isOnline;
  final DateTime lastSeen;
  final String? status; // available, busy, away, etc.

  OnlineStatus({
    required this.userId,
    required this.isOnline,
    required this.lastSeen,
    this.status,
  });

  factory OnlineStatus.fromJson(Map<String, dynamic> json) {
    return OnlineStatus(
      userId: json['userId'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : DateTime.now(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'status': status,
    };
  }
}