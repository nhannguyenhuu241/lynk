import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/chat_message_bubble.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';

/// Model for chat messages with enhanced metadata
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final BotReplyLayout? layout;
  final bool isDelivered;
  final bool isRead;
  final String? messageType; // text, image, product, etc.

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.layout,
    this.isDelivered = true,
    this.isRead = false,
    this.messageType = 'text',
  });
}

/// Modern conversation layout with proper message grouping
class ConversationLayout extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController? scrollController;
  final Function(ChatMessage)? onMessageTap;
  final Function(ChatMessage)? onMessageLongPress;
  final EdgeInsets padding;
  final bool showTimestamps;
  final bool showDeliveryStatus;

  const ConversationLayout({
    Key? key,
    required this.messages,
    this.scrollController,
    this.onMessageTap,
    this.onMessageLongPress,
    this.padding = const EdgeInsets.all(16),
    this.showTimestamps = false,
    this.showDeliveryStatus = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: scrollController,
      padding: padding,
      itemCount: messages.length,
      reverse: true, // Show latest messages at bottom
      itemBuilder: (context, index) {
        final reversedIndex = messages.length - 1 - index;
        final message = messages[reversedIndex];
        final previousMessage = reversedIndex > 0 ? messages[reversedIndex - 1] : null;
        final nextMessage = reversedIndex < messages.length - 1 ? messages[reversedIndex + 1] : null;

        final isGroupStart = _isGroupStart(message, previousMessage);
        final isGroupEnd = _isGroupEnd(message, nextMessage);
        final showTimestamp = _shouldShowTimestamp(message, previousMessage);

        return Column(
          children: [
            if (showTimestamp) ...[
              _buildTimestamp(context, message.timestamp),
              const SizedBox(height: 8),
            ],
            _buildMessageWithGrouping(
              context,
              message,
              isGroupStart: isGroupStart,
              isGroupEnd: isGroupEnd,
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppTheme.getTextSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: AppTextSizes.subTitle,
              color: AppTheme.getTextSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with Lynk',
            style: TextStyle(
              fontSize: AppTextSizes.body,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWithGrouping(
    BuildContext context,
    ChatMessage message, {
    required bool isGroupStart,
    required bool isGroupEnd,
  }) {
    final marginTop = isGroupStart ? 12.0 : 2.0;
    final marginBottom = isGroupEnd ? 12.0 : 2.0;

    return Container(
      margin: EdgeInsets.only(
        top: marginTop,
        bottom: marginBottom,
      ),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            // Bot avatar for grouped messages
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              child: isGroupEnd
                  ? _buildBotAvatar(context)
                  : const SizedBox.shrink(),
            ),
          ],
          Flexible(
            child: ChatMessageBubble(
              isUserMessage: message.isUser,
              layout: message.layout ?? BotReplyLayout.medium,
              showDeliveryStatus: showDeliveryStatus && 
                  message.isUser && 
                  isGroupEnd,
              isDelivered: message.isDelivered,
              isRead: message.isRead,
              onTap: () => onMessageTap?.call(message),
              onLongPress: () => onMessageLongPress?.call(message),
              child: _buildMessageContent(context, message),
            ),
          ),
          if (message.isUser) ...[
            // User avatar for grouped messages
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, bottom: 4),
              child: isGroupEnd
                  ? _buildUserAvatar(context)
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, ChatMessage message) {
    return Text(
      message.text,
      style: TextStyle(
        color: message.isUser 
            ? AppColors.white
            : AppTheme.getTextPrimary(context),
        fontSize: AppTextSizes.body,
        fontWeight: message.isUser ? FontWeight.w500 : FontWeight.w400,
        height: 1.4,
      ),
    );
  }

  Widget _buildBotAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.magic,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.auto_awesome,
          size: 18,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.neutral400,
        border: Border.all(
          color: AppColors.neutral300,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 18,
          color: AppColors.neutral600,
        ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context, DateTime timestamp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getBackground(context).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorder(context),
          width: 0.5,
        ),
      ),
      child: Text(
        _formatTimestamp(timestamp),
        style: TextStyle(
          fontSize: AppTextSizes.tiny,
          color: AppTheme.getTextSecondary(context),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _isGroupStart(ChatMessage message, ChatMessage? previousMessage) {
    if (previousMessage == null) return true;
    if (message.isUser != previousMessage.isUser) return true;
    
    final timeDiff = message.timestamp.difference(previousMessage.timestamp);
    return timeDiff.inMinutes > 5; // Group messages within 5 minutes
  }

  bool _isGroupEnd(ChatMessage message, ChatMessage? nextMessage) {
    if (nextMessage == null) return true;
    if (message.isUser != nextMessage.isUser) return true;
    
    final timeDiff = nextMessage.timestamp.difference(message.timestamp);
    return timeDiff.inMinutes > 5;
  }

  bool _shouldShowTimestamp(ChatMessage message, ChatMessage? previousMessage) {
    if (!showTimestamps) return false;
    if (previousMessage == null) return true;
    
    final timeDiff = message.timestamp.difference(previousMessage.timestamp);
    return timeDiff.inHours >= 1; // Show timestamp every hour
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      // Same day - show time
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Within a week - show day name
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[timestamp.weekday - 1];
    } else {
      // More than a week - show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Enhanced conversation controller for managing message flow
class ConversationController extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  ScrollController get scrollController => _scrollController;

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
    _scrollToBottom();
  }

  void updateMessage(String id, ChatMessage updatedMessage) {
    final index = _messages.indexWhere((msg) => msg.id == id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  void markAsRead(String messageId) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      _messages[index] = ChatMessage(
        id: _messages[index].id,
        text: _messages[index].text,
        isUser: _messages[index].isUser,
        timestamp: _messages[index].timestamp,
        layout: _messages[index].layout,
        isDelivered: _messages[index].isDelivered,
        isRead: true,
        messageType: _messages[index].messageType,
      );
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // ListView is reversed, so 0 is bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}