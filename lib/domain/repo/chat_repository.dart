import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/firestore_service.dart';

class ChatMessage {
  final String id;
  final String userId;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      userId: map['userId'] ?? '',
      message: map['message'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: DateTime.parse(map['timestamp']),
      metadata: map['metadata'],
    );
  }
}

class ChatRepository {
  final FirestoreService _firestoreService = FirestoreService();
  static const String _collection = 'chat_messages';
  static const String _userCollection = 'users';

  Future<void> sendMessage({
    required String userId,
    required String message,
    required bool isUser,
    Map<String, dynamic>? metadata,
  }) async {
    final data = ChatMessage(
      id: '',
      userId: userId,
      message: message,
      isUser: isUser,
      timestamp: DateTime.now(),
      metadata: metadata,
    ).toMap();

    await _firestoreService.createDocument(
      collection: _collection,
      data: data,
    );
  }

  Stream<List<ChatMessage>> getChatMessages(String userId, {int limit = 50}) {
    return _firestoreService
        .streamDocuments(
          collection: _collection,
          query: _firestoreService
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .limit(limit),
        )
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<List<ChatMessage>> getChatHistory(String userId, {int limit = 50}) async {
    final snapshot = await _firestoreService.getDocuments(
      collection: _collection,
      query: _firestoreService
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit),
    );

    return snapshot.docs.map((doc) {
      return ChatMessage.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> deleteMessage(String messageId) async {
    await _firestoreService.deleteDocument(
      collection: _collection,
      documentId: messageId,
    );
  }

  Future<void> clearChatHistory(String userId) async {
    final batch = _firestoreService.batch();
    final messages = await getChatHistory(userId, limit: 1000);
    
    for (final message in messages) {
      batch.delete(
        _firestoreService.collection(_collection).doc(message.id),
      );
    }
    
    await batch.commit();
  }

  Future<void> createOrUpdateUser({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    await _firestoreService.createDocument(
      collection: _userCollection,
      documentId: userId,
      data: {
        ...userData,
        'lastUpdated': FieldValue.serverTimestamp(),
      },
    );
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _firestoreService.streamDocument(
      collection: _userCollection,
      documentId: userId,
    );
  }
}