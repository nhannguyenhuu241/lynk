import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      if (documentId != null) {
        await _firestore.collection(collection).doc(documentId).set(data);
      } else {
        await _firestore.collection(collection).add(data);
      }
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  Future<QuerySnapshot> getDocuments({
    required String collection,
    Query<Map<String, dynamic>>? query,
  }) async {
    try {
      if (query != null) {
        return await query.get();
      }
      return await _firestore.collection(collection).get();
    } catch (e) {
      throw Exception('Failed to get documents: $e');
    }
  }

  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  Stream<QuerySnapshot> streamDocuments({
    required String collection,
    Query<Map<String, dynamic>>? query,
  }) {
    if (query != null) {
      return query.snapshots();
    }
    return _firestore.collection(collection).snapshots();
  }

  Stream<DocumentSnapshot> streamDocument({
    required String collection,
    required String documentId,
  }) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  WriteBatch batch() {
    return _firestore.batch();
  }

  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler,
  ) async {
    return _firestore.runTransaction(transactionHandler);
  }

  Future<Map<String, String>> getApiKeys() async {
    try {
      final keyChat = _firestore.collection('key-chat');
      
      final chatGptDoc = await keyChat.doc('chatgpt').get();
      final geminiDoc = await keyChat.doc('gemini').get();
      
      final chatGptKey = chatGptDoc.exists ? (chatGptDoc.data()?['key'] as String? ?? '') : '';
      final geminiKey = geminiDoc.exists ? (geminiDoc.data()?['key'] as String? ?? '') : '';
      
      return {
        'chatgpt': chatGptKey,
        'gemini': geminiKey,
      };
    } catch (e) {
      print('Error fetching API keys: $e');
      return {
        'chatgpt': '',
        'gemini': '',
      };
    }
  }
}