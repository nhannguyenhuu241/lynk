import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';

class ChatMessageBubble extends StatefulWidget {
  final Widget child;
  final bool isUserMessage;
  final BotReplyLayout layout;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDeliveryStatus;
  final bool isDelivered;
  final bool isRead;
  final String? messageText;

  const ChatMessageBubble({
    super.key,
    required this.child,
    required this.isUserMessage,
    required this.layout,
    this.onTap,
    this.onLongPress,
    this.showDeliveryStatus = false,
    this.isDelivered = true,
    this.isRead = false,
    this.messageText,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;
  bool _showShareButton = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: widget.isUserMessage ? 30.0 : -30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Enhanced color scheme with better contrast and cosmic theme integration
    final Color baseUserColor = AppColors.primary;
    final Color baseBotColor = AppColors.neutral50;

    final glassColor = widget.isUserMessage
        ? baseUserColor.withValues(alpha: 0.9)
        : baseBotColor.withValues(alpha: 0.95);

    final alignment = widget.isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final maxWidth = _getMaxWidth(context);
    final borderRadius = _getModernBorderRadius();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.maxPadding, 
                vertical: AppSizes.minPadding / 2,
              ),
              child: Column(
                crossAxisAlignment: alignment,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showShareButton = !_showShareButton;
                          });
                          widget.onTap?.call();
                        },
                        onLongPress: widget.onLongPress,
                        onTapDown: (_) => _setPressed(true),
                        onTapUp: (_) => _setPressed(false),
                        onTapCancel: () => _setPressed(false),
                        child: AnimatedScale(
                          scale: _isPressed ? 0.98 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                          child: Container(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: ClipRRect(
                              borderRadius: borderRadius,
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: _getAdaptivePadding(),
                                  decoration: BoxDecoration(
                                    color: glassColor,
                                    borderRadius: borderRadius,
                                    gradient: _getBubbleGradient(),
                                    border: Border.all(
                                      color: _getBorderColor(),
                                      width: widget.isUserMessage ? 0.0 : 1.0,
                                    ),
                                    boxShadow: _getBubbleShadow(),
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                                    ),
                                    child: SingleChildScrollView(
                                      child: SafeTextWrapper(child: widget.child),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!widget.isUserMessage && widget.messageText != null)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          top: _showShareButton ? -10 : -5,
                          right: -10,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _showShareButton ? 1.0 : 0.0,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: _showShareButton ? 1.0 : 0.0,
                              child: _buildShareButton(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (widget.showDeliveryStatus && widget.isUserMessage) ...[
                    const SizedBox(height: 4),
                    _buildDeliveryStatus()
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _setPressed(bool pressed) {
    if (mounted) {
      setState(() {
        _isPressed = pressed;
      });
    }
  }

  double _getMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (widget.isUserMessage) {
      return screenWidth * 0.75;
    }
    
    // Always return long format width for bot messages
    return screenWidth * 0.9;
  }

  BorderRadius _getModernBorderRadius() {
    // Modern asymmetric corners for more natural conversation flow
    if (widget.isUserMessage) {
      return const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(8),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    }
  }

  EdgeInsets _getAdaptivePadding() {
    // Adaptive padding based on content and message type
    final basePadding = widget.isUserMessage ? 14.0 : 16.0;
    // Always use long format padding for consistent display
    final verticalPadding = 16.0;
    
    return EdgeInsets.symmetric(
      horizontal: basePadding,
      vertical: verticalPadding,
    );
  }

  LinearGradient? _getBubbleGradient() {
    if (!widget.isUserMessage) return null;
    
    return LinearGradient(
      colors: [
        AppColors.primary,
        AppColors.primaryDark,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _getBorderColor() {
    if (widget.isUserMessage) return Colors.transparent;
    
    return AppColors.neutral300.withValues(alpha: 0.5);
  }

  List<BoxShadow> _getBubbleShadow() {
    if (!widget.isUserMessage) {
      return [
        BoxShadow(
          color: AppColors.neutral400.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    // Enhanced shadow for user messages
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.12),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  Widget _buildDeliveryStatus() {
    Color statusColor = AppColors.neutral500;
    IconData statusIcon = Icons.access_time;
    
    if (widget.isDelivered) {
      statusColor = widget.isRead ? AppColors.secondary : AppColors.neutral400;
      statusIcon = widget.isRead ? Icons.done_all : Icons.done;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(
          statusIcon,
          size: 16,
          color: statusColor,
        ),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (widget.messageText != null && widget.messageText!.isNotEmpty) {
            // Only share functionality - no URL opening
            try {
              await Share.share(
                widget.messageText!,
                subject: 'Tin nhắn từ Lynk',
              );
            } catch (e) {
              debugPrint('Share error: $e');
            }
            
            // Hide share button after action
            setState(() {
              _showShareButton = false;
            });
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.share_rounded,
            size: 20,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class StyledChatMessageBubble extends StatefulWidget {
  final Widget child;
  final BotReplyLayout layout;
  final TailDirection? tail;
  final String? messageText;

  final double radius;
  final double tailSize;

  const StyledChatMessageBubble({
    super.key,
    required this.child,
    required this.layout,
    this.tail,
    this.radius = 18.0,
    this.tailSize = 12.0,
    this.messageText,
  });
  
  @override
  State<StyledChatMessageBubble> createState() => _StyledChatMessageBubbleState();
}

class _StyledChatMessageBubbleState extends State<StyledChatMessageBubble> {
  bool _showShareButton = false;

  @override
  Widget build(BuildContext context) {
    // Always use long format width
    final maxWidth = MediaQuery.of(context).size.width * 0.95;

    final tailDirection = (widget.tail != null)
        ? widget.tail!
        : TailDirection.top;  // Always use top direction since we're always in long format

    EdgeInsets dynamicPadding;
    const basePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    switch (tailDirection) {
      case TailDirection.top:
        dynamicPadding = EdgeInsets.fromLTRB(
          basePadding.left,
          basePadding.top + widget.tailSize,
          basePadding.right,
          basePadding.bottom,
        );
        break;
      case TailDirection.bottom:
        dynamicPadding = EdgeInsets.fromLTRB(
          basePadding.left,
          basePadding.top,
          basePadding.right,
          basePadding.bottom + widget.tailSize,
        );
        break;
      default:
        dynamicPadding = basePadding;
        break;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showShareButton = !_showShareButton;
            });
          },
          child: ClipPath(
            clipper: BubbleClipper(
              tailDirection: tailDirection,
              radius: widget.radius,
              tailSize: widget.tailSize,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.25),
                ),
                padding: dynamicPadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                  ),
                  child: SingleChildScrollView(
                    child: SafeTextWrapper(child: widget.child),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.messageText != null)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            top: _showShareButton ? -10 : -5,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showShareButton ? 1.0 : 0.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: _showShareButton ? 1.0 : 0.0,
                child: _buildShareButton(context),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildShareButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (widget.messageText != null && widget.messageText!.isNotEmpty) {
            // Only share functionality - no URL opening
            try {
              await Share.share(
                widget.messageText!,
                subject: 'Tin nhắn từ Lynk',
              );
            } catch (e) {
              debugPrint('Share error: $e');
            }
            
            // Hide share button after action
            setState(() {
              _showShareButton = false;
            });
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.share_rounded,
            size: 20,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

/// Widget wrapper để xử lý text an toàn với UTF-16
class SafeTextWrapper extends StatelessWidget {
  final Widget child;

  const SafeTextWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (child is Text) {
      final textWidget = child as Text;
      final safeText = _sanitizeText(textWidget.data ?? '');

      return Text(
        safeText,
        style: textWidget.style,
        strutStyle: textWidget.strutStyle,
        textAlign: textWidget.textAlign,
        textDirection: textWidget.textDirection,
        locale: textWidget.locale,
        softWrap: textWidget.softWrap,
        overflow: textWidget.overflow,
        textScaleFactor: textWidget.textScaleFactor,
        maxLines: textWidget.maxLines,
        semanticsLabel: textWidget.semanticsLabel,
        textWidthBasis: textWidget.textWidthBasis,
        textHeightBehavior: textWidget.textHeightBehavior,
      );
    }
    if (child is RichText) {
      return Builder(
        builder: (context) {
          try {
            return child;
          } catch (e) {
            return Text(
              'Nội dung không thể hiển thị',
              style: DefaultTextStyle.of(context).style,
            );
          }
        },
      );
    }
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          debugPrint('Error rendering child in ChatMessageBubble: $e');
          return Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Lỗi hiển thị nội dung',
              style: TextStyle(color: Colors.red.shade400),
            ),
          );
        }
      },
    );
  }

  /// Làm sạch text để đảm bảo UTF-16 hợp lệ
  String _sanitizeText(String text) {
    try {
      final buffer = StringBuffer();

      for (int i = 0; i < text.length; i++) {
        final codeUnit = text.codeUnitAt(i);
        if (_isHighSurrogate(codeUnit)) {
          if (i + 1 < text.length && _isLowSurrogate(text.codeUnitAt(i + 1))) {
            buffer.write(text[i]);
            buffer.write(text[i + 1]);
            i++;
          } else {
            buffer.write('\uFFFD');
          }
        } else if (_isLowSurrogate(codeUnit)) {
          buffer.write('\uFFFD');
        } else {
          buffer.write(text[i]);
        }
      }

      return buffer.toString();
    } catch (e) {
      debugPrint('Error sanitizing text: $e');
      return 'Nội dung không hợp lệ';
    }
  }

  bool _isHighSurrogate(int codeUnit) {
    return codeUnit >= 0xD800 && codeUnit <= 0xDBFF;
  }

  bool _isLowSurrogate(int codeUnit) {
    return codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;
  }
}

class BubbleClipper extends CustomClipper<Path> {
  final TailDirection tailDirection;
  final double radius;
  final double tailSize;

  BubbleClipper({
    required this.tailDirection,
    this.radius = 18.0,
    this.tailSize = 12.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;

    switch (tailDirection) {
      case TailDirection.left:
        path.moveTo(radius + tailSize, 0);
        path.lineTo(w - radius, 0);
        path.arcToPoint(Offset(w, radius), radius: Radius.circular(radius));
        path.lineTo(w, h - radius);
        path.arcToPoint(Offset(w - radius, h), radius: Radius.circular(radius));
        path.lineTo(radius + tailSize, h);
        path.arcToPoint(Offset(tailSize, h - radius),
            radius: Radius.circular(radius));
        path.lineTo(tailSize, h / 2 + tailSize / 2);
        path.quadraticBezierTo(0, h / 2, tailSize, h / 2 - tailSize / 2);
        path.lineTo(tailSize, radius);
        path.arcToPoint(Offset(radius + tailSize, 0),
            radius: Radius.circular(radius));
        break;
      case TailDirection.right:
        path.moveTo(radius, 0);
        path.lineTo(w - radius - tailSize, 0);
        path.arcToPoint(Offset(w - tailSize, radius),
            radius: Radius.circular(radius));
        path.lineTo(w - tailSize, h / 2 - tailSize / 2);
        path.quadraticBezierTo(w, h / 2, w - tailSize, h / 2 + tailSize / 2);
        path.lineTo(w - tailSize, h - radius);
        path.arcToPoint(Offset(w - radius - tailSize, h),
            radius: Radius.circular(radius));
        path.lineTo(radius, h);
        path.arcToPoint(Offset(0, h - radius), radius: Radius.circular(radius));
        path.lineTo(0, radius);
        path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));
        break;
      case TailDirection.top:
        path.moveTo(radius, tailSize);
        path.lineTo(w / 2 - tailSize, tailSize);
        path.quadraticBezierTo(w / 2, 0, w / 2 + tailSize, tailSize);
        path.lineTo(w - radius, tailSize);
        path.arcToPoint(Offset(w, radius + tailSize),
            radius: Radius.circular(radius));
        path.lineTo(w, h - radius);
        path.arcToPoint(Offset(w - radius, h), radius: Radius.circular(radius));
        path.lineTo(radius, h);
        path.arcToPoint(Offset(0, h - radius), radius: Radius.circular(radius));
        path.lineTo(0, radius + tailSize);
        path.arcToPoint(Offset(radius, tailSize),
            radius: Radius.circular(radius));
        break;
      case TailDirection.bottom:
        path.moveTo(radius, 0);
        path.lineTo(w - radius, 0);
        path.arcToPoint(Offset(w, radius), radius: Radius.circular(radius));
        path.lineTo(w, h - radius - tailSize);
        path.arcToPoint(Offset(w - radius, h - tailSize),
            radius: Radius.circular(radius));
        path.lineTo(w / 2 + tailSize, h - tailSize);
        path.quadraticBezierTo(w / 2, h, w / 2 - tailSize, h - tailSize);
        path.lineTo(radius, h - tailSize);
        path.arcToPoint(Offset(0, h - radius - tailSize),
            radius: Radius.circular(radius));
        path.lineTo(0, radius);
        path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}