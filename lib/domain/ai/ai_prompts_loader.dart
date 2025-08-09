import 'dart:convert';
import 'package:flutter/services.dart';

class AiPromptsLoader {
  static final Map<String, Map<String, dynamic>> _cache = {};

  static Future<Map<String, dynamic>> loadPrompts(String language) async {
    if (_cache.containsKey(language)) {
      return _cache[language]!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
          'assets/json/ai_prompts/$language.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _cache[language] = jsonData;
      return jsonData;
    } catch (e) {
      // Fallback to Vietnamese if language file not found
      if (language != 'vi') {
        return loadPrompts('vi');
      }
      throw Exception('Failed to load AI prompts: $e');
    }
  }

  static Future<String> getSystemPrompt(String language) async {
    final prompts = await loadPrompts(language);
    return prompts['system_prompt'] ?? '';
  }

  static Future<String> getErrorMessage(String errorType, String language) async {
    final prompts = await loadPrompts(language);
    final errorMessages = prompts['error_messages'] as Map<String, dynamic>?;
    return errorMessages?[errorType] ?? 'An error occurred';
  }

  static Future<String> getPromptTemplate(String promptType, String language) async {
    final prompts = await loadPrompts(language);
    final promptTemplates = prompts['prompts'] as Map<String, dynamic>?;
    return promptTemplates?[promptType] ?? '';
  }
}