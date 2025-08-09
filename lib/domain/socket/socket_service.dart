import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_preferences_manager.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:rxdart/rxdart.dart';

import 'models/online_status.dart';
import 'models/socket_event.dart';
import 'models/socket_message.dart';
import 'models/typing_indicator.dart';
import 'socket_manager.dart';

/// Socket Service for integrating SocketManager with the app
class SocketService {
  final SocketManager _socketManager = SocketManager();
  final SharedPreferencesManager _prefsManager;
  
  // Subjects for broadcasting events with caching
  final _messagesSubject = ReplaySubject<SocketMessage>(maxSize: 100);
  final _typingSubject = BehaviorSubject<Map<String, TypingIndicator>>.seeded({});
  final _onlineStatusSubject = BehaviorSubject<Map<String, OnlineStatus>>.seeded({});
  final _connectionSubject = BehaviorSubject<bool>.seeded(false);
  
  // Subscriptions
  final List<StreamSubscription> _subscriptions = [];
  
  // Cache for tracking states
  final Map<String, TypingIndicator> _typingCache = {};
  final Map<String, OnlineStatus> _onlineStatusCache = {};
  
  SocketService({SharedPreferencesManager? prefsManager}) 
      : _prefsManager = prefsManager ?? SharedPreferencesManager();

  // Public streams
  Stream<SocketMessage> get messages => _messagesSubject.stream;
  Stream<Map<String, TypingIndicator>> get typingIndicators => _typingSubject.stream;
  Stream<Map<String, OnlineStatus>> get onlineStatuses => _onlineStatusSubject.stream;
  Stream<bool> get connectionState => _connectionSubject.stream;
  Stream<SocketEvent> get socketEvents => _socketManager.socketEvents;
  Stream<String> get errors => _socketManager.errors;

  // Getters
  bool get isConnected => _socketManager.isConnected;
  String? get currentUserId => _socketManager.currentUserId;

  /// Initialize socket service
  Future<void> initialize() async {
    try {
      // Get user data from shared preferences
      final userId = await _prefsManager.getString(KeySharePreferences.keyUserId);
      final authToken = await _prefsManager.getString(KeySharePreferences.keyAuthToken);
      final environment = await _getEnvironment();

      if (userId == null || authToken == null) {
        throw Exception('User not authenticated');
      }

      // Initialize socket manager
      await _socketManager.initialize(
        userId: userId,
        authToken: authToken,
        environment: environment,
      );

      // Setup listeners
      _setupListeners();
      
      debugPrint('Socket service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize socket service: $e');
      rethrow;
    }
  }

  /// Get current environment
  Future<String> _getEnvironment() async {
    // You can get this from your config or shared preferences
    // For now, defaulting to staging
    return 'staging';
  }

  /// Setup event listeners
  void _setupListeners() {
    // Connection state
    _subscriptions.add(
      _socketManager.connectionState.listen((isConnected) {
        _connectionSubject.add(isConnected);
        
        if (isConnected) {
          // Set user as online when connected
          _socketManager.updateOnlineStatus(true, status: 'available');
        }
      }),
    );

    // Messages
    _subscriptions.add(
      _socketManager.messages.listen((message) {
        _messagesSubject.add(message);
        
        // Auto-mark as delivered
        _socketManager.markMessageDelivered(message.id);
      }),
    );

    // Typing indicators
    _subscriptions.add(
      _socketManager.typingIndicators.listen((typing) {
        if (typing.isTyping) {
          _typingCache[typing.userId] = typing;
        } else {
          _typingCache.remove(typing.userId);
        }
        _typingSubject.add(Map.from(_typingCache));
        
        // Auto-remove typing indicator after timeout
        if (typing.isTyping) {
          Future.delayed(const Duration(seconds: 5), () {
            if (_typingCache[typing.userId]?.timestamp == typing.timestamp) {
              _typingCache.remove(typing.userId);
              _typingSubject.add(Map.from(_typingCache));
            }
          });
        }
      }),
    );

    // Online status
    _subscriptions.add(
      _socketManager.onlineStatuses.listen((status) {
        _onlineStatusCache[status.userId] = status;
        _onlineStatusSubject.add(Map.from(_onlineStatusCache));
      }),
    );
  }

