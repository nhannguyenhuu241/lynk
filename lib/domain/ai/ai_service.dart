import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api/openai/openai_api_service.dart';

class AIService {
  // Main method - only use OpenAI GPT
  static Future<String> getResponse({
    required String prompt,
    String language = 'vi',
    String? userLocation,
    int maxRetries = 2,
  }) async {
    // Try OpenAI GPT with retry
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('Calling OpenAI GPT API (attempt $attempt/$maxRetries)...');
        
        String response;
        if (userLocation != null && userLocation.isNotEmpty) {
          response = await OpenaiApiService.getResponseWithLocation(
            prompt: prompt,
            userLocation: userLocation,
            language: language,
          );
        } else {
          response = await OpenaiApiService.getResponse(
            prompt,
            language: language,
          );
        }
        
        debugPrint('OpenAI GPT successful');
        return response;
        
      } catch (e) {
        debugPrint('OpenAI GPT attempt $attempt failed: $e');
        
        // If it's a server error and we have retries left, wait and retry
        if (attempt < maxRetries && _isRetryableError(e.toString())) {
          debugPrint('Retrying OpenAI GPT in 2 seconds...');
          await Future.delayed(Duration(seconds: 2));
          continue;
        }
        
        // If all retries failed, throw exception
        if (attempt == maxRetries) {
          throw Exception('OpenAI GPT service failed after $maxRetries attempts');
        }
      }
    }
    
    // This should never be reached, but just in case
    throw Exception('OpenAI GPT service failed');
  }
  
  // Method with image support - only use OpenAI GPT
  static Future<String> getResponseWithImage({
    required String prompt,
    required File imageFile,
    String language = 'vi',
  }) async {
    try {
      debugPrint('Calling OpenAI GPT API for image analysis...');
      
      final response = await OpenaiApiService.getResponseWithImage(
        prompt: prompt,
        imageFile: imageFile,
        language: language,
      );
      
      debugPrint('OpenAI image API successful');
      return response;
      
    } catch (e) {
      debugPrint('OpenAI GPT image analysis failed: $e');
      throw Exception('OpenAI GPT service failed for image analysis');
    }
  }
  
  // Method for CV analysis - only use OpenAI GPT
  static Future<String> analyzeCVFile({
    required File cvFile,
    required String analysisPrompt,
    String language = 'vi',
  }) async {
    try {
      debugPrint('Calling OpenAI GPT API for CV analysis...');
      
      // Use OpenAI GPT image analysis for CV
      final response = await OpenaiApiService.getResponseWithImage(
        prompt: analysisPrompt,
        imageFile: cvFile,
        language: language,
      );
      
      debugPrint('OpenAI CV analysis successful');
      return response;
      
    } catch (e) {
      debugPrint('OpenAI GPT CV analysis failed: $e');
      throw Exception('OpenAI GPT service failed for CV analysis');
    }
  }
  
  // Check if error is retryable (server errors, timeouts)
  static bool _isRetryableError(String error) {
    final retryableErrors = [
      'HTTP 500',
      'HTTP 502',
      'HTTP 503', 
      'HTTP 504',
      'internal error',
      'INTERNAL',
      'timeout',
      'connection failed',
      'server error',
    ];
    
    return retryableErrors.any((retryableError) => 
      error.toLowerCase().contains(retryableError.toLowerCase())
    );
  }

  // Check if response indicates an error
  static bool _isErrorResponse(String response) {
    final errorKeywords = [
      'Không thể',
      'Đã xảy ra lỗi',
      'Không thể kết nối',
      'Unable to',
      'An error occurred',
      'Failed to',
      'internal error',
      'retry or report',
      'INTERNAL',
      'HTTP 500',
      'HTTP 429',
      'HTTP 403',
      'HTTP 401',
      'quota exceeded',
      'rate limit',
      '오류가 발생했습니다',
      '연결할 수 없습니다',
    ];
    
    return errorKeywords.any((keyword) => 
      response.toLowerCase().contains(keyword.toLowerCase())
    );
  }
  
  // Get error messages in different languages
  static String _getErrorMessage(String errorType, String language) {
    final messages = {
      'vi': {
        'service_failed': 'Dịch vụ AI không khả dụng. Vui lòng thử lại sau.',
        'image_analysis_failed': 'Không thể phân tích hình ảnh. Vui lòng thử lại.',
        'cv_analysis_failed': 'Không thể phân tích CV. Vui lòng thử lại.',
      },
      'en': {
        'service_failed': 'AI service is unavailable. Please try again later.',
        'image_analysis_failed': 'Unable to analyze image. Please try again.',
        'cv_analysis_failed': 'Unable to analyze CV. Please try again.',
      },
      'ko': {
        'service_failed': 'AI 서비스를 사용할 수 없습니다. 나중에 다시 시도해 주세요.',
        'image_analysis_failed': '이미지를 분석할 수 없습니다. 다시 시도해 주세요.',
        'cv_analysis_failed': '이력서를 분석할 수 없습니다. 다시 시도해 주세요.',
      },
    };
    
    return messages[language]?[errorType] ?? messages['vi']![errorType]!;
  }
}