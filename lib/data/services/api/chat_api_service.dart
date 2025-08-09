import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'base_api_service.dart';
import '../../model/response/chat_response.dart';
import '../../local/shared_prefs/shared_prefs_key.dart';
import '../../../common/globals.dart';

class ChatApiService {
  static const String _chatEndpoint = '/api/v1/chat';

  static Future<ChatResponse> sendMessage({
    required String message,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? context,
  }) async {
    try {
      debugPrint('\n══════════════════════════════════════════════════════');
      debugPrint('📨 CHAT API REQUEST');
      debugPrint('Message: $message');
      debugPrint('══════════════════════════════════════════════════════\n');

      // Simple request format as specified
      final requestData = {
        'message': message,
      };

      final response = await BaseApiService.dio.post(
        _chatEndpoint,
        data: requestData,
      );

      // Parse response to ChatResponse model
      final chatResponse = ChatResponse.fromJson(response.data);

      debugPrint('\n══════════════════════════════════════════════════════');
      debugPrint('✅ CHAT API RESPONSE SUCCESS');
      debugPrint('Full Response: ${response.data}');
      debugPrint('Reply: ${chatResponse.reply}');
      debugPrint('Status: ${chatResponse.status}');
      debugPrint('Session ID: ${chatResponse.sessionId}');
      debugPrint('══════════════════════════════════════════════════════\n');

      // Save session ID if present
      if (chatResponse.sessionId != null) {
        await Globals.prefs.setString(SharedPrefsKey.sessionId, chatResponse.sessionId!);
        debugPrint('💾 Session ID saved: ${chatResponse.sessionId}');
      }

      return chatResponse;
    } on DioException catch (e) {
      debugPrint('\n══════════════════════════════════════════════════════');
      debugPrint('❌ CHAT API ERROR');
      debugPrint('Error: ${e.message}');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('══════════════════════════════════════════════════════\n');
      
      // Re-throw to allow fallback to OpenAI
      throw e;
    } catch (e) {
      debugPrint('Unexpected error in chat API: $e');
      throw e;
    }
  }

  static Future<ChatResponse> sendChatWithHistory({
    required String message,
    required List<Map<String, String>> chatHistory,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? userContext,
  }) async {
    try {
      // Simple request format - just message
      final requestData = {
        'message': message,
      };

      final response = await BaseApiService.dio.post(
        _chatEndpoint,
        data: requestData,
      );

      // Parse response to ChatResponse model
      final chatResponse = ChatResponse.fromJson(response.data);

      debugPrint('\n══════════════════════════════════════════════════════');
      debugPrint('✅ CHAT API WITH HISTORY RESPONSE');
      debugPrint('Reply: ${chatResponse.reply}');
      debugPrint('Status: ${chatResponse.status}');
      debugPrint('Session ID: ${chatResponse.sessionId}');
      debugPrint('══════════════════════════════════════════════════════\n');

      // Save session ID if present
      if (chatResponse.sessionId != null) {
        await Globals.prefs.setString(SharedPrefsKey.sessionId, chatResponse.sessionId!);
      }

      return chatResponse;
    } catch (e) {
      debugPrint('Chat API error with history: $e');
      throw e;
    }
  }
}