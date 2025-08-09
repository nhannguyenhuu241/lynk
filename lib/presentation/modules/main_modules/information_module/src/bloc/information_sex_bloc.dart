import 'package:flutter/material.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/utils/custom_navigator.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/presentation/modules/main_modules/information_module/src/ui/information_phone_screen.dart';
import 'package:rxdart/rxdart.dart';

class InformationSexBloc {
  late BuildContext context;

  late ProfileModel model;

  InformationSexBloc(BuildContext context, ProfileModel model) {
    this.context = context;
    this.model = model;
  }


  final streamCurrentBotMessage = BehaviorSubject<Map<String, String>?>();
  final streamLynkState = BehaviorSubject<LynkState>();
  final streamBotSize = BehaviorSubject<double>();
  final streamBotAlignment = BehaviorSubject<Alignment>();
  final streamBotReply = BehaviorSubject<BotReplyLayout>();
  final streamIsBotReplying = BehaviorSubject<bool>();
  final streamShowTypingIndicator = BehaviorSubject<bool>();
  final streamBounceController = BehaviorSubject<AnimationController>();
  Map<String, String>? currentBotMessage;
  LynkState _lynkState = LynkState.welcoming;
  double _botSize = 0.5;
  Alignment _botAlignment =  Alignment(0.0, 0.0);
  BotReplyLayout _replyLayout = BotReplyLayout.medium;
//Anh trai thì say hi 👋, em xinh thì thả tym 💖 – cho xin tín hiệu để còn xưng hô cho chuẩn nào!
  dispose() {
      streamCurrentBotMessage.close();
      streamLynkState.close();
      streamBotSize.close();
      streamBotAlignment.close();
      streamBotReply.close();
      streamIsBotReplying.close();
      streamShowTypingIndicator.close();
      streamBounceController.close();
  }

  void initialBotWelcome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      currentBotMessage = {
        'sender': 'bot',
        'text': AppLocalizations.text(LangKey.info_sex_welcome)
      };
      streamCurrentBotMessage.add(currentBotMessage);
      streamLynkState.add(_lynkState);
      streamBotSize.add(_botSize);
      streamBotAlignment.add(_botAlignment);
      streamBotReply.add(_replyLayout);
    });
  }

  void handleGenderSelection(String gender) {
    // Gán gender ngay lập tức
    streamCurrentBotMessage.add(null);

    _lynkState = LynkState.welcoming;
    streamLynkState.add(_lynkState);
    _botSize = 0.5;
    streamBotSize.add(_botSize);
    Future.delayed(const Duration(milliseconds: 300), () {
      _botSize = 0.5;
      streamBotSize.add(_botSize);
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      String responseText;
      if (gender == 'male') {
        final maleResponses = [
          AppLocalizations.text(LangKey.info_male_response_1),
          AppLocalizations.text(LangKey.info_male_response_2),
          AppLocalizations.text(LangKey.info_male_response_3),
        ];
        responseText = maleResponses[DateTime.now().millisecond % maleResponses.length];
      } else {
        final femaleResponses = [
          AppLocalizations.text(LangKey.info_female_response_1),
          AppLocalizations.text(LangKey.info_female_response_2),
          AppLocalizations.text(LangKey.info_female_response_3),
        ];
        responseText = femaleResponses[DateTime.now().millisecond % femaleResponses.length];
      }
      currentBotMessage = {
        'sender': 'bot',
        'text': responseText
      };
      streamCurrentBotMessage.add(currentBotMessage);
      _lynkState = LynkState.happy;
      streamLynkState.add(_lynkState);
      _replyLayout = BotReplyLayout.long;
      streamBotReply.add(_replyLayout);
    });
    _saveData(gender);
  }

  _saveData(String gender) {
    ProfileModel modelC = ProfileModel(
      name: model.name, 
      dateTime: model.dateTime, 
      gender: gender,
      phoneNumber: null, // Will be set in phone screen
      selectedZodiac: null, // Will be set later in zodiac selection
    );
    Future.delayed(const Duration(seconds: 5), () {
      // Navigate to phone screen instead of zodiac selection
      CustomNavigator.pushReplacement(
        context, 
        InformationPhoneScreen(modelC),
      );
    });
  }
}