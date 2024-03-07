import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/themes/app_pin_theme.dart';

class OtpVerificationPage extends StatelessWidget {
  final pinFieldController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  OtpVerificationPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Theme variables for styling the otp pin input
    final TextStyle pinTextStyle =
        Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).primaryColor,
            );
    final PinTheme defaultPinTheme = AppPinTheme.defaultPinTheme.copyWith(
      textStyle: pinTextStyle,
    );
    final PinTheme focusedPinTheme = AppPinTheme.focusedPinTheme.copyWith(
      textStyle: pinTextStyle,
    );

    // Handle on otp submit
    void handleOtpSubmit(String otp) async {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: Get.arguments['verificationId'], smsCode: otp);
        await FirebaseAuth.instance.signInWithCredential(credential);
      } catch (e) {
        log('Error signing in with OTP: ${e.toString()}');
        Get.snackbar(
          'Errr!',
          'Invalid verification code.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    }

    // Build actual component.
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Get.arguments.containsKey('verificationId')
              ? Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 100,
                        padding: const EdgeInsets.all(AppDefaults.padding),
                        child: SvgPicture.asset('assets/svg/image1.svg'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Enter verification code',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'We sent a 6-digit verification code to ${Get.arguments['phoneNumber']}.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Center(
                                child: Pinput(
                                  length: 6,
                                  controller: pinFieldController,
                                  focusNode: focusNode,
                                  androidSmsAutofillMethod:
                                      AndroidSmsAutofillMethod
                                          .smsUserConsentApi,
                                  listenForMultipleSmsOnAndroid: true,
                                  focusedPinTheme: focusedPinTheme,
                                  defaultPinTheme: defaultPinTheme,
                                  showCursor: true,
                                  pinputAutovalidateMode:
                                      PinputAutovalidateMode.onSubmit,
                                  onCompleted: (pin) => handleOtpSubmit(pin),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            handleOtpSubmit(
                                pinFieldController.value.text.toString());
                          },
                          child: const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                )
              : const Text('Invalid page.'),
        ),
      ),
    );
  }
}
