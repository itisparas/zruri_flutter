import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputManualLocation extends StatelessWidget {
  const InputManualLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              child: const Icon(Icons.close),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      body: const SafeArea(
        child: Text('data'),
      ),
    );
  }
}
