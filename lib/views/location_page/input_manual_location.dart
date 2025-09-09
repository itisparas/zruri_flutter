import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/constants/app_defaults.dart';
import 'package:zruri/views/location_page/controllers/location_controller.dart';

class InputManualLocation extends StatelessWidget {
  InputManualLocation({super.key});

  final TextEditingController searchTextField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    LocationController locationController = Get.put(LocationController());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
        title: Text('Location', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDefaults.margin),
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: searchTextField,
                googleAPIKey: locationController.googleGeocodingApiKey,
                debounceTime: 1000,
                showError: false,
                getPlaceDetailWithLatLng: (Prediction prediction) async {
                  await locationController.updateLocation(
                    determinePosition: false,
                    latitude: prediction.lat ?? '',
                    longitude: prediction.lng ?? '',
                    description: prediction.description ?? '',
                  );
                  locationController.loading.value = false;
                },
                itemClick: (Prediction prediction) {
                  locationController.loading.value = true;
                  searchTextField.text = prediction.description!;
                },
                boxDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDefaults.radius),
                ),
                inputDecoration: InputDecoration(
                  hintText: 'Search locality',
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.all(10),
                  suffixIcon: Obx(
                    () => InkWell(
                      onTap: () async {
                        if (locationController.loading.value) return;
                        await locationController.updateLocation(
                          determinePosition: true,
                        );
                      },
                      child: locationController.loading.value
                          ? const Padding(
                              padding: EdgeInsets.all(AppDefaults.padding),
                              child: SizedBox(
                                height: 10,
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  clipBehavior: Clip.hardEdge,
                                  child: CircularProgressIndicator(
                                    color: AppColors.placeholder,
                                  ),
                                ),
                              ),
                            )
                          : const Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),
                countries: const ['in', 'ca'],
                isLatLngRequired: true,
                itemBuilder: (context, index, Prediction prediction) =>
                    Container(
                      padding: const EdgeInsets.all(AppDefaults.padding),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined),
                          const SizedBox(width: 7),
                          Expanded(child: Text(prediction.description ?? "")),
                        ],
                      ),
                    ),
                isCrossBtnShown: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
