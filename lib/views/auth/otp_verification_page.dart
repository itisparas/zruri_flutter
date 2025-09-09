import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/core/themes/app_pin_theme.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class OtpVerificationPage extends StatelessWidget {
  final pinFieldController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  final authController = Get.put(AuthController(), permanent: true);

  OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme variables for styling the otp pin input
    final TextStyle pinTextStyle = Theme.of(
      context,
    ).textTheme.titleLarge!.copyWith(color: Theme.of(context).primaryColor);
    final PinTheme defaultPinTheme = AppPinTheme.defaultPinTheme.copyWith(
      textStyle: pinTextStyle,
    );
    final PinTheme focusedPinTheme = AppPinTheme.focusedPinTheme.copyWith(
      textStyle: pinTextStyle,
    );

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
                      const SizedBox(height: 20),
                      Text(
                        'Enter verification code',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'We sent a 6-digit verification code to ${Get.arguments['phoneNumber']}.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
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
                                  autofocus: true,
                                  focusedPinTheme: focusedPinTheme,
                                  defaultPinTheme: defaultPinTheme,
                                  showCursor: true,
                                  pinputAutovalidateMode:
                                      PinputAutovalidateMode.onSubmit,
                                  onCompleted: (pin) =>
                                      authController.handleOtpSubmit(pin),
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
                            authController.handleOtpSubmit(
                              pinFieldController.value.text.toString(),
                            );
                          },
                          child: Obx(
                            () => Text(
                              authController.isLoading.value
                                  ? 'Loading...'
                                  : 'Continue',
                            ),
                          ),
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
