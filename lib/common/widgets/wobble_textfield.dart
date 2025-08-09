part of widget;

class WobbleTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;

  const WobbleTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
  });

  @override
  State<WobbleTextField> createState() => _WobbleTextFieldState();
}

class _WobbleTextFieldState extends State<WobbleTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Tổng thời gian animation
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.015), weight: 1), // Nghiêng phải
      TweenSequenceItem(tween: Tween<double>(begin: 0.015, end: -0.015), weight: 1), // Nghiêng trái
      TweenSequenceItem(tween: Tween<double>(begin: -0.015, end: 0.0), weight: 1), // Về giữa
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus) {
        _controller.forward(from: 0.0); // Chạy animation khi focus
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void wobble() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * math.pi,
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}