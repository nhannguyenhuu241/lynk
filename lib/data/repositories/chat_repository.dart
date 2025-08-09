import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/api/base_api_service.dart';
import '../model/request/chat_request.dart';
import '../model/response/chat_response.dart';

class ChatRepository {
  static const String _chatEndpoint = '/api/v1/chat';

  Future<ChatResponse> sendMessage(ChatRequest request) async {
    try {
      final response = await BaseApiService.dio.post(
        _chatEndpoint,
        data: request.toJson(),
      );

      return ChatResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Chat error: ${e.message}');
      if (e.response != null) {
        // Try to parse error response
        return ChatResponse(
          error: e.response?.data['error'] ?? 
                 e.response?.data['message'] ?? 
                 'Failed to send message',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error during chat: $e');
      throw Exception('Chat failed: $e');
    }
  }
}