class AppRouteNames {
  static const authlanding = '/authlanding';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otpVerification = '/otp-verification';
  static const entrypoint = '/entrypoint';
  static const home = '/home';
  static const promptLocation = '/prompt-location';
  static const inputManualLocation = '/manual-location';
  static const postAdFormPageMainRoute = '/details-page/';
  static const postAdFormPage =
      '$postAdFormPageMainRoute:category/:category_id';
  static const modernPostAdPage = '/modern-post-ad';
  static const postAdSuccessPageMainRoute = '/post-ad-success/';
  static const postAdSuccessPage = '$postAdSuccessPageMainRoute:adId';
  static const adPageMainRoute = '/ad/';
  static const adPage = '$adPageMainRoute:adId';
  static const searchPage = '/search';
  static const listingPage = '/listing';
  static const listings = '$listingPage/:genre/:genre_info';
  static const chatPage = '/chat';

  categoryListing(String categoryName) {
    return '$listingPage/category_id/$categoryName';
  }
}
