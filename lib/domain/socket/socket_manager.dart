import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'models/online_status.dart';
import 'models/socket_event.dart';
import 'models/socket_message.dart';
import 'models/typing_indicator.dart';
import 'socket_config.dart';

/// Socket Manager Singleton for handling real-time communication
class SocketManager {
  // Private constructor
  SocketManager._privateConstructor();

  // Single instance
  static final SocketManager _instance = SocketManager._privateConstructor();

  // Factory constructor to return the same instance
  factory SocketManager() {
    return _instance;
  }

  // Socket instance
  IO.Socket? _socket;
  
  // Connection state
  bool _isConnected = false;
  String? _currentUserId;
  String? _authToken;
  String _environment = 'staging';
  
  // Retry configuration
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // Stream controllers
  final _connectionStateController = BehaviorSubject<bool>.seeded(false);
  final _socketEventController = PublishSubject<SocketEvent>();
  final _messageController = PublishSubject<SocketMessage>();
  final _typingController = PublishSubject<TypingIndicator>();
  final _onlineStatusController = PublishSubject<OnlineStatus>();
  final _errorController = PublishSubject<String>();

  // Public streams
  Stream<bool> get connectionState => _connectionStateController.stream;
  Stream<SocketEvent> get socketEvents => _socketEventController.stream;
  Stream<SocketMessage> get messages => _messageController.stream;
  Stream<TypingIndicator> get typingIndicators => _typingController.stream;
  Stream<OnlineStatus> get onlineStatuses => _onlineStatusController.stream;
  Stream<String> get errors => _errorController.stream;

  // Getters
  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;

  /// Initialize socket manager with configuration
  Future<void> initialize({
    required String userId,
    required String authToken,
    String environment = 'staging',
  }) async {
    try {
      _currentUserId = userId;
      _authToken = authToken;
      _environment = environment;

      await connect();
    } catch (e) {
      _handleError('Initialization failed: $e');
    }
  }

