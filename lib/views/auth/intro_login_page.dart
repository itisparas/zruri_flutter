// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/utils/constants.dart';
// import 'package:zruri/views/auth/controllers/auth_controller.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class SelectedCountryController extends GetxController {
  Rx<Country> selectedCountry = Country(
    phoneCode: "1",
    countryCode: "CA",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Canada",
    example: "Canada",
    displayName: "Canada",
    displayNameNoCountryCode: "CA",
    e164Key: "",
  ).obs;

  updateSelectedCountry(value) => selectedCountry(value);
}

class IntroLoginPage extends StatelessWidget {
  final SelectedCountryController c = Get.put(SelectedCountryController());

  final TextEditingController phoneNumberController = TextEditingController();

  final AuthController authController = Get.find();

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
                  child: SvgPicture.asset('assets/svg/image1.svg'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Enter your phone number',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'We will send a verification code to your phone.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
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
                    ),
                  ),
                ),
                const Spacer(),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall,
                    children: [
                      const TextSpan(text: 'By continuing, you agree to $title\'s '),
                      TextSpan(
                        text: 'Terms of Use',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchUrl(
                                'https://zruri.dzrv.digital/terms.html',
                              ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _launchUrl(
                                'https://zruri.dzrv.digital/privacy.html',
                              ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Obx(
                      () => Text(
                        authController.isLoading.value
                            ? 'Loading...'
                            : 'Continue',
                      ),
                    ),
                    onPressed: () async {
                      var phoneNumber =
                          "${c.selectedCountry.value.phoneCode}${phoneNumberController.value.text}";
                      await authController.sendOtp(phoneNumber: phoneNumber);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open the link',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open the link',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// class IntroLoginPage extends StatelessWidget {
//   final SelectedCountryController c = Get.put(SelectedCountryController());

//   final TextEditingController phoneNumberController = TextEditingController();

//   final authController = Get.lazyPut(() => AuthController());

//   IntroLoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
