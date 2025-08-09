part of widget;


class CustomRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AnimationType animationType;

  CustomRoute({required this.page, this.animationType = AnimationType.normal})
      : super(
    settings: RouteSettings(name: page.runtimeType.toString()),
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionDuration: AppAnimation.duration,
    reverseTransitionDuration: AppAnimation.duration,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) {
      final curveAnimation = CurvedAnimation(
        parent: animation,
        curve: AppAnimation.curve,
        reverseCurve: Curves.easeOut,
      );

      switch (animationType) {
        case AnimationType.fade:
          return FadeTransition(opacity: curveAnimation, child: child);
        case AnimationType.slide:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curveAnimation),
            child: child,
          );
        case AnimationType.scale:
          return ScaleTransition(
            scale: curveAnimation,
            child: child,
          );
        case AnimationType.rotate:
          return RotationTransition(
            turns: curveAnimation,
            child: child,
          );
        case AnimationType.normal:
        default:
          return FadeTransition(opacity: animation, child: child);
      }
    },
  );
}


class CustomRouteHero extends PageRouteBuilder {
  final Widget? page;
  CustomRouteHero({this.page})
      : super(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      page!,
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) =>
          FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation),
            child: child,
          ),
      opaque: true,
      transitionDuration: Duration(milliseconds: 1000));

  @override
  // TODO: implement settings
  RouteSettings get settings =>
      RouteSettings(name: page.runtimeType.toString());
}

class CustomRouteDialog extends PageRouteBuilder {
  final Widget? page;
  CustomRouteDialog({this.page})
      : super(
      pageBuilder: (context, animation, secondaryAnimation) => page!,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) =>
          FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation),
            child: child,
          ),
      opaque: false);
}
