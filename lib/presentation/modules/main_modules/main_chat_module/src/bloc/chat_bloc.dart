import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:lynk_an/common/utils/custom_navigator.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/domain/ai/ai_service.dart';
import 'package:lynk_an/domain/location/location_service.dart';
import 'package:lynk_an/data/services/api/chat_api_service.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/presentation/modules/main_modules/cv_module/src/ui/cv_chat_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:lynk_an/presentation/modules/authen_module/zodiac_selection/src/model/zodiac_model.dart';
import 'package:lynk_an/common/globals.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/ui/zodiac_reading_screen.dart';
import 'package:lynk_an/data/services/chat_service.dart';
import 'package:lynk_an/data/services/user_profile_service.dart';
import 'package:lynk_an/data/model/response/auth_response.dart';

class ChatMessage {
  final String sender;
  final String text;
  final DateTime timestamp;
  final BotReplyLayout? layout;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.layout,
  });
}

class ChatBloc {
  late BuildContext context;
  late ProfileModel model;
  late bool isInit;
  late bool isFromZodiacSelection;
  
  // Chat service for WebSocket
  final ChatService _chatService = ChatService();
  
  ChatBloc(this.context, this.model, this.isInit, {this.isFromZodiacSelection = false}) {
    // Initialize with empty string first, will be updated in _initializeLanguage
    streamPlaceholder = BehaviorSubject<String>.seeded('');
    _initializeLanguage();
    _initializeWebSocket();
    _setupTextListener();
  }

  final textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  Timer? _welcomeTimer;
  bool _isWelcoming = false;

  // Chat history
  final List<ChatMessage> _chatHistory = [];

  // Stream controllers
  final streamLynkState = BehaviorSubject<LynkState>.seeded(LynkState.idle);
  final streamBotAlignment = BehaviorSubject<Alignment>.seeded(const Alignment(0.0, -0.3));
  final streamCurrentBotMessage = BehaviorSubject<Map<String, String>?>.seeded(null);
  final streamIsBotReplying = BehaviorSubject<bool>.seeded(false);
  final streamShowTypingIndicator = BehaviorSubject<bool>.seeded(false);
  final streamReplyLayout = BehaviorSubject<BotReplyLayout>.seeded(BotReplyLayout.short);
  late final BehaviorSubject<String> streamPlaceholder;
  final streamChatHistory = BehaviorSubject<List<ChatMessage>>.seeded([]);
  final streamShowHistory = BehaviorSubject<bool>.seeded(false);
  final streamBotMessageVisible = BehaviorSubject<bool>.seeded(true);
  final streamShowSuggestions = BehaviorSubject<bool>.seeded(true);
  final streamCurrentLanguage = BehaviorSubject<String>.seeded('vi');
  final streamShowZodiacReadingButton = BehaviorSubject<bool>.seeded(false);
  final streamUseOpenAI = BehaviorSubject<bool>.seeded(false); // OpenAI is fallback only
  final streamBotStreamingMessage = BehaviorSubject<String>.seeded(''); // For streaming responses
  final streamConnectionStatus = BehaviorSubject<String>.seeded('connecting'); // Connection status



  List<String> _getWelcomeBackMessages(String language) {
    switch (language) {
      case 'vi':
        return [
          "Ơ kìa, {name} của Lynk đây rồi! 🎉 Dạo này sao rồi, kể em nghe đi nào!",
          "Ui chà, {name} quay lại rồi kìa! 💫 Lynk nhớ lắm luôn á!",
          "Hehe, {name} đến chơi với Lynk nè! 🌟 Hôm nay thế nào rồi?",
          "{name} ơi! Lynk đang chờ đấy! ✨ Có gì hay ho kể em nghe không?",
          "Wow {name} xuất hiện! 🎊 Lynk vui quá, mình lại được tám nữa rồi!"
        ];
      case 'en':
        return [
          "Oh look, {name} is here! 🎉 How have you been? Tell me everything!",
          "Wow, {name} is back! 💫 Lynk missed you so much!",
          "Hehe, {name} came to chat with Lynk! 🌟 How's your day going?",
          "{name}! Lynk has been waiting! ✨ Any exciting news to share?",
          "Wow {name} is here! 🎊 Lynk is so happy, we can chat again!"
        ];
      case 'ko':
        return [
          "어머, {name}님이 왔네요! 🎉 요즘 어떻게 지내셨어요? 다 얘기해주세요!",
          "와, {name}님이 돌아왔어요! 💫 린크가 정말 보고 싶었어요!",
          "히히, {name}님이 린크랑 놀러 왔네! 🌟 오늘 어때요?",
          "{name}님! 린크가 기다리고 있었어요! ✨ 재미있는 소식 있나요?",
          "와 {name}님이 나타났어요! 🎊 린크가 너무 기뻐요, 또 수다 떨 수 있겠네요!"
        ];
      default:
        return [
          "Ơ kìa, {name} của Lynk đây rồi! 🎉 Dạo này sao rồi, kể em nghe đi nào!",
          "Ui chà, {name} quay lại rồi kìa! 💫 Lynk nhớ lắm luôn á!",
          "Hehe, {name} đến chơi với Lynk nè! 🌟 Hôm nay thế nào rồi?",
          "{name} ơi! Lynk đang chờ đấy! ✨ Có gì hay ho kể em nghe không?",
          "Wow {name} xuất hiện! 🎊 Lynk vui quá, mình lại được tám nữa rồi!"
        ];
    }
  }

  void toggleOpenAI() {
    final currentValue = streamUseOpenAI.value;
    streamUseOpenAI.add(!currentValue);
    debugPrint('🔄 OpenAI toggle: ${!currentValue ? "ON" : "OFF"}');
  }
  
  void _showFallbackNotification() {
    // Show a subtle notification that we're using fallback
    final language = streamCurrentLanguage.value;
    String message;
    
    switch (language) {
      case 'en':
        message = 'Using backup connection...';
        break;
      case 'ko':
        message = '백업 연결 사용 중...';
        break;
      default:
        message = 'Đang sử dụng kết nối dự phòng...';
    }
    
    debugPrint('📢 Fallback notification: $message');
    // You can also show this in UI if needed
  }

  void dispose() {
    _welcomeTimer?.cancel();
    _typingTimer?.cancel();
    focusNode.dispose();
    textController.clear();
    streamLynkState.close();
    streamBotAlignment.close();
    streamCurrentBotMessage.close();
    streamIsBotReplying.close();
    streamShowTypingIndicator.close();
    streamReplyLayout.close();
    streamPlaceholder.close();
    _chatService.dispose();
    streamChatHistory.close();
    streamShowHistory.close();
    streamBotMessageVisible.close();
    streamShowSuggestions.close();
    streamCurrentLanguage.close();
    streamShowZodiacReadingButton.close();
    streamUseOpenAI.close();
    streamBotStreamingMessage.close();
    streamConnectionStatus.close();
  }
  
  void _initializeLanguage() {
    final savedLanguage = Globals.prefs.getString(SharedPrefsKey.language);
    String languageCode = 'vi';
    if (savedLanguage == LangKey.langVi) {
      languageCode = 'vi';
    } else if (savedLanguage == LangKey.langEn) {
      languageCode = 'en';
    } else if (savedLanguage == LangKey.langKo) {
      languageCode = 'ko';
    }
    streamCurrentLanguage.add(languageCode);
    _updatePlaceholderForLanguage(languageCode);
    print('🌐 ChatBloc initialized with language: $languageCode (from $savedLanguage)');
  }
  
