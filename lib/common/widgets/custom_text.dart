part of widget;

class CustomText extends StatelessWidget {
  final String? text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final FontStyle? fontStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? isUnderline;

  const CustomText(
      {super.key,
      this.text,
      this.fontSize,
      this.fontWeight,
      this.color,
      this.fontStyle,
      this.textAlign,
      this.maxLines,
      this.overflow,
      this.isUnderline = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      style: TextStyle(
        fontSize: fontSize ?? AppTextSizes.body,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? AppTheme.getTextPrimary(context),
        fontStyle: fontStyle ?? FontStyle.normal,
        decoration: (isUnderline!) ? TextDecoration.underline : TextDecoration.none,
        fontFamily: AppFonts.font
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class CustomTextInput extends StatelessWidget {
  final String? text;
  final FontStyle? fontStyle;
  final Color? color;
  final GestureTapCallback? onTap;

  CustomTextInput({super.key, this.text, this.fontStyle, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.minPadding),
            child: CustomText(
              text: text,
              color: color ?? (onTap == null ? AppTheme.getTextPrimary(context) : AppTheme.getPrimary(context)),
              fontStyle: fontStyle,
            ),
          ),
          SizedBox(
            height: 1.0,
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
class CustomTextAnimation extends StatefulWidget {
  final String? text;
  final Duration duration; // Thời gian để hoàn thành animation
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final FontStyle? fontStyle;
  final TextAlign? textAlign;
  final bool? isUnderline;

  const CustomTextAnimation({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 1500),
    this.fontSize,
    this.fontWeight,
    this.color,
    this.fontStyle,
    this.textAlign,
    this.isUnderline = false,
  });

  @override
  State<CustomTextAnimation> createState() => _CustomTextAnimationState();
}

class _CustomTextAnimationState extends State<CustomTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _startAnimation();
    _controller.forward();
  }

  // Khởi động hoặc khởi động lại animation
  void _startAnimation() {
    // StepTween sẽ tạo ra các giá trị nguyên từ begin đến end
    _characterCount = StepTween(begin: 0, end: widget.text?.length ?? 0)
        .animate(_controller);
  }

  // Hàm này được gọi khi widget được cập nhật với text mới
  @override
  void didUpdateWidget(CustomTextAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      // Cập nhật lại animation cho text mới
      _startAnimation();
      // Chạy lại animation từ đầu
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Rất quan trọng: phải hủy controller để tránh memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        // Lấy chuỗi con dựa trên giá trị hiện tại của animation
        String visibleText = (widget.text ?? "").substring(0, _characterCount.value);

        // Sử dụng lại CustomText gốc của bạn để hiển thị
        return CustomText(
          text: visibleText,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          color: widget.color,
          fontStyle: widget.fontStyle,
          textAlign: widget.textAlign,
          isUnderline: widget.isUnderline,
          // Đảm bảo văn bản không bị xuống dòng khi đang animation
          maxLines: 100, // Hoặc một số đủ lớn
        );
      },
    );
  }
}