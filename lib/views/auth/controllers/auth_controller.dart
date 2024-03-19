import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<User?> firebaseUser;
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
}
