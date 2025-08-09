import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lynk_an/common/assets.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/utils/extension.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/flame/lynk_flame_widget.dart';
import 'package:lynk_an/common/widgets/widget.dart';
import 'package:lynk_an/presentation/modules/main_modules/information_module/src/bloc/information_name_bloc.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/chat_message_bubble.dart';

class InformationNameScreen extends StatefulWidget {
  const InformationNameScreen({super.key});

  @override
  State<InformationNameScreen> createState() => _InformationNameScreenState();
}

class _InformationNameScreenState extends State<InformationNameScreen>
    with TickerProviderStateMixin {
  late InformationNameBloc _bloc;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _bloc = InformationNameBloc(context);
    _bloc.initialBotWelcome();
    _bloc.focusNode.addListener(() {
      setState(() {});
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
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBot() {
    return StreamBuilder(
        stream: _bloc.streamBotAlignment.output,
        initialData: Alignment(0.0, -0.3),
        builder: (context, snapshotAligment) {
          return AnimatedAlign(
            duration: Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: snapshotAligment.data ?? Alignment(0.0, -0.3),
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
                          return LynkFlameWidget(
                            key: ValueKey(botSize),
                            width: MediaQuery.of(context).size.width * botSize,
                            height: MediaQuery.of(context).size.height * botSize,
                            botSize: 1.6,
                            state: _lynkState,
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
                bubbleAlignment = const Alignment(0.0, 0.2);
                break;
              case BotReplyLayout.long:
                bubbleAlignment = const Alignment(0.0, -0.2);
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
                      textShadow: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: Offset(0, 0),
                        ),
                        Shadow(
                          color: AppColors.white.withValues(alpha: 0.3),
                          blurRadius: 20,  
                          offset: Offset(0, 2),
                        ),
                      ],
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

  Widget _buildNameTextField() {
    final bool isFocused = _bloc.focusNode.hasFocus;
    return Column(
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
                  AppLocalizations.text(LangKey.enter_your_name_here),
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
        // Enhanced text field
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isFocused ? 1.0 : _pulseAnimation.value,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.ultraPadding),
                child: Stack(
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
                                color: AppColors.primary.withValues(alpha: _glowAnimation.value * 0.5),
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
                    // Text field with enhanced styling
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.ultraPadding),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: 60,
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
                              color: AppColors.white.withValues(alpha: isFocused ? 0.9 : 0.6),
                              width: isFocused ? 3 : 2.5,
                            ),
                          ),
                          child: TextField(
                            controller: _bloc.textController,
                            focusNode: _bloc.focusNode,
                            textAlign: TextAlign.center,
                            onChanged: (value) => _bloc.onNameChanged(value),
                            onSubmitted: (value) => _bloc.respondToName(value),
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
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20),
                              hintText: AppLocalizations.text(LangKey.lynk_an_ne),
                              hintStyle: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.7),
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Helper text
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isFocused ? 0.8 : 0.6,
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            child: Text(
              isFocused ? AppLocalizations.text(LangKey.info_press_done_or_wait) : AppLocalizations.text(LangKey.info_tap_here_to_start),
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body() {
    final bool isFocused = _bloc.focusNode.hasFocus;
    return Stack(
      children: [
        Image.asset(
          Assets.imgBackground2,
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
        Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    alignment: isFocused
                        ? Alignment(0.0, -0.75)
                        : Alignment(0.0, -0.2),
                    child: _buildNameTextField(),
                  ),
                  Positioned(
                      bottom: -15,
                      child: Transform.rotate(angle: 15 * (pi / 180), child: _buildAnimatedBot())),
                  Positioned(bottom: 200 , right: AppSizes.maxPadding, left: AppSizes.maxPadding, child: _buildChatArea()),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: Container(
          child: _body(),
        ),
      ),
    );
  }
}