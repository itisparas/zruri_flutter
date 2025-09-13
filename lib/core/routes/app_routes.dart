import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/route_manager.dart';
import 'package:zruri/controllers/categories_controller.dart';
import 'package:zruri/controllers/post_ad_form_controller.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/core/routes/unknown_page.dart';
import 'package:zruri/core/services/save_dynamic_form.dart';
import 'package:zruri/views/auth/intro_login_page.dart';
import 'package:zruri/views/auth/otp_verification_page.dart';
import 'package:zruri/views/chat/chat_page.dart';
import 'package:zruri/views/entrypoint/entrypoint_ui.dart';
import 'package:zruri/views/home/home.dart';
import 'package:zruri/views/auth_landing_page/auth_landing_page.dart';
import 'package:zruri/views/listings/ad_page.dart';
import 'package:zruri/views/listings/listing_page.dart';
import 'package:zruri/views/location_page/input_manual_location.dart';
import 'package:zruri/views/location_page/prompt_location.dart';
import 'package:zruri/views/onboarding/onboarding_page.dart';
import 'package:zruri/views/post_ad_page/modern_post_ad_page.dart';
import 'package:zruri/views/post_ad_page/post_ad_form.dart';
import 'package:zruri/views/post_ad_page/post_ad_success.dart';
import 'package:zruri/views/search/search_page.dart';

class AppRoutes {
  static const String initialRoute = AppRouteNames.authlanding;
  static GetPage unknownGetPage = GetPage(
    name: '/unknown',
    page: () => UnknownPage(),
  );
  static List<GetPage> getPages = [
    GetPage(name: AppRouteNames.authlanding, page: () => AuthLandingPage()),
    GetPage(name: AppRouteNames.onboarding, page: () => OnboardingPage()),
    GetPage(name: AppRouteNames.login, page: () => IntroLoginPage()),
    GetPage(
      name: AppRouteNames.otpVerification,
      page: () => OtpVerificationPage(),
    ),
    GetPage(name: AppRouteNames.entrypoint, page: () => EntrypointUI()),
    GetPage(name: AppRouteNames.home, page: () => const HomePage()),
    GetPage(name: AppRouteNames.listings, page: () => ListingPage()),
    GetPage(name: AppRouteNames.searchPage, page: () => const SearchPage()),
    GetPage(
      name: AppRouteNames.modernPostAdPage,
      page: () => ModernPostAdFormPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PostAdFormController());
        Get.lazyPut(() => CategoriesController());
        Get.lazyPut(() => SaveDynamicForm());
      }),
    ),
    GetPage(
      name: AppRouteNames.postAdSuccessPage,
      page: () => const PostAdSuccess(),
    ),
    GetPage(name: AppRouteNames.adPage, page: () => AdPage()),
    GetPage(name: AppRouteNames.postAdFormPage, page: () => PostAdFormPage()),
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
    GetPage(name: AppRouteNames.chatPage, page: () => ChatPage()),
  ];
}
