import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri/core/constants/app_defaults.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.width / 2,
      child: Container(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(75),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDefaults.padding * 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Crafted with ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  CupertinoIcons.heart_solid,
                  size: 36,
                  color: Theme.of(context).colorScheme.error,
                ),
                Text(
                  ' for',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Zruri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
