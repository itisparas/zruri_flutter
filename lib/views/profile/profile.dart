import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:zruri_flutter/core/constants/app_colors.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class Profile extends StatelessWidget {
  final TextEditingController displayNameController = TextEditingController(
    text: 'Zruri user',
  );
  final TextEditingController phoneNumberController = TextEditingController();

  Profile({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.find();
    ScreenController screenController = Get.find();

    FirebaseAuth.instance.authStateChanges().listen(
      (event) {
        if (event != null) {
          displayNameController.setText(event.displayName ?? 'Zruri user');
          phoneNumberController.setText(event.phoneNumber ?? '');
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            screenController.gotoPrevPage();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDefaults.padding),
                  child: Text(
                    'Basic information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDefaults.padding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(right: AppDefaults.padding),
                        child: CircularProfileAvatar(
                          'https://i.pravatar.cc/300',
                          placeHolder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                          radius: 50,
                          cacheImage: true,
                        ),
                      ),
                      SizedBox(
                        width: Get.width - AppDefaults.padding * 3 - 100,
                        child: TextFormField(
                          controller: displayNameController,
                          style: Theme.of(context).textTheme.titleMedium,
                          decoration: const InputDecoration(isDense: true),
                          onEditingComplete: () async {
                            await authController.updateUserDisplayName(
                              displayNameController.text,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Contact information section START
                Padding(
                  padding: const EdgeInsets.only(top: AppDefaults.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppDefaults.padding),
                        child: Text(
                          'Contact information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextFormField(
                        controller: phoneNumberController,
                        readOnly: true,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          helperMaxLines: 1,
                          helperText: 'Boom! Your phone number is verified.',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(
                        height: AppDefaults.margin,
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppDefaults.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppDefaults.padding),
                        child: Text(
                          'Additional information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Text(
                        'User information like joining date and number of ad posts will be displayed here before launch of the application.',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            authController.signOut();
                          },
                          child: const Text('Logout'),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Center(
                        child: Text('Vyrbix 1.0.0'),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
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
