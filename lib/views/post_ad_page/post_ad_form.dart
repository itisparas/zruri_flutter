import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zruri_flutter/controllers/categories_controller.dart';
import 'package:zruri_flutter/core/constants/app_colors.dart';
import 'package:zruri_flutter/core/constants/app_defaults.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/services/render_form_field.dart';
import 'package:zruri_flutter/core/services/save_dynamic_form.dart';
import 'package:zruri_flutter/models/categories_model.dart';
import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_model.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class PostAdFormPage extends StatelessWidget {
  PostAdFormPage({super.key}) {
    Get.lazyPut(() => CategoriesController());
    Get.lazyPut(() => SaveDynamicForm());
  }

  final ScreenController screenController = Get.find<ScreenController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final SaveDynamicForm saveDynamicForm = Get.find<SaveDynamicForm>();
    CategoriesController categoriesController =
        Get.find<CategoriesController>();
    List<DynamicModel> formFields = []; // Declare formFields here

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppMessages.enUs['postingpage.title'],
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => !saveDynamicForm.isLoading.value
              ? Column(
                  children: [
                    Expanded(
                      child: Obx(
                        () {
                          if (categoriesController.loading.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            );
                          }
                          return CustomScrollView(
                            physics: const ClampingScrollPhysics(),
                            slivers: [
                              _renderFormFields(categoriesController,
                                  saveDynamicForm, formFields),
                              _imagePicker(saveDynamicForm),
                              _selectedImages(saveDynamicForm),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: Get.width,
                      child: Padding(
                        padding: const EdgeInsets.all(AppDefaults.padding),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                saveDynamicForm.images.isNotEmpty) {
                              // Handle form submission here
                              // For example, you can call a function to submit the form data to a server
                              // or save it locally
                              _formKey.currentState!.save();
                              saveDynamicForm.postAdForm(
                                  Get.parameters['category'],
                                  Get.parameters['category_id']);
                            } else if (!_formKey.currentState!.validate()) {
                              Get.snackbar(
                                AppMessages.enUs['snackbar']['error.title'],
                                AppMessages.enUs['snackbar']
                                    ['error.invalidform'],
                                snackPosition: AppDefaults.snackPosition,
                                backgroundColor:
                                    AppDefaults.snackbarBackgroundColor,
                                colorText: AppDefaults.snackbarColorText,
                                isDismissible:
                                    AppDefaults.isSnackbarDismissible,
                                duration: AppDefaults.snackbarDuration,
                              );
                            } else {
                              Get.snackbar(
                                AppMessages.enUs['snackbar']['error.title'],
                                AppMessages.enUs['snackbar']
                                    ['error.imagenotuploaded'],
                                snackPosition: AppDefaults.snackPosition,
                                backgroundColor:
                                    AppDefaults.snackbarBackgroundColor,
                                colorText: AppDefaults.snackbarColorText,
                                isDismissible:
                                    AppDefaults.isSnackbarDismissible,
                                duration: AppDefaults.snackbarDuration,
                              );
                            }
                          },
                          child: const Text('Post ad'),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: SizedBox(
                    height: Get.height / 2,
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                            color: AppColors.primary),
                        const SizedBox(
                          height: AppDefaults.margin / 2,
                        ),
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.titleMedium!,
                          child: AnimatedTextKit(
                            repeatForever: true,
                            animatedTexts: [
                              FadeAnimatedText(
                                  'Uploaded ${saveDynamicForm.imageUploadController.currentUploadingIndex.value.toString()} of ${saveDynamicForm.images.length} images.'),
                              FadeAnimatedText(
                                'Publishing your ad.',
                              ),
                              FadeAnimatedText('We\'re making things ready.'),
                              FadeAnimatedText('Great things, take time!'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  dynamic _renderFormFields(CategoriesController categoriesController,
      SaveDynamicForm saveDynamicForm, List<DynamicModel> formFields) {
    final categoryName = Get.parameters['category'];
    final categoryDetails = categoriesController.categories.firstWhere(
      (element) => element.name == categoryName,
      orElse: () => CategoriesModel(
        id: '',
        homepage: false,
        name: 'default',
        formFields: [],
      ),
    );

    // Add a condition to check if the category name is not "default"
    if (categoryName?.toLowerCase() != 'default') {
      saveDynamicForm.formFields.value = categoryDetails.formFields;

      return GetBuilder<SaveDynamicForm>(
        builder: (controller) {
          return Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SliverList.builder(
              itemCount: controller.formFields.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(
                  top: AppDefaults.padding,
                  left: AppDefaults.padding,
                  right: AppDefaults.padding,
                ),
                child: RenderFormField()
                    .renderFormField(controller.formFields[index]),
              ),
            ),
          );
        },
      );
    } else {
      // If the category name is "default", return an empty Container
      return Container();
    }
  }

  SliverToBoxAdapter _imagePicker(SaveDynamicForm saveDynamicForm) {
    RxBool isLoading = false.obs;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppDefaults.padding,
          left: AppDefaults.padding,
          right: AppDefaults.padding,
        ),
        child: Row(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: OutlinedButton.icon(
                onPressed: () async {
                  isLoading.value = true;
                  final List<XFile> images =
                      await ImagePicker().pickMultiImage();
                  for (XFile file in images) {
                    saveDynamicForm.images.add(File(file.path));
                  }
                  isLoading.value = false;
                },
                icon: const Icon(Icons.add),
                label: const Text('Add image(s)'),
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(
                      horizontal: AppDefaults.padding,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: AppDefaults.margin,
            ),
            Obx(
              () => isLoading.value
                  ? const CircularProgressIndicator(
                      color: AppColors.primary,
                    )
                  : Container(),
            ),
            saveDynamicForm.images.isNotEmpty
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        saveDynamicForm.images.clear();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Clear'),
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: AppDefaults.padding),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _selectedImages(SaveDynamicForm saveDynamicForm) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: SizedBox(
          height: AppDefaults.imageTileWidth,
          child: Obx(
            () => ListView.builder(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: saveDynamicForm.images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppDefaults.padding),
                  child: Image.file(
                    saveDynamicForm.images[index],
                    width: AppDefaults.imageTileWidth,
                    height: AppDefaults.imageTileWidth,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
