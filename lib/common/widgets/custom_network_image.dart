part of widget;

class CustomNetworkImage extends StatelessWidget {
  final double? width;
  final double? height;
  final String? url;
  final BoxFit? fit;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final double? radius;
  final Color? borderColor;
  final Widget? placeholder;

  CustomNetworkImage(
      {this.width,
      this.height,
      this.url,
      this.fit,
      this.backgroundColor,
      this.radius,
      this.borderColor,
      this.placeholder,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(radius ?? 0.0),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.white,
          border: borderColor == null ? null : Border.all(color: borderColor!),
          borderRadius: BorderRadius.circular(radius ?? 0.0),
        ),
        child: url == null
            ? (placeholder ?? CustomPlaceholder())
            : CachedNetworkImage(
                imageUrl: url!,
                width: width,
                height: height,
                fit: fit ?? BoxFit.cover,
                placeholder: (_, url) =>
                    placeholder ??
                    Transform(
                        alignment: FractionalOffset.center,
                        transform: Matrix4.identity()..scale(0.5, 0.5),
                        child: CupertinoActivityIndicator()),
                errorWidget: (_, url, __) => placeholder ?? CustomPlaceholder(),
                useOldImageOnUrlChange: true),
      ),
    );
  }
}

class CustomAvatar extends StatelessWidget {
  final String? url;
  final String? name;
  final double? size;
  final Color? borderColor;
  final GestureTapCallback? onTap;
  final TextStyle? styleName;

  CustomAvatar(
      {this.url,
      this.name,
      this.size,
      this.borderColor,
      this.onTap,
      this.styleName});

  @override
  Widget build(BuildContext context) {
    List<String> names = (name ?? "").split(" ");
    names.remove("");
    String? placeholder;
    if (names.length == 1 && names[0].isNotEmpty) {
      placeholder = names[0][0];
    } else if (names.length > 1) {
      placeholder =
          "${names[names.length - 2][0]}${names[names.length - 1][0]}";
    }
    return InkWell(
      child: CustomNetworkImage(
        width: size,
        height: size,
        radius: size,
        borderColor: borderColor,
        url: url,
        fit: BoxFit.cover,
        placeholder: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.5)),
          padding: EdgeInsets.all(size! / 5),
          alignment: Alignment.center,
          child: AutoSizeText(
            (placeholder ?? "").trim().toUpperCase(),
            style: styleName ?? TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: size! * 0.8
            ),
            minFontSize: 1.0,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
