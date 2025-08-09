part of widget;

class AnimatedTypingText extends StatefulWidget {
  final String text;
  final Color color;
  final List<Shadow>? textShadow;
  final Duration typingSpeed;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final VoidCallback? onComplete;

  const AnimatedTypingText({
    Key? key,
    required this.text,
    required this.color,
    this.textShadow,
    this.typingSpeed = const Duration(milliseconds: 10),
    this.style,
    this.maxLines,
    this.overflow,
    this.onComplete,
  }) : super(key: key);

  @override
  State<AnimatedTypingText> createState() => _AnimatedTypingTextState();
}

class _AnimatedTypingTextState extends State<AnimatedTypingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        milliseconds: widget.text.length * widget.typingSpeed.inMilliseconds,
      ),
      vsync: this,
    );

    _characterCount = StepTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) {
      // Call onComplete callback when animation finishes
      widget.onComplete?.call();
    });
  }

  @override
  void didUpdateWidget(AnimatedTypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      // Reset animation for new text
      _controller.stop();
      _controller.duration = Duration(
        milliseconds: widget.text.length * widget.typingSpeed.inMilliseconds,
      );
      
      _characterCount = StepTween(
        begin: 0,
        end: widget.text.length,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      
      _controller.forward(from: 0).then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    // Safely dispose animation controller
    try {
      _controller.dispose();
    } catch (e) {
      // Handle disposal error gracefully
      debugPrint('Error disposing typing text animation controller: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        // Ensure we don't exceed the text length
        int endIndex = _characterCount.value.clamp(0, widget.text.length);
        String text = widget.text.substring(0, endIndex);
        return Text(
          text,
          style: (widget.style ?? TextStyle()).copyWith(
            color: widget.color,
            shadows: widget.textShadow,
            fontSize: AppTextSizes.title,
          ),
          maxLines: widget.maxLines,
          overflow: widget.overflow ?? TextOverflow.ellipsis,
        );
      },
    );
  }
}