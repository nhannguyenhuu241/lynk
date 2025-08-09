part of widget;

class CustomGenderOption extends StatefulWidget {
  final String gender;
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomGenderOption({
    Key? key,
    required this.gender,
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomGenderOption> createState() => _CustomGenderOptionState();
}

class _CustomGenderOptionState extends State<CustomGenderOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              width: 150,
              height: 180,
              child: Stack(
                children: [
                  // Glow effect when selected
                  if (widget.isSelected)
                    Positioned.fill(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: widget.isSelected ? 0.2 : 0.0,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color,
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Main glass container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: widget.isSelected ? 12 : 10,
                        sigmaY: widget.isSelected ? 12 : 10,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.isSelected
                                ? [
                              widget.color.withValues(alpha: 0.25),
                              widget.color.withValues(alpha: 0.15),
                            ]
                                : [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.10),
                            ],
                          ),
                          border: Border.all(
                            color: widget.isSelected
                                ? widget.color.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.3),
                            width: widget.isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isSelected
                                  ? widget.color.withValues(alpha: 0.4)
                                  : Colors.black.withValues(alpha: 0.1),
                              blurRadius: 25,
                              spreadRadius: widget.isSelected ? 8 : 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Subtle pattern overlay
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.05,
                                child: CustomPaint(
                                  painter: _PatternPainter(widget.color),
                                ),
                              ),
                            ),
                            // Content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon container with gradient
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutBack,
                                    padding: EdgeInsets.all(
                                        widget.isSelected ? 20 : 16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          widget.color.withValues(alpha: 
                                              widget.isSelected ? 0.7 : 0.4),
                                          widget.color.withValues(alpha: 
                                              widget.isSelected ? 0.5 : 0.2),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.color.withValues(alpha: 0.4),
                                          blurRadius: 20,
                                          spreadRadius: 3,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      widget.icon,
                                      size: widget.isSelected ? 48 : 42,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Label with animation
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize: widget.isSelected ? 20 : 18,
                                      fontWeight: widget.isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: widget.isSelected
                                          ? widget.color
                                          : AppColors.white,
                                      letterSpacing: 1.5,
                                      shadows: widget.isSelected
                                          ? [
                                        Shadow(
                                          color: widget.color
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                        ),
                                      ]
                                          : [],
                                    ),
                                    child: Text(widget.label),
                                  ),
                                ],
                              ),
                            ),
                            // Selection indicator
                            if (widget.isSelected)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.elasticOut,
                                  scale: widget.isSelected ? 1.0 : 0.0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.color.withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: widget.color,
                                      weight: 800,
                                    ),
                                  ),
                                ),
                              ),
                            // Floating particles effect
                            if (widget.isSelected)
                              ..._buildFloatingParticles(),
                          ],
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
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(3, (index) {
      return Positioned(
        bottom: 20 + (index * 15.0),
        left: 60 + (index * 10.0),
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 800 + (index * 200)),
          opacity: widget.isSelected ? 0.6 : 0.0,
          child: Container(
            width: 4 + (index * 2.0),
            height: 4 + (index * 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw subtle circles pattern
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        canvas.drawCircle(
          Offset(
            (i * size.width / 4),
            (j * size.height / 4),
          ),
          2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}