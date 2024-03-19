import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/utils/constants.dart';

class SelectedCountryController extends GetxController {
  Rx<Country> selectedCountry = Country(
          phoneCode: "91",
          countryCode: "IN",
          e164Sc: 0,
          geographic: true,
          level: 1,
          name: "India",
          example: "India",
          displayName: "India",
          displayNameNoCountryCode: "IN",
          e164Key: "")
      .obs;

  updateSelectedCountry(value) => selectedCountry(value);
}

class IntroLoginPage extends StatelessWidget {
  final SelectedCountryController c = Get.put(SelectedCountryController());

  final TextEditingController phoneNumberController = TextEditingController();

  IntroLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: double.infinity,
                  height: 100,
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: SvgPicture.asset('assets/svg/image1.svg')),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Enter your phone number',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 10,
              ),
              Text('We will send a verification code to your phone.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              TextFormField(
                maxLength: 10,
                keyboardType: TextInputType.phone,
                cursorColor: Theme.of(context).primaryColor,
                controller: phoneNumberController,
                style: Theme.of(context).textTheme.titleMedium,
                decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    counterText: '',
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            favorite: ['IN', 'CA'],
                            showPhoneCode: true,
                            countryListTheme: const CountryListThemeData(
                              bottomSheetHeight: 550,
                              inputDecoration: InputDecoration(
                                hintText: 'Search',
                                enabledBorder: AppDefaults.outlineInputBorder,
                                focusedBorder: AppDefaults.outlineInputBorder,
                              ),
                            ),
                            onSelect: (value) {
                              c.updateSelectedCountry(value);
                            },
                          );
                        },
                        child: Obx(
                          () => (Text(
                            '${c.selectedCountry.value.flagEmoji} +${c.selectedCountry.value.phoneCode}',
                            style: Theme.of(context).textTheme.titleMedium,
                          )),
                        ),
                      ),
                    )),
              ),
              const Spacer(),
              Text(
                  'By continuing, you agree to $title\'s Terms of Use and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Continue'),
                  onPressed: () async {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber:
                          '+${c.selectedCountry.value.phoneCode}${phoneNumberController.value.text.toString()}',
                      verificationCompleted:
                          (PhoneAuthCredential credential) async {
                        await FirebaseAuth.instance
                            .signInWithCredential(credential);
                      },
                      verificationFailed: (FirebaseAuthException ex) {
                        Get.snackbar(
                          'Errr!',
                          'Error while sending verification code, please try again.',
                          duration: const Duration(seconds: 5),
                          backgroundColor: Colors.black,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        log(ex.toString());
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        Get.toNamed('/otp-verification', arguments: {
                          'phoneNumber':
                              '+${c.selectedCountry.value.phoneCode}-${phoneNumberController.value.text.toString()}',
                          'verificationId': verificationId,
                        });
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
