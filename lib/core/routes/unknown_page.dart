import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/views/auth/controllers/auth_controller.dart';

class UnknownPage extends StatelessWidget {
  final AuthController authController = Get.find();

  UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Text('Hello, world! 404 Unkown page.')),
    );
  }
}
