import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/flame/lynk_flame_widget.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/common/widgets/widget.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/common/utils/custom_navigator.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/ui/chat_screen.dart';
import 'package:lynk_an/common/widgets/lynk_loading_dialog.dart';
import 'package:lynk_an/data/services/user_profile_service.dart';
import 'package:sprintf/sprintf.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/chat_message_bubble.dart';
import 'package:lynk_an/common/globals.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:lynk_an/common/assets.dart';
import 'package:lynk_an/data/services/zodiac_reading_service.dart';
import 'package:lynk_an/domain/api/openai/openai_api_service.dart';

import '../bloc/zodiac_selection_bloc.dart';
import '../model/zodiac_model.dart';
import '../widget/zodiac_confirm_button.dart';
import '../widget/zodiac_chip_widget.dart';

class ZodiacSelectionScreen extends StatefulWidget {
  final ProfileModel model;
  final Function(ZodiacModel)? onZodiacSelected;

  const ZodiacSelectionScreen({
    super.key,
    required this.model,
    this.onZodiacSelected,
  });

  @override
  State<ZodiacSelectionScreen> createState() => _ZodiacSelectionScreenState();
}

class _ZodiacSelectionScreenState extends State<ZodiacSelectionScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late ZodiacSelectionBloc _bloc;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  bool _isLoading = false;
  bool _isAppInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _bloc = ZodiacSelectionBloc();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30), // Slower animation for better performance
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _startBackgroundAnimation();
  }
  
  void _startBackgroundAnimation() {
    if (!_isAppInBackground && mounted) {
      _backgroundController.repeat();
    }
  }
  
  void _stopBackgroundAnimation() {
    if (_backgroundController.isAnimating) {
      _backgroundController.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInBackground = false;
        _startBackgroundAnimation();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _isAppInBackground = true;
        _stopBackgroundAnimation();
        break;
      case AppLifecycleState.hidden:
        _isAppInBackground = true;
        _stopBackgroundAnimation();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    // Stop animation before disposal
    _stopBackgroundAnimation();
    
    // Safely dispose animation controller
    try {
      _backgroundController.dispose();
    } catch (e) {
      // Handle disposal error gracefully
      debugPrint('Error disposing background animation controller: $e');
    }
    
    // Safely close bloc
    try {
      _bloc.close();
    } catch (e) {
      // Handle bloc closure error gracefully
      debugPrint('Error closing zodiac selection bloc: $e');
    }
    
    super.dispose();
  }

  void _onZodiacTap(ZodiacModel zodiac) {
    _bloc.add(ZodiacSelectedEvent(zodiac));
  }

  void _onConfirmPressed() async {
    final state = _bloc.state;
    if (state is ZodiacSelectionLoaded && state.selectedZodiac != null) {
      // Set loading state
      setState(() {
        _isLoading = true;
      });
      
      // Show loading dialog
      final loadingMessage = sprintf(
        AppLocalizations.text(LangKey.loading_exploring_zodiac),
        [state.selectedZodiac!.localizedName],
      );
      LynkLoadingDialog.show(
        context,
        message: loadingMessage,
        botState: LynkState.happy,
      );
      
      try {
        // Call the callback if provided
        widget.onZodiacSelected?.call(state.selectedZodiac!);
        
        // Save ProfileModel with selected zodiac to SharedPreferences
        final finalModel = ProfileModel(
          name: widget.model.name,
          dateTime: widget.model.dateTime,
          gender: widget.model.gender,
          selectedZodiac: state.selectedZodiac!.id,
        );
        
        // Save the updated profile model with selected zodiac
        await UserProfileService.saveProfileModel(finalModel);
        
        // Mark zodiac selection as completed
        await UserProfileService.saveZodiacSelectionState(true);
        
        // Generate zodiac reading via AI
        await _generateZodiacReading(state.selectedZodiac!, finalModel);
        
        // Hide loading dialog and reset loading state
        if (context.mounted) {
          LynkLoadingDialog.hide(context);
          setState(() {
            _isLoading = false;
          });
        }
        
        // Navigate to chat screen with the model
        if (context.mounted) {
          CustomNavigator.pushReplacement(
            context,
            ChatScreen(
              model: finalModel,
              isInit: true,
              isFromZodiacSelection: true,
            ),
          );
        }
      } catch (e) {
        // Hide loading dialog and reset loading state on error
        if (context.mounted) {
          LynkLoadingDialog.hide(context);
          setState(() {
            _isLoading = false;
          });
        }
        debugPrint('Error in zodiac confirmation: $e');
        // Still navigate even if there's an error
        if (context.mounted) {
          final finalModel = ProfileModel(
            name: widget.model.name,
            dateTime: widget.model.dateTime,
            gender: widget.model.gender,
            selectedZodiac: state.selectedZodiac!.id,
          );
          CustomNavigator.pushReplacement(
            context,
            ChatScreen(
              model: finalModel,
              isInit: true,
              isFromZodiacSelection: true,
            ),
          );
        }
      }
    }
  }

  Future<void> _generateZodiacReading(ZodiacModel selectedZodiac, ProfileModel model) async {
    try {
      // Get current language from SharedPrefs
      final currentLanguage = Globals.prefs.getString(SharedPrefsKey.language) ?? LangKey.langVi;
      String languageCode = 'vi';
      if (currentLanguage == LangKey.langEn) {
        languageCode = 'en';
      } else if (currentLanguage == LangKey.langKo) {
        languageCode = 'ko';
      }
      
      // Generate AI prompt for zodiac reading using complete profile data
      final aiPrompt = await ZodiacReadingService.instance.generateAIPromptFromProfile(
        palaceId: selectedZodiac.id,
        profile: model,
        language: languageCode,
      );
      
      if (aiPrompt != null) {
        print('🌟 Generating zodiac reading for ${selectedZodiac.nameVi}...');
        print('📝 AI Prompt:\n$aiPrompt');
        
        // Call AI to generate zodiac reading content using the same language
        final aiResponse = await OpenaiApiService.getResponse(aiPrompt, language: languageCode);
        
        print('🤖 OpenAI Response:\n$aiResponse');
        
        if (aiResponse != null && aiResponse.isNotEmpty) {
          // Save the raw AI response directly (it's already formatted nicely)
          Globals.prefs.setString('zodiac_reading_${selectedZodiac.id}', aiResponse);
          print('✅ Zodiac reading generated and saved for ${selectedZodiac.nameVi}');
          print('📄 Reading preview:\n${aiResponse.substring(0, aiResponse.length > 500 ? 500 : aiResponse.length)}...');
        } else {
          print('❌ AI response is null or empty');
        }
      } else {
        print('❌ AI prompt is null');
      }
    } catch (e) {
      print('❌ Error generating zodiac reading: $e');
      // Continue to chat screen even if reading generation fails
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        body: Stack(
          children: [
            // Background image (same as information module)
            Image.asset(
              Assets.imgBackground2,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
            // Content
            SafeArea(
              child: BlocConsumer<ZodiacSelectionBloc, ZodiacSelectionState>(
                listener: (context, state) {
                  if (state is ZodiacSelectionConfirmed) {
                    // Handle confirmation - navigate to next screen or callback
                    widget.onZodiacSelected?.call(state.selectedZodiac);
                  }
                },
                builder: (context, state) {
                  return _buildBody(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBody(BuildContext context, ZodiacSelectionState state) {
    if (state is ZodiacSelectionInitial) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (state is ZodiacSelectionLoaded) {
      return SingleChildScrollView(
        padding: AppSizes.paddingHorizontal20,
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Bot Avatar and Chat
            _buildBotSection(state),
            
            const SizedBox(height: 32),
            
            // Zodiac Grid
            _buildZodiacGrid(state),
            
            const SizedBox(height: 32),
            
            // Confirm Button
            _buildConfirmButton(state),
            
            const SizedBox(height: 20),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBotSection(ZodiacSelectionLoaded state) {
    return Semantics(
      container: true,
      label: AppLocalizations.text(LangKey.zodiac_bot_area_label),
      child: Column(
        children: [
          // Bot Avatar
          Semantics(
            label: AppLocalizations.text(LangKey.zodiac_bot_avatar_label),
            image: true,
            child: Container(
              width: 140,
              height: 140,
              margin: EdgeInsets.all(AppSizes.minPadding),
              child: LynkFlameWidget(
                width: 120,
                height: 120,
                botSize: 0.8,
                state: state.showingExplanation ? LynkState.happy : LynkState.welcoming,
              ),
            ),
          ),
        // Chat Bubble  
        Semantics(
          liveRegion: true,
          label: '${AppLocalizations.text(LangKey.zodiac_bot_message_label)}: ${state.currentMessage}',
          child: StyledChatMessageBubble(
            layout: BotReplyLayout.long,
            tail: TailDirection.top,
            messageText: state.currentMessage,
            child: AnimatedTypingText(
              text: state.currentMessage,
              color: AppColors.white,
              maxLines: null,
              overflow: TextOverflow.visible,
              typingSpeed: state.showingExplanation 
                  ? const Duration(milliseconds: 50)
                  : const Duration(milliseconds: 0),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildZodiacGrid(ZodiacSelectionLoaded state) {
    return Semantics(
      container: true,
      label: AppLocalizations.text(LangKey.zodiac_list_label),
      hint: AppLocalizations.text(LangKey.zodiac_list_hint),
      child: Container(
        padding: AppSizes.paddingAll16,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 10,
          children: state.zodiacs.map((zodiac) {
            final isSelected = state.selectedZodiac?.id == zodiac.id;
            return ZodiacChipWidget(
              zodiac: zodiac,
              isSelected: isSelected,
              onTap: () => _onZodiacTap(zodiac),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(ZodiacSelectionLoaded state) {
    return Container(
      width: double.infinity,
      padding: AppSizes.paddingHorizontal4,
      child: ZodiacConfirmButton(
        isEnabled: state.isConfirmButtonEnabled && !_isLoading,
        onPressed: state.isConfirmButtonEnabled && !_isLoading ? _onConfirmPressed : null,
        text: _isLoading 
            ? AppLocalizations.text(LangKey.zodiac_processing) 
            : state.selectedZodiac != null 
                ? sprintf(AppLocalizations.text(LangKey.zodiac_explore_button), [state.selectedZodiac!.localizedName]) 
                : AppLocalizations.text(LangKey.zodiac_select_prompt),
      ),
    );
  }
}