
import 'package:flutter/material.dart';
import 'package:lynk_an/common/assets.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/utils/custom_navigator.dart';
import 'package:lynk_an/common/utils/extension.dart';
import 'package:lynk_an/common/widgets/widget.dart';
import 'package:lynk_an/presentation/modules/authen_module/onboarding_module/src/bloc/onboarding_bloc.dart';
import 'package:lynk_an/presentation/modules/authen_module/onboarding_module/src/widget/onboarding_card_data.dart';
import 'package:lynk_an/presentation/modules/authen_module/onboarding_module/src/widget/onboarding_card_view.dart';
import 'package:lynk_an/presentation/modules/main_modules/information_module/src/ui/information_name_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  late OnboardingBloc _bloc;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _bloc = OnboardingBloc(context);
    _bloc.onLoadOnBoardingData();

    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.8,
    );

    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackground(context),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Image.asset(
              Assets.imgBackground2,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
            StreamBuilder(
                stream: _bloc.streamOnBoardingData.output,
                initialData: [],
                builder: (context, snapshot) {
                  List<OnboardingCardData>? cardData = (snapshot.data ?? []).cast<OnboardingCardData>();
                return Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: cardData.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (_pageController.position.haveDimensions) {
                                value = _pageController.page! - index;
                                value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                              }
                              return Center(
                                child: SizedBox(
                                  height: Curves.easeOut.transform(value) * 500,
                                  width: Curves.easeOut.transform(value) * 350,
                                  child: child,
                                ),
                              );
                            },
                            child: OnboardingCardView(
                              data: cardData[index],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.maxPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          cardData.length,
                              (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: EdgeInsets.symmetric(horizontal: AppSizes.minPadding),
                            height: AppSizes.minPadding,
                            width: _currentPage == index ? AppSizes.lagePadding : AppSizes.minPadding,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppTheme.getPrimary(context)
                                  : AppColors.neutral400,
                              borderRadius: BorderRadius.circular(AppSizes.radius),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          AppSizes.lagePadding,
                          0,
                          AppSizes.lagePadding,
                          AppSizes.lagePadding
                      ),
                      child: LiquidGlassButton(
                        onPressed: () {
                          if (_currentPage == cardData.length - 1) {
                            CustomNavigator.pushReplacement(context, InformationNameScreen());
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        text: _currentPage == cardData.length - 1
                            ? AppLocalizations.text(LangKey.startFlexing)
                            : AppLocalizations.text(LangKey.continueString),
                      ),
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}