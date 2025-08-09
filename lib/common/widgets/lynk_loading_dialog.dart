import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/flame/lynk_flame_widget.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'dart:ui';

import 'package:lynk_an/common/widgets/widget.dart';

class LynkLoadingDialog extends StatefulWidget {
  final String? message;
  final LynkState botState;
  
  const LynkLoadingDialog({
    Key? key,
    this.message,
    this.botState = LynkState.amazed,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    String? message,
    LynkState botState = LynkState.amazed,
    bool barrierDismissible = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => LynkLoadingDialog(
        message: message,
        botState: botState,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  State<LynkLoadingDialog> createState() => _LynkLoadingDialogState();
}

class _LynkLoadingDialogState extends State<LynkLoadingDialog> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final botSize = MediaQuery.of(context).size.width * 0.2;
    return WillPopScope(
      onWillPop: () async => false,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.maxPadding),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.lagePadding, horizontal: AppSizes.lagePadding * 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.maxPadding),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bot animation
                      SizedBox(
                        width: botSize,
                        height: botSize,
                        child: LynkFlameWidget(
                          width: botSize,
                          height: botSize,
                          botSize: 1.0,
                          state: widget.botState,
                        ),
                      ),
                      SizedBox(height: AppSizes.minPadding),
                      // Loading text
                      CustomText(
                        text: widget.message ?? AppLocalizations.text(LangKey.please_wait),
                        color: AppColors.white,
                        fontSize: AppTextSizes.body,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: AppSizes.minPadding),
                      // Loading dots animation
                      _LoadingDots(),
                    ],
                  ),
                ),
              ),
            ),
          )));
        },
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _animations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: 0.5 + _animations[index].value * 0.5,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.white.withValues(alpha: 
                          0.5 + _animations[index].value * 0.5,
                        ),
                        AppColors.primary.withValues(alpha: 
                          0.3 + _animations[index].value * 0.7,
                        ),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 
                          0.3 + _animations[index].value * 0.5,
                        ),
                        blurRadius: 8,
                        spreadRadius: 2,
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