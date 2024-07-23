import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';
import 'package:zruri_flutter/models/auth_user_model.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  RxBool isLoading = false.obs;

  Rx<AuthUser?> firebaseUser = null.obs;
  Rx<bool> isLoggedIn = false.obs;
  Rx<String?> verificationId = ''.obs;
  Rx<PhoneNumber> phoneNumberParsed = PhoneNumber.parse('919123456789').obs;

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  void onReady() {
    super.onReady();
    firebaseUser = FirebaseAuth.instance.currentUser != null
        ? Rx<AuthUser?>(
            AuthUser.fromFirebaseUser(FirebaseAuth.instance.currentUser!),
          )
        : null.obs;

    FirebaseAuth.instance.userChanges().listen((User? user) {
      firebaseUser.value =
          user != null ? AuthUser.fromFirebaseUser(user) : null;
    });

    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(AuthUser? user) async {
    if (user == null) {
      isLoggedIn.value = false;
      Get.offAllNamed(AppRouteNames.onboarding);
    } else {
      bool userExists = await this.userExists(user.user.uid);

      isLoggedIn.value = true;

      phoneNumberParsed.value = PhoneNumber.parse(user.user.phoneNumber ?? '');

      if (userExists) {
        await updateLastLogin(user.user.uid);
        Get.offAllNamed(AppRouteNames.entrypoint);
      } else {
        await addNewUser(user.user);
        Get.offAllNamed(AppRouteNames.promptLocation);
      }
    }
  }

  Future<bool> userExists(String userId) async {
    final DocumentSnapshot doc = await _usersCollection.doc(userId).get();
    if (doc.exists) {
      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null &&
          data.containsKey('location') &&
          data['location'] != null) {
        firebaseUser.value?.address = data['location']['formattedAddress'];
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> addNewUser(User user) async {
    await _usersCollection.doc(user.uid).set({
      'phonenumber': user.phoneNumber,
      'displayname': user.displayName ?? '',
      'photourl': user.photoURL,
      'newuser': true,
      'createdAt': FieldValue.serverTimestamp(),
      'lastlogin': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLastLogin(String userUid) async {
    await _usersCollection.doc(userUid).update({
      'lastlogin': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserLocation(Map<String, dynamic> location) async {
    firebaseUser.value?.address = location['formattedAddress'];
    await _usersCollection
        .doc(firebaseUser.value?.user.uid)
        .update({'location': location}).then(
      (value) {
        log('message');
        return Get.offAllNamed(AppRouteNames.entrypoint);
      },
      onError: (e) => throw Exception(e),
    );
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
