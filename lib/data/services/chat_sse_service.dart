import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/user_profile_service.dart';

/// Service for handling Server-Sent Events (SSE) streaming chat responses
class ChatSSEService {
  static const String _baseUrl = 'http://35.187.235.34';
  static const String _streamEndpoint = '/api/v1/chat/stream';
  
  StreamController<String>? _streamController;
  http.Client? _httpClient;
  StreamSubscription? _streamSubscription;
  
  /// Stream of chat response chunks
  Stream<String> get responseStream => 
      _streamController?.stream ?? const Stream.empty();
  
  /// Send message and get streaming response
  Future<Stream<String>> sendMessageWithStream(String message) async {
    try {
      // Cancel any existing stream
      await closeStream();
      
      // Create new stream controller
      _streamController = StreamController<String>.broadcast();
      _httpClient = http.Client();
      
      // Get access token
      final accessToken = UserProfileService.getAccessToken();
      
      // Build request URL with query parameters
      final uri = Uri.parse('$_baseUrl$_streamEndpoint').replace(
        queryParameters: {
          'message': message,
        },
      );
      
      debugPrint('🌊 Starting SSE stream: $uri');
      
      // Create request with headers
      final request = http.Request('GET', uri)
        ..headers.addAll({
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        });
      
      // Send request and get streaming response
      final response = await _httpClient!.send(request);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to connect to stream: ${response.statusCode}');
      }
      
      // Process the stream
      _streamSubscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          _processSSELine(line);
        },
        onError: (error) {
          debugPrint('❌ SSE stream error: $error');
          _streamController?.addError(error);
        },
        onDone: () {
          debugPrint('✅ SSE stream completed');
          _streamController?.close();
        },
        cancelOnError: false,
      );
      
      return _streamController!.stream;
      
    } catch (e) {
      debugPrint('❌ Failed to start SSE stream: $e');
      _streamController?.addError(e);
      rethrow;
    }
  }
  
  /// Process SSE line data
  void _processSSELine(String line) {
    // SSE format: "data: {content}"
    if (line.startsWith('data: ')) {
      final data = line.substring(6); // Remove "data: " prefix
      
      if (data.trim().isEmpty || data == '[DONE]') {
        // Stream completed
        debugPrint('🏁 SSE stream end signal received');
        _streamController?.close();
        return;
      }
      
      try {
        // Try to parse as JSON first
        final json = jsonDecode(data);
        
        // Extract content from JSON response
        String content = '';
        if (json is Map) {
          // Handle different possible response formats
          content = json['content'] ?? 
                   json['message'] ?? 
                   json['text'] ?? 
                   json['delta'] ?? 
                   data;
        } else {
          content = data;
        }
        
        if (content.isNotEmpty) {
          _streamController?.add(content);
          debugPrint('📝 SSE chunk: $content');
        }
        
      } catch (e) {
        // If not JSON, treat as plain text
        if (data.isNotEmpty) {
          _streamController?.add(data);
          debugPrint('📝 SSE text: $data');
        }
      }
    } else if (line.startsWith('event: ')) {
      // Handle SSE events
      final event = line.substring(7);
      debugPrint('📢 SSE event: $event');
    } else if (line.startsWith(':')) {
      // SSE comment (heartbeat)
      debugPrint('💓 SSE heartbeat');
    }
  }
  
  /// Close the stream and clean up resources
  Future<void> closeStream() async {
    await _streamSubscription?.cancel();
    await _streamController?.close();
    _httpClient?.close();
    
    _streamSubscription = null;
    _streamController = null;
    _httpClient = null;
    
    debugPrint('🔚 SSE stream closed');
  }
  
  /// Dispose of all resources
  Future<void> dispose() async {
    await closeStream();
  }
}