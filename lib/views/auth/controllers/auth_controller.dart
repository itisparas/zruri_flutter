import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  Rx<User?> firebaseUser = null.obs;
  Rx<bool> isLoggedIn = false.obs;
  Rx<PhoneNumber> phoneNumberParsed = PhoneNumber.parse('919123456789').obs;

  @override
  void onReady() {
    super.onReady();

    firebaseUser = Rx<User?>(FirebaseAuth.instance.currentUser);

    firebaseUser.bindStream(FirebaseAuth.instance.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    if (user == null) {
      isLoggedIn.value = false;
      Get.offAllNamed('/onboarding');
    } else {
      isLoggedIn.value = true;

      phoneNumberParsed.value = PhoneNumber.parse(user.phoneNumber ?? '');

      Get.offAndToNamed('/entrypoint');
    }
  }

  signOut() async {
    await FirebaseAuth.instance
        .signOut()
        .then(
          (value) => Get.snackbar(
            'Success!',
            "You've been successfully logged out. We'll miss you, hope to see you again back soon.",
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.black,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          ),
        )
        .onError((error, stackTrace) {
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: FirebaseAuthException,
          stack: stackTrace,
        ),
        fatal: false,
      );
      return Get.snackbar(
        'Errr!',
        'There was some issue while logging out.',
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.black,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    });
  }
}
