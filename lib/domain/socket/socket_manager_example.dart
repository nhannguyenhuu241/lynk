/// Example usage of SocketManager
/// This file demonstrates how to integrate SocketManager in your Flutter app

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lynk_an/domain/socket/socket_manager.dart';
import 'package:lynk_an/domain/socket/models/socket_message.dart';
import 'package:lynk_an/domain/socket/models/typing_indicator.dart';
import 'package:lynk_an/domain/socket/models/online_status.dart';

class SocketManagerExample extends StatefulWidget {
  const SocketManagerExample({Key? key}) : super(key: key);

  @override
  State<SocketManagerExample> createState() => _SocketManagerExampleState();
}

class _SocketManagerExampleState extends State<SocketManagerExample> {
  final SocketManager _socketManager = SocketManager();
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _setupListeners();
  }

  /// Initialize socket connection
  Future<void> _initializeSocket() async {
    try {
      // Get auth token from your authentication service
      final authToken = 'your-auth-token-here';
      final userId = 'current-user-id';
      
      // Initialize socket manager
      await _socketManager.initialize(
        userId: userId,
        authToken: authToken,
        environment: 'staging', // or 'production' for live environment
      );
    } catch (e) {
      debugPrint('Failed to initialize socket: $e');
    }
  }

  /// Setup event listeners
  void _setupListeners() {
    // Listen to connection state changes
    _subscriptions.add(
      _socketManager.connectionState.listen((isConnected) {
        debugPrint('Socket connection state: $isConnected');
        
        if (isConnected) {
          // Update user online status when connected
          _socketManager.updateOnlineStatus(true, status: 'available');
        }
      }),
    );

    // Listen to incoming messages
    _subscriptions.add(
      _socketManager.messages.listen((message) {
        _handleNewMessage(message);
      }),
    );

    // Listen to typing indicators
    _subscriptions.add(
      _socketManager.typingIndicators.listen((typing) {
        _handleTypingIndicator(typing);
      }),
    );

    // Listen to online status updates
    _subscriptions.add(
      _socketManager.onlineStatuses.listen((status) {
        _handleOnlineStatus(status);
      }),
    );

    // Listen to errors
    _subscriptions.add(
      _socketManager.errors.listen((error) {
        _handleError(error);
      }),
    );
  }

  /// Handle incoming messages
  void _handleNewMessage(SocketMessage message) {
    debugPrint('New message from ${message.senderId}: ${message.content}');
    
    // Mark message as delivered
    _socketManager.markMessageDelivered(message.id);
    
    // Update your UI or local database
    setState(() {
      // Add message to your message list
    });
    
    // If message is visible to user, mark as read
    if (true) { // Replace with actual visibility check
      _socketManager.markMessageRead(message.id);
    }
  }

  /// Handle typing indicators
  void _handleTypingIndicator(TypingIndicator typing) {
    debugPrint('User ${typing.userId} is ${typing.isTyping ? "typing" : "stopped typing"}');
    
    // Update your UI to show/hide typing indicator
    setState(() {
      // Update typing status in UI
    });
  }

  /// Handle online status updates
  void _handleOnlineStatus(OnlineStatus status) {
    debugPrint('User ${status.userId} is ${status.isOnline ? "online" : "offline"}');
    
    // Update your UI to show online/offline status
    setState(() {
      // Update user status in UI
    });
  }

  /// Handle errors
  void _handleError(String error) {
    debugPrint('Socket error: $error');
    
    // Show error to user if needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connection error: $error')),
    );
  }

  /// Send a message
  Future<void> sendMessage(String recipientId, String content) async {
    final message = SocketMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _socketManager.currentUserId ?? '',
      recipientId: recipientId,
      content: content,
      type: 'text',
      timestamp: DateTime.now(),
    );

    await _socketManager.sendMessage(message);
  }

  /// Send typing indicator
  void sendTypingIndicator(String recipientId, bool isTyping) {
    _socketManager.sendTypingIndicator(recipientId, isTyping);
  }

  /// Join a chat room
  void joinChatRoom(String roomId) {
    _socketManager.joinRoom(roomId);
  }

  /// Leave a chat room
  void leaveChatRoom(String roomId) {
    _socketManager.leaveRoom(roomId);
  }

  /// Update authentication token (e.g., after token refresh)
  Future<void> updateAuthToken(String newToken) async {
    await _socketManager.updateAuthToken(newToken);
  }

  @override
  void dispose() {
    // Update offline status before disposing
    _socketManager.updateOnlineStatus(false);
    
    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    
    // Dispose socket manager
    _socketManager.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket Manager Example'),
      ),
      body: StreamBuilder<bool>(
        stream: _socketManager.connectionState,
        builder: (context, snapshot) {
          final isConnected = snapshot.data ?? false;
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isConnected ? Icons.cloud_done : Icons.cloud_off,
                  size: 64,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => sendMessage('recipient-id', 'Hello!'),
                  child: const Text('Send Test Message'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Example integration in a chat screen
class ChatScreenIntegration {
  final SocketManager _socketManager = SocketManager();
  final TextEditingController _messageController = TextEditingController();
  Timer? _typingTimer;
  bool _isTyping = false;
  final String recipientId = 'recipient-user-id';

  /// Initialize in initState
  void initialize() {
    // Listen to text changes for typing indicator
    _messageController.addListener(_onTextChanged);
  }

  /// Handle text changes for typing indicator
  void _onTextChanged() {
    if (_messageController.text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _socketManager.sendTypingIndicator(recipientId, true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        _socketManager.sendTypingIndicator(recipientId, false);
      }
    });
  }

  /// Send message
  Future<void> sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Stop typing indicator
    _typingTimer?.cancel();
    if (_isTyping) {
      _isTyping = false;
      _socketManager.sendTypingIndicator(recipientId, false);
    }

    // Send message
    final message = SocketMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _socketManager.currentUserId ?? '',
      recipientId: recipientId,
      content: content,
      type: 'text',
      timestamp: DateTime.now(),
    );

    await _socketManager.sendMessage(message);
    _messageController.clear();
  }

  /// Dispose
  void dispose() {
    _typingTimer?.cancel();
    _messageController.dispose();
  }
}