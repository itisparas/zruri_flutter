import 'dart:developer';

import 'package:flutter/material.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    log('Unkown page.');
    return const Scaffold(
      body: SafeArea(
        child: Text('Hello, world! 404 Unkown page.'),
      ),
    );
  }
}
