import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:lynk_an/common/globals.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/utils/custom_navigator.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/flame/lynk_flame_widget.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/avatar_expressions.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:lynk_an/presentation/modules/authen_module/onboarding_module/src/ui/onboarding_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  String _selectedLanguage = LangKey.langVi;
  
  FlagType get _currentFlagType {
    switch (_selectedLanguage) {
      case LangKey.langVi:
        return FlagType.vietnam;
      case LangKey.langEn:
        return FlagType.usa;
      case LangKey.langKo:
        return FlagType.southKorea;
      default:
        return FlagType.vietnam;
    }
  }
  
  List<LanguageOption> _getLanguages() {
    // Return languages in fixed order - no reordering based on selection
    return [
      LanguageOption(
        code: LangKey.langVi,
        name: AppLocalizations.text(LangKey.language_vietnamese),
        flag: '🇻🇳',
        nativeName: AppLocalizations.text(LangKey.language_vietnam_country),
      ),
      LanguageOption(
        code: LangKey.langEn,
        name: AppLocalizations.text(LangKey.language_english),
        flag: '🇺🇸',
        nativeName: AppLocalizations.text(LangKey.language_us_country),
      ), 
      LanguageOption(
        code: LangKey.langKo,
        name: AppLocalizations.text(LangKey.language_korean),
        flag: '🇰🇷',
        nativeName: AppLocalizations.text(LangKey.language_korea_country),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedLanguage = Globals.prefs.getString(SharedPrefsKey.language, value: LangKey.langVi);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _selectLanguage(String languageCode) async {
    if (_selectedLanguage != languageCode) {
      setState(() {
        _selectedLanguage = languageCode;
      });
      
      await Globals.prefs.setString(SharedPrefsKey.language, languageCode);
      
      // Update locale immediately
      Globals.localeType = languageCode == LangKey.langVi
          ? LocaleType.vi
          : languageCode == LangKey.langKo
              ? LocaleType.ko
              : LocaleType.en;
      
      // Rebuild the app with new locale without restarting
      Globals.myApp?.currentState?.onRefresh();
      
      // Force rebuild this screen to update language texts
      await Future.delayed(Duration(milliseconds: 100));
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _continueToOnboarding() async {
    await Globals.prefs.setBool(SharedPrefsKey.language_selected, true);

    CustomNavigator.pushReplacement(
      context,
      OnboardingScreen(),
      animationType: AnimationType.slide,
    );
  }

  Widget _buildDecorCircle(Color color) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLanguageOption(LanguageOption language, int index) {
    final bool isSelected = _selectedLanguage == language.code;
    final systemLanguage = Globals.prefs.getString(SharedPrefsKey.language, value: LangKey.langVi);
    final bool isSystemLanguage = language.code == systemLanguage;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () => _selectLanguage(language.code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.coral.withValues(alpha: 0.15) 
                    : (isSystemLanguage ? AppColors.mint.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.9)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.coral : Colors.grey.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? AppColors.coral.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          language.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.coral : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              language.nativeName,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected 
                                    ? AppColors.coral.withValues(alpha: 0.8)
                                    : Colors.grey[600],
                              ),
                            ),
                            if (isSystemLanguage && !isSelected) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.mint.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'System',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mint.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.coral,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.coral.withValues(alpha: 0.2),
                  AppColors.sunnyYellow.withValues(alpha: 0.2),
                  AppColors.mint.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -60,
            child: _buildDecorCircle(AppColors.coral.withValues(alpha: 0.3)),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _buildDecorCircle(AppColors.mint.withValues(alpha: 0.3)),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                const SizedBox(height: 40),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        child: LynkFlameWidget(
                          width: 120,
                          height: 120,
                          botSize: 0.8,
                          state: LynkState.holdingFlag,
                          flagType: _currentFlagType,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.text(LangKey.language_selection_title),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.text(LangKey.language_selection_subtitle),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Language Options
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: _getLanguages().length,
                    itemBuilder: (context, index) {
                      final languages = _getLanguages();
                      return _buildLanguageOption(languages[index], index);
                    },
                  ),
                ),
                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _continueToOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.coral.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.text(LangKey.language_continue),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
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

class LanguageOption {
  final String code;
  final String name;
  final String flag;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
    required this.nativeName,
  });
}