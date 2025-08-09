import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/domain/api/openai/openai_api_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/globals.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';

class CVChatMessage {
  final String sender;
  final String text;
  final DateTime timestamp;
  final String? messageType;

  CVChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.messageType,
  });

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'messageType': messageType,
  };

  factory CVChatMessage.fromJson(Map<String, dynamic> json) => CVChatMessage(
    sender: json['sender'],
    text: json['text'],
    timestamp: DateTime.parse(json['timestamp']),
    messageType: json['messageType'],
  );
}

class CVChatBloc {
  late BuildContext context;
  late ProfileModel model;

  CVChatBloc(this.context, this.model) {
    _initializeLanguage();
  }

  Timer? autoResetTimer;
  String? _fullResponse;
  int _currentResponseIndex = 0;

  bool _isAnalyzingCV = false;
  File? _analyzedFile;
  String _currentLanguage = 'vi'; // Default to Vietnamese
  
  // Chat history
  final List<CVChatMessage> _chatHistory = [];

  final streamLynkState = BehaviorSubject<LynkState>.seeded(LynkState.idle);
  final streamBotAlignment = BehaviorSubject<Alignment>.seeded(const Alignment(0.0, -0.5));
  final streamCurrentBotMessage = BehaviorSubject<Map<String, String>?>();
  final streamIsBotReplying = BehaviorSubject<bool>.seeded(false);
  final streamReplyLayout = BehaviorSubject<BotReplyLayout>.seeded(BotReplyLayout.medium);
  final streamSuggestedQuestions = BehaviorSubject<List<String>>.seeded([]);
  final streamNeedFilePicker = BehaviorSubject<bool>.seeded(false);
  final streamChatHistory = BehaviorSubject<List<CVChatMessage>>.seeded([]);
  final streamShowChatHistory = BehaviorSubject<bool>.seeded(false);

  List<String> get _cvQuestions => [
    AppLocalizations.text(LangKey.cv_question_strengths),
    AppLocalizations.text(LangKey.cv_question_improve),
    AppLocalizations.text(LangKey.cv_question_position),
    AppLocalizations.text(LangKey.cv_question_experience),
    AppLocalizations.text(LangKey.cv_question_skills_missing),
    AppLocalizations.text(LangKey.cv_question_layout),
    AppLocalizations.text(LangKey.cv_question_impression),
    AppLocalizations.text(LangKey.cv_question_salary)
  ];

  void _initializeLanguage() {
    final savedLanguage = Globals.prefs.getString(SharedPrefsKey.language);
    
    // Map language key to language code
    if (savedLanguage == LangKey.langVi) {
      _currentLanguage = 'vi';
    } else if (savedLanguage == LangKey.langEn) {
      _currentLanguage = 'en';
    } else if (savedLanguage == LangKey.langKo) {
      _currentLanguage = 'ko';
    }
    // Default is already 'vi' if no saved language
    
    print('🌐 CVChatBloc initialized with language: $_currentLanguage (from $savedLanguage)');
  }

  void dispose() {
    autoResetTimer?.cancel();
    streamLynkState.close();
    streamBotAlignment.close();
    streamCurrentBotMessage.close();
    streamIsBotReplying.close();
    streamReplyLayout.close();
    streamSuggestedQuestions.close();
    streamNeedFilePicker.close();
    streamChatHistory.close();
    streamShowChatHistory.close();
  }

  void triggerFilePicker() {
    streamNeedFilePicker.add(true);
    Future.delayed(const Duration(milliseconds: 100), () {
      streamNeedFilePicker.add(false);
    });
  }

  void initialBotWelcome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      String welcomeText = AppLocalizations.text(LangKey.cv_welcome_message).replaceAll('{name}', model.name);

      streamCurrentBotMessage.add({
        'sender': 'bot',
        'text': welcomeText,
        'isTruncated': 'false'
      });
      streamLynkState.add(LynkState.welcoming);
      streamBotAlignment.add(const Alignment(0.0, -0.5));
      
      // Add welcome message to history
      _addToChatHistory('bot', welcomeText, 'welcome');

