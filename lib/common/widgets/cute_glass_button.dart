part of widget;

class CuteGlassButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final bool isEnabled;

  const CuteGlassButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.isEnabled = true,
  });

  @override
  State<CuteGlassButton> createState() => _CuteGlassButtonState();
}

class _CuteGlassButtonState extends State<CuteGlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut)
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isEnabled) {
      _controller.forward();
      // Thêm một chút delay trước khi thực hiện hành động để người dùng thấy hiệu ứng
      Future.delayed(const Duration(milliseconds: 120), () {
        widget.onTap();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      // Làm mờ nút nếu bị vô hiệu hóa
      opacity: widget.isEnabled ? 1.0 : 0.5,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _handleTap,
          child: ClipOval(
            child: BackdropFilter(
              // Tăng độ mờ để hiệu ứng rõ nét hơn
              filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // 1. Dùng gradient để tạo hiệu ứng ánh sáng trên bề mặt cong
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.3), // Vùng sáng hơn
                      Colors.white.withValues(alpha: 0.1), // Vùng tối hơn
                    ],
                    stops: const [0.1, 0.9],
                  ),
                  // 2. Viền tinh tế để xác định cạnh của "kính"
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                  // 3. Thêm bóng cho icon để tạo chiều sâu 3D
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 5,
                      offset: const Offset(1, 2),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}