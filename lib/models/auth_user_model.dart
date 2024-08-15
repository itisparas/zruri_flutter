import 'package:firebase_auth/firebase_auth.dart';
import 'package:zruri_flutter/models/location_details.dart';

class AuthUser {
  final User user;
  Location location;
  String address;
  final bool isLoggedIn;

  AuthUser(
      {required this.user,
      required this.address,
      required this.isLoggedIn,
      required this.location});

  factory AuthUser.fromFirebaseUser(User user,
      {String? address, bool? isLoggedIn, dynamic location}) {
    return AuthUser(
      user: user,
      address: address ?? '',
      isLoggedIn: isLoggedIn ?? false,
      location: location ??
          Location(
            latitude: 37.33233141,
            longitude: -122.0312186,
            formattedAddress: '4 Infinite Loop, Cupertino, CA 95014, USA',
            locality: 'Cupertino, CA, USA',
            administrativeArea: 'Cupertino, CA, USA',
            country: 'United States',
          ),
    );
  }
}