  /// Connect to socket server
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      debugPrint('Socket already connected');
      return;
    }

    try {
      final socketUrl = SocketConfig.getSocketUrl(_environment);
      final options = SocketConfig.getSocketOptions(_authToken);

      debugPrint('Connecting to socket server: $socketUrl');

      _socket = IO.io(socketUrl, IO.OptionBuilder()
          .setTransports(options['transports'] as List<String>)
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(options['reconnectionDelay'] as int)
          .setReconnectionDelayMax(options['reconnectionDelayMax'] as int)
          .setReconnectionAttempts(options['reconnectionAttempts'] as int)
          .setTimeout(options['timeout'] as int)
          .setQuery(options['query'] as Map<String, dynamic>)
          .setExtraHeaders(options['extraHeaders'] as Map<String, dynamic>)
          .build());

      _setupEventListeners();
      _socket!.connect();
    } catch (e) {
      _handleError('Connection failed: $e');
    }
  }

  /// Disconnect from socket server
  Future<void> disconnect() async {
    try {
      _cancelReconnectTimer();
      
      if (_socket != null) {
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
      }

      _isConnected = false;
      _connectionStateController.add(false);
      
      debugPrint('Socket disconnected');
    } catch (e) {
      _handleError('Disconnect failed: $e');
    }
  }

  /// Setup all socket event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      debugPrint('Socket connected');
      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionStateController.add(true);
      _socketEventController.add(SocketEvent(type: SocketEventType.connect));
      
      // Authenticate after connection
      _authenticate();
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket disconnected');
      _isConnected = false;
      _connectionStateController.add(false);
      _socketEventController.add(SocketEvent(type: SocketEventType.disconnect));
      
      // Attempt reconnection if not manually disconnected
      _attemptReconnect();
    });

    _socket!.onConnectError((error) {
      debugPrint('Socket connection error: $error');
      _socketEventController.add(SocketEvent(
        type: SocketEventType.connectError,
        error: error.toString(),
      ));
      _handleError('Connection error: $error');
    });

    _socket!.onError((error) {
      debugPrint('Socket error: $error');
      _socketEventController.add(SocketEvent(
        type: SocketEventType.error,
        error: error.toString(),
      ));
      _handleError('Socket error: $error');
    });

    // Reconnection events
    _socket!.on(SocketConfig.eventReconnect, (_) {
      debugPrint('Socket reconnected');
      _reconnectAttempts = 0;
      _socketEventController.add(SocketEvent(type: SocketEventType.reconnect));
    });

    _socket!.on(SocketConfig.eventReconnectAttempt, (attemptNumber) {
      debugPrint('Socket reconnection attempt: $attemptNumber');
      _socketEventController.add(SocketEvent(
        type: SocketEventType.reconnectAttempt,
        data: attemptNumber,
      ));
    });

    _socket!.on(SocketConfig.eventReconnectError, (error) {
      debugPrint('Socket reconnection error: $error');
      _socketEventController.add(SocketEvent(
        type: SocketEventType.reconnectError,
        error: error.toString(),
      ));
    });

    _socket!.on(SocketConfig.eventReconnectFailed, (_) {
      debugPrint('Socket reconnection failed');
      _socketEventController.add(SocketEvent(type: SocketEventType.reconnectFailed));
    });

    // Custom events
    _setupCustomEventListeners();
  }

  /// Setup custom event listeners for chat functionality
  void _setupCustomEventListeners() {
    if (_socket == null) return;

    // Authentication events
    _socket!.on(SocketConfig.eventAuthSuccess, (data) {
      debugPrint('Authentication successful');
      _socketEventController.add(SocketEvent(
        type: SocketEventType.connect,
        data: data,
      ));
    });

    _socket!.on(SocketConfig.eventAuthError, (error) {
      debugPrint('Authentication error: $error');
      _socketEventController.add(SocketEvent(
        type: SocketEventType.authError,
        error: error.toString(),
      ));
      _handleError('Authentication failed: $error');
    });

    // Message events
    _socket!.on(SocketConfig.eventNewMessage, (data) {
      debugPrint('New message received: $data');
      try {
        final message = SocketMessage.fromJson(data as Map<String, dynamic>);
        _messageController.add(message);
        _socketEventController.add(SocketEvent(
          type: SocketEventType.newMessage,
          data: message,
        ));
      } catch (e) {
        _handleError('Failed to parse message: $e');
      }
    });

    _socket!.on(SocketConfig.eventMessageDelivered, (data) {
      debugPrint('Message delivered: $data');
      _socketEventController.add(SocketEvent(
        type: SocketEventType.messageDelivered,
        data: data,
      ));
    });

    _socket!.on(SocketConfig.eventMessageRead, (data) {
      debugPrint('Message read: $data');
      _socketEventController.add(SocketEvent(
        type: SocketEventType.messageRead,
        data: data,
      ));
    });

    // Typing events
    _socket!.on(SocketConfig.eventTyping, (data) {
      debugPrint('User typing: $data');
      try {
        final typing = TypingIndicator.fromJson(data as Map<String, dynamic>);
        _typingController.add(typing);
        _socketEventController.add(SocketEvent(
          type: SocketEventType.userTyping,
          data: typing,
        ));
      } catch (e) {
        _handleError('Failed to parse typing indicator: $e');
      }
    });

    _socket!.on(SocketConfig.eventStopTyping, (data) {
      debugPrint('User stopped typing: $data');
      try {
        final typing = TypingIndicator.fromJson(data as Map<String, dynamic>);
        _typingController.add(typing);
        _socketEventController.add(SocketEvent(
          type: SocketEventType.userStoppedTyping,
          data: typing,
        ));
      } catch (e) {
        _handleError('Failed to parse typing indicator: $e');
      }
    });

    // Online status events
    _socket!.on(SocketConfig.eventOnlineStatus, (data) {
      debugPrint('Online status update: $data');
      try {
        final status = OnlineStatus.fromJson(data as Map<String, dynamic>);
        _onlineStatusController.add(status);
        _socketEventController.add(SocketEvent(
          type: status.isOnline 
              ? SocketEventType.userOnline 
              : SocketEventType.userOffline,
          data: status,
        ));
      } catch (e) {
        _handleError('Failed to parse online status: $e');
      }
    });

    _socket!.on(SocketConfig.eventUserJoined, (data) {
      debugPrint('User joined: $data');
      _socketEventController.add(SocketEvent(
        type: SocketEventType.joinRoom,
        data: data,
      ));
    });

    _socket!.on(SocketConfig.eventUserLeft, (data) {
      debugPrint('User left: $data');
      _socketEventController.add(SocketEvent(
        type: SocketEventType.leaveRoom,
        data: data,
      ));
    });
  }

  /// Authenticate with the socket server
  void _authenticate() {
    if (_socket == null || !_socket!.connected) return;

    _socket!.emit(SocketConfig.eventAuthenticate, {
      'userId': _currentUserId,
      'token': _authToken,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send a message
  Future<void> sendMessage(SocketMessage message) async {
    if (!_isConnected) {
      _handleError('Cannot send message: Socket not connected');
      return;
    }

    try {
      _socket!.emit(SocketConfig.eventNewMessage, message.toJson());
      debugPrint('Message sent: ${message.id}');
    } catch (e) {
      _handleError('Failed to send message: $e');
    }
  }

  /// Send typing indicator
  void sendTypingIndicator(String recipientId, bool isTyping) {
    if (!_isConnected) return;

    try {
      final indicator = TypingIndicator(
        userId: _currentUserId ?? '',
        recipientId: recipientId,
        isTyping: isTyping,
        timestamp: DateTime.now(),
      );

      _socket!.emit(
        isTyping ? SocketConfig.eventTyping : SocketConfig.eventStopTyping,
        indicator.toJson(),
      );
    } catch (e) {
      _handleError('Failed to send typing indicator: $e');
    }
  }

  /// Update online status
  void updateOnlineStatus(bool isOnline, {String? status}) {
    if (!_isConnected) return;

    try {
      final onlineStatus = OnlineStatus(
        userId: _currentUserId ?? '',
        isOnline: isOnline,
        lastSeen: DateTime.now(),
        status: status,
      );

      _socket!.emit(SocketConfig.eventOnlineStatus, onlineStatus.toJson());
    } catch (e) {
      _handleError('Failed to update online status: $e');
    }
  }

  /// Join a chat room
  void joinRoom(String roomId) {
    if (!_isConnected) return;

    try {
      _socket!.emit('join_room', {
        'roomId': roomId,
        'userId': _currentUserId,
      });
      debugPrint('Joined room: $roomId');
    } catch (e) {
      _handleError('Failed to join room: $e');
    }
  }

  /// Leave a chat room
  void leaveRoom(String roomId) {
    if (!_isConnected) return;

    try {
      _socket!.emit('leave_room', {
        'roomId': roomId,
        'userId': _currentUserId,
      });
      debugPrint('Left room: $roomId');
    } catch (e) {
      _handleError('Failed to leave room: $e');
    }
  }

  /// Mark message as delivered
  void markMessageDelivered(String messageId) {
    if (!_isConnected) return;

    try {
      _socket!.emit(SocketConfig.eventMessageDelivered, {
        'messageId': messageId,
        'userId': _currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _handleError('Failed to mark message as delivered: $e');
    }
  }

  /// Mark message as read
  void markMessageRead(String messageId) {
    if (!_isConnected) return;

    try {
      _socket!.emit(SocketConfig.eventMessageRead, {
        'messageId': messageId,
        'userId': _currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _handleError('Failed to mark message as read: $e');
    }
  }

  /// Attempt to reconnect
  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _handleError('Max reconnection attempts reached');
      return;
    }

    _cancelReconnectTimer();
    
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      debugPrint('Attempting reconnection... (${_reconnectAttempts}/$_maxReconnectAttempts)');
      connect();
    });
  }

  /// Cancel reconnection timer
  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Handle errors
  void _handleError(String error) {
    debugPrint('Socket error: $error');
    _errorController.add(error);
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await disconnect();
    
    await _connectionStateController.close();
    await _socketEventController.close();
    await _messageController.close();
    await _typingController.close();
    await _onlineStatusController.close();
    await _errorController.close();
  }

  /// Update authentication token (useful for token refresh)
  Future<void> updateAuthToken(String newToken) async {
    _authToken = newToken;
    
    if (_isConnected) {
      // Reconnect with new token
      await disconnect();
      await connect();
    }
  }

  /// Get socket statistics
  Map<String, dynamic> getSocketStats() {
    return {
      'isConnected': _isConnected,
      'currentUserId': _currentUserId,
      'environment': _environment,
      'reconnectAttempts': _reconnectAttempts,
      'socketId': _socket?.id,
    };
  }
}