class AppRouteNames {
  static const landing = '/landing';
  static const onboarding = '/onboarding';
  static const entrypoint = '/entrypoint';
  static const promptLocation = '/prompt-location';
  static const inputManualLocation = '/manual-location';
  static const postAdFormPageMainRoute = '/details-page/';
  static const postAdFormPage =
      '$postAdFormPageMainRoute:category/:category_id';
  static const postAdSuccessPageMainRoute = '/post-ad-success/';
  static const postAdSuccessPage = '$postAdSuccessPageMainRoute:adId';
  static const adPageMainRoute = '/ad/';
  static const adPage = '$adPageMainRoute:adId';
  static const searchPage = '/search';
  static const listingPage = '/listing';
  static const listings = '$listingPage/:genre/:genre_info';

  categoryListing(String categoryName) {
    return '$listingPage/category/$categoryName';
  }
}
