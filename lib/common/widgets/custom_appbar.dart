part of widget;

class CustomAppBar extends StatelessWidget {
  final String? title;
  final Widget? customTitle;
  final List<CustomOptionAppBar>? options;
  final IconData? icon;
  final GestureTapCallback? onWillPop;
  final bool isBottomSheet;
  final Widget? child;

  CustomAppBar(
      {this.title,
      this.customTitle,
      this.options,
      this.icon,
      this.onWillPop,
      this.isBottomSheet = false,
      this.child});

  Widget _buildIcon(int index, Color color, BuildContext context) {
    CustomOptionAppBar model = options![index];
    return CustomIconButton(
        onTap: model.onTap,
        icon: model.icon,
        isText: model.text != null,
        color: color,
        child: model.text == null
            ? null
            : CustomText(
                text: options![index].text,
                color: AppTheme.getPrimary(context),
              ));
  }

  @override
  Widget build(BuildContext context) {
    bool canPop = CustomNavigator.canPop(context);
    Color color = isBottomSheet ? AppTheme.getTextPrimary(context) : AppColors.white;
    Color optionColor = isBottomSheet ? AppTheme.getPrimary(context) : AppColors.white;
    return Container(
      padding: EdgeInsets.only(top: isBottomSheet ? 0.0 : AppSizes.screenPadding.top),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: kToolbarHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.minPadding +
                          ((options == null || options!.length == 0)
                              ? (canPop ? AppSizes.onTap : 0.0)
                              : (options!.length * AppSizes.onTap))),
                  child: customTitle ??
                      Center(
                        child: CustomText(
                          text: title,
                          fontSize: AppTextSizes.title,
                          color: color,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                ),
                Row(
                  children: [
                    Opacity(
                      child: InkWell(
                        onTap: canPop
                            ? (onWillPop ?? () => CustomNavigator.pop(context))
                            : null,
                        child: Container(
                          width: AppSizes.onTap,
                          height: AppSizes.onTap,
                          padding: EdgeInsets.only(left: AppSizes.maxPadding),
                          child: Icon(
                            icon ?? Icons.arrow_back_ios,
                            color: color,
                            size: 15.0,
                          ),
                        ),
                      ),
                      opacity: canPop ? 1.0 : 0.0,
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    (options == null || options!.length == 0)
                        ? Container()
                        : Container(
                            height: AppSizes.onTap,
                            child: ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppSizes.minPadding),
                                itemCount: options!.length,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (_, index) =>
                                    options![index].child ??
                                    _buildIcon(index, optionColor, context)),
                          )
                  ],
                )
              ],
            ),
          ),
          if (child != null) child!
        ],
      ),
    );
  }
}

class CustomOptionAppBar {
  final String? icon;
  final GestureTapCallback? onTap;
  final bool showIcon;
  final Widget? child;
  final String? text;

  CustomOptionAppBar(
      {this.icon, this.showIcon = true, this.onTap, this.child, this.text});
}
