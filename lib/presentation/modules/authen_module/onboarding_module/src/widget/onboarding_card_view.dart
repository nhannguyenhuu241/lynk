import 'package:flutter/material.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/widgets/widget.dart';
import 'package:lynk_an/presentation/modules/authen_module/onboarding_module/src/widget/onboarding_card_data.dart';

class OnboardingCardView extends StatelessWidget {
  final OnboardingCardData data;

  const OnboardingCardView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppSizes.minPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.maxPadding),
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade100,
            Colors.deepPurple.shade300,
            Colors.deepPurple.shade500,
            Colors.purple.shade900,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizes.minPadding),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.maxPadding - AppSizes.minPadding),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.maxPadding),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.maxPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.minPadding),
                      child: Image.asset(
                        data.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.maxPadding),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        CustomText(
                          text: data.title,
                          textAlign: TextAlign.center,
                          fontSize: AppTextSizes.title,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade900,
                        ),
                        SizedBox(height: AppSizes.minPadding),
                        CustomText(
                          text: data.description,
                          textAlign: TextAlign.center,
                          fontSize: AppTextSizes.subTitle,
                          color: Colors.brown.shade800,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}