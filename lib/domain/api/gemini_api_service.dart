import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import '../../common/globals.dart';
import '../ai/ai_prompts_loader.dart';

class GeminiApiService {
  static const String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";
  
  static String get apiKey {
    final key = Globals.getGeminiKey();
    debugPrint("Gemini API Key: ${key.isEmpty ? 'EMPTY' : 'SET (${key.substring(0, 5)}...)'} ");
    return key;
  }

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        headers: {'Content-Type': 'application/json'},
        connectTimeout: Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 15),
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
    try {
      final systemPrompt = await _getSystemPrompt(language);
      
      final response = await _createDio().post(
        '$apiUrl?key=$apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': '$systemPrompt\n\nCâu hỏi: $prompt'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1000,
          },
          "tools": [
            {"google_search": {}}
          ]
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['error'] != null) {
          final error = data['error'];
          throw Exception("Gemini API error: ${error['message']}");
        }
        
        final candidates = response.data['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content']['parts'][0]['text'];
          return content.toString();
        }
        return await _getErrorMessage('no_response', language);
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      debugPrint("Gemini API DioException: ${e.message}");
      debugPrint("Gemini API Status Code: ${e.response?.statusCode}");
      debugPrint("Gemini API Response: ${e.response?.data}");
      
      // Check for specific error codes
      if (e.response?.statusCode == 401) {
        throw Exception("Gemini API Key invalid (401)");
      } else if (e.response?.statusCode == 500) {
        throw Exception("Gemini server error (500)");
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
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final extension = path.extension(imageFile.path).toLowerCase();
      final mimeType = _getMimeType(extension);
      
      final systemPrompt = await _getSystemPrompt(language);

      final response = await _createDio().post(
        '$apiUrl?key=$apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': '$systemPrompt\n\nYêu cầu phân tích hình ảnh: $prompt'},
                {
                  'inline_data': {
                    'mime_type': mimeType,
                    'data': base64Image
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1000,
          },
          "tools": [
            {"google_search": {}}
          ]
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['error'] != null) {
          final error = data['error'];
          throw Exception("Gemini API error: ${error['message']}");
        }
        
        final candidates = response.data['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content']['parts'][0]['text'];
          return content.toString();
        }
        return await _getErrorMessage('image_analysis_failed', language);
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      debugPrint("Gemini Image API DioException: ${e.message}");
      debugPrint("Gemini Image API Status Code: ${e.response?.statusCode}");
      
      if (e.response?.statusCode == 401) {
        throw Exception("Gemini API Key invalid (401)");
      } else if (e.response?.statusCode == 500) {
        throw Exception("Gemini server error (500)");
      }
      
      throw e;
    } catch (e) {
      debugPrint("Image analysis error: $e");
      throw e;
    }
  }

  // CV analysis method
  static Future<String> analyzeCVFile({
    required File cvFile,
    required String analysisPrompt,
    String language = 'vi',
  }) async {
    final extension = path.extension(cvFile.path).toLowerCase();
    if (['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension)) {
      return await getResponseWithImage(
        prompt: analysisPrompt,
        imageFile: cvFile,
        language: language,
      );
    } else {
      return await _getErrorMessage('unsupported_format', language);
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