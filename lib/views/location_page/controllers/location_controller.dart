import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'package:zruri_flutter/core/services/location_service.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

class LocationController extends GetxController {
  AuthController authController = Get.find<AuthController>();

  final String googleGeocodingApiKey =
      'AIzaSyAgiJfKNjXdZyG2lPjM_xehFgxnlCZO6_E';
  bool isDebugMode = kDebugMode;
  late GoogleGeocodingApi api;

  LocationService serviceInstance = LocationService();

  RxBool loading = false.obs;

  LocationController() {
    api = GoogleGeocodingApi(googleGeocodingApiKey, isLogged: isDebugMode);
  }

  Future<void> updateLocation({
    required bool determinePosition,
    String latitude = '',
    String longitude = '',
    String description = '',
  }) async {
    loading.value = true;
    if (determinePosition) {
      Position position = await serviceInstance.determinePosition();
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    }
    GoogleGeocodingResponse geocodingResponse = await api.reverse(
      '$latitude,$longitude',
      language: 'en',
    );
    Map<String, dynamic> location = {
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': description == ''
          ? geocodingResponse.results.first.formattedAddress
          : description,
      'locality': geocodingResponse.results
          .firstWhere((GoogleGeocodingResult element) =>
              element.types.any((element) => element == 'locality'))
          .formattedAddress,
      'administrativeArea': geocodingResponse.results
          .firstWhere(
            (GoogleGeocodingResult element) => element.types.any(
              (element) =>
                  element == 'administrative_area_level_7' ||
                  element == 'administrative_area_level_6' ||
                  element == 'administrative_area_level_5' ||
                  element == 'administrative_area_level_4' ||
                  element == 'administrative_area_level_3' ||
                  element == 'administrative_area_level_2' ||
                  element == 'administrative_area_level_1' ||
                  element == 'locality',
            ),
          )
          .formattedAddress,
      'country': geocodingResponse.results
          .firstWhere(
              (element) => element.types.any((element) => element == 'country'))
          .formattedAddress,
    };
    await authController.updateUserLocation(location);
    loading.value = false;
  }
}
