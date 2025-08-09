part of widget;

class CustomIconButton extends StatelessWidget {
  final GestureTapCallback? onTap;
  final String? icon;
  final Widget? child;
  final Color? color;
  final bool isText;

  CustomIconButton(
      {this.child, this.icon, this.onTap, this.color, this.isText = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: isText ? null : AppSizes.onTap,
        height: AppSizes.onTap,
        padding: EdgeInsets.all(AppSizes.onTap / 5),
        child: Center(
          child: child ??
              ImageIcon(
                AssetImage(icon!),
                color: color ?? AppColors.primary,
              ),
        ),
      ),
    );
  }
}

class CustomIconButtonFill extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final GestureTapCallback? onTap;

  const CustomIconButtonFill(
      {super.key, required this.icon, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: color ?? AppColors.primary,
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 18.0,
        ),
      ),
      onTap: onTap,
    );
  }
}
