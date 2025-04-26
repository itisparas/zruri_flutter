import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/views/auth/controllers/auth_controller.dart';

class AuthLandingPage extends StatelessWidget {
  AuthLandingPage({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () {
            if (authController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return authController.isLoggedIn.value
                  ? const Text('logged in')
                  : ElevatedButton(
                      onPressed: () => {authController.signOut()},
                      child: const Text('Logout'));
            }
          },
        ),
      ),
    );
  }
}
