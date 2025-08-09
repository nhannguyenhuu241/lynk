import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../model/websocket/websocket_message.dart';

class ChatWebSocketService {
  static const String _baseUrl = '35.187.235.34';
  static const String _path = '/api/v1/ws/chat';
  
  WebSocketChannel? _channel;
  StreamController<WebSocketMessage>? _messageController;
  StreamController<bool>? _connectionController;
  
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  
  String? _userId;
  String? _accessToken;
  
  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  
  // Public streams
  Stream<WebSocketMessage> get messages => 
      _messageController?.stream ?? const Stream.empty();
  Stream<bool> get connectionState => 
      _connectionController?.stream ?? const Stream.empty();
  
  bool get isConnected => _isConnected;
  
  ChatWebSocketService() {
    _messageController = StreamController<WebSocketMessage>.broadcast();
    _connectionController = StreamController<bool>.broadcast();
  }
  
  /// Connect to WebSocket with user credentials
  Future<void> connect({
    required String userId,
    required String accessToken,
  }) async {
    try {
      _userId = userId;
      _accessToken = accessToken;
      _shouldReconnect = true;
      _reconnectAttempts = 0;
      
      await _connectWebSocket();
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _handleConnectionError();
    }
  }
  
  /// Internal connection method
  Future<void> _connectWebSocket() async {
    try {
      if (_channel != null) {
        await disconnect(shouldReconnect: false);
      }
      
      final uri = Uri(
        scheme: 'ws',
        host: _baseUrl,
        path: _path,
        queryParameters: {'token': _accessToken},
      );
      
      debugPrint('Connecting to WebSocket: $uri');
      debugPrint('🔑 Token being used: ${_accessToken?.substring(0, 20)}...');
      
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );
      
      _isConnected = true;
      _connectionController?.add(true);
      _reconnectAttempts = 0;
      
      _startHeartbeat();
      
      debugPrint('WebSocket connected successfully');
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      _handleConnectionError();
      rethrow;
    }
  }
  
  /// Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      debugPrint('WebSocket received: $data');
      
      final Map<String, dynamic> json = jsonDecode(data);
      final message = WebSocketMessage.fromJson(json);
      
      _messageController?.add(message);
      
      // Handle specific message types
      switch (message.type) {
        case 'pong':
          debugPrint('Received pong');
          break;
        case 'error':
          debugPrint('Server error: ${message.data}');
          // Check if it's an authentication error
          if (json['message'] == 'Unauthorized' || json['message'] == 'Token expired') {
            debugPrint('⚠️ WebSocket authentication failed - token may be expired');
            _handleAuthenticationError();
          }
          break;
        case 'chat_response':
          // Handle chat response from server
          debugPrint('Received chat response: ${message.data}');
          break;
        default:
          // Handle other message types
          break;
      }
    } catch (e) {
      debugPrint('Error parsing WebSocket message: $e');
    }
  }
  
  /// Handle WebSocket errors
  void _handleError(error) {
    debugPrint('WebSocket error: $error');
    _handleConnectionError();
  }
  
  /// Handle WebSocket connection closed
  void _handleDone() {
    debugPrint('WebSocket connection closed');
    _handleConnectionError();
  }
  
  /// Handle authentication errors
  void _handleAuthenticationError() {
    debugPrint('🔐 Handling authentication error');
    _isConnected = false;
    _connectionController?.add(false);
    _stopHeartbeat();
    
    // Notify listeners about auth error
    _messageController?.add(WebSocketMessage(
      type: 'auth_error',
      data: {'message': 'Authentication failed. Please login again.'},
    ));
    
    // Don't attempt reconnection for auth errors
    _shouldReconnect = false;
  }
  
  /// Handle connection errors and attempt reconnection
  void _handleConnectionError() {
    _isConnected = false;
    _connectionController?.add(false);
    _stopHeartbeat();
    
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      debugPrint('Attempting reconnection $_reconnectAttempts/$_maxReconnectAttempts');
      
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(_reconnectDelay, () {
        if (_shouldReconnect && _userId != null && _accessToken != null) {
          _connectWebSocket();
        }
      });
    } else if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnection attempts reached');
    }
  }
  
  /// Send message through WebSocket
  void sendMessage(Map<String, dynamic> data) {
    if (!_isConnected || _channel == null) {
      debugPrint('Cannot send message: WebSocket not connected');
      return;
    }
    
    try {
      final message = jsonEncode(data);
      _channel!.sink.add(message);
      debugPrint('WebSocket sent: $message');
    } catch (e) {
      debugPrint('Error sending WebSocket message: $e');
    }
  }
  
  /// Send chat message
  void sendChatMessage(String message, {Map<String, dynamic>? metadata}) {
    // Send message in the format expected by server: {"message": "content"}
    sendMessage({
      'message': message,
    });
  }
  
  /// Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    sendMessage({
      'type': 'typing',
      'data': {
        'isTyping': isTyping,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }
  
  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        sendMessage({'type': 'ping'});
      }
    });
  }
  
  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
  
  /// Disconnect from WebSocket
  Future<void> disconnect({bool shouldReconnect = false}) async {
    _shouldReconnect = shouldReconnect;
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    
    if (_channel != null) {
      await _channel!.sink.close(status.normalClosure);
      _channel = null;
    }
    
    _isConnected = false;
    _connectionController?.add(false);
    
    debugPrint('WebSocket disconnected');
  }
  
  /// Update authentication token and reconnect
  Future<void> updateAuthToken(String newToken) async {
    _accessToken = newToken;
    if (_isConnected && _userId != null) {
      await disconnect(shouldReconnect: true);
    }
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    await _messageController?.close();
    await _connectionController?.close();
  }
}