import 'package:get/route_manager.dart';
import 'package:zruri_flutter/views/auth/intro_login_page.dart';
import 'package:zruri_flutter/views/onboarding/onboarding_page.dart';

class AppRoutes {
  static const String initialRoute = '/';
  static List<GetPage> getPages = [
    GetPage(name: '/', page: () => const OnboardingPage()),
    GetPage(name: '/login', page: () => const IntroLoginPage())
  ];
}
