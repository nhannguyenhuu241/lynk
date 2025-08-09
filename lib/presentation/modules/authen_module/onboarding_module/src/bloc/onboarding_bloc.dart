import 'package:flutter/cupertino.dart';
import 'package:lynk_an/common/assets.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/utils/extension.dart';
import 'package:lynk_an/presentation/modules/authen_module/onboarding_module/src/widget/onboarding_card_data.dart';
import 'package:rxdart/rxdart.dart';

class OnboardingBloc {

  late BuildContext context;

  OnboardingBloc(BuildContext context) {
    this.context = context;
  }

  final streamOnBoardingData = BehaviorSubject<List<OnboardingCardData>?>();

  dispose() {
    streamOnBoardingData.close();
  }

  Future<void> onLoadOnBoardingData() async {
    final List<OnboardingCardData> cardData = [
      OnboardingCardData(
        image: Assets.imgOnBoarding_1,
        title: AppLocalizations.text(LangKey.onboarding_title_1),
        description: AppLocalizations.text(LangKey.onboarding_description_1),
      ),
      OnboardingCardData(
        image: Assets.imgOnBoarding_2,
        title: AppLocalizations.text(LangKey.onboarding_title_2),
        description: AppLocalizations.text(LangKey.onboarding_description_2),
      ),
      OnboardingCardData(
        image: Assets.imgOnBoarding_3,
        title: AppLocalizations.text(LangKey.onboarding_title_3),
        description: AppLocalizations.text(LangKey.onboarding_description_3),
      ),
    ];
    streamOnBoardingData.set(cardData);
  }

}