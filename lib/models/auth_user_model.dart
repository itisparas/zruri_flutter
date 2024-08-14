import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final User user;
  dynamic location;
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
      location: location ?? {},
    );
  }
}
