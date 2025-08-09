import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lynk_an/common/assets.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/utils/extension.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/flame/lynk_flame_widget.dart';
import 'package:lynk_an/common/widgets/widget.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/presentation/modules/main_modules/information_module/src/bloc/information_birthday_bloc.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/chat_message_bubble.dart';

class InformationBirthdayScreen extends StatefulWidget {
  final ProfileModel model;
  InformationBirthdayScreen(this.model);

  @override
  State<InformationBirthdayScreen> createState() => _InformationBirthdayScreenState();
}

class _InformationBirthdayScreenState extends State<InformationBirthdayScreen>
    with TickerProviderStateMixin {
  late InformationBirthdayBloc _bloc;
  late AnimationController _glowController;
  late AnimationController _bounceController;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bloc = InformationBirthdayBloc(context, widget.model);
    _bloc.initialBotWelcome();

    // Initialize glow animation
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Initialize bounce animation
    _bounceController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _bounceController.dispose();
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
                bubbleAlignment =  Alignment(0.9, 0.0);
                break;
              case BotReplyLayout.medium:
                bubbleAlignment =  Alignment(0.0, 0.0);
                break;
              case BotReplyLayout.long:
                bubbleAlignment =  Alignment(0.0, -0.2);
                break;
            }
            return AnimatedAlign(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              alignment: bubbleAlignment,
              child: AnimatedSwitcher(
                duration:  Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Container(
                  key: ValueKey('bot_response_${message['text']}'),
                  child: StyledChatMessageBubble(
                    layout: replyLayout,
                    tail: TailDirection.top,
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

  Widget _buildBirthdayPicker() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Instruction with icon
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cake_rounded,
                      color: AppColors.white.withValues(alpha: 0.9),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                     AppLocalizations.text(LangKey.enter_your_birthday_here),
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.95),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.7),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.celebration_rounded,
                      color: AppColors.white.withValues(alpha: 0.9),
                      size: 28,
                    ),
                  ],
                ),
              ),

              // Main date picker button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.ultraPadding),
                child: GestureDetector(
                  onTap: () => _bloc.selectDate(),
                  child: Stack(
                    children: [
                      // Glow effect
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSizes.ultraPadding),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: _glowAnimation.value),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: _glowAnimation.value * 0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Main container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.ultraPadding),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                          child: Container(
                            height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.white.withValues(alpha: 0.4),
                                  AppColors.white.withValues(alpha: 0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppSizes.ultraPadding),
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.6),
                                width: 2.5,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background pattern
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: BirthdayPatternPainter(),
                                  ),
                                ),
                                // Content
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.calendar_month_rounded,
                                          color: AppColors.white,
                                          size: 32,
                                        ),
                                      ),
                                      Expanded(
                                        child: StreamBuilder<DateTime?>(
                                          stream: _bloc.streamSelectedDate.output,
                                          builder: (context, snapshot) {
                                            final selectedDate = snapshot.data;
                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  selectedDate == null
                                                      ? AppLocalizations.text(LangKey.lynk_an_ne)
                                                      : DateFormat('dd / MM / yyyy').format(selectedDate),
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: selectedDate == null ? 22 : 24,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: selectedDate == null ? 2 : 1,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black.withValues(alpha: 0.3),
                                                        blurRadius: 5,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (selectedDate != null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    DateFormat('HH:mm').format(selectedDate),
                                                    style: TextStyle(
                                                      color: AppColors.white.withValues(alpha: 0.9),
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black.withValues(alpha: 0.3),
                                                          blurRadius: 5,
                                                          offset: const Offset(0, 1),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Tap indicator
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _body() {
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
                  // Bot positioned at top
                  Positioned(
                    top: 16,
                    left: -124,
                    right: 0,
                    child: Transform.rotate(
                      angle: -10 * (pi / 180),
                      child: _buildAnimatedBot(),
                    ),
                  ),
                  // Chat area below bot
                  Positioned(
                    top: 180,
                    right: AppSizes.maxPadding,
                    left: AppSizes.maxPadding,
                    child: _buildChatArea(),
                  ),
                  // Birthday picker positioned lower
                  Align(
                    alignment: Alignment(0.0, 0.3),
                    child: _buildBirthdayPicker(),
                  ),
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

class BirthdayPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      double x = (size.width / 5) * i + 20;
      double y = sin(i * 0.5) * 10 + size.height / 2;
      canvas.drawCircle(Offset(x, y), 8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}