import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';

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

  updateUserDisplayName(String displayName) async {
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
      Get.snackbar(
        AppMessages.enUs['snackbar']['success.title'],
        AppMessages.enUs['snackbar']['auth']['success']['updateDisplayName'],
        snackPosition: AppDefaults.snackPosition,
        backgroundColor: AppDefaults.snackbarBackgroundColor,
        colorText: AppDefaults.snackbarColorText,
        isDismissible: AppDefaults.isSnackbarDismissible,
        duration: AppDefaults.snackbarDuration,
      );
    } on FirebaseAuthException catch (e) {
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: e,
        ),
        fatal: false,
      );
      Get.snackbar(
        AppMessages.enUs['snackbar']['error.title'],
        AppMessages.enUs['snackbar']['auth']['error']['updateDisplayName'],
        snackPosition: AppDefaults.snackPosition,
        backgroundColor: AppDefaults.snackbarBackgroundColor,
        colorText: AppDefaults.snackbarColorText,
        isDismissible: AppDefaults.isSnackbarDismissible,
        duration: AppDefaults.snackbarDuration,
      );
    }
  }

  // Handle sign in of user to send OTP
  void sendOtp({required String phoneNumber}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException ex) {
        Get.snackbar(
          AppMessages.enUs['snackbar']['error.title'],
          AppMessages.enUs['snackbar']['auth']['error']['otpSendFailed'],
          snackPosition: AppDefaults.snackPosition,
          backgroundColor: AppDefaults.snackbarBackgroundColor,
          colorText: AppDefaults.snackbarColorText,
          isDismissible: AppDefaults.isSnackbarDismissible,
          duration: AppDefaults.snackbarDuration,
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        Get.toNamed(
          '/otp-verification',
          arguments: {
            'phoneNumber': '+$phoneNumber',
            'verificationId': verificationId,
          },
        );
        Get.snackbar(
          AppMessages.enUs['snackbar']['success.title'],
          AppMessages.enUs['snackbar']['auth']['success']['otpSent'],
          snackPosition: AppDefaults.snackPosition,
          backgroundColor: AppDefaults.snackbarBackgroundColor,
          colorText: AppDefaults.snackbarColorText,
          isDismissible: AppDefaults.isSnackbarDismissible,
          duration: AppDefaults.snackbarDuration,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Handle on otp submit
  void handleOtpSubmit(String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: Get.arguments['verificationId'], smsCode: otp);
      await FirebaseAuth.instance.signInWithCredential(credential);
      Get.snackbar(
        AppMessages.enUs['snackbar']['success.title'],
        AppMessages.enUs['snackbar']['auth']['success']['login'],
        snackPosition: AppDefaults.snackPosition,
        backgroundColor: AppDefaults.snackbarBackgroundColor,
        colorText: AppDefaults.snackbarColorText,
        isDismissible: AppDefaults.isSnackbarDismissible,
        duration: AppDefaults.snackbarDuration,
      );
    } catch (e) {
      Get.snackbar(
        AppMessages.enUs['snackbar']['error.title'],
        AppMessages.enUs['snackbar']['auth']['error']['incorrectOtp'],
        snackPosition: AppDefaults.snackPosition,
        backgroundColor: AppDefaults.snackbarBackgroundColor,
        colorText: AppDefaults.snackbarColorText,
        isDismissible: AppDefaults.isSnackbarDismissible,
        duration: AppDefaults.snackbarDuration,
      );
    }
  }

  signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.snackbar(
        AppMessages.enUs['snackbar']['success.title'],
        AppMessages.enUs['snackbar']['auth']['success']['logout'],
        snackPosition: AppDefaults.snackPosition,
        backgroundColor: AppDefaults.snackbarBackgroundColor,
        colorText: AppDefaults.snackbarColorText,
        isDismissible: AppDefaults.isSnackbarDismissible,
        duration: AppDefaults.snackbarDuration,
      );
    } on FirebaseAuthException catch (e) {
      FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: e,
        ),
        fatal: false,
      );
      Get.snackbar(
        AppMessages.enUs['snackbar']['error.title'],
        AppMessages.enUs['snackbar']['auth']['error']['logout'],
        snackPosition: AppDefaults.snackPosition,
        backgroundColor: AppDefaults.snackbarBackgroundColor,
        colorText: AppDefaults.snackbarColorText,
        isDismissible: AppDefaults.isSnackbarDismissible,
        duration: AppDefaults.snackbarDuration,
      );
    }
  }
}