  void _initializeWebSocket() async {
    try {
      final userId = UserProfileService.getUserId();
      final accessToken = UserProfileService.getAccessToken();
      
      if (userId != null && accessToken != null) {
        final authResponse = AuthResponse(
          userId: userId,
          accessToken: accessToken,
          phoneNumber: UserProfileService.getPhoneNumber(),
          deviceId: UserProfileService.getDeviceId(),
          name: model.name,
        );
        
        await _chatService.initialize(authResponse);
        _chatService.incomingMessages.listen((message) {
          _handleIncomingWebSocketMessage(message);
        });
        _chatService.connectionState.listen((isConnected) {
          debugPrint('🔌 WebSocket connection state: ${isConnected ? "Connected" : "Disconnected"}');
          streamConnectionStatus.add(isConnected ? 'connected' : 'disconnected');
        });
        
        debugPrint('✅ WebSocket initialized successfully for user: $userId');
      } else {
        debugPrint('⚠️ WebSocket not initialized: Missing user credentials');
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize WebSocket: $e');
    }
  }
  
  void _handleIncomingWebSocketMessage(dynamic wsMessage) {
    // Convert WebSocket message to our local ChatMessage type
    // wsMessage is already a ChatMessage from the WebSocket service
    final message = ChatMessage(
      sender: 'bot',
      text: wsMessage.content ?? '',
      timestamp: wsMessage.timestamp ?? DateTime.now(),
      layout: BotReplyLayout.medium,
    );
    
    // Add incoming message to chat history
    _chatHistory.add(message);
    streamChatHistory.add(_chatHistory);
    
    // Show chat history if receiving messages
    if (!streamShowHistory.value) {
      streamShowHistory.add(true);
    }
    
    debugPrint('📨 Received WebSocket message: ${message.text}');
  }
  
  Timer? _typingTimer;
  bool _isTyping = false;
  
  void _setupTextListener() {
    textController.addListener(() {
      final text = textController.text;
      
      // If user started typing and wasn't typing before
      if (text.isNotEmpty && !_isTyping) {
        _isTyping = true;
        if (_chatService.isConnected) {
          _chatService.sendTypingIndicator(true);
        }
      }
      
      // Reset typing timer
      _typingTimer?.cancel();
      if (text.isNotEmpty) {
        _typingTimer = Timer(const Duration(seconds: 2), () {
          // Stop typing indicator after 2 seconds of no typing
          if (_isTyping) {
            _isTyping = false;
            if (_chatService.isConnected) {
              _chatService.sendTypingIndicator(false);
            }
          }
        });
      } else {
        // If text is empty, stop typing
        if (_isTyping) {
          _isTyping = false;
          if (_chatService.isConnected) {
            _chatService.sendTypingIndicator(false);
          }
        }
      }
    });
  }

  String _getIntroMessage(ZodiacModel selectedZodiac, String language) {
    switch (language) {
      case 'en':
        return "✨ Wow! You've chosen ${selectedZodiac.nameEn} - ${selectedZodiac.description}";
      case 'ko':
        return "✨ 와! ${selectedZodiac.nameKo ?? selectedZodiac.nameEn}를 선택하셨군요 - ${selectedZodiac.description}";
      default:
        return "✨ Wow! Bạn đã chọn cung ${selectedZodiac.nameVi} - ${selectedZodiac.description}";
    }
  }

  String _getReadingReadyMessage(ZodiacModel selectedZodiac, String language) {
    switch (language) {
      case 'en':
        return "🌟 Lynk has prepared your ${selectedZodiac.nameEn} horoscope reading for this month!";
      case 'ko':
        return "🌟 Lynk가 이번 달 ${selectedZodiac.nameKo ?? selectedZodiac.nameEn} 운세를 준비했습니다!";
      default:
        return "🌟 Lynk đã chuẩn bị xong bài đọc tử vi cung ${selectedZodiac.nameVi} tháng này cho bạn rồi đó!";
    }
  }

  String _getReadingPreparingMessage(ZodiacModel selectedZodiac, String language) {
    switch (language) {
      case 'en':
        return "🌟 Your ${selectedZodiac.nameEn} horoscope is being prepared...\n\n💫 While waiting, let's chat with Lynk!";
      case 'ko':
        return "🌟 ${selectedZodiac.nameKo ?? selectedZodiac.nameEn} 운세를 준비하고 있습니다...\n\n💫 기다리는 동안 Lynk와 대화해보세요!";
      default:
        return "🌟 Tử vi cung ${selectedZodiac.nameVi} của bạn đang được chuẩn bị...\n\n💫 Trong lúc chờ đợi, hãy trò chuyện với Lynk nhé!";
    }
  }

  void initialBotWelcome() {
    _isWelcoming = true;
    
    // Check and request location permission on startup
    _checkAndRequestLocationPermission();
    
    if (isFromZodiacSelection && model.selectedZodiac != null) {
      _showZodiacReadingIntro();
    } else if (isInit) {
      _getAstrologyReading();
    } else {
      _welcomeBackUser();
    }
  }
  
  void _checkAndRequestLocationPermission() async {
    final hasLocationPermission = await LocationService.checkLocationPermission();
    if (!hasLocationPermission) {
      // Request permission but don't show message if denied
      await LocationService.requestLocationPermission();
    }
  }

  void clearCurrentMessage() {
    streamCurrentBotMessage.add(null);
    streamBotMessageVisible.add(false);
    streamShowHistory.add(false);
    streamLynkState.add(LynkState.idle);
    streamBotAlignment.add(const Alignment(0.0, -0.3));
  }

  void showChatHistory() {
    if (_chatHistory.isNotEmpty) {
      streamShowHistory.add(true);
      streamChatHistory.add(_chatHistory);
    }
  }

  void hideChatHistory() {
    streamShowHistory.add(false);
  }

  void showZodiacReading() {
    print('🎯 showZodiacReading() called');
    if (model.selectedZodiac == null) {
      print('❌ model.selectedZodiac is null');
      return;
    }
    
    print('📿 Selected zodiac ID: ${model.selectedZodiac}');
    final selectedZodiac = ZodiacModel.findById(model.selectedZodiac!);
    if (selectedZodiac == null) {
      print('❌ Could not find zodiac with ID: ${model.selectedZodiac}');
      return;
    }
    
    print('✅ Found zodiac: ${selectedZodiac.nameVi}');
    final readingJson = Globals.prefs.getString('zodiac_reading_${selectedZodiac.id}');
    print('📖 Reading JSON exists: ${readingJson != null && readingJson.isNotEmpty}');
    
    if (readingJson != null && readingJson.isNotEmpty) {
      print('🚀 Navigating to ZodiacReadingScreen');
      // Navigate to zodiac reading screen
      CustomNavigator.push(
        context,
        ZodiacReadingScreen(
          zodiacId: selectedZodiac.id,
          zodiacName: selectedZodiac.nameVi,
          readingJson: readingJson,
        ),
      );
    } else {
      print('❌ No reading JSON found for zodiac: ${selectedZodiac.id}');
    }
  }

  void _addToChatHistory(String sender, String text, BotReplyLayout? layout) {
    final message = ChatMessage(
      sender: sender,
      text: text,
      timestamp: DateTime.now(),
      layout: layout,
    );
    _chatHistory.add(message);
    streamChatHistory.add(_chatHistory);
  }

  void _cancelWelcomeProcess() {
    _welcomeTimer?.cancel();
    _isWelcoming = false;
    streamShowTypingIndicator.add(false);
    streamIsBotReplying.add(false);
  }

  void _getAstrologyReading() async {
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!_isWelcoming) return;

      streamLynkState.add(LynkState.thinking);
      streamIsBotReplying.add(true);
      streamShowTypingIndicator.add(true);
      streamBotAlignment.add(const Alignment(0.0, -0.5));

      String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(model.dateTime);
      String genderText = model.gender == 'male' ? 'male' : 'female';

      String prompt = _getAstrologyPrompt(formattedDate, genderText);

      try {
        if (!_isWelcoming) return;

        final currentLanguage = streamCurrentLanguage.value;
        
        // Try chat API first, then OpenAI
        String botText;
        try {
          final userId = Globals.prefs.getString(SharedPrefsKey.userId);
          final sessionId = Globals.prefs.getString(SharedPrefsKey.sessionId);
          
          final context = {
            'user_info': {
              'name': model.name,
              'gender': model.gender,
              'birth_date': formattedDate,
            },
            'language': currentLanguage,
            'context_type': 'astrology_welcome',
          };
          
          final chatResponse = await ChatApiService.sendMessage(
            message: prompt,
            userId: userId,
            sessionId: sessionId,
            context: context,
          );
          if (chatResponse.isSuccess) {
            botText = chatResponse.reply!;
          } else {
            throw Exception('Chat API returned empty reply');
          }
        } catch (e) {
          // Fallback to OpenAI
          botText = await AIService.getResponse(
            prompt: prompt,
            language: currentLanguage,
          );
        }
        
        final (emotionState, cleanMessage) = _extractEmotionAndMessage(botText);
        final sanitizedText = _sanitizeText(cleanMessage);

        if (!_isWelcoming) return;

        streamShowTypingIndicator.add(false);
        final layout = _getLayoutForText(sanitizedText);
        _setLayoutBasedOnLength(sanitizedText);

        streamCurrentBotMessage.add({
          'sender': 'bot',
          'text': sanitizedText
        });
        streamLynkState.add(emotionState);
        streamIsBotReplying.add(false);
        streamBotMessageVisible.add(true);
        _isWelcoming = false;

        _addToChatHistory('bot', sanitizedText, layout);

      } catch (e) {
        if (!_isWelcoming) return;

        streamShowTypingIndicator.add(false);
        String fallbackMessage = _generateFallbackAstrologyMessage();

        final layout = _getLayoutForText(fallbackMessage);
        _setLayoutBasedOnLength(fallbackMessage);
        streamCurrentBotMessage.add({
          'sender': 'bot',
          'text': fallbackMessage
        });
        streamLynkState.add(LynkState.happy);
        streamIsBotReplying.add(false);
        streamBotMessageVisible.add(true);
        _isWelcoming = false;

        _addToChatHistory('bot', fallbackMessage, layout);
      }
    });
  }

  void _showZodiacReadingIntro() async {
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!_isWelcoming) return;

      // Get zodiac info
      final selectedZodiac = ZodiacModel.findById(model.selectedZodiac!);
      if (selectedZodiac == null) {
        _getAstrologyReading(); // Fallback to regular astrology
        return;
      }

      // First message - brief intro
      final currentLanguage = streamCurrentLanguage.value;
      String introMessage = _getIntroMessage(selectedZodiac, currentLanguage);
      
      streamCurrentBotMessage.add({
        'sender': 'bot',
        'text': introMessage
      });
      _setLayoutBasedOnLength(introMessage);
      streamLynkState.add(LynkState.happy);
      streamBotMessageVisible.add(true);
      _addToChatHistory('bot', introMessage, BotReplyLayout.medium);

      // Wait 3 seconds then show second message with button
      _welcomeTimer = Timer(const Duration(seconds: 3), () async {
        if (!_isWelcoming) return;

        // Load saved zodiac reading if exists
        final readingJson = Globals.prefs.getString('zodiac_reading_${selectedZodiac.id}');
        print('🔍 Loading zodiac reading for ${selectedZodiac.id}');
        print('📖 Reading JSON exists: ${readingJson != null && readingJson.isNotEmpty}');
        if (readingJson != null) {
          print('📄 Reading JSON length: ${readingJson.length} characters');
        }
        
        String secondMessage;
        
        if (readingJson != null && readingJson.isNotEmpty) {
          secondMessage = _getReadingReadyMessage(selectedZodiac, currentLanguage);
        } else {
          secondMessage = _getReadingPreparingMessage(selectedZodiac, currentLanguage);
        }

        streamShowTypingIndicator.add(false);
        
        if (readingJson != null && readingJson.isNotEmpty) {
          // Show zodiac reading message with clickable card
          streamCurrentBotMessage.add({
            'sender': 'bot',
            'text': secondMessage,
            'type': 'zodiac_reading',
            'zodiac_id': selectedZodiac.id,
            'zodiac_name': selectedZodiac.nameVi,
          });
        } else {
          streamCurrentBotMessage.add({
            'sender': 'bot',
            'text': secondMessage
          });
        }
        
        _setLayoutBasedOnLength(secondMessage);
        streamLynkState.add(LynkState.welcoming);
        
        _addToChatHistory('bot', secondMessage, BotReplyLayout.long);
        
        _isWelcoming = false;
        streamIsBotReplying.add(false);
      });
    });
  }

  void _welcomeBackUser() async {
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!_isWelcoming) return;

      final currentLanguage = streamCurrentLanguage.value;
      final welcomeMessages = _getWelcomeBackMessages(currentLanguage);
      String welcomeMessage = welcomeMessages[Random().nextInt(welcomeMessages.length)]
          .replaceAll('{name}', model.name);

      final layout = _getLayoutForText(welcomeMessage);
      streamCurrentBotMessage.add({
        'sender': 'bot',
        'text': welcomeMessage
      });
      _setLayoutBasedOnLength(welcomeMessage);
      streamLynkState.add(LynkState.welcoming);
      streamBotMessageVisible.add(true);

      _addToChatHistory('bot', welcomeMessage, layout);

      _welcomeTimer = Timer(const Duration(seconds: 5), () async {
        if (!_isWelcoming) return;

        streamLynkState.add(LynkState.thinking);
        streamIsBotReplying.add(true);
        streamShowTypingIndicator.add(true);

        String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(model.dateTime);
        String genderText = model.gender == 'male' ? 'nam' : 'nữ';
        String todayDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

        String prompt = _getDailyFortunePrompt(formattedDate, genderText, todayDate);

        try {
          if (!_isWelcoming) return;

          final currentLanguage = streamCurrentLanguage.value;
          
          // Try chat API first, then OpenAI
          String botText;
          try {
            final userId = Globals.prefs.getString(SharedPrefsKey.userId);
            final sessionId = Globals.prefs.getString(SharedPrefsKey.sessionId);
            
            final context = {
              'user_info': {
                'name': model.name,
                'gender': genderText,
                'birth_date': formattedDate,
                'zodiac': model.selectedZodiac,
              },
              'language': currentLanguage,
              'context_type': 'daily_fortune',
              'today_date': todayDate,
            };
            
            final chatResponse = await ChatApiService.sendMessage(
              message: prompt,
              userId: userId,
              sessionId: sessionId,
              context: context,
            );
            if (chatResponse.isSuccess) {
              botText = chatResponse.reply!;
            } else {
              throw Exception('Chat API returned empty reply');
            }
          } catch (e) {
            // Fallback to OpenAI
            botText = await AIService.getResponse(
              prompt: prompt,
              language: currentLanguage,
            );
          }
          
          final (emotionState, cleanMessage) = _extractEmotionAndMessage(botText);
          final sanitizedText = _sanitizeText(cleanMessage);

          if (!_isWelcoming) return;

          streamShowTypingIndicator.add(false);
          final layoutForHistory = _getLayoutForText(sanitizedText);
          _setLayoutBasedOnLength(sanitizedText);

          streamCurrentBotMessage.add({
            'sender': 'bot',
            'text': sanitizedText
          });
          streamLynkState.add(emotionState);
          streamIsBotReplying.add(false);
          streamBotMessageVisible.add(true);
          _isWelcoming = false;

          _addToChatHistory('bot', sanitizedText, layoutForHistory);

        } catch (e) {
          if (!_isWelcoming) return;

          streamShowTypingIndicator.add(false);
          String fallbackMessage = _generateFallbackDailyFortune();

          final layoutForHistory = _getLayoutForText(fallbackMessage);
          _setLayoutBasedOnLength(fallbackMessage);
          streamCurrentBotMessage.add({
            'sender': 'bot',
            'text': fallbackMessage
          });
          streamLynkState.add(LynkState.happy);
          streamIsBotReplying.add(false);
          streamBotMessageVisible.add(true);
          _isWelcoming = false;

          _addToChatHistory('bot', fallbackMessage, layoutForHistory);
        }
      });
    });
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Ẩn bong bóng chat khi focus
      streamBotMessageVisible.add(false);
      // Ẩn suggestions khi focus
      streamShowSuggestions.add(false);

      if (_isWelcoming) {
        _cancelWelcomeProcess();
      }

      if (streamIsBotReplying.hasValue && !streamIsBotReplying.value) {
        streamLynkState.add(LynkState.listening);
        // Không thay đổi vị trí bot khi focus
      }
    } else {
      // Hiện lại bong bóng chat khi unfocus (nếu có tin nhắn)
      if (streamCurrentBotMessage.hasValue && streamCurrentBotMessage.value != null) {
        streamBotMessageVisible.add(true);
      }

      // Hiện suggestions khi unfocus và không có text
      final isBotReplying = streamIsBotReplying.hasValue ? streamIsBotReplying.value : false;
      if (textController.text.trim().isEmpty && !isBotReplying) {
        streamShowSuggestions.add(true);
      }

      if (streamLynkState.hasValue && streamLynkState.value == LynkState.listening) {
        streamLynkState.add(LynkState.idle);
      }
    }
  }

  Future<void> handleSendMessage() async {
    final userMessage = textController.text.trim();
    if (userMessage.isEmpty || streamIsBotReplying.value) return;

    _cancelWelcomeProcess();

    // Add user message to history
    _addToChatHistory('user', userMessage, null);
    
    // Send message through WebSocket if connected
    if (_chatService.isConnected) {
      // Send typing indicator first
      _chatService.sendTypingIndicator(false);
      
      // Send the actual message
      _chatService.sendMessage(userMessage).then((response) {
        if (response.isSuccess) {
          debugPrint('📤 Message sent successfully via API/WebSocket');
        }
      }).catchError((error) {
        debugPrint('❌ Failed to send message: $error');
      });
    }

    textController.clear();
    focusNode.unfocus();
    _changePlaceholder();

    streamLynkState.add(LynkState.thinking);
    streamIsBotReplying.add(true);
    streamShowTypingIndicator.add(true);
    streamBotAlignment.add(const Alignment(0.0, -0.3));
    
    // Check for language change request first
    String? requestedLanguage = _detectLanguageChangeRequest(userMessage);
    
    // If no direct detection, check with AI for ambiguous requests
    if (requestedLanguage == null && _mightBeLanguageRequest(userMessage)) {
      requestedLanguage = await _detectLanguageWithAI(userMessage);
    }
    
    if (requestedLanguage != null) {
      // Handle language change
      streamCurrentLanguage.add(requestedLanguage);
      _updatePlaceholderForLanguage(requestedLanguage);
      
      String confirmationMessage = _getLanguageConfirmationMessage(requestedLanguage);
      final layoutForHistory = _getLayoutForText(confirmationMessage);
      _setLayoutBasedOnLength(confirmationMessage);
      
      streamCurrentBotMessage.add({'sender': 'bot', 'text': confirmationMessage});
      streamLynkState.add(LynkState.happy);
      streamIsBotReplying.add(false);
      streamBotMessageVisible.add(true);
      
      _addToChatHistory('bot', confirmationMessage, layoutForHistory);
      
      // Generate welcome message in new language after 2 seconds
      Future.delayed(const Duration(seconds: 2), () async {
        await _generateWelcomeInNewLanguage(requestedLanguage!);
      });
      
      return;
    }
    
    bool isAskingAboutCV = _checkIfAskingAboutCV(userMessage);
    bool isAskingAboutNearbyPlaces = _checkIfAskingAboutNearbyPlaces(userMessage);
    
    String? userLocation;
    
    // Handle location request for nearby places
    if (isAskingAboutNearbyPlaces) {
      final hasLocationPermission = await LocationService.checkLocationPermission();
      if (!hasLocationPermission) {
        final granted = await LocationService.requestLocationPermission();
        if (!granted) {
          // Show location permission message
          final currentLanguage = streamCurrentLanguage.value;
          final locationMessage = LocationService.getLocationPromptMessage(currentLanguage);
          
          streamShowTypingIndicator.add(false);
          final layoutForHistory = _getLayoutForText(locationMessage);
          _setLayoutBasedOnLength(locationMessage);
          
          streamCurrentBotMessage.add({'sender': 'bot', 'text': locationMessage});
          streamLynkState.add(LynkState.idle);
          streamIsBotReplying.add(false);
          streamBotMessageVisible.add(true);
          _addToChatHistory('bot', locationMessage, layoutForHistory);
          
          return;
        }
      }
      
      // Get current location if permission is granted
      userLocation = await LocationService.getCurrentLocationText();
    }
    
    String enhancedPrompt = _getMainChatPrompt(
      userMessage: userMessage,
      isAskingAboutCV: isAskingAboutCV,
    );

    try {
      final currentLanguage = streamCurrentLanguage.value;
      String botText = '';
      bool socketSuccess = false;
      
      // PRIORITY 1: Try WebSocket/SSE streaming first
      if (_chatService.isConnected) {
        try {
          debugPrint('🌊 Attempting SSE streaming response (Priority 1)');
          
          // Clear streaming buffer
          streamBotStreamingMessage.add('');
          
          // Get streaming response
          final stream = await _chatService.sendMessageWithStream(userMessage);
          
          // Set timeout for SSE response
          bool hasReceivedData = false;
          final streamWithTimeout = stream.timeout(
            const Duration(seconds: 30),
            onTimeout: (sink) {
              if (!hasReceivedData) {
                sink.addError('SSE timeout - no response received');
              }
              sink.close();
            },
          );
          
          // Accumulate streaming chunks
          await for (final chunk in streamWithTimeout) {
            hasReceivedData = true;
            botText += chunk;
            streamBotStreamingMessage.add(botText);
            
            // Update bot message in real-time
            streamCurrentBotMessage.add({'sender': 'bot', 'text': botText});
            streamBotMessageVisible.add(true);
          }
          
          if (botText.isNotEmpty) {
            socketSuccess = true;
            debugPrint('✅ SSE streaming successful: ${botText.length} chars');
          }
          
        } catch (sseError) {
          debugPrint('❌ SSE streaming failed: $sseError');
          debugPrint('🔄 Falling back to OpenAI...');
        }
      } else {
        debugPrint('⚠️ WebSocket not connected, using OpenAI fallback');
      }
      
      // PRIORITY 2: Fallback to OpenAI if socket failed or not connected
      if (!socketSuccess) {
        debugPrint('🤖 Using OpenAI as fallback (Priority 2)');
        
        // Show fallback notification to user
        _showFallbackNotification();
        
        if (userLocation != null) {
          botText = await AIService.getResponse(
            prompt: enhancedPrompt,
            language: currentLanguage,
            userLocation: userLocation,
          );
        } else {
          botText = await AIService.getResponse(
            prompt: enhancedPrompt,
            language: currentLanguage,
          );
        }
        debugPrint('✅ OpenAI response received');
      } else {
        // Use LynkAn Chat API (default)
        try {
          // Get user ID and session ID from SharedPreferences
          final userId = Globals.prefs.getString(SharedPrefsKey.userId);
          final sessionId = Globals.prefs.getString(SharedPrefsKey.sessionId);
          
          // Prepare context for API
          final context = {
            'user_info': {
              'name': model.name,
              'gender': model.gender,
              'birth_date': model.dateTime.toIso8601String(),
              'zodiac': model.selectedZodiac,
            },
            'language': currentLanguage,
            if (userLocation != null) 'location': userLocation,
            if (isAskingAboutCV) 'context_type': 'cv_inquiry',
          };
          
          // Prepare chat history for API
          final apiHistory = _chatHistory.map((msg) => {
            'role': msg.sender == 'user' ? 'user' : 'assistant',
            'content': msg.text,
          }).toList();
          
          debugPrint('🔄 Using LynkAn Chat API');
          final chatResponse = await ChatApiService.sendChatWithHistory(
            message: userMessage,
            chatHistory: apiHistory,
            userId: userId,
            sessionId: sessionId,
            userContext: context,
          );
          
          if (chatResponse.isSuccess) {
            botText = chatResponse.reply!;
            debugPrint('✅ LynkAn Chat API response received');
            debugPrint('📊 Status: ${chatResponse.status}');
          } else {
            throw Exception('Chat API returned empty reply');
          }
        } catch (e) {
          debugPrint('❌ LynkAn Chat API failed');
          debugPrint('Error: $e');
          throw e;
        }
      }
      
      // Extract emotion state and message
      final (emotionState, cleanMessage) = _extractEmotionAndMessage(botText);
      final sanitizedText = _sanitizeText(cleanMessage);
      
      // Debug: Check if response contains PRODUCT_LINK
      if (botText.contains('[PRODUCT_LINK]')) {
        debugPrint('AI Response contains PRODUCT_LINK: $botText');
      } else {
        debugPrint('AI Response WITHOUT PRODUCT_LINK: $botText');
      }
      
      streamShowTypingIndicator.add(false);

      final layoutForHistory = _getLayoutForText(sanitizedText);
      _setLayoutBasedOnLength(sanitizedText);

      if (sanitizedText.contains('[CV_SCREEN_ID]')) {
        String displayText = sanitizedText.replaceAll('[CV_SCREEN_ID]', '').trim();
        streamCurrentBotMessage.add({'sender': 'bot', 'text': displayText});
        _addToChatHistory('bot', displayText, layoutForHistory);
        Future.delayed(const Duration(seconds: 6), () {
          CustomNavigator.push(context, CVChatScreen(model: model));
        });
      } else {
        streamCurrentBotMessage.add({'sender': 'bot', 'text': sanitizedText});
        _addToChatHistory('bot', sanitizedText, layoutForHistory);
      }

      streamLynkState.add(emotionState);
      streamIsBotReplying.add(false);
      streamBotMessageVisible.add(true);

      // Show suggestions again after bot response if text is empty
      Future.delayed(const Duration(seconds: 1), () {
        if (textController.text.trim().isEmpty && !focusNode.hasFocus) {
          streamShowSuggestions.add(true);
        }
      });

    } catch (e) {
      streamShowTypingIndicator.add(false);
      
      // Check if it's an API key error
      String errorMessage;
      if (e.toString().contains('API key not configured')) {
        errorMessage = streamCurrentLanguage.value == 'vi' 
            ? 'Xin lỗi, Lynk chưa thể kết nối với OpenAI. Vui lòng tắt OpenAI và dùng API hoặc khởi động lại ứng dụng nhé! 😔'
            : 'Sorry, Lynk cannot connect to OpenAI. Please turn off OpenAI and use API mode or restart the app! 😔';
      } else {
        errorMessage = _getErrorMessage();
      }
      
      // Show error message to user
      final layoutForHistory = _getLayoutForText(errorMessage);
      _setLayoutBasedOnLength(errorMessage);
      streamCurrentBotMessage.add({'sender': 'bot', 'text': errorMessage});
      streamLynkState.add(LynkState.sadboi);
      streamIsBotReplying.add(false);
      streamBotMessageVisible.add(true);
      
      _addToChatHistory('bot', errorMessage, layoutForHistory);
      
      // Don't add to chat history when both APIs fail
      
      // Show suggestions again after error if text is empty
      Future.delayed(const Duration(seconds: 1), () {
        if (textController.text.trim().isEmpty && !focusNode.hasFocus) {
          streamShowSuggestions.add(true);
        }
      });
    }
  }

  Future<void> handleSuggestionTap(String suggestion) async {
    // Hide suggestions when user taps on one
    streamShowSuggestions.add(false);
    
    // Set the suggestion text to the text controller
    textController.text = suggestion;
    
    // Trigger the send message flow
    await handleSendMessage();
    
    // Show suggestions again after a delay for next interaction
    Future.delayed(const Duration(seconds: 2), () {
      if (!streamIsBotReplying.value && textController.text.isEmpty) {
        streamShowSuggestions.add(true);
      }
    });
  }

  void onTextChanged() {
    final hasText = textController.text.trim().isNotEmpty;
    if (hasText) {
      // Hide suggestions when user types
      streamShowSuggestions.add(false);
    } else if (!focusNode.hasFocus && !streamIsBotReplying.value) {
      // Show suggestions when text is empty and not focused
      streamShowSuggestions.add(true);
    }
  }

  void _changePlaceholder() {
    final random = Random();
    final currentLanguage = streamCurrentLanguage.value;
    final placeholders = _getPlaceholdersForLanguage(currentLanguage);
    streamPlaceholder.add(placeholders[random.nextInt(placeholders.length)]);
  }

  void resetToIdleState() {
    streamLynkState.add(LynkState.idle);
    streamBotAlignment.add(const Alignment(0.0, -0.3));
    streamIsBotReplying.add(false);
  }

  BotReplyLayout _getLayoutForText(String text) {
    if (text.length < 50) {
      return BotReplyLayout.short;
    } else if (text.length < 100) {
      return BotReplyLayout.medium;
    } else {
      return BotReplyLayout.long;
    }
  }

  void _setLayoutBasedOnLength(String text) {
    BotReplyLayout newLayout = _getLayoutForText(text);
    Alignment newAlignment;

    switch (newLayout) {
      case BotReplyLayout.short:
        newAlignment = const Alignment(0.0, -0.2);
        break;
      case BotReplyLayout.medium:
        newAlignment = const Alignment(0.0, -0.5);
        break;
      case BotReplyLayout.long:
        newAlignment = const Alignment(0.0, -0.85);
        break;
    }

    streamReplyLayout.add(newLayout);
    streamBotAlignment.add(newAlignment);
  }

  bool _checkIfAskingAboutCV(String message) {
    final lowerMessage = message.toLowerCase();
    final cvKeywords = [
      'cv', 'curriculum vitae', 'resume', 'hồ sơ',
      'xem cv', 'kiểm tra cv', 'check cv', 'xem hồ sơ',
      'sửa cv', 'cải thiện cv', 'cv của tôi', 'cv của mình',
      'hồ sơ xin việc', 'đơn xin việc', 'profile',
    ];

    return cvKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  bool _checkIfAskingAboutNearbyPlaces(String message) {
    final lowerMessage = message.toLowerCase();
    final nearbyKeywords = [
      'gần đây', 'gần nhất', 'gần tôi', 'gần mình', 'nearby', 'near me', 'closest',
      'nhà hàng', 'quán ăn', 'restaurant', 'food', 'ăn ở đâu', 'eat where',
      'cửa hàng', 'shop', 'store', 'mua ở đâu', 'buy where',
      'quán cà phê', 'cafe', 'coffee shop', 'uống cà phê',
      'siêu thị', 'supermarket', 'market', 'chợ',
      '근처', '가까운', '음식점', '식당', '카페', '상점', '마트',
    ];

    return nearbyKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  String? _detectLanguageChangeRequest(String message) {
    final lowerMessage = message.toLowerCase().trim();
    
    // Check for explicit language change keywords
    final explicitChangeKeywords = [
      'đổi ngôn ngữ', 'chuyển ngôn ngữ', 'change language', 'switch language',
      'đổi sang tiếng', 'chuyển sang tiếng', 'switch to', 'change to',
      'nói tiếng', 'dùng tiếng', 'use language',
      '언어 바꿔', '언어 변경', 'thay đổi ngôn ngữ'
    ];
    
    // If no explicit change keyword found, return null
    if (!explicitChangeKeywords.any((keyword) => lowerMessage.contains(keyword))) {
      return null;
    }
    
    // Vietnamese language requests
    final vietnameseKeywords = [
      'tiếng việt', 'vietnamese', 'việt nam', 'viet nam', 'tieng viet'
    ];
    
    // English language requests  
    final englishKeywords = [
      'tiếng anh', 'english', 'tieng anh', 'anh ngữ'
    ];
    
    // Korean language requests
    final koreanKeywords = [
      'tiếng hàn', 'korean', '한국어', 'hàn quốc', 'tieng han'
    ];
    
    // Check which language is requested
    if (vietnameseKeywords.any((keyword) => lowerMessage.contains(keyword))) {
      return 'vi';
    }
    
    if (englishKeywords.any((keyword) => lowerMessage.contains(keyword))) {
      return 'en';
    }
    
    if (koreanKeywords.any((keyword) => lowerMessage.contains(keyword))) {
      return 'ko';
    }
    
    return null;
  }
  
  String? _detectLanguageUsingContext(String message) {
    // This method is not used anymore since we only detect explicit language change requests
    return null;
  }
  
  bool _mightBeLanguageRequest(String message) {
    final lowerMessage = message.toLowerCase();
    // Only check for very explicit language-related keywords
    final languageKeywords = [
      'ngôn ngữ', 'language', '언어',
      'đổi sang tiếng', 'chuyển sang tiếng', 
      'switch language', 'change language'
    ];
    
    return languageKeywords.any((keyword) => lowerMessage.contains(keyword));
  }
  
  Future<String?> _detectLanguageWithAI(String message) async {
    try {
      final prompt = '''Analyze this message and determine if the user is EXPLICITLY requesting to change the chat language.
      User message: "$message"
      
      ONLY consider it a language change request if the user explicitly mentions:
      - Changing language (đổi ngôn ngữ, change language, 언어 변경)
      - Switching to a specific language (chuyển sang tiếng anh, switch to english, etc.)
      
      If they are requesting a language change, respond with ONLY one of these codes:
      - vi (for Vietnamese)
      - en (for English)  
      - ko (for Korean)
      
      If they are NOT requesting a language change, respond with: none
      
      DO NOT consider general questions or statements in another language as change requests.
      
      Response (ONLY the code, nothing else):''';
      
      final currentLanguage = streamCurrentLanguage.value;
      
      // Try chat API first, then OpenAI
      String response;
      try {
        final userId = Globals.prefs.getString(SharedPrefsKey.userId);
        final chatResponse = await ChatApiService.sendMessage(
          message: prompt,
          userId: userId,
        );
        if (chatResponse.isSuccess) {
          response = chatResponse.reply!;
        } else {
          throw Exception('Chat API returned empty reply');
        }
      } catch (e) {
        // Fallback to OpenAI
        response = await AIService.getResponse(
          prompt: prompt,
          language: currentLanguage,
        );
      }
      
      final cleanResponse = response.trim().toLowerCase();
      
      if (cleanResponse == 'vi' || cleanResponse == 'en' || cleanResponse == 'ko') {
        return cleanResponse;
      }
      
      return null;
    } catch (e) {
      // If AI detection fails, return null
      return null;
    }
  }

  String _getLanguageConfirmationMessage(String newLanguage) {
    switch (newLanguage) {
      case 'vi':
        return "Được rồi! Lynk sẽ nói tiếng Việt với ${model.name} từ bây giờ nhé! 🇻🇳✨";
      case 'en':
        return "Sure! Lynk will speak English with ${model.name} from now on! 🇺🇸✨";
      case 'ko':
        return "알겠어요! 이제부터 린크가 ${model.name}님과 한국어로 대화할게요! 🇰🇷✨";
      default:
        return "Được rồi! Lynk đã chuyển ngôn ngữ rồi nhé! ✨";
    }
  }

  void _updatePlaceholderForLanguage(String language) {
    // Get the appropriate placeholder based on language
    String placeholder;
    switch (language) {
      case 'vi':
        placeholder = "Kể Lynk nghe gì đó đi...";
        break;
      case 'en':
        placeholder = "Tell Lynk something...";
        break;
      case 'ko':
        placeholder = "링크에게 무언가를 말해보세요...";
        break;
      default:
        placeholder = "Kể Lynk nghe gì đó đi...";
        break;
    }
    streamPlaceholder.add(placeholder);
  }

  List<String> _getPlaceholdersForLanguage(String language) {
    switch (language) {
      case 'vi':
        return [
          "Kể Lynk nghe gì đó đi...",
          "Có chuyện gì thú vị không?",
          "Tâm sự với Lynk nào!",
          "Lynk đang lắng nghe đây..."
        ];
      case 'en':
        return [
          "Tell Lynk something...",
          "What's on your mind?",
          "Share with Lynk!",
          "Lynk is listening..."
        ];
      case 'ko':
        return [
          "린크에게 무슨 일이 있었는지 말해봐...",
          "무슨 재미있는 일이 있나요?",
          "린크와 이야기해봐!",
          "린크가 듣고 있어요..."
        ];
      default:
        return [
          "Kể Lynk nghe gì đó đi...",
          "Có chuyện gì thú vị không?",
          "Tâm sự với Lynk nào!",
          "Lynk đang lắng nghe đây..."
        ];
    }
  }

  (LynkState, String) _extractEmotionAndMessage(String response) {
    // First try the standard [EMOTION:key] format
    final emotionPattern = RegExp(r'\[EMOTION:(\w+)\]');
    final match = emotionPattern.firstMatch(response);
    
    String cleanMessage = response;
    
    if (match != null) {
      final emotionKey = match.group(1)?.toLowerCase() ?? 'happy';
      cleanMessage = response.replaceAll(emotionPattern, '').trim();
      
      // Map emotion key to LynkState
      final emotionState = _mapEmotionKeyToState(emotionKey);
      return (emotionState, cleanMessage);
    }
    
    // Also remove any other bracketed formats like [HAPPY:snack], [STATE:emotion], etc.
    final anyBracketPattern = RegExp(r'\[\w+:\w+\]');
    cleanMessage = cleanMessage.replaceAll(anyBracketPattern, '').trim();
    
    // If no emotion marker found, analyze content to determine emotion
    final analyzedEmotion = _analyzeMessageEmotion(cleanMessage);
    return (analyzedEmotion, cleanMessage);
  }
  
  LynkState _mapEmotionKeyToState(String emotionKey) {
    switch (emotionKey) {
      case 'idle':
        return LynkState.idle;
      case 'sleeping':
        return LynkState.sleeping;
      case 'happy':
        return LynkState.happy;
      case 'thinking':
      case 'welcoming':
        return LynkState.welcoming;
      case 'angry':
        return LynkState.angry;
      case 'amazed':
        return LynkState.amazed;
      case 'trolling':
        return LynkState.happy;  // Map trolling to happy instead
      case 'sadboi':
        return LynkState.sadboi;
      case 'listening':
        return LynkState.listening;
      case 'scared':
        return LynkState.scared;
      case 'dizzy':
        return LynkState.dizzy;
      case 'sleepy':
        return LynkState.sleepy;
      case 'lowenergy':
        return LynkState.lowenergy;
      case 'holdingflag':
        return LynkState.holdingFlag;
      default:
        return LynkState.happy;
    }
  }
  
  LynkState _analyzeMessageEmotion(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Check for specific emotion indicators
    if (lowerMessage.contains('xin lỗi') || lowerMessage.contains('sorry') || 
        lowerMessage.contains('죄송')) {
      return LynkState.sadboi;
    }
    
    if (lowerMessage.contains('wow') || lowerMessage.contains('tuyệt vời') || 
        lowerMessage.contains('amazing') || lowerMessage.contains('대단')) {
      return LynkState.amazed;
    }
    
    if (lowerMessage.contains('sợ') || lowerMessage.contains('scared') || 
        lowerMessage.contains('무서')) {
      return LynkState.scared;
    }
    
    if (lowerMessage.contains('chào') || lowerMessage.contains('hello') || 
        lowerMessage.contains('안녕') || lowerMessage.contains('welcome')) {
      return LynkState.welcoming;
    }
    
    if (lowerMessage.contains('buồn ngủ') || lowerMessage.contains('sleepy') || 
        lowerMessage.contains('졸려')) {
      return LynkState.sleepy;
    }
    
    if (lowerMessage.contains('🤔') || lowerMessage.contains('suy nghĩ') || 
        lowerMessage.contains('thinking')) {
      return LynkState.happy;  // Use happy instead of thinking
    }
    
    if (lowerMessage.contains('😡') || lowerMessage.contains('tức giận') || 
        lowerMessage.contains('angry')) {
      return LynkState.angry;
    }
    
    if (lowerMessage.contains('😎') || lowerMessage.contains('troll') || 
        lowerMessage.contains('đùa')) {
      return LynkState.happy;  // Use happy instead of trolling
    }
    
    // Default to happy for positive messages
    return LynkState.happy;
  }

  String _sanitizeText(String text) {
    try {
      // Use runes to properly handle Unicode characters including emojis
      final StringBuffer buffer = StringBuffer();
      final runes = text.runes;
      
      for (final rune in runes) {
        // Only add valid Unicode code points
        if (rune <= 0x10FFFF) {
          buffer.write(String.fromCharCode(rune));
        }
      }
      
      return buffer.toString();
    } catch (e) {
      // If there's still an error, return the text as-is
      // Flutter will handle invalid characters
      return text;
    }
  }

  String _generateFallbackAstrologyMessage() {
    final currentLanguage = streamCurrentLanguage.value;
    List<String> messages = _getFallbackAstrologyMessages(currentLanguage);
    return messages[Random().nextInt(messages.length)];
  }

  List<String> _getFallbackAstrologyMessages(String language) {
    switch (language) {
      case 'vi':
        return [
          "Ồ ${model.name} là người rất đặc biệt đấy! 🌟 Lynk thấy bạn có tính cách mạnh mẽ và quyết đoán. Tương lai chắc chắn sẽ rực rỡ lắm! ✨",
          "Wow, ${model.name} sinh ra đã mang mệnh quý nhân rồi! 💫 Lynk thấy bạn sẽ gặp nhiều may mắn trong thời gian tới đấy! 🍀",
          "Hehe, ${model.name} là tuýp người rất thú vị! 🎊 Tử vi cho thấy bạn sẽ có nhiều cơ hội tốt, cứ tự tin tiến lên nhé! 💪"
        ];
      case 'en':
        return [
          "Oh ${model.name} is a very special person! 🌟 Lynk sees you have a strong and decisive personality. Your future will definitely be bright! ✨",
          "Wow, ${model.name} was born with a noble destiny! 💫 Lynk sees you'll encounter lots of luck in the coming time! 🍀",
          "Hehe, ${model.name} is a very interesting type of person! 🎊 Your horoscope shows many good opportunities, just move forward confidently! 💪"
        ];
      case 'ko':
        return [
          "오 ${model.name}님은 정말 특별한 분이네요! 🌟 린크가 보니 강하고 결단력 있는 성격을 가지셨어요. 미래는 분명 밝을 거예요! ✨",
          "와, ${model.name}님은 태어날 때부터 귀인의 운명을 타고났네요! 💫 린크가 보니 앞으로 많은 행운을 만날 거예요! 🍀",
          "히히, ${model.name}님은 정말 흥미로운 분이에요! 🎊 운세를 보니 좋은 기회가 많이 올 거예요, 자신있게 나아가세요! 💪"
        ];
      default:
        return [
          "Ồ ${model.name} là người rất đặc biệt đấy! 🌟 Lynk thấy bạn có tính cách mạnh mẽ và quyết đoán. Tương lai chắc chắn sẽ rực rỡ lắm! ✨",
          "Wow, ${model.name} sinh ra đã mang mệnh quý nhân rồi! 💫 Lynk thấy bạn sẽ gặp nhiều may mắn trong thời gian tới đấy! 🍀",
          "Hehe, ${model.name} là tuýp người rất thú vị! 🎊 Tử vi cho thấy bạn sẽ có nhiều cơ hội tốt, cứ tự tin tiến lên nhé! 💪"
        ];
    }
  }

  String _generateFallbackDailyFortune() {
    final currentLanguage = streamCurrentLanguage.value;
    List<String> messages = _getFallbackDailyFortuneMessages(currentLanguage);
    return messages[Random().nextInt(messages.length)];
  }

  List<String> _getFallbackDailyFortuneMessages(String language) {
    switch (language) {
      case 'vi':
        return [
          "Hôm nay ${model.name} sẽ gặp nhiều may mắn đấy! 🌈 Lynk thấy có quý nhân phù trợ, bạn cứ tự tin làm việc nhé! ⭐",
          "Ui, ngày hôm nay của ${model.name} khá thuận lợi nha! 💫 Tài lộc hanh thông, công việc suôn sẻ. Nhớ giữ tâm trạng vui vẻ nhé bạn! 😊",
          "Lynk thấy hôm nay ${model.name} nên chủ động trong mọi việc! ✨ Vận may đang mỉm cười với bạn đấy! Cố lên nào! 💪"
        ];
      case 'en':
        return [
          "Today ${model.name} will have lots of luck! 🌈 Lynk sees helpful people around you, just work confidently! ⭐",
          "Oh, today looks quite favorable for ${model.name}! 💫 Fortune flows smoothly, work goes well. Remember to keep a positive mood! 😊",
          "Lynk thinks ${model.name} should take initiative today! ✨ Luck is smiling at you! Keep it up! 💪"
        ];
      case 'ko':
        return [
          "오늘 ${model.name}님은 많은 행운을 만날 거예요! 🌈 린크가 보니 귀인이 도와줄 거예요, 자신있게 일하세요! ⭐",
          "와, 오늘은 ${model.name}님께 꽤 순조로운 날이네요! 💫 재물운이 좋고 일이 잘 풀려요. 긍정적인 마음을 유지하세요! 😊",
          "린크가 보니 오늘 ${model.name}님은 주도적으로 행동하면 좋겠어요! ✨ 행운이 당신에게 미소짓고 있어요! 힘내세요! 💪"
        ];
      default:
        return [
          "Hôm nay ${model.name} sẽ gặp nhiều may mắn đấy! 🌈 Lynk thấy có quý nhân phù trợ, bạn cứ tự tin làm việc nhé! ⭐",
          "Ui, ngày hôm nay của ${model.name} khá thuận lợi nha! 💫 Tài lộc hanh thông, công việc suôn sẻ. Nhớ giữ tâm trạng vui vẻ nhé bạn! 😊",
          "Lynk thấy hôm nay ${model.name} nên chủ động trong mọi việc! ✨ Vận may đang mỉm cười với bạn đấy! Cố lên nào! 💪"
        ];
    }
  }

  String _getAstrologyPrompt(String formattedDate, String genderText) {
    final currentLanguage = streamCurrentLanguage.value;
    switch (currentLanguage) {
      case 'vi':
        return '''Bạn là chuyên gia huyền học. Thông tin:
        Tên: ${model.name}
        Sinh: $formattedDate
        Giới tính: $genderText
        
        Cho biết tử vi ngắn gọn. 
        QUAN TRỌNG: 
        1. Trả lời ĐÚNG 2-70 từ, cợt nhã vui vẻ, thêm emoji.
        2. Thêm tag cảm xúc phù hợp ở đầu câu trả lời theo format: [EMOTION:key]
        Các key có thể dùng: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
      case 'en':
        return '''You are an astrology expert. Information:
        Name: ${model.name}
        Born: $formattedDate
        Gender: ${model.gender}
        
        Provide a brief horoscope reading. 
        IMPORTANT: 
        1. Reply with EXACTLY 2-70 words, be playful and cheerful, add emojis.
        2. Add appropriate emotion tag at the beginning in format: [EMOTION:key]
        Available keys: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
      case 'ko':
        return '''당신은 점성술 전문가입니다. 정보:
        이름: ${model.name}
        생일: $formattedDate
        성별: ${model.gender == 'male' ? '남성' : '여성'}
        
        간단한 운세를 알려주세요. 
        중요: 
        1. 정확히 2-70단어로 답하고, 장난스럽고 즐겁게, 이모지 추가.
        2. 시작 부분에 적절한 감정 태그 추가: [EMOTION:key]
        사용 가능한 키: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
      default:
        return '''Bạn là chuyên gia huyền học. Thông tin:
        Tên: ${model.name}
        Sinh: $formattedDate
        Giới tính: $genderText
        
        Cho biết tử vi ngắn gọn. 
        QUAN TRỌNG: 
        1. Trả lời ĐÚNG 2-70 từ, cợt nhã vui vẻ, thêm emoji.
        2. Thêm tag cảm xúc phù hợp ở đầu câu trả lời theo format: [EMOTION:key]
        Các key có thể dùng: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
    }
  }

  String _getDailyFortunePrompt(String formattedDate, String genderText, String todayDate) {
    final currentLanguage = streamCurrentLanguage.value;
    switch (currentLanguage) {
      case 'vi':
        return '''Chuyên gia huyền học. Thông tin:
        Tên: ${model.name}  
        Sinh: $formattedDate
        Giới tính: $genderText
        
        Vận trình hôm nay ($todayDate) thế nào? 
        QUAN TRỌNG: 
        1. Trả lời ĐÚNG 2-70 từ, cợt nhã, thêm emoji.
        2. Thêm tag cảm xúc phù hợp ở đầu câu trả lời theo format: [EMOTION:key]
        Các key có thể dùng: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
      case 'en':
        return '''Astrology expert. Information:
        Name: ${model.name}  
        Born: $formattedDate
        Gender: ${model.gender}
        
        How is today's ($todayDate) fortune? 
        IMPORTANT: 
        1. Reply with EXACTLY 2-70 words, be playful, add emojis.
        2. Add appropriate emotion tag at the beginning in format: [EMOTION:key]
        Available keys: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
      case 'ko':
        return '''점성술 전문가. 정보:
        이름: ${model.name}  
        생일: $formattedDate
        성별: ${model.gender == 'male' ? '남성' : '여성'}
        
        오늘($todayDate)의 운세는 어떤가요? 
        중요: 
        1. 정확히 2-70단어로 답하고, 장난스럽게, 이모지 추가.
        2. 시작 부분에 적절한 감정 태그 추가: [EMOTION:key]
        사용 가능한 키: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
      default:
        return '''Chuyên gia huyền học. Thông tin:
        Tên: ${model.name}  
        Sinh: $formattedDate
        Giới tính: $genderText
        
        Vận trình hôm nay ($todayDate) thế nào? 
        QUAN TRỌNG: 
        1. Trả lời ĐÚNG 2-70 từ, cợt nhã, thêm emoji.
        2. Thêm tag cảm xúc phù hợp ở đầu câu trả lời theo format: [EMOTION:key]
        Các key có thể dùng: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
    }
  }

  String _getCVResponseMessage() {
    final currentLanguage = streamCurrentLanguage.value;
    switch (currentLanguage) {
      case 'vi':
        return "${model.name} ơi, Lynk sẽ nhờ em Lynk Vi xem CV giúp bạn ngay nha! CV chuẩn sẽ giúp bạn thành công đó nha!";
      case 'en':
        return "${model.name}, Lynk will ask Lynk Vi to help review your CV right away! A professional CV will help you succeed!";
      case 'ko':
        return "${model.name}님, 린크가 린크비에게 CV 검토를 부탁할게요! 전문적인 CV가 성공에 도움이 될 거예요!";
      default:
        return "${model.name} ơi, Lynk sẽ nhờ em Lynk Vi xem CV giúp bạn ngay nha! CV chuẩn sẽ giúp bạn thành công đó nha!";
    }
  }

  String _getErrorMessage() {
    final currentLanguage = streamCurrentLanguage.value;
    switch (currentLanguage) {
      case 'vi':
        return "Ui, Lynk đang gặp chút trục trặc! 😅 ${model.name} thử hỏi lại nhé! 🌟";
      case 'en':
        return "Oops, Lynk is having a little trouble! 😅 ${model.name}, please try asking again! 🌟";
      case 'ko':
        return "어머, 린크가 조금 문제가 있네요! 😅 ${model.name}님, 다시 한번 물어봐 주세요! 🌟";
      default:
        return "Ui, Lynk đang gặp chút trục trặc! 😅 ${model.name} thử hỏi lại nhé! 🌟";
    }
  }

  String _getMainChatPrompt({
    required String userMessage,
    required bool isAskingAboutCV,
  }) {
    final currentLanguage = streamCurrentLanguage.value;
    final formattedDate = DateFormat('dd/MM/yyyy').format(model.dateTime ?? DateTime.now());
    final genderText = model.gender == 'male'
        ? (currentLanguage == 'vi' ? 'Nam' : currentLanguage == 'en' ? 'Male' : '남성')
        : (currentLanguage == 'vi' ? 'Nữ' : currentLanguage == 'en' ? 'Female' : '여성');
    
    // Get current date and time info
    final now = DateTime.now();
    final currentDate = DateFormat('dd/MM/yyyy').format(now);
    final currentTime = DateFormat('HH:mm').format(now);
    final dayOfWeek = _getDayOfWeek(now.weekday, currentLanguage);
    final timeOfDay = _getTimeOfDay(now.hour, currentLanguage);

    if (isAskingAboutCV) {
      switch (currentLanguage) {
        case 'vi':
          return '''Thông tin người hỏi:
      Tên: ${model.name}
      Sinh: $formattedDate
      Giới tính: $genderText
      
      Câu hỏi: $userMessage
      
      QUAN TRỌNG: Người dùng muốn xem CV. Trả lời CHÍNH XÁC: "[CV_SCREEN_ID] ${_getCVResponseMessage()}"''';
        case 'en':
          return '''User information:
      Name: ${model.name}
      Born: $formattedDate
      Gender: $genderText
      
      Question: $userMessage
      
      IMPORTANT: User wants to see CV. Reply EXACTLY: "[CV_SCREEN_ID] ${_getCVResponseMessage()}"''';
        case 'ko':
          return '''질문자 정보:
      이름: ${model.name}
      생일: $formattedDate
      성별: $genderText
      
      질문: $userMessage
      
      중요: 사용자가 CV를 보고 싶어합니다. 정확히 답변: "[CV_SCREEN_ID] ${_getCVResponseMessage()}"''';
        default:
          return '''Thông tin người hỏi:
      Tên: ${model.name}
      Sinh: $formattedDate
      Giới tính: $genderText
      
      Câu hỏi: $userMessage
      
      QUAN TRỌNG: Người dùng muốn xem CV. Trả lời CHÍNH XÁC: "[CV_SCREEN_ID] ${_getCVResponseMessage()}"''';
      }
    } else {
      switch (currentLanguage) {
        case 'vi':
          return '''Thông tin người hỏi:
      Tên: ${model.name}
      Sinh: $formattedDate
      Giới tính: $genderText
      
      Thời gian hiện tại:
      Ngày: $currentDate ($dayOfWeek)
      Giờ: $currentTime ($timeOfDay)
      
      Câu hỏi: $userMessage
      
      QUAN TRỌNG: 
      1. Trả lời ĐÚNG 50-70 từ, cợt nhã vui vẻ, thêm emoji.
      2. Thêm tag cảm xúc phù hợp ở đầu câu trả lời theo format: [EMOTION:key]
      3. Gợi ý phù hợp với thời gian hiện tại (sáng/trưa/chiều/tối, thứ mấy)
      Các key có thể dùng: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
        case 'en':
          return '''User information:
      Name: ${model.name}
      Born: $formattedDate
      Gender: $genderText
      
      Current time:
      Date: $currentDate ($dayOfWeek)
      Time: $currentTime ($timeOfDay)
      
      Question: $userMessage
      
      IMPORTANT: 
      1. Answer in EXACTLY 50-70 words, be playful and cheerful, add emoji.
      2. Add appropriate emotion tag at the beginning in format: [EMOTION:key]
      3. Suggest things appropriate for current time (morning/afternoon/evening/night, day of week)
      Available keys: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
        case 'ko':
          return '''질문자 정보:
      이름: ${model.name}
      생일: $formattedDate
      성별: $genderText
      
      현재 시간:
      날짜: $currentDate ($dayOfWeek)
      시각: $currentTime ($timeOfDay)
      
      질문: $userMessage
      
      중요: 
      1. 정확히 50-70 단어로 답변, 장난스럽고 즐겁게, 이모지 추가.
      2. 답변 시작에 적절한 감정 태그 추가 형식: [EMOTION:key]
      3. 현재 시간에 맞는 제안하기 (아침/점심/저녁/밤, 요일)
      사용 가능한 키: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
        default:
          return '''Thông tin người hỏi:
      Tên: ${model.name}
      Sinh: $formattedDate
      Giới tính: $genderText
      
      Thời gian hiện tại:
      Ngày: $currentDate ($dayOfWeek)
      Giờ: $currentTime ($timeOfDay)
      
      Câu hỏi: $userMessage
      
      QUAN TRỌNG: 
      1. Trả lời ĐÚNG 50-70 từ, cợt nhã vui vẻ, thêm emoji.
      2. Thêm tag cảm xúc phù hợp ở đầu câu trả lời theo format: [EMOTION:key]
      3. Gợi ý phù hợp với thời gian hiện tại (sáng/trưa/chiều/tối, thứ mấy)
      Các key có thể dùng: happy, amazed, sadboi, scared, dizzy, sleepy, lowenergy, welcoming''';
      }
    }
  }

  Future<void> _generateWelcomeInNewLanguage(String language) async {
    streamLynkState.add(LynkState.thinking);
    streamIsBotReplying.add(true);
    streamShowTypingIndicator.add(true);
    streamBotAlignment.add(const Alignment(0.0, -0.3));

    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(model.dateTime);
    String genderText = model.gender == 'male' ? 'nam' : 'nữ';
    
    String prompt = '';
    switch (language) {
      case 'vi':
        prompt = '''Bạn là LynkAn, một bot thân thiện và vui vẻ. Người dùng vừa chuyển sang tiếng Việt.
        Thông tin người dùng:
        Tên: ${model.name}
        Sinh: $formattedDate
        Giới tính: $genderText
        
        Hãy chào mừng và hỏi thăm vui vẻ, thân thiện. 
        QUAN TRỌNG: 
        1. Trả lời ĐÚNG 20-40 từ, thêm emoji vui vẻ.
        2. Thêm tag cảm xúc [EMOTION:welcoming] ở đầu câu trả lời.''';
        break;
      case 'en':
        prompt = '''You are LynkAn, a friendly and cheerful bot. The user just switched to English.
        User info:
        Name: ${model.name}
        Born: $formattedDate
        Gender: ${model.gender}
        
        Give a warm welcome and ask how they are doing. 
        IMPORTANT: 
        1. Reply with EXACTLY 20-40 words, add fun emojis.
        2. Add emotion tag [EMOTION:welcoming] at the beginning of your response.''';
        break;
      case 'ko':
        prompt = '''당신은 친근하고 즐거운 봇 LynkAn입니다. 사용자가 방금 한국어로 전환했습니다.
        사용자 정보:
        이름: ${model.name}
        생일: $formattedDate
        성별: ${model.gender == 'male' ? '남성' : '여성'}
        
        따뜻하게 인사하고 안부를 물어보세요. 
        중요: 
        1. 정확히 20-40단어로 답하고, 재미있는 이모지를 추가하세요.
        2. 응답 시작 부분에 감정 태그 [EMOTION:welcoming]을 추가하세요.''';
        break;
    }

    try {
      // Try chat API first, then OpenAI
      String botText;
      try {
        final userId = Globals.prefs.getString(SharedPrefsKey.userId);
        final sessionId = Globals.prefs.getString(SharedPrefsKey.sessionId);
        
        final context = {
          'user_info': {
            'name': model.name,
            'gender': model.gender,
            'birth_date': formattedDate,
          },
          'language': language,
          'context_type': 'language_change_welcome',
        };
        
        final chatResponse = await ChatApiService.sendMessage(
          message: prompt,
          userId: userId,
          sessionId: sessionId,
          context: context,
        );
        if (chatResponse.isSuccess) {
          botText = chatResponse.reply!;
        } else {
          throw Exception('Chat API returned empty reply');
        }
      } catch (e) {
        // Fallback to OpenAI
        botText = await AIService.getResponse(
          prompt: prompt,
          language: language,
        );
      }
      
      final (emotionState, cleanMessage) = _extractEmotionAndMessage(botText);
      final sanitizedText = _sanitizeText(cleanMessage);
      
      streamShowTypingIndicator.add(false);
      final layoutForHistory = _getLayoutForText(sanitizedText);
      _setLayoutBasedOnLength(sanitizedText);
      
      streamCurrentBotMessage.add({'sender': 'bot', 'text': sanitizedText});
      streamLynkState.add(emotionState);
      streamIsBotReplying.add(false);
      streamBotMessageVisible.add(true);
      
      _addToChatHistory('bot', sanitizedText, layoutForHistory);
      
      // Show suggestions after welcome message
      Future.delayed(const Duration(seconds: 1), () {
        if (textController.text.trim().isEmpty && !focusNode.hasFocus) {
          streamShowSuggestions.add(true);
        }
      });
      
    } catch (e) {
      streamShowTypingIndicator.add(false);
      // Use fallback welcome based on language
      String fallbackMessage = '';
      switch (language) {
        case 'vi':
          fallbackMessage = "Chào ${model.name}! 🌟 Lynk rất vui được nói chuyện tiếng Việt với bạn! Hôm nay thế nào rồi? 😊";
          break;
        case 'en':
          fallbackMessage = "Hello ${model.name}! 🌟 Lynk is happy to chat in English with you! How's your day going? 😊";
          break;
        case 'ko':
          fallbackMessage = "안녕하세요 ${model.name}님! 🌟 린크가 한국어로 대화할 수 있어서 기뻐요! 오늘 어떻게 지내세요? 😊";
          break;
      }
       
      final layoutForHistory = _getLayoutForText(fallbackMessage);
      _setLayoutBasedOnLength(fallbackMessage);
      streamCurrentBotMessage.add({'sender': 'bot', 'text': fallbackMessage});
      streamLynkState.add(LynkState.welcoming);
      streamIsBotReplying.add(false);
      streamBotMessageVisible.add(true);
      
      _addToChatHistory('bot', fallbackMessage, layoutForHistory);
      
      // Show suggestions
      Future.delayed(const Duration(seconds: 1), () {
        if (textController.text.trim().isEmpty && !focusNode.hasFocus) {
          streamShowSuggestions.add(true);
        }
      });
    }
  }

  String _getDayOfWeek(int weekday, String language) {
    final days = {
      'vi': ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'],
      'en': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
      'ko': ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
    };
    return days[language]?[weekday - 1] ?? days['vi']![weekday - 1];
  }

  String _getTimeOfDay(int hour, String language) {
    if (hour >= 5 && hour < 12) {
      return language == 'vi' ? 'sáng' : language == 'en' ? 'morning' : '아침';
    } else if (hour >= 12 && hour < 17) {
      return language == 'vi' ? 'chiều' : language == 'en' ? 'afternoon' : '오후';
    } else if (hour >= 17 && hour < 21) {
      return language == 'vi' ? 'tối' : language == 'en' ? 'evening' : '저녁';
    } else {
      return language == 'vi' ? 'đêm' : language == 'en' ? 'night' : '밤';
    }
  }
}