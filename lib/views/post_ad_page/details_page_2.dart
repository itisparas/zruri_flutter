import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zruri_flutter/controllers/categories_controller.dart';
import 'package:zruri_flutter/core/constants/app_messages.dart';
import 'package:zruri_flutter/core/constants/constants.dart';
import 'package:zruri_flutter/core/routes/app_route_names.dart';
import 'package:zruri_flutter/views/entrypoint/controllers/screen_controller.dart';

class DetailsPage2 extends StatelessWidget {
  final ScreenController screenController = Get.put(ScreenController());
  final CategoriesController categoriesController = Get.find();

  DetailsPage2({super.key});

  final _formKey = GlobalKey<FormState>();
  final FocusNode focusNode = FocusNode();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      log('Validated Form');
      _formKey.currentState!.save();
      // log the value of field 'title' in the form.
      log(_formKey.currentState.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    log(categoriesController.categories.toList().toString());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              screenController.onChange(2);
              Get.offAllNamed(AppRouteNames.entrypoint);
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
            Text(categoriesController.categories.toList().toString()),
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
                      TextFormField(
                        key: const Key('title'),
                        decoration: const InputDecoration(
                          hintText: 'Title of the ad',
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (term) {
                          FocusScope.of(context).requestFocus(focusNode);
                        },
                        autofocus: true,
                      ),
                      const SizedBox(
                        height: AppDefaults.margin,
                      ),
                      TextFormField(
                        key: const Key('description'),
                        decoration: const InputDecoration(
                          hintText: 'Description of your ad',
                          isDense: true,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        focusNode: focusNode,
                        textInputAction: TextInputAction.done,
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
