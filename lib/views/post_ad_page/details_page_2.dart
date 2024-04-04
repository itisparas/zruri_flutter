import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/controllers/categories_controller.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/constants/constants.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';
import 'package:zruri_flutter/core/services/render_form_field.dart';
import 'package:zruri_flutter/models/categories_model.dart';
import 'package:zruri_flutter/models/dynamic-form-models/dynamic_form_model.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class DetailsPage2 extends GetView<CategoriesController> {
  final ScreenController screenController = Get.put(ScreenController());
  // final CategoriesController categoriesController =
  //     Get.put(CategoriesController());

  DetailsPage2({super.key});

  final _formKey = GlobalKey<FormState>();
  final FocusNode focusNode = FocusNode();
  final RenderFormField renderFormField = RenderFormField();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          CategoriesModel categoryDetails =
                              controller.categories.firstWhere((element) =>
                                  element.name == Get.parameters['category']);
                          List<DynamicModel> formFields =
                              categoryDetails.formFields;
                          return Expanded(
                            // Added Expanded widget here
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
                                    ), // Added SizedBox here
                                  ],
                                );
                              },
                            ),
                          );
                        },
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
