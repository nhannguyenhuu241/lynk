import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/chat_repository.dart';
import '../model/request/chat_request.dart';
import '../model/response/chat_response.dart' as api_response;
import '../model/response/auth_response.dart';
import '../model/websocket/websocket_message.dart';
import 'websocket/chat_websocket_service.dart';
import 'chat_sse_service.dart';

/// Unified chat service that combines REST API, WebSocket, and SSE functionality
class ChatService {
  final ChatRepository _chatRepository;
  final ChatWebSocketService _webSocketService;
  final ChatSSEService _sseService;
  
  // Cache current user info
  AuthResponse? _currentUser;
  
  // Stream controllers
  final _incomingMessagesController = StreamController<ChatMessage>.broadcast();
  final _typingIndicatorController = StreamController<TypingIndicator>.broadcast();
  
  // Public streams
  Stream<ChatMessage> get incomingMessages => _incomingMessagesController.stream;
  Stream<TypingIndicator> get typingIndicators => _typingIndicatorController.stream;
  Stream<bool> get connectionState => _webSocketService.connectionState;
  
  bool get isConnected => _webSocketService.isConnected;
  
  ChatService({
    ChatRepository? chatRepository,
    ChatWebSocketService? webSocketService,
    ChatSSEService? sseService,
  })  : _chatRepository = chatRepository ?? ChatRepository(),
        _webSocketService = webSocketService ?? ChatWebSocketService(),
        _sseService = sseService ?? ChatSSEService() {
    _setupWebSocketListeners();
  }
  
  /// Initialize chat service with user credentials
  Future<void> initialize(AuthResponse authResponse) async {
    _currentUser = authResponse;
    
    if (authResponse.userId != null && authResponse.accessToken != null) {
      await _webSocketService.connect(
        userId: authResponse.userId!,
        accessToken: authResponse.accessToken!,
      );
    } else {
      throw Exception('Invalid user credentials for chat initialization');
    }
  }
  
  /// Setup WebSocket message listeners
  void _setupWebSocketListeners() {
    _webSocketService.messages.listen((message) {
      switch (message.type) {
        case 'message':
          final chatMessage = ChatMessage.fromWebSocketMessage(message);
          _incomingMessagesController.add(chatMessage);
          break;
        case 'typing':
          final typingIndicator = TypingIndicator.fromWebSocketMessage(message);
          _typingIndicatorController.add(typingIndicator);
          break;
        case 'chat_response':
          // Handle chat response from server
          final chatResponse = ChatResponse.fromWebSocketMessage(message);
          // Create a ChatMessage from the response to display
          final chatMessage = ChatMessage(
            content: chatResponse.reply,
            senderId: chatResponse.senderId ?? 'bot',
            metadata: chatResponse.metadata,
            timestamp: chatResponse.timestamp,
          );
          _incomingMessagesController.add(chatMessage);
          break;
        case 'error':
          debugPrint('WebSocket error: ${message.data}');
          break;
        case 'auth_error':
          debugPrint('Authentication error detected: ${message.data}');
          // TODO: Handle re-authentication flow
          break;
        default:
          debugPrint('Unknown message type: ${message.type}');
      }
    });
  }
  
  /// Send a message through WebSocket
  Future<api_response.ChatResponse> sendMessage(String message, {String? conversationId}) async {
    try {
      // Send directly through WebSocket
      if (_webSocketService.isConnected) {
        _webSocketService.sendChatMessage(message);
        
        // Return a success response for compatibility
        return api_response.ChatResponse(
          reply: 'sent', // Reply will come through WebSocket listener
          status: 'success',
          sessionId: _currentUser?.sessionId,
        );
      } else {
        // If WebSocket is not connected, fall back to REST API
        final response = await _chatRepository.sendMessage(
          ChatRequest(
            message: message,
            conversationId: conversationId,
          ),
        );
        return response;
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }
  
  /// Send message with streaming response via SSE
  Future<Stream<String>> sendMessageWithStream(String message) async {
    try {
      // First send via WebSocket using the correct format
      if (_webSocketService.isConnected) {
        _webSocketService.sendChatMessage(message);
      }
      
      // Then get streaming response via SSE
      final stream = await _sseService.sendMessageWithStream(message);
      
      // Process the stream and also forward to WebSocket for history
      final processedStream = stream.map((chunk) {
        // Optionally notify WebSocket about received chunks
        if (_webSocketService.isConnected) {
          _webSocketService.sendMessage({
            'type': 'bot_response_chunk',
            'data': {
              'content': chunk,
              'timestamp': DateTime.now().toIso8601String(),
            },
          });
        }
        return chunk;
      });
      
      return processedStream;
    } catch (e) {
      debugPrint('Error sending message with stream: $e');
      rethrow;
    }
  }
  
  /// Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (_webSocketService.isConnected) {
      _webSocketService.sendTypingIndicator(isTyping);
    }
  }
  
  /// Reconnect WebSocket
  Future<void> reconnect() async {
    if (_currentUser != null && 
        _currentUser!.userId != null && 
        _currentUser!.accessToken != null) {
      await _webSocketService.connect(
        userId: _currentUser!.userId!,
        accessToken: _currentUser!.accessToken!,
      );
    }
  }
  
  /// Update authentication token
  Future<void> updateAuthToken(String newToken) async {
    if (_currentUser != null) {
      _currentUser = AuthResponse(
        accessToken: newToken,
        tokenType: _currentUser!.tokenType,
        userId: _currentUser!.userId,
        sessionId: _currentUser!.sessionId,
        phoneNumber: _currentUser!.phoneNumber,
        deviceId: _currentUser!.deviceId,
        name: _currentUser!.name,
      );
      await _webSocketService.updateAuthToken(newToken);
    }
  }
  
  /// Disconnect from chat
  Future<void> disconnect() async {
    await _webSocketService.disconnect();
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    await _incomingMessagesController.close();
    await _typingIndicatorController.close();
    await _webSocketService.dispose();
    await _sseService.dispose();
  }
}