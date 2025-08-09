import 'package:flutter/material.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/utils/custom_navigator.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/common/widgets/lynk_loading_dialog.dart';
import 'package:lynk_an/common/widgets/lynk_error_dialog.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/data/repositories/auth_repository.dart';
import 'package:lynk_an/data/model/request/auth_request.dart';
import 'package:lynk_an/data/services/device_id_service.dart';
import 'package:lynk_an/data/services/user_profile_service.dart';
import 'package:lynk_an/presentation/modules/authen_module/zodiac_selection/src/ui/zodiac_selection_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class InformationPhoneBloc {
  late BuildContext context;
  late ProfileModel model;
  final AuthRepository _authRepository = AuthRepository();

  InformationPhoneBloc(BuildContext context, ProfileModel model) {
    this.context = context;
    this.model = model;
  }

  final streamCurrentBotMessage = BehaviorSubject<Map<String, String>?>();
  final streamLynkState = BehaviorSubject<LynkState>();
  final streamBotSize = BehaviorSubject<double>();
  final streamBotAlignment = BehaviorSubject<Alignment>();
  final streamBotReply = BehaviorSubject<BotReplyLayout>();
  final streamIsValidPhone = BehaviorSubject<bool>();
  final streamPhoneError = BehaviorSubject<String?>();
  final streamShowButton = BehaviorSubject<bool>();
  
  Map<String, String>? currentBotMessage;
  LynkState _lynkState = LynkState.welcoming;
  double _botSize = 0.5;
  Alignment _botAlignment = Alignment(0.8, 0.8);
  BotReplyLayout _replyLayout = BotReplyLayout.medium;

  dispose() {
    streamCurrentBotMessage.close();
    streamLynkState.close();
    streamBotSize.close();
    streamBotAlignment.close();
    streamBotReply.close();
    streamIsValidPhone.close();
    streamPhoneError.close();
    streamShowButton.close();
  }

  void initialBotWelcome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      currentBotMessage = {
        'sender': 'bot',
        'text': AppLocalizations.text(LangKey.info_phone_welcome)
      };
      streamCurrentBotMessage.add(currentBotMessage);
      streamLynkState.add(_lynkState);
      streamBotSize.add(_botSize);
      streamBotAlignment.add(_botAlignment);
      streamBotReply.add(_replyLayout);
      streamShowButton.add(false);
    });
  }

  bool isValidVietnamesePhone(String phone) {
    // Remove all spaces and special characters
    String cleanedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)\.]+'), '');
    
    // Vietnamese phone number patterns
    // 10 digits starting with 0 followed by network prefix
    final vnPhoneRegex = RegExp(r'^0(3[2-9]|5[6-9]|7[0-9]|8[1-9]|9[0-9])\d{7}$');
    
    // 11 digits with country code +84
    final vnPhoneWithCountryCode = RegExp(r'^(\+84|84)(3[2-9]|5[6-9]|7[0-9]|8[1-9]|9[0-9])\d{7}$');
    
    return vnPhoneRegex.hasMatch(cleanedPhone) || vnPhoneWithCountryCode.hasMatch(cleanedPhone);
  }

  String formatPhoneNumber(String phone) {
    // Remove all non-digit characters except +
    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d\+]'), '');
    
    // If starts with +84, format as +84 XX XXX XXXX
    if (cleanedPhone.startsWith('+84')) {
      if (cleanedPhone.length >= 12) {
        return '+84 ${cleanedPhone.substring(3, 5)} ${cleanedPhone.substring(5, 8)} ${cleanedPhone.substring(8)}';
      }
    }
    // If starts with 84, format as +84 XX XXX XXXX
    else if (cleanedPhone.startsWith('84') && cleanedPhone.length >= 11) {
      return '+84 ${cleanedPhone.substring(2, 4)} ${cleanedPhone.substring(4, 7)} ${cleanedPhone.substring(7)}';
    }
    // If starts with 0, format as 0XX XXX XXXX
    else if (cleanedPhone.startsWith('0') && cleanedPhone.length >= 10) {
      return '${cleanedPhone.substring(0, 3)} ${cleanedPhone.substring(3, 6)} ${cleanedPhone.substring(6)}';
    }
    
    return phone;
  }

  void validatePhoneNumber(String phone) {
    if (phone.isEmpty) {
      streamIsValidPhone.add(false);
      streamPhoneError.add(null);
      streamShowButton.add(false);
      return;
    }

    bool isValid = isValidVietnamesePhone(phone);
    streamIsValidPhone.add(isValid);
    
    if (!isValid && phone.length >= 3) {
      streamPhoneError.add(AppLocalizations.text(LangKey.info_phone_error));
      _lynkState = LynkState.thinking;
      streamLynkState.add(_lynkState);
    } else {
      streamPhoneError.add(null);
      if (isValid) {
        _lynkState = LynkState.happy;
        streamLynkState.add(_lynkState);
      } else {
        _lynkState = LynkState.welcoming;
        streamLynkState.add(_lynkState);
      }
    }
    
    // Show button when there's input (will be validated on continue)
    streamShowButton.add(phone.isNotEmpty);
  }

  void handleContinueButton(String phoneNumber) {
    // If phone is empty, proceed with skip behavior
    if (phoneNumber.isEmpty) {
      handleSkipPhone();
      return;
    }
    
    // Validate phone number
    bool isValid = isValidVietnamesePhone(phoneNumber);
    
    if (isValid) {
      // If valid phone, proceed with registration
      handlePhoneSubmit(phoneNumber);
    } else {
      // If invalid phone, show error and don't proceed
      streamPhoneError.add(AppLocalizations.text(LangKey.info_phone_error));
      _lynkState = LynkState.thinking;
      streamLynkState.add(_lynkState);
      
      // Show error message from bot
      currentBotMessage = {
        'sender': 'bot',
        'text': AppLocalizations.text(LangKey.info_phone_error)
      };
      streamCurrentBotMessage.add(currentBotMessage);
    }
  }

  void handlePhoneSubmit(String phoneNumber) {
    String formattedPhone = formatPhoneNumber(phoneNumber);
    
    // Clear current message
    streamCurrentBotMessage.add(null);
    
    _lynkState = LynkState.amazed;
    streamLynkState.add(_lynkState);
    _botSize = 0.55;
    streamBotSize.add(_botSize);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _botSize = 0.5;
      streamBotSize.add(_botSize);
      
      // Show thank you message
      currentBotMessage = {
        'sender': 'bot',
        'text': AppLocalizations.text(LangKey.info_phone_thank_you)
      };
      streamCurrentBotMessage.add(currentBotMessage);
      _lynkState = LynkState.happy;
      streamLynkState.add(_lynkState);
      _replyLayout = BotReplyLayout.short;
      streamBotReply.add(_replyLayout);
    });
    
    _saveData(formattedPhone);
  }

  void handleSkipPhone() {
    // Clear current message
    streamCurrentBotMessage.add(null);
    
    _lynkState = LynkState.happy;
    streamLynkState.add(_lynkState);
    _botSize = 0.55;
    streamBotSize.add(_botSize);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _botSize = 0.5;
      streamBotSize.add(_botSize);
      
      // Show understanding message
      currentBotMessage = {
        'sender': 'bot',
        'text': AppLocalizations.text(LangKey.info_phone_skip_message)
      };
      streamCurrentBotMessage.add(currentBotMessage);
      _lynkState = LynkState.happy;
      streamLynkState.add(_lynkState);
      _replyLayout = BotReplyLayout.short;
      streamBotReply.add(_replyLayout);
    });
    
    _saveData('');
  }

  _saveData(String phoneNumber) async {
    // Wait for thank you message to be visible
    await Future.delayed(const Duration(seconds: 2));
    
    // Show loading dialog
    LynkLoadingDialog.show(
      context,
      message: AppLocalizations.text(LangKey.loading_registering),
      botState: LynkState.happy,
    );
    
    try {
      // Get device ID
      final deviceId = await DeviceIdService.getDeviceId();
      
      // Format birth date and extract hour
      final birthDateTime = model.dateTime;
      final birthDate = DateFormat('dd/MM/yyyy').format(birthDateTime);
      final bornHour = birthDateTime.hour;
      
      // Create register request with optional phone number
      final registerRequest = RegisterRequest(
        phoneNumber: phoneNumber.isEmpty ? null : phoneNumber.replaceAll(' ', ''), // Phone is optional
        deviceId: deviceId,
        name: model.name,
        gender: model.gender,
        birthDate: birthDate,
        bornHour: bornHour,
      );
      
      // Debug log
      debugPrint('=== REGISTER REQUEST ===');
      debugPrint('Phone: ${registerRequest.phoneNumber ?? "Not provided"}');
      debugPrint('Device ID: ${registerRequest.deviceId}');
      debugPrint('Name: ${registerRequest.name}');
      debugPrint('Gender: ${registerRequest.gender}');
      debugPrint('Birth Date: ${registerRequest.birthDate}');
      debugPrint('Born Hour: ${registerRequest.bornHour}');
      debugPrint('=======================');
      
      // Call register API
      final response = await _authRepository.register(registerRequest);
      
      // Hide loading dialog
      if (context.mounted) {
        LynkLoadingDialog.hide(context);
      }
      
      if (response.isSuccess) {
        debugPrint('=== REGISTER SUCCESS ===');
        debugPrint('Access Token: ${response.accessToken}');
        debugPrint('User ID: ${response.userId}');
        debugPrint('Session ID: ${response.sessionId}');
        debugPrint('=======================');
        
        // Save user profile using UserProfileService
        await UserProfileService.saveUserProfile(response);
        
        // Update the ProfileModel with phone number (optional)
        final updatedProfileModel = ProfileModel(
          name: model.name,
          dateTime: model.dateTime,
          gender: model.gender,
          phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
          selectedZodiac: null, // Will be set later in zodiac selection
        );
        
        // Navigate to zodiac selection
        if (context.mounted) {
          CustomNavigator.pushReplacement(
            context,
            ZodiacSelectionScreen(
              model: updatedProfileModel,
              onZodiacSelected: (zodiac) {
                print('Selected zodiac: ${zodiac.nameVi} ${zodiac.symbol}');
              },
            ),
          );
        }
      } else {
        // Show error message
        if (context.mounted) {
          LynkErrorDialog.show(context, message: response.error);
        }
      }
    } catch (e) {
      // Hide loading dialog
      if (context.mounted) {
        LynkLoadingDialog.hide(context);
      }
      
      // Show error dialog
      if (context.mounted) {
        LynkErrorDialog.show(context);
      }
      
      debugPrint('Registration error: $e');
    }
  }
}