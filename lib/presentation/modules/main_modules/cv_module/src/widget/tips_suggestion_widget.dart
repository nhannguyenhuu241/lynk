import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/lang_key.dart';

class TipsSuggestionWidget extends StatefulWidget {
  final List<TipModel> tips;
  final Function(String) onTipTapped;

  const TipsSuggestionWidget({
    Key? key,
    required this.tips,
    required this.onTipTapped,
  }) : super(key: key);

  @override
  State<TipsSuggestionWidget> createState() => _TipsSuggestionWidgetState();
}

class _TipsSuggestionWidgetState extends State<TipsSuggestionWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tips.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with sparkling effect
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _shimmerAnimation.value * 3.14159,
                        child: Icon(
                          Icons.auto_awesome,
                          color: Colors.amber,
                          size: 24,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.text(LangKey.cv_suggestions_from_lynk),
                    style: TextStyle(
                      color: AppColors.neutral900,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '✨',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Horizontal scrollable tips
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.tips.length,
                itemBuilder: (context, index) {
                  final tip = widget.tips[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildTipChip(tip, index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipChip(TipModel tip, int index) {
    final colors = [
      AppColors.sunriseTop,
      AppColors.infoLight,
      AppColors.secondaryLight,
      AppColors.sunriseMiddle,
      AppColors.primary,
    ];
    
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => widget.onTipTapped(tip.message),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200 + (index * 50)),
        curve: Curves.easeOut,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.4),
              color.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tip.text,
                  style: TextStyle(
                    color: AppColors.neutral900,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TipModel {
  final String text;
  final String message;
  final IconData icon;
  final String emoji;

  const TipModel({
    required this.text,
    required this.message,
    required this.icon,
    required this.emoji,
  });

  // Predefined tips for CV analysis
  static List<TipModel> getCVTips() {
    return [
      TipModel(
        text: AppLocalizations.text(LangKey.cv_tip_strengths),
        message: AppLocalizations.text(LangKey.cv_tip_strengths_msg),
        icon: Icons.star_rounded,
        emoji: '⭐',
      ),
      TipModel(
        text: AppLocalizations.text(LangKey.cv_tip_improvements),
        message: AppLocalizations.text(LangKey.cv_tip_improvements_msg),
        icon: Icons.tips_and_updates_rounded,
        emoji: '💡',
      ),
      TipModel(
        text: AppLocalizations.text(LangKey.cv_tip_skills),
        message: AppLocalizations.text(LangKey.cv_tip_skills_msg),
        icon: Icons.psychology_rounded,
        emoji: '🧠',
      ),
      TipModel(
        text: AppLocalizations.text(LangKey.cv_tip_positions),
        message: AppLocalizations.text(LangKey.cv_tip_positions_msg),
        icon: Icons.work_rounded,
        emoji: '💼',
      ),
      TipModel(
        text: AppLocalizations.text(LangKey.cv_tip_layout),
        message: AppLocalizations.text(LangKey.cv_tip_layout_msg),
        icon: Icons.design_services_rounded,
        emoji: '🎨',
      ),
      TipModel(
        text: AppLocalizations.text(LangKey.cv_tip_impression),
        message: AppLocalizations.text(LangKey.cv_tip_impression_msg),
        icon: Icons.auto_awesome_rounded,
        emoji: '✨',
      ),
      TipModel(
        text: AppLocalizations.text(LangKey.cv_tip_experience),
        message: AppLocalizations.text(LangKey.cv_tip_experience_msg),
        icon: Icons.workspace_premium_rounded,
        emoji: '🏆',
      ),
      TipModel(
        text: AppLocalizations.text(LangKey.cv_tip_salary),
        message: AppLocalizations.text(LangKey.cv_tip_salary_msg),
        icon: Icons.attach_money_rounded,
        emoji: '💰',
      ),
    ];
  }
}