      // After 2 seconds, ask for CV
      Future.delayed(const Duration(seconds: 2), () {
        streamCurrentBotMessage.add({
          'sender': 'bot',
          'text': AppLocalizations.text(LangKey.cv_show_cv_request),
          'isTruncated': 'false'
        });
        streamLynkState.add(LynkState.happy);
        
        // Add request message to history
        _addToChatHistory('bot', AppLocalizations.text(LangKey.cv_show_cv_request), 'request');
      });
    });
  }

  Future<void> analyzeCV(File cvFile) async {
    _analyzedFile = cvFile;
    _isAnalyzingCV = true;

    // Show analyzing state
    streamLynkState.add(LynkState.thinking);
    streamCurrentBotMessage.add({
      'sender': 'bot',
      'text': AppLocalizations.text(LangKey.cv_analyzing_message),
      'isTruncated': 'false'
    });

    // Create analysis prompt
    String prompt = '''${AppLocalizations.text(LangKey.cv_analysis_prompt_intro)}
    ${AppLocalizations.text(LangKey.cv_analysis_prompt_strengths)}
    ${AppLocalizations.text(LangKey.cv_analysis_prompt_position)}
    ${AppLocalizations.text(LangKey.cv_analysis_prompt_advice)}
    
    ${AppLocalizations.text(LangKey.cv_analysis_prompt_info)}
    ${AppLocalizations.text(LangKey.cv_analysis_prompt_name).replaceAll('%s', model.name)}
    ${AppLocalizations.text(LangKey.cv_analysis_prompt_gender).replaceAll('%s', model.gender == "male" ? AppLocalizations.text(LangKey.cv_gender_male) : AppLocalizations.text(LangKey.cv_gender_female))}
    
    ${AppLocalizations.text(LangKey.cv_analysis_prompt_response_format)}''';

    // Print prompt before sending
    print('\n=== CV ANALYSIS PROMPT ===');
    print('Language: $_currentLanguage');
    print('Prompt: $prompt');
    print('=========================\n');

    try {
      String response;

      // Check file type
      final extension = cvFile.path.toLowerCase();
      if (extension.endsWith('.jpg') ||
          extension.endsWith('.jpeg') ||
          extension.endsWith('.png')) {
        // Use OpenAI image analysis for image files
        response = await OpenaiApiService.getResponseWithImage(
          prompt: prompt,
          imageFile: cvFile,
          language: _currentLanguage,
        );
      } else {
        // For PDF/DOC files, use text prompt
        // In production, you'd extract text from PDF first
        response = await OpenaiApiService.getResponse(
            prompt + "\n\n${AppLocalizations.text(LangKey.cv_file_type_label).replaceAll('%s', extension.split('.').last.toUpperCase())}",
            language: _currentLanguage
        );
      }

      // Print response after receiving
      print('\n=== CV ANALYSIS RESPONSE ===');
      print('Response: $response');
      print('============================\n');

      // Show initial analysis
      _showTruncatedResponse(response);

      // Show suggested questions
      streamSuggestedQuestions.add(_cvQuestions.take(4).toList());

      streamLynkState.add(LynkState.happy);
      _isAnalyzingCV = false;
      
      // Add analysis to history
      _addToChatHistory('bot', _fullResponse!, 'analysis');

    } catch (e) {
      print('\n=== CV ANALYSIS ERROR ===');
      print('Error: $e');
      print('=========================\n');
      
      streamCurrentBotMessage.add({
        'sender': 'bot',
        'text': AppLocalizations.text(LangKey.cv_error_analyzing).replaceAll('{name}', model.name),
        'isTruncated': 'false'
      });
      streamLynkState.add(LynkState.sadboi);
      print('Error analyzing CV: $e');
    }
  }

  void handleQuestionTap(String question) async {
    streamLynkState.add(LynkState.thinking);
    streamCurrentBotMessage.add(null);

    // Add user question to history
    _addToChatHistory('user', question, 'question');
    
    // Print user question
    print('\n=== USER QUESTION ===');
    print('Question: $question');
    print('Language: $_currentLanguage');
    print('====================\n');

    // Shuffle and update suggested questions
    List<String> remainingQuestions = List.from(_cvQuestions)..remove(question);
    remainingQuestions.shuffle();
    streamSuggestedQuestions.add(remainingQuestions.take(4).toList());

    // Create prompt for specific question
    String prompt = '''${AppLocalizations.text(LangKey.cv_question_prompt_intro)}
    ${AppLocalizations.text(LangKey.cv_analysis_prompt_name).replaceAll('%s', model.name)}
    ${AppLocalizations.text(LangKey.cv_analysis_prompt_gender).replaceAll('%s', model.gender == "male" ? AppLocalizations.text(LangKey.cv_gender_male) : AppLocalizations.text(LangKey.cv_gender_female))}
    
    ${AppLocalizations.text(LangKey.cv_question_prompt_answer).replaceAll('%s', question)}
    
    ${AppLocalizations.text(LangKey.cv_question_prompt_combine)}
    ${AppLocalizations.text(LangKey.cv_question_prompt_important)}''';

    // Print prompt before sending
    print('\n=== QUESTION PROMPT ===');
    print('Prompt: $prompt');
    print('======================\n');

    try {
      final response = await OpenaiApiService.getResponse(prompt, language: _currentLanguage);
      
      // Print response after receiving
      print('\n=== QUESTION RESPONSE ===');
      print('Response: $response');
      print('========================\n');
      
      _showTruncatedResponse(response);
      streamLynkState.add(LynkState.happy);
      
      // Add response to history
      _addToChatHistory('bot', response, 'question_response');

    } catch (e) {
      print('\n=== QUESTION ERROR ===');
      print('Error: $e');
      print('=====================\n');
      
      streamCurrentBotMessage.add({
        'sender': 'bot',
        'text': AppLocalizations.text(LangKey.cv_error_general),
        'isTruncated': 'false'
      });
      streamLynkState.add(LynkState.sadboi);
    }
  }

  void _showTruncatedResponse(String fullText) {
    _fullResponse = _sanitizeText(fullText);
    _currentResponseIndex = 0;

    // Split response if longer than 70 words
    List<String> words = _fullResponse!.split(' ');

    if (words.length <= 70) {
      streamCurrentBotMessage.add({
        'sender': 'bot',
        'text': _fullResponse!,
        'isTruncated': 'false'
      });
      _setLayoutBasedOnLength(_fullResponse!);
    } else {
      // Show first 60-70 words
      String truncated = words.take(65).join(' ') + '...';
      streamCurrentBotMessage.add({
        'sender': 'bot',
        'text': truncated,
        'isTruncated': 'true'
      });
      _setLayoutBasedOnLength(truncated);
      _currentResponseIndex = 65;
    }
  }

  void showMoreContent() {
    if (_fullResponse == null) return;

    List<String> words = _fullResponse!.split(' ');
    if (_currentResponseIndex >= words.length) return;

    streamLynkState.add(LynkState.thinking);

    // Show next 60-70 words
    int endIndex = min(_currentResponseIndex + 65, words.length);
    String nextChunk = words.sublist(_currentResponseIndex, endIndex).join(' ');

    bool hasMore = endIndex < words.length;

    streamCurrentBotMessage.add({
      'sender': 'bot',
      'text': nextChunk + (hasMore ? '...' : ''),
      'isTruncated': hasMore ? 'true' : 'false'
    });

    _setLayoutBasedOnLength(nextChunk);
    _currentResponseIndex = endIndex;

    streamLynkState.add(LynkState.happy);
  }
  
  void _addToChatHistory(String sender, String text, String? messageType) {
    final message = CVChatMessage(
      sender: sender,
      text: text,
      timestamp: DateTime.now(),
      messageType: messageType,
    );
    _chatHistory.add(message);
    streamChatHistory.add(_chatHistory);
  }
  
  void toggleChatHistory() {
    streamShowChatHistory.add(!streamShowChatHistory.value);
  }
  
  void hideChatHistory() {
    streamShowChatHistory.add(false);
  }
  
  List<CVChatMessage> getChatHistory() {
    return List.from(_chatHistory);
  }
  
  void clearChatHistory() {
    _chatHistory.clear();
    streamChatHistory.add(_chatHistory);
    streamShowChatHistory.add(false);
  }

  void _setLayoutBasedOnLength(String text) {
    BotReplyLayout newLayout;
    Alignment newAlignment;

    if (text.length < 100) {
      newLayout = BotReplyLayout.short;
      newAlignment = const Alignment(0.0, -0.3);
    } else if (text.length < 200) {
      newLayout = BotReplyLayout.medium;
      newAlignment = const Alignment(0.0, -0.4);
    } else {
      newLayout = BotReplyLayout.long;
      newAlignment = const Alignment(0.0, -0.6);
    }

    streamReplyLayout.add(newLayout);
    streamBotAlignment.add(newAlignment);
  }

  String _sanitizeText(String text) {
    try {
      final buffer = StringBuffer();
      for (int i = 0; i < text.length; i++) {
        final char = text.codeUnitAt(i);

        if (char >= 0xD800 && char <= 0xDBFF) {
          if (i + 1 < text.length) {
            final nextChar = text.codeUnitAt(i + 1);
            if (nextChar >= 0xDC00 && nextChar <= 0xDFFF) {
              buffer.writeCharCode(char);
              buffer.writeCharCode(nextChar);
              i++;
              continue;
            }
          }
          continue;
        }

        if (char >= 0xDC00 && char <= 0xDFFF) {
          continue;
        }

        buffer.writeCharCode(char);
      }

      return buffer.toString();
    } catch (e) {
      return text.replaceAll(RegExp(r'[^\x00-\x7F\u0080-\uFFFF]'), '');
    }
  }
}