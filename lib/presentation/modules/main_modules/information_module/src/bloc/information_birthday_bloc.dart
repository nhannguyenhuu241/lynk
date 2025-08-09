import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/utils/custom_navigator.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/presentation/modules/main_modules/information_module/src/ui/information_sex_screen.dart';
import 'package:lynk_an/common/globals.dart';
import 'package:lynk_an/data/local/shared_prefs/shared_prefs_key.dart';
import 'package:rxdart/rxdart.dart';

class InformationBirthdayBloc {

  late BuildContext context;
  late ProfileModel model;

  InformationBirthdayBloc(BuildContext context, ProfileModel model) {
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

  final streamSelectedDate = BehaviorSubject<DateTime?>();
  DateTime? _selectedDate;

  LynkState _lynkState = LynkState.welcoming;
  double _botSize = 0.5;
  Alignment _botAlignment =  Alignment(0.0, -0.3);
  BotReplyLayout _replyLayout = BotReplyLayout.medium;
  Map<String, String>? currentBotMessage;

  dispose() {
    streamCurrentBotMessage.close();
    streamLynkState.close();
    streamBotSize.close();
    streamBotAlignment.close();
    streamBotReply.close();
    streamSelectedDate.close();
  }

  Future<void> selectDate() async {
    // Date picker with enhanced UI
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: AppLocalizations.text(LangKey.info_select_birthday),
      confirmText: AppLocalizations.text(LangKey.info_continue),
      cancelText: AppLocalizations.text(LangKey.info_cancel),
      fieldLabelText: AppLocalizations.text(LangKey.info_birthday_label),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.secondaryDark,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.primary,
              headerForegroundColor: Colors.white,
              dayForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return AppColors.secondaryDark;
              }),
              yearForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return AppColors.secondaryDark;
              }),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    // Time picker with enhanced UI
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      helpText: AppLocalizations.text(LangKey.info_select_time),
      confirmText: AppLocalizations.text(LangKey.info_confirm),
      cancelText: AppLocalizations.text(LangKey.info_cancel),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                side: BorderSide(color: AppColors.primary, width: 2),
              ),
              dayPeriodBorderSide: const BorderSide(color: AppColors.primary, width: 2),
              dayPeriodShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                side: BorderSide(color: AppColors.primary, width: 2),
              ),
              dialHandColor: AppColors.primary,
              dialBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
              hourMinuteTextColor: AppColors.secondaryDark,
              dayPeriodTextColor: AppColors.secondaryDark,
              helpTextStyle: const TextStyle(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              dialTextColor: AppColors.secondaryDark,
              entryModeIconColor: AppColors.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (newDateTime == _selectedDate) return;
    
    // Check if birth year equals current year
    if (pickedDate.year == DateTime.now().year) {
      showBabyMessage();
      return;
    }

    _selectedDate = newDateTime;
    streamSelectedDate.add(newDateTime);
    respondToBirthday(newDateTime);
  }

  void initialBotWelcome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      currentBotMessage = {
        'sender': 'bot',
        'text': AppLocalizations.text(LangKey.info_birthday_welcome)
      };
      streamCurrentBotMessage.add(currentBotMessage);
      streamLynkState.add(_lynkState);
      streamBotSize.add(_botSize);
      streamBotAlignment.add(_botAlignment);
      streamBotReply.add(_replyLayout);
    });
  }

  void showBabyMessage() {
    // Get current language from SharedPreferences
    final currentLanguage = Globals.prefs.getString(SharedPrefsKey.language) ?? LangKey.langVi;
    
    String message;
    if (currentLanguage == LangKey.langEn) {
      message = "Oh my little baby! 👶 You're too young to talk to Lynk An yet! Come back when you're older, okay? 🍼";
    } else if (currentLanguage == LangKey.langKo) {
      message = "아이고 아기야! 👶 아직 Lynk An과 대화하기엔 너무 어려요! 좀 더 크면 다시 와주세요, 알겠죠? 🍼";
    } else {
      message = "Ôi em bé ơi! 👶 Hãy bú sữa cho nó chóng lớn nhé, còn chưa thể nói chuyện cùng Lynk An đâu đó! 🍼";
    }
    
    currentBotMessage = {'sender': 'bot', 'text': message};
    streamCurrentBotMessage.add(currentBotMessage);
    _replyLayout = BotReplyLayout.long;
    streamBotReply.add(_replyLayout);
    _lynkState = LynkState.welcoming;
    streamLynkState.add(_lynkState);
    
    // Reset the selected date
    _selectedDate = null;
    streamSelectedDate.add(null);
  }

  void respondToBirthday(DateTime birthDay) {
    final formattedDate = DateFormat('dd/MM/yyyy, HH:mm').format(birthDay);
    final responseText = AppLocalizations.text(LangKey.info_birthday_response).replaceAll('{formattedDate}', formattedDate);
    currentBotMessage = {'sender': 'bot', 'text': responseText};
    streamCurrentBotMessage.add(currentBotMessage);
    _replyLayout = BotReplyLayout.long;
    streamBotReply.add(_replyLayout);
    _lynkState = LynkState.happy;
    streamLynkState.add(_lynkState);
    streamBotAlignment.add(_botAlignment);

    ProfileModel modelB = ProfileModel(
        name: model.name,
        dateTime: birthDay,
        gender: ''
    );

    // Shorter delay for better UX
    Future.delayed(const Duration(seconds: 5), () {
      CustomNavigator.pushReplacement(context, InformationSexScreen(modelB));
    });
  }
}