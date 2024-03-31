import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  RxBool isLoading = false.obs;

  Rx<User?> firebaseUser = null.obs;
  Rx<bool> isLoggedIn = false.obs;
  Rx<String?> verificationId = ''.obs;
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
      Get.offAllNamed(AppRouteNames.onboarding);
    } else {
      isLoggedIn.value = true;

      phoneNumberParsed.value = PhoneNumber.parse(user.phoneNumber ?? '');

      Get.offAllNamed(AppRouteNames.entrypoint);
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
      Get.snackbar(
        AppMessages.enUs['snackbar']['error.title'],
        AppMessages.enUs['snackbar']['auth']['error']['updateDisplayName'],
        snackPosition: AppDefaults.snackPosition,
        backgroundColor: AppDefaults.snackbarBackgroundColor,
        colorText: AppDefaults.snackbarColorText,
        isDismissible: AppDefaults.isSnackbarDismissible,
        duration: AppDefaults.snackbarDuration,
      );
      throw Exception(e);
    }
  }

  // Handle sign in of user to send OTP
  Future<void> sendOtp({required String phoneNumber}) async {
    isLoading.value = true;
    try {
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
          isLoading.value = false;
          throw Exception(ex);
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId.value = verificationId;

          Get.toNamed(
            '/otp-verification',
            arguments: {
              'phoneNumber': '+$phoneNumber',
              'verificationId': verificationId,
            },
          );
          isLoading.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  // Handle on otp submit
  void handleOtpSubmit(String otp) async {
    isLoading.value = true;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value!,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
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
      isLoading.value = false;
      throw Exception(e);
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
      Get.snackbar(
        AppMessages.enUs['snackbar']['error.title'],
        AppMessages.enUs['snackbar']['auth']['error']['logout'],
        snackPosition: AppDefaults.snackPosition,
        backgroundColor: AppDefaults.snackbarBackgroundColor,
        colorText: AppDefaults.snackbarColorText,
        isDismissible: AppDefaults.isSnackbarDismissible,
        duration: AppDefaults.snackbarDuration,
      );
      throw Exception(e);
    }
  }
}
