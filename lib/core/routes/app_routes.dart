import 'package:get/route_manager.dart';
import 'package:zruri_flutter/core/routes/unknown_page.dart';
import 'package:zruri_flutter/views/auth/intro_login_page.dart';
import 'package:zruri_flutter/views/auth/otp_verification_page.dart';
import 'package:zruri_flutter/views/onboarding/onboarding_page.dart';

class AppRoutes {
  static const String initialRoute = '/onboarding';
  static GetPage unknownGetPage =
      GetPage(name: '/', page: () => const UnknownPage());
  static List<GetPage> getPages = [
    GetPage(name: '/onboarding', page: () => const OnboardingPage()),
    GetPage(name: '/login', page: () => IntroLoginPage()),
    GetPage(name: '/otp-verification', page: () => OtpVerificationPage()),
  ];
}
