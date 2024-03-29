import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';

class PromptLocation extends StatefulWidget {
  const PromptLocation({super.key});

  @override
  State<PromptLocation> createState() => _PromptLocationState();
}

class _PromptLocationState extends State<PromptLocation> {
  final bool _loading = false;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location permission not enabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are denied forever, we cannot request for location permission.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: Get.height * 0.4,
              child: SvgPicture.asset('assets/svg/prompt-location.svg'),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              AppMessages.enUs['prompt.location.title'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: Get.width * .8,
              child: Text(
                AppMessages.enUs['prompt.location.description'],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge,
                overflow: TextOverflow.clip,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppDefaults.padding / 2,
                left: AppDefaults.padding,
                right: AppDefaults.padding,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.location_on_sharp),
                      label: const Text('Nearby deals'),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Get.offAndToNamed(AppRouteNames.inputManualLocation);
                      },
                      child: const Text(
                        'Set location manually',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
