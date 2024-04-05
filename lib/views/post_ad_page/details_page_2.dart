import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zruri_flutter/controllers/categories_controller.dart';
import 'package:zruri_flutter/controllers/image_upload.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/constants/constants.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';
import 'package:zruri_flutter/core/services/firebase_storage_service.dart';
import 'package:zruri_flutter/core/services/render_form_field.dart';
import 'package:zruri_flutter/models/categories_model.dart';
import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_model.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class DetailsPage2 extends StatelessWidget {
  final ScreenController screenController = Get.put(ScreenController());

  DetailsPage2({super.key});

  final _formKey = GlobalKey<FormState>();
  final FocusNode focusNode = FocusNode();
  final RenderFormField renderFormField = RenderFormField();
  final FirebaseStorageService storageService = FirebaseStorageService();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageUploadController imageUploadController =
        Get.put(ImageUploadController());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              screenController.onChange(2);
              Get.offNamed(AppRouteNames.entrypoint);
            },
            icon: const Icon(Icons.close),
          ),
        ],
        title: Text(
          AppMessages.enUs['postingpage.title'],
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDefaults.padding,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () {
                          CategoriesModel? categoryDetails;
                          List<DynamicModel> formFields = [];
                          final categoriesController =
                              Get.put<CategoriesController>(
                                  CategoriesController());
                          final categoryName = Get.parameters['category'];
                          if (categoryName != null) {
                            categoryDetails =
                                categoriesController.categories.firstWhere(
                              (element) => element.name == categoryName,
                              orElse: () => CategoriesModel(
                                id: '',
                                homepage: false,
                                name: 'default',
                                formFields: [],
                              ),
                            );
                            formFields = categoryDetails.formFields;
                          }
                          return Expanded(
                            child: ListView.builder(
                              itemCount: formFields.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    renderFormField.getTextFormFieldWidget(
                                      formFields[index],
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          Obx(
                            () => imageUploadController.uploading.value
                                ? const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  )
                                : IconButton.outlined(
                                    onPressed: imageUploadController
                                            .uploading.value
                                        ? null
                                        : () async {
                                            final List<XFile> images =
                                                await ImagePicker()
                                                    .pickMultiImage();
                                            final List<File> imageFiles =
                                                <File>[];
                                            for (XFile image in images) {
                                              imageFiles.add(File(image.path));
                                            }
                                            await imageUploadController
                                                .uploadImages(
                                              files: imageFiles,
                                              dirName: 'ads',
                                              userSpecific: true,
                                            );
                                          },
                                    icon: const Icon(Icons.add),
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              AppDefaults.borderRadius,
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        AppColors.scaffoldWithBoxBackground,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(
                            width: AppDefaults.margin,
                          ),
                          Obx(
                            () => imageUploadController.images.isEmpty
                                ? const Text('No image selected.')
                                : Container(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: AppDefaults.margin,
                      ),
                      Expanded(
                        child: Obx(
                          () => imageUploadController.images.isEmpty
                              ? Container()
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: AppDefaults.imageTilesCount,
                                  ),
                                  itemCount:
                                      imageUploadController.images.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: CachedNetworkImage(
                                            imageUrl: imageUploadController
                                                .images[index],
                                            placeholder: (context, url) =>
                                                const SpinKitCircle(
                                              color: AppColors.primary,
                                            ),
                                            fit: BoxFit.cover,
                                            width: AppDefaults.imageTilesWidth,
                                            height: AppDefaults.imageTilesWidth,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              AppDefaults.imageTilesGutterWidth,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(
                  AppDefaults.padding,
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Post'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