  /// Send a text message
  Future<void> sendTextMessage({
    required String recipientId,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final message = SocketMessage(
      id: _generateMessageId(),
      senderId: currentUserId ?? '',
      recipientId: recipientId,
      content: content,
      type: 'text',
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    await _socketManager.sendMessage(message);
  }

  /// Send an image message
  Future<void> sendImageMessage({
    required String recipientId,
    required String imageUrl,
    String? caption,
    Map<String, dynamic>? metadata,
  }) async {
    final messageMetadata = {
      'imageUrl': imageUrl,
      'caption': caption,
      ...?metadata,
    };

    final message = SocketMessage(
      id: _generateMessageId(),
      senderId: currentUserId ?? '',
      recipientId: recipientId,
      content: caption ?? '',
      type: 'image',
      timestamp: DateTime.now(),
      metadata: messageMetadata,
    );

    await _socketManager.sendMessage(message);
  }

  /// Send a file message
  Future<void> sendFileMessage({
    required String recipientId,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    String? mimeType,
    Map<String, dynamic>? metadata,
  }) async {
    final messageMetadata = {
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      ...?metadata,
    };

    final message = SocketMessage(
      id: _generateMessageId(),
      senderId: currentUserId ?? '',
      recipientId: recipientId,
      content: fileName,
      type: 'file',
      timestamp: DateTime.now(),
      metadata: messageMetadata,
    );

    await _socketManager.sendMessage(message);
  }

  /// Send typing indicator with debounce
  Timer? _typingDebounce;
  void sendTypingIndicator(String recipientId, bool isTyping) {
    _typingDebounce?.cancel();
    
    if (isTyping) {
      _socketManager.sendTypingIndicator(recipientId, true);
      
      // Auto-stop typing after 3 seconds
      _typingDebounce = Timer(const Duration(seconds: 3), () {
        _socketManager.sendTypingIndicator(recipientId, false);
      });
    } else {
      _socketManager.sendTypingIndicator(recipientId, false);
    }
  }

  /// Join a chat room
  void joinRoom(String roomId) {
    _socketManager.joinRoom(roomId);
  }

  /// Leave a chat room
  void leaveRoom(String roomId) {
    _socketManager.leaveRoom(roomId);
  }

  /// Mark message as read
  void markMessageAsRead(String messageId) {
    _socketManager.markMessageRead(messageId);
  }

  /// Mark multiple messages as read
  void markMessagesAsRead(List<String> messageIds) {
    for (final messageId in messageIds) {
      _socketManager.markMessageRead(messageId);
    }
  }

  /// Update user online status
  void updateOnlineStatus(bool isOnline, {String? status}) {
    _socketManager.updateOnlineStatus(isOnline, status: status);
  }

  /// Get online status for a user
  OnlineStatus? getOnlineStatus(String userId) {
    return _onlineStatusCache[userId];
  }

  /// Check if a user is typing
  bool isUserTyping(String userId) {
    return _typingCache.containsKey(userId);
  }

  /// Clear all caches
  void clearCache() {
    _typingCache.clear();
    _onlineStatusCache.clear();
    _typingSubject.add({});
    _onlineStatusSubject.add({});
  }

  /// Reconnect socket
  Future<void> reconnect() async {
    await _socketManager.disconnect();
    await _socketManager.connect();
  }

  /// Update authentication token
  Future<void> updateAuthToken(String newToken) async {
    await _prefsManager.setString(KeySharePreferences.keyAuthToken, newToken);
    await _socketManager.updateAuthToken(newToken);
  }

  /// Generate unique message ID
  String _generateMessageId() {
    return '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Dispose resources
  Future<void> dispose() async {
    _typingDebounce?.cancel();
    
    // Set user as offline before disposing
    _socketManager.updateOnlineStatus(false);
    
    // Cancel subscriptions
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    
    // Close subjects
    await _messagesSubject.close();
    await _typingSubject.close();
    await _onlineStatusSubject.close();
    await _connectionSubject.close();
    
    // Dispose socket manager
    await _socketManager.dispose();
    
    // Clear caches
    clearCache();
  }
}