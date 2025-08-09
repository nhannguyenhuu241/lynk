import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lottie/lottie.dart';

class ChatGPTInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback? onVoicePressed;
  final bool isEnabled;
  final VoidCallback? onTextChanged;

  const ChatGPTInput({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onSend,
    this.onVoicePressed,
    this.isEnabled = true,
    this.onTextChanged,
  }) : super(key: key);

  @override
  State<ChatGPTInput> createState() => _ChatGPTInputState();
}

class _ChatGPTInputState extends State<ChatGPTInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
      widget.onTextChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.neutral300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              enabled: widget.isEnabled,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(
                color: AppColors.neutral900,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onSubmitted: _hasText && widget.isEnabled ? (_) => widget.onSend() : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildSendButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    final isEnabled = widget.isEnabled;
    
    return GestureDetector(
      onTap: isEnabled ? (_hasText ? widget.onSend : widget.onVoicePressed) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _hasText && isEnabled 
              ? AppColors.neutral200
              : isEnabled 
                  ? AppColors.neutral200 
                  : AppColors.neutral300,
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: _hasText
              ? Lottie.asset(
                  key: const ValueKey('send'),
                  'assets/lottie/lot_send.json',
                  width: AppSizes.icon,
                  height: AppSizes.icon,
                  fit: BoxFit.contain,
                  repeat: true,
                )
              : Lottie.asset(
                  key: const ValueKey('voice'),
                  'assets/lottie/lot_voice.json',
                  width: AppSizes.icon,
                  height: AppSizes.icon,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
        ),
      ),
    );
  }
}