import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final User user;
  String address;
  final bool isLoggedIn;

  AuthUser(
      {required this.user, required this.address, required this.isLoggedIn});

  factory AuthUser.fromFirebaseUser(User user,
      {String? address, bool? isLoggedIn}) {
    return AuthUser(
        user: user, address: address ?? '', isLoggedIn: isLoggedIn ?? false);
  }
}
