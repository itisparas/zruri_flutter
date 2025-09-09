import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zruri/core/constants/constants.dart';
import 'package:zruri/views/onboarding/data/onboarding_model.dart';

class OnboardingView extends StatelessWidget {
  final OnboardingModel data;

  const OnboardingView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: Get.width - 50,
          height: Get.width - 50,
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding * 2),
            child: SvgPicture.asset(
              data.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            children: [
              Text(
                data.headline,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
