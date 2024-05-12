import 'package:get/route_manager.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';
import 'package:zruri_flutter/core/routes/unknown_page.dart';
import 'package:zruri_flutter/views/auth/intro_login_page.dart';
import 'package:zruri_flutter/views/auth/otp_verification_page.dart';
import 'package:zruri_flutter/views/entrypoint/entrypoint_ui.dart';
import 'package:zruri_flutter/views/home/home.dart';
import 'package:zruri_flutter/views/landing_page/landing_page.dart';
import 'package:zruri_flutter/views/listings/ad_page.dart';
import 'package:zruri_flutter/views/location_page/input_manual_location.dart';
import 'package:zruri_flutter/views/location_page/prompt_location.dart';
import 'package:zruri_flutter/views/onboarding/onboarding_page.dart';
import 'package:zruri_flutter/views/post_ad_page/post_ad_form.dart';
import 'package:zruri_flutter/views/post_ad_page/post_ad_success.dart';

class AppRoutes {
  static const String initialRoute = '/landing';
  static GetPage unknownGetPage =
      GetPage(name: '/', page: () => const UnknownPage());
  static List<GetPage> getPages = [
    GetPage(name: '/landing', page: () => LandingPage()),
    GetPage(name: '/onboarding', page: () => const OnboardingPage()),
    GetPage(name: '/login', page: () => IntroLoginPage()),
    GetPage(name: '/otp-verification', page: () => OtpVerificationPage()),
    GetPage(name: '/entrypoint', page: () => EntrypointUI()),
    GetPage(name: '/home', page: () => const HomePage()),
    GetPage(
      name: AppRouteNames.postAdSuccessPage,
      page: () => const PostAdSuccess(),
    ),
    GetPage(
      name: AppRouteNames.adPage,
      page: () => const AdPage(),
    ),
    GetPage(
      name: AppRouteNames.postAdFormPage,
      page: () => PostAdFormPage(),
    ),
    GetPage(
      name: AppRouteNames.promptLocation,
      page: () => const PromptLocation(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRouteNames.inputManualLocation,
      page: () => InputManualLocation(),
      transition: Transition.downToUp,
    ),
  ];
}
