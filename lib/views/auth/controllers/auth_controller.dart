import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/constants/app_messages.dart';
import 'package:zruri/core/routes/app_route_names.dart';
import 'package:zruri/main.dart';
import 'package:zruri/models/auth_user_model.dart';
import 'package:zruri/models/location_details.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  RxBool isLoading = true.obs;

  final firebaseUser = Rx<AuthUser?>(null);
  Rx<bool> isLoggedIn = false.obs;
  Rx<String?> verificationId = ''.obs;
  Rx<PhoneNumber> phoneNumberParsed = PhoneNumber.parse('919123456789').obs;

  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  @override
  void onReady() {
    super.onReady();

    print('AuthController onReady');

    FirebaseAuth.instance.userChanges().listen((User? user) {
      firebaseUser.value = user != null
          ? AuthUser.fromFirebaseUser(user)
          : null;
    });

    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user != null) {
        firebaseUser.value = AuthUser.fromFirebaseUser(user);
      } else {
        firebaseUser.value = null;
      }
    });

    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(AuthUser? user) async {
    if (user == null) {
      Get.offAllNamed(AppRouteNames.onboarding);
      isLoggedIn.value = false;
      isLoading.value = false;
    } else {
      bool userExists = await this.userExists(user.user.uid);

      isLoggedIn.value = true;

      phoneNumberParsed.value = PhoneNumber.parse(user.user.phoneNumber ?? '');

      if (userExists) {
        await updateLastLogin(user.user.uid);
        Get.offAllNamed(AppRouteNames.entrypoint);
        isLoading.value = false;
      } else {
        await addNewUser(user.user);
        Get.offAllNamed(AppRouteNames.promptLocation);
        isLoading.value = false;
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
        // Convert the map to a Location object
        Location location = Location.fromMap(data['location']);
        firebaseUser.value?.location = location;
        firebaseUser.value?.address = location.formattedAddress;
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

  Future<void> updateUserLocation(Location location) async {
    firebaseUser.value?.location = location;
    firebaseUser.value?.address = location.formattedAddress;
    print(location.latitude.runtimeType);
    await _usersCollection
        .doc(firebaseUser.value?.user.uid)
        .update({'location': location.toMap()})
        .then((value) {
          return Get.offAllNamed(AppRouteNames.entrypoint);
        }, onError: (e) => throw Exception(e));
  }

  updateUserDisplayName(String displayName) async {
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
      await _usersCollection.doc(FirebaseAuth.instance.currentUser?.uid).update(
        {'displayname': FirebaseAuth.instance.currentUser?.displayName},
      );
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
      await auth.verifyPhoneNumber(
        phoneNumber: '+$phoneNumber',
        verificationCompleted: (_) {},
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
            AppRouteNames.otpVerification,
            arguments: {
              'phoneNumber': '+$phoneNumber',
              'verificationId': verificationId,
            },
          );
          isLoading.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId.value = verificationId;
          isLoading.value = false;
        },
        timeout: const Duration(seconds: 120),
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
      Get.offAll(AppRouteNames.authlanding);
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
