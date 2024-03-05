import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';

class OtpVerificationPage extends StatelessWidget {
  final pinFieldController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  OtpVerificationPage({
    super.key,
  });

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
                  'We sent a 6-digit verification code to ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
