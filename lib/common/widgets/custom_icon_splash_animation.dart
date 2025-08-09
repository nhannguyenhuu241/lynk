part of widget;

class CustomIconSplashAnimation extends StatefulWidget {
  final String iconPath;
  final double size;

  const CustomIconSplashAnimation({
    Key? key,
    required this.iconPath,
    this.size = 120.0,
  }) : super(key: key);

  @override
  State<CustomIconSplashAnimation> createState() =>
      _CustomIconSplashAnimationState();
}

class _CustomIconSplashAnimationState extends State<CustomIconSplashAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  // late AnimationController _rotationController; // Removed rotation controller
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  // late Animation<double> _rotationAnimation; // Removed rotation animation
  late Animation<double> _fadeAnimation;
  // late Animation<double> _glowAnimation; // Removed - not used in bright theme
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();

    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Rotation animation controller - REMOVED
    // _rotationController = AnimationController(
    //   duration: const Duration(milliseconds: 2000),
    //   vsync: this,
    // );

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Scale animation - gentle bounce effect
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
    );

    // Rotation animation - smooth rotation - REMOVED
    // _rotationAnimation = Tween<double>(
    //   begin: 0.0,
    //   end: 2 * math.pi,
    // ).animate(
    //   CurvedAnimation(
    //     parent: _rotationController,
    //     curve: Curves.easeInOut,
    //   ),
    // );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    // Glow animation removed for bright theme - shadows handled in splash_screen.dart

    // Start animations
    _fadeController.forward();
    _delayTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        _scaleController.forward();
      }
    });

    // After scale completes, start gentle rotation - REMOVED
    // _scaleController.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     _rotationController.repeat();
    //   }
    // });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _scaleController.dispose();
    // _rotationController.dispose(); // Removed rotation controller disposal
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleController,
          // _rotationController, // Removed from animation merge
          _fadeController,
        ]),
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.size / 4),
                  child: Image.asset(
                    widget.iconPath,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
