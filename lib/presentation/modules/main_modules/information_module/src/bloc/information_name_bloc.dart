import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/utils/custom_navigator.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/presentation/modules/main_modules/information_module/src/ui/information_birthday_screen.dart';
import 'package:rxdart/rxdart.dart';

class InformationNameBloc {

  late BuildContext context;
  Timer? _debounceTimer;
  Timer? _navigationTimer;
  bool _hasResponded = false;

  InformationNameBloc(BuildContext context) {
    this.context = context;
    // Listen to text changes for showing/hiding submit button
    textController.addListener(() {
      streamHasText.add(textController.text.isNotEmpty);
    });
  }

  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final streamCurrentBotMessage = BehaviorSubject<Map<String, String>?>();
  final streamLynkState = BehaviorSubject<LynkState>();
  final streamBotSize = BehaviorSubject<double>();
  final streamBotAlignment = BehaviorSubject<Alignment>();
  final streamBotReply = BehaviorSubject<BotReplyLayout>();
  final streamIsBotReplying = BehaviorSubject<bool>();
  final streamShowTypingIndicator = BehaviorSubject<bool>();
  final streamBounceController = BehaviorSubject<AnimationController>();
  final streamHasText = BehaviorSubject<bool>.seeded(false);

  LynkState _lynkState = LynkState.welcoming;
  double _botSize = 0.5;
  Alignment _botAlignment =  Alignment(0.0, -0.3);
  BotReplyLayout _replyLayout = BotReplyLayout.medium;
  bool _isBotReplying = false;
  bool _showTypingIndicator = false;
  late AnimationController _bounceController;
  Map<String, String>? currentBotMessage;

  dispose() {
    _debounceTimer?.cancel();
    _navigationTimer?.cancel();
    streamCurrentBotMessage.close();
    streamLynkState.close();
    streamBotSize.close();
    streamBotAlignment.close();
    streamBotReply.close();
    streamHasText.close();
    textController.dispose();
    focusNode.dispose();
  }

  void initialBotWelcome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      currentBotMessage = {
        'sender': 'bot',
        'text': AppLocalizations.text(LangKey.info_welcome_message)
      };
      streamCurrentBotMessage.add(currentBotMessage);
      streamLynkState.add(_lynkState);
      streamBotSize.add(_botSize);
      streamBotAlignment.add(_botAlignment);
      streamBotReply.add(_replyLayout);
    });
  }

  void onNameChanged(String value) {
    // Cancel any existing timer
    _debounceTimer?.cancel();

    // Reset response flag if user starts typing again
    if (_hasResponded && value.trim().length < 2) {
      _hasResponded = false;
      _navigationTimer?.cancel();
    }

    // Only process if name has at least 2 characters and hasn't responded yet
    if (value.trim().length >= 2 && !_hasResponded) {
      // Wait 4 seconds after user stops typing
      _debounceTimer = Timer(const Duration(seconds: 4), () {
        respondToName(value);
      });
    }
  }

  void respondToName(String name) {
    if (name.trim().isEmpty || _hasResponded) {
      return;
    }

    _hasResponded = true;
    _debounceTimer?.cancel();
    focusNode.unfocus();

    final responseText = AppLocalizations.text(LangKey.info_response_to_name).replaceAll('{name}', name);
    currentBotMessage = {'sender': 'bot', 'text': responseText};
    streamCurrentBotMessage.add(currentBotMessage);
    _replyLayout = BotReplyLayout.long;
    streamBotReply.add(_replyLayout);
    _lynkState = LynkState.happy;
    streamLynkState.add(_lynkState);
    _botAlignment = const Alignment(-0.8, 0.6);
    streamBotAlignment.add(_botAlignment);

    ProfileModel model = ProfileModel(name: name.trim(), dateTime: DateTime.now(), gender:  '');

    // Navigate after bot finishes responding
    _navigationTimer = Timer(const Duration(seconds: 4), () {
      CustomNavigator.pushReplacement(context, InformationBirthdayScreen(model));
    });
  }

}