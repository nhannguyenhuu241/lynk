import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import '../../../common/globals.dart';
import '../../ai/ai_prompts_loader.dart';

class OpenaiApiService {
  static const String apiUrl = "https://api.openai.com/v1/chat/completions";
  
  static String get apiKey {
    final key = Globals.getChatGPTKey();
    if (key.isEmpty) {
      debugPrint("❌ OpenAI API Key is EMPTY!");
      debugPrint("Please check if the API key was fetched from Firestore during app startup");
    } else {
      debugPrint("✅ OpenAI API Key is SET: ${key.substring(0, min(5, key.length))}...");
    }
    return key;
  }

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }

  static Future<String> _getSystemPrompt(String language) async {
    return await AiPromptsLoader.getSystemPrompt(language);
  }

  static Future<String> _getErrorMessage(String errorType, String language) async {
    return await AiPromptsLoader.getErrorMessage(errorType, language);
  }

  // Main text response method
  static Future<String> getResponse(String prompt, {String language = 'vi'}) async {
    // Check if API key is available
    if (apiKey.isEmpty) {
      debugPrint("❌ Cannot call OpenAI API: API key is empty");
      throw Exception('OpenAI API key not configured. Please check your internet connection and restart the app.');
    }
    
    try {
      final systemPrompt = await _getSystemPrompt(language);
      
      final response = await _createDio().post(
        '',
        data: {
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt}
          ],
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'].toString();
      } else {
        return "${await _getErrorMessage('api_error', language)}: ${response.statusMessage}";
      }
    } on DioException catch (e) {
      debugPrint("OpenAI API DioException: ${e.message}");
      debugPrint("OpenAI API Status Code: ${e.response?.statusCode}");
      debugPrint("OpenAI API Response: ${e.response?.data}");
      
      // Check for specific error codes
      if (e.response?.statusCode == 401) {
        throw Exception("OpenAI API Key invalid (401)");
      } else if (e.response?.statusCode == 500) {
        throw Exception("OpenAI server error (500)");
      }
      
      throw e; // Re-throw the exception
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw e; // Re-throw the exception
    }
  }

  // Method with location support
  static Future<String> getResponseWithLocation({
    required String prompt,
    String? userLocation,
    String language = 'vi',
  }) async {
    String enhancedPrompt = prompt;
    if (userLocation != null && userLocation.isNotEmpty) {
      enhancedPrompt = '$prompt\n\nVị trí hiện tại của tôi: $userLocation';
    }
    return await getResponse(enhancedPrompt, language: language);
  }

  // Method with image analysis
  static Future<String> getResponseWithImage({
    required String prompt,
    required File imageFile,
    String language = 'vi',
    String? detail = "auto",
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final extension = path.extension(imageFile.path).toLowerCase();
      final mimeType = _getMimeType(extension);

      final systemPrompt = await _getSystemPrompt(language);
      
      final response = await _createDio().post(
        '',
        data: {
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mimeType;base64,$base64Image',
                    'detail': detail,
                  },
                },
              ],
            },
          ],
          'max_tokens': 1000,
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'].toString();
      } else {
        return "${await _getErrorMessage('api_error', language)}: ${response.statusMessage}";
      }
    } on DioException catch (e) {
      debugPrint("OpenAI Image API DioException: ${e.message}");
      debugPrint("OpenAI Image API Status Code: ${e.response?.statusCode}");
      
      if (e.response?.statusCode == 401) {
        throw Exception("OpenAI API Key invalid (401)");
      } else if (e.response?.statusCode == 500) {
        throw Exception("OpenAI server error (500)");
      }
      
      throw e;
    } catch (e) {
      debugPrint("Image analysis error: $e");
      throw e;
    }
  }

  // Helper method to get MIME type
  static String _getMimeType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}