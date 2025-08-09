part of widget;

class CustomTittleSplashScreen extends StatefulWidget {
  final String title;

  CustomTittleSplashScreen(this.title);

  @override
  State<CustomTittleSplashScreen> createState() => _CustomTittleSplashScreenState();
}

class _CustomTittleSplashScreenState extends State<CustomTittleSplashScreen>  with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _glowController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<double>> _slideAnimations;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final int characterCount = widget.title.length;
    const double stagger = 0.1;

    _fadeAnimations = List.generate(characterCount, (index) {
      final startTime = stagger * index;
      final endTime = startTime + 0.5;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(startTime, endTime.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(characterCount, (index) {
      final startTime = stagger * index;
      final endTime = startTime + 0.5;
      return Tween<double>(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(startTime, endTime.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _glowAnimation = Tween<double>(begin: 5.0, end: 15.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _glowController.repeat(reverse: true);
      }
    });

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _glowController]),
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.title.length, (index) {
            if (widget.title[index] == ' ') {
              return SizedBox(width: AppSizes.maxPadding);
            }
            return Transform.translate(
              offset: Offset(0, _slideAnimations[index].value),
              child: Opacity(
                opacity: _fadeAnimations[index].value,
                child: Text(
                  widget.title[index],
                  style: TextStyle(
                    fontSize: AppTextSizes.header * 2.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: AppFonts.font,
                    shadows: [
                      Shadow(
                        blurRadius: _glowAnimation.value,
                        color: Colors.cyan.withValues(alpha: 0.7),
                      ),
                      Shadow(
                        blurRadius: _glowAnimation.value + 5,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                      const Shadow(
                        blurRadius: 2.0,
                        color: AppColors.white,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}