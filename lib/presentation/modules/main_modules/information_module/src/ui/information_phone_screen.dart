import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lynk_an/common/assets.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/utils/extension.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/flame/lynk_flame_widget.dart';
import 'package:lynk_an/common/widgets/widget.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/presentation/modules/main_modules/information_module/src/bloc/information_phone_bloc.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/chat_message_bubble.dart';
import 'package:rxdart/rxdart.dart';

class InformationPhoneScreen extends StatefulWidget {
  final ProfileModel model;
  InformationPhoneScreen(this.model);

  @override
  State<InformationPhoneScreen> createState() => _InformationPhoneScreenState();
}

class _InformationPhoneScreenState extends State<InformationPhoneScreen> 
    with TickerProviderStateMixin {
  late InformationPhoneBloc _bloc;
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  final streamIsValidPhone = BehaviorSubject<bool>.seeded(false);

  @override
  void initState() {
    super.initState();
    _bloc = InformationPhoneBloc(context, widget.model);
    _bloc.initialBotWelcome();
    
    // Connect validation stream
    _bloc.streamIsValidPhone.stream.listen((isValid) {
      streamIsValidPhone.add(isValid);
    });
    
    // Initialize glow animation
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _phoneController.addListener(() {
      _bloc.validatePhoneNumber(_phoneController.text);
    });
    
    // Listen to focus changes
    _phoneFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    streamIsValidPhone.close();
    _bloc.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBot() {
    return StreamBuilder(
        stream: _bloc.streamBotAlignment.output,
        initialData: Alignment(0.8, 0.8),
        builder: (context, snapshotAligment) {
          return AnimatedAlign(
            duration: Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: snapshotAligment.data ?? Alignment(0.8, 0.8),
            child: StreamBuilder(
                stream: _bloc.streamBotSize.output,
                initialData: 0.5,
                builder: (context, snapshotBotSize) {
                  double botSize = snapshotBotSize.data ?? 0.5;
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                    width: MediaQuery.of(context).size.width * botSize,
                    height: MediaQuery.of(context).size.width * botSize,
                    child: StreamBuilder(
                        stream: _bloc.streamLynkState.output,
                        initialData: LynkState.welcoming,
                        builder: (context, snapshot) {
                          LynkState _lynkState =
                              snapshot.data ?? LynkState.welcoming;
                          return Transform.scale(
                            scaleX: -1, // Mirror the bot horizontally
                            child: LynkFlameWidget(
                              key: ValueKey(botSize),
                              width: MediaQuery.of(context).size.width * botSize,
                              height: MediaQuery.of(context).size.height * botSize,
                              botSize: 1.6,
                              state: _lynkState,
                            ),
                          );
                        }),
                  );
                }),
          );
        });
  }

  Widget _buildChatArea() {
    return Stack(
      children: [
        _buildBotResponse(),
      ],
    );
  }

  Widget _buildBotResponse() {
    return StreamBuilder<Map<String, String>?>(
      stream: _bloc.streamCurrentBotMessage.output,
      builder: (context, snapshotMessage) {
        if (snapshotMessage.data == null) {
          return const SizedBox.shrink();
        }
        final message = snapshotMessage.data!;
        return StreamBuilder<BotReplyLayout>(
          stream: _bloc.streamBotReply.output,
          initialData: BotReplyLayout.medium,
          builder: (context, snapshotLayout) {
            final replyLayout = snapshotLayout.data!;
            Alignment bubbleAlignment;
            switch (replyLayout) {
              case BotReplyLayout.short:
                bubbleAlignment = const Alignment(0.9, 0.0);
                break;
              case BotReplyLayout.medium:
                bubbleAlignment = Alignment(0.0, 0.0);
                break;
              case BotReplyLayout.long:
                bubbleAlignment = const Alignment(0.0, -0.3);
                break;
            }
            return AnimatedAlign(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              alignment: bubbleAlignment,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Container(
                  key: ValueKey('bot_response_${message['text']}'),
                  child: StyledChatMessageBubble(
                    layout: replyLayout,
                    tail: TailDirection.bottom,
                    child: AnimatedTypingText(
                      text: message['text']!,
                      color: AppColors.black,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                      key: ValueKey(message['text']!),
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

  Widget _buildPhoneInput() {
    final bool isFocused = _phoneFocusNode.hasFocus;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.maxPadding,
          vertical: AppSizes.maxPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Instruction text
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isFocused ? 0.0 : 1.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    color: AppColors.white.withValues(alpha: 0.9),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.text(LangKey.info_phone_optional_hint),
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_downward_rounded,
                    color: AppColors.white.withValues(alpha: 0.9),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          // Animated phone input with glow effect
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isFocused ? 1.0 : _pulseAnimation.value,
                child: StreamBuilder<String?>(
                  stream: _bloc.streamPhoneError.output,
                  builder: (context, errorSnapshot) {
                    bool hasError = errorSnapshot.data != null;
                    return Stack(
                      children: [
                        // Glow effect
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppSizes.ultraPadding),
                                boxShadow: [
                                  BoxShadow(
                                    color: hasError
                                        ? AppColors.error.withValues(alpha: _glowAnimation.value * 0.5)
                                        : AppColors.primary.withValues(alpha: _glowAnimation.value * 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: AppColors.white.withValues(alpha: _glowAnimation.value * 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Text field with glass morphism
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.ultraPadding),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: 68,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.white.withValues(alpha: isFocused ? 0.5 : 0.4),
                                    AppColors.white.withValues(alpha: isFocused ? 0.4 : 0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(AppSizes.ultraPadding),
                                border: Border.all(
                                  color: hasError  
                                      ? AppColors.error.withValues(alpha: 0.9)
                                      : AppColors.white.withValues(alpha: isFocused ? 0.9 : 0.6),
                                  width: isFocused ? 3 : 2.5,
                                ),
                              ),
                              child: TextField(
                                controller: _phoneController,
                                focusNode: _phoneFocusNode,
                                keyboardType: TextInputType.phone,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: AppTextSizes.title,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 5,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (value) {
                                  if (streamIsValidPhone.value == true) {
                                    _phoneFocusNode.unfocus();
                                    _bloc.handlePhoneSubmit(value);
                                  }
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[\d\+\-\s\(\)]')),
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  hintText: AppLocalizations.text(LangKey.info_phone_hint),
                                  hintStyle: TextStyle(
                                    color: AppColors.white.withValues(alpha: 0.7),
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.phone_android_rounded,
                                    color: hasError 
                                        ? AppColors.error 
                                        : AppColors.white.withValues(alpha: 0.7),
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          // Continue button
          const SizedBox(height: 24),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isFocused ? 0.0 : 1.0,
            child: GestureDetector(
              onTap: () {
                _bloc.handleSkipPhone();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.primary.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.ultraPadding),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.text(LangKey.continueString),
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _body() {
    return GestureDetector(
      onTap: () {
        // When tapping outside, check if phone is valid and submit
        if (_phoneFocusNode.hasFocus) {
          _phoneFocusNode.unfocus();
          if (streamIsValidPhone.value == true) {
            _bloc.handlePhoneSubmit(_phoneController.text);
          }
        }
      },
      child: Stack(
        children: [
          Image.asset(
            Assets.imgBackground2,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          SafeArea(
            child: Column(
            children: [
              // Phone input section at the top
              Expanded(
                flex: 2,
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  alignment: _phoneFocusNode.hasFocus 
                      ? Alignment(0.0, -0.5)  // Move up when focused
                      : Alignment(0.0, 0.0),   // Center when not focused
                  child: _buildPhoneInput(),
                ),
              ),
              // Bot at the bottom
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Stack(
                  children: [
                    // Chat bubble above bot

                    // Bot at bottom right
                    Positioned(
                      bottom: -15,
                      right: -15,
                      child: Transform.rotate(
                        angle: -15 * (pi / 180),
                        child: _buildAnimatedBot(),
                      ),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).size.width * 0.45, // Position above bot
                      left: AppSizes.maxPadding,
                      right: AppSizes.maxPadding, // Full width
                      child: _buildChatArea(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Push content up when keyboard shows
        body: _body(),
      ),
    );
  }
}