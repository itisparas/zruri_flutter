import 'package:zruri_flutter/core/constants/constants.dart';
import 'package:zruri_flutter/views/onboarding/data/onboarding_model.dart';

class OnboardingData {
  static List<OnboardingModel> items = [
    OnboardingModel(
      imageUrl: AppImages.onboarding1,
      headline: 'Buddy Up, Move In',
      description: 'Roomies wanted! Let the good times roll.',
    ),
    OnboardingModel(
      imageUrl: AppImages.onboarding2,
      headline: 'Home Sweet Swipe',
      description: 'Find your cozy corner, just a swipe away!',
    ),
    OnboardingModel(
      imageUrl: AppImages.onboarding3,
      headline: 'Job Joyride',
      description: 'Hop on the job train, destination: success!',
    )
  ];
}
