import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/background/flame/background_game.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/flame/lynk_flame_widget.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/bloc/chat_bloc.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/chat_message_bubble.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/chatgpt_input.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/mystical_suggestion_chips.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/animated_product_text.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/modern_typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final ProfileModel model;
  final bool isInit;
  final bool isFromZodiacSelection;
  
  ChatScreen({
    required this.model, 
    required this.isInit,
    this.isFromZodiacSelection = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late ChatBloc _bloc;
  late final BackgroundGame _backgroundGame;
  late TimeOfDayState _currentTimeOfDay;

  @override
  void initState() {
    super.initState();
    _bloc = ChatBloc(context, widget.model, widget.isInit, isFromZodiacSelection: widget.isFromZodiacSelection);
    _updateTimeOfDay();
    _backgroundGame = BackgroundGame(
      initialWeather: WeatherState.clear,
      initialTimeOfDay: _currentTimeOfDay,
    );
    _bloc.focusNode.addListener(_bloc.onFocusChange);
    _bloc.initialBotWelcome();
  }

  @override
  void dispose() {
    _bloc.focusNode.removeListener(_bloc.onFocusChange);
    _bloc.dispose();
    super.dispose();
  }

  void _updateTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 7) {
      _currentTimeOfDay = TimeOfDayState.sunset;
    } else if (hour >= 7 && hour < 17) {
      _currentTimeOfDay = TimeOfDayState.day;
    } else if (hour >= 17 && hour < 19) {
      _currentTimeOfDay = TimeOfDayState.sunrise;
    } else {
      _currentTimeOfDay = TimeOfDayState.night;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: _backgroundGame)),
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      _buildAnimatedBot(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 100.0),
                        child: _buildChatArea(),
                      ),
                      _buildChatHistory(),
                    ],
                  ),
                ),
              ],
            ),
            Align(alignment: Alignment.bottomCenter, child: _buildInputArea()),
            // Connection status indicator
            _buildConnectionStatus(),
            // OpenAI toggle hidden as requested
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBot() {
    return StreamBuilder<Alignment>(
      stream: _bloc.streamBotAlignment,
      initialData: const Alignment(0.0, -0.3),
      builder: (context, snapshotAlignment) {
        return AnimatedAlign(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: snapshotAlignment.data!,
          child: GestureDetector(
            onTap: () {
              _bloc.clearCurrentMessage();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              child: StreamBuilder<LynkState>(
                stream: _bloc.streamLynkState,
                initialData: LynkState.idle,
                builder: (context, snapshotState) {
                  return LynkFlameWidget(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.5,
                    botSize: 1.0,
                    state: snapshotState.data!,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatArea() {
    return Stack(
      children: [
        _buildBotResponse(),
      ],
    );
  }

  Widget _buildBotResponse() {
    return StreamBuilder<bool>(
      stream: _bloc.streamBotMessageVisible,
      initialData: true,
      builder: (context, snapshotVisible) {
        if (!snapshotVisible.data!) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<bool>(
          stream: _bloc.streamShowTypingIndicator,
          initialData: false,
          builder: (context, snapshotTyping) {
            final showTyping = snapshotTyping.data!;
            if (showTyping) {
              return _buildTypingIndicator();
            }
            return _buildMessageBubble();
          },
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      top: screenHeight * 0.1,
      right: screenWidth * 0.1,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
        child: const CosmicTypingIndicator(
          key: ValueKey('cosmic-typing'),
          size: 80.0,
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    return StreamBuilder<BotReplyLayout>(
      stream: _bloc.streamReplyLayout,
      initialData: BotReplyLayout.short,
      builder: (context, snapshotLayout) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        double? top;
        double? left;
        double? right;

        switch (snapshotLayout.data!) {
          case BotReplyLayout.short:
            top = screenHeight * 0.4;
            right = screenWidth * 0.05;
            left = null;
            break;
          case BotReplyLayout.medium:
            top = screenHeight * 0.5;
            left = screenWidth * 0.1;
            right = screenWidth * 0.1;
            break;
          case BotReplyLayout.long:
            top = screenHeight * 0.3;
            left = screenWidth * 0.05;
            right = screenWidth * 0.05;
            break;
        }

        return AnimatedPositioned(
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          top: top,
          left: left,
          right: right,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: StreamBuilder<Map<String, String>?>(
              stream: _bloc.streamCurrentBotMessage,
              builder: (context, snapshotMessage) {
                final message = snapshotMessage.data;
                if (message != null) {
                  final isZodiacReading = message['type'] == 'zodiac_reading';
                  
                  return GestureDetector(
                    onLongPress: () {
                      _bloc.showChatHistory();
                    },
                    child: StyledChatMessageBubble(
                      key: ValueKey(message['text']),
                      layout: snapshotLayout.data!,
                      messageText: message['text'],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedProductText(
                            color: AppTheme.getTextPrimary(context),
                            text: message['text']!,
                            style: TextStyle(fontSize: AppTextSizes.subTitle),
                            textShadow: [
                              Shadow(
                                color: AppTheme.getGlassColor(context).withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 0),
                              ),
                              Shadow(
                                color: AppTheme.getPrimary(context).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          if (isZodiacReading) ...[
                            const SizedBox(height: 12),
                            _buildZodiacReadingCard(
                              zodiacId: message['zodiac_id'] ?? '',
                              zodiacName: message['zodiac_name'] ?? '',
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatHistory() {
    return StreamBuilder<bool>(
      stream: _bloc.streamShowHistory,
      initialData: false,
      builder: (context, snapshotShow) {
        if (!snapshotShow.data!) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<List<ChatMessage>>(
          stream: _bloc.streamChatHistory,
          initialData: [],
          builder: (context, snapshotHistory) {
            final history = snapshotHistory.data!;
            if (history.isEmpty) {
              return const SizedBox.shrink();
            }

            return Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _bloc.hideChatHistory();
                },
                child: Container(
                  color: AppColors.glassDark.withValues(alpha: 0.5),
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: AppTheme.getGlassColor(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.getGlassColor(context).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final message = history[index];
                              final isUser = message.sender == 'user';

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: isUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: isUser ? 40 : 0,
                                        right: isUser ? 0 : 40,
                                      ),
                                      child: isUser
                                          ? ChatMessageBubble(
                                        child: Text(
                                          message.text,
                                          style: TextStyle(
                                            color: AppTheme.getTextPrimary(context),
                                            fontSize: AppTextSizes.title,
                                            shadows: [
                                              Shadow(
                                                color: AppTheme.getGlassColor(context).withValues(alpha: 0.5),
                                                blurRadius: 8,
                                                offset: const Offset(0, 0),
                                              ),
                                              Shadow(
                                                color: AppTheme.getPrimary(context).withValues(alpha: 0.3),
                                                blurRadius: 15,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        isUserMessage: true,
                                        layout: BotReplyLayout.short,
                                        messageText: message.text,
                                      )
                                          : StyledChatMessageBubble(
                                        layout: message.layout ?? BotReplyLayout.medium,
                                        messageText: message.text,
                                        child: AnimatedProductText(
                                          text: message.text,
                                          color: AppTheme.getTextPrimary(context),
                                          style: TextStyle(
                                            fontSize: AppTextSizes.title,
                                          ),
                                          textShadow: [
                                            Shadow(
                                              color: AppTheme.getGlassColor(context).withValues(alpha: 0.6),
                                              blurRadius: 10,
                                              offset: const Offset(0, 0),
                                            ),
                                            Shadow(
                                              color: AppTheme.getPrimary(context).withValues(alpha: 0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          typingSpeed: Duration.zero, // No animation for history
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: AppTheme.getGlassColor(context).withValues(alpha: 0.5),
                                          fontSize: AppTextSizes.title,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                     ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildZodiacReadingCard({
    required String zodiacId,
    required String zodiacName,
  }) {
    return InkWell(
      onTap: () => _bloc.showZodiacReading(),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.2),
              AppColors.secondary.withValues(alpha: 0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📖 ${AppLocalizations.text(LangKey.view_zodiac_detail)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppLocalizations.text(LangKey.zodiac_reading_subtitle).replaceAll("%s", zodiacName)}',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16.0,
          AppSizes.minPadding,
          16.0,
          AppSizes.maxPadding
      ),
      child: StreamBuilder<bool>(
        stream: _bloc.streamIsBotReplying,
        initialData: false,
        builder: (context, snapshot) {
          final isReplying = snapshot.data!;

          return StreamBuilder<String>(
            stream: _bloc.streamPlaceholder,
            initialData: AppLocalizations.text(LangKey.chat_input_placeholder),
            builder: (context, placeholderSnapshot) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mystical suggestion chips
                  StreamBuilder<bool>(
                    stream: _bloc.streamShowSuggestions,
                    initialData: true,
                    builder: (context, suggestionsSnapshot) {
                      return StreamBuilder<String>(
                        stream: _bloc.streamCurrentLanguage,
                        initialData: 'vi',
                        builder: (context, languageSnapshot) {
                          return MysticalSuggestionChips(
                            isVisible: suggestionsSnapshot.data! && !isReplying,
                            language: languageSnapshot.data!,
                            onSuggestionTap: (suggestion) {
                              _bloc.handleSuggestionTap(suggestion);
                            },
                          );
                        },
                      );
                    },
                  ),
                  // Chat input
                  ChatGPTInput(
                    controller: _bloc.textController,
                    focusNode: _bloc.focusNode,
                    hintText: placeholderSnapshot.data!,
                    onSend: _bloc.handleSendMessage,
                    onVoicePressed: () {
                      // TODO: Implement voice recording
                    },
                    isEnabled: !isReplying,
                    onTextChanged: _bloc.onTextChanged,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: StreamBuilder<String>(
        stream: _bloc.streamConnectionStatus,
        initialData: 'connecting',
        builder: (context, snapshot) {
          final status = snapshot.data ?? 'disconnected';
          final isConnected = status == 'connected';
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'connected'
                  ? Colors.green.withValues(alpha: 0.2)
                  : status == 'connecting'
                      ? Colors.blue.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: status == 'connected'
                    ? Colors.green.withValues(alpha: 0.5)
                    : status == 'connecting'
                        ? Colors.blue.withValues(alpha: 0.5)
                        : Colors.orange.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: status == 'connected'
                        ? Colors.green
                        : status == 'connecting'
                            ? Colors.blue
                            : Colors.orange,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  status == 'connected' 
                      ? 'Connected' 
                      : status == 'connecting' 
                          ? 'Connecting...' 
                          : 'Disconnected',
                  style: TextStyle(
                    color: status == 'connected' 
                        ? Colors.green 
                        : status == 'connecting'
                            ? Colors.blue
                            : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}