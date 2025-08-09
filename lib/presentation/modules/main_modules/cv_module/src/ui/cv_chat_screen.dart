import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lynk_an/common/assets.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/flame/lynk_flame_widget.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/presentation/modules/main_modules/cv_module/src/bloc/cv_chat_bloc.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/chat_message_bubble.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/animated_product_text.dart';
import 'package:lynk_an/presentation/modules/main_modules/cv_module/src/widget/liquid_glass_input_widget.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/lang_key.dart';

class CVChatScreen extends StatefulWidget {
  final ProfileModel model;
  const CVChatScreen({required this.model});

  @override
  State<CVChatScreen> createState() => _CVChatScreenState();
}

class _CVChatScreenState extends State<CVChatScreen> with TickerProviderStateMixin {
  late CVChatBloc _bloc;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _bubbleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _bubbleAnimation;
  File? _selectedFile;
  bool _showContinueButton = false;
  String? _currentFullResponse;

  @override
  void initState() {
    super.initState();
    _bloc = CVChatBloc(context, widget.model);

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Float animation for buttons
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Bubble animation for chat messages
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bubbleAnimation = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOutCubic,
    );

    _bloc.initialBotWelcome();

    // Removed duplicate file picker listeners since LiquidGlassInputWidget handles file selection
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _bubbleController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCard(context).withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 10),
            Text(AppLocalizations.text(LangKey.cv_oops)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.text(LangKey.close),
              style: TextStyle(color: AppTheme.getPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCard(context).withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.security, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(AppLocalizations.text(LangKey.request_permissions)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.text(LangKey.cv_cancel)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.text(LangKey.open_settings)),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialogInModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCard(context).withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.security, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(AppLocalizations.text(LangKey.request_permissions)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.text(LangKey.cv_cancel)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
              _bloc.triggerFilePicker();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.text(LangKey.open_settings)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Full screen background
          Positioned.fill(
            child: Image.asset(
              Assets.imgBackgroundCV,
              fit: BoxFit.cover,
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          // Main content - full screen
          SafeArea(
            top: false, // Allow full screen for bot
            child: Column(
              children: [
                // Bot and chat area - now full screen
                Expanded(
                  child: Stack(
                    children: [
                      _buildAnimatedBot(),
                      _buildChatArea(),
                      _buildChatHistoryOverlay(),
                      _buildFloatingActions(),
                      // Floating back button
                      _buildFloatingBackButton(),
                    ],
                  ),
                ),
                // Tips suggestions
                // TipsSuggestionWidget(
                //   tips: TipModel.getCVTips(),
                //   onTipTapped: (message) {
                //     _bloc.handleQuestionTap(message);
                //   },
                // ),
                const SizedBox(height: 8),
                // New liquid glass input
                LiquidGlassInputWidget(
                  onSendMessage: (message) {
                    _bloc.handleQuestionTap(message);
                  },
                  onFileSelected: (file) {
                    setState(() {
                      _selectedFile = file;
                    });
                    _bloc.analyzeCV(file);
                  },
                  onMicrophonePressed: () {
                    // TODO: Implement voice input
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.text(LangKey.cv_voice_feature_coming)),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  isLoading: false,
                ),
              ],
            ),
          ),
        ],
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
              // Clear current message or toggle history
              _bloc.toggleChatHistory();
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
    return StreamBuilder<Alignment>(
      stream: _bloc.streamBotAlignment,
      initialData: const Alignment(0.0, -0.3),
      builder: (context, snapshotBotAlignment) {
        return StreamBuilder<BotReplyLayout>(
          stream: _bloc.streamReplyLayout,
          initialData: BotReplyLayout.medium,
          builder: (context, snapshotLayout) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            
            // Calculate bot position
            final botAlignment = snapshotBotAlignment.data!;
            final botSize = screenWidth * 0.5; // Bot size from _buildAnimatedBot
            
            // Calculate bubble position relative to bot
            final botCenterX = screenWidth / 2 + (botAlignment.x * screenWidth / 2);
            final botCenterY = screenHeight / 2 + (botAlignment.y * screenHeight / 2);
            final botBottom = botCenterY + (botSize / 2);
            
            double? top;
            double? left;
            double? right;

            // Position bubble below bot based on bot's current position
            switch (snapshotLayout.data!) {
              case BotReplyLayout.short:
                top = botBottom + 20; // 20px gap below bot
                left = screenWidth * 0.1;
                right = screenWidth * 0.1;
                break;
              case BotReplyLayout.medium:
                top = botBottom + 15; // 15px gap below bot
                left = screenWidth * 0.05;
                right = screenWidth * 0.05;
                break;
              case BotReplyLayout.long:
                top = botBottom + 10; // 10px gap below bot
                left = screenWidth * 0.05;
                right = screenWidth * 0.05;
                break;
            }

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
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
              builder: (context, snapshot) {
                if (snapshot.data == null) return const SizedBox.shrink();

                final message = snapshot.data!;
                final isTruncated = message['isTruncated'] == 'true';

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        _bloc.toggleChatHistory();
                      },
                      child: AnimatedBuilder(
                        animation: _bubbleAnimation,
                        builder: (context, child) {
                          // Start animation when new message appears
                          if (_bubbleController.status != AnimationStatus.completed &&
                              _bubbleController.status != AnimationStatus.forward) {
                            _bubbleController.forward();
                          }
                          return Transform.scale(
                            scale: _bubbleAnimation.value,
                            child: StyledChatMessageBubble(
                              layout: snapshotLayout.data!,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.35, // 35% of screen height
                                ),
                                child: SingleChildScrollView(
                                  child: AnimatedProductText( 
                                    color: AppTheme.getTextPrimary(context),
                                    text: message['text']!,
                                    style: TextStyle(fontSize: 17),
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
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (isTruncated) ...[
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildGlassButton(
                          text: AppLocalizations.text(LangKey.cv_listen_more),
                          icon: Icons.arrow_downward_rounded,
                          onTap: () {
                            _bloc.showMoreContent();
                            // Reset and restart animation for new content
                            _bubbleController.reset();
                            _bubbleController.forward();
                          },
                          color: AppColors.infoLight,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        );
      },
    );
      },
    );
  }

  Widget _buildSuggestedQuestions(List<String> questions) {
    final colors = [
      AppColors.sunriseTop, // Pink pastel replacement
      AppColors.infoLight, // Blue pastel replacement  
      AppColors.secondaryLight, // Teal replacement
      AppColors.sunriseMiddle, // Yellow pastel replacement
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.amber,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.text(LangKey.cv_can_ask),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              final color = colors[index % colors.length];

              return _buildColorfulQuestionChip(question, color);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorfulQuestionChip(String question, Color color) {
    return GestureDetector(
      onTap: () => _bloc.handleQuestionTap(question),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForQuestion(question),
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              question,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForQuestion(String question) {
    if (question.contains(AppLocalizations.text(LangKey.cv_question_strengths).split(' ')[0])) return Icons.star_rounded;
    if (question.contains(AppLocalizations.text(LangKey.cv_question_improve).split(' ')[0])) return Icons.tips_and_updates_rounded;
    if (question.contains(AppLocalizations.text(LangKey.cv_question_position).split(' ')[0])) return Icons.work_rounded;
    if (question.contains(AppLocalizations.text(LangKey.cv_question_experience).split(' ')[0])) return Icons.workspace_premium_rounded;
    if (question.contains(AppLocalizations.text(LangKey.cv_question_skills_missing).split(' ')[0])) return Icons.psychology_rounded;
    if (question.contains(AppLocalizations.text(LangKey.cv_question_layout).split(' ')[0])) return Icons.design_services_rounded;
    if (question.contains(AppLocalizations.text(LangKey.cv_question_impression).split(' ')[0])) return Icons.auto_awesome_rounded;
    if (question.contains(AppLocalizations.text(LangKey.cv_question_salary).split(' ')[0])) return Icons.attach_money_rounded;
    return Icons.help_outline_rounded;
  }

  Widget _buildGlassButton({
    String? text,
    IconData? icon,
    required VoidCallback onTap,
    double size = 50,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(text != null ? 14 : 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (color ?? Colors.white).withValues(alpha: 0.2),
              (color ?? Colors.white).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: (color ?? Colors.white).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (color ?? Colors.black).withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: color ?? Colors.white,
                    size: text != null ? 20 : 24,
                  ),
                if (text != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      color: color ?? Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Positioned(
      right: 20,
      bottom: 180, // Adjusted to be above the new input widget
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCard(context).withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.tips_and_updates, color: Colors.amber),
            const SizedBox(width: 10),
            Text(AppLocalizations.text(LangKey.cv_tips_title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTip(AppLocalizations.text(LangKey.cv_tip_clear_photo)),
            _buildTip(AppLocalizations.text(LangKey.cv_tip_pdf_size)),
            _buildTip(AppLocalizations.text(LangKey.cv_tip_complete_info)),
            _buildTip(AppLocalizations.text(LangKey.cv_tip_good_format)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.text(LangKey.cv_understood),
              style: TextStyle(color: AppTheme.getPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 14),
      ),
    );
  }
  
  Widget _buildChatHistoryOverlay() {
    return StreamBuilder<bool>(
      stream: _bloc.streamShowChatHistory,
      initialData: false,
      builder: (context, snapshot) {
        if (!snapshot.data!) return const SizedBox.shrink();
        
        return Positioned.fill(
          child: GestureDetector(
            onTap: () => _bloc.hideChatHistory(),
            child: Container(
              color: AppColors.glassDark.withValues(alpha: 0.5),
              child: Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from propagating to parent
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
                        child: StreamBuilder<List<CVChatMessage>>(
                        stream: _bloc.streamChatHistory,
                        initialData: const [],
                        builder: (context, historySnapshot) {
                          final history = historySnapshot.data ?? [];
                          
                          if (history.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 60,
                                    color: AppTheme.getGlassColor(context).withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.text(LangKey.cv_no_chat_history),
                                    style: TextStyle(
                                      color: AppTheme.getGlassColor(context).withValues(alpha: 0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return ListView.builder(
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
                                                   fontSize: 17,
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
                                              layout: BotReplyLayout.medium,
                                              messageText: message.text,
                                              child: AnimatedProductText(
                                                text: message.text,
                                                color: AppTheme.getTextPrimary(context),
                                                style: TextStyle(
                                                  fontSize: 17,
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
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
      },
    );
  }

  Widget _buildFloatingBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: _buildGlassButton(
        icon: Icons.arrow_back_ios_rounded,
        onTap: () => Navigator.pop(context),
        size: 45,
      ),
    );
  }
